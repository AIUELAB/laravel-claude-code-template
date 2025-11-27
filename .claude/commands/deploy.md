# Deployment Checklist

Pre-deployment verification and deployment steps.

## Instructions

### Pre-Deployment Checks

1. **Code Quality**
   ```bash
   docker compose exec app ./vendor/bin/pint --test
   docker compose exec app ./vendor/bin/phpstan analyse
   ```

2. **Tests**
   ```bash
   docker compose exec app php artisan test
   ```

3. **Environment**
   - Check `.env.production` exists
   - Verify `APP_DEBUG=false`
   - Verify `APP_ENV=production`

4. **Dependencies**
   ```bash
   composer install --no-dev --optimize-autoloader
   npm run build
   ```

### Deployment Steps

1. **Enable Maintenance Mode**
   ```bash
   php artisan down --secret="your-bypass-token"
   ```

2. **Pull Latest Code**
   ```bash
   git pull origin main
   ```

3. **Install Dependencies**
   ```bash
   composer install --no-dev --optimize-autoloader
   npm ci && npm run build
   ```

4. **Run Migrations**
   ```bash
   php artisan migrate --force
   ```

5. **Clear & Rebuild Caches**
   ```bash
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   php artisan event:cache
   ```

6. **Restart Queue Workers**
   ```bash
   php artisan queue:restart
   ```

7. **Disable Maintenance Mode**
   ```bash
   php artisan up
   ```

### Post-Deployment

- Verify application is accessible
- Check error logs
- Monitor performance metrics
