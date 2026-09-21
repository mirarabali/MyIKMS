# IKMS Decisions Register

## Decision Format
- **ID**: DEC-NN
- **Title**: Short descriptive name
- **Status**: Proposed | Accepted | Superseded
- **Phase**: When decision was made
- **Context**: Problem being solved
- **Options Considered**: Alternatives evaluated
- **Decision**: Chosen approach
- **Consequences**: Implications (positive/negative)
- **Reversal Path**: How to undo if needed

---

## DEC-01 — Domain-Scoped Role Naming Pattern

**Status:** Accepted  
**Phase:** 0  
**Context:** `UserRoles` table has no domain column, but CONV-08 requires domain-scoped roles.

**Options Considered:**
1. Add `Domain_Id` column to `UserRoles` — Rejected: violates INV-01 (schema frozen)
2. Separate linking table `DomainUserRoles` — Rejected: violates INV-01
3. Encode domain in role name — Selected: no schema change required

**Decision:** Format `"{RoleTitle} — {DomainTitle}"` using em-dash (U+2014) as separator.

**Consequences:**
- ✅ No schema modification required
- ✅ Simple to implement and parse
- ⚠️ Role names must be unique across all domain combinations
- ⚠️ UI must handle composition/decomposition transparently

**Reversal Path:** If better mechanism identified, requires Level-C approval for schema change.

---

## DEC-02 — Mapper Choice: AutoMapper over Mapster

**Status:** Accepted  
**Phase:** 0  
**Context:** Need object-to-object mapping between entities and DTOs.

**Options Considered:**
1. **AutoMapper** — Selected
2. **Mapster** — Lighter weight, but smaller community
3. **Manual mapping** — More verbose, error-prone

**Decision:** Use AutoMapper with explicit profile classes organized by bounded context.

**Consequences:**
- ✅ Large community, extensive documentation
- ✅ Good ASP.NET Core DI integration
- ✅ Profile-based organization fits Clean Architecture
- ⚠️ Slight performance overhead vs manual mapping (acceptable)

**Reversal Path:** Replace `IMapper` implementations; profiles are isolated.

---

## DEC-03 — Search Engine: SQL Server FTS Initially

**Status:** Accepted  
**Phase:** 0  
**Context:** Need full-text search over Terms and DocContent with Persian support.

**Options Considered:**
1. **SQL Server Full-Text Search** — Selected
2. **Elasticsearch** — More powerful, but requires separate infrastructure
3. **OpenSearch** — Similar to Elasticsearch, same infrastructure concern

**Decision:** Start with SQL Server FTS, can migrate later if needed.

**Consequences:**
- ✅ No new infrastructure (respects INV-04 "no containers")
- ✅ Complies with INV-03 (only indexes/catalogs added)
- ⚠️ Persian word breaker may need custom configuration
- ⚠️ Less flexible than dedicated search engine

**Reversal Path:** Implement `ISearchEngine` abstraction, create Elasticsearch adapter.

---

## DEC-04 — Payment Gateway Abstraction

**Status:** Accepted  
**Phase:** 0  
**Context:** Need payment processing for access policy and loan fees.

**Options Considered:**
1. **Interface-based abstraction** — Selected
2. **Direct integration** — Tightly coupled, hard to test

**Decision:** `IPaymentGateway` interface with `MockPaymentGateway` for dev/test.

**Consequences:**
- ✅ Easy testing without real payments
- ✅ Can swap providers without code changes
- ✅ Multiple provider support (ZarinPal, IDPay, etc.)

**Reversal Path:** N/A — this is the correct pattern.

---

## DEC-05 — Locator String Grammar (CONV-01)

**Status:** Accepted  
**Phase:** 0  
**Context:** Need standard format for locator strings in `Relations.TermsRelation_Description`.

**Options Considered:**
1. **Structured grammar** — Selected: `vol.{volume}/p.{page}/{position}`
2. **Free-form text** — Ambiguous, hard to parse

**Decision:** Formal grammar with paragraph (§), section, or line notation.

**Consequences:**
- ✅ Unambiguous, machine-parseable
- ✅ Round-trip safe (parse → serialize → same string)
- ✅ Tested parser utility class

**Reversal Path:** Update parser, migrate existing data if format changes.

---

## DEC-06 — Time-Code String Grammar (CONV-02)

**Status:** Accepted  
**Phase:** 0  
**Context:** Need standard format for audio/video time-codes.

**Options Considered:**
1. **HH:mm:ss** — Selected: familiar, supports long content
2. **Total seconds** — Less human-readable
3. **SMPTE timecode** — Overkill for our use case

**Decision:** `HH:mm:ss` for point, `HH:mm:ss-HH:mm:ss` for range.

**Consequences:**
- ✅ Familiar to users (video editor standard)
- ✅ Hours can exceed 23 for long content
- ✅ Validated parser utility class

**Reversal Path:** Update parser, migrate existing data.

---

## DEC-07 — Cardinality String Grammar (CONV-03)

**Status:** Accepted  
**Phase:** 0  
**Context:** Need standard format for cardinality constraints.

**Options Considered:**
1. **Single value or range** — Selected: `"0"`, `"3"`, `"*"`, `"0..3"`, `"1..*"`
2. **JSON object** — Overly complex for simple constraints

**Decision:** Parsed to `(int min, int max)` tuple where max=-1 means unbounded.

**Consequences:**
- ✅ Human-readable in database
- ✅ Easy to validate programmatically
- ✅ Supports all common cardinality patterns

**Reversal Path:** Update parser, minimal data migration.

---

## DEC-08 — State_Id on TMD is Authoritative (CONV-04)

**Status:** Accepted  
**Phase:** 0  
**Context:** `TMD` table has both `State_Id` and `TMD_StateId` columns.

**Decision:** New code never writes `TMD_StateId`. Always use `State_Id`.

**Consequences:**
- ✅ Single source of truth for state
- ✅ Prevents conflicting state values
- ⚠️ Requires discipline in code reviews

**Reversal Path:** N/A — this enforces existing schema intent.

---

## DEC-09 — RelationsTypes Duality Inference (CONV-05)

**Status:** Accepted  
**Phase:** 0  
**Context:** `RelationsTypes` serves dual purpose based on `RelationsType_DataTypeId`.

**Decision:** Infer type at runtime: NOT NULL = attribute type, NULL = semantic relation type.

**Consequences:**
- ✅ No discriminator column needed
- ✅ Respects frozen schema
- ⚠️ Must remember to check `DataTypeId` in queries

**Reversal Path:** N/A — this is how the schema works.

---

## DEC-10 — Permission Key Discovery from Attributes (CONV-06)

**Status:** Accepted  
**Phase:** 0  
**Context:** Need to sync permission keys from code into `API`/`Permissions` tables.

**Decision:** Startup scan of `[RequirePermission]` attributes, idempotent upsert.

**Consequences:**
- ✅ Single source of truth (code)
- ✅ No manual permission registration
- ⚠️ Missing permissions only detected at startup

**Reversal Path:** Manual permission management if automated sync disabled.

---

## DEC-11 — Polymorphic Key Whitelist Validation (CONV-07)

**Status:** Accepted  
**Phase:** 0  
**Context:** `Files` and `Logs` use polymorphic keys (`*_TableName`).

**Decision:** Hardcoded whitelist of valid table names, validated on every write.

**Consequences:**
- ✅ Prevents invalid table references
- ✅ Clear error messages
- ⚠️ Must update whitelist when adding new referenceable tables

**Reversal Path:** N/A — security requirement.

---

## DEC-12 — JSON Audit Snapshots (CONV-09)

**Status:** Accepted  
**Phase:** 0  
**Context:** Need version history/revert capability via `Logs.Log_Activity`.

**Decision:** JSON snapshot of changed fields with old/new values.

**Consequences:**
- ✅ Complete audit trail
- ✅ Revert by replaying old values
- ⚠️ JSON size grows with entity size

**Reversal Path:** Alternative logging format if JSON proves problematic.

---

## DEC-13 — Modules Always Active (CONV-11)

**Status:** Accepted  
**Phase:** 0  
**Context:** `Modules` table has no status column.

**Decision:** Accept limitation — all modules always active. Archive via documentation.

**Consequences:**
- ✅ No schema workaround attempts
- ✅ Clear design boundary
- ⚠️ Cannot deactivate modules without violating INV-01

**Reversal Path:** Requires Level-C (schema change).

---

## DEC-14 — Blazor Rejected for Frontends

**Status:** Accepted  
**Phase:** 0  
**Context:** Frontend stack selection per §4.

**Options Considered:**
1. **React + Next.js** — Selected
2. **Blazor** — Rejected

**Decision:** React ecosystem chosen for RTL/Persian support and SEO.

**Consequences:**
- ✅ Mature RTL/Jalali libraries
- ✅ Next.js provides SSR for public portal SEO
- ⚠️ Two frontend codebases (Admin + Public)

**Reversal Path:** Major rewrite — not recommended after Phase 1.

---

## Pending Decisions

### DEC-15 — Admin Panel Component Library

**Status:** Proposed  
**Context:** Choosing between MUI and Ant Design for React admin panel.

**Options:**
1. **MUI (Material-UI)** — Rich component set, good RTL support
2. **Ant Design** — Enterprise-focused, excellent RTL

**Recommendation:** MUI — larger community, more Persian i18n resources.

---

## Summary

| ID | Topic | Status | Phase |
|----|-------|--------|-------|
| DEC-01 | Domain-scoped role naming | Accepted | 0 |
| DEC-02 | Mapper choice | Accepted | 0 |
| DEC-03 | Search engine | Accepted | 0 |
| DEC-04 | Payment gateway | Accepted | 0 |
| DEC-05 | Locator grammar | Accepted | 0 |
| DEC-06 | Time-code grammar | Accepted | 0 |
| DEC-07 | Cardinality grammar | Accepted | 0 |
| DEC-08 | State_Id authority | Accepted | 0 |
| DEC-09 | RelationsTypes duality | Accepted | 0 |
| DEC-10 | Permission discovery | Accepted | 0 |
| DEC-11 | Polymorphic key whitelist | Accepted | 0 |
| DEC-12 | JSON audit snapshots | Accepted | 0 |
| DEC-13 | Modules always active | Accepted | 0 |
| DEC-14 | Blazor rejected | Accepted | 0 |
| DEC-15 | Admin component library | Proposed | pending |
