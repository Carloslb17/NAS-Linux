#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

mkdir -p logs
LOG_FILE="logs/tests.log"
> "$LOG_FILE"

declare -A results
keys=("Services" "Containers" "Network" "Disk" "APIs" "Backups" "Snapshots" "Install" "Immich")

run_test() {
    local script=$1
    local name=$2
    
    start_time=$(date +%s)
    if bash "$script" >> "$LOG_FILE" 2>&1; then
        end_time=$(date +%s)
        results["$name"]="OK"
    else
        end_time=$(date +%s)
        results["$name"]="FAILED"
    fi
}

echo "Running tests..."
run_test "tests/system_tests.sh" "Services"
run_test "tests/container_tests.sh" "Containers"
run_test "tests/network_tests.sh" "Network"
run_test "tests/disk_tests.sh" "Disk"
run_test "tests/api_tests.sh" "APIs"
run_test "tests/backup_tests.sh" "Backups"
run_test "tests/snapshot_tests.sh" "Snapshots"
run_test "tests/install_tests.sh" "Install"
run_test "tests/immich_tests.sh" "Immich"

echo ""
echo "SYSTEM TEST SUMMARY"
echo ""

errors=0
for name in "${keys[@]}"; do
    res=${results[$name]}
    if [ "$res" == "OK" ]; then
        echo -e "${name}: ${GREEN}${res}${NC}"
    else
        echo -e "${name}: ${RED}${res}${NC}"
        errors=$((errors+1))
    fi
done

echo ""
if [ $errors -eq 0 ]; then
    exit 0
else
    exit 1
fi
