#!/bin/bash

DEVICE_NAME="Bonnie's Buds FE"

# Get the MAC address
MAC=$(bluetoothctl devices | grep "$DEVICE_NAME" | awk '{print $2}')

if [ -z "$MAC" ]; then
    echo "❌ Bluetooth device '$DEVICE_NAME' not found."
    exit 1
fi

echo "✅ Found $DEVICE_NAME at $MAC"

# Disconnect
bluetoothctl <<EOF
disconnect $MAC
quit
EOF

sleep 5

# Reconnect
bluetoothctl <<EOF
connect $MAC
quit
EOF


echo "✅ Reconnected $DEVICE_NAME"
