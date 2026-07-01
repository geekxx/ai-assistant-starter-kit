---
name: intake
description: Delegation intake interview. Use before delegating any significant or ambiguous task to a specialist. Runs a 6-question interview that forces precision, then compresses the answers into the spawn prompt the specialist receives. Skip for small, unambiguous tasks (filing, list updates, lookups).
---

# Intake — Delegation Brief

A specialist you spawn sees **only** the prompt you hand them. No session history,
no memory of past conversations, no context except what you write. This interview
turns that delegation brief from a guess into a decision.

## When to run this

- Run it when the task is significant or the brief is ambiguous: a deck, a research
  piece, a multi-step deliverable, anything where a wrong interpretation costs real rework.
- **Do not** run it for small, unambiguous tasks (filing a note, updating a list, a
  lookup, archiving an inbox file). The friction would just train <CUSTOMIZE: owner_name> to skip it.
- When in doubt, ask <CUSTOMIZE: owner_name>: "This one's worth a quick intake. Two minutes?" then proceed.

## The interview

Ask one question at a time. Wait for the answer before moving on.
After each answer, reflect back what you heard in one sentence, then continue.
The harder a question is to answer, the more useful it is — that difficulty is
the language gap a specialist would otherwise fill with a guess.

1. **The task** — What are you trying to make, decide, or get done? One sentence. If it takes more than one sentence, the scope isn't clear yet.
2. **Done looks like** — What's the deliverable that lands in `owners_inbox/`, in what format, and what is the checkable exit condition: the specific test, rubric, count, or sign-off that tells the specialist to stop iterating? A vague aspiration ("it should feel right") is not an exit condition — push for something that can pass or fail.
   _(Coaching: if <CUSTOMIZE: owner_name>'s answer is fuzzy, ask: "How would you decide in under 60 seconds whether the specialist's draft is accepted or needs another pass?" Press until the answer is testable.)_
3. **Shared language** — What terms, named things, people, or prior decisions does this touch that the specialist wouldn't know cold? For each: what does it mean in your context?
4. **Locked decisions** — What's already decided and not up for re-litigation? For each: the decision, and why it's locked.
5. **The failure mode** — What does a bad deliverable look like? What's the real cost of getting it wrong? This becomes the guardrail in the spawn prompt.
6. **The one thing** — If this has to get one thing right above all else, what is it? This becomes the headline instruction to the specialist.

## After the interview

1. **Route.** Name the specialist who should own this (or flag that a new hire is
   needed via <CUSTOMIZE: researcher_name> + <CUSTOMIZE: hr_name>). Stay the single point of contact.
2. **Compress into the spawn prompt.** Fold the six answers into the delegation prompt:
   - Q1 → the objective line
   - Q2 → deliverable spec + explicit exit condition (the checkable test the specialist uses to know when they are done) + output path
   - Q3 → a "context the specialist won't have" section
   - Q4 → constraints, marked as locked
   - Q5 → explicit guardrails / "do not" list
   - Q6 → the single headline instruction, stated first
   - Pick the model per CLAUDE.md (task complexity vs. cost).
3. **Persist durable shared language to memory.** Check whether any term from Q3 or
   decision from Q4 is worth keeping across sessions. Use your assistant's existing
   memory system — do **not** create a separate context file.
   Before writing a memory, apply the filter:
   - Would you have to explain this again next session without it?
   - Is it genuinely recurring, not specific to this one task?
   - Does it already exist in memory or CLAUDE.md?

   Only persist entries that pass all three. A shared-language term or locked decision is
   usually `type: reference` or `type: project`; keep it tight (name, one-line definition,
   and **Why:** for a decision). When in doubt, don't write it.

Then delegate, using the interview answers as the specialist's context.
