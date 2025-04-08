#!/bin/bash

echo "Tailing sys logs at: /var/log*"
tail -f /var/log/*.log
