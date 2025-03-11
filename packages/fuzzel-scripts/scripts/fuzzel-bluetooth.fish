#!/usr/bin/env bash

toggle() {
	notify-send "$device" "Attempting to $1"
	(bluetoothctl "$1" "$mac" &&
		notify-send "$device" "Successfully ${1}ed") ||
		notify-send -u critical "$device" "Failed to $1" >/dev/null 2>&1
}

bluetoothctl show | rg -q "Powered: no" && {
	notify-send -u critical "Bluetooth" "Disabled"
	exit 1
}

saved=$(bluetoothctl devices)
connected=$(bluetoothctl devices Connected)

devices=$(
	echo "$saved" | while read -r device; do
		echo "$connected" | rg -q "$device" && echo "$device *" || echo "$device"
	done
)

count=$(echo "$devices" | wc -l)

if [ "$count" -eq 1 ]; then
	device=$(echo "$saved" | cut -d' ' -f3)
	mac=$(echo "$saved" | cut -d' ' -f2)
elif [ "$count" -gt 1 ]; then
	choice=$(
		echo "$devices" | cut -d' ' -f3- | sort | fuzzel -l "$count" -w 20 -di
	) || exit 0

	echo "$choice" | rg -q "*" && choice=$(echo "$choice" | cut -d' ' -f1)
	device=$(echo "$saved" | rg "$choice" | cut -d' ' -f3)
	mac=$(echo "$saved" | rg "$choice" | cut -d' ' -f2)

	(echo "$connected" | rg -q "$mac" && toggle disconnect) || toggle connect
else
	notify-send "Bluetooth" "No saved devices"
fi
