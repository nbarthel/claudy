# Rails Workflow Knowledge Core

This document serves as the central repository for learned patterns, architectural decisions, and project-specific knowledge. It is updated by the Rails Workflow agents to improve future implementations.

## 1. Project Architecture

### Core Stack
- **Framework**: Rails 8.0+
- **Database**: PostgreSQL
- **Frontend**: Hotwire (Turbo + Stimulus)
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache / Redis

### Key Decisions
- [Date]: Adopted Service Object pattern for complex business logic
- [Date]: Enforced TDD for all new features
- [Date]: Standardized on JSON:API for API endpoints

## 2. Established Patterns

### Authentication
- **Pattern**: Devise with JWT for API
- **Context**: API-first authentication
- **Implementation**: `User` model with `devise-jwt` gem

### Service Objects
- **Pattern**: Result Object
- **Context**: Returning success/failure from services
- **Implementation**: `Result` class with `success?`, `failure?`, `data`, `error`

### Background Jobs
- **Pattern**: Job Continuations
- **Context**: Long-running multi-step processes
- **Implementation**: Rails 8.1 style continuations with Solid Queue

## 3. Anti-Patterns to Avoid

- **Fat Controllers**: Move logic to Services or Models
- **Callbacks for Business Logic**: Use Service Objects instead
- **N+1 Queries**: Use `includes` or `strict_loading`

## 4. Learned Lessons

- [Date]: Turbo Streams require correct MIME type handling in Nginx
- [Date]: Solid Queue requires separate worker process in production

---

*This file is automatically updated by Rails Workflow agents.*
