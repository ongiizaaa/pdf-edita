#!/usr/bin/env bash
# Stop hook: ถ้า index.html ถูกแก้ ให้ commit แล้ว push ขึ้น main (เว็บเสิร์ฟจาก main)
set -uo pipefail

input=$(cat)
# กันวนซ้ำ: ถ้ารอบก่อน hook นี้บล็อกไปแล้ว ไม่บล็อกซ้ำ
[ "$(jq -r '.stop_hook_active // false' <<<"$input")" = "true" ] && retry=1 || retry=0

cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}" || exit 0

fail() {
  if [ "$retry" = 1 ]; then
    echo "{\"systemMessage\": \"push-index-to-main: $1\"}"
    exit 0
  fi
  echo "push-index-to-main: $1" >&2
  exit 2
}

# 1) index.html ยังไม่ได้ commit -> commit ให้อัตโนมัติ
if [ -n "$(git status --porcelain -- index.html)" ]; then
  git add -- index.html
  git commit -q -m "Update index.html" -- index.html || fail "commit index.html ไม่สำเร็จ"
fi

git fetch -q origin main || fail "fetch origin/main ไม่สำเร็จ"

# 2) ไม่มีอะไรใหม่ที่แตะ index.html เมื่อเทียบกับ main -> ไม่ต้องทำอะไร
git diff --quiet origin/main HEAD -- index.html && exit 0

# 3) เอา commit ไปต่อท้าย main ล่าสุด แล้ว push
if ! git merge-base --is-ancestor origin/main HEAD; then
  git rebase -q origin/main || { git rebase --abort; fail "rebase บน origin/main ชนกัน (conflict) — แก้ conflict แล้ว push HEAD:main เอง"; }
fi
git push -q origin HEAD:main || fail "git push origin HEAD:main ไม่สำเร็จ"

echo "{\"systemMessage\": \"index.html pushed to main ($(git rev-parse --short HEAD))\"}"
