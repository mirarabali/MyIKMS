# IKMS — Project Understanding (Phase 0)

## 1. Product Vision (Restated)

IKMS (Integrated Knowledge Management System) is a comprehensive, multi-domain platform designed to manage the **entire lifecycle of structured knowledge** — from conceptual organization through content creation, review, publication, and retrieval. It is not merely a document repository but a sophisticated system that combines semantic knowledge organization (thesaurus, ontology, knowledge graphs), multi-audience content delivery (encyclopedia, glossary, dictionary), digital/physical resource management with access control, advanced indexing and search capabilities, scientific workflow with quality control, fine-grained access control (domain-scoped RBAC + ABAC), and multi-format reporting. The platform serves three distinct user groups: system administrators and subject-matter experts (via an admin panel), and end users (via a public portal) who search, browse, and access knowledge resources.

---

## 2. Seven Functional Layers (Key Entities Restated)

### Layer 1 — Semantic Knowledge Organization
| Entity | Purpose |
|--------|---------|
| **Domain** | Hierarchical subject areas (e.g., "Islamic Jurisprudence", "Information Science") with title, description, status |
| **Module** | Definable content/entity types (thesaurus, glossary, dictionary, encyclopedia, news, etc.) — hierarchical and extensible |
| **Term** | Base concept/entry with title, description, and lifecycle status |
| **KnowledgeNode** | The central linking entity connecting Term ↔ Module ↔ Domain, with "preferred term" flag and independent status |
| **RelationType** | Defines relationship types between entities with graph-theory properties (transitive, asymmetric, etc.) AND custom attribute definitions |
| **ModuleRelationType** | Junction table specifying which relation types are valid for each module |
| **RelationConstraint** | Validation rules for relations (cardinality limits, safe rule-based validation — no raw SQL) |
| **Relation** | Actual instances of relationships between KnowledgeNodes, including a Locator for position within resources |

### Layer 2 — Knowledge Content Production & Delivery
| Entity | Purpose |
|--------|---------|
| **ContentEntry** | Multilingual, multi-audience content attached to a KnowledgeNode (body text, audience level, language, source references, workflow status) |
| **Localization mechanism** | Entity-level i18n for titles, descriptions, and content (not just UI translation) |

### Layer 3 — Resources, Library, and Content Access
| Entity | Purpose |
|--------|---------|
| **Resource** (base + specialized types) | Books, articles, theses, videos, audio, images, websites with shared metadata (author, publisher, language, classification, barcode, location) |
| **ResourceContent** | Digital text content at volume/section/page/paragraph granularity — uses shared Locator value object |
| **File/Attachment** | Proper polymorphic association for files attached to News, Organizations, Projects, Resources, KnowledgeNodes, ResourceContent |
| **AccessPolicy** | Rules for limited preview (e.g., 3 pages) followed by paywall/membership requirement |
| **Loan** | Physical and digital lending tracking (dates, renewals, fees, status) |
| **Payment** | Payment records with amount, date, status (pending/completed/failed/refunded), method, transaction/invoice reference |

### Layer 4 — Indexing & Information Retrieval
| Entity | Purpose |
|--------|---------|
| **Hierarchical/Locator Index** | Maps terms to exact positions in resources (page, paragraph, verse, narration) using shared Locator |
| **Linear/Abstract Index** | Index phrases built from terms and connector words |
| **TimeBasedIndex** | For audio/video: maps terms to time ranges or points |
| **Search Engine** | Cross-field search with filters (status, domain, subject) and operators (starts-with, contains, exact-phrase) |

### Layer 5 — Scientific Workflow, Review & Quality Control
| Entity | Purpose |
|--------|---------|
| **State** | Reusable status values (draft, pending_review, approved, rejected, etc.) |
| **WorkflowDefinition** | Steps per project type/role, sequencing (previous/next), SLA duration, safe transition conditions (rule DSL, no raw SQL) |
| **ProjectType / Project / ProjectUser** | Work batch grouping and user assignment |
| **WorkflowInstance** | Tracks each ContentEntry/KnowledgeNode through workflow (state history, timestamps) |
| **Workbox** | Per-user queue of pending items with alerts and stage notes |
| **AuditTrail** | Full change history with categorized action types (create/edit/delete/login/logout/status-change), revert capability |

### Layer 6 — Users, Roles & Access Control
| Entity | Purpose |
|--------|---------|
| **Organization** | Hierarchical organizations (corporate/individual users) |
| **OrganizationUser** | User membership in organizations (with agent flag) |
| **Role / UserRole** | Role definitions and user-role assignments |
| **Permission** | Named, stable permissions (e.g., "Domains.Term.Create") auto-discovered at startup, manageable via admin panel |
| **Domain-Scope Assignment** | Domain scoping at role-assignment level (ABAC), checked in authorization policies |
| **News** | Implemented as a Module (not separate), reusing the same tagging mechanism as other content |
| **Theme/ThemeType** | Low-priority configurable UI pages scoped to Organization + Module (+ optional Domain) |

### Layer 7 — Reporting
| Output Type | Purpose |
|-------------|---------|
| **Tree Output** | Thesaurus/domain hierarchy visualization |
| **Graph Output** | Concept and relation network visualization |
| **Tabular Output** | Tabular data with Excel/PDF/CSV export |
| **Data Layer Design** | Optimized for recursive CTE queries (trees) and graph traversals |

---

## 3. Frontend Technology Choice & Justification

### Decision: **React** for both Admin Panel and Public Portal

### Technical Justification

| Criterion | React | Angular | Blazor |
|-----------|-------|---------|--------|
| **Learning Curve** | Moderate; widely adopted | Steep; comprehensive but complex | Low for .NET devs, but limited JS ecosystem |
| **Ecosystem** | Largest ecosystem, mature libraries (i18n, RTL, charts) | Comprehensive but heavier | Growing but smaller ecosystem |
| **RTL Support** | Excellent (styled-components, emotion, CSS-in-JS) | Good (built-in) | Limited (CSS workarounds needed) |
| **Performance** | Virtual DOM, fine-grained control | Change detection can be heavy | WebAssembly overhead for Blazor WASM |
| **Hiring/Community** | Largest developer pool | Strong enterprise adoption | Niche (.NET-focused) |
| **Jalali Calendar Libraries** | Multiple mature options (moment-jalaali, react-multi-date-picker) | Available but fewer options | Very limited |
| **Bundle Size** | Small core, tree-shakeable | Larger baseline | Large WASM payload |

### Architecture Decision
- **Admin Panel**: React + TypeScript + Vite + Material-UI (or Ant Design) with RTL support
- **Public Portal**: React + TypeScript + Vite + Tailwind CSS (for lighter weight, better SEO)
- **Shared**: Both use the same i18n framework (react-i18next), same Jalali calendar library, same RTL configuration

This choice is documented in `docs/DECISIONS.md`.

---

## 4. Phased Execution Plan (Concrete Deliverables)

### Phase 1 — Solution Skeleton & Setup
**Deliverables:**
- `/src/IKMS.Domain/` — Class library with `.csproj`
- `/src/IKMS.Application/` — Class library with `.csproj`
- `/src/IKMS.Infrastructure/` — Class library with `.csproj`
- `/src/IKMS.WebApi/` — Web API project with `.csproj`
- `/tests/IKMS.Domain.Tests/` — xUnit test project
- `/tests/IKMS.Application.Tests/` — xUnit test project
- `/tests/IKMS.WebApi.IntegrationTests/` — Integration test project
- `setup.ps1` / `setup.sh` — Package restore, EF migration, seed data scripts
- `appsettings.Example.json` — Configuration template
- `.gitignore` — Excluding `appsettings.Development.json`, `*.user`, `bin/`, `obj/`
- `README.md` — Prerequisites, setup instructions, run commands
- `docs/ERD.md` — Initial ERD skeleton (Mermaid)
- CI configuration (GitHub Actions or Azure DevOps pipeline YAML)

### Phase 2 — User/Organization/Role/Permission/Auth
**Deliverables:**
- **Domain Entities**: `User`, `Organization`, `OrganizationUser`, `Role`, `UserRole`, `Permission`, `Session`, `RefreshToken`, `AccessTokenBlacklist`, `LoginLockout`
- **Application Layer**: DTOs, Validators (FluentValidation), Mappers, Services (`IAuthService`, `IUserService`, `IOrganizationService`, `IRoleService`, `IPermissionService`)
- **Infrastructure**: DbContext with entities configured, Repositories, JWT service, Password hasher (BCrypt/Argon2)
- **WebApi**: Controllers (`AuthController`, `UsersController`, `OrganizationsController`, `RolesController`, `PermissionsController`), Middleware (global exception handler, request ID), Swagger config with JWT support
- **Endpoints**: `POST /api/auth/login`, `POST /api/auth/logout`, `POST /api/auth/refresh`, `POST /api/auth/register`, `GET /api/users`, `POST /api/users`, `PUT /api/users/{id}`, `DELETE /api/users/{id}`, `GET /api/organizations`, `POST /api/organizations`, `GET /api/roles`, `POST /api/roles`, `GET /api/permissions`
- **Tests**: Unit tests for password hashing, token generation/validation; Integration tests for login/logout/refresh flows; Lockout behavior tests

### Phase 3 — Domain, Module, Term, KnowledgeNode, RelationType, ModuleRelationType, RelationConstraint, Relation
**Deliverables:**
- **Domain Entities**: `Domain`, `Module`, `Term`, `KnowledgeNode`, `RelationType`, `ModuleRelationType`, `RelationConstraint`, `Relation`, `Locator` (value object)
- **Application Layer**: DTOs, Validators, Mappers, Services for each entity
- **Infrastructure**: DbContext configurations, Repositories
- **WebApi**: Controllers (`DomainsController`, `ModulesController`, `TermsController`, `KnowledgeNodesController`, `RelationTypesController`, `RelationsController`)
- **Endpoints**: CRUD for all entities, `POST /api/relations/validate` (constraint validation)
- **Tests**: Tree-building tests (recursive hierarchy), constraint validation tests, relation graph property tests

### Phase 4 — Multilingual/Multi-level ContentEntry + Workflow Link
**Deliverables:**
- **Domain Entities**: `ContentEntry`, `ContentEntryLocalization`, `AudienceLevel` (enum)
- **Application Layer**: DTOs, Validators, Mappers, `IContentEntryService` with localization handling
- **Infrastructure**: DbContext configurations, Repositories
- **WebApi**: `ContentEntriesController` with endpoints for CRUD, language-specific retrieval
- **Workflow Integration**: Draft state linking to Phase 5 workflow
- **Tests**: Localization tests (multiple languages per entry), audience filtering tests

### Phase 5 — Resource + File/Attachment + AccessPolicy + Loan + Payment
**Deliverables:**
- **Domain Entities**: `Resource` (base class), `Book`, `Article`, `Thesis`, `Video`, `Audio`, `Image`, `Website` (TPH or TPT), `ResourceContent`, `FileAttachment` (polymorphic), `AccessPolicy`, `Loan`, `Payment`
- **Application Layer**: DTOs, Validators, Mappers, Services (`IResourceService`, `ILoanService`, `IPaymentService`)
- **Infrastructure**: DbContext with proper polymorphic configuration, Repositories
- **WebApi**: `ResourcesController`, `LoansController`, `PaymentsController`
- **Endpoints**: Resource CRUD, file upload/download, loan lifecycle endpoints, payment processing
- **Tests**: Polymorphic file attachment tests, access policy enforcement tests, loan lifecycle tests

### Phase 6 — Indexing + Search
**Deliverables:**
- **Domain Entities**: `HierarchicalIndex`, `LinearIndex`, `TimeBasedIndex`
- **Application Layer**: `ISearchService`, `IIndexingService`
- **Infrastructure**: SQL Server Full-Text Search configuration OR Elasticsearch/OpenSearch integration
- **WebApi**: `SearchController` with query parameters for filters/operators
- **Tests**: Search result accuracy tests, filter combination tests

### Phase 7 — State/WorkflowDefinition/Project/ProjectType/Workbox/AuditTrail
**Deliverables:**
- **Domain Entities**: `State`, `WorkflowDefinition`, `ProjectType`, `Project`, `ProjectUser`, `WorkflowInstance`, `WorkboxItem`, `AuditTrailEntry`
- **Application Layer**: `IWorkflowService`, `IWorkboxService`, `IAuditService`
- **Infrastructure**: DbContext configurations, Repositories
- **WebApi**: `WorkflowsController`, `ProjectsController`, `WorkboxController`, `AuditController`
- **Endpoints**: Workflow definition CRUD, workflow instance transitions, workbox retrieval, audit log queries
- **Tests**: Full workflow traversal tests (approve/reject/revise), audit trail completeness tests, version revert tests

### Phase 8 — Reporting (Tree/Graph/Tabular + Export)
**Deliverables:**
- **Application Layer**: `IReportService` with methods for tree/graph/tabular output
- **WebApi**: `ReportsController` with export endpoints (Excel/PDF/CSV)
- **Infrastructure**: Report generation libraries (EPPlus, QuestPDF, CsvHelper)
- **Tests**: Report accuracy tests, export format tests

### Phase 9 — Admin Panel Frontend
**Deliverables:**
- `/src/IKMS.AdminPanel/` — React application
- Pages: Dashboard, Domain Management, Term Management, Content Entry Editor, Resource Manager, Workflow Manager, User/Role/Permission Manager, Reports Viewer
- Components: Reusable form components, data tables, tree views, graph visualizations
- i18n setup with Persian default, RTL layout, Jalali calendar integration
- **Tests**: Component unit tests, E2E smoke test for key admin journey

### Phase 10 — Public Portal Frontend
**Deliverables:**
- `/src/IKMS.PublicPortal/` — React application
- Pages: Home, Search Results, Content View, Resource Preview, Registration/Login, Loan Request, Payment
- Components: Search bar, content reader with preview limit, user registration forms
- i18n setup with Persian default, RTL layout, Jalali calendar integration
- **Tests**: Component unit tests, E2E smoke test for end-user journey (search → view → request access)

### Phase 11 — Security Hardening, Performance Tuning, Documentation, Sample Data, Full Regression
**Deliverables:**
- Security audit report, OWASP compliance checklist
- Performance benchmarks, index optimization report
- Complete `README.md` with step-by-step setup instructions
- Seed data script with sample Domains, Terms, ContentEntries, Resources, Users
- Final validation report mapping every requirement to code locations
- **All tests passing**, zero build warnings, clean CI/CD pipeline

---

## 5. Assumptions, Ambiguities, and Resolutions

| # | Ambiguity/Assumption | Resolution |
|---|---------------------|------------|
| 1 | **Module status**: The reference `Modules` table has no status column, unlike Domain/Term/KnowledgeNode. Should Module have a lifecycle status? | **Decision**: Add `Status` property to Module for consistency (Draft/Active/Deprecated). Documented in `docs/DECISIONS.md`. |
| 2 | **RelationType vs. Attribute-Type duality**: The legacy `RelationsTypes` table serves double duty as both relation definitions AND custom field/attribute definitions. Should these be split? | **Decision**: Keep unified but clarify with an `EntityType` discriminator enum (`RelationType` vs. `AttributeType`). This preserves flexibility while making intent explicit. Documented in `docs/DECISIONS.md`. |
| 3 | **Resource type extensibility**: Type-specific tables vs. EAV for custom fields per resource type. | **Decision**: Use Table-Per-Hierarchy (TPH) with discriminator column for main resource types, plus a separate `ResourceCustomField` table for truly dynamic custom fields. This balances performance with extensibility. Documented in `docs/DECISIONS.md`. |
| 4 | **Polymorphic File Attachments**: How to implement proper referential integrity for files attached to multiple entity types? | **Decision**: Use EF Core's Table-Per-Hierarchy pattern with a base `AttachmentOwner` abstract entity, and concrete owner entities reference their specific record. Alternatively, use separate foreign key columns (nullable) for each owner type — cleaner but requires schema changes per new owner type. Chose the latter for simplicity and explicit FK constraints. Documented in `docs/DECISIONS.md`. |
| 5 | **Search Engine Choice**: SQL Server Full-Text Search vs. Elasticsearch/OpenSearch. | **Decision**: Start with SQL Server Full-Text Search (reduces infrastructure complexity, no containers per requirements). Design the search interface to allow swapping to Elasticsearch later if needed. Documented in `docs/DECISIONS.md`. |
| 6 | **Safe Rule DSL for Constraints/Workflow Conditions**: What form should the safe validation DSL take? | **Decision**: Implement a predefined enum of rule types (`MinCardinality`, `MaxCardinality`, `RegexPattern`, `DateRange`, `RequiredRelatedEntity`) with JSON parameters, validated server-side. No expression evaluation, no raw SQL. Documented in `docs/DECISIONS.md`. |
| 7 | **Permission Registry Auto-Discovery**: How to auto-discover named permissions at startup? | **Decision**: Use assembly scanning for attributes like `[RequirePermission("Domains.Term.Create")]` on controller actions, sync to database on application startup. Documented in `docs/DECISIONS.md`. |
| 8 | **Date Storage**: All dates stored as UTC `datetime2` in database, converted to Jalali only at UI layer. | **Decision**: Confirmed. Use `DateTimeOffset` in .NET, store as UTC, convert to Jalali in frontend using libraries like `moment-jalaali` or `react-multi-date-picker`. |
| 9 | **Soft Delete Pattern**: All entities with `Deleted` column in legacy schema should use soft delete. | **Decision**: Implement global query filter in EF Core for soft-deleted entities, with explicit `IncludeDeleted()` method for admins. Add `DeletedAt` timestamp and `DeletedBy` user reference. |
| 10 | **Mapping Library Choice**: AutoMapper vs. Mapster. | **Decision**: Choose **Mapster** for better performance, simpler configuration, and compile-time safety. Documented in `docs/DECISIONS.md`. |

---

## 6. Architecture-Changing Questions

### Question 1: Multi-Tenancy by Organization

**Context**: In the reference schema, `ProjectType`, `NewsCategory`, and `Themes` are each hard-scoped to a single `OrganizationId`. This suggests per-organization data silos rather than shared data with organization as a categorization dimension.

**Question**: Does IKMS require **genuine multi-tenant data isolation by Organization** (where Organization A cannot see Organization B's data at the database/query level, similar to SaaS multi-tenancy), OR is Organization simply a categorization/filtering dimension within a single shared dataset (where cross-organization reporting and visibility is acceptable/expected)?

**Implications if Multi-Tenant**:
- Every query must include `OrganizationId` filter (global query filter in EF Core)
- Unique indexes may need to include `OrganizationId`
- Seed data must be organization-scoped
- Domain-scoped ABAC becomes more complex (domains may be org-specific or shared)
- Some entities (like Domains, Terms, Modules) might be shared across orgs, while others (Projects, News, Themes) are org-specific — requiring careful modeling

**Implications if Single-Tenant with Org Categorization**:
- Simpler queries, no mandatory org filter
- Easier cross-organization reporting
- Organization is just another foreign key for filtering/grouping

**My Recommendation**: Based on the product vision describing a platform serving multiple user types (general managers, institute managers, group managers, subject-matter experts), I suspect **single-tenant with org categorization** is sufficient, with some entities being org-specific (Projects, News, Themes) and others being global/shared (Domains, Terms, Modules, RelationTypes). However, this significantly affects the data model design, so I need explicit confirmation before proceeding with Phase 1.

---

### Question 2: Permission Granularity Scope

**Context**: The prompt mentions domain-scoped ABAC where domain scope is configurable at the user's role assignment level.

**Question**: Should the permission system also support **Organization-scoped permissions** (if multi-tenancy is confirmed), or is Organization filtering handled separately from the permission system?

**Example**: A user might have `Domains.Term.Edit` permission scoped to Domain X, but should they also be restricted to Organization Y? Or is Organization membership checked independently?

**My Recommendation**: Treat Organization membership as a separate check (user must be member of org to access org-scoped resources), while Domain scoping is part of the ABAC permission check. This keeps concerns separated. Confirm if this aligns with expectations.

---

### Question 3: Workflow Condition DSL Complexity

**Context**: Both `RelationConstraint` and `WorkflowDefinition` need safe validation rules (no raw SQL).

**Question**: Should the rule DSL support **compound conditions** (AND/OR logic), or only simple atomic rules? For example: "IF related entity count > 3 AND user role = Expert THEN allow transition."

**My Recommendation**: Start with **atomic rules only** (single condition per constraint/workflow step) for Phase 7. Compound logic can be added later if needed. This keeps implementation tractable. Confirm if this is acceptable.

---

## 7. Confirmation Request

I have read and understood the entire IKMS project brief, including:
- All 11 phases and their Definition-of-Done criteria
- The seven functional layers and their entities
- The reference schema (Appendix) and the 14 mandatory corrections (Section 9)
- All non-functional requirements (security, performance, observability, documentation)

Before I proceed to **Phase 1** (Solution Skeleton & Setup), I request your explicit approval of this `PROJECT_UNDERSTANDING.md` document and answers to the three architecture questions above, particularly:

1. **Multi-tenancy**: Is Organization-based multi-tenant data isolation required, or is Organization just a categorization dimension?
2. **Permission scoping**: Should Organization scoping be integrated into the permission system, or handled separately?
3. **Workflow DSL**: Is atomic-rule-only DSL acceptable for the initial implementation?

Please reply with **"approved"** or **"confirmed"** once you've reviewed this document, along with answers to the questions. Upon approval, I will proceed to Phase 1.
