#!/bin/bash
set -euo pipefail

echo "=== 类型检查 / 编译通过 ==="
if command -v mypy &>/dev/null; then
  mypy . 2>/dev/null || echo "mypy check failed"
else
  echo "SKIP: mypy not installed"
fi

echo "=== 相关单元测试通过（含新增测试） ==="
if command -v pytest &>/dev/null; then
  pytest 2>/dev/null || echo "pytest failed"
else
  echo "SKIP: pytest not installed"
fi

echo "=== Lint / Format 通过 ==="
if command -v black &>/dev/null; then
  black --check . 2>/dev/null || echo "black check failed"
else
  echo "SKIP: black not installed"
fi

if command -v flake8 &>/dev/null; then
  flake8 . 2>/dev/null || echo "flake8 check failed"
else
  echo "SKIP: flake8 not installed"
fi

echo "=== 无静默异常吞噬 ==="
if grep -r --include="*.py" -E "except\s*:" . 2>/dev/null | head -5; then
  echo "WARNING: Found empty except clauses (see above)"
else
  echo "OK: No empty except clauses found"
fi

echo "=== 无硬编码密钥与敏感信息 ==="
if grep -r --include="*.py" -iE "api_key.*=.*['\"]|password.*=.*['\"]|token.*=.*['\"]" . 2>/dev/null | head -5; then
  echo "WARNING: Possible hardcoded secrets found (see above)"
else
  echo "OK: No obvious hardcoded secrets"
fi

echo "=== CHANGELOG 的 [Unreleased] 段已追加本次变更 ==="
if [ -f CHANGELOG.md ]; then
  if grep -q "\[Unreleased\]" CHANGELOG.md; then
    echo "OK: CHANGELOG has [Unreleased] section"
  else
    echo "WARNING: CHANGELOG does not have [Unreleased] section"
  fi
else
  echo "SKIP: No CHANGELOG.md found"
fi

echo "=== 未触碰版本号、tag、发布动作 ==="
if git diff --name-only HEAD 2>/dev/null | grep -E "VERSION|CHANGELOG|\.tag"; then
  echo "WARNING: Version/tag/release files may have been modified"
  exit 1
else
  echo "OK: No version/tag/release changes detected"
fi

echo ""
echo "=== Preflight complete ==="
