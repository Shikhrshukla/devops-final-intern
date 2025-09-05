!/bin/bash

echo "------START------"
echo "User: $(whoami)"
echo "Date: $(date)"
echo "Disk usage (in human readable format):"
df -h
echo "------END------"
