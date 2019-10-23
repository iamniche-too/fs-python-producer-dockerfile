#!/bin/bash

sleep 30s

echo "Running Producer..."
source /usr/local/fs-python/env/bin/activate && cd /usr/local/fs-python && python3 producer.py
