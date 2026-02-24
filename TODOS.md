## ✅ Checklist de Entrega - Community Platform

### Repositório & Código

- [x] Código no GitHub (público): URL DO REPO
- [x] README com instruções completas
- [x] Linter/formatter configurado
- [] Código limpo e organizado

### Stack Utilizada

- [x] Backend: Ruby on Rails 8.1.2
- [x] Frontend: Slim + Stimulus + Tailwind CSS
- [x] Banco de dados: PostgreSQL
- [x] Testes: RSpec com SimpleCov

### Seeds & Deploy

- [] Criar script que popula o banco via chamadas HTTP aos endpoints da API:
- [] 3-5 comunidades
- [] 50 usuários únicos
- [] 1000 mensagens:
  - [] 70% são posts principais
  - [] 30% são comentários/respostas
- [] 20 IPs únicos diferentes
- [] 80% das mensagens têm pelo menos uma reação
- [] URL da aplicação: [URL]
- [] Seeds executados (dados de exemplo visíveis)

#### Tecnologias sugeridas:

- [] Ruby: usar net/http, httparty ou faraday
- [] Node: usar axios ou fetch
- [] Python: usar requests
- [] Bash: usar curl

### Funcionalidades - API

- [] POST /api/v1/messages (criar mensagem + sentiment)
- [] POST /api/v1/reactions (com proteção de concorrência)
- [] GET /api/v1/communities/:id/messages/top
- [] GET /api/v1/analytics/suspicious_ips
- [] Tratamento de erros apropriado
- [] Validações implementadas

### Funcionalidades - Frontend - 25%

- [] Listagem de comunidades
- [] Timeline de mensagens
- [] Criar mensagem (sem reload)
- [] Reagir a mensagens (sem reload)
- [] Ver thread de comentários
- [] Responsivo (mobile + desktop)
  #### Se sobrar tempo, implementar:
  - [] Componentes utilizando Phlex
  - [] Testear esses componentes
  - [] Adicionar delete/archive de mensagens
  - [] Adicionar edição de mensagens

### Testes - 20%

- [] Cobertura mínima de 70%
- [] Qualidade de testes relevantes

### Qualidade do Código - 10%

- [] Código limpo e organizado
- [] Código comentado
- [] Código documentado

### Seeds & Deploy - 10%

- [] Criar script que popula o banco via chamadas HTTP aos endpoints da API:
- [] 3-5 comunidades
- [] 50 usuários únicos
- [] 1000 mensagens:
  - [] 70% são posts principais
  - [] 30% são comentários/respostas
- [] 20 IPs únicos diferentes
- [] 80% das mensagens têm pelo menos uma reação
- [] URL da aplicação: [URL]
- [] Seeds executados (dados de exemplo visíveis)

### Documentação

- [] Setup local documentado
- [] Decisões técnicas explicadas
- [] Como rodar seeds
- [] Endpoints da API documentados
- [] Screenshot ou GIF da interface (opcional)

#### Tecnologias sugeridas:

- [] Ruby: usar net/http, httparty ou faraday
- [] Node: usar axios ou fetch
- [] Python: usar requests
- [] Bash: usar curl

#### Diferenciadores (Bônus - não obrigatório)

##### Implemente 1-2 destes:

- [x] Ruby on Rails stack completo (HAML + Stimulus + Turbo)
- [] Real-time updates (WebSockets/Action Cable/Socket.io)
- [] Filtros de mensagens (por sentiment, por data)
- [] Dashboard de moderação
- [] Paginação infinita (infinite scroll)
- [] Integração real com API de IA
- [] Testes end-to-end (Cypress, Playwright, Capybara)
- [x] CI/CD configurado (GitHub Actions)
- [x] Docker / Docker Compose
- [] UI polida com animações

#### Dicas

1. Comece pelo backend - garanta a API funcionando primeiro
2. Use bibliotecas consolidadas - não reinvente a roda
3. Priorize funcionalidade sobre beleza - frontend bonito é bônus
4. Teste enquanto desenvolve - não deixe testes para o final
5. Documente decisões técnicas - explique seus trade-offs
6. Deploy cedo - não deixe para última hora
7. Gerencie seu tempo:
   - Dias 1-2: API básica
   - Dias 3-4: Frontend + testes
   - Dia 5: Seeds + deploy
   - Dias 6-7: Buffer e polimento
