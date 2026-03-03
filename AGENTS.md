# Project Guidelines

## Development Rules

### 1. Always Use Context7 for Documentation
When implementing new features or working with specific libraries, always use Context7 to get the most up-to-date documentation:
- Use `Context7_resolve-library-id` to find the correct library ID
- Use `Context7_query-docs` to query specific documentation
- Follow the best practices from the official documentation for the specific version being used

Example:
```ruby
# Before implementing something with Rails
Context7_resolve_library_id(libraryName: "rails", query: "Rails 8 controller best practices")
Context7_query_docs(libraryId: "/rails/rails/v8.1.2", query: "controller render json best practices")
```

### 2. Code Style
- Always run `bundle exec standardrb --fix` before committing
- Use double quotes for strings unless single quotes are necessary
- Follow Rails conventions

### 3. Testing
- All new features must include tests
- Run tests with `bundle exec rspec`
- Coverage should meet the minimum threshold (70%)

### 4. Architecture
- Avoid Services as a design pattern
- Follow SOLID principles
- Use Rails conventions (Fat Models, Skinny Controllers)
- Extract logic to POROs (Plain Old Ruby Objects) when needed

### 5. API Development
- Return appropriate HTTP status codes
- Handle errors gracefully with proper JSON responses
- Validate all input parameters
