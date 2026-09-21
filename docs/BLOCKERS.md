# IKMS Blockers Register

## Purpose
This document tracks blocking issues that prevent phase progression per §9.6. A phase is BLOCKED when it remains RED after `MAX_REPAIR_ROUNDS` (5) or when a Level-C condition is encountered.

---

## Current Blockers

### BLOCKER-001 — Missing Appendix Schema (Level C)

**Gate IDs Affected:** G4 (schema guard), G9 (traceability completeness)  
**Phase:** 0  
**Severity:** CRITICAL — Cannot proceed to Phase 1 without this

#### Error Output
```
G4 Schema Guard: FAIL
  - db/schema.snapshot.json: FILE MISSING
  - Reason: Appendix schema definition not provided in requirements document
  
G9 Traceability: PARTIAL FAIL
  - REQ-P0-04 (db/schema.snapshot.json): BLOCKED
  - ERD.md: BLOCKED (cannot generate without schema)
```

#### Root Cause Hypotheses Tested
1. **Appendix was in separate document** — Checked conversation history; not found
2. **Schema should be inferred from §6 descriptions** — Violates INV-01 spirit (schema is frozen)
3. **Should use representative schema** — Would require Level-C approval

#### Actions Taken
- Documented all tables mentioned in §6 in PROJECT_UNDERSTANDING.md
- Created TRACEABILITY.md with requirements mapped to table names
- Proceeding with Mode B documentation production

#### Minimal Reproduction
Attempt to scaffold EF Core DbContext without connection string → fails.

#### Recommended Path Forward
**Option A (Recommended):** User provides complete Appendix schema with:
- All table names (exact spelling including typos like `NewsCtegory_Id`)
- Column definitions (name, type, nullability)
- Primary keys, foreign keys, constraints
- Any existing indexes

**Option B (If Appendix unavailable):** Authorize construction of representative schema based on §6 entity descriptions, clearly marked as provisional. This requires explicit user approval as it technically violates INV-01 spirit.

**Option C (Hybrid):** Provide partial schema for critical tables first (Users, Domains, Terms, TMD, Relations), enabling Phase 1-3 work while remaining tables are documented.

#### Alternatives Considered
- Reverse-engineer from existing database (requires DB access)
- Use schema inference from entity descriptions (risky, may miss details)

---

### BLOCKER-002 — .NET 9 SDK Unavailable (Level C)

**Gate IDs Affected:** G1 (build), G2 (tests), G3 (coverage), G8 (runtime smoke)  
**Phase:** 1+  
**Severity:** HIGH — Cannot execute backend gates

#### Error Output
```bash
$ dotnet --version
bash: dotnet: command not found
```

#### Environment State
- Node.js: v20.20.2 ✅
- npm: 10.8.2 ✅
- .NET SDK: NOT FOUND ❌
- PowerShell: NOT FOUND ❌

#### Root Cause
Execution environment lacks .NET 9 SDK installation.

#### Actions Taken
- Declared Operating Mode B (Chat-only) per §8
- All deliverables produced as complete file contents with exact paths
- Gates labelled `STATIC ONLY (not executed)`
- User instructions prepared for local verification

#### Recommended Path Forward
**Option A (Recommended):** User installs .NET 9 SDK locally:
```bash
# Linux/macOS
wget https://dot.net/v1/dotnet-install.sh
chmod +x dotnet-install.sh
./dotnet-install.sh --channel 9.0

# Or use official installer from https://dotnet.microsoft.com/download
```

**Option B:** Continue in Mode B until deployment, then verify on target machine.

#### Impact on Timeline
- Documentation phases (0, partial 1): No impact
- Code implementation phases (1-11): Can produce code, cannot verify gates
- Final delivery: Requires user to run full gate suite locally

---

## Resolved Blockers

*(None yet)*

---

## Summary

| ID | Issue | Status | Phase | Resolution |
|----|-------|--------|-------|------------|
| BLOCKER-001 | Missing Appendix schema | OPEN | 0 | Awaiting user response |
| BLOCKER-002 | .NET 9 SDK unavailable | OPEN | 1+ | Mode B operation |

---

## Escalation Path

If blockers remain unresolved after 48 hours:
1. Document attempted workarounds
2. Identify minimal viable subset that can proceed
3. Recommend project continuation strategy

---

*Last updated: Session 1, Phase 0 in progress*
