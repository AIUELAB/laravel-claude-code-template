#!/usr/bin/env python3
"""
validate-env.py - 環境変数の検証スクリプト

このスクリプトは以下を検証します：
1. 必須環境変数が設定されているか
2. プレースホルダー（CHANGE_ME）が残っていないか
3. 環境変数の形式が正しいか

使用方法:
    python scripts/validate-env.py [--strict] [--env-file .env]

オプション:
    --strict    警告もエラーとして扱う
    --env-file  読み込む.envファイルのパス（デフォルト: .env）
"""

import os
import sys
import re
import argparse
from pathlib import Path
from typing import Optional

# =============================================================================
# 設定: プロジェクトに応じてこの部分をカスタマイズしてください
# =============================================================================

# 必須環境変数（未設定またはプレースホルダーの場合はエラー）
REQUIRED_VARS: dict[str, dict] = {
    'PROJECT_NAME': {
        'pattern': r'^[a-z][a-z0-9_-]+$',
        'error': 'プロジェクト名は小文字英字で始まり、小文字英数字・ハイフン・アンダースコアのみ使用可能',
        'placeholder': 'CHANGE_ME',
    },
}

# プロジェクト固有の必須変数（Supabaseを使用する場合はコメント解除）
# REQUIRED_VARS.update({
#     'SUPABASE_URL': {
#         'pattern': r'^https://[a-z0-9]+\.supabase\.co$',
#         'error': 'Supabase URLの形式が不正です（例: https://xxxxx.supabase.co）',
#         'placeholder': 'CHANGE_ME',
#     },
#     'SUPABASE_ANON_KEY': {
#         'pattern': r'^eyJ',
#         'error': 'Supabase Anon Keyの形式が不正です（JWTトークン形式）',
#         'placeholder': 'CHANGE_ME',
#     },
# })

# オプション環境変数（設定されていれば形式を検証、未設定はOK）
OPTIONAL_VARS: dict[str, dict] = {
    'ANTHROPIC_API_KEY': {
        'pattern': r'^sk-ant-',
        'error': 'Anthropic APIキーは "sk-ant-" で始まる必要があります',
    },
    'OPENAI_API_KEY': {
        'pattern': r'^sk-',
        'error': 'OpenAI APIキーは "sk-" で始まる必要があります',
    },
    'GITHUB_TOKEN': {
        'pattern': r'^(ghp_|gho_|github_pat_)',
        'error': 'GitHub Tokenの形式が不正です',
    },
}

# プレースホルダーとして認識するパターン
PLACEHOLDER_PATTERNS = [
    'CHANGE_ME',
    'your_',
    'YOUR_',
    '<your-',
    'xxx',
    'placeholder',
    'example',
]

# =============================================================================
# カラー出力
# =============================================================================

class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

def print_error(msg: str) -> None:
    print(f"{Colors.RED}❌ {msg}{Colors.NC}")

def print_warning(msg: str) -> None:
    print(f"{Colors.YELLOW}⚠️  {msg}{Colors.NC}")

def print_success(msg: str) -> None:
    print(f"{Colors.GREEN}✅ {msg}{Colors.NC}")

def print_info(msg: str) -> None:
    print(f"{Colors.BLUE}ℹ️  {msg}{Colors.NC}")

# =============================================================================
# 検証ロジック
# =============================================================================

def is_placeholder(value: str) -> bool:
    """値がプレースホルダーかどうかを判定"""
    value_lower = value.lower()
    return any(pattern.lower() in value_lower for pattern in PLACEHOLDER_PATTERNS)

def validate_var(
    name: str,
    config: dict,
    required: bool = True
) -> tuple[bool, Optional[str]]:
    """
    環境変数を検証

    Returns:
        (is_valid, error_message)
    """
    value = os.getenv(name, '')

    # 未設定チェック
    if not value:
        if required:
            return False, f"{name} が設定されていません"
        return True, None

    # プレースホルダーチェック
    placeholder = config.get('placeholder')
    if placeholder and placeholder in value:
        return False, f"{name} がプレースホルダーのままです（値: {value}）"

    if is_placeholder(value):
        return False, f"{name} がプレースホルダーのままです（値: {value}）"

    # パターンチェック
    pattern = config.get('pattern')
    if pattern and not re.match(pattern, value):
        error_msg = config.get('error', f'{name} の形式が不正です')
        return False, f"{name}: {error_msg}"

    return True, None

def load_env_file(env_file: Path) -> bool:
    """
    .envファイルを読み込んで環境変数に設定

    Returns:
        ファイルが存在して読み込めたかどうか
    """
    if not env_file.exists():
        return False

    try:
        # python-dotenvがあれば使用
        from dotenv import load_dotenv
        load_dotenv(env_file)
        return True
    except ImportError:
        # なければ手動でパース
        with open(env_file, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, _, value = line.partition('=')
                    key = key.strip()
                    value = value.strip().strip('"').strip("'")
                    os.environ[key] = value
        return True

def validate_all(strict: bool = False) -> bool:
    """
    すべての環境変数を検証

    Args:
        strict: Trueの場合、警告もエラーとして扱う

    Returns:
        すべての検証が通ったかどうか
    """
    errors: list[str] = []
    warnings: list[str] = []

    print()
    print("=" * 60)
    print("環境変数の検証を実行中...")
    print("=" * 60)
    print()

    # 必須変数の検証
    print("📋 必須変数のチェック:")
    for name, config in REQUIRED_VARS.items():
        is_valid, error_msg = validate_var(name, config, required=True)
        if is_valid:
            value = os.getenv(name, '')
            masked = value[:10] + '...' if len(value) > 10 else value
            print_success(f"{name} = {masked}")
        else:
            errors.append(error_msg)
            print_error(error_msg)

    print()

    # オプション変数の検証
    print("📋 オプション変数のチェック:")
    for name, config in OPTIONAL_VARS.items():
        value = os.getenv(name, '')
        if not value:
            print_info(f"{name} = (未設定)")
            continue

        is_valid, error_msg = validate_var(name, config, required=False)
        if is_valid:
            masked = value[:10] + '...' if len(value) > 10 else value
            print_success(f"{name} = {masked}")
        else:
            warnings.append(error_msg)
            print_warning(error_msg)

    print()
    print("=" * 60)

    # 結果表示
    if errors:
        print()
        print_error(f"エラー: {len(errors)}件")
        for error in errors:
            print(f"  - {error}")
        print()
        print("🛑 環境変数の設定を確認してください")
        print("   .env ファイルを編集して、CHANGE_ME の項目を適切な値に変更してください")
        print()
        return False

    if warnings:
        print()
        print_warning(f"警告: {len(warnings)}件")
        for warning in warnings:
            print(f"  - {warning}")
        if strict:
            print()
            print("🛑 strict モードのため、警告をエラーとして扱います")
            return False

    print()
    print_success("環境変数の検証に成功しました")
    print()
    return True

# =============================================================================
# メイン
# =============================================================================

def main() -> int:
    parser = argparse.ArgumentParser(
        description='環境変数を検証します',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    parser.add_argument(
        '--strict',
        action='store_true',
        help='警告もエラーとして扱う'
    )
    parser.add_argument(
        '--env-file',
        type=Path,
        default=Path('.env'),
        help='読み込む.envファイルのパス（デフォルト: .env）'
    )

    args = parser.parse_args()

    # .envファイルを読み込み
    if args.env_file.exists():
        load_env_file(args.env_file)
        print_info(f"環境変数ファイルを読み込みました: {args.env_file}")
    else:
        print_warning(f"環境変数ファイルが見つかりません: {args.env_file}")
        print_info("環境変数から直接読み込みます")

    # 検証実行
    success = validate_all(strict=args.strict)

    return 0 if success else 1

if __name__ == '__main__':
    sys.exit(main())
