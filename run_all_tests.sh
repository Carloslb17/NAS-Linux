#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$0")"
LOG_FILE="logs/all_tests.log"

mkdir -p logs

# Counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

run_test() {
    local test_name=$1
    local test_file=$2
    
    log ""
    log "════════════════════════════════════════"
    log "🧪 Running: $test_name"
    log "════════════════════════════════════════"
    
    ((TOTAL_TESTS++))
    
    if bash "$test_file" >> "$LOG_FILE" 2>&1; then
        log "✅ $test_name PASSED"
        ((PASSED_TESTS++))
    else
        log "❌ $test_name FAILED"
        ((FAILED_TESTS++))
    fi
}

log "🧪 HomeLab NAS Pro - Complete Test Suite"
log "Started: $(date)"
log ""

# Run comprehensive tests
run_test "System & Infrastructure Tests" "$SCRIPT_DIR/tests/full_test_suite.sh"
run_test "Immich Service Tests" "$SCRIPT_DIR/tests/immich_specific_tests.sh"

# Additional quick checks
log ""
log "════════════════════════════════════════"
log "Additional Diagnostics"
log "════════════════════════════════════════"

log ""
log "Docker Container Status:"
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | tee -a "$LOG_FILE"

log ""
log "════════════════════════════════════════"
log "📊 TEST SUMMARY"
log "════════════════════════════════════════"
log "Total Test Suites: $TOTAL_TESTS"
log "✅ Passed: $PASSED_TESTS"
log "❌ Failed: $FAILED_TESTS"
log "Completion Time: $(date)"
log "Log File: $LOG_FILE"
log ""

if [ $FAILED_TESTS -eq 0 ]; then
    log "🎉 ALL TESTS PASSED - SYSTEM IS READY"
    exit 0
else
    log "⚠️  Some tests failed. Review $LOG_FILE for details."
    exit 1
fi
    fi
done

echo ""
if [ $errors -eq 0 ]; then
    exit 0
else
    exit 1
fi
