#!/bin/bash

# Record the start time
START_TIME=$(date +%s)

# Simulate delay
sleep 10  # Adding a 5-second delay to simulate a longer execution time

# Collect CPU and memory usage in percentage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
MEMORY_USAGE=$(free -m | awk '/Mem:/ { printf "%.2f", $3/$2 * 100.0 }')

# Check if data collection was successful
if [ $? -ne 0 ]; then
    echo "Error collecting CPU and memory usage."
    exit 1  # Exit the script with error
fi

# Calculate percentage values (as decimals)
CPU_USAGE_DECIMAL=$(echo "scale=4; $CPU_USAGE / 100" | bc)
MEMORY_USAGE_DECIMAL=$(echo "scale=4; $MEMORY_USAGE / 100" | bc)

# Check if calculations were successful
if [ $? -ne 0 ]; then
    echo "Error calculating CPU and memory usage."
    exit 1  # Exit the script with error
fi

# Record the end time
END_TIME=$(date +%s)

# Calculate the duration of execution
DURATION=$((END_TIME - START_TIME))

# Send metrics to Pushgateway
echo "custom_script_cpu_usage $CPU_USAGE_DECIMAL" | curl --data-binary @- http://localhost:9092/metrics/job/custom_script
if [ $? -ne 0 ]; then
    echo "Error sending CPU usage to Pushgateway."
    exit 1  # Exit the script with error
fi

echo "custom_script_memory_usage $MEMORY_USAGE_DECIMAL" | curl --data-binary @- http://localhost:9092/metrics/job/custom_script
if [ $? -ne 0 ]; then
    echo "Error sending memory usage to Pushgateway."
    exit 1  # Exit the script with error
fi

echo "custom_script_duration_seconds $DURATION" | curl --data-binary @- http://localhost:9092/metrics/job/custom_script
if [ $? -ne 0 ]; then
    echo "Error sending duration to Pushgateway."
    exit 1  # Exit the script with error
fi

echo "custom_script_success 1" | curl --data-binary @- http://localhost:9092/metrics/job/custom_script
if [ $? -ne 0 ]; then
    echo "Error sending success status to Pushgateway."
    exit 1  # Exit the script with error
fi

# If all commands executed successfully
echo "All commands executed successfully."

