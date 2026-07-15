#!/bin/bash
# tests/test-setup-mcp-config.sh — 验证 setup-mcp-config.sh 核心行为

set -e
TEST_CONFIG="/tmp/test-config.yaml"
PASS=0; FAIL=0

# Test 1: detects missing paperclip_b/c
cat > "$TEST_CONFIG" << 'YAML'
mcp_servers:
  paperclip_a:
    command: /media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-a/wrapper.sh
    enabled: true
YAML

bash /media/ok2049/work/work/paperclip-mcp-v2/setup-mcp-config.sh --config "$TEST_CONFIG" --check-only 2>&1 | grep -q "MISSING: paperclip_b"
[ $? -eq 0 ] && echo "PASS: detects missing paperclip_b" && PASS=$((PASS+1)) || { echo "FAIL: does not detect missing paperclip_b"; FAIL=$((FAIL+1)); }

# Test 2: detects paperclip: 'null' residue
cat > "$TEST_CONFIG" << 'YAML'
mcp_servers:
  paperclip: 'null'
  paperclip_a:
    command: /media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-a/wrapper.sh
    enabled: true
YAML

bash /media/ok2049/work/work/paperclip-mcp-v2/setup-mcp-config.sh --config "$TEST_CONFIG" --check-only 2>&1 | grep -q "paperclip.*残留"
[ $? -eq 0 ] && echo "PASS: detects paperclip: null residue" && PASS=$((PASS+1)) || { echo "FAIL: does not detect paperclip: null"; FAIL=$((FAIL+1)); }

# Test 3: detects bad env on paperclip_a
cat > "$TEST_CONFIG" << 'YAML'
mcp_servers:
  paperclip_a:
    command: /media/ok2049/work/work/paperclip-mcp-v2/paperclip-mcp-v2-a/wrapper.sh
    enabled: true
    env: '{"PAPERCLIP_API_KEY":"test"}'
YAML

bash /media/ok2049/work/work/paperclip-mcp-v2/setup-mcp-config.sh --config "$TEST_CONFIG" --check-only 2>&1 | grep -q "env"
[ $? -eq 0 ] && echo "PASS: detects bad env on paperclip_a" && PASS=$((PASS+1)) || { echo "FAIL: does not detect bad env"; FAIL=$((FAIL+1)); }

echo "=== $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]
