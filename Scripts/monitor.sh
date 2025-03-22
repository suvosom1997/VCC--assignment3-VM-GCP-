#!/bin/bash

# Get CPU and memory usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
MEM_USAGE=$(free | grep Mem | awk '{print ($3/$2) * 100.0}')

# Define threshold
THRESHOLD=75.0

# Log file
LOG_FILE="$HOME/monitoring.log"

# Check if usage exceeds threshold
if (( $(echo "$CPU_USAGE > $THRESHOLD" | bc -l) )) || (( $(echo "$MEM_USAGE > $THRESHOLD" | bc -l) )); then
   echo "[WARNING] $(date): High usage detected: CPU=$CPU_USAGE%, RAM=$MEM_USAGE%" | tee -a $LOG_FILE
   ./scale_to_gcp.sh
else
   echo "[OK] $(date): CPU=$CPU_USAGE%, RAM=$MEM_USAGE%" | tee -a $LOG_FILE
fi