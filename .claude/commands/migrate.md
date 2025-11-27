# Database Migration

Run Laravel migrations with safety checks.

## Usage

Optional arguments:
- (none) - Run pending migrations
- `fresh` - Drop all tables and re-run migrations
- `fresh --seed` - Fresh migration with seeders
- `rollback` - Rollback last batch
- `status` - Show migration status

## Instructions

1. **Before running migrations:**
   - Check current migration status
   - Warn if running `fresh` in production environment

2. **Run the migration:**
   ```bash
   docker compose exec app php artisan migrate $ARGUMENTS
   ```

3. **After migration:**
   - Show updated migration status
   - List any new tables created
   - Remind about seeders if database is empty

## Safety Checks

- Never run `migrate:fresh` if `APP_ENV=production`
- Always backup before destructive operations
- Show confirmation for rollback operations
