#!/bin/bash

# Define the log file path
log_file="access.log"

# Ensure the log file exists
if [[ ! -f "$log_file" ]]; then
    echo "Log file not found!"
    exit 1
fi

# 1. Request Counts
total_requests=$(wc -l < "$log_file")
get_requests=$(grep -c 'GET' "$log_file")
post_requests=$(grep -c 'POST' "$log_file")

# 2. Unique IP Addresses
unique_ips=$(awk '{print $1}' "$log_file" | sort -u)
total_unique_ips=$(echo "$unique_ips" | wc -l)

# GET and POST requests per IP
declare -A get_requests_per_ip
declare -A post_requests_per_ip

while read -r ip; do
    get_count=$(grep -cE "^$ip .*GET" "$log_file")
    post_count=$(grep -cE "^$ip .*POST" "$log_file")
    get_requests_per_ip["$ip"]=$get_count
    post_requests_per_ip["$ip"]=$post_count
done <<< "$unique_ips"

# 3. Failure Requests
failed_requests=$(awk '$9 ~ /^[45]/' "$log_file" | wc -l)
failed_percentage=$(awk -v total="$total_requests" -v failed="$failed_requests" 'BEGIN {printf "%.2f", (failed/total)*100}')

# 4. Top User
top_user=$(awk '{print $1}' "$log_file" | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')

# 5. Daily Request Averages
total_days=$(awk '{print $4}' "$log_file" | cut -d: -f1 | sort -u | wc -l)
average_requests_per_day=$(awk -v total="$total_requests" -v days="$total_days" 'BEGIN {printf "%.2f", total/days}')

# 6. Failure Analysis by Day
failures_by_day=$(awk '$9 ~ /^[45]/ {print $4}' "$log_file" | cut -d: -f1 | sort | uniq -c | sort -nr)

# Additional Analyses

# Requests per Hour
requests_per_hour=$(awk '{print $4}' "$log_file" | cut -d: -f2 | sort | uniq -c)

# Status Code Breakdown
status_code_breakdown=$(awk '{print $9}' "$log_file" | sort | uniq -c | sort -nr)

# Most Active User by Method
most_active_get_user=$(grep 'GET' "$log_file" | awk '{print $1}' | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')
most_active_post_user=$(grep 'POST' "$log_file" | awk '{print $1}' | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')

# Patterns in Failure Requests by Hour
failure_patterns_by_hour=$(awk '$9 ~ /^[45]/ {print $4}' "$log_file" | cut -d: -f2 | sort | uniq -c | sort -nr)

# Output Results

echo "1. Request Counts:"
echo "   - Total requests: $total_requests"
echo "   - GET requests: $get_requests"
echo "   - POST requests: $post_requests"
echo ""

echo "2. Unique IP Addresses:"
echo "   - Total unique IPs: $total_unique_ips"
echo "   - GET and POST requests per IP:"
for ip in "${!get_requests_per_ip[@]}"; do
    echo "     - $ip: GET=${get_requests_per_ip[$ip]}, POST=${post_requests_per_ip[$ip]}"
done
echo ""

echo "3. Failure Requests:"
echo "   - Total failed requests: $failed_requests"
echo "   - Percentage of failed requests: $failed_percentage%"
echo ""

echo "4. Top User:"
echo "   - Most active IP: $top_user"
echo ""

echo "5. Daily Request Averages:"
echo "   - Average requests per day: $average_requests_per_day"
echo ""

echo "6. Failure Analysis by Day:"
echo "$failures_by_day"
echo ""

echo "Additional Analyses:"
echo "   - Requests per Hour:"
echo "$requests_per_hour"
echo ""

echo "   - Status Code Breakdown:"
echo "$status_code_breakdown"
echo ""

echo "   - Most Active User by Method:"
echo "     - GET: $most_active_get_user"
echo "     - POST: $most_active_post_user"
echo ""

echo "   - Patterns in Failure Requests by Hour:"
echo "$failure_patterns_by_hour"
echo ""
