#!/bin/bash
# =============================================================================
# setup-project.sh - テンプレートプロジェクトの対話式セットアップ
# =============================================================================
# 使用方法: ./scripts/setup-project.sh
# このスクリプトは新しいプロジェクトを複製した後、最初に実行してください
# =============================================================================

set -e

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ヘルパー関数
print_header() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# メイン処理開始
print_header "🚀 プロジェクトセットアップウィザード"

echo ""
echo "このスクリプトは以下を行います："
echo "  1. プロジェクト名の設定"
echo "  2. 環境変数ファイル（.env）の生成"
echo "  3. 共通APIキーの読み込み（オプション）"
echo "  4. Python仮想環境のセットアップ（該当する場合）"
echo "  5. 環境変数の検証"
echo ""

# =============================================================================
# Step 1: プロジェクト名の入力
# =============================================================================
print_header "📛 Step 1: プロジェクト名の設定"

# 現在のディレクトリ名をデフォルトとして提案
DEFAULT_PROJECT_NAME=$(basename "$(pwd)")
read -p "プロジェクト名を入力してください [${DEFAULT_PROJECT_NAME}]: " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-$DEFAULT_PROJECT_NAME}

# プロジェクト名の検証（小文字英数字、ハイフン、アンダースコアのみ）
if [[ ! "$PROJECT_NAME" =~ ^[a-z][a-z0-9_-]*$ ]]; then
    print_error "プロジェクト名は小文字英字で始まり、小文字英数字・ハイフン・アンダースコアのみ使用可能です"
    exit 1
fi

print_success "プロジェクト名: ${PROJECT_NAME}"

# =============================================================================
# Step 2: .env ファイルの生成
# =============================================================================
print_header "📝 Step 2: 環境変数ファイルの生成"

if [ -f ".env.example" ]; then
    if [ -f ".env" ]; then
        read -p ".env ファイルが既に存在します。上書きしますか？ [y/N]: " OVERWRITE
        if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
            print_warning ".env ファイルをスキップしました"
        else
            cp .env.example .env
            print_success ".env ファイルを生成しました"
        fi
    else
        cp .env.example .env
        print_success ".env ファイルを生成しました"
    fi

    # プロジェクト名を置換
    if [ -f ".env" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/CHANGE_ME_project_name/${PROJECT_NAME}/g" .env
        else
            sed -i "s/CHANGE_ME_project_name/${PROJECT_NAME}/g" .env
        fi
        print_success ".env にプロジェクト名を設定しました"
    fi
else
    print_warning ".env.example が見つかりません。スキップします"
fi

# MCP設定ファイル
if [ -f ".env.mcp.example" ]; then
    if [ ! -f ".env.mcp" ]; then
        cp .env.mcp.example .env.mcp
        print_success ".env.mcp ファイルを生成しました"
    else
        print_info ".env.mcp ファイルは既に存在します"
    fi
fi

# =============================================================================
# Step 3: 共通APIキーの読み込み（オプション）
# =============================================================================
print_header "🔑 Step 3: 共通APIキーの読み込み"

KEY_DIR="/Users/$USER/Documents/key"
KEYS_LOADED=0

if [ -d "$KEY_DIR" ]; then
    echo "キーディレクトリを検出: ${KEY_DIR}"
    echo ""

    # Anthropic API Key
    if [ -f "${KEY_DIR}/anthropic_api_key.txt" ] || [ -f "${KEY_DIR}/ANTHROPIC_API_KEY.txt" ]; then
        KEY_FILE="${KEY_DIR}/anthropic_api_key.txt"
        [ -f "${KEY_DIR}/ANTHROPIC_API_KEY.txt" ] && KEY_FILE="${KEY_DIR}/ANTHROPIC_API_KEY.txt"
        ANTHROPIC_KEY=$(cat "$KEY_FILE" | tr -d '\n')
        if [ -f ".env" ] && [ -n "$ANTHROPIC_KEY" ]; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s|ANTHROPIC_API_KEY=.*|ANTHROPIC_API_KEY=${ANTHROPIC_KEY}|g" .env
            else
                sed -i "s|ANTHROPIC_API_KEY=.*|ANTHROPIC_API_KEY=${ANTHROPIC_KEY}|g" .env
            fi
            print_success "Anthropic APIキーを読み込みました"
            ((KEYS_LOADED++))
        fi
    fi

    # OpenAI API Key
    if [ -f "${KEY_DIR}/openai_api_key.txt" ] || [ -f "${KEY_DIR}/OPENAI_API_KEY.txt" ]; then
        KEY_FILE="${KEY_DIR}/openai_api_key.txt"
        [ -f "${KEY_DIR}/OPENAI_API_KEY.txt" ] && KEY_FILE="${KEY_DIR}/OPENAI_API_KEY.txt"
        OPENAI_KEY=$(cat "$KEY_FILE" | tr -d '\n')
        if [ -f ".env" ] && [ -n "$OPENAI_KEY" ]; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s|OPENAI_API_KEY=.*|OPENAI_API_KEY=${OPENAI_KEY}|g" .env
            else
                sed -i "s|OPENAI_API_KEY=.*|OPENAI_API_KEY=${OPENAI_KEY}|g" .env
            fi
            print_success "OpenAI APIキーを読み込みました"
            ((KEYS_LOADED++))
        fi
    fi

    # GitHub Token
    if [ -f "${KEY_DIR}/GITHUB_PAT_key.txt" ] || [ -f "${KEY_DIR}/github_token.txt" ]; then
        KEY_FILE="${KEY_DIR}/GITHUB_PAT_key.txt"
        [ -f "${KEY_DIR}/github_token.txt" ] && KEY_FILE="${KEY_DIR}/github_token.txt"
        GITHUB_TOKEN=$(cat "$KEY_FILE" | tr -d '\n')
        if [ -f ".env" ] && [ -n "$GITHUB_TOKEN" ]; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s|GITHUB_TOKEN=.*|GITHUB_TOKEN=${GITHUB_TOKEN}|g" .env
            else
                sed -i "s|GITHUB_TOKEN=.*|GITHUB_TOKEN=${GITHUB_TOKEN}|g" .env
            fi
            print_success "GitHub Tokenを読み込みました"
            ((KEYS_LOADED++))
        fi
    fi

    if [ $KEYS_LOADED -eq 0 ]; then
        print_info "読み込み可能なキーファイルが見つかりませんでした"
    fi
else
    print_info "キーディレクトリが見つかりません: ${KEY_DIR}"
    print_info "APIキーは手動で .env ファイルに設定してください"
fi

# =============================================================================
# Step 4: Python仮想環境のセットアップ（該当する場合）
# =============================================================================
if [ -f "requirements.txt" ]; then
    print_header "🐍 Step 4: Python仮想環境のセットアップ"

    read -p "Python仮想環境をセットアップしますか？ [Y/n]: " SETUP_VENV
    SETUP_VENV=${SETUP_VENV:-Y}

    if [[ "$SETUP_VENV" =~ ^[Yy]$ ]]; then
        # uvが使用可能かチェック
        if command -v uv &> /dev/null; then
            echo "uv を使用して高速セットアップを実行します..."
            uv venv
            uv pip install -r requirements.txt
            if [ -f "requirements-dev.txt" ]; then
                uv pip install -r requirements-dev.txt
            fi
            print_success "仮想環境をセットアップしました（uv使用）"
        else
            echo "標準のpipを使用してセットアップを実行します..."
            python3 -m venv venv
            source venv/bin/activate
            pip install --upgrade pip
            pip install -r requirements.txt
            if [ -f "requirements-dev.txt" ]; then
                pip install -r requirements-dev.txt
            fi
            print_success "仮想環境をセットアップしました"
        fi
    else
        print_info "仮想環境のセットアップをスキップしました"
    fi
fi

# =============================================================================
# Step 5: 環境変数の検証
# =============================================================================
print_header "🔍 Step 5: 環境変数の検証"

if [ -f "scripts/validate-env.py" ]; then
    if [ -d "venv" ]; then
        source venv/bin/activate
        python scripts/validate-env.py || true
    elif command -v python3 &> /dev/null; then
        python3 scripts/validate-env.py || true
    else
        print_warning "Python が見つかりません。検証をスキップします"
    fi
else
    print_info "validate-env.py が見つかりません。検証をスキップします"
fi

# =============================================================================
# 完了メッセージ
# =============================================================================
print_header "🎉 セットアップ完了！"

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}📋 次のステップ（必ず確認してください）${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "1. .env ファイルを開いて「CHANGE_ME」の項目を設定"
echo "   特に以下は必ず変更してください："
echo "   - SUPABASE_URL（新しいSupabaseプロジェクトを作成）"
echo "   - SUPABASE_ANON_KEY"
echo "   - SUPABASE_SERVICE_ROLE_KEY"
echo ""
echo "2. 仮想環境を有効化（Pythonプロジェクトの場合）："
echo "   source venv/bin/activate"
echo ""
echo "3. 開発サーバーを起動："
echo "   make run"
echo ""
echo -e "${RED}⚠️  重要: テンプレートのSupabaseキーは絶対に使用しないでください${NC}"
echo -e "${RED}   データの混在やセキュリティ問題の原因になります${NC}"
echo ""
