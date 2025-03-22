#!/bin/bash

# Function to generate CPU load
generate_cpu_load() {
  duration=$1
  echo "Generating CPU load for $duration seconds"
  
  # Create multiple processes that perform heavy calculations
  for i in $(seq 1 $(nproc)); do
    dd if=/dev/zero bs=1M count=1024 | md5sum &
  done
  
  # Wait for specified duration
  sleep $duration
  
  # Kill background processes
  pkill -f "dd if=/dev/zero"
  echo "Load generation completed"
}

# Generate load for the specified duration (default: 60 seconds)
generate_cpu_load ${1:-60}