# IKMS Technical Decisions

This document records key architectural and technical decisions made during the IKMS project.

---

## Decision 001: Frontend Technology Stack

**Date:** Phase 0  
**Status:** Accepted  
**Context:** Selecting frontend frameworks for Admin Panel and Public Portal.

### Options Considered
1. **Blazor Server/WASM** - Same-language convenience with C# backend
2. **React SPA + Next.js** - Modern JavaScript ecosystem
3. **Angular** - Full-featured framework
4. **Vue.js** - Lightweight alternative

### Decision
- **Admin Panel:** React 18 + TypeScript + Vite + Material UI (or Ant Design)
- **Public Portal:** Next.js (React) + TypeScript

### Rationale
1. **RTL/Persian Ecosystem:** React has the most mature RTL and Persian i18n libraries (`react-i18next`, `moment-jalaali`, `react-multi-date-picker`). Blazor's ecosystem is thin for these requirements.
2. **SEO Requirements:** Public Portal needs server-side rendering for search engine optimization. Next.js provides this out of the box; client-side-only React does not.
3. **Component Reusability:** Both apps can share components, i18n setup, and RTL configuration while using the appropriate rendering strategy for their use case.
4. **Developer Ecosystem:** Larger talent pool, more libraries, better long-term maintainability.

### Consequences
- Two separate frontend codebases to maintain (mitigated by shared component libraries)
- Node.js required as a prerequisite alongside .NET SDK
- No Docker containers; direct local execution via `npm run dev`

---

## Decision 002: TMD Status Column Handling

**Date:** Phase 0  
**Status:** Accepted  
**Context:** The `TMD` table has two status columns: `TMD_StateId` and `State_Id`.

### Decision
- **`State_Id` is authoritative** for all business logic
- **Never write to `TMD_StateId`** from new application code
- Read operations use only `State_Id`

### Rationale
- Legacy schema artifact; `State_Id` was added later as the correct foreign key to `States`
- `TMD_StateId` is deprecated but cannot be removed (immutable schema rule)
- Single source of truth prevents inconsistency

### Consequences
- All TMD status checks reference `State_Id`
- Documentation must clarify this for future maintainers

---

## Decision 003: Domain-Scoped RBAC Implementation

**Date:** Phase 0  
**Status:** Accepted  
**Context:** `UserRoles` table has no domain column, but Layer 6 requires domain-scoped permissions.

### Decision
Implement **domain-scoped roles** as distinct `Roles` rows:
- Example: "Term Editor — Jurisprudence" and "Term Editor — Management" are separate roles in the `Roles` table
- Domain filter attached to role definition, not individual assignment
- Role naming convention: `"{Permission} — {Domain}"`

### Rationale
- Cannot add a `DomainId` column to `UserRoles` (immutable schema)
- Clean separation of concerns at the role definition level
- Simpler authorization checks in application code

### Consequences
- More rows in `Roles` table (acceptable trade-off)
- Role management UI must support domain selection when creating roles
- Permission keys remain stable; domain scoping is semantic

---

## Decision 004: RelationsTypes Dual Role Pattern

**Date:** Phase 0  
**Status:** Accepted  
**Context:** `RelationsTypes` serves both as semantic relations (e.g., "Author") and attribute types (via `IsNodeLabel`/`DataTypeId`).

### Decision
- **Embrace the duality** as the core mechanism for metadata (Layer 3)
- **No discriminator column** added
- Infer role from `RelationsType_DataTypeId`:
  - If `NULL` → Semantic relation between two TMD nodes
  - If set → Attribute/scalar field type

### Rationale
- Schema is immutable; cannot restructure
- This pattern enables the "everything is a graph node" architecture
- Documented convention, not a defect

### Consequences
- Application layer must check `IsNodeLabel` and `DataTypeId` to interpret relation types correctly
- Metadata like author, publisher, barcode, classification all stored as typed Relations edges
- Requires clear documentation and team training

---

## Decision 005: SqlCondition and Process_Condition Safety

**Date:** Phase 0  
**Status:** Accepted  
**Context:** `RelationConstraints.SqlCondition` and `Process.Process_Condition` contain raw strings that could be security risks if executed.

### Decision
- **Never evaluate as executable SQL or arbitrary code**
- Implement a **fixed, whitelisted rule parser** in the Application layer
- Only predefined operators and patterns are recognized:
  - Cardinality parsing from `MinCardinallity`/`MaxCardinallity` (e.g., `"0..3"`)
  - Simple boolean conditions on known fields
  - State transition validation

### Rationale
- Security: Prevents SQL injection and arbitrary code execution
- Maintainability: Centralized, testable validation logic
- Auditability: Clear rules visible in code

### Consequences
- Limited expressiveness compared to raw SQL (acceptable for security)
- Parser must be extended carefully with each new requirement
- All parser logic covered by unit tests

---

## Decision 006: Files and Logs Referential Integrity

**Date:** Phase 0  
**Status:** Accepted  
**Context:** `Files.File_TableName`/`File_TableRecordId` and `Logs.Log_TableName`/`Log_TableRecordId` use string-based references without real foreign keys.

### Decision
- **Code-level whitelist** of valid `TableName` values enforced on every write
- Whitelist defined as a static configuration in Application layer
- Covered by integration tests
- Valid tables include: `TMD`, `Terms`, `News`, `Domains`, `Modules`, etc.

### Rationale
- Cannot add proper FK constraints (immutable schema)
- Prevents orphaned file/log records
- Clear error messages on invalid references

### Consequences
- Whitelist must be updated when new entity types are introduced
- Tests verify whitelist enforcement
- Some runtime risk remains (mitigated by testing)

---

## Decision 007: Permission Key Storage

**Date:** Phase 0  
**Status:** Accepted  
**Context:** `API_ControllerName` column stores what was originally controller names, but we need stable permission keys.

### Decision
- Store **stable permission keys** in `API_ControllerName` (e.g., `"Domains.Term.Create"`)
- Format: `"{Aggregate}.{Entity}.{Operation}"`
- Auto-discover `[RequirePermission("...")]` attributes at startup
- Sync discovered permissions into `API`/`Permissions` tables on application startup

### Rationale
- Human-readable, stable identifiers independent of URL/controller structure
- Easy to audit and assign to roles
- Supports fine-grained authorization

### Consequences
- Existing `API` data may need migration (seed script handles this)
- Permission keys documented in API documentation
- Startup sync ensures database matches code

---

## Decision 008: Password Hashing

**Date:** Phase 0  
**Status:** Accepted  
**Context:** `User_Password nvarchar(255)` currently stores plain text or weak hashes.

### Decision
- Use **BCrypt** (or Argon2 if BCrypt unavailable) for password hashing
- Hash generated passwords before writing to `User_Password`
- Salt automatically included in BCrypt hash format
- Minimum cost factor: 12

### Rationale
- OWASP recommendation for password storage
- BCrypt widely supported in .NET (NuGet: `BCrypt.Net-Next`)
- Fits within existing `nvarchar(255)` column (BCrypt hashes are ~60 chars)

### Consequences
- Existing passwords must be reset or migrated (handled in seed data)
- Login endpoint verifies hash instead of plain text
- Password reset flow implemented securely

---

## Decision 009: Modules Status Handling

**Date:** Phase 0  
**Status:** Accepted  
**Context:** `Modules` table has no `Module_StateId` or similar status column.

### Decision
- **Treat all Modules as always-active**
- No soft-delete or status filtering on Module queries
- Accept as a documented limitation

### Rationale
- Cannot add status column (immutable schema)
- Modules are foundational; deletion would cascade destructively
- Soft-delete handled at child entity level (TMD, Terms, etc.)

### Consequences
- Modules cannot be deactivated without schema change
- Application assumes all Modules are valid
- Documented in `PROJECT_UNDERSTANDING.md`

---

## Decision 010: Search Engine Selection

**Date:** Phase 0 (provisional)  
**Status:** TBD after Phase 6 analysis  
**Context:** Layer 4 requires cross-field search with filters.

### Options
1. **SQL Server Full-Text Search (FTS)** - Built-in, no extra infrastructure
2. **Elasticsearch/OpenSearch** - More powerful, external dependency

### Preliminary Decision
- Start with **SQL Server FTS** for simplicity (no containers, local execution requirement)
- Evaluate performance in Phase 6
- Document migration path to Elasticsearch if needed

### Rationale
- Project requires no-container local execution
- FTS sufficient for initial requirements (prefix, contains, exact phrase)
- Lower operational complexity

### Consequences
- May need to revisit if scale/performance demands exceed FTS capabilities
- Indexes added to `Terms`, `DocContent`, `TMD` for FTS

---

## Decision 011: Mapping Library

**Date:** Phase 1  
**Status:** Pending  
**Context:** Need AutoMapper or Mapster for DTO ↔ Entity mapping.

### Preliminary Decision
- **Mapster** (lighter weight, faster, simpler API)
- Alternative: AutoMapper if complex configurations needed

### Rationale
- Mapster has better performance benchmarks
- Simpler configuration syntax
- Active maintenance

---

## Decision 012: Date Display Localization

**Date:** Phase 0  
**Status:** Accepted  
**Context:** Database stores UTC/Gregorian dates; UI must show Jalali (Persian) calendar.

### Decision
- **Database:** Always store `datetime2` as UTC
- **Backend:** Return UTC timestamps in API responses
- **Frontend:** Convert to Jalali calendar using `moment-jalaali` or `react-multi-date-picker`
- User locale preference stored in user profile (future enhancement)

### Rationale
- Single source of truth (UTC) prevents timezone confusion
- Frontend conversion allows per-user localization
- Libraries mature and well-maintained

### Consequences
- All date displays go through localization layer
- Tests verify UTC storage
- Future: user-specific timezone/locale settings

---

*Last updated: Phase 0*
