#!/bin/bash
set -e

# カラー出力用
RED='\033[0;31m'
NC='\033[0m' # No Color

# ステージングされたファイルを取得
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

# .env.keys がステージングされていないかチェック
if echo "$STAGED_FILES" | grep -qE '\.env\.keys$'; then
  echo -e "${RED}❌ 重大なエラー: .env.keys ファイルはコミットできません！${NC}"
  echo -e "${RED}   このファイルには暗号化キーが含まれており、絶対にコミットしてはいけません。${NC}"
  echo ""
  echo "ステージングから削除してください:"
  echo "  git reset HEAD .env.keys"
  exit 1
fi

# .env.decrypted がステージングされていないかチェック
if echo "$STAGED_FILES" | grep -qE '\.env\.decrypted$'; then
  echo -e "${RED}❌ 重大なエラー: .env.decrypted ファイルはコミットできません！${NC}"
  echo -e "${RED}   このファイルには復号済みの環境変数が含まれており、絶対にコミットしてはいけません。${NC}"
  echo ""
  echo "ステージングから削除してください:"
  echo "  git reset HEAD .env.decrypted"
  exit 1
fi
# ステージングされた .env ファイル（ディレクトリに関わらず）をチェック
# /\.env$ または ^\.env$ でマッチ（ディレクトリ区切り + .env または ルートの .env）
ENV_FILES=$(echo "$STAGED_FILES" | grep -E '(^|/)\.env(\.|$)' | grep -vE '\.env\.(keys|decrypted)$' || true)

if [ -n "$ENV_FILES" ]; then
  while IFS= read -r env_file; do
    # ステージングされたファイルの内容を取得
    ENV_CONTENT=$(git show ":0:$env_file" 2>/dev/null || echo "")

    # 新規追加の場合、ワークツリーの内容を確認
    if [ -z "$ENV_CONTENT" ] && [ -f "$env_file" ]; then
      ENV_CONTENT=$(cat "$env_file")
    fi

    # 内容がない場合はスキップ
    if [ -z "$ENV_CONTENT" ]; then
      continue
    fi

    # 【判定ロジック】
    # 1. コメント行、空行、DOTENV_PUBLIC_KEY行を除外
    # 2. 残った行の中で「encrypted:」という文字列が含まれない行を抽出
    UNENCRYPTED_LINES=$(echo "$ENV_CONTENT" | \
                        grep -v '^#' | \
                        grep -v '^[[:space:]]*$' | \
                        grep -v '^DOTENV_PUBLIC_KEY=' | \
                        grep -v 'encrypted:' || true)

    if [ -n "$UNENCRYPTED_LINES" ]; then
      echo -e "${RED}❌ エラー: $env_file 内に暗号化されていない行を検出しました！${NC}"
      echo -e "平文のままコミットしようとしています:"
      echo "$UNENCRYPTED_LINES" | while read -r line; do
        echo -e "${RED}  $line${NC}"
      done
      echo ""
      echo "✅ 対応策:"
      echo "1. 'dotenvx encrypt -f $env_file' を実行して暗号化してください。"
      echo "2. その後、'git add $env_file' をして再度コミットしてください。"
      exit 1
    fi
  done <<< "$ENV_FILES"
fi

exit 0
