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

### Funcionalidades - Frontend

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

### Testes

- [] Cobertura mínima de 70%
- [] Testes passando
- [] Como rodar: `bundle exec rspec`

### Documentação

- [] Setup local documentado
- [] Decisões técnicas explicadas
- [] Como rodar seeds
- [] Endpoints da API documentados
- [] Screenshot ou GIF da interface (opcional)

### ⏰ Entregue em: 12/02/2026
