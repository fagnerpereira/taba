# **taba**

A digital village that brings us back together.

Humans evolved through community and connection—not isolation. Yet today, we're pulling apart into individualism, which threatens our survival and evolution as a species. **taba** creates a welcoming space where we reconnect, support each other, and thrive together again.

---

# Community Platform

A community management platform with REST API, modern web interface, and AI-powered sentiment analysis.

## 🚀 Technologies

### Backend

- **Ruby on Rails 8.1.2** - Full web framework
- **PostgreSQL** - Relational database
- **RSpec** - Testing framework with 70%+ coverage
- **SimpleCov** - Test coverage analysis

### Frontend

- **Slim** - Concise templating engine
- **Stimulus** - Lightweight JavaScript framework
- **Tailwind CSS** - Utility-first CSS framework
- **Turbo** - Fast navigation without page reloads

### AI & Analytics

- **Custom SentimentAnalyzer** - Sentiment analysis in Portuguese/English
- Scores: -1.0 (very negative) to 1.0 (very positive)
- Visual indicator emojis

## 📋 Features

### REST API (v1)

- **POST /api/v1/messages** - Create messages/comments
- **POST /api/v1/reactions** - React to messages
- **GET /api/v1/communities/:id/messages/top** - Top messages by engagement
- **GET /api/v1/analytics/suspicious_ips** - Detect suspicious IPs

### Web Interface

- **Community Listing** - Responsive grid with counters
- **Message Timeline** - Feed with 50 most recent messages
- **Reaction System** - Like ❤️ Love 💡 Insight
- **Comment Threads** - Hierarchical visualization
- **Sentiment Analysis** - Visual indicators and emojis
- **Responsive Design** - Mobile-first with Tailwind

## 🛠️ Local Setup

### Prerequisites

- Ruby 4.0+
- PostgreSQL 13+
- Node.js 18+
- Bundler

### Installation

```bash
# Clone the repository
git clone [REPOSITORY_URL]
cd community_platform

# Install dependencies
bundle install
npm install

# Configure database
cp config/database.yml.example config/database.yml
# Edit config/database.yml with your PostgreSQL credentials

# Create database
rails db:create
rails db:migrate

# Populate with sample data
rails db:seed

# Start server
rails s
```

### Code Quality Tools

#### StandardRB - Ruby Linter & Formatter

We've adopted **StandardRB** as our Ruby style guide, linter, and formatter to eliminate bike-shedding about code style.

**Why StandardRB Matters:**

Code style debates are personal, time-consuming, and distract from what truly matters:

- Performance optimizations
- Important refactorings
- Code quality improvements
- Increasing test coverage
- Feature development

**Benefits:**

- **Zero Configuration**: Works out of the box with sensible defaults
- **Enforced Consistency**: All team members write code that looks the same
- **Automated Formatting**: Focus on logic, not spacing or braces
- **Time Savings**: Redirect energy from style debates to meaningful improvements

**Usage:**

```bash
# Check code style
bundle exec standardrb

# Auto-fix issues
bundle exec standardrb --fix

# Run in parallel for faster checks
bundle exec standardrb --parallel
```

#### RSpec - Testing Framework

**Setup:**
RSpec is configured with Rails integration. Run tests with:

```bash
# Run all tests
bundle exec rspec

# Run specific test types
bundle exec rspec spec/models
bundle exec rspec spec/controllers
bundle exec rspec spec/services

# Run with coverage report
COVERAGE=true bundle exec rspec
```

#### SimpleCov - Test Coverage

SimpleCov is configured to track test coverage with a **70% minimum threshold**, ensuring code quality and reliability.

**Configuration:**

- Minimum coverage threshold: 70%
- Current coverage: ~80%
- Generates detailed HTML reports in `coverage/index.html`

**Viewing Coverage:**
After running tests with coverage enabled, open `coverage/index.html` in your browser to see:

- Overall coverage percentage
- Per-file coverage details
- Line-by-line coverage indicators
- Untested code identification

**Coverage Targets:**

- **Models**: 80% minimum (critical business logic)
- **Services**: 80% minimum (core application behavior)
- **Controllers**: 70% minimum (request handling)
- **Helpers**: 70% minimum (view logic)

If coverage drops below 70%, SimpleCov will fail the test suite to maintain code quality standards.

### Running Tests

```bash
# Run all tests
bundle exec rspec

# View coverage report (after running tests)
open coverage/index.html
```

## 🌱 Seeds

The seed script creates:

- **5 Communities** diversified
- **33 Unique Users**
- **1000+ Messages** (90% main, 10% replies)
- **20 Different IPs** for analysis
- **3700+ Reactions** on 80% of messages

Execute with:

```bash
rails db:seed
```

## 📊 Data Models

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

## 🤖 Sentiment Analysis

Keyword-based algorithm:

- **Positive words**: great, excellent, cool, good, loved, amazing, wonderful, fantastic, perfect, awesome, adorei, ótimo, excelente, legal, bom, incrível...
- **Negative words**: bad, terrible, horrible, awful, hate, disgusting, worst, fail, odiei, ruim, péssimo, horrível, terrível...
- **Normalization**: Scores limited to -1.0 and 1.0
- **Languages**: Support for Portuguese and English

Visual indicators:

- 😄 Very positive (0.5 - 1.0)
- 🙂 Positive (0.1 - 0.5)
- 😐 Neutral (-0.1 - 0.1)
- 😕 Negative (-0.5 - -0.1)
- 😞 Very negative (-1.0 - -0.5)

## 🔒 Performance & Security

### Optimized Indexes

- `messages` → `[community_id, created_at]`
- `messages` → `[user_id, created_at]`
- `messages` → `user_ip`
- `reactions` → `[message_id, user_id, reaction_type]`

### Validations

- IP format validation
- Sentiment score bounds (-1.0 to 1.0)
- Unique username/community names
- Reaction uniqueness constraints

### Concurrency

- Database transactions for reaction creation
- Constraints to prevent duplicates
- Proper race condition handling

## 🚀 Deploy

### Render.com

1. Connect your repository to Render
2. Configure Web Service with:
   - Build Command: `bundle install && rails db:migrate && rails db:seed`
   - Start Command: `bundle exec puma -C config/puma.rb`
   - Environment: PostgreSQL
3. Configure environment variables:
   - `DATABASE_URL`
   - `RAILS_MASTER_KEY`
   - `RAILS_ENV=production`

### Environment Variables

```bash
DATABASE_URL=postgresql://user:pass@host:5432/dbname
RAILS_MASTER_KEY=your_master_key
RAILS_ENV=production
SECRET_KEY_BASE=your_secret_key
```

## 📈 Analytics

### Suspicious IPs Endpoint

Detects multiple users using the same IP:

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

### Top Messages by Engagement

Ranking algorithm:

```
Engagement = (reactions × 1.5) + (replies × 1.0)
```

## 🧪 Tests

### Coverage

- **Target**: 70% minimum
- **Current**: ~80%
- **Tool**: SimpleCov

### Structure

```
spec/
├── models/          # Model tests
├── services/        # Service tests
├── controllers/     # Controller tests
├── helpers/         # Helper tests
└── factories/       # FactoryBot fixtures
```

### Running Tests

```bash
# All tests
bundle exec rspec

# Only models
bundle exec rspec spec/models/

# With coverage
COVERAGE=true bundle exec rspec
```

## 🎯 Implemented Requirements

### Technical Requirements

✅ **Automated tests** - 70%+ coverage with SimpleCov
✅ **Configured linter** - RuboCop with Rails Omakase
✅ **Public code** - Open GitHub repository
✅ **Functional deploy** - Online application on Render
✅ **Complete README** - Detailed documentation

### Mandatory Features

✅ **Complete REST API** - All endpoints working
✅ **Interactive frontend** - Reactions without reload via Stimulus
✅ **Sentiment analysis** - Custom Ruby implementation
✅ **Robust seeds** - 1000+ realistic messages
✅ **Error handling** - Proper validations and responses

### Implemented Differentials

⭐ **Full Ruby on Rails** - Differential stack requested
⭐ **Slim + Stimulus + Turbo** - Modern frontend without heavy JavaScript
⭐ **Bilingual sentiment analysis** - Portuguese + English
⭐ **Responsive design** - Mobile-first with Tailwind
⭐ **Concurrency protection** - Transactions and constraints

## 📝 Technical Decisions

### Ruby on Rails vs Node.js

**Choice**: Ruby on Rails
**Reason**: Explicit differential requirement, framework maturity, complete ecosystem for testing and deploy.

### Slim vs HAML vs ERB

**Choice**: **Slim** (replacing HAML)

**Rationale**:
After careful evaluation, Slim was selected as the templating engine over both HAML and ERB for several compelling reasons:

#### **Why Slim Over HAML**:

1. **Cleaner, More Intuitive Syntax**:
   - Slim's syntax is even more minimal than HAML's, removing additional characters (`%` for tags) making it the cleanest option available
   - Example: `div.container` vs HAML's `.container` (less ambiguity, easier for newcomers)

2. **Better Performance**:
   - Slim has faster compilation times than HAML in most benchmarks
   - Lower memory footprint, which matters for large applications
   - More efficient generated code

3. **Team Collaboration Benefits**:
   - Syntax closely resembles HTML, making it easier for frontend developers to understand and contribute
   - Lower learning curve for team members unfamiliar with Ruby templating
   - Easier to teach and onboard new developers

4. **HTML-Compatible Syntax**:
   - You can write nearly plain HTML when needed, making migration and mixed usage seamless
   - Great for gradual migration from ERB/HTML files
   - Less "magic" that's easier for teams to reason about

5. **Active Maintenance & Modern Tooling**:
   - Slim has a more active recent development cycle
   - Better integration with modern Rails and frontend tooling
   - Strong compatibility with Rails 8+ features

#### **Why Slim Over ERB**:

1. **DRY Principle**: No `<%= %>` tags, `end` statements, or XML closing tags
2. **Readability**: Indentation-based structure is visually clearer
3. **Developer Experience**: Less typing, fewer errors, faster development
4. **Performance**: Compiled templates are generally faster than ERB
5. **Error Prevention**: Complies with HTML standards automatically

#### **Migration Path**:

Migration from HAML to Slim is straightforward because:

- Both use indentation-based syntax
- Slim can interpret similar structures with minimal changes
- The `haml2slim` converter gem automates most conversions
- Can be done incrementally, file by file

**Note**: While HAML was initially chosen for its conciseness, Slim represents the next evolution—offering the same benefits with better performance, clearer syntax, and superior team Collaboration experience.

### Stimulus vs React

**Choice**: Stimulus + Turbo
**Reason**: Sufficient for required interactions, less complexity, better performance, aligned with Rails.

### Custom Sentiment Analysis vs External API

**Choice**: Custom implementation
**Reason**: Full algorithm control, Portuguese support, no API costs, deterministic.

### Patterns

- Use semantic commit messages
- Keep test coverage > 70%
- Follow RuboCop style guides
- Document changes in README

## 📄 License

MIT License - See LICENSE file for details.

---

**Built with ❤️ using Ruby on Rails, made stronger by its vibrant community**
