#!/bin/bash
# scripts/start-nats.sh
# Start NATS Server with JetStream enabled

echo "Starting NATS Server with JetStream..."

if ! which nats-server > /dev/null 2>&1; then
    echo "NATS Server not installed. Install with: brew install nats-server"
    exit 1
fi

# Kill any existing process on port 4222
EXISTING_PID=$(lsof -ti:4222 2>/dev/null)
if [ -n "$EXISTING_PID" ]; then
    echo "Killing existing process on port 4222 (PID: $EXISTING_PID)..."
    kill -9 $EXISTING_PID 2>/dev/null
    sleep 1
fi

# Start NATS with JetStream enabled
nats-server -js -p 4222 &
NATS_PID=$!

sleep 1

if ps -p $NATS_PID > /dev/null 2>&1; then
    echo "NATS Server started with PID: $NATS_PID"
    echo "JetStream enabled on port 4222"
    echo ""
    echo "To stop: kill $NATS_PID"
    echo "To verify: nats server info"
else
    echo "Error: NATS Server failed to start"
    exit 1
fi
