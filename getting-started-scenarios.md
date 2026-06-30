# Getting Started: Scenarios and Tips

## First Use Scenarios

These scenarios are designed to show you what makes a personal AI assistant different from a basic chatbot. Each one requires your assistant to recognize a capability gap, hire a new team member to fill it, and then coordinate that agent to deliver a real result. That hiring loop, where the researcher scopes the domain and HR drafts the new agent profile, is the core capability you are learning to use.

---

### Scenario 1: Plan an International Trip

**The ask:** Tell your assistant to plan a 10-day trip to Japan in October. You want flights, accommodation, a day-by-day itinerary, and a budget breakdown.

**Why this works as a first demo:** Your starter kit ships with no travel specialist. The orchestrator has to flag that gap, send the researcher to define what a real travel planner knows, and have HR draft and hire a new agent before any planning begins. Once the new agent is live, the actual trip planning runs. The end deliverable is a full travel brief you can evaluate immediately, because you already know what a good Japan trip looks like.

**What to watch for:** The moment your assistant says "I don't have a team member who can handle this, I'm going to hire one" is the point of the demo. Everything after that is proof it worked.

---

### Scenario 2: Research and Shortlist a Major Purchase

**The ask:** Ask your assistant to help you buy a used car (or a high-end laptop, or a home audio system). You want a shortlist of options, a price and market analysis, a recommended pick, and a walk-away price for negotiation.

**Why this works as a first demo:** The starter kit has no consumer researcher, no market analyst, and no negotiation advisor. Depending on how specific your request is, you may watch two or three agents get hired in sequence before any research begins. The output is a decision brief that is both tangible and personally relevant.

**What to watch for:** Whether the assistant correctly identifies that this task needs multiple specialists, not just one. A good orchestrator breaks the problem before delegating.

---

### Scenario 3: Prepare for a Role or Career Change

**The ask:** Name a specific company and job title you are curious about. Ask your assistant to research the company and role, benchmark compensation, identify skill gaps relative to your current background, and produce a 90-day prep plan.

**Why this works as a first demo:** None of those capabilities exist in the starter kit. A labor market analyst, a company researcher, and potentially a compensation benchmarker all need to be hired first. The output is also immediately meaningful to whoever is running the demo, which makes it easy to judge quality.

**What to watch for:** This scenario tests whether the assistant can hold a multi-part brief across several agents and stitch the outputs into a single coherent deliverable, not just hand you four separate documents.

---

## Tips and Tricks

### Getting Your Assistant to Remember Something

Drop a note into `team_inbox/` that says "remember this for all future conversations" and states what you want retained. Your orchestrator will save it to memory. Examples:

- "Remember that I prefer outputs as bullet points, not paragraphs."
- "Remember that I'm based in Sydney and any travel suggestions should route through SYD."
- "Remember my car is a 2021 Toyota RAV4 so you don't have to ask every time."

Memory persists across sessions. If something is remembered incorrectly, just correct it the same way: "Update your memory, my preference for X has changed to Y."

---

### How to Drop Work into the Inbox

You do not need to be in a chat session to give your assistant work. Drop a file into `team_inbox/` with a short note explaining what you want done. Your assistant reads the inbox at the start of each session. Good formats for inbox drops:

- A screenshot of an email you need drafted in reply
- A PDF you want summarized with recommendations
- A voice memo transcript you want turned into action items
- A URL (as a text file) you want researched and filed

---

### How to Set the Output Format

By default your assistant delivers markdown. If you want something different, say so explicitly:

- "Deliver this as a table."
- "I want this as a Word doc in the owners inbox."
- "Give me a one-pager I can paste into an email."

You can also set a standing preference in memory: "Remember that I prefer all research outputs as a one-page brief, not a long report."

---

### How to Give Feedback That Sticks

If your assistant does something wrong, or right in a non-obvious way, tell it to remember the lesson. Corrections compound over time.

- "That tone was too formal. Remember I write casually."
- "Perfect structure on that brief. Remember to use that format for all future research outputs."
- "Don't include cost estimates unless I ask. Remember that."

The difference between a generic assistant and a great one is the feedback loop. The more you correct and confirm, the more calibrated it becomes.

---

### Prioritizing Work

Your assistant runs at normal priority by default. If something is urgent, say so explicitly: "This is urgent, handle it first." The orchestrator will queue it ahead of other work.

For non-urgent tasks you want done in the background, say: "No rush on this, pick it up when the team has capacity." This is useful for research tasks that do not have a deadline.

---

### When to Hire vs When to Just Ask

Not every task needs a new agent. A rough guide:

| Ask directly | Hire an agent |
| --- | --- |
| One-off question or lookup | Recurring work in a new domain |
| Simple formatting or editing | Specialist knowledge required |
| Summarizing something you provide | Research, planning, or analysis |
| Quick draft using existing context | Multi-step deliverables |

If you are unsure, just ask. Your orchestrator will tell you whether it can handle the task itself or whether it needs to bring someone in.
