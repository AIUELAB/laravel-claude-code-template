# Claude Code Laravel Development Instructions

## Language

**CRITICAL**: Respond in **Japanese (日本語)** unless explicitly asked otherwise.

## Project Overview

This is a Laravel 11 project with Claude Code + MCP integration, optimized for AI-assisted development.

**Tech Stack**:
- PHP 8.3+
- Laravel 11
- MySQL 8.0 / PostgreSQL 16
- Redis (Cache & Queue)
- Docker (Laravel Sail compatible)
- Vite + TailwindCSS

## Architecture

### Clean Architecture Pattern

```
app/
├── Http/
│   ├── Controllers/      # Thin controllers (validation + response)
│   ├── Requests/         # Form Request validation
│   └── Resources/        # API Resources (JSON transformation)
├── Domain/               # Business logic (framework-agnostic)
│   ├── Models/           # Eloquent models
│   ├── Services/         # Business services
│   ├── Repositories/     # Data access abstraction
│   └── Events/           # Domain events
├── Infrastructure/       # External services
│   ├── External/         # Third-party API clients
│   └── Persistence/      # Repository implementations
└── Support/              # Helpers, traits, constants
```

### Layer Responsibilities

- **Controllers**: HTTP layer only, delegate to services
- **Services**: Business logic, orchestration
- **Repositories**: Data access, query building
- **Models**: Eloquent relationships, accessors, mutators

## MCP Server Strategy

### Default Enabled (Essential)

| MCP | Purpose | When to Use |
|-----|---------|-------------|
| **filesystem** | File operations | Always |
| **GitHub** | Version control | Always |

### Optional (Enable When Needed)

| MCP | Purpose | Enable Command |
|-----|---------|----------------|
| **Context7** | Laravel/PHP docs | `--c7` flag |
| **Supabase** | BaaS integration | Full profile |
| **postgres** | Direct DB access | When needed |

## Coding Standards

### PHP Style (PSR-12 + Laravel conventions)

```php
<?php

declare(strict_types=1);

namespace App\Domain\Services;

use App\Domain\Repositories\UserRepositoryInterface;
use App\Domain\Models\User;

final class UserService
{
    public function __construct(
        private readonly UserRepositoryInterface $userRepository,
    ) {}

    public function findById(int $id): ?User
    {
        return $this->userRepository->find($id);
    }

    public function create(array $data): User
    {
        return $this->userRepository->create($data);
    }
}
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Controller | PascalCase + Controller | `UserController` |
| Service | PascalCase + Service | `UserService` |
| Repository | PascalCase + Repository | `UserRepository` |
| Interface | PascalCase + Interface | `UserRepositoryInterface` |
| Request | PascalCase + Request | `StoreUserRequest` |
| Resource | PascalCase + Resource | `UserResource` |
| Event | Past tense | `UserCreated` |
| Listener | Present tense | `SendWelcomeEmail` |
| Job | Verb phrase | `ProcessPayment` |

### Database Conventions

```php
// Migration naming: {timestamp}_create_{table}_table.php
// Table names: plural, snake_case (users, blog_posts)
// Column names: snake_case (first_name, created_at)
// Foreign keys: {singular}_id (user_id, post_id)
// Pivot tables: alphabetical order (post_tag, not tag_post)
```

## Slash Commands

Available commands in `.claude/commands/`:

- `/artisan` - Run artisan commands with context
- `/make-feature` - Create complete feature (Controller, Service, Repository, Tests)
- `/migrate` - Run migrations with safety checks
- `/test` - Run PHPUnit tests
- `/deploy` - Deployment checklist

## Common Workflows

### Adding a New Feature

1. Create migration: `php artisan make:migration create_items_table`
2. Create model: `php artisan make:model Item`
3. Create repository interface and implementation
4. Create service
5. Create controller with request validation
6. Create API resource
7. Add routes
8. Write tests

### API Development

```php
// routes/api.php
Route::apiResource('items', ItemController::class);

// app/Http/Controllers/ItemController.php
public function index(): AnonymousResourceCollection
{
    $items = $this->itemService->paginate();
    return ItemResource::collection($items);
}

public function store(StoreItemRequest $request): ItemResource
{
    $item = $this->itemService->create($request->validated());
    return new ItemResource($item);
}
```

### Running Tests

```bash
# All tests
php artisan test

# Specific test
php artisan test --filter=UserServiceTest

# With coverage
php artisan test --coverage
```

## Docker Environment

```bash
# Start all services
docker compose up -d

# Run artisan commands
docker compose exec app php artisan migrate

# Access MySQL
docker compose exec db mysql -u laravel -p

# View logs
docker compose logs -f app
```

## Security Rules

### Critical (Never Skip)

1. **Never** commit `.env` files
2. **Always** use `$request->validated()` for input
3. **Never** use raw SQL without bindings
4. **Always** use CSRF protection for forms

### Important

1. Use Form Requests for validation
2. Use Policies for authorization
3. Use Sanctum/Passport for API auth
4. Encrypt sensitive data

## Environment Variables

```bash
# Required
APP_KEY=             # Generate with: php artisan key:generate
DB_CONNECTION=mysql
DB_HOST=db
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret

# Optional - Supabase
SUPABASE_URL=
SUPABASE_KEY=

# Optional - Redis
REDIS_HOST=redis
CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
```

## Troubleshooting

### Common Issues

```bash
# Clear all caches
php artisan optimize:clear

# Regenerate autoload
composer dump-autoload

# Fix permissions
chmod -R 775 storage bootstrap/cache

# Reset database
php artisan migrate:fresh --seed
```

### Docker Issues

```bash
# Rebuild containers
docker compose build --no-cache

# Reset volumes
docker compose down -v
docker compose up -d
```

## Performance Tips

1. **Eager Loading**: Always use `with()` to prevent N+1
2. **Chunking**: Use `chunk()` for large datasets
3. **Caching**: Use Redis for frequently accessed data
4. **Queue**: Offload heavy tasks to queue workers

## References

- [Laravel Documentation](https://laravel.com/docs)
- [Laravel Best Practices](https://github.com/alexeymezenin/laravel-best-practices)
- [PHP The Right Way](https://phptherightway.com/)
