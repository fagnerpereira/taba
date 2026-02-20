# Community Platform

Uma plataforma de gestão de comunidades com API REST, interface web moderna e análise de sentimento powered by AI.

## 🚀 Tecnologias

### Backend

- **Ruby on Rails 8.1.2** - Framework web completo
- **PostgreSQL** - Banco de dados relacional
- **RSpec** - Framework de testes com 70%+ de cobertura
- **SimpleCov** - Análise de cobertura de testes

### Frontend

- **HAML** - Template engine conciso
- **Stimulus** - Framework JavaScript minimalista
- **Tailwind CSS** - Framework CSS utility-first
- **Turbo** - Navegação rápida sem reloads

### IA & Análise

- **SentimentAnalyzer** custom - Análise de sentimento em português/inglês
- Scores: -1.0 (muito negativo) a 1.0 (muito positivo)
- Emojis indicativos visuais

## 📋 Funcionalidades

### API REST (v1)

- **POST /api/v1/messages** - Criar mensagens/comentários
- **POST /api/v1/reactions** - Reagir a mensagens
- **GET /api/v1/communities/:id/messages/top** - Top mensagens por engajamento
- **GET /api/v1/analytics/suspicious_ips** - Detectar IPs suspeitos

### Interface Web

- **Listagem de Comunidades** - Grid responsivo com contadores
- **Timeline de Mensagens** - Feed com 50 mensagens mais recentes
- **Sistema de Reações** - Like ❤️ Love 💡 Insightful
- **Threads de Comentários** - Visualização hierárquica
- **Análise de Sentimento** - Indicadores visuais e emojis
- **Responsive Design** - Mobile-first com Tailwind

## 🛠️ Setup Local

### Pré-requisitos

- Ruby 4.0+
- PostgreSQL 13+
- Node.js 18+
- Bundler

### Instalação

```bash
# Clone o repositório
git clone [URL_DO_REPOSITORIO]
cd community_platform

# Instale dependências
bundle install
npm install

# Configure o banco de dados
cp config/database.yml.example config/database.yml
# Edite config/database.yml com suas credenciais PostgreSQL

# Crie o banco
rails db:create
rails db:migrate

# Popule com dados de exemplo
rails db:seed

# Inicie o servidor
rails s
```

### Rodar Testes

```bash
# Rodar todos os testes
bundle exec rspec

# Ver cobertura
open coverage/index.html
```

## 🌱 Seeds

O script de seeds cria:

- **5 Comunidades** diversificadas
- **33 Usuários** únicos
- **1000+ Mensagens** (90% principais, 10% respostas)
- **20 IPs** diferentes para análise
- **3700+ Reações** em 80% das mensagens

Execute com:

```bash
rails db:seed
```

## 📊 Modelos de Dados

### User

- `username` (string, unique, required)

### Community

- `name` (string, unique, required)
- `description` (text)

### Message

- `content` (text, required)
- `user_id` (foreign key)
- `community_id` (foreign key)
- `parent_message_id` (polymorphic, nullable)
- `user_ip` (string, required)
- `ai_sentiment_score` (float, -1.0 to 1.0)

### Reaction

- `message_id` (foreign key)
- `user_id` (foreign key)
- `reaction_type` (enum: like, love, insightful)
- **Unique constraint**: `[message_id, user_id, reaction_type]`

## 🤖 Análise de Sentimento

Algoritmo baseado em palavras-chave:

- **Palavras positivas**: ótimo, excelente, legal, bom, adorei, incrível...
- **Palavras negativas**: ruim, péssimo, horrível, terrível, odeio...
- **Normalização**: Scores limitados a -1.0 e 1.0
- **Idiomas**: Suporte para português e inglês

Indicadores visuais:

- 😄 Muito positivo (0.5 - 1.0)
- 🙂 Positivo (0.1 - 0.5)
- 😐 Neutro (-0.1 - 0.1)
- 😕 Negativo (-0.5 - -0.1)
- 😞 Muito negativo (-1.0 - -0.5)

## 🔒 Performance & Segurança

### Índices Otimizados

- `messages` → `[community_id, created_at]`
- `messages` → `[user_id, created_at]`
- `messages` → `user_ip`
- `reactions` → `[message_id, user_id, reaction_type]`

### Validações

- IP format validation
- Sentiment score bounds (-1.0 to 1.0)
- Unique username/community names
- Reaction uniqueness constraints

### Concorrência

- Transações para criação de reações
- Database constraints para evitar duplicatas
- Tratamento adequado de race conditions

## 🚀 Deploy

### Render.com

1. Conecte seu repositório ao Render
2. Configure Web Service com:
   - Build Command: `bundle install && rails db:migrate && rails db:seed`
   - Start Command: `bundle exec puma -C config/puma.rb`
   - Environment: PostgreSQL
3. Configure variáveis de ambiente:
   - `DATABASE_URL`
   - `RAILS_MASTER_KEY`
   - `RAILS_ENV=production`

### Variáveis de Ambiente

```bash
DATABASE_URL=postgresql://user:pass@host:5432/dbname
RAILS_MASTER_KEY=your_master_key
RAILS_ENV=production
SECRET_KEY_BASE=your_secret_key
```

## 📈 Analytics

### Endpoint de IPs Suspeitos

Detecta múltiplos usuários usando o mesmo IP:

```bash
GET /api/v1/analytics/suspicious_ips?min_users=3

Response:
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

### Top Messages por Engajamento

Algoritmo de ranking:

```
Engajamento = (reactions × 1.5) + (respostas × 1.0)
```

## 🧪 Testes

### Cobertura

- **Target**: 70% mínimo
- **Atual**: ~80%
- **Ferramenta**: SimpleCov

### Estrutura

```
spec/
├── models/          # Testes de modelos
├── services/        # Testes de serviços
├── controllers/     # Testes de controllers
├── helpers/         # Testes de helpers
└── factories/       # FactoryBot fixtures
```

### Rodar Testes

```bash
# Todos os testes
bundle exec rspec

# Apenas models
bundle exec rspec spec/models/

# Com覆盖率
COVERAGE=true bundle exec rspec
```

## 🎯 Desafios Implementados

### Requisitos Técnicos

✅ **Testes automatizados** - 70%+ cobertura com SimpleCov  
✅ **Linter configurado** - RuboCop com Rails Omakase  
✅ **Código público** - GitHub repositório aberto  
✅ **Deploy funcional** - Aplicação online no Render  
✅ **README completo** - Documentação detalhada

### Funcionalidades Obrigatórias

✅ **API REST completa** - Todos os endpoints funcionando  
✅ **Frontend interativo** - Reações sem reload via Stimulus  
✅ **Análise de sentimento** - Implementação custom em Ruby  
✅ **Seeds robustos** - 1000+ mensagens realistas  
✅ **Tratamento de erros** - Validações e responses adequados

### Diferenciais Implementados

⭐ **Ruby on Rails completo** - Stack diferencial solicitado  
⭐ **HAML + Stimulus + Turbo** - Frontend moderno sem JavaScript pesado  
⭐ **Análise de sentimento bilingue** - Português + inglês  
⭐ **Design responsivo** - Mobile-first com Tailwind  
⭐ **Proteção contra concorrência** - Transações e constraints

## 📝 Decisões Técnicas

### Ruby on Rails vs Node.js

**Escolha**: Ruby on Rails  
**Motivo**: Requisito explícito do diferencial, maturidade do framework, ecoistema completo para testes e deploy.

### HAML vs ERB

**Escolha**: HAML  
**Motivo**: Sintaxe mais limpa e diferencial solicitado, melhor legibilidade para templates complexos.

### Stimulus vs React

**Escolha**: Stimulus + Turbo  
**Motivo**: Suficiente para interações necessárias, menor complexidade, melhor performance, alinhado com Rails.

### Análise de Sentimento Custom vs API Externa

**Escolha**: Implementação custom  
**Motivo**: Controle total do algoritmo, suporte a português, sem custos de API, determinístico.

## 🤝 Contribuição

1. Fork o repositório
2. Crie branch `feature/nova-funcionalidade`
3. Commit suas mudanças
4. Push para o branch
5. Abra Pull Request

### Padrões

- Use mensagens de commit semânticas
- Mantenha cobertura de testes > 70%
- Siga os guias de estilo do RuboCop
- Documente mudanças em README

## 📄 Licença

MIT License - Ver arquivo LICENSE para detalhes.

---

**Desenvolvido com ❤️ usando Ruby on Rails**
