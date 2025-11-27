# =============================================================================
# Laravel Makefile - Docker環境対応
# =============================================================================
# 使用方法: make <target>
# ヘルプ: make help
# =============================================================================

.PHONY: help init setup setup-fast validate test lint format run clean

# デフォルトターゲット
.DEFAULT_GOAL := help

# 設定
DOCKER_COMPOSE := docker compose
PHP := $(DOCKER_COMPOSE) exec app php
ARTISAN := $(PHP) artisan
COMPOSER := $(DOCKER_COMPOSE) exec app composer
NPM := $(DOCKER_COMPOSE) exec app npm
SCRIPTS_DIR := scripts

# カラー定義
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

# =============================================================================
# ヘルプ
# =============================================================================

help: ## このヘルプを表示
	@echo ""
	@echo "$(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(CYAN)📋 Laravel 利用可能なコマンド$(NC)"
	@echo "$(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

# =============================================================================
# セットアップ
# =============================================================================

init: ## 初回セットアップ（対話式）
	@echo "$(CYAN)🚀 プロジェクトセットアップを開始...$(NC)"
	@if [ -f "$(SCRIPTS_DIR)/setup-project.sh" ]; then \
		bash $(SCRIPTS_DIR)/setup-project.sh; \
	else \
		echo "$(RED)❌ setup-project.sh が見つかりません$(NC)"; \
		exit 1; \
	fi

setup: validate ## Docker環境をセットアップ
	@echo "$(CYAN)📦 Docker環境をセットアップ中...$(NC)"
	$(DOCKER_COMPOSE) build
	$(DOCKER_COMPOSE) up -d
	@sleep 5
	$(COMPOSER) install
	$(ARTISAN) key:generate --force
	$(ARTISAN) migrate --force
	$(NPM) install
	$(NPM) run build
	@echo "$(GREEN)✅ セットアップ完了$(NC)"
	@echo "$(CYAN)🌐 http://localhost:8080 でアクセスできます$(NC)"

setup-fast: validate ## Docker環境を高速セットアップ（キャッシュ使用）
	@echo "$(CYAN)⚡ 高速セットアップ中...$(NC)"
	$(DOCKER_COMPOSE) up -d
	@sleep 3
	$(COMPOSER) install --prefer-dist --no-progress
	$(ARTISAN) key:generate --force
	$(ARTISAN) migrate --force
	@echo "$(GREEN)✅ 高速セットアップ完了$(NC)"

# =============================================================================
# 検証
# =============================================================================

validate: ## 環境変数を検証
	@echo "$(CYAN)🔍 環境変数を検証中...$(NC)"
	@if [ -f "$(SCRIPTS_DIR)/validate-env.py" ]; then \
		python3 $(SCRIPTS_DIR)/validate-env.py; \
	else \
		echo "$(YELLOW)⚠️  validate-env.py が見つかりません$(NC)"; \
	fi

validate-strict: ## 環境変数を厳密に検証
	@echo "$(CYAN)🔍 環境変数を厳密に検証中...$(NC)"
	@if [ -f "$(SCRIPTS_DIR)/validate-env.py" ]; then \
		python3 $(SCRIPTS_DIR)/validate-env.py --strict; \
	fi

# =============================================================================
# Docker操作
# =============================================================================

up: ## Dockerコンテナを起動
	@echo "$(CYAN)🐳 Docker起動中...$(NC)"
	$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)✅ 起動完了: http://localhost:8080$(NC)"

down: ## Dockerコンテナを停止
	@echo "$(CYAN)🐳 Docker停止中...$(NC)"
	$(DOCKER_COMPOSE) down
	@echo "$(GREEN)✅ 停止完了$(NC)"

restart: ## Dockerコンテナを再起動
	@echo "$(CYAN)🐳 Docker再起動中...$(NC)"
	$(DOCKER_COMPOSE) restart
	@echo "$(GREEN)✅ 再起動完了$(NC)"

logs: ## Dockerログを表示
	$(DOCKER_COMPOSE) logs -f

ps: ## Dockerコンテナ状態を表示
	$(DOCKER_COMPOSE) ps

shell: ## アプリコンテナにシェルで入る
	$(DOCKER_COMPOSE) exec app bash

# =============================================================================
# Laravel Artisan
# =============================================================================

run: up ## 開発サーバーを起動（Docker）
	@echo "$(GREEN)✅ 開発サーバー起動中: http://localhost:8080$(NC)"

artisan: ## Artisanコマンドを実行（例: make artisan cmd="migrate"）
	$(ARTISAN) $(cmd)

migrate: ## マイグレーションを実行
	@echo "$(CYAN)🗄️ マイグレーション実行中...$(NC)"
	$(ARTISAN) migrate

migrate-fresh: ## データベースをリセットしてマイグレーション
	@echo "$(CYAN)🗄️ データベースリセット中...$(NC)"
	$(ARTISAN) migrate:fresh --seed

seed: ## シーダーを実行
	$(ARTISAN) db:seed

tinker: ## Tinkerを起動
	$(ARTISAN) tinker

# =============================================================================
# 開発
# =============================================================================

test: ## PHPUnitテストを実行
	@echo "$(CYAN)🧪 テスト実行中...$(NC)"
	$(ARTISAN) test

test-coverage: ## テストをカバレッジ付きで実行
	@echo "$(CYAN)🧪 カバレッジ付きテスト実行中...$(NC)"
	$(ARTISAN) test --coverage

lint: ## PHP_CodeSnifferでリント
	@echo "$(CYAN)🔍 リント実行中...$(NC)"
	$(DOCKER_COMPOSE) exec app ./vendor/bin/phpcs --standard=PSR12 app/

format: ## PHP-CS-Fixerでフォーマット
	@echo "$(CYAN)✨ フォーマット中...$(NC)"
	$(DOCKER_COMPOSE) exec app ./vendor/bin/php-cs-fixer fix app/

# =============================================================================
# フロントエンド
# =============================================================================

npm: ## NPMコマンドを実行（例: make npm cmd="run dev"）
	$(NPM) $(cmd)

dev: ## Vite開発サーバーを起動
	$(NPM) run dev

build: ## フロントエンドをビルド
	$(NPM) run build

# =============================================================================
# クリーンアップ
# =============================================================================

clean: ## キャッシュをクリア
	@echo "$(CYAN)🧹 キャッシュクリア中...$(NC)"
	$(ARTISAN) optimize:clear
	@echo "$(GREEN)✅ キャッシュクリア完了$(NC)"

clean-all: down ## Docker環境を完全削除
	@echo "$(CYAN)🗑️ Docker環境を完全削除中...$(NC)"
	$(DOCKER_COMPOSE) down -v --rmi local
	@echo "$(GREEN)✅ 完全削除完了$(NC)"

# =============================================================================
# 情報
# =============================================================================

info: ## プロジェクト情報を表示
	@echo ""
	@echo "$(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(CYAN)📊 Laravel プロジェクト情報$(NC)"
	@echo "$(CYAN)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo ""
	@echo "$(GREEN)Docker:$(NC) $$(docker --version 2>/dev/null | head -1 || echo 'Not found')"
	@echo "$(GREEN)コンテナ状態:$(NC)"
	@$(DOCKER_COMPOSE) ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "  コンテナ未起動"
	@echo ""
	@echo "$(GREEN).env:$(NC) $$(if [ -f ".env" ]; then echo '$(GREEN)✅ 存在$(NC)'; else echo '$(YELLOW)❌ 未作成$(NC)'; fi)"
	@echo ""
