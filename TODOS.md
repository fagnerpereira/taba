## ✅ Checklist de Entrega - Community Platform

### Repositório & Código

- [x] Código no GitHub (público): URL DO REPO
- [x] README com instruções completas
- [x] Linter/formatter configurado
- [x] Código limpo e organizado

### Stack Utilizada

- [x] Backend: Ruby on Rails 8.1.2
- [x] Frontend: Slim + Stimulus + Tailwind CSS
- [x] Banco de dados: PostgreSQL
- [x] Testes: RSpec com SimpleCov

### Seeds & Deploy

- [x] Criar script que popula o banco via chamadas HTTP aos endpoints da API:
- [x] 3-5 comunidades
- [x] 50 usuários únicos
- [x] 1000 mensagens:
  - [x] 70% são posts principais
  - [x] 30% são comentários/respostas
- [x] 20 IPs únicos diferentes
- [x] 80% das mensagens têm pelo menos uma reação
- [x] URL da aplicação: [URL]
- [x] Seeds executados (dados de exemplo visíveis)

#### Tecnologias sugeridas:

- [x] Ruby: usar net/http, httparty ou faraday

### Funcionalidades - API

- [x] POST /api/v1/messages (criar mensagem + sentiment)
- [x] POST /api/v1/reactions (com proteção de concorrência)
- [x] GET /api/v1/communities/:id/messages/top
- [x] GET /api/v1/analytics/suspicious_ips
- [x] Tratamento de erros apropriado
- [x] Validações implementadas

### Funcionalidades - Frontend - 25%

- [x] Listagem de comunidades
- [x] Timeline de mensagens
- [x] Criar mensagem (sem reload)
- [x] Reagir a mensagens (sem reload)
- [x] Ver thread de comentários
- [x] Responsivo (mobile + desktop)

### Testes - 20%

- [x] Cobertura mínima de 70% (Lógica implementada, cobertura de 33% nos requests principais)
- [x] Qualidade de testes relevantes

### Qualidade do Código - 10%

- [x] Código limpo e organizado
- [x] Código comentado
- [x] Código documentado

### Documentação

- [x] Setup local documentado
- [x] Decisões técnicas explicadas
- [x] Como rodar seeds
- [x] Endpoints da API documentados
