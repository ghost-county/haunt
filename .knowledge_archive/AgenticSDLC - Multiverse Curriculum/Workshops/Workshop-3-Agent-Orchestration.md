# Workshop 3: Agent Orchestration

> *From one worker to a coordinated team.*

---

## Overview

| | |
|---|---|
| **Duration** | 60 minutes |
| **Format** | Architecture design + hands-on setup |
| **Output** | Multi-agent system with NATS JetStream + Matrix |
| **Prerequisites** | Working autonomous worker from Workshop 2 |

---

## Learning Objectives

By the end of this workshop, you will:

- Design LLM-friendly codebases (small files, small commits)
- Create specialized sub-agents for different code areas
- Set up queue-based task distribution
- Configure agent-to-agent communication via NATS JetStream + Matrix

---

## Why Multiple Agents?

A single autonomous worker hits limits:

- **Context overflow** - Large codebases exceed context windows
- **Specialization** - Different areas need different expertise
- **Parallelization** - Some work can happen simultaneously
- **Reliability** - Specialists make fewer mistakes in their domain

**The solution:** A team of specialist agents, each with a focused scope.

---

## LLM-Friendly Codebase Design

Before adding agents, make your codebase agent-friendly.

### Small Files

```
# Bad: One huge file
src/
└── app.py (3000 lines)

# Good: Many small files
src/
├── auth/
│   ├── login.py (100 lines)
│   ├── logout.py (50 lines)
│   └── session.py (150 lines)
├── api/
│   ├── users.py (200 lines)
│   └── products.py (180 lines)
└── utils/
    ├── validation.py (80 lines)
    └── formatting.py (60 lines)
```

**Why:** Agents can hold an entire small file in context. They hallucinate less when they can see everything they're modifying.

### Small Commits

```bash
# Bad
git commit -m "Added user authentication, product catalog, and checkout flow"

# Good
git commit -m "REQ-001: Add password hashing utility"
git commit -m "REQ-001: Add login endpoint"
git commit -m "REQ-001: Add session management"
```

**Why:** Small commits are easier to review, easier to revert, and easier for other agents to understand.

### Clear Interfaces

```python
# Good: Clear interface documented
class UserService:
    """
    Handles all user-related operations.

    Dependencies:
    - DatabaseConnection (injected)
    - EmailService (injected)

    Used by:
    - AuthController
    - AdminController

    Methods:
    - create_user(email, password) -> User
    - get_user(id) -> User | None
    - update_user(id, data) -> User
    - delete_user(id) -> bool
    """
```

**Why:** Other agents working on dependent systems can read the interface without reading the implementation.

### The Hallucination Threshold

When files get too big, agents hallucinate:

- They invent methods that don't exist
- They misremember function signatures
- They lose track of state

**Rule of thumb:** If a file is over 300 lines, consider splitting it. If an agent needs to modify more than 500 lines of context, create a specialist.

---

## Creating Specialist Agents

### Agent Anatomy

Every specialist agent needs:

| Component | Purpose |
|-----------|---------|
| **Name** | A memorable identity |
| **Personality** | Optional but helps with consistency |
| **Scope** | What files/systems they own |
| **Tools** | What they can do |
| **Interfaces** | How they communicate with others |
| **System Prompt** | Everything above in one document |

### Example: Roy the Backend Developer

```markdown
# Agent: Roy

## Character
You are Roy, a backend developer. You're methodical, thorough, and slightly
grumpy about poorly documented APIs. You take pride in clean code and
comprehensive error handling.

## Scope
You own all code in:
- /src/api/
- /src/services/
- /src/models/
- /tests/api/
- /tests/services/

You do NOT modify:
- /src/frontend/ (that's Jen's domain)
- /src/infrastructure/ (that's Moss's domain)

## Tools Available
- Read/write files in your scope
- Run: pytest, mypy, ruff
- Database: Read schema, run migrations
- Git: commit to feature branches only

## Interfaces
### Input
- Receive requirements from #requirements channel
- Receive API specs from #architecture channel
- Receive bug reports from #issues channel

### Output
- Post completed endpoints to #integration channel
- Post questions to #architecture channel
- Post blockers to #help channel

## Working Style
1. Read the requirement completely before starting
2. Check existing code for similar patterns
3. Write tests FIRST
4. Implement to pass tests
5. Run full test suite before committing
6. Document any API changes in /docs/api/

## What I Refuse To Do
- Commit without tests
- Modify files outside my scope
- Make breaking API changes without posting to #architecture first
- Use mutable global state
```

### Example: Jen the Frontend Developer

```markdown
# Agent: Jen

## Character
You are Jen, a frontend developer. You care deeply about user experience
and accessibility. You're frustrated by APIs that return inconsistent data.

## Scope
You own all code in:
- /src/frontend/
- /src/components/
- /tests/e2e/

## Tools Available
- Read/write files in your scope
- Run: npm test, npm run build, playwright
- Read-only access to API documentation

## Interfaces
### Input
- Receive designs from #design channel
- Receive API specs from #integration channel (posted by Roy)
- Receive bug reports from #issues channel

### Output
- Post questions about APIs to #integration channel
- Post accessibility concerns to #design channel
- Post completed features to #demo channel

## What I Refuse To Do
- Modify backend code
- Ship without E2E tests
- Ignore accessibility requirements
- Use any color without checking contrast ratio
```

---

## Queue-Based Task Distribution

### The Queue Drainer Pattern

```
┌─────────────────┐
│  Requirement    │
│     Queue       │
│  [REQ-007]      │
│  [REQ-008]      │
│  [REQ-009]      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Queue Drainer  │
│                 │
│  Routes tasks   │
│  to agents      │
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌───────┐ ┌───────┐
│  Roy  │ │  Jen  │
│Backend│ │Frontend│
└───────┘ └───────┘
```

### Implementation

```python
# queue_drainer.py
import json
from typing import List, Dict

class QueueDrainer:
    def __init__(self):
        self.agents = {
            'backend': RoyAgent(),
            'frontend': JenAgent(),
            'infrastructure': MossAgent(),
        }
        self.queue = self.load_queue()

    def load_queue(self) -> List[Dict]:
        """Load pending requirements from roadmap."""
        # Parse ROADMAP.md, return list of pending requirements
        pass

    def route_requirement(self, req: Dict) -> str:
        """Determine which agent should handle this requirement."""
        # Simple routing based on requirement tags
        if 'api' in req['tags'] or 'backend' in req['tags']:
            return 'backend'
        elif 'ui' in req['tags'] or 'frontend' in req['tags']:
            return 'frontend'
        elif 'infra' in req['tags'] or 'deploy' in req['tags']:
            return 'infrastructure'
        else:
            return 'backend'  # Default

    def drain(self):
        """Process all items in queue."""
        while self.queue:
            req = self.queue.pop(0)
            agent_name = self.route_requirement(req)
            agent = self.agents[agent_name]

            print(f"Assigning {req['id']} to {agent_name}")
            success = agent.process(req)

            if not success:
                # Put back in queue with retry count
                req['retries'] = req.get('retries', 0) + 1
                if req['retries'] < 3:
                    self.queue.append(req)
                else:
                    self.flag_for_human(req)
```

### Routing Strategies

**Tag-based routing:**

```python
ROUTING_RULES = {
    'api': 'backend',
    'database': 'backend',
    'ui': 'frontend',
    'component': 'frontend',
    'deploy': 'infrastructure',
    'ci': 'infrastructure',
}
```

**File-based routing:**

```python
def route_by_files(req):
    files = req.get('likely_files', [])
    for f in files:
        if f.startswith('src/api/'):
            return 'backend'
        elif f.startswith('src/frontend/'):
            return 'frontend'
    return 'backend'  # Default
```

**AI-based routing:**

```python
def route_by_ai(req):
    prompt = f"""
    Given this requirement, which agent should handle it?
    Agents: backend (Roy), frontend (Jen), infrastructure (Moss)

    Requirement: {req['statement']}

    Respond with just the agent name.
    """
    response = client.messages.create(...)
    return response.content[0].text.strip().lower()
```

---

## Agent Communication: NATS + Matrix

We use two systems for different purposes:

| System | Purpose | Who Uses It |
|--------|---------|-------------|
| **NATS JetStream** | Agent-to-agent work coordination | Agents only |
| **Matrix** | Human-agent interaction | Humans + Agents |

### Why This Split?

**NATS JetStream** is perfect for agent coordination:

- Persistent streams - Messages survive restarts
- Consumer groups - Multiple agents can share work
- Acknowledgments - Know when work is actually done
- Replay - Agents can catch up on missed messages

**Matrix** is perfect for human interaction:

- Chat interface - Humans can just type
- Visibility - See what agents are discussing
- Intervention - Jump in when needed
- History - Searchable conversation logs

---

## NATS JetStream Setup

### Installation

```bash
# Install NATS server
curl -L https://github.com/nats-io/nats-server/releases/download/v2.10.0/nats-server-v2.10.0-linux-amd64.zip -o nats-server.zip
unzip nats-server.zip
sudo mv nats-server /usr/local/bin/

# Start with JetStream enabled
nats-server --jetstream --store_dir /var/lib/nats
```

### Create Streams and Consumers

```bash
# Install NATS CLI
curl -L https://github.com/nats-io/natscli/releases/download/v0.1.1/nats-0.1.1-linux-amd64.zip -o nats-cli.zip
unzip nats-cli.zip

# Create streams for each work type
nats stream add REQUIREMENTS --subjects "work.requirements.*" --retention limits --max-msgs 10000
nats stream add INTEGRATION --subjects "work.integration.*" --retention limits --max-msgs 10000
nats stream add ARCHITECTURE --subjects "work.architecture.*" --retention limits --max-msgs 10000

# Create consumers for each agent
nats consumer add REQUIREMENTS roy --pull --ack explicit --max-deliver 3 --filter "work.requirements.backend"
nats consumer add REQUIREMENTS jen --pull --ack explicit --max-deliver 3 --filter "work.requirements.frontend"
```

### Stream Structure

```
Streams:
├── REQUIREMENTS     <- Work items for agents
│   ├── work.requirements.backend
│   ├── work.requirements.frontend
│   └── work.requirements.infra
├── INTEGRATION      <- Completed work announcements
│   └── work.integration.*
├── ARCHITECTURE     <- Design decisions, API specs
│   └── work.architecture.*
└── ISSUES           <- Bug reports, blockers
    └── work.issues.*
```

### Agent Implementation with NATS

```python
# nats_agent.py
import nats
from nats.js.api import ConsumerConfig, AckPolicy
import json
import asyncio

class NATSAgent:
    def __init__(self, name: str, subjects: list[str]):
        self.name = name
        self.subjects = subjects
        self.nc = None
        self.js = None

    async def connect(self):
        """Connect to NATS and set up JetStream."""
        self.nc = await nats.connect("nats://localhost:4222")
        self.js = self.nc.jetstream()

    async def publish(self, subject: str, message: dict):
        """Publish a message to a stream."""
        message['from'] = self.name
        message['timestamp'] = asyncio.get_event_loop().time()
        await self.js.publish(subject, json.dumps(message).encode())

    async def pull_messages(self, stream: str, batch: int = 10) -> list:
        """Pull messages from our consumer."""
        try:
            sub = await self.js.pull_subscribe(
                subject=None,
                durable=self.name,
                stream=stream
            )
            messages = await sub.fetch(batch, timeout=5)
            return messages
        except nats.errors.TimeoutError:
            return []

    async def ack(self, msg):
        """Acknowledge a message as processed."""
        await msg.ack()

    async def nak(self, msg, delay: int = 30):
        """Negative ack - redelivery after delay."""
        await msg.nak(delay=delay)

    async def close(self):
        """Clean up connection."""
        await self.nc.close()
```

---

## The Turn-Based Queue Draining Pattern

This is the core pattern for agent coordination.

### How It Works

```
┌─────────────────────────────────────────────────────────────┐
│                    NATS JetStream                           │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ REQUIREMENTS Stream                                  │   │
│  │  [msg1] [msg2] [msg3] [msg4] [msg5] [msg6]         │   │
│  └──────────────────────┬──────────────────────────────┘   │
│                         │                                   │
│         ┌───────────────┼───────────────┐                  │
│         ▼               ▼               ▼                  │
│    ┌─────────┐    ┌─────────┐    ┌─────────┐              │
│    │  Roy    │    │  Jen    │    │  Moss   │              │
│    │Consumer │    │Consumer │    │Consumer │              │
│    └────┬────┘    └────┬────┘    └────┬────┘              │
└─────────┼──────────────┼──────────────┼────────────────────┘
          │              │              │
          ▼              ▼              ▼
     Turn Start     Turn Start     Turn Start
          │              │              │
     Pull msgs      Pull msgs      Pull msgs
          │              │              │
     Process        Process        Process
          │              │              │
     ACK/NAK        ACK/NAK        ACK/NAK
          │              │              │
     Turn End       Turn End       Turn End
```

### The Turn Cycle

```python
# turn_cycle.py
import asyncio
from datetime import datetime

class TurnBasedAgent(NATSAgent):
    def __init__(self, name: str, turn_duration: int = 1800):  # 30 min default
        super().__init__(name, [])
        self.turn_duration = turn_duration

    async def run_turn(self):
        """Execute one complete turn."""
        print(f"[{self.name}] Turn starting at {datetime.now()}")

        # 1. Pull all pending messages
        messages = await self.pull_messages("REQUIREMENTS", batch=20)
        print(f"[{self.name}] Pulled {len(messages)} messages")

        # 2. Process each message
        for msg in messages:
            try:
                payload = json.loads(msg.data.decode())
                success = await self.process_work(payload)

                if success:
                    # Work done - acknowledge
                    await self.ack(msg)
                    print(f"[{self.name}] Completed and ACKed: {payload.get('id')}")
                else:
                    # Work failed - will be redelivered
                    await self.nak(msg, delay=60)
                    print(f"[{self.name}] NAKed for retry: {payload.get('id')}")

            except Exception as e:
                print(f"[{self.name}] Error processing: {e}")
                await self.nak(msg, delay=300)  # Longer delay on error

        # 3. Check for coordination messages
        arch_messages = await self.pull_messages("ARCHITECTURE", batch=10)
        for msg in arch_messages:
            await self.update_knowledge(json.loads(msg.data.decode()))
            await self.ack(msg)

        # 4. Post any completion notices
        if self.completed_work:
            for work in self.completed_work:
                await self.publish("work.integration.complete", work)

        print(f"[{self.name}] Turn complete")

    async def process_work(self, payload: dict) -> bool:
        """Override in subclass - do the actual work."""
        raise NotImplementedError
```

### Why Explicit Acks Matter

```
Without ACKs:
  Agent pulls message → Agent crashes → Message lost forever

With ACKs:
  Agent pulls message → Agent crashes → Message redelivered to same/other agent
```

JetStream guarantees:
- Unacked messages are redelivered after timeout
- `max-deliver` prevents infinite retry loops
- Dead letter queues catch permanently failed messages

### Coordination Example: API Handoff

```python
# Roy finishes an API endpoint
async def complete_endpoint(self, endpoint_info: dict):
    # 1. Commit the code
    self.git_commit(f"REQ-{endpoint_info['requirement']}: {endpoint_info['name']}")

    # 2. Publish to integration stream
    await self.publish("work.integration.api_ready", {
        'type': 'api_ready',
        'requirement': endpoint_info['requirement'],
        'endpoint': endpoint_info['path'],
        'method': endpoint_info['method'],
        'schema': endpoint_info['response_schema']
    })

# Jen picks up the notification on her next turn
async def process_integration_message(self, payload: dict):
    if payload['type'] == 'api_ready':
        # Now Jen can build the frontend against this API
        self.known_apis[payload['endpoint']] = payload['schema']
        await self.queue_frontend_work(payload['requirement'])
```

---

## Matrix for Human-Agent Interaction

### Why Matrix?

- You can just chat naturally
- Agents read the room every turn
- You see their discussions
- Full history and search

### Setup

```bash
# Run Matrix server (Synapse)
docker run -d --name synapse \
  -v synapse-data:/data \
  -p 8008:8008 \
  matrixdotorg/synapse:latest

# Or use a hosted Matrix server
```

### Room Structure

```
Matrix Rooms:
├── #general          <- Team chat, announcements
├── #backend          <- Roy's domain, humans can participate
├── #frontend         <- Jen's domain
├── #architecture     <- Design discussions
└── #alerts           <- Agents post issues needing human attention
```

### Agent Matrix Integration

```python
# matrix_agent.py
from nio import AsyncClient, MatrixRoom, RoomMessageText

class MatrixEnabledAgent:
    def __init__(self, name: str, homeserver: str, access_token: str):
        self.name = name
        self.client = AsyncClient(homeserver)
        self.client.access_token = access_token
        self.rooms = {}

    async def connect(self):
        """Connect and join rooms."""
        await self.client.sync(timeout=30000)
        # Join relevant rooms
        for room_id in self.room_ids:
            await self.client.join(room_id)

    async def read_room(self, room_id: str, since: str = None) -> list:
        """Read messages from a room since last check."""
        response = await self.client.room_messages(
            room_id,
            start=since,
            limit=50
        )
        return [
            {
                'sender': event.sender,
                'body': event.body,
                'timestamp': event.server_timestamp
            }
            for event in response.chunk
            if isinstance(event, RoomMessageText)
        ]

    async def post(self, room_id: str, message: str):
        """Post a message to a room."""
        await self.client.room_send(
            room_id,
            message_type="m.room.message",
            content={
                "msgtype": "m.text",
                "body": f"[{self.name}] {message}"
            }
        )

    async def check_for_human_input(self) -> list:
        """Check if humans have posted anything relevant."""
        messages = []
        for room_id in self.rooms:
            room_messages = await self.read_room(room_id, self.last_check)
            # Filter for human messages (not from agents)
            human_messages = [
                m for m in room_messages
                if not m['sender'].startswith('@agent')
            ]
            messages.extend(human_messages)
        return messages
```

### Turn Integration with Matrix

```python
async def run_turn_with_matrix(self):
    """Turn that includes Matrix check."""

    # 1. Check Matrix for human input
    human_messages = await self.check_for_human_input()
    for msg in human_messages:
        await self.process_human_input(msg)

    # 2. Do regular NATS work queue processing
    await self.process_work_queue()

    # 3. Post status to Matrix if anything interesting happened
    if self.status_update:
        await self.post(
            self.status_room,
            f"Completed {len(self.completed_work)} items this turn"
        )

    # 4. Post to #alerts if stuck
    if self.blocked:
        await self.post(
            self.alerts_room,
            f"BLOCKED: {self.blocked_reason}\nNeed human help with: {self.blocked_item}"
        )
```

### Example: Roy Checking Messages

```python
class RoyAgent(TurnBasedAgent, MatrixEnabledAgent):
    def __init__(self):
        TurnBasedAgent.__init__(self, "roy")
        MatrixEnabledAgent.__init__(
            self,
            name="roy",
            homeserver="https://matrix.example.com",
            access_token="..."
        )

    async def run_turn(self):
        """Roy's complete turn cycle."""

        # Check Matrix for human messages
        human_input = await self.check_for_human_input()
        for msg in human_input:
            if self.is_addressed_to_me(msg):
                await self.handle_human_request(msg)

        # Pull work from NATS
        work_items = await self.pull_messages("REQUIREMENTS", batch=10)

        for msg in work_items:
            payload = json.loads(msg.data.decode())

            if payload['type'] == 'implement_endpoint':
                success = await self.implement_endpoint(payload)
                if success:
                    await self.ack(msg)
                    # Notify on NATS
                    await self.publish("work.integration.api_ready", {
                        'requirement': payload['requirement'],
                        'endpoint': payload['endpoint']
                    })
                    # Also mention in Matrix
                    await self.post(
                        "#backend",
                        f"Completed {payload['endpoint']} for REQ-{payload['requirement']}"
                    )
                else:
                    await self.nak(msg, delay=300)

        # Check architecture updates
        arch_updates = await self.pull_messages("ARCHITECTURE", batch=5)
        for msg in arch_updates:
            await self.update_api_specs(json.loads(msg.data.decode()))
            await self.ack(msg)
```

---

## The Turn System

Agents don't run continuously. They take turns, draining their queues.

### Why Turns?

- **Cost control** - Agents only run when needed
- **Coordination** - Messages accumulate between turns
- **Human oversight** - Humans can intervene between turns
- **Resource sharing** - Multiple agents share one VM
- **ACK guarantees** - Work is confirmed complete before next turn

### Turn Timing

```
┌─────────────────────────────────────────────────────┐
│ Hour 0:00  │ Hour 0:30  │ Hour 1:00  │ Hour 1:30   │
├─────────────────────────────────────────────────────┤
│ Roy works  │ Jen works  │ Roy works  │ Jen works   │
│ Pulls NATS │ Sees Roy's │ Sees Jen's │ Continues   │
│ ACKs done  │ API (NATS) │ questions  │ integration │
│ Posts API  │ Starts UI  │ Answers    │             │
└─────────────────────────────────────────────────────┘
```

### Implementation with NATS

```python
# turn_scheduler.py
import asyncio
import schedule
import time

async def roy_turn():
    agent = RoyAgent()
    await agent.connect()  # Connect to NATS + Matrix
    await agent.run_turn()  # Pull, process, ACK
    await agent.close()

async def jen_turn():
    agent = JenAgent()
    await agent.connect()
    await agent.run_turn()
    await agent.close()

def run_roy():
    asyncio.run(roy_turn())

def run_jen():
    asyncio.run(jen_turn())

# Schedule turns - staggered to avoid resource contention
schedule.every(30).minutes.at(":00").do(run_roy)
schedule.every(30).minutes.at(":15").do(run_jen)

while True:
    schedule.run_pending()
    time.sleep(60)
```

### Cross-Stream Communication via NATS

The turn system enables information flow between work streams:

```
Backend Stream (NATS)                 Frontend Stream (NATS)
     │                                      │
     │  Roy designs API                     │
     │  Publishes to work.architecture.*    │
     │  ACKs his requirement                │
     ▼                                      │
  ──────────────────────────────────────────┼──────────
     │                                      │
     │                                      │  Jen's turn starts
     │                                      │  Pulls from ARCHITECTURE stream
     │                                      │  Sees Roy's API spec
     │                                      │  ACKs the spec message
     │                                      ▼
  ──────────────────────────────────────────┼──────────
     │                                      │
     │  Roy implements API                  │
     │  Publishes to work.integration.*    │
     │  ACKs his requirement                │
     ▼                                      │
  ──────────────────────────────────────────┼──────────
     │                                      │
     │                                      │  Jen pulls integration stream
     │                                      │  Integrates real API
     │                                      │  Publishes issues to work.issues.*
```

### Agent-to-Agent Direct Communication

Agents can also message each other directly via NATS:

```python
# Direct message pattern
async def ask_agent(self, target_agent: str, question: dict):
    """Send a direct question to another agent."""
    await self.publish(f"work.direct.{target_agent}", {
        'type': 'question',
        'from': self.name,
        'question': question,
        'reply_to': f"work.direct.{self.name}"
    })

async def check_direct_messages(self):
    """Check for messages addressed to me."""
    messages = await self.pull_messages("DIRECT", batch=10)
    for msg in messages:
        payload = json.loads(msg.data.decode())
        if payload['type'] == 'question':
            response = await self.answer_question(payload['question'])
            await self.publish(payload['reply_to'], {
                'type': 'answer',
                'from': self.name,
                'answer': response
            })
        await self.ack(msg)
```

---

## Exercise 3.1: Create Two Specialist Agents

**Time:** 30 minutes
**Output:** Two agents communicating via NATS JetStream

### Part A: Define Agent Scopes (10 min)

Create character sheets for two agents:

**Agent 1: Backend**

```markdown
# agents/roy.md
[Fill in using template above]
```

**Agent 2: Frontend**

```markdown
# agents/jen.md
[Fill in using template above]
```

### Part B: Set Up NATS JetStream (10 min)

```bash
# Install and start NATS
nats-server --jetstream --store_dir /tmp/nats

# Create streams
nats stream add REQUIREMENTS --subjects "work.requirements.*" --retention limits
nats stream add INTEGRATION --subjects "work.integration.*" --retention limits
nats stream add DIRECT --subjects "work.direct.*" --retention limits

# Create consumers for each agent
nats consumer add REQUIREMENTS roy --pull --ack explicit --filter "work.requirements.backend"
nats consumer add REQUIREMENTS jen --pull --ack explicit --filter "work.requirements.frontend"
nats consumer add DIRECT roy --pull --ack explicit --filter "work.direct.roy"
nats consumer add DIRECT jen --pull --ack explicit --filter "work.direct.jen"

# Test it
nats pub work.requirements.backend '{"id": "test-001", "type": "test"}'
nats consumer next REQUIREMENTS roy  # Should see the message
```

### Part C: Implement Basic Agents (10 min)

Create minimal agent implementations that:

1. Pull from their NATS consumer
2. Process work and ACK on success
3. NAK with delay on failure
4. Publish completion to INTEGRATION stream

Test:

1. Publish a requirement: `nats pub work.requirements.backend '{"id": "REQ-001"}'`
2. Run Roy's turn - watch him pull and ACK
3. Check Roy published to integration: `nats stream view INTEGRATION`
4. Run Jen's turn - watch her see Roy's message

---

## Exercise 3.2: Queue Drainer with JetStream

**Time:** 20 minutes
**Output:** Working queue drainer with ACK guarantees

### Part A: Create Stream per Work Type

```bash
# Streams for different work types
nats stream add BACKEND_WORK --subjects "work.requirements.backend.*"
nats stream add FRONTEND_WORK --subjects "work.requirements.frontend.*"
nats stream add INFRA_WORK --subjects "work.requirements.infra.*"
```

### Part B: Implement Queue Drainer

```python
# queue_drainer.py
async def drain_queue(agent_name: str, stream: str, max_items: int = 10):
    """Pull and process items until queue is drained or max reached."""
    nc = await nats.connect()
    js = nc.jetstream()

    sub = await js.pull_subscribe(
        subject=None,
        durable=agent_name,
        stream=stream
    )

    processed = 0
    while processed < max_items:
        try:
            messages = await sub.fetch(1, timeout=5)
            for msg in messages:
                success = await process_work(msg)
                if success:
                    await msg.ack()
                    processed += 1
                else:
                    await msg.nak(delay=60)
        except nats.errors.TimeoutError:
            # Queue drained
            break

    await nc.close()
    return processed
```

### Part C: Test ACK Behavior

1. Publish 3 messages to a stream
2. Pull one, don't ACK, kill the agent
3. Restart agent - message should redeliver
4. ACK it this time
5. Verify message is gone from pending

---

## Common Issues

### Issue: Messages Not Being Redelivered

Agent pulls message, crashes, but message doesn't come back.

**Fix:** Ensure explicit ACK mode:

```bash
nats consumer add STREAM consumer_name --ack explicit --max-deliver 3
```

### Issue: Duplicate Processing

Agent processes message, crashes before ACK, message redelivers, work done twice.

**Fix:** Make operations idempotent, or track processed message IDs:

```python
async def process_work(self, msg):
    msg_id = msg.headers.get('Nats-Msg-Id')
    if await self.already_processed(msg_id):
        await msg.ack()  # Already done, just ACK
        return True
    # ... do work ...
    await self.mark_processed(msg_id)
    return True
```

### Issue: Agents Stepping on Each Other's Files

Even with defined scopes, accidents happen.

**Fix:** Add file-based locking:

```python
def acquire_file_lock(filepath):
    lock_file = f"{filepath}.lock"
    if os.path.exists(lock_file):
        return False
    with open(lock_file, 'w') as f:
        f.write(self.name)
    return True
```

### Issue: Turn Timing Conflicts

Two agents try to run at exactly the same time.

**Fix:** Stagger turn times:

```python
schedule.every(30).minutes.at(":00").do(run_roy)
schedule.every(30).minutes.at(":15").do(run_jen)
schedule.every(30).minutes.at(":30").do(run_moss)
```

### Issue: Stream Growing Too Large

Old messages accumulating forever.

**Fix:** Set retention limits:

```bash
nats stream add REQUIREMENTS \
  --subjects "work.requirements.*" \
  --retention limits \
  --max-msgs 10000 \
  --max-age 7d
```

---

## What You'll Have After This Workshop

1. **LLM-friendly codebase** with small files and clear interfaces
2. **Specialist agent definitions** with clear scopes and tools
3. **NATS JetStream** for reliable agent-to-agent communication
4. **Matrix integration** for human-agent interaction
5. **Turn-based queue draining** with explicit ACKs
6. **Direct messaging** between agents for coordination

Your agents can now work as a team, passing information and coordinating without real-time meetings. Work is guaranteed delivered via JetStream ACKs.

---

## Next Steps

- [Workshop 4 - Release Management](Workshop-4-Release-Management.md) - Coordinate merges and scale the team
- Add a third specialist agent for infrastructure

---

**Previous:** [Workshop 2 - Autonomous Workers](Workshop-2-Autonomous-Workers.md) | **Next:** [Workshop 4 - Release Management](Workshop-4-Release-Management.md)
