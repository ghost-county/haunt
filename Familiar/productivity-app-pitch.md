# Productivity App - Design Doc & Pitch

## Working Name Candidates
- Argus
- Heimdall
- Virgil
- Pilot
- Steady
- Levee
- Helm
- Sift

---

## The Problem

Knowledge workers with ADHD lose hours every day to context switching and decision paralysis. They open their email - 47 unread messages stare back. They check their calendar - 6 meetings, but which ones actually matter? They look at their task list - 30 items, all seemingly urgent.

The result? They spend more time managing their productivity tools than actually being productive. They check email compulsively because they don't trust themselves to know what's important. They miss critical deadlines buried in noise. They burn mental energy just figuring out where to start.

Current productivity tools make this worse - they're designed for neurotypical brains that can naturally filter, prioritize, and context-switch. For ADHD brains, every tool is another tab, another context, another place to check.

---

## The Solution

A single, intelligent dashboard that uses AI to do the thinking for you. It connects to your existing tools (email, calendar, tasks), analyzes everything through the lens of YOUR work patterns and priorities, and presents one simple view: "Here's what actually needs your attention right now, and why."

No more decision fatigue. No more context switching. No more wondering if you're working on the right thing.

---

## How It Works

The system continuously monitors your email, calendar, and task systems. When new information arrives, AI analyzes it for urgency, action required, estimated time, and deadline - not just by keywords, but by understanding context, sender relationships, and content.

Instead of showing you everything, it shows you what matters:

- "3 emails need immediate response (estimated 20 minutes total)"
- "Meeting prep required: Board review in 2 hours - needs 15 minutes"
- "2 tasks due today, but X is blocked until Y responds"

---

## Key Features

### Intelligent Triage
- AI analyzes every email for actual urgency vs. perceived urgency
- Understands who matters (boss vs. vendor spam)
- Extracts deadlines and action items automatically
- Learns your patterns over time

### Unified Dashboard
- One view across email, calendar, tasks
- Color-coded priority (what's on fire, what can wait)
- Clear next actions, no ambiguity
- Estimated time for each item

### Brain Dump Capture
- Quick-add for random thoughts that hit mid-task
- AI processes them later, extracts action items
- Prevents "I should do this now" derailment

### Focus Environment
- Built-in soundscapes (brown noise, office ambience, rain)
- Hyperfocus mode: hide everything except current task
- Distraction logging to understand patterns
- No need to leave the app to create focus conditions

### Energy-Aware Scheduling
- Match task recommendations to user's energy patterns
- High-cognitive work suggested during peak hours, admin tasks during slumps
- Learns from calendar patterns and task completion history
- Adapts to individual chronotypes

### Meeting Context Autopilot
- 30 minutes before any meeting, auto-surface relevant context
- Shows related emails, docs, and open action items with attendees
- Summarizes last interaction and outstanding commitments
- No more scrambling or walking in cold

### Context Bundles
- AI groups related items across email/calendar/tasks by project or person
- Work on "Project Phoenix" and see everything related in one view
- Eliminates hunting across scattered tools
- Automatic relationship mapping

### Interrupt Recovery Mode
- One-button context capture when pulled away (phone, coworker, emergency)
- Stores exactly where you were and what you were thinking
- When you return, restores full context instantly
- Tracks interrupt patterns to identify problem areas

### Calendar Defense
- Proactively blocks focus time based on task load
- Suggests meeting consolidation opportunities
- Warns before accepting meetings that fragment clear days
- Protects deep work windows

### Cross-Platform
- Web app for work computer
- Desktop app for home
- Mobile for on-the-go captures and quick checks

---

## User Accounts & Subscription

### Authentication

Users sign in exclusively via OAuth through Google or Microsoft. This approach:

- Eliminates password management friction (one less thing to remember)
- Aligns naturally with required integrations (Gmail/Outlook, Calendar)
- Reduces onboarding steps — sign in and connect services in one motion
- Leverages enterprise SSO where users already have managed accounts

No email/password option. Users must have either a Google or Microsoft account.

### What Syncs Across Devices

User accounts enable seamless experience across web, desktop, and mobile. All user state lives in the cloud:

| Data Category | What's Included |
|---------------|-----------------|
| **Integrations** | OAuth tokens for connected services (Gmail, Outlook, calendar, task systems) |
| **AI Personalization** | Learned urgency patterns, sender importance rankings, response time models |
| **Energy Profile** | Chronotype settings, peak hours, detected productivity patterns |
| **Preferences** | Dashboard layout, notification settings, default soundscapes, theme |
| **Context Bundles** | User-created and AI-generated project/person groupings |
| **Brain Dump History** | Captured thoughts, extracted action items, processing status |
| **Focus Analytics** | Session history, interrupt logs, distraction patterns |
| **Interrupt Snapshots** | Saved context states for recovery |

Users log in on any device and pick up exactly where they left off. No re-configuration, no re-training the AI.

### Account Tiers

Two tiers: **Free** and **Pro**.

At launch, both tiers include identical functionality. The tier structure exists to support future differentiation and monetization without requiring architectural changes.

| | Free | Pro |
|---|------|-----|
| **All current features** | ✓ | ✓ |
| **Cross-device sync** | ✓ | ✓ |
| **AI personalization** | ✓ | ✓ |
| **Future premium features** | — | ✓ |
| **Price** | $0 | TBD |

Future candidates for Pro-only features (not committed):
- Advanced analytics and productivity insights
- Priority AI processing
- Extended brain dump history
- Team collaboration features
- Custom integrations

### Billing Infrastructure

Stripe integration will be implemented from day one, but dormant:

- Users can exist in Free or Pro state
- Upgrade/downgrade flows are built but not exposed in UI
- Webhook handlers ready for subscription lifecycle events
- No payment collection until tier differentiation is defined

This ensures we can flip the switch on monetization without a rebuild.

### Account Data Handling

User data is stored in a central repository with:

- Encryption at rest for all sensitive data (OAuth tokens, personal patterns)
- Clear data retention policies (to be defined)
- User-initiated account deletion with full data purge
- GDPR/CCPA compliance considerations built into schema design

*See Open Questions for outstanding privacy/data handling decisions.*

---

## Target Users

**Primary:** Knowledge workers with ADHD, particularly in tech and creative fields where email overload and constant context-switching are killing productivity.

**Secondary:** Anyone drowning in digital noise who needs help prioritizing.

---

## The Differentiator

Every productivity tool on the market asks you to bring discipline, organization, and executive function TO the tool. This one knows you don't have those in abundance - that's the whole problem. Instead, it provides the executive function FOR you. It's not a tool that helps you work - it's a tool that thinks alongside you.

---

## Success Metrics

- Reduction in "email check" frequency
- Faster response time on actually-urgent items
- Decreased missed deadlines
- User-reported decrease in decision fatigue
- Time spent in focused work vs. tool-hopping

---

## Why Now

AI finally makes this possible. Previous attempts at "smart inboxes" relied on rules and filters - crude instruments that can't understand nuance. LLMs can actually read an email and understand "this is urgent because your boss used specific language indicating deadline pressure" vs. "this vendor is using urgent-sounding words but there's no actual deadline."

---

## The Vision

This isn't just a productivity app. It's a cognitive assistant for people whose brains work differently. It meets ADHD brains where they are instead of demanding they change to fit neurotypical systems.

---

## Open Questions / TODO

- [ ] Final name selection
- [ ] Pricing model (Pro tier pricing, annual discount strategy)
- [ ] MVP feature set (what ships first?)
- [ ] Integration priority order (Gmail first? Outlook? Both?)
- [ ] Privacy/data handling approach (retention policies, user data access, third-party sharing)
- [ ] Competitive analysis
- [ ] Pro tier feature differentiation (what justifies the upgrade?)
- [ ] Billing trigger (what milestone activates paid tier?)

---

*Last updated: December 2024*
