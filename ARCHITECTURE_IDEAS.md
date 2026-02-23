Especificação Técnica: Arquitetura e Implementação da Plataforma de Comunidades

1. Visão Geral da Arquitetura e Fluxo de Dados

Para sustentar uma plataforma de comunidades de alta performance, a arquitetura deve ser desenhada focando em baixa latência e alta disponibilidade. Optamos pelo Ruby on Rails utilizando a stack "Solid" (Solid Queue, Solid Cache e Solid Cable), uma abordagem moderna que elimina a dependência de serviços externos como Redis, centralizando a persistência no PostgreSQL. Esta decisão simplifica a infraestrutura e reduz a latência de rede, utilizando o banco de dados para gerenciar filas de processamento, cache de fragmentos e comunicação via WebSockets.

A interação entre esses componentes garante resiliência: o Solid Queue isola tarefas pesadas (IA e analytics), o Solid Cache mitiga gargalos de leitura em dados agregados (como o ranking de engajamento), e o Solid Cable provê interatividade em tempo real. Essa base sustenta uma lógica de negócios onde a integridade dos dados e a experiência do usuário caminham juntas, permitindo que a aplicação escale vertical e horizontalmente sem os custos de complexidade de microserviços prematuros.

---

2. Lógica de Negócios (Padrões de Implementação Ruby)

Abaixo, detalhamos a implementação lógica das regras críticas, focando em atomicidade e eficiência de consulta.

1. Criação de Mensagem com Estado e Auto-provisionamento

# POST /api/v1/messages

# Gerencia a criação do usuário 'on-the-fly' e inicia o ciclo de vida da IA

```ruby
def create_message(params)
  Transaction do
    user = User.find_or_create_by!(username: params[:username])
    message = Message.create!(
      user: user,
      community_id: params[:community_id],
      content: params[:content],
      user_ip: params[:user_ip],
      parent_message_id: params[:parent_message_id],
      ai_status: :pending # Enum: [pending, processed, failed]
    )

    # Disparo assíncrono via Solid Queue
    AnalyzeSentimentJob.perform_later(message.id)
    return message
  end
end
```

2. Reação com Proteção de Concorrência

# POST /api/v1/reactions

# Uso de Pessimistic Locking e Database Constraints para garantir unicidade

```ruby
def add_reaction(params)
  Message.find(params[:message_id]).with_lock do # A constraint UNIQUE [message_id, user_id, reaction_type] no DB é a última linha de defesa
    reaction = Reaction.create!(params)
    broadcast_reaction_counts(params[:message_id])
  end
rescue ActiveRecord::RecordNotUnique
  raise CustomErrors::AlreadyReacted, "Usuário já reagiu com este tipo"
end
```

3. Ranking de Engajamento (Prevenção de N+1)

# GET /top - Engajamento = (reactions _ 1.5) + (replies _ 1.0)

# Apenas posts principais (parent_id: nil) entram no ranking global

```ruby
def top_messages(community_id, limit = 10)
  Message.where(community_id: community_id, parent_message_id: nil)
    .includes(:user) # Evita N+1 para o autor
    .left_joins(:reactions, :replies)
    .group(:id)
    .select("messages.*,
      (COUNT(DISTINCT reactions.id) * 1.5 +
      COUNT(DISTINCT replies.id) * 1.0) AS engagement_score,
      COUNT(DISTINCT reactions.id) as reaction_count,
      COUNT(DISTINCT replies.id) as reply_count")
    .order("engagement_score DESC")
    .limit(limit)
end
```

4. Detecção de IPs Suspeitos

# GET /analytics/suspicious_ips?min_users=3

```ruby
def suspicious_ips(min_users = 3)
  Message.group(:user_ip)
    .having("COUNT(DISTINCT user_id) >= ?", min_users)
    .select("user_ip as ip,
      COUNT(DISTINCT user_id) as user_count,
      ARRAY_AGG(DISTINCT users.username) as usernames")
    .joins(:user)
end
```

---

3. Matriz de Requisições e Casos de Teste (API & Interface)

A integridade do sistema é validada pela paridade entre testes de request (API) e testes de sistema (Hotwire/DOM).

| Contexto            | Request API (JSON)            | Interação UI (Hotwire)        | Resultado Esperado (Status/DOM)                            |
| :------------------ | :---------------------------- | :---------------------------- | :--------------------------------------------------------- |
| Criação Post        | POST /messages                | Preencher form e submit       | 201 Created; Novo turbo-frame na timeline.                 |
| Resposta (Reply)    | POST /messages (c/ parent_id) | Clicar em "Responder" no post | 201 Created; Comentário indentado via Turbo Stream.        |
| Reação Duplicada    | POST /reactions               | Clicar em "Like" já ativo     | 422 Unprocessable; Toast notification de erro.             |
| Ranking Top N       | GET /top?limit=5              | Aba "Destaques"               | 200 OK; Lista ordenada por engagement_score.               |
| IP Fraudulento      | GET /suspicious_ips           | Painel Admin                  | 200 OK; Tabela com usernames agregados por IP.             |
| Recurso Inexistente | GET /messages/999             | Link quebrado                 | 404 Not Found; Renderização de página de erro customizada. |

---

4. Estratégia de Indexação e Escalabilidade de Dados

O desempenho sob carga pesada em PostgreSQL depende da minimização de Full Table Scans. Nossa estratégia inclui:

1. Chaves Estrangeiras: Índices B-Tree em messages(user_id, community_id) e messages(parent_message_id) para acelerar a montagem de threads e navegação.
2. Constraint de Unicidade: Índice Composto Único em reactions(message_id, user_id, reaction_type). Este índice é vital para a performance de escrita, permitindo que o DB rejeite duplicatas em tempo logarítmico.
3. Índice de Cobertura para Ranking: Índice parcial ou composto que inclua as colunas de agregação para otimizar o cálculo de engagement_score em comunidades volumosas.
4. Índice de Auditoria: Índice em messages(user_ip) para garantir que a consulta de segurança não degrade conforme a tabela cresce para milhões de registros.

---

5. Integração OpenAI via Stack "Solid"

Para evitar o bloqueio de threads de execução (Request Timeout), utilizamos um fluxo assíncrono rigoroso:

1. Persistence Layer: A mensagem é salva com ai_status: :pending. O usuário recebe resposta imediata.
2. Solid Queue: Um job é enfileirado. Ele recupera a mensagem e gera um cache_key baseado no hash do content.
3. Solid Cache: Antes de chamar a OpenAI, o job verifica se o score para aquele conteúdo já foi processado anteriormente (economia de tokens e tempo).
4. OpenAI API: O job executa a chamada, atualiza o ai_sentiment_score e altera o status para :processed.
5. Solid Cable: Um Turbo::StreamsChannel.broadcast_replace_to é disparado. O componente de badge de sentimento na UI do usuário é substituído em tempo real, sem necessidade de refresh.

---

6. Prototipagem de Interface (Hotwire & Stimulus)

A interface utiliza Hotwire para manter o estado do servidor sincronizado com o cliente de forma declarativa.

Componente: Post Principal (\_message.html.erb)

```html
<turbo-frame id="message_<%= message.id %>">
  <div class="p-4 border shadow-sm" data-controller="sentiment">
    <header class="flex justify-between">
      <span class="font-bold text-indigo-700"
        >@<%= message.user.username %></span
      >
      <!-- Stream listener para o score da IA -->
      <%= turbo_stream_from message, :sentiment %>
      <div id="sentiment_badge_<%= message.id %>">
        <% if message.pending? %>
        <span class="animate-pulse bg-gray-200">Analisando...</span>
        <% else %> <%= render "messages/sentiment_badge", score:
        message.ai_sentiment_score %> <% end %>
      </div>
    </header>

    <p class="py-2"><%= message.content %></p>

    <footer class="flex gap-4" data-controller="reactions">
      <button data-action="click->reactions#submit" data-type="like">
        👍
        <span id="count_like_<%= message.id %>"><%= message.like_count %></span>
      </button>
    </footer>
  </div>
</turbo-frame>
```

Comportamento Dinâmico:

- Stimulus Controller (form_controller.js): Utiliza o evento turbo:submit-success para realizar o reset() do formulário de mensagens e focar no campo de texto novamente.
- Real-time Update: O turbo_stream_from estabelece a conexão via Solid Cable, permitindo que o servidor "empurre" o badge de sentimento e as atualizações de contagem de reações assim que os jobs de background terminarem, garantindo uma experiência de SPA (Single Page Application) com a simplicidade do Rails.

Este blueprint assegura que a implementação atenda a todos os requisitos do desafio técnico, mantendo a simplicidade arquitetural e a performance exigida para uma plataforma moderna de comunidades.

### Fundamentos de Modelagem Relacional: O Coração das Comunidades Digitais

Bem-vindo à arquitetura por trás das interações sociais. Quando você posta um comentário em uma comunidade, não está apenas enviando texto; você está alimentando uma estrutura lógica projetada para garantir que a informação chegue ao lugar certo, seja atribuída à pessoa correta e possa ser recuperada com velocidade.

Como Especialista em Engenharia de Dados, convido você a explorar como transformamos o caos das interações humanas em uma estrutura organizada e inteligente.

---

1. O Mapa do Tesouro: O que é um Banco de Dados Relacional?

Imagine que um banco de dados relacional é como uma cidade planejada. Nesta cidade, as informações não ficam espalhadas; elas vivem em "casas" específicas chamadas Tabelas. Cada casa tem um propósito (uma para moradores, outra para praças, outra para registros de mensagens).

Para que a cidade funcione, essas casas precisam estar conectadas por "estradas" chamadas Relacionamentos. Sem essas estradas, o morador não encontraria sua praça, e a mensagem nunca chegaria ao seu destino. A estrutura relacional é ideal para uma plataforma de comunidades porque ela garante a integridade: nada se perde, e cada peça de informação sabe exatamente a quem pertence.

"O propósito central de um banco de dados relacional é criar uma fonte única de verdade, onde os dados são organizados sem redundância e as conexões entre eles refletem a lógica do mundo real através de regras rígidas de integridade."

Para entender essa cidade, precisamos primeiro conhecer seus habitantes fundamentais.

---

2. Os Pilares: Entidades Users e Communities

Toda comunidade digital começa com duas fundações: quem participa e onde participam. No nosso modelo, estas são as "casas" Users (Usuários) e Communities (Comunidades).

Cada registro precisa de uma identidade única, a Chave Primária (PK). Em grandes sistemas, você pode ver IDs como Inteiros (sequenciais e rápidos) ou UUIDs (longos e globalmente únicos). No nosso projeto, o uso de Inteiros facilita a leitura e performance inicial. Além disso, aplicamos a restrição UNIQUE em atributos como o username e o name da comunidade.

Por que isso é vital? Tecnicamente, impedir duplicidade evita ambiguidades. Se dois cidadãos tivessem o mesmo "registro geral", o sistema não saberia a quem entregar uma notificação. O banco de dados bloqueia essa tentativa na raiz.

Estrutura da Tabela: Users (Os Moradores)

Atributo Tipo de Dado Por que é importante?
id (PK) Inteiro A identidade única e imutável de cada usuário.
username String (Unique) Identificador exclusivo para login e menções.
created_at Timestamp Registro de quando o usuário entrou na "cidade".

Estrutura da Tabela: Communities (Os Bairros)

Atributo Tipo de Dado Por que é importante?
id (PK) Inteiro Identificador único da comunidade.
name String (Unique) O nome público do espaço de discussão.
description Text Detalha o propósito e as regras da comunidade.
created_at Timestamp Data de fundação do espaço.

---

3. O Elo de Ligação: A Tabela Messages e as Chaves Estrangeiras (FK)

A tabela Messages é o centro pulsante da cidade, onde a conversa acontece. Para que o banco saiba quem escreveu e onde a mensagem reside, utilizamos as Chaves Estrangeiras (Foreign Keys - FK), que funcionam como endereços precisos.

- user_id (FK): Uma ponte que aponta para o autor na tabela Users.
- community_id (FK): Uma ponte que aponta para o local na tabela Communities.
- user_ip: Capturamos o IP (ex: "192.168.1.1") para permitir auditorias de segurança, como detectar se múltiplos usuários estão operando a partir de uma mesma origem (potencial fraude).

O Conceito de Threads e o Auto-relacionamento

Um detalhe avançado de engenharia aqui é o campo parent_message_id. Ele é uma Self-Referencing Foreign Key (Chave Estrangeira Auto-referenciada). Isso significa que uma linha na tabela de mensagens pode apontar para outra linha na mesma tabela.

- Mensagem Raiz (Post) -> parent_message_id é NULL.
  - Resposta 1 -> parent_message_id aponta para o ID da Raiz.
    - Sub-resposta -> parent_message_id aponta para o ID da Resposta 1.

Essa hierarquia permite que a interface web renderize conversas encadeadas de forma lógica.

---

4. Regras de Engajamento: Reactions e o "Bilhete Único"

A interação se estende às reações: 'like', 'love' e 'insightful'. Na tabela Reactions, aplicamos a regra: "Um cidadão só pode ter um tipo de bilhete para cada atração".

Para garantir que um usuário não infle artificialmente a popularidade de um post, o banco utiliza uma Restrição Única Composta nos campos [message_id, user_id, reaction_type].

💡 Dica do Especialista: Esta restrição é a sua última linha de defesa. Em sistemas de alta escala, dois pedidos de "like" podem chegar ao servidor no exato mesmo milissegundo (concorrência). Sem essa regra no nível do banco de dados (usando transactions ou constraints), o sistema poderia aceitar ambos, gerando dados duplicados e métricas falsas. O banco de dados garante que, se a regra for violada, a transação seja abortada imediatamente.

---

5. Transformando Dados em Inteligência: Sentimento e Engajamento

Com os dados organizados, a cidade passa a gerar indicadores de saúde e relevância.

Clima Emocional: AI Sentiment Score

O campo ai_sentiment_score armazena um valor entre -1.0 (extremamente negativo) e 1.0 (extremamente positivo). Um valor de 0.0 indica um sentimento neutro. Isso permite que moderadores identifiquem rapidamente comunidades em conflito sem ler cada linha de texto.

O Ranking de Engajamento

Para determinar quais mensagens devem aparecer no topo (Endpoint /top), aplicamos uma fórmula ponderada que valoriza o esforço da interação:

Fórmula de Engajamento: (Reaction Count _ 1.5) + (Reply Count _ 1.0)

Exemplo de Ranking (Visualização do Endpoint):

Mensagem Reaction Count Reply Count Cálculo de Engajamento Score Final
"Amo esta stack!" 20 5 (20 _ 1.5) + (5 _ 1.0) 35.0
"Dúvida técnica" 5 15 (5 _ 1.5) + (15 _ 1.0) 22.5
"Bom dia!" 2 1 (2 _ 1.5) + (1 _ 1.0) 4.0

---

6. Do Modelo à Realidade: Por que a Modelagem Importa?

Uma modelagem bem feita é o que separa um protótipo de uma aplicação pronta para o mundo real. Os benefícios principais são:

1. Integridade Inabalável: As restrições garantem que não existam mensagens sem autor ("órfãs") ou reações infinitas de um mesmo usuário.
2. Performance em Escala: Ao definir Chaves Estrangeiras e Índices corretamente, o banco consegue realizar buscas complexas (como o ranking de engajamento) em milissegundos, mesmo com milhões de mensagens.
3. Segurança e Auditoria: Através de campos como user_ip, o modelo de dados suporta ferramentas de analytics para detectar comportamentos suspeitos e fraudes.

Dominar esses fundamentos é o primeiro passo para se tornar um arquiteto de soluções robustas. Lembre-se: o código define como o sistema se comporta, mas o banco de dados define o que o sistema sabe. Cuide bem da sua estrutura!

### Guia de Lógica de Negócio: Transformando Comportamento em Dados Mensuráveis

1. Introdução: A Ponte entre Interação e Algoritmo

No desenvolvimento de sistemas modernos, a Lógica de Negócio atua como o sistema nervoso de uma aplicação. Como engenheiros, não lidamos apenas com strings e inteiros; lidamos com intenções humanas. Quando um usuário clica em "curtir" ou escreve um comentário, ele está gerando um sinal de valor. Nosso papel é traduzir esse comportamento subjetivo em dados estruturados e métricas quantitativas.

Pense no código como um tradutor simultâneo em uma conferência internacional. O usuário fala a "língua da interação" (sentimentos, cliques, conexões), e o sistema precisa traduzi-la instantaneamente para a "língua da decisão" (rankings, pontuações de crédito, indicadores de fraude). Um desenvolvedor que não entende a lógica por trás do algoritmo é apenas um digitador de sintaxe; o desenvolvedor orientado a produtos é aquele que entende como cada linha de código protege a integridade e a relevância do ecossistema de dados.

Transição: Essa tradução começa no nível atômico da comunicação: o texto. Vamos desconstruir como capturamos a intenção por trás das palavras.

---

2. Análise de Sentimento: Decifrando o Texto

O campo ai_sentiment_score é um float que varia de -1.0 (extremamente negativo) a 1.0 (extremamente positivo). Ele é a representação numérica da "temperatura" de uma mensagem. No contexto deste projeto, podemos abordar essa métrica de duas formas:

Comparativo de Implementação

Característica Opção 1: Simulação por Palavras-Chave Opção 2: Integração com IA Real
Complexidade Baixa: Lógica algorítmica local. Alta: Requer integração com APIs externas.
Arquitetura Determinística e rápida. Estocástica e sujeita a latência de rede.
Custo Operacionalmente nulo. Geralmente baseado em tokens (ex: OpenAI).
Precisão Limitada (não detecta sarcasmo ou contexto). Alta (entende nuances semânticas complexas).

A Matemática da Simulação (Business Logic)

Para a Opção 1, definimos conjuntos estritos de termos baseados em requisitos de negócio:

- POSITIVE_WORDS: 'ótimo', 'excelente', 'legal', 'bom', 'adorei', 'incrível'.
- NEGATIVE_WORDS: 'ruim', 'péssimo', 'horrível', 'terrível', 'odeio'.

A fórmula aplicada é: \text{Score} = \frac{\text{positivo} - \text{negativo}}{\text{total de termos identificados}}

Exemplo de Processamento: Imagine o texto: "Adorei este conteúdo, mas o vídeo é ruim".

```ruby
# Lógica de extração de valor semântico
text = "Adorei este conteúdo, mas o vídeo é ruim".lower()
pos = sum(1 for w in ['adorei', 'incrível', 'bom'] if w in text) # Identifica 'adorei' (1)
neg = sum(1 for w in ['ruim', 'péssimo'] if w in text) # Identifica 'ruim' (1)

total = pos + neg
if total == 0:
  sentiment = 0.0
else: # Arredondamento para 2 casas decimais conforme requisito
  sentiment = round((pos - neg) / total, 2)

print(sentiment) # Resultado: 0.0 (Sentimento Neutro)
```

Transição: Tendo quantificado a qualidade da mensagem, o próximo passo arquitetural é medir sua relevância através do engajamento.

---

3. Algoritmo de Engajamento: O Cálculo de Relevância

O sucesso de uma comunidade depende de dar visibilidade ao conteúdo que gera valor. O ranking de mensagens não é aleatório; ele segue uma fórmula ponderada para o endpoint top:

Engajamento = (Total de Reações × 1.5) + (Total de Respostas × 1.0)

Racional Arquitetural dos Pesos

Como Senior Engineers, escolhemos pesos diferentes para equilibrar o Signal-to-Noise Ratio (Razão Sinal-Ruído):

- Reações (Peso 1.5): São sinais de alta fidelidade. Uma reação é uma validação explícita de sentimento (Like, Love, Insightful). Por ser um sinal mais "puro" de aprovação ou interesse, possui um peso 50% superior.
- Respostas (Peso 1.0): Representam profundidade e conversação. Embora exijam mais esforço do usuário, respostas podem incluir debates negativos, correções ou ruído fora de tópico. Por isso, embora essenciais para a retenção, possuem um peso base menor.

Cenário de Ranking

Considere o impacto dessa lógica no "Top N" da plataforma:

Mensagem Reações (x1.5) Respostas (x1.0) Score Final Ranking
A (Popularidade Rápida) 20 (30.0) 5 (5.0) 35.0 2º Lugar
B (Geradora de Debate) 10 (15.0) 25 (25.0) 40.0 1º Lugar

Transição: Para que esses cálculos sejam performáticos e confiáveis, a estrutura de dados subjacente precisa ser imune a manipulações.

---

4. Arquitetura de Dados para Lógica de Negócio

A confiabilidade de métricas de negócio depende da integridade da persistência. No modelo de dados, destacamos três pontos críticos:

1. Rastreabilidade: O campo user_ip nas mensagens permite auditar a origem das interações, essencial para análise de comportamento e segurança.
2. Hierarquia Nativa: O uso de parent_message_id permite reconstruir threads de comentários sem a necessidade de tabelas complexas de adjacência, mantendo a integridade da conversa.
3. Controle de Concorrência e Unicidade: O requisito de negócio exige que um usuário não inflacionar o engajamento artificialmente.

A Constraint de Reações

A aplicação de uma UNIQUE constraint composta em [message_id, user_id, reaction_type] é uma decisão de design vital. Ela permite que um usuário reaja com um 'like' e um 'love' na mesma mensagem (diversificando o sentimento), mas impede que o mesmo usuário envie dois 'likes' para duplicar o score.

Para lidar com cliques simultâneos (concorrência), o backend deve utilizar transações de banco de dados ou pessimistic locking, garantindo que a regra de "um tipo de reação por usuário" nunca seja violada.

Transição: Uma arquitetura robusta não apenas conta dados legítimos, mas também identifica padrões de abuso.

---

5. Analytics e Detecção de Fraude: O Caso dos IPs Suspeitos

A lógica de negócio também protege o ecossistema. O endpoint /api/v1/analytics/suspicious_ips é a nossa primeira linha de defesa contra ataques de Sybil (criação de múltiplas contas por um único ator).

Utilizamos o parâmetro min_users (com default em 3) para definir o limiar de suspeição. Se um único endereço IP está vinculado a mais usuários do que o limite definido, temos um indício de fraude ou automação.

"Dados de infraestrutura (IP) cruzados com dados de aplicação (User) geram segurança de negócio. Sem essa validação, o algoritmo de engajamento torna-se vulnerável a manipulações que destroem a confiança da comunidade."

Esta análise é o que garante que o "Top Mensagens" reflita a realidade da comunidade, e não o esforço de um botnet.

Transição: Consolidar esses pilares de Sentimento, Engajamento e Integridade é o que define uma implementação de nível sênior.

---

6. Conclusão: O Valor do Dado Processado

Transformar comportamento em dados mensuráveis exige uma visão sistêmica que vai além do CRUD básico. Aprendemos que a lógica de negócio deve permear desde a constraint do banco de dados até o algoritmo de ranking ponderado.

Checklist de Implementação

Valide se sua implementação respeita os critérios de excelência técnica:

- [ ] Automatização de Score: O ai_sentiment_score é calculado e persistido no POST /messages, tratando o caso de "zero palavras identificadas".
- [ ] Proteção de Engajamento: A UNIQUE constraint impede duplicidade de reações do mesmo tipo, e o código trata requisições concorrentes com transações.
- [ ] Otimização de Performance: O endpoint de top mensagens utiliza JOINs ou Counter Caches para evitar o problema de consulta N+1.
- [ ] Segurança Parametrizada: O endpoint de IPs suspeitos respeita o parâmetro min_users e expõe a lista de usernames afetados.
- [ ] Navegação Hierárquica: A estrutura de parent_message_id é respeitada para garantir a integridade das threads no frontend.

Seguindo este guia, você garante que sua aplicação não seja apenas um repositório de texto, mas uma plataforma inteligente capaz de gerar insights reais para o negócio.

### Plano de Arquitetura de Software: Plataforma de Gestão de Comunidades

1. Visão Geral e Objetivos Estratégicos

No atual cenário de ecossistemas digitais, a retenção de usuários e a saúde das interações dependem da capacidade técnica de processar dados em tempo real e extrair insights qualitativos de forma imediata. Esta plataforma foi concebida como uma solução moderna de engajamento social, onde a integração de análise de sentimento assistida por IA e métricas de engajamento não são apenas funcionalidades, mas pilares estratégicos para a moderação proativa e o crescimento sustentável da base de usuários. Ao transformar interações brutas em indicadores de sentimento e relevância, permitimos que gestores de comunidade tomem decisões baseadas em dados para mitigar toxicidade e promover discussões de alto valor.

O projeto está estruturado em torno dos seguintes objetivos fundamentais:

- API REST de Alta Performance: Prover uma espinha dorsal robusta para o gerenciamento de mensagens, reações e inteligência de dados.
- Interface Web Reativa: Entregar uma experiência de usuário fluida através de tecnologias que permitem interações dinâmicas sem o overhead de recarregamentos de página.
- Inteligência de Moderação: Implementar sistemas automatizados para análise de teor das mensagens e identificação de comportamentos fraudulentos ou abusivos.

Esta visão estratégica é sustentada por uma fundação tecnológica selecionada para garantir escalabilidade horizontal e integridade rigorosa dos dados.

2. Stack Tecnológica e Justificativa Técnica

A seleção de componentes da stack tecnológica é vital para assegurar o sucesso do deploy e a manutenibilidade do sistema sob carga. Como Arquiteto de Soluções, priorizo ferramentas que oferecem um equilíbrio entre produtividade de desenvolvimento e controle granular sobre a persistência.

Camada Tecnologia Justificativa Técnica
Backend Ruby on Rails O padrão Active Record e as convenções REST aceleram a implementação de regras de negócio complexas, enquanto sua maturidade garante um ecossistema estável para APIs críticas.
Frontend Hotwire (Stimulus + Turbo) Esta abordagem permite reatividade SPA-like mantendo o estado no servidor, reduzindo a complexidade do JavaScript e otimizando o tempo de carregamento da timeline.
Banco de Dados PostgreSQL É imperativo o uso do PostgreSQL para garantir suporte a transações ACID, integridade referencial estrita e a implementação eficiente de restrições de unicidade compostas.

A stack escolhida dita a forma como os dados serão estruturados e protegidos, estabelecendo os limites de segurança e performance que regem o sistema.

3. Arquitetura de Dados e Restrições de Integridade

A confiabilidade das métricas de engajamento depende de um esquema de banco de dados normalizado que impeça anomalias e redundâncias. A integridade dos dados na origem é o que garante que os cálculos de ranking e análises de fraude sejam auditáveis e precisos.

A modelagem de dados detalha as seguintes entidades e atributos:

- Users
  - id: Chave Primária (PK).
  - username: String (único, obrigatório).
  - created_at: Timestamp de criação (obrigatório).
- Communities
  - id: Chave Primária (PK).
  - name: String (único, obrigatório).
  - description: Text (opcional).
  - created_at: Timestamp de criação (obrigatório).
- Messages
  - id: Chave Primária (PK).
  - user_id: Chave Estrangeira (FK, obrigatória).
  - community_id: Chave Estrangeira (FK, obrigatória).
  - parent_message_id: Chave Estrangeira (FK, opcional) – suporta threads e respostas.
  - content: Text (obrigatório).
  - user_ip: String (obrigatório) – fundamental para auditoria de fraude.
  - ai_sentiment_score: Float (nullable, escala -1.0 a 1.0).
  - created_at: Timestamp de criação (obrigatório).
- Reactions
  - id: Chave Primária (PK).
  - message_id: Chave Estrangeira (FK, obrigatória).
  - user_id: Chave Estrangeira (FK, obrigatória).
  - reaction_type: String (ex: 'like', 'love', 'insightful').
  - created_at: Timestamp de criação (obrigatório).

A arquitetura exige a aplicação de uma restrição UNIQUE composta em [message_id, user_id, reaction_type]. Esta regra de integridade é crítica para impedir que um único usuário infle artificialmente o engajamento através de spam de reações idênticas na mesma mensagem, garantindo a legitimidade da experiência do usuário e a precisão dos rankings.

Esta estrutura de dados robusta serve como base para a exposição dos serviços via API, conforme detalhado a seguir.

4. Design da API REST e Contratos de Interface

A API é a espinha dorsal da plataforma, exigindo contratos claros para garantir o desacoplamento entre o backend e a interface Hotwire.

Endpoints e Fluxos de Dados

1. POST /api/v1/messages O fluxo de criação valida a existência do usuário via username; caso inexistente, o sistema deve criá-lo automaticamente antes de persistir a mensagem. O ai_sentiment_score é calculado de forma síncrona ou assíncrona durante este ciclo.

- Request:

```json
{
  "username": "john_doe",
  "community_id": 1,
  "content": "Conteúdo da mensagem",
  "user_ip": "192.168.1.1",
  "parent_message_id": null
}
```

- Response (201):

```json
{
  "id": 1,
  "content": "Conteúdo da mensagem",
  "user": {
    "id": 1,
    "username": "john_doe"
  },
  "community_id": 1,
  "parent_message_id": null,
  "ai_sentiment_score": 0.75,
  "created_at": "2025-11-24T10:00:00Z"
}
```

2. POST /api/v1/reactions Gerencia as interações de engajamento rápido. O sistema deve validar a restrição de uma reação por tipo por usuário.

- Request:

```json
{
  "message_id": 1,
  "user_id": 1,
  "reaction_type": "like"
}
```

- Response (200):

```json
{
  "message_id": 1,
  "reactions": {
    "like": 15,
    "love": 8,
    "insightful": 3
  }
}
```

3. GET /api/v1/communities/:id/messages/top Retorna o ranking de mensagens baseado no Engagement Score.

- Lógica: (reações _ 1.5) + (respostas _ 1.0).
- Parâmetros: limit (default: 10, max: 50).
- Response (200):

```json
{
  "messages": [
    {
      "id": 1,
      "content": "Conteúdo...",
      "user": { "id": 1, "username": "john_doe" },
      "ai_sentiment_score": 0.8,
      "reaction_count": 23,
      "reply_count": 5,
      "engagement_score": 39.5
    }
  ]
}
```

4. GET /api/v1/analytics/suspicious_ips Endpoint analítico para segurança. Identifica IPs que operam múltiplas contas.

- Parâmetros: min_users (default: 3).
- Response (200):

```json
{
  "suspicious_ips": [
    {
      "ip": "192.168.1.1",
      "user_count": 5,
      "usernames": ["user1", "user2", "user3", "user4", "user5"]
    }
  ]
}
```

A eficiência destes endpoints depende da gestão rigorosa de requisições simultâneas.

5. Estratégias de Concorrência e Otimização de Performance

Lidar com alta densidade de interações em tempo real exige estratégias para evitar condições de corrida (race conditions). Sem proteção adequada, múltiplas requisições simultâneas de reações do mesmo usuário poderiam burlar as regras de negócio.

Tratamento de Concorrência em Reactions

É imperativo implementar Advisory Locks no nível do banco de dados ou utilizar Optimistic Locking para garantir que a verificação de existência e a inserção da reação sejam atômicas. A restrição UNIQUE em [message_id, user_id, reaction_type] deve ser tratada como a última linha de defesa, capturando exceções de violação de banco de dados e convertendo-as em mensagens de erro amigáveis para o usuário.

Otimização de Consultas (Anti-N+1)

Para o endpoint de "Top N" mensagens, a arquitetura prescreve o uso de Eager Loading (através de includes no Rails) para carregar usuários e contagens de reações em uma única consulta otimizada. Devem ser criados índices compostos nas chaves estrangeiras (community_id, created_at) e nas colunas de reações para garantir que o cálculo do ranking não degrade sob carga.

Esta eficiência na persistência serve de base para a camada de inteligência que agrega valor qualitativo aos dados.

6. Inteligência de Dados e Análise de Fraude

A inteligência da plataforma reside na capacidade de transformar dados transacionais em ferramentas de moderação e segurança.

Análise de Sentimento (IA)

Cada mensagem persistida deve ser processada por um analisador de sentimento que atribui um ai_sentiment_score em uma escala de -1.0 (extremamente negativo) a 1.0 (extremamente positivo). A implementação utilizará uma abordagem baseada em processamento de linguagem natural (NLP), onde palavras-chave positivas e negativas são ponderadas para gerar o score decimal. Este valor é essencial para a interface web, permitindo que badges visuais alertem moderadores e usuários sobre o tom da conversa na timeline.

Detecção de Fraude e IPs Suspeitos

O endpoint suspicious_ips é a ferramenta primária de auditoria proativa. A lógica de detecção baseia-se na correlação de dados de rede: qualquer endereço IP associado a um mínimo de 3 usernames diferentes é sinalizado. Esta análise é vital para identificar ataques de Sybil, onde um único indivíduo tenta manipular o engajamento ou a percepção da comunidade através de contas múltiplas, garantindo a integridade democrática da plataforma.

Esta arquitetura atende integralmente aos requisitos de funcionalidade, performance e qualidade de código, estabelecendo um ambiente escalável e seguro para a gestão de comunidades modernas.
