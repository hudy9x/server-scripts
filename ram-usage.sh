#!/bin/bash

# Axiom API details (replace with your actual values)
API_TOKEN="1"
DATASET_NAME="1"
 
# Sleep time variable (modify as needed)
SLEEP_TIME=1

# Note: To visualize Ram field on Axiom, run the following command 
#
# test
# | where ['type'] == "RAM"
# | summarize avg(toint(ram)) by bin(_time, 1m)

if [[ -z "$API_TOKEN" || -z "$DATASET_NAME" ]]; then
  echo "Error: Both API_TOKEN and DATASET_NAME must be set. Please provide values for these variables."
  exit 1  # Use a specific exit code to indicate an error
fi

# Function to check RAM usage
function get_ram_usage() {
  # Use free command with -m flag for megabytes
  # ram_usage=$(free -m | awk '/Mem:/ {printf("%d", $3)}')  # Extract only used memory value
  ram_usage=$(free -m | awk '/Mem:/ {printf("%.0f", $3/$2 * 100)}')

  echo $ram_usage

  # if [[ $ram_usage -le 20 ]]; then
  #   ram_usage=20
  #   # ram_usage="L20"
  # elif [[ $ram_usage -le 30 ]]; then
  #   ram_usage=30
  # elif [[ $ram_usage -le 35 ]]; then
  #   ram_usage=35
  #   # ram_usage="L35"
  # elif [[ $ram_usage -le 40 ]]; then
  #   ram_usage=40
  # elif [[ $ram_usage -le 45 ]]; then
  #   ram_usage=45
  #   # ram_usage="L45"
  # elif [[ $ram_usage -le 50 ]]; then
  #   ram_usage=50
  # elif [[ $ram_usage -le 60 ]]; then
  #   ram_usage=60
  #   # ram_usage="L50"
  # elif [[ $ram_usage -le 70 ]]; then
  #   ram_usage=70
  #   # ram_usage="L70"
  # elif [[ $ram_usage -le 80 ]]; then
  #   ram_usage=80
  #   # ram_usage="L80"
  # elif [[ $ram_usage -le 90 ]]; then
  #   ram_usage=90
  #   # ram_usage="L90"
  # else
  #   ram_usage=99
  #   # ram_usage="L99"
  # fi


  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to get RAM usage using 'free' command." >&2
    exit 1
  fi
}

# Function to send data to Axiom
function send_ram_data() {
  # Construct final JSON array string
  final_data_array=""
  # Loop through each object in ram_data_array and add comma
  for item in "${ram_data_array[@]}"; do
    final_data_array+="$item,"
  done
  # Remove the trailing comma from the final string
  final_data_array="[${final_data_array::-1}]"  # Remove last character

  # Echo final_data_array for debugging (optional)
  echo "Final RAM Data Array:"
  echo "$final_data_array"


  # Send data to Axiom using curl
  curl -X 'POST' \
    "https://api.axiom.co/v1/datasets/$DATASET_NAME/ingest" \
    -H "Authorization: Bearer $API_TOKEN" \
    -H 'Content-Type: application/json' \
    -d "$final_data_array" &> /tmp/curl_output.log

  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to send data to Axiom. Check /tmp/curl_output.log for details." >&2
  fi
}

function start_scanning(){
  echo "Start scanning round"
  # Initialize empty array for RAM data
  ram_data_array=()



  # Loop to check RAM usage and store data
  for i in {1..12}; do
    echo "Iteration: $i"
    # Get RAM usage with error handling
    get_ram_usage || echo "Error occurred during RAM usage check. Continuing..." >&2

    # Get current date and time components
    current_time=$(date +%S)
    current_minute=$(date +%M)
    current_hour=$(date +%H)
    current_date=$(date +%d)
    current_month=$(date +%m)
    current_year=$(date +%Y)

    # Create JSON object for RAM data
    ram_data_object='{"type": "RAM", "ram": "'$ram_usage'", "minute": "'$current_minute'", "second": "'$current_time'", "hour": "'$current_hour'", "date": "'$current_date'", "month": "'$current_month'", "year": "'$current_year'"}'

    # Add RAM data object to the array
    # echo $ram_data_object
    ram_data_array+=("$ram_data_object")

    sleep $SLEEP_TIME
  done

  # Send data to Axiom with error handling
  send_ram_data || echo "Error occurred while sending data to Axiom." >&2

  echo "RAM data sent to Axiom successfully!"
}

while true; do
  start_scanning
done
