#!/bin/bash
# scripts/create-nats-streams.sh
# Create NATS JetStream streams for Agentic SDLC

echo "=== Creating NATS JetStream Streams ==="

# Check if NATS is running
if ! nats server ping > /dev/null 2>&1; then
    echo "Error: NATS server not running. Start with: ./scripts/start-nats.sh"
    exit 1
fi

echo ""
echo "Creating REQUIREMENTS stream..."
nats stream add REQUIREMENTS \
    --subjects "work.requirements.*" \
    --storage file \
    --replicas 1 \
    --retention limits \
    --max-msgs 10000 \
    --max-age 30d \
    --discard old \
    --max-msg-size 1MB \
    --dupe-window 2m \
    --defaults 2>/dev/null || echo "  REQUIREMENTS stream already exists"

echo ""
echo "Creating WORK stream..."
nats stream add WORK \
    --subjects "work.assigned.*,work.progress.*,work.complete.*" \
    --storage file \
    --replicas 1 \
    --retention limits \
    --max-msgs 50000 \
    --max-age 7d \
    --discard old \
    --max-msg-size 1MB \
    --dupe-window 2m \
    --defaults 2>/dev/null || echo "  WORK stream already exists"

echo ""
echo "Creating INTEGRATION stream..."
nats stream add INTEGRATION \
    --subjects "work.integration.*" \
    --storage file \
    --replicas 1 \
    --retention limits \
    --max-msgs 10000 \
    --max-age 7d \
    --discard old \
    --max-msg-size 1MB \
    --dupe-window 2m \
    --defaults 2>/dev/null || echo "  INTEGRATION stream already exists"

echo ""
echo "Creating RELEASES stream..."
nats stream add RELEASES \
    --subjects "work.releases.*" \
    --storage file \
    --replicas 1 \
    --retention limits \
    --max-msgs 5000 \
    --max-age 30d \
    --discard old \
    --max-msg-size 1MB \
    --dupe-window 2m \
    --defaults 2>/dev/null || echo "  RELEASES stream already exists"

echo ""
echo "=== Verifying streams ==="
nats stream ls

echo ""
echo "=== NATS streams created! ==="
