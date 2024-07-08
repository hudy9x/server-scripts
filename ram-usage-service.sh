#!/bin/bash

# Service name
service_name="dainh-resource-collection"

# Create systemd service file
service_file="/etc/systemd/system/$service_name.service"
# service_file="./$service_name.service"

# Download directory (current directory by default)
download_dir="${PWD}"  # PWD is a variable holding the current working directory

# Function to print error message and exit
function error_exit() {
  echo "ERR: $1"
  exit 1
}

cat << EOF > "$service_file"
[Unit]
Description=Dainh Resource Collection Service

[Service]
Type=simple
User=root  # Adjust if needed for a different user
ExecStart=/bin/bash -c "$download_dir/ram-usage.sh"
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Check if service file creation was successful
if [[ $? -ne 0 ]]; then
  error_exit "Failed to create systemd service file: $service_file"
fi

# Reload systemd and enable the service
systemctl daemon-reload
systemctl enable "$service_name.service"

echo "Service $service_name created and enabled successfully."


