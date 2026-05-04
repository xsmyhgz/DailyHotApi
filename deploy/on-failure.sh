#!/bin/bash
ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "$ts dailyhot-api FAILED (state=$(systemctl show -p ActiveState --value dailyhot-api))" >> /var/log/dailyhot-failures.log
