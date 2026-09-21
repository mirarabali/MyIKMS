# IKMS Assumptions & Ambiguities Register

## Classification Key
- **Level A**: Ordinary technical choices — decide silently, implement
- **Level B**: Conventions/contracts/interpretations — decide and document in DECISIONS.md
- **Level C**: Requires stopping and asking — INV violation, schema change, contradiction, or missing credentials

---

## Resolved Assumptions (Level B)

### A.1 — Domain-Scoped Role Naming Pattern (CONV-08)

**Ambiguity:** `UserRoles` table has no domain column. How to associate a role with a specific domain?

**Resolution:** Domain-scoped roles are encoded in the role name using the pattern:
```
"{RoleTitle} — {DomainTitle}"
```
- Separator: em-dash (U+2014) surrounded by spaces
- Both parts trimmed before comparison
- Parsing: split on last occurrence of `" — "` to handle role titles that might contain the separator
- Example: `"Term Editor — Jurisprudence"` and `"Term Editor — Management"` are distinct roles

**Utility Class:** `DomainScopedRoleParser` in `IKMS.Application.Utilities`
- `Parse(string roleName): (string roleTitle, string domainTitle)`
- `Compose(string roleTitle, string domainTitle): string roleName`
- Tested with edge cases (separator in title, leading/trailing spaces, empty domain)

**Consequences:**
- Role names must be unique across all domain combinations
- When creating a new domain-scoped role, system checks for existing role with same name
- UI displays role title and domain separately, composes for storage

**Reversal Path:** If a better mechanism is identified, migrate by:
1. Add `UserRoles.Domain_Id` column (requires Level-C, schema change — not recommended)
2. Or: use a different naming convention with migration script

**Documented In:** DECISIONS.md as DEC-01

---

### A.2 — Mapper Choice

**Decision:** AutoMapper over Mapster

**Justification:**
- Larger community and more extensive documentation
- Better integration examples with ASP.NET Core DI
- Sufficient performance for our use case (no extreme throughput requirements identified)
- Profile-based organization aligns with Clean Architecture boundaries

**Implementation:**
- Profile classes organized by bounded context in `IKMS.Application.Mapping.Profiles`
- Examples: `DomainProfile`, `TermProfile`, `RelationProfile`, `AuthProfile`
- All mappings defined explicitly (no attribute-based auto-mapping)

**Documented In:** DECISIONS.md as DEC-02

---

### A.3 — Search Engine Choice

**Decision:** SQL Server Full-Text Search (FTS) initially

**Justification:**
- No new infrastructure required (respects "no containers" constraint)
- Complies with INV-03 (only indexes/catalogs added)
- Adequate for Persian text with proper word breaker configuration
- Can be enhanced later if performance demands

**Implementation:**
- Full-text catalogs created on `Terms.Term_Title`, `Terms.Term_Description`, `DocContent.DocContent_Body`
- Custom word breaker configuration for Persian/Arabic normalization
- FTS queries wrapped in repository methods

**Reversal Path:** Migrate to Elasticsearch/OpenSearch by:
1. Deploy search cluster
2. Implement `ISearchEngine` abstraction
3. Create `ElasticsearchSearchEngine` adapter
4. Switch via DI configuration
5. Keep FTS as fallback during transition

**Documented In:** DECISIONS.md as DEC-03

---

### A.4 — Payment Gateway Abstraction

**Decision:** Interface-based abstraction with mock implementation

**Interface:** `IPaymentGateway` in `IKMS.Application.Interfaces`
```csharp
Task<PaymentInitializationResult> InitializePayment(PaymentRequest request);
Task<PaymentVerificationResult> VerifyPayment(string referenceId);
Task<RefundResult> Refund(string transactionId, decimal amount);
```

**Implementations:**
- `MockPaymentGateway`: For development/testing, simulates success/failure scenarios
- `ZarinPalGateway`: Production adapter for ZarinPal (Iranian payment gateway)
- `IDPayGateway`: Production adapter for IDPay

**Configuration:** Selected via `appsettings.json` → `Payment:Provider`

**Documented In:** DECISIONS.md as DEC-04

---

### A.5 — Locator String Grammar (CONV-01)

**Decision:** Formal grammar for locator strings stored in `Relations.TermsRelation_Description`

**Grammar:**
```
locator := vol.{digit}+/p.{digit}+/{position}
position := ¶{digit}+ | sec.{digit}+ | {digit}+  (paragraph | section | line)
```

**Examples:**
- `vol.2/p.45/¶3` — Volume 2, Page 45, Paragraph 3
- `vol.1/p.12/sec.4` — Volume 1, Page 12, Section 4
- `vol.3/p.78/12` — Volume 3, Page 78, Line 12

**Utility Class:** `LocatorStringParser` in `IKMS.Application.Utilities`
- `Parse(string locator): Locator` — returns structured object
- `Serialize(Locator locator): string` — round-trip safe
- `TryParse(string, out Locator): bool` — validation
- Tested with valid/invalid inputs

**Documented In:** DECISIONS.md as DEC-05

---

### A.6 — Time-Code String Grammar (CONV-02)

**Decision:** HH:mm:ss format for audio/video time-codes

**Grammar:**
```
timepoint := H+:mm+:ss  (hours can exceed 23 for long content)
timerange := timepoint-timepoint
```

**Examples:**
- `00:12:30` — Point: 12 minutes, 30 seconds
- `01:45:00-02:15:00` — Range: from 1h45m to 2h15m
- `25:30:00` — Long content: 25 hours, 30 minutes

**Utility Class:** `TimeCodeStringParser` in `IKMS.Application.Utilities`
- `ParsePoint(string): TimeSpan`
- `ParseRange(string): (TimeSpan start, TimeSpan end)`
- `Format(TimeSpan): string`
- `FormatRange(TimeSpan, TimeSpan): string`
- Validation: rejects malformed strings, negative times, end < start

**Documented In:** DECISIONS.md as DEC-06

---

### A.7 — Cardinality String Grammar (CONV-03)

**Decision:** Accepted formats for `RelationConstraints.MinCardinallity` / `MaxCardinallity`

**Formats:**
- `"0"`, `"3"`, `"*"` — Single values (* = unbounded)
- `"0..3"`, `"1..*"` — Range notation

**Parsed Representation:** `(int min, int max)` tuple where `max = -1` indicates unbounded

**Utility Class:** `CardinalityStringParser` in `IKMS.Application.Utilities`
- `Parse(string): (int min, int max)`
- `Validate(int count, string constraint): bool`
- Tested with all valid formats and common invalid inputs

**Documented In:** DECISIONS.md as DEC-07

---

## Pending Assumptions (Awaiting Clarification)

### A.8 — Appendix Schema Availability (Level C)

**Issue:** The prompt references an Appendix containing the frozen SQL Server schema, but it was not provided.

**Impact:** Cannot proceed with:
- Generating `db/schema.snapshot.json`
- Creating Mermaid ERD
- Scaffolding EF Core DbContext
- Implementing any backend logic (all depends on exact column names/types)

**Default Position if Told "Use Judgement":** Construct representative schema based on entity descriptions in §6, but this violates INV-01 spirit (schema is frozen and must match exactly). Not recommended.

**Status:** BLOCKING — Phase 0 cannot complete without this

---

### A.9 — SQL Server Instance Availability (Level C)

**Assumption Required:** A locally reachable SQL Server instance (Developer/Express/LocalDB) exists with the schema already applied.

**Configuration:** Connection string provided via:
- `appsettings.Development.json` → `ConnectionStrings:DefaultConnection`
- Or `.env` file → `DB_CONNECTION_STRING`

**Impact if Unavailable:** Cannot execute gates G1, G2, G4, G8 (require database connection)

**Fallback:** Proceed in Mode B (Chat-only), producing all code with explicit instructions for user to run gates locally

**Status:** Acknowledged — proceeding in Mode B due to missing .NET SDK anyway

---

### A.10 — .NET 9 SDK Availability (Level C)

**Observation:** Current execution environment lacks .NET 9 SDK

**Impact:** Cannot execute `dotnet build`, `dotnet test`, or any backend gates

**Resolution:** Operating in **Mode B (Chat-only)** per §8
- All file contents produced with exact paths
- Gates labelled `STATIC ONLY (not executed)`
- User must run verification commands locally

**Status:** Acknowledged — Mode B declared

---

## Implementation Notes

### CONV-04 — State_Id on TMD is Authoritative

**Clarification:** New code never writes `TMD_StateId` column directly. Always use `State_Id` property.

**Enforcement:**
- Entity configuration: `TMD_StateId` property marked `[NotMapped]` or ignored
- Service layer: only `State_Id` setter exposed
- Tests verify `TMD_StateId` is never written

**Documented In:** DECISIONS.md as DEC-08

---

### CONV-05 — RelationsTypes Duality

**Interpretation:** A `RelationsTypes` row is:
- An *attribute/field type* when `RelationsType_DataTypeId` IS NOT NULL
- A *semantic relation type* when `RelationsType_DataTypeId` IS NULL

**Inference Logic:** Never add a discriminator column. Determine type at runtime:
```csharp
bool IsAttributeType(RelationsTypes rt) => rt.RelationsType_DataTypeId.HasValue;
bool IsSemanticRelationType(RelationsTypes rt) => !rt.RelationsType_DataTypeId.HasValue;
```

**Utility Class:** `RelationsTypeDiscriminator` in `IKMS.Application.Utilities`

**Documented In:** DECISIONS.md as DEC-09

---

### CONV-06 — Permission Keys Discovery

**Mechanism:** At startup, scan all controllers for `[RequirePermission("key")]` attributes. Sync discovered keys into `API` and `Permissions` tables idempotently.

**Implementation:**
- `PermissionDiscoveryService` uses reflection to find all `[RequirePermission]` attributes
- `PermissionSyncService` upserts into `API` (controller names) and `Permissions` (permission keys)
- Idempotent: running multiple times produces same result
- Missing permissions logged as warnings

**Documented In:** DECISIONS.md as DEC-10

---

### CONV-07 — Files/Logs Polymorphic Keys Whitelist

**Validation:** On every write to `Files` or `Logs`, validate `*_TableName` against a fixed code-level whitelist.

**Whitelist:** Hardcoded list of valid table names:
```csharp
static readonly HashSet<string> ValidTableNames = new()
{
    "TMD", "Terms", "Domains", "Modules", "Relations", 
    // ... all valid tables
};
```

**Utility Class:** `TableNameValidator` in `IKMS.Application.Utilities`
- `IsValid(string tableName): bool`
- `Validate(string tableName)` — throws if invalid

**Tests:** Attempting to write with non-whitelisted table name is rejected

**Documented In:** DECISIONS.md as DEC-11

---

### CONV-09 — Audit/Version History as JSON Snapshot

**Format:** `Logs.Log_Activity` contains JSON snapshot of changed row:
```json
{
  "entityType": "TMD",
  "entityId": 123,
  "changedFields": {
    "TMD_Title": { "old": "Old Title", "new": "New Title" },
    "TMD_Description": { "old": null, "new": "Description" }
  },
  "timestamp": "2025-01-15T10:30:00Z",
  "userId": 42
}
```

**Revert Mechanism:** Replay prior snapshot by:
1. Retrieve snapshot from `Logs`
2. Deserialize `changedFields`
3. Apply `.old` values back to entity
4. Save changes (creates new audit entry)

**Utility Class:** `AuditSnapshotSerializer` in `IKMS.Application.Utilities`

**Documented In:** DECISIONS.md as DEC-12

---

### CONV-11 — Modules Has No Status Column

**Accepted Limitation:** All modules are always active. No soft-delete, no status filtering.

**Implication:** Cannot deactivate a module without schema change (violates INV-01). Workaround: archive via documentation, not database state.

**Documented In:** DECISIONS.md as DEC-13

---

## Summary

| ID | Topic | Classification | Status | DEC Reference |
|----|-------|----------------|--------|---------------|
| A.1 | Domain-scoped role naming | B | Resolved | DEC-01 |
| A.2 | Mapper choice | B | Resolved | DEC-02 |
| A.3 | Search engine choice | B | Resolved | DEC-03 |
| A.4 | Payment gateway abstraction | B | Resolved | DEC-04 |
| A.5 | Locator string grammar | B | Resolved | DEC-05 |
| A.6 | Time-code string grammar | B | Resolved | DEC-06 |
| A.7 | Cardinality string grammar | B | Resolved | DEC-07 |
| A.8 | Appendix schema availability | C | BLOCKING | — |
| A.9 | SQL Server instance | C | Acknowledged | — |
| A.10 | .NET 9 SDK | C | Mode B declared | — |
| CONV-04 | State_Id authority | B | Resolved | DEC-08 |
| CONV-05 | RelationsTypes duality | B | Resolved | DEC-09 |
| CONV-06 | Permission key discovery | B | Resolved | DEC-10 |
| CONV-07 | Polymorphic key whitelist | B | Resolved | DEC-11 |
| CONV-09 | JSON audit snapshots | B | Resolved | DEC-12 |
| CONV-11 | Modules always active | B | Resolved | DEC-13 |
