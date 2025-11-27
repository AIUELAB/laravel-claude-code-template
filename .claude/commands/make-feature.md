# Make Feature Command

Create a complete feature with all necessary components.

## Usage

Provide a feature name (singular, PascalCase). Example: `Product`, `BlogPost`, `UserProfile`

## Instructions

Create the following files for the feature `$ARGUMENTS`:

### 1. Model
```bash
docker compose exec app php artisan make:model $ARGUMENTS -mfs
```

### 2. Controller (API Resource)
Create `app/Http/Controllers/{$ARGUMENTS}Controller.php`:
- Index, show, store, update, destroy methods
- Use Form Requests for validation
- Return API Resources

### 3. Form Requests
Create validation requests:
- `Store{$ARGUMENTS}Request.php`
- `Update{$ARGUMENTS}Request.php`

### 4. API Resource
Create `app/Http/Resources/{$ARGUMENTS}Resource.php`

### 5. Repository
Create:
- `app/Domain/Repositories/{$ARGUMENTS}RepositoryInterface.php`
- `app/Infrastructure/Persistence/Eloquent{$ARGUMENTS}Repository.php`

### 6. Service
Create `app/Domain/Services/{$ARGUMENTS}Service.php`

### 7. Tests
Create:
- `tests/Feature/{$ARGUMENTS}ControllerTest.php`
- `tests/Unit/{$ARGUMENTS}ServiceTest.php`

### 8. Routes
Add to `routes/api.php`:
```php
Route::apiResource('{plural_lowercase}', {$ARGUMENTS}Controller::class);
```

## Output

After creating all files:
1. Show the directory structure
2. Remind to run `php artisan migrate`
3. Show example API endpoints
