# Laravel プロジェクト セットアップガイド

このドキュメントは、Laravelテンプレートから新しいプロジェクトを作成する際のセットアップ手順を説明します。

## クイックスタート

```bash
# 1. セットアップスクリプトを実行
make init

# 2. .envファイルを編集（APP_KEYは自動生成されます）
# 3. Docker環境を起動
make setup

# 4. ブラウザでアクセス
open http://localhost:8080
```

## 詳細セットアップ

### ステップ 1: 環境変数の設定

```bash
# 対話式セットアップ（推奨）
make init

# または手動で
cp .env.example .env
# .envを編集してPROJECT_NAMEを変更
```

### ステップ 2: Docker環境の起動

```bash
# 標準セットアップ
make setup

# または高速セットアップ（キャッシュ使用）
make setup-fast
```

これにより以下が実行されます：
- Dockerコンテナのビルド・起動
- Composerパッケージのインストール
- APP_KEYの生成
- データベースマイグレーション
- NPMパッケージのインストール
- フロントエンドのビルド

### ステップ 3: 動作確認

- **アプリケーション**: http://localhost:8080
- **Mailpit (メール確認)**: http://localhost:8025

---

## セットアップチェックリスト

### 必須項目

- [ ] `.env`ファイルを作成した
- [ ] `PROJECT_NAME`を設定した
- [ ] `make validate`がエラーなしで通過した
- [ ] Dockerコンテナが起動している（`make ps`で確認）
- [ ] http://localhost:8080 にアクセスできる

### オプション項目

- [ ] データベース設定をカスタマイズ
- [ ] Redis設定をカスタマイズ
- [ ] メール設定をカスタマイズ

---

## 利用可能なコマンド

### セットアップ

```bash
make init           # 初回セットアップ（対話式）
make setup          # Docker環境セットアップ
make setup-fast     # 高速セットアップ
make validate       # 環境変数検証
```

### Docker操作

```bash
make up             # コンテナ起動
make down           # コンテナ停止
make restart        # コンテナ再起動
make logs           # ログ表示
make ps             # コンテナ状態表示
make shell          # コンテナ内シェル
```

### Laravel開発

```bash
make run            # 開発サーバー起動
make migrate        # マイグレーション実行
make migrate-fresh  # DB リセット + マイグレーション
make seed           # シーダー実行
make tinker         # Tinker起動
make test           # テスト実行
make test-coverage  # カバレッジ付きテスト
```

### コード品質

```bash
make lint           # リント実行
make format         # フォーマット
make clean          # キャッシュクリア
```

### フロントエンド

```bash
make dev            # Vite開発サーバー
make build          # 本番ビルド
```

---

## Docker構成

| サービス | ポート | 説明 |
|---------|-------|------|
| app | 8080 | Laravel アプリケーション |
| db | 3306 | MySQL データベース |
| redis | 6379 | Redis キャッシュ |
| mailpit | 8025 | メールテストUI |

---

## トラブルシューティング

### よくある問題

#### 1. ポートが使用中

```bash
# 使用中のポートを確認
lsof -i :8080

# 別のプロセスを停止するか、.envでポートを変更
APP_PORT=8081
```

#### 2. パーミッションエラー

```bash
# コンテナ内でパーミッションを修正
make shell
chmod -R 775 storage bootstrap/cache
```

#### 3. データベース接続エラー

```bash
# DBコンテナが起動しているか確認
make ps

# DBコンテナを再起動
docker compose restart db
```

#### 4. Composerメモリ不足

```bash
# メモリ制限を増やして実行
docker compose exec app php -d memory_limit=-1 /usr/bin/composer install
```

---

## MCP連携（Claude Code使用時）

### 基本設定

`.env.mcp`ファイルを作成：

```bash
cp .env.mcp.example .env.mcp
# APIキーを設定
```

### 推奨MCPプロファイル

- **minimal**: filesystem + GitHub のみ（最速）
- **standard**: + Context7 + Brave Search
- **full**: 全機能有効

---

## 次のステップ

1. **CLAUDE.md**を確認 - Laravel開発ガイドライン
2. **README.md**を確認 - プロジェクト概要
3. `/artisan` コマンドでArtisan操作
4. `/make-feature` で新機能を作成
