#!/bin/bash
#
# NovaCommerce – Lab 09
# Controlled CPU Stress Test
#
# Purpose:
# Generate sustained CPU utilization to validate the EC2 Auto Scaling
# Target Tracking policy.
#
# Expected laboratory behavior:
#
#   Baseline: 2 EC2 instances
#          ↓
#   CPU utilization increases
#          ↓
#   Target Tracking reacts
#          ↓
#   Scale-out to 4 EC2 instances
#
# After the workload stops, the environment should be left untouched
# so Target Tracking can perform scale-in automatically.
#
# IMPORTANT:
# Use only in a controlled laboratory environment.

set -e

DURATION="${1:-600}"
CPU_WORKERS="${2:-2}"

echo "NovaCommerce Lab 09 – CPU Stress Test"
echo "Duration: ${DURATION} seconds"
echo "CPU workers: ${CPU_WORKERS}"
echo

# Install stress-ng if it is not already available.
if ! command -v stress-ng >/dev/null 2>&1; then
    echo "stress-ng is not installed. Installing..."
    sudo dnf install -y stress-ng
fi

echo "Current load:"
uptime
echo

echo "Starting controlled CPU workload..."
stress-ng --cpu "${CPU_WORKERS}" --timeout "${DURATION}s"

echo
echo "CPU stress test completed."
echo "Do NOT manually reduce Auto Scaling desired capacity."
echo "Monitor CloudWatch and Auto Scaling Activity History and allow"
echo "the Target Tracking policy to perform scale-in automatically."
