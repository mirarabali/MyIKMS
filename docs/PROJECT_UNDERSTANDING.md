# IKMS Project Understanding

## 1. Vision Statement (in our own words)

IKMS is a **knowledge lifecycle platform** — not a document repository — that enables organizations to create, organize, review, and deliver structured knowledge content across multiple domains, languages, and audience levels. It transforms raw information into authoritative, multi-variant knowledge entries (glossary terms, encyclopedia articles, dictionary entries) through a formal workflow process, while managing access to both digital and physical resources (books, media) via a unified workflow engine. The system sits atop an existing, immutable SQL Server schema and exposes all business logic through a single backend API serving two frontends: an administrative panel for knowledge workers and a public portal for end users.

## 2. Seven Functional Layers & Key Entities

### L1 — Semantic Knowledge Organization
| Table | Purpose |
|-------|---------|
| `Domains` | Hierarchical knowledge domains (`Domain_Parent`, `Domain_StateId`) |
| `Modules` | Content/entity types (thesaurus, ontology, glossary, etc.) — always active |
| `Terms` | Canonical term titles/descriptions (`Term_StateId`) |
| `TMD` | Central graph node: Term × Module × Domain intersection (`TMD_IsPreferred`, `State_Id`) |
| `RelationsTypes` | Relation/attribute type definitions with graph-theory flags |
| `MRT` | Valid relation types per module |
| `RelationConstraints` | Cardinality + rule constraints on relations |
| `Relations` | Typed edges between TMD nodes (`First_TMDId`/`TermsRelation_TypeId`/`Second_TMDId`) |

### L2 — Content Production & Delivery
| Table | Purpose |
|-------|---------|
| `TMD` (variants) | Each language/audience combination is a separate TMD row |
| `Relations` | Links variants to canonical entry (typed edges like `Language:fa`, `Audience:Researcher`) |
| `DocContent` | Actual content body at volume/section/page/paragraph granularity (`DocContent_TMDId`) |

### L3 — Resources, Library & Access Control
| Table | Purpose |
|-------|---------|
| `TMD` (as Resource) | Books, articles, videos represented as TMD rows under Library module |
| `Relations` | Metadata edges: author, publisher, subject, tags, barcode, location |
| `Files` | Physical file storage (`File_TableName` + `File_TableRecordId` polymorphic) |
| `ProjectType`/`Process` | AccessPolicy & Loan workflows (Requested → Payment → Granted / Borrowed → Returned) |
| `Payments` | Payment records linked to projects; status derived from project step |
| `DocContent` | Limited preview enforcement (default 3 free pages) |

### L4 — Indexing & Retrieval
| Mechanism | Implementation |
|-----------|----------------|
| Locator index | Query over `DocContent` joined to `TMD`/`Terms` |
| Linear/abstract index | Composed from `Terms` + `Relations` with `RelationsType_ReverseTitle` |
| Time-based index | `Relations` edge with time-code payload (`00:12:30-00:14:00`) in `TermsRelation_Description` |
| Search | Cross-field search over `Terms`/`DocContent` with filters (status, domain, module, subject) |

### L5 — Workflow, Review & QC
| Table | Purpose |
|-------|---------|
| `States` | Possible workflow states |
| `Process` | Steps per project type (`Process_Next`/`Process_Previous`, `Process_Duration`) |
| `ProjectType` | Defines workflow templates (review, access, loan) |
| `Projects` | Active workflow instances (`Project_StartDate`/`Project_EndDate`) |
| `ProjectUsers` | Users assigned to projects |
| `TMDP` | Tracks TMD in workflow (`TMDP_StartDate`/`TMDP_EndDate`, state) |
| `Logs` | Audit trail with JSON snapshots (`Log_Activity`, `Log_TypeId`) |

### L6 — Users, Roles & Access Control
| Table | Purpose |
|-------|---------|
| `Users` | User accounts (`User_UserName`, `User_Password` hashed) |
| `Organizations` | Corporate entities |
| `OrganizationUsers` | Many-to-many link |
| `Roles` | Role definitions (domain-scoped via naming: `Term Editor — Jurisprudence`) |
| `UserRoles` | User-role assignments |
| `API`/`Permissions` | Permission registry synced from `[RequirePermission]` attributes |
| `AuthSessions`/`AuthRefreshTokens`/`AuthAccessTokenBlacklists`/`AuthLoginLockouts` | Token management & lockout |
| `News`/`NewsCategory`/`NewsRelNewsCategory`/`NewsRelTags` | News subsystem (standalone, not via TMD) |

### L7 — Reporting
| Output Type | Implementation |
|-------------|----------------|
| Tree | Recursive CTE over `Domains`/`Modules` |
| Graph | Traversal over `Relations`/`RelationsTypes` |
| Tabular | Query with filters/sorting/pagination + Excel/PDF/CSV export |

## 3. Frontend Stack Decision

**Admin Panel:** React 18 + TypeScript + Vite + MUI/Ant Design
**Public Portal:** Next.js (React) + TypeScript

**Justification:**
- **RTL/Persian ecosystem:** React has mature RTL support (`react-i18next`, `moment-jalaali`, `react-multi-date-picker`) essential for Persian UI and Jalali dates (INV-11, INV-12)
- **SEO requirement:** Public portal needs SSR for search engine visibility on entry/resource pages — Next.js provides this out of the box, while client-only SPAs do not
- **Dense interaction patterns:** Admin panel requires complex tree/graph/workflow screens best served by React's component ecosystem
- **Blazor rejected:** While same-language convenience is attractive, Blazor lacks the RTL/Jalali ecosystem maturity and has no built-in SEO story for the public portal

See `docs/DECISIONS.md` for full decision record.

## 4. Phases 1–11: Planned Deliverables

### Phase 1 — Skeleton, Scaffold & Gate Infrastructure
- Solution structure: `IKMS.Domain`, `IKMS.Application`, `IKMS.Infrastructure`, `IKMS.WebApi`
- `Directory.Build.props`: nullable enabled, warnings as errors
- EF Core DbContext scaffolded Database-First from existing SQL Server schema
- `setup.ps1`/`setup.sh`: package restore, connection string validation, seed execution
- `tools/verify.ps1`/`verify.sh`: gate runner (G1–G9 checks)
- `tools/scan-forbidden.*`: pattern scanner (TODO, FIXME, etc.)
- `tools/schema-guard.*`: migration guard + snapshot diff checker
- Coverage wiring (coverlet)
- `appsettings.Example.json`, `.env.example`
- README skeleton with prerequisites
- Mermaid ERD of existing schema
- `db/schema.snapshot.json`: authoritative schema snapshot

### Phase 2 — Identity, RBAC/ABAC & Auth
- Entity configurations: `Users`, `Organizations`, `OrganizationUsers`, `Roles`, `UserRoles`, `API`, `Permissions`
- Auth services: JWT issuance, refresh token rotation, session management, blacklist, lockout
- `AuthSessions`, `AuthRefreshTokens`, `AuthAccessTokenBlacklists`, `AuthLoginLockouts` integration
- `[RequirePermission]` attribute with startup sync (CONV-06)
- Argon2id password hashing into `User_Password`
- Rate limiting on auth endpoints
- Tests: login/logout flow, token rotation, lockout expiry, domain-scoped RBAC, permission sync

### Phase 3 — Graph Engine
- CRUD APIs: `Domains`, `Modules`, `Terms`, `TMD`, `RelationsTypes`, `MRT`, `RelationConstraints`, `Relations`
- Soft-delete implementation
- Pagination middleware
- Write-time validation: cycle detection, cardinality enforcement, graph flag checks (irreflexive, asymmetric, transitive, equivalence)
- Whitelisted rule parser for `SqlCondition` (INV-07)
- Preferred TMD enforcement per term/module/domain scope
- Tests: hierarchy cycles, cardinality violations, graph flag enforcement, malicious SQL rejection

### Phase 4 — Content Variants
- Variant creation API: link canonical TMD to language/audience variants via typed Relations
- `DocContent` CRUD at volume/section/page/paragraph granularity
- Draft submission creating `TMDP` workflow entry
- Fallback logic when variant absent
- Tests: multi-language variants, audience variants, fallback behavior, DocContent granularity, workflow entry creation

### Phase 5 — Library, Access & Loans
- Resource-as-TMD patterns (book, article, video, etc.)
- Metadata relations: author, publisher, subject, tag, classification, barcode
- `Files` upload with CONV-07 whitelist validation
- `ProjectType`/`Process` definitions: AccessPolicy (Requested→Payment→Granted), Loan (Requested→Approved→Borrowed→Returned)
- Payment linkage via `Payments` table; status derived from project step
- Preview limit enforcement (default 3 pages) server-side
- Concurrent loan request handling
- Tests: resource composition, file whitelist, access policy lifecycle, preview bypass attempt, loan lifecycle, payment status derivation, concurrent requests

### Phase 6 — Indexing & Search
- Locator index service (query over `DocContent` + `TMD`/`Terms`)
- Linear/abstract index composer (using `RelationsType_ReverseTitle`)
- Time-based index service (parsing CONV-02 time-code strings)
- Locator/time-code parser utility with round-trip tests
- Cross-field search with operators: starts-with, contains, exact-phrase
- Filters: status, domain, module, subject
- Persian text normalization (ی/ك, ZWNJ, diacritics)
- Search engine choice: SQL Server Full-Text Search vs Elasticsearch/OpenSearch (see DECISIONS.md)
- Tests: locator queries, abstract index composition, time-code parsing, search operators, filter combinations, Persian normalization

### Phase 7 — Workflow, Workbox & Audit
- `States`/`Process`/`ProjectType`/`Projects`/`ProjectUsers`/`TMDP` integration
- Workbox query: items where current Process step matches user's role
- Transition validation (no skipping steps)
- SLA tracking: items exceeding `Process_Duration` marked overdue
- Audit logging: JSON snapshots in `Logs.Log_Activity` with correct `Log_TypeId`
- Revert functionality: replay prior snapshot
- Whitelisted parser for `Process_Condition` (INV-07)
- Tests: full review workflow, reject/revise paths, workbox filtering, illegal transitions, SLA reporting, audit snapshots, revert operation

### Phase 8 — Reporting
- Tree report: recursive CTE over `Domains`/`Modules` with depth limit
- Graph report: traversal over `Relations`/`RelationsTypes` with cycle safety
- Tabular report: filters, sorting, pagination
- Export services: Excel, PDF, CSV with Persian RTL rendering
- Streaming for large reports (≥50k rows)
- Tests: tree correctness, graph traversal, tabular output, export file validity, streaming performance

### Phase 9 — Admin Panel (React + TypeScript + Vite)
- Authentication UI: login, logout
- Domain/Module/Term/TMD management screens
- Relation editor with graph visualization
- Content variant editor
- Library management interface
- Workbox view
- User/role management
- Report viewers
- Theme-aware shell
- RTL layout verification, Persian UI, Jalali date display
- i18n architecture: no hardcoded strings outside locale files
- Playwright E2E: full lifecycle (create→edit→relations→submit→approve)
- Tests: RTL/i18n, permission-based UI hiding, date display

### Phase 10 — Public Portal (Next.js + TypeScript)
- Search/browse interface
- Entry and resource detail pages
- Limited preview reader
- Individual and corporate registration flows
- Loan/access request forms
- Payment flow (mock gateway)
- News section (using `News` tables directly)
- SSR verification: meaningful HTML/meta without JS
- WCAG compliance: landmarks, contrast, keyboard navigation, lang/dir attributes
- Playwright E2E: anonymous search→preview limit→register→request access→pay→unlock
- Tests: SSR output, corporate registration, workbox integration, accessibility

### Phase 11 — Hardening, Docs, Seed & Final Regression
- Security review: HTTPS enforcement, CORS policy, ProblemDetails on all errors, OWASP checklist
- Performance tuning: indexes (INV-03 only), async optimization, optional Redis cache for thesaurus/domain tree
- Themes/ThemeTypes implementation (if green)
- Seed script: coherent demo dataset (domains, modules, terms, TMDs, relations, books with metadata, access/loan projects, users per role) — idempotent, rows only
- Complete documentation: README, ERD, DECISIONS, PROJECT_UNDERSTANDING, TRACEABILITY, PROGRESS
- Clean-machine walkthrough verification
- Full regression: all tests from phases 1–10 green
- Traceability matrix: 100% REQ-* coverage with real file/test references

## 5. Assumptions & Ambiguities

### A.1 — CONV-08: Domain-Scoped Role Naming Pattern
**Ambiguity:** How exactly should domain-scoped roles be named? What separator? What if role name or domain title contains the separator?
**Resolution (Level B):** Format: `"{RoleTitle} — {DomainTitle}"` using em-dash (U+2014) as separator. Both parts trimmed. When assigning a role to a user for a specific domain, the system looks up (or creates, if permitted) the role with this exact name. Parsing: split on last occurrence of `" — "` to extract role title and domain title. Documented in DECISIONS.md with parser utility class `DomainScopedRoleParser`.

### A.2 — Missing Appendix Schema
**Assumption:** The Appendix containing the full SQL Server schema definition will be provided. Until then, Phase 0 cannot complete `db/schema.snapshot.json` or the Mermaid ERD.
**Classification:** Level C blocker if not provided — cannot proceed with scaffold without knowing exact table/column names, types, and nullability.

### A.3 — SQL Server Availability
**Assumption:** A locally reachable SQL Server instance (Developer/Express/LocalDB) exists with the schema already applied. Connection string provided via `appsettings.Development.json` or `.env`.
**Classification:** Level C if unavailable — cannot execute gates G1/G2/G4/G8 without database.

### A.4 — .NET 9 SDK Availability
**Observation:** Current environment lacks .NET SDK. Required for build/test gates.
**Classification:** Level C blocker — cannot execute backend gates without .NET 9 SDK.

### A.5 — Mapper Choice
**Decision (Level B):** Using **AutoMapper** over Mapster. Justification: larger community, more extensive documentation, better integration with ASP.NET Core DI, sufficient performance for our use case. Profile classes organized by bounded context in `IKMS.Application.Mapping`. Documented in DECISIONS.md.

### A.6 — Search Engine Choice
**Decision (Level B):** Starting with **SQL Server Full-Text Search**. Justification: no new infrastructure required, respects INV-03 (indexes/catalogs only), adequate for Persian text with proper word breaker configuration. Can migrate to Elasticsearch/OpenSearch later if performance demands. Documented in DECISIONS.md with reversal path.

### A.7 — Payment Gateway Abstraction
**Decision (Level B):** Interface `IPaymentGateway` with methods `InitializePayment`, `VerifyPayment`, `Refund`. Mock implementation `MockPaymentGateway` for development/testing. Real gateway adapters (ZarinPal, IDPay, etc.) implemented separately. Documented in DECISIONS.md.

### A.8 — Locator String Grammar (CONV-01)
**Decision (Level B):** Formal grammar: `vol.{volume}/p.{page}/{locator}` where locator is one of `¶{paragraph}`, `sec.{section}`, or line `{line}`. Example: `vol.2/p.45/¶3` or `vol.1/p.12/sec.4` or `vol.3/p.78/12`. Parser utility: `LocatorStringParser` with validated round-trip tests. Documented in DECISIONS.md.

### A.9 — Time-Code String Grammar (CONV-02)
**Decision (Level B):** Format: `HH:mm:ss` for point, `HH:mm:ss-HH:mm:ss` for range. Hours can exceed 23 for long content. Parser utility: `TimeCodeStringParser` with validation. Stored in `Relations.TermsRelation_Description`. Documented in DECISIONS.md.

### A.10 — Cardinality String Grammar (CONV-03)
**Decision (Level B):** Accepted formats: `"0"`, `"3"`, `"*"`, `"0..3"`, `"1..*"`. Parser utility: `CardinalityStringParser` returning `(min, max)` tuple where max is -1 for unbounded. Documented in DECISIONS.md.

## 6. Level-C Questions — RESOLVED

**CQ-1: Missing Appendix Schema** — **RESOLVED** ✓
The schema was provided after initial Phase 0 work began. All 36 tables with 262 columns have been documented in `db/schema.snapshot.json`. Notable legacy names preserved per INV-01:
- `NewsCtegory_*` (misspelled "Category")
- `Oranization_Description` (misspelled "Organization")  
- `MinCardinallity`, `MaxCardinallity` (misspelled "Cardinality")
- `OrganizationUsers_isAgent` (lowercase 'i')
- `TermsRelation_*` (not "Relation")
- Both `TMD_StateId` AND `State_Id` on TMD table

**CQ-2: .NET 9 SDK Unavailable** — **RESOLVED** ✓
Operating in **Mode B (Chat-only)**. All code is complete and runnable, but gate verifications are labelled `STATIC ONLY (not executed)`. User must run verification commands locally.

---

## 7. Declaration of Operating Mode

**Current Mode: B (Chat-only)**

I cannot execute `dotnet` commands in this environment. Therefore:
- All gates will be labelled `Verification: STATIC ONLY (not executed)`
- I will produce complete, runnable file contents with exact paths
- The final report will list precise commands for the user to run for real verification
- I will NOT claim any build or test passed without actual execution

This complies with §8 and INV-06 (no fake green).
