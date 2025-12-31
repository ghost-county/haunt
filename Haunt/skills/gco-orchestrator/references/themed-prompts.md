# Themed Prompts: Atmospheric Collections

## Theming Philosophy

- Keep atmospheric touches **light and quick**
- Theming enhances, doesn't obscure
- Core workflow stays clear and functional
- Random selection adds variety without being overwhelming
- Mode transitions should feel natural, not jarring

---

## Mode Detection Prompts

### Mode 1 Detection (New Project)

- "🕯️ No .haunt/ detected. Beginning full séance ritual..."
- "🕯️ A virgin repository. Let us prepare the full ritual..."
- "🕯️ Fresh ground for a haunting. The full séance begins..."

### Mode 1 Detection (Existing Project)

- "🕯️ Existing project detected. Beginning incremental séance..."
- "🕯️ The spirits recognize this place. An incremental summoning..."
- "🕯️ A familiar haunting. Beginning targeted ritual..."

### Mode 2 Initial Prompt

- "🕯️ The spirits stir. What brings you to the veil?"
- "🕯️ The séance chamber awaits. What is your intent?"
- "🕯️ The candles flicker. Speak your purpose."

### Mode 2 Choice A Follow-up

- "What would you like to add?"
- "Tell me your vision. What shall we manifest?"
- "Speak it into being. What do you wish to create?"

### Mode 2 Choice B - Roadmap Display Header

- "📋 Current roadmap shows these unstarted items:"
- "📜 The grimoire reveals these pending rituals:"
- "📋 The spirits await these tasks:"

### Mode 3 Initial Prompt

- "🕯️ A fresh haunting ground. What would you like to build?"
- "🕯️ Untouched soil. What shall we raise from nothing?"
- "🕯️ A blank slate awaits. What is your vision?"

---

## Summoning Prompts (Before Spawning Agents)

**Usage:** 75% random selection from this list, 25% original creation

### Ready Prompts

- "Ready to summon the spirits?"
- "Are you brave enough to summon the spirits?"
- "Shall we invoke the spirits for our dark intent?"
- "The spirits grow restless. Shall we release them?"
- "The veil is thin. Ready to call forth the spirits?"
- "Your roadmap is complete. Dare we wake the dead?"
- "The ritual is prepared. Summon the spirits?"
- "The incantation is ready. Shall we begin the summoning?"
- "The spirits await your command. Give the word?"
- "By candlelight and code, shall we summon our ghostly allies?"

---

## Summoning Responses (After User Says Yes)

**Usage:** 75% random selection from this list, 25% original creation

### Affirmative Responses

- "👻 The spirits rise..."
- "🕯️ The candles flicker. They come."
- "💀 So be it. The summoning begins."
- "🌙 The veil parts..."
- "👁️ They hear your call."

---

## Decline Responses (After User Says No)

**Usage:** 75% random selection from this list, 25% original creation

### Negative Responses

- "🕯️ The candles dim. The spirits rest... for now."
- "👻 Wise. The spirits will wait."
- "🌑 The séance concludes. Your roadmap stands ready."
- "💤 The dead sleep a while longer."

---

## Planning Depth Messages

### Quick Mode

- "⚡ Quick scrying..."
- "⚡ A swift glimpse into the future..."
- "⚡ Fast-tracking the ritual..."

### Standard Mode

- "🔮 Scrying the future..."
- "🔮 The crystal ball reveals..."
- "🔮 Reading the signs..."

### Deep Mode

- "🔮 Deep scrying the future..."
- "🔮 The depths of the crystal reveal..."
- "🔮 Peering into the void..."

---

## Gardening/Archival Messages

### Gardening Start

- "🌙 The spirits have returned. Their work is done."
- "⚰️ The ritual is complete. Time to lay them to rest."
- "🕯️ The candles extinguish. Banishing the spirits..."

### Archival Success

- "⚰️ The spirits rest."
- "💤 They return to the void."
- "🌑 The séance concludes."

### Partial Completion

- "🌙 The spirits have returned. Some work remains."
- "⚰️ Some spirits linger still..."
- "🕯️ The ritual continues tomorrow."

---

## Error/Warning Messages

### No Roadmap

- "⚠️ The grimoire is empty. Create a roadmap first."
- "📜 No rituals found. Scry the future first: `/seance --scry`"
- "🔮 The spirits have nothing to work on. Plan first."

### All Blocked

- "⚠️ All paths are blocked. Resolve dependencies first."
- "🚧 The way is barred. Unblock requirements before summoning."
- "🔴 The spirits cannot proceed. Dependencies must be met."

### Version Update Available

- "🔮 Haunt framework has new features available."
- "📦 A new version of the framework awaits."
- "✨ The spirits bring new powers..."

---

## 75/25 Rule Guidance

**When to use canned prompts (75%):**
- Pick randomly from appropriate category
- Use `random.choice()` or similar
- Ensures variety without manual effort

**When to create original (25%):**
- Generate spooky emoji + brief atmospheric line
- Keep to Ghost County style: supernatural, mysterious, brief
- Examples of good original prompts:
  - "🦇 The bats stir. Shall we wake them?"
  - "🕸️ The web is woven. Time to catch our prey?"
  - "⚡ Lightning strikes. The spirits answer."
- Avoid being overly verbose or breaking character

**Implementation:**
```python
import random

SUMMONING_PROMPTS = [
    "Ready to summon the spirits?",
    "Are you brave enough to summon the spirits?",
    # ... rest of canned prompts
]

def get_summoning_prompt():
    """
    Returns summoning prompt following 75/25 rule.
    75% of time: random canned prompt
    25% of time: encourage LLM to generate original
    """
    if random.random() < 0.75:
        return random.choice(SUMMONING_PROMPTS)
    else:
        return "[GENERATE_ORIGINAL]"  # Signal to LLM to create new one

prompt = get_summoning_prompt()
if prompt == "[GENERATE_ORIGINAL]":
    # LLM creates spooky emoji + brief atmospheric line
    prompt = generate_original_prompt()
```

---

## Guidelines for Original Prompt Creation

When generating original prompts (25% of time), follow these guidelines:

### Structure

1. **Start with spooky emoji** (1-2 emojis max)
2. **Brief atmospheric phrase** (5-10 words)
3. **Optional question mark** (if prompting for decision)

### Good Examples

- "🌙 Moonlight guides the way. Shall we proceed?"
- "💀 The bones rattle. Time to wake the dead?"
- "🕷️ The spiders weave. Ready to spin fate?"
- "⚡ Thunder rolls. The spirits stir."
- "🦇 Night falls. Shall we summon?"

### Bad Examples (Avoid)

- "🎃🕯️🌙💀 The spirits of the ancient realm gather in the moonlit graveyard, awaiting your command to rise from their eternal slumber and heed your call to action..." (Too verbose)
- "Click yes to continue" (Not atmospheric)
- "🤖 Initializing agent processes..." (Wrong theme - robotic, not supernatural)

### Emoji Suggestions by Context

**Summoning:** 👻 🕯️ 💀 🌙 👁️ 🦇 🕷️ ⚡
**Decline:** 🌑 💤 🕯️ 🦉
**Archival:** ⚰️ 💤 🌑 🕯️
**Planning:** 🔮 🌙 ✨ 🕯️
**Errors:** ⚠️ 🚧 🔴 ⛔
