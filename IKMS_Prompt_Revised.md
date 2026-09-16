## 0. Your Role in This Project

You are the lead architect and full-stack delivery team for this project. Your job is not just to write code — you must:

1. **First fully understand the whole project before writing a single line of code** (see Phase 0 below) and get my explicit sign-off on your plan.
2. Deliver the implementation **one phase at a time, in strict order** (Section 7). You may never start a phase before the previous one has been explicitly approved by me.
3. In every phase, the code you deliver must be **complete, precise, and free of bugs** — no stubs, no "TODO, implement later," no fake/hardcoded data pretending to be real logic, no known-broken pieces left for "later." If something cannot be finished properly within a phase, you must say so explicitly in that phase's report rather than silently shipping a half-working piece.
4. After finishing a phase: build it, test it, fix every error yourself, and only when it is **100% green and meets every Definition-of-Done item** do you report it to me and **stop and wait for my explicit confirmation** before starting the next phase. This is a hard rule — see Section 8.
5. Resolve ordinary ambiguous technical decisions yourself using current .NET/EF Core best practices, and document them in `docs/DECISIONS.md`. Only pause mid-phase to ask me a question if it is truly architecture-changing.
6. At the very end (after Phase 11 is approved), deliver a **final validation report**: build status, test status, how to run the whole stack with a single command (`docker-compose up`), and a checklist mapping every requirement in this prompt to the corresponding part of the codebase.

Never declare a phase — or the whole project — "done" while anything is half-finished, untested, or failing.

---

## 1. Product Vision

IKMS is a multi-domain platform for managing the **full lifecycle of structured knowledge** — not a simple document repository. The architecture must reflect the following seven functional layers (details in Section 4):

1. Semantic knowledge organization (thesaurus + ontology/knowledge graph + domains + configurable relations)
2. Knowledge content production and delivery (glossary/dictionary/knowledgebase/encyclopedia, multi-level per audience, multilingual)
3. Resources, library, and content access (physical + digital, type-driven metadata, access control/paywall, lending)
4. Indexing and information retrieval (hierarchical/locator index, linear/abstract index, time-based index for audio/video, cross-field search)
5. Scientific workflow, review, and quality control (states, approve/reject/revise process, workbox/queue, versioning and history)
6. Users, roles, and access control (domain-scoped RBAC + ABAC, organizations, individual/corporate users)
7. Reporting (tree, graph, and tabular output)

---

## 2. Scope of This Project

All three of the following must be built:

- **Backend / API**: complete and self-contained (the single source of truth for all business logic).
- **Admin/Editorial Panel**: for general managers, institute managers, group managers, and subject-matter experts — managing the thesaurus, content, resources, workflow/workbox, users, and reports.
- **Public User Portal**: search and browse the encyclopedia/glossary/library, view digital content with limited preview, register as an individual or corporate user, request loans/access, and pay.

---

## 3. Architecture & Technology Stack

### Backend (required)
- **.NET 8**, ASP.NET Core Web API
- **Clean Architecture**: `IKMS.Domain` / `IKMS.Application` / `IKMS.Infrastructure` / `IKMS.WebApi`
- **EF Core, Code-First** (design the model and migrations from scratch yourself; the attached reference schema is inspiration only — see Section 9)
- SQL Server as the primary database
- Authentication: JWT (short-lived access token) + rotating refresh token + session management + token blacklist on logout/revoke + account lockout after repeated failed login attempts
- Authorization: combined **domain-scoped RBAC + ABAC** (see Sections 4-6 and 9)
- Validation: FluentValidation
- Mapping: AutoMapper or Mapster (pick one and document the choice)
- API documentation: Swagger/OpenAPI + API versioning
- Structured logging: Serilog + a global exception-handling middleware returning ProblemDetails responses
- Health check endpoint

### Frontend
The frontend technology choice (Angular / React / Blazor, or a mix) is up to you; however:
- Document the technical justification for your choice in `docs/DECISIONS.md`.
- Both apps must default to **RTL layout and Persian language**, with an i18n architecture extensible to other languages.
- Display dates in the Jalali (Persian) calendar in the UI, while storing everything as UTC/Gregorian in the database.

### Infrastructure & Deployment (no containers)
- **Do not use Docker or any container technology.** The project must run directly on the local machine: .NET 8 SDK for the backend, Node.js for the frontends, and a locally installed/reachable SQL Server instance (Developer Edition, Express, or LocalDB).
- Provide a simple setup script (`setup.ps1` for Windows and `setup.sh` for macOS/Linux) at the repo root that restores packages, applies EF Core migrations against the configured connection string, and seeds sample data.
- The README must document, step by step, exactly how to install prerequisites (.NET 8 SDK, Node.js version, SQL Server) and how to run each part on a clean machine: the API via `dotnet run`, and each frontend app via its normal dev-server command (e.g., `npm start` / `ng serve` / `npm run dev`).
- All configuration (connection strings, JWT secret, etc.) goes through `appsettings.Development.json` / `.env` files that are git-ignored, with `appsettings.Example.json` / `.env.example` templates checked into the repo so setup is copy-and-fill.
- Seed sample data (Domains, Terms, a few encyclopedia entries, a few library resources, sample users with different roles) for quick manual testing.

### Testing
- xUnit for unit tests of the Domain/Application layers.
- Integration tests for the API (SQLite in-memory or Testcontainers against real SQL Server).
- At least one smoke E2E scenario for the key user journeys of each frontend app.

---

## 4. Data Model & Domain Layers (Functional Requirements)

> Treat the reference schema (`docs/reference/LEGACY_SCHEMA.sql`) only as a way to understand the concepts and relationships; design the table structure, naming, data types, and keys **fresh and optimized** (Code-First). A per-table business-purpose guide (`docs/reference/TABLE_GUIDE.md`: table → purpose → related tables) is also provided; use it the same way — as conceptual grounding for what each legacy table was trying to accomplish and how the old tables relate to each other conceptually (including relationships that were never enforced as real foreign keys) — never as a literal target structure. Where the guide reveals intent that isn't obvious from column names alone, that intent is called out explicitly below.

### Layer 1 — Semantic Knowledge Organization
- **Domain**: hierarchical (self-referencing), title, description, status.
- **Module** (a definable content/entity type: thesaurus, glossary, dictionary, knowledgebase, encyclopedia, news, ...): hierarchical and extensible. Unlike Domain/Term/KnowledgeNode, the reference `Modules` table has no status column of its own — decide and document in `DECISIONS.md` whether Module should carry a lifecycle status (draft/active/deprecated) for consistency with the other core entities.
- **Term**: title, description, status.
- **KnowledgeNode** (an improved equivalent of the old TMD): links Term↔Module↔Domain with a "preferred term" flag and a status independent of the Term itself.
- **RelationType**: hierarchical, title/reverse title, and graph-theory properties: `IsHierarchical`, `IsTransitive`, `IsAsymmetric`, `IsEquivalence`, `IsIrreflexive`, `IsSystemDefined`. In the reference schema this same table (`RelationsTypes`) is deliberately overloaded to also describe **custom attributes/fields** on entities (an `IsNodeLabel` flag for "shown as a node label in the UI" and a self-referencing `DataTypeId` for "this row's value type"), not only relations between two KnowledgeNodes — e.g. an "authorship" relation between a Book-type KnowledgeNode and a Person-type KnowledgeNode uses the same table as a plain "ISBN" custom field. Decide explicitly whether the new design keeps this as one generalized Relation/Attribute-Type concept or splits it into two distinct entities, and document the decision and its trade-offs in `docs/DECISIONS.md` — this choice affects how Layer 3's "extensible custom fields per resource type" is implemented.
- **ModuleRelationType**: which relation types are valid for which module.
- **RelationConstraint**: cardinality limits (min/max source↔target, both directions), a minimum/maximum length constraint (for attribute-style relation types), error severity, and a validation pattern. **Instead of executing raw SQL** (the old `SqlCondition` field), design a safe validation mechanism (a predefined rule enum with parameters, or a small safe DSL — never arbitrary SQL execution).
- **Relation**: source, type, target, priority, level, description, **Locator** (exact position within a resource, e.g., page/paragraph/verse/narration). Design this Locator as a shared value object so it can be reused wherever a "position within a resource" needs to be recorded — see the Layer 3/Layer 4 note below.

### Layer 2 — Knowledge Content Production & Delivery
- **ContentEntry**: one per KnowledgeNode, with `AudienceLevel` (teen/young adult/adult/researcher), language, body text, source/reference, workflow status.
- Multilingual support must be **entity-level** (title/description/content), not just UI translation. Design a generic i18n mechanism.

### Layer 3 — Resources, Library, and Content Access
- **Resource** base type + specialized types (book, article, thesis, video, audio, image, website, ...) with shared metadata (author, publisher, language, subject, tags, classification, location, barcode).
- **ResourceContent** (equivalent of the old `DocContent`): the digital resource's own text, stored at volume/section/page/paragraph granularity and linked to the owning Resource. Because this is exactly the same kind of "position within a resource" that Layer 1's Relation.Locator and Layer 4's hierarchical/locator index need, reuse a single shared locator representation across all three rather than inventing separate position models.
- Custom fields per resource type must be **extensible**; decide between type-specific tables (preferred) or EAV, and document the reasoning. This decision should be consistent with how you resolved the RelationType/custom-attribute question in Layer 1.
- **File/Attachment**: instead of the weak polymorphic pattern from the old schema (`TableName + RecordId` string, no referential integrity), implement a proper polymorphic pattern in EF Core. In the reference system, attachable owners include at least: News items, Organization logos, Projects, Resources/KnowledgeNodes, and ResourceContent — make sure the new polymorphic design covers this same breadth of owner types, not just Resources.
- **AccessPolicy**: limited preview (e.g., up to 3 pages) followed by a membership/payment requirement for digital content.
- **Loan** (physical and digital lending): dates, renewal, fees, status.
- **Payment/Subscription**: linked to organizational/individual users and their access scope, and optionally to the project/workflow context that produced the charge. The reference `Payments` table only stores an amount — it is missing a payment date, a payment status (e.g. pending/completed/failed/refunded), a payment method, and a transaction/invoice reference; the new design must include all of these.

### Layer 4 — Indexing & Information Retrieval
- **Hierarchical/locator index**: term ↔ exact position in a resource (page, paragraph, end of book, verse, narration, named entity, subject). This locator granularity should be the same shared value object used by ResourceContent (Layer 3) and by Relation.Locator (Layer 1), so a single "position within a resource" concept is indexed, related, and displayed consistently everywhere it appears.
- **Linear/abstract index**: an index phrase built from terms and connector words.
- **Time-based index**: for audio/video, term ↔ time range or point.
- **Search**: cross-field, with status/domain/subject filters, and operators (starts-with, contains, exact-phrase). Use SQL Server Full-Text Search or an external engine (Elasticsearch/OpenSearch) — justify your choice.

### Layer 5 — Scientific Workflow, Review & Quality Control
- **State** and **WorkflowDefinition** (improved equivalent of the old Process table): steps per project type/role, sequencing (previous/next step), SLA duration, and a pass/transition condition. The old `Process.Process_Condition` column is free text in the same spirit as `RelationConstraints.SqlCondition` — apply the same rule to it: never evaluate it as raw SQL or arbitrary code, express it with the same safe rule/DSL mechanism designed for RelationConstraint (correction #2 in Section 9).
- **ProjectType / Project / ProjectUser**: grouping of work batches and user assignment. In the reference schema `ProjectType` (and, transitively, `Process`) is scoped to a single Organization — see the Layer 6 note on organization scoping before finalizing this design.
- **WorkflowInstance** (equivalent of the old TMDP): tracks each KnowledgeNode/ContentEntry through the workflow, including its state and the time window it occupied that state.
- **Workbox**: a per-user queue of pending items, with alerts for new items and per-stage notes.
- **AuditTrail/VersionHistory** (improved equivalent of the old Logs table): full change history with revert capability. The old `Logs` table categorizes every entry through a separate `LogType` table (create/edit/delete/login/logout/status-change, etc.) rather than a free-text description alone — keep a similar categorized action-type enum/lookup in the new AuditTrail design rather than relying only on free text.
- Core review actions: approve, reject, revise.

### Layer 6 — Users, Roles & Access Control
- **Organization** (hierarchical) and **OrganizationUser** (individual/corporate user, agent flag). In the reference schema, `ProjectType`, `NewsCategory`, and `Themes` each hang directly off a single Organization, which implies the legacy system leaned toward per-organization data siloing rather than pure categorization within one shared dataset. Decide and document explicitly in `DECISIONS.md` whether IKMS needs genuine multi-tenant data isolation by Organization (separate from the already-required domain-scoped RBAC/ABAC) or whether Organization is just one more categorization dimension — this is exactly the kind of decision to surface as an architecture question in Phase 0 if it changes how Section 4 entities are modeled.
- **Role / UserRole**.
- **Advanced permission model**: instead of raw strings (`ControllerName/URL/ActionType`), design a registry of stable, named permissions (e.g., `[RequirePermission("Domains.Term.Create")]`) auto-discovered and synced into the database at startup, manageable from the admin panel.
- **Domain-scoped ABAC**: domain scope must be configurable **at the level of the user's role assignment**, not just the role, and checked in the Authorization Policy.
- Permitted operations must at minimum include create, edit, soft-delete, and route-to-workbox.
- Implement News as just another `Module` on the same content/tagging engine: reuse the same term-tagging relation used elsewhere (the old schema links News ↔ Terms as tags, and News ↔ NewsCategory as a category) rather than inventing a parallel tagging mechanism just for News.
- "Themes/ThemeTypes" is low priority; implement last, only if time permits. Conceptually this is a configurable-UI-page mechanism: each Theme is a named, storable UI definition scoped to an Organization + Module (and optionally a Domain), and ThemeType says what kind of page it is (home page, search-results page, single-content view, list page, detail page, etc.). If you do implement it, keep this "page template registry" intent rather than repurposing the tables for something else.

### Layer 7 — Reporting
- Tree output (thesaurus/domain tree)
- Graph output (concept and relation graph)
- Tabular output with Excel/PDF/CSV export
- Design the data layer so recursive-CTE tree queries and graph queries are efficient from the start.

---

## 5. Non-Functional Requirements

- **Security**: OWASP ASP.NET Core best practices; hash passwords with Argon2/BCrypt; full input validation; rate limiting on auth endpoints; clear CORS policy; enforce HTTPS; secrets only via configuration/environment variables, never hardcoded.
- **Performance**: pagination everywhere, proper indexing, async/await throughout, optional Redis caching for the frequently-read thesaurus/domain tree.
- **Observability**: health checks, structured logging with a request ID for tracing.
- **Documentation**: complete README, ERD (Mermaid in `docs/`), `docs/DECISIONS.md`, Swagger for the API.
- **Accessibility**: basic WCAG principles on the public portal.

---

## 6. Suggested Repository Structure

```
/src
  /IKMS.Domain
  /IKMS.Application
  /IKMS.Infrastructure
  /IKMS.WebApi
  /IKMS.AdminPanel      (admin panel frontend)
  /IKMS.PublicPortal    (public portal frontend)
/tests
  /IKMS.Domain.Tests
  /IKMS.Application.Tests
  /IKMS.WebApi.IntegrationTests
/docs
  PROJECT_UNDERSTANDING.md   (produced in Phase 0, before any code)
  DECISIONS.md
  ERD.md
  PROGRESS.md
  /reference
    LEGACY_SCHEMA.sql        (old system's schema — inspiration only, see Section 9)
    TABLE_GUIDE.md           (per-table business-purpose guide for the legacy schema, in Persian)
setup.ps1
setup.sh
README.md
```

---

## 7. Phased Execution Plan (mandatory — strict order, one phase at a time, explicit approval required between every phase)

**Rule: after finishing any phase, STOP. Report it. Wait for my explicit "approved/confirmed" reply. Do not start the next phase until you receive it.** Full detail on what the report must contain is in Section 8.

| Phase | Content | Definition of Done |
|---|---|---|
| 0 | **Comprehension & Planning — no code.** Read this entire prompt, `docs/reference/LEGACY_SCHEMA.sql`, and `docs/reference/TABLE_GUIDE.md` end to end. Produce `docs/PROJECT_UNDERSTANDING.md` (see contents below). | I have reviewed and explicitly approved `PROJECT_UNDERSTANDING.md` |
| 1 | Solution skeleton, `setup.ps1`/`setup.sh`, connection to a local SQL Server instance, initial CI | Empty solution builds; `setup` script runs cleanly and connects to the configured local SQL Server |
| 2 | User/Organization/Role/Permission/Auth (JWT+Refresh+Session+Blacklist+Lockout) | All auth endpoints tested and green via Swagger; unit/integration tests pass |
| 3 | Domain, Module, Term, KnowledgeNode, RelationType, ModuleRelationType, RelationConstraint, Relation | Build a domain hierarchy, define terms, define relation types with graph properties, create relations validated against constraints — all tested |
| 4 | Multilingual/multi-level ContentEntry + link to draft workflow | Create/edit/submit a content entry in multiple languages and audience levels |
| 5 | Resource (all types) + File/Attachment + AccessPolicy + Loan + Payment | Add a resource of each type, upload a file, apply the 3-page-preview + paywall rule, simulate a full loan lifecycle |
| 6 | Indexing (locator/linear/time-based) + Search | Index a resource; search with status/domain/field filters returns correct results |
| 7 | State/WorkflowDefinition/Project/ProjectType/Workbox/AuditTrail | An entry moves through the full workflow (approve/reject/revise); full logging recorded; revert to a previous version works |
| 8 | Reporting (tree/graph/tabular + export) | At least 3 report types with Excel/PDF export |
| 9 | Admin panel frontend | The full lifecycle of work is possible for an expert/manager from the UI |
| 10 | Public portal frontend | End-user journeys (search, read, register, request a loan) work from the UI |
| 11 | Security hardening, performance tuning, complete documentation, sample data, full regression pass | Build succeeds with zero errors/warnings, all tests are green, and following the README's setup steps on a clean machine (running `setup.ps1`/`setup.sh` and then the normal `dotnet run` / dev-server commands) brings up the whole system successfully |

### Contents required in `docs/PROJECT_UNDERSTANDING.md` (Phase 0 deliverable)

1. A one-paragraph restatement, in your own words, of the product vision.
2. The seven functional layers and their key entities, restated to confirm you understood them correctly.
3. Your chosen frontend stack for the Admin Panel and the Public Portal, with justification.
4. The full phase list (1–11) with, for each phase, the concrete deliverables you plan to produce (specific files/classes/endpoints/screens) — not just the Definition of Done copied from this prompt.
5. An explicit list of every assumption, ambiguity, or interpretation you made while reading this prompt, and how you resolved each one.
6. Any question that is genuinely architecture-changing — ask it here, before Phase 1 starts, rather than discovering it mid-implementation. (For example: is Organization-scoped multi-tenant data isolation required, or is Organization just a categorization field? See the Layer 6 note in Section 4.)

Do not create any project file, run `dotnet new`, or write any code until I have explicitly approved this document.

---

## 8. Iteration, Confirmation Gates & Self-Correction

### Per-phase quality bar (all of these must be true before a phase can be reported as finished)
- `dotnet build` succeeds with **zero errors and zero warnings**.
- `dotnet test` (and the frontend test suite, once relevant) passes **100%** — zero failing or skipped tests.
- Every single Definition-of-Done bullet for that phase (Section 7) is verifiably met — not "mostly," not "works except for X."
- No leftover `TODO` comments, stub methods, placeholder/fake data pretending to be real logic, or commented-out broken code anywhere in the phase's deliverable.
- Every piece of new business logic added in the phase has a real, passing automated test exercising it — not just code that compiles.
- If something genuinely could not be finished to this bar within the phase, you must say so explicitly and clearly in the phase report rather than omit or gloss over it.

### The confirmation gate (hard rule)
1. When a phase meets the bar above, write a **Phase Completion Report** as your reply, containing:
   - What was built: the concrete list of new files/classes/endpoints/screens.
   - Exact commands I can run myself to verify it (build/run/test commands, example requests via curl or Swagger, URLs to open).
   - A confirmation line in this exact shape: `Build: 0 errors. Tests: X/X passing. Definition of Done: all criteria met.`
   - Any known limitation or deferred item, stated explicitly.
2. Update `docs/PROGRESS.md` with the same summary.
3. **Then stop. Do not start the next phase.** Wait for my explicit confirmation (e.g., "approved," "confirmed," "proceed," "OK," "تایید").
4. If I ask for changes instead, apply them, re-run build/tests until green again, and send an updated Phase Completion Report before asking for confirmation again.
5. If you hit a genuinely architecture-changing ambiguity mid-phase, ask **one short, specific question** as part of your update and wait — do not guess your way past it.

This confirmation gate applies to **every phase from 0 through 11, with no exceptions.**

---

## 9. Corrections to Make Relative to the Reference Schema (mandatory)

The reference schema (`docs/reference/LEGACY_SCHEMA.sql`) is inspiration only; the following issues must be **fixed** in the new design, not repeated:

1. The string-based polymorphic pattern (`Files.File_TableName` + `File_TableRecordId`, `Logs.Log_TableName` + `Log_TableRecordId`) has no referential integrity — replace it with real foreign keys or a proper EF Core polymorphic pattern.
2. The `SqlCondition` column in `RelationConstraints` implies executing raw SQL — a serious security risk; replace it with a predefined, safe rule/DSL.
3. The permission model depends directly on `API_ControllerName/URL/ActionType` — it breaks on every refactor; replace it with stable, named permissions (see Section 4-6).
4. Ambiguous/duplicate columns such as both `TMD_StateId` and `State_Id` existing on the same table must be unique and unambiguous in the new design.
5. Short text field lengths (e.g., `nvarchar(50)` for a domain title) should be reviewed against real needs.
6. Be consistent about date types (`datetime` vs `datetime2`) and store everything in UTC.
7. Fix inconsistent/misspelled naming (e.g., `NewsCtegory`) in the new design.
8. Ensure user passwords are never stored in plain text — always a secure hash.
9. Add indexes and unique constraints on key business fields (e.g., username, domain/module code) that were missing in the reference schema.
10. The `Payments` table stores only an amount, with no payment date, payment status, payment method, or transaction/invoice reference — add all of these to the new Payment entity (see Layer 3).
11. The `Process.Process_Condition` free-text column carries the same raw-execution risk as `RelationConstraints.SqlCondition` — apply the same safe rule/DSL replacement to it, not just to relation constraints (see Layer 5).
12. `RelationsTypes` conflates two concepts — an actual relation between two KnowledgeNodes, and a custom attribute/field definition with a data type — via the `IsNodeLabel` flag and the self-referencing `DataTypeId`. Decide explicitly whether the new design keeps one generalized concept or splits it into two, and document the reasoning (see Layer 1).
13. Several entities (`ProjectType`, `NewsCategory`, `Themes`) are hard-scoped to a single Organization in the reference schema, implying organization-level data siloing that was never made explicit as a system-wide design decision. Decide and document whether IKMS requires true multi-tenant isolation by Organization, independent of domain-scoped RBAC/ABAC (see Layer 6).
14. `Modules` has no status/lifecycle column, unlike `Domains`, `Terms`, `TMD`, `Process`, and `TMDP`, which each have one. Decide and document whether the new Module entity should carry a status for consistency (see Layer 1).

---

## 10. Expected Final Deliverable

A complete, runnable repository — running natively on the local machine with no containers, via the `setup` script plus standard `dotnet run` / dev-server commands — consisting of Backend + Admin Panel + Public Portal, with a Code-First database designed from scratch, green tests, complete documentation (README, ERD, DECISIONS, PROJECT_UNDERSTANDING, PROGRESS), seeded sample data for demos, and a final validation report as described in Section 8 — built strictly phase by phase, with my explicit approval obtained after every single phase.
