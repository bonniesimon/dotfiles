#!/bin/bash

# check-branch.sh - Run lint, prettier, typescript, and tests on changed files
# Usage: ./scripts/check-branch.sh [options]
#
# Options:
#   --skip-lint      Skip ESLint check
#   --skip-prettier  Skip Prettier check
#   --skip-tsc       Skip TypeScript check
#   --skip-tests     Skip Jest tests
#   --fail-fast      Stop on first failure
#   --base=<branch>  Base branch to compare against (default: origin/main)
#   -h, --help       Show this help message

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default options
SKIP_LINT=false
SKIP_PRETTIER=false
SKIP_TSC=false
SKIP_TESTS=false
FAIL_FAST=false
BASE_BRANCH="origin/main"

# Results tracking
LINT_RESULT=""
PRETTIER_RESULT=""
TSC_RESULT=""
TESTS_RESULT=""

# Parse arguments
for arg in "$@"; do
  case $arg in
    --skip-lint)
      SKIP_LINT=true
      shift
      ;;
    --skip-prettier)
      SKIP_PRETTIER=true
      shift
      ;;
    --skip-tsc)
      SKIP_TSC=true
      shift
      ;;
    --skip-tests)
      SKIP_TESTS=true
      shift
      ;;
    --fail-fast)
      FAIL_FAST=true
      shift
      ;;
    --base=*)
      BASE_BRANCH="${arg#*=}"
      shift
      ;;
    -h|--help)
      sed -n '2,14p' "$0" | sed 's/^# //' | sed 's/^#//'
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $arg${NC}"
      exit 1
      ;;
  esac
done

# Verify we're in a cherrim package directory
if [ ! -f "package.json" ] || ! grep -q '"name": "@spring/cherrim"' package.json 2>/dev/null; then
  echo -e "${RED}Error: This script must be run from the packages/cherrim directory${NC}"
  exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Branch Check Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Base branch: ${YELLOW}$BASE_BRANCH${NC}"
echo ""

# Get changed files (relative to packages/cherrim)
echo -e "${BLUE}Finding changed files...${NC}"
# Get files changed in packages/cherrim, then strip the packages/cherrim/ prefix
RAW_CHANGED=$(git diff --name-only "$BASE_BRANCH"...HEAD -- . 2>/dev/null || git diff --name-only "$BASE_BRANCH" -- . 2>/dev/null || echo "")
CHANGED_FILES=$(echo "$RAW_CHANGED" | sed 's|^packages/cherrim/||')

if [ -z "$CHANGED_FILES" ]; then
  echo -e "${YELLOW}No changed files found in packages/cherrim${NC}"
  echo ""
  echo -e "${GREEN}All checks passed (nothing to check)${NC}"
  exit 0
fi

# Filter for files that exist (ignore deleted files)
EXISTING_FILES=""
while IFS= read -r file; do
  if [ -n "$file" ] && [ -f "$file" ]; then
    EXISTING_FILES="$EXISTING_FILES$file"$'\n'
  fi
done <<< "$CHANGED_FILES"
EXISTING_FILES=$(echo "$EXISTING_FILES" | sed '/^$/d')

# Filter for lintable files (.ts, .tsx, .js, .jsx)
LINT_FILES=$(echo "$EXISTING_FILES" | grep -E '\.(ts|tsx|js|jsx)$' | grep -v '\.d\.ts$' || echo "")
# Filter for prettier-checkable files
PRETTIER_FILES=$(echo "$EXISTING_FILES" | grep -E '\.(ts|tsx|js|jsx|json|md|css|scss)$' || echo "")

echo -e "Changed files: ${YELLOW}$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')${NC}"
echo -e "Lintable files: ${YELLOW}$(echo "$LINT_FILES" | grep -c . || echo 0)${NC}"
echo ""

# Function to run a check
run_check() {
  local name=$1
  local skip=$2
  local cmd=$3
  
  if [ "$skip" = true ]; then
    echo -e "${YELLOW}[$name] Skipped${NC}"
    return 0
  fi
  
  echo -e "${BLUE}[$name] Running...${NC}"
  
  if eval "$cmd"; then
    echo -e "${GREEN}[$name] Passed${NC}"
    return 0
  else
    echo -e "${RED}[$name] Failed${NC}"
    return 1
  fi
}

# Track overall status
OVERALL_STATUS=0

# 1. ESLint
echo ""
echo -e "${BLUE}----------------------------------------${NC}"
if [ -z "$LINT_FILES" ]; then
  echo -e "${YELLOW}[ESLint] No lintable files changed${NC}"
  LINT_RESULT="skipped"
elif [ "$SKIP_LINT" = true ]; then
  echo -e "${YELLOW}[ESLint] Skipped${NC}"
  LINT_RESULT="skipped"
else
  echo -e "${BLUE}[ESLint] Running on changed files...${NC}"
  # Convert newlines to spaces for eslint
  LINT_FILES_SPACE=$(echo "$LINT_FILES" | tr '\n' ' ')
  if npx eslint $LINT_FILES_SPACE; then
    echo -e "${GREEN}[ESLint] Passed${NC}"
    LINT_RESULT="passed"
  else
    echo -e "${RED}[ESLint] Failed${NC}"
    LINT_RESULT="failed"
    OVERALL_STATUS=1
    if [ "$FAIL_FAST" = true ]; then
      echo -e "${RED}Stopping due to --fail-fast${NC}"
      exit 1
    fi
  fi
fi

# 2. Prettier
echo ""
echo -e "${BLUE}----------------------------------------${NC}"
if [ -z "$PRETTIER_FILES" ]; then
  echo -e "${YELLOW}[Prettier] No files to check${NC}"
  PRETTIER_RESULT="skipped"
elif [ "$SKIP_PRETTIER" = true ]; then
  echo -e "${YELLOW}[Prettier] Skipped${NC}"
  PRETTIER_RESULT="skipped"
else
  echo -e "${BLUE}[Prettier] Running on changed files...${NC}"
  PRETTIER_FILES_SPACE=$(echo "$PRETTIER_FILES" | tr '\n' ' ')
  if npx prettier --check $PRETTIER_FILES_SPACE; then
    echo -e "${GREEN}[Prettier] Passed${NC}"
    PRETTIER_RESULT="passed"
  else
    echo -e "${RED}[Prettier] Failed${NC}"
    PRETTIER_RESULT="failed"
    OVERALL_STATUS=1
    if [ "$FAIL_FAST" = true ]; then
      echo -e "${RED}Stopping due to --fail-fast${NC}"
      exit 1
    fi
  fi
fi

# 3. TypeScript
echo ""
echo -e "${BLUE}----------------------------------------${NC}"
if [ "$SKIP_TSC" = true ]; then
  echo -e "${YELLOW}[TypeScript] Skipped${NC}"
  TSC_RESULT="skipped"
else
  echo -e "${BLUE}[TypeScript] Running full type check...${NC}"
  if yarn tsc:check 2>&1; then
    echo -e "${GREEN}[TypeScript] Passed${NC}"
    TSC_RESULT="passed"
  else
    echo -e "${RED}[TypeScript] Failed${NC}"
    TSC_RESULT="failed"
    OVERALL_STATUS=1
    if [ "$FAIL_FAST" = true ]; then
      echo -e "${RED}Stopping due to --fail-fast${NC}"
      exit 1
    fi
  fi
fi

# 4. Jest Tests
echo ""
echo -e "${BLUE}----------------------------------------${NC}"
if [ "$SKIP_TESTS" = true ]; then
  echo -e "${YELLOW}[Jest] Skipped${NC}"
  TESTS_RESULT="skipped"
else
  # Get changed test files
  TEST_FILES=$(echo "$EXISTING_FILES" | grep -E '\.(test|itest)\.(ts|tsx)$' || echo "")
  # Get changed source files (non-test)
  SOURCE_FILES=$(echo "$EXISTING_FILES" | grep -E '\.(ts|tsx)$' | grep -vE '\.(test|itest)\.(ts|tsx)$' || echo "")
  
  TEST_COUNT=$(echo "$TEST_FILES" | grep -c . || echo 0)
  SOURCE_COUNT=$(echo "$SOURCE_FILES" | grep -c . || echo 0)
  
  echo -e "${BLUE}[Jest] Found $TEST_COUNT changed test files, $SOURCE_COUNT changed source files${NC}"
  
  if [ "$TEST_COUNT" -eq 0 ] && [ "$SOURCE_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}[Jest] No test or source files changed${NC}"
    TESTS_RESULT="skipped"
  else
    JEST_ARGS=""
    
    # Add test files directly
    if [ -n "$TEST_FILES" ] && [ "$TEST_COUNT" -gt 0 ]; then
      JEST_ARGS="$JEST_ARGS $(echo "$TEST_FILES" | tr '\n' ' ')"
    fi
    
    # Add --findRelatedTests for source files
    if [ -n "$SOURCE_FILES" ] && [ "$SOURCE_COUNT" -gt 0 ]; then
      JEST_ARGS="$JEST_ARGS --findRelatedTests $(echo "$SOURCE_FILES" | tr '\n' ' ')"
    fi
    
    echo -e "${BLUE}[Jest] Running tests...${NC}"
    if yarn test $JEST_ARGS --passWithNoTests; then
      echo -e "${GREEN}[Jest] Passed${NC}"
      TESTS_RESULT="passed"
    else
      echo -e "${RED}[Jest] Failed${NC}"
      TESTS_RESULT="failed"
      OVERALL_STATUS=1
    fi
  fi
fi

# Summary
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

print_result() {
  local name=$1
  local result=$2
  case $result in
    passed)
      echo -e "  $name: ${GREEN}Passed${NC}"
      ;;
    failed)
      echo -e "  $name: ${RED}Failed${NC}"
      ;;
    skipped)
      echo -e "  $name: ${YELLOW}Skipped${NC}"
      ;;
  esac
}

print_result "ESLint" "$LINT_RESULT"
print_result "Prettier" "$PRETTIER_RESULT"
print_result "TypeScript" "$TSC_RESULT"
print_result "Jest" "$TESTS_RESULT"

echo ""
if [ $OVERALL_STATUS -eq 0 ]; then
  echo -e "${GREEN}All checks passed!${NC}"
else
  echo -e "${RED}Some checks failed.${NC}"
fi

exit $OVERALL_STATUS
