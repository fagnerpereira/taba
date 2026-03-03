# TODO: README com instruções completas
# taba - Plataforma de Comunidades

Plataforma moderna de comunidades construída com **Ruby on Rails 8.1.2** e a stack **Solid**.

## 🚀 Tecnologias
- **Backend**: Rails 8.1.2, PostgreSQL
- **Frontend**: Slim, Stimulus, Tailwind CSS, Hotwire (Turbo)
- **Background Jobs/Cache**: Solid Queue, Solid Cache

## 🛠 Setup Local
1. Instale as dependências: `bundle install`
2. Prepare o banco: `bin/rails db:prepare`
3. Inicie o servidor: `bin/rails s`

## 🧪 Testes
Para rodar os testes e ver a cobertura:
```bash
bundle exec rspec
```

## 📦 Seeds via API
Para popular o banco conforme os requisitos do desafio:
1. Certifique-se de que o servidor está rodando (`bin/rails s`)
2. Execute:
```bash
ruby script/seed_via_api.rb
```

## 📡 Endpoints da API (v1)
- `POST /api/v1/messages`: Cria mensagens e usuários automaticamente.
- `POST /api/v1/reactions`: Adiciona reações com proteção de concorrência.
- `GET /api/v1/communities/:id/messages/top`: Ranking de engajamento.
- `GET /api/v1/analytics/suspicious_ips`: Identifica IPs suspeitos.

## 📐 Decisões Técnicas
- **Solid Stack**: Escolhido para reduzir dependências externas (Redis) e simplificar o deploy.
- **Pessimistic Locking**: Utilizado na criação de reações para garantir atomicidade em alta carga.
- **On-the-fly Provisioning**: Usuários são criados automaticamente no primeiro post para melhorar o UX da API.
