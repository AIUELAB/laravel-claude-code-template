# Laravel Boost

Claude Code + MCP連携に最適化されたLaravel開発テンプレート

## Features

- **Laravel 11 + PHP 8.3** - 最新のLaravelフレームワーク
- **Claude Code統合** - AI支援開発に最適化されたCLAUDE.md
- **MCP連携** - filesystem, GitHub, Context7, Supabase対応
- **Docker環境** - 開発環境を即座に構築
- **カスタムスラッシュコマンド** - `/artisan`, `/make-feature`, `/test`, `/migrate`, `/deploy`
- **CI/CD** - GitHub Actions による自動テスト・デプロイ
- **Clean Architecture** - Repository + Service パターン

## Quick Start

### 1. Clone & Setup

```bash
# リポジトリをクローン
git clone https://github.com/AIUELAB/laravel-claude-code-template.git my-project
cd my-project

# 環境変数をコピー
cp .env.example .env

# Docker起動
docker compose up -d

# 依存関係インストール
docker compose exec app composer install

# アプリケーションキー生成
docker compose exec app php artisan key:generate

# マイグレーション実行
docker compose exec app php artisan migrate
```

### 2. アクセス

| Service | URL |
|---------|-----|
| Application | http://localhost:8080 |
| Mailpit | http://localhost:8025 |
| MySQL | localhost:3306 |
| Redis | localhost:6379 |

## Project Structure

```
.
├── .claude/
│   └── commands/           # カスタムスラッシュコマンド
│       ├── artisan.md      # Artisan実行
│       ├── make-feature.md # 機能生成
│       ├── test.md         # テスト実行
│       ├── migrate.md      # マイグレーション
│       └── deploy.md       # デプロイチェックリスト
├── .github/
│   └── workflows/          # GitHub Actions CI/CD
├── app/
│   ├── Http/               # Controllers, Requests, Resources
│   ├── Domain/             # Business logic
│   │   ├── Models/
│   │   ├── Services/
│   │   └── Repositories/
│   └── Infrastructure/     # External services
├── docker/                 # Docker設定
├── mcp-config/
│   └── profiles/           # MCPプロファイル
└── CLAUDE.md               # Claude Code指示書
```

## Slash Commands

| Command | Description |
|---------|-------------|
| `/artisan` | Artisanコマンドを実行 |
| `/make-feature` | 完全な機能を生成（Controller, Service, Repository, Tests） |
| `/test` | PHPUnitテストを実行 |
| `/migrate` | マイグレーションを実行（安全チェック付き） |
| `/deploy` | デプロイチェックリストを表示 |

## MCP Profiles

| Profile | Tokens | MCPs |
|---------|--------|------|
| `minimal` | ~600 | filesystem |
| `standard` | ~1,800 | filesystem, github, context7 |
| `full` | ~3,500 | + postgres, brave-search, supabase |

## Development

### テスト実行

```bash
docker compose exec app php artisan test
```

### コードスタイル

```bash
# フォーマット
docker compose exec app ./vendor/bin/pint

# 静的解析
docker compose exec app ./vendor/bin/phpstan analyse
```

### 新機能追加

```bash
# Claude Codeで /make-feature Product を実行すると：
# - Model + Migration + Factory + Seeder
# - Controller (API Resource)
# - Form Requests
# - Repository Interface + Implementation
# - Service
# - Tests
# が自動生成されます
```

## Docker Commands

```bash
# 起動
docker compose up -d

# 停止
docker compose down

# ログ確認
docker compose logs -f app

# コンテナに入る
docker compose exec app bash

# キャッシュクリア
docker compose exec app php artisan optimize:clear
```

## Environment Variables

```bash
# .env
APP_NAME=LaravelBoost
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8080

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret

CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

MIT License
