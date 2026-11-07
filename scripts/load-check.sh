#!/usr/bin/env bash
# Sends a request every 0.2s and counts failed responses. Stop with Ctrl+C.

URL="${1:-http://localhost}"
total=0
failed=0

# Print the summary on Ctrl+C
trap 'echo; echo "Total: $total  Failed: $failed"; exit' INT

while true; do
  total=$((total + 1))
  response=$(curl -s -m 2 -w '\n%{http_code}' "$URL")
  code=$(echo "$response" | tail -n1)

  if [ "$code" != "200" ]; then
    failed=$((failed + 1))
    echo "$(date +%T) FAIL ($code)"
  else
    version=$(echo "$response" | grep -o 'Version: [^<]*')
    pod=$(echo "$response" | grep -o 'Pod: [^<]*')
    echo "$(date +%T) 200  $version  $pod"
  fi

  sleep 0.2
done