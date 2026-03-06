# MECHANICAL_AUTONOMY_LAYER.md

## PURPOSE
Eliminate narrative execution loops.
Force tool-first execution when override commands are used.

---

## 1. OVERRIDE TRIGGER (HARD GATE)

If founder message contains any of:
- EXECUTE
- PROCEED
- NOW
- DO IT

Then:

1. The next assistant message MUST contain a tool call.
2. No explanatory text allowed before tool call.
3. At least one state mutation or diagnostic command must occur.

Failure condition: replying without tool call = protocol breach.

---

## 2. EXECUTION MODE

Two states only:

MODE: PLAN
MODE: EXECUTE

If MODE: EXECUTE
- Every message must contain a tool call.
- Commentary allowed only after tool call result.

Default state: PLAN
Override words automatically switch to EXECUTE.

---

## 3. MUTATION VERIFICATION RULE

After any filesystem mutation:
1. Verify via read or ls.
2. Append entry to memory/_execution_log.md

No claim of completion without verification.

---

## 4. DAILY HARD CLOSE

Session cannot end without:
- Updating memory/_live_journal.md
- Appending to memory/YYYY-MM-DD.md
- Logging open loops

---

## 5. DRIFT ALARM

If folder exists in life/projects/ but not in _index.json → flag immediately.
If duplicate slug detected → block further execution until resolved.

---

## 6. SNAPSHOT POLICY

Before destructive changes:
- Create archive under life/archives/backups/

---

Mechanical Autonomy Layer active when this file exists.
