# Artisan Command Runner

Run Laravel artisan commands with context awareness.

## Usage

Provide an artisan command to run. Examples:
- `make:model User -mfs` (with migration, factory, seeder)
- `make:controller UserController --api`
- `migrate:fresh --seed`
- `queue:work`
- `schedule:run`

## Instructions

1. Execute the artisan command in the Docker container:
   ```bash
   docker compose exec app php artisan $ARGUMENTS
   ```

2. If the command creates files, read and display the created file contents.

3. For `make:*` commands, suggest related commands that might be needed.

4. For migration commands, show the current migration status afterward.

5. Handle errors gracefully and suggest fixes.

## Context

- Working directory: Laravel project root
- PHP version: 8.3
- Laravel version: 11.x
