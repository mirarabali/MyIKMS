# IKMS — Project Understanding (Phase 0)

## 1. Product Vision (Restated)

IKMS is a comprehensive, multi-domain knowledge lifecycle management platform—not merely a document repository. It enables organizations to create, organize, review, publish, and distribute structured knowledge content across multiple audiences and languages. The platform combines semantic knowledge organization (thesaurus + ontology/knowledge graph), content production workflows, resource/library management with access control and lending, sophisticated indexing and search capabilities, scientific review workflows, granular role-based access control scoped to domains, and flexible reporting—all built on top of an existing, immutable SQL Server database schema via two generic engines: the **knowledge graph engine** (TMD + Relations + RelationsTypes) and the **workflow engine** (ProjectType + Projects + Process + TMDP).

---

## 2. Seven Functional Layers & Key Entities (Using Exact Table Names)

### Layer 1 — Semantic Knowledge Organization
| Concept | Existing Table(s) | Notes |
|---------|-------------------|-------|
| Domain hierarchy | `Domains` (`Domain_Id`, `Domain_Title`, `Domain_Parent` → `Domains.Domain_Id`, `Domain_StateId`) | Self-referencing hierarchy |
| Module types | `Modules` (`Module_Id`, `Module_Name`, `Module_ParentId`) | No status column—treated as always active |
| Terms | `Terms` (`Term_Id`, `Term_Title`, `Term_Description`, `Term_StateId`) | Base vocabulary entries |
| TMD (central node) | `TMD` (`TMD_Id`, `TMD_ModuleId`, `TMD_DomainId`, `TMD_TermId`, `State_Id`, `TMD_IsPreferred`) | `State_Id` is authoritative; `TMD_StateId` never written |
| Relation types | `RelationsTypes` (`RelationsType_Id`, `RelationsType_Title`, `RelationsType_ReverseTitle`, `RelationsType_IsNodeLabel`, `RelationsType_DataTypeId`, graph flags) | Dual role: semantic relation OR attribute type |
| Module–RelationType mapping | `MRT` (`MRT_Id`, `MRT_ModuleId`, `MRT_RelationTypeId`) | Which relation types valid per module |
| Relation constraints | `RelationConstraints` (`Id`, `Mrt_Id`, `SqlCondition`, `MinCardinallity`, `MaxCardinallity`) | `SqlCondition` parsed by whitelist rule parser only |
| Relations (edges) | `Relations` (`TermsRelation_Id`, `First_TMDId`, `TermsRelation_TypeId`, `Second_TMDId`, `TermsRelation_Description`) | `TermsRelation_Description` holds locators/timecodes |

### Layer 2 — Knowledge Content Production & Delivery
| Concept | Existing Table(s) | Notes |
|---------|-------------------|-------|
| Content variants | `TMD` (separate row per variant) + `Relations` (links variant to canonical TMD via audience/language relation types) | Entity-level multilingual/multi-audience |
| Content body | `DocContent` (`DocContent_Id`, `DocContent_TMDId`, `DocContent_VolumeNo`, `DocContent_SectionNo`, `DocContent_PageNo`, `DocContent_ParagraphNo`, `DocContent_Text`) | Granular text storage |

### Layer 3 — Resources, Library, and Content Access
| Concept | Existing Table(s) | Notes |
|---------|-------------------|-------|
| Resource (book/article/etc.) | `TMD` under Library module + `Relations` for metadata (author, publisher, subject, tags, barcode, etc.) | No Resource/Book table—graph pattern |
| Digital text | `DocContent` linked via `DocContent_TMDId` | Volume/section/page/paragraph granularity |
| Files | `Files` (`File_TableName`, `File_TableRecordId` string pattern) | Mitigated by code-level whitelist |
| AccessPolicy | `ProjectType` + `Process` (e.g., Requested → Payment → Granted) | No AccessPolicy table—workflow pattern |
| Loan | `ProjectType` + `Process` (Requested → Approved → Borrowed → Returned) + `Payments` | Uses `Project_StartDate`/`Project_EndDate` |
| Payment | `Payments` (`Payment_Id`, `Payment_OrganizationUserId`, `Payment_Cost`, `Payment_ProjectId`) | Status derived from project's current Process step |

### Layer 4 — Indexing & Information Retrieval
| Concept | Existing Table(s) | Notes |
|---------|-------------------|-------|
| Hierarchical/locator index | Query over `DocContent` + `TMD` + `Terms` | Not persisted |
| Linear/abstract index | Computed from `Terms` + `Relations` + `RelationsTypes.RelationsType_ReverseTitle` | Not persisted |
| Time-based index | `Relations` row typed "MentionedAt" with timecode in `TermsRelation_Description` | Locator convention |
| Search | Full-text over `Terms.Term_Title`, `DocContent.DocContent_Text` (+ optional external engine) | Adds indexes/catalogs only, no schema changes |

### Layer 5 — Scientific Workflow, Review & Quality Control
| Concept | Existing Table(s) | Notes |
|---------|-------------------|-------|
| States | `States` (`State_Id`, `State_Title`) | Generic status values |
| Workflow definition | `Process` (`Process_Id`, `Process_StateId`, `Process_ProjectTypeId`, `Process_Next`, `Process_Previous`, `Process_Duration`, `Process_Condition`, `Process_RoleId`) | `Process_Condition` parsed by whitelist rule parser |
| Project types | `ProjectType` (`ProjectType_Id`, `ProjectType_Name`, `ProjectType_OrganizationId`) | Content review, AccessPolicy, Loan all use same engine |
| Project instances | `Projects` (`Project_Id`, `Project_Title`, `Project_ProjectTypeId`, `Project_ProcessId`, `Project_StartDate`, `Project_EndDate`, `Project_ChangeProcessDate`, `Project_PreviousStepText`) | |
| Project participants | `ProjectUsers` (`ProjectUser_Id`, `ProjectUser_UserId`, `ProjectUser_ProjectId`) | |
| Workflow instance tracking | `TMDP` (`TMDP_Id`, `TMDP_TMDId`, `TMDP_ProjectId`, `TMDP_StateId`, `TMDP_StartDate`, `TMDP_EndDate`) | Links TMD to Project |
| Workbox | Query over `TMDP` + `Process` + `Roles` | Not a table |
| Audit trail / version history | `Logs` (`Log_Id`, `Log_TableName`, `Log_TableRecordId`, `Log_TypeId`, `Log_Activity`, `Log_UserId`, `Log_CreatedDateTime`) + `LogType` | JSON snapshot in `Log_Activity` |

### Layer 6 — Users, Roles & Access Control
| Concept | Existing Table(s) | Notes |
|---------|-------------------|-------|
| Organizations | `Organizations` (`Organization_Id`, `Organization_Name`, `Organization_ParentId`, …) | Hierarchical |
| Organization members | `OrganizationUsers` (`OrganizationUsers_Id`, `OrganizationUsers_OrganizationId`, `OrganizationUsers_UserId`, `OrganizationUsers_isAgent`) | |
| Roles | `Roles` (`Role_Id`, `Role_Name`) | Domain-scoped roles defined as separate rows (e.g., "Term Editor — Jurisprudence") |
| User–Role assignment | `UserRoles` (`UserRole_Id`, `UserRole_UserId`, `UserRole_RoleId`) | No domain column—domain scoping via role naming convention |
| Permissions | `Permissions` (`Permission_Id`, `Permission_RoleId`, `Permission_APIId`, `Permission_Value`) + `API` (`API_ControllerName`, `API_URL`, `API_ActionType`) | Stable permission keys stored in `API_ControllerName` |
| Authentication sessions | `AuthSessions`, `AuthRefreshTokens`, `AuthAccessTokenBlacklists`, `AuthLoginLockouts` | JWT + refresh token rotation + session management + blacklist + lockout |
| News | `News`, `NewsCategory`, `NewsRelNewsCategory`, `NewsRelTags` | Direct use; not routed through TMD/Modules |
| Themes | `Themes`, `ThemeTypes` | Low priority |

### Layer 7 — Reporting
| Concept | Existing Table(s) | Notes |
|---------|-------------------|-------|
| Tree output | Recursive CTE over `Domains` / `Modules` | |
| Graph output | Traversal over `Relations` / `RelationsTypes` | |
| Tabular output | Standard queries + export logic | Excel/PDF/CSV |

---

## 3. Frontend Stack Choice & Justification

| Application | Technology | Justification |
|-------------|------------|---------------|
| **Admin Panel** | React 18 + TypeScript + Vite + Material UI (or Ant Design) | Rich data/tree/graph/workflow screens require React's ecosystem; RTL-first component libraries (MUI/AntD) have excellent Persian/RTL support; deepest i18n library ecosystem (`react-i18next`, `moment-jalaali`/`react-multi-date-picker`) for Jalali calendar and Persian localization |
| **Public Portal** | Next.js (React) + TypeScript | Public search/browse content requires SEO and fast first paint, which client-side-only SPA cannot provide; Next.js offers SSR/SSG for SEO while sharing components/i18n/RTL setup with Admin Panel |

**Rejected alternative**: Blazor was considered for same-language convenience (C#), but its RTL/Jalali ecosystem is thin and it has no built-in SEO story for the Public Portal.

This decision will be documented in `docs/DECISIONS.md` with full reasoning.

---

## 4. Phase Plan (Phases 1–11) — Concrete Deliverables

### Phase 1 — Solution Skeleton & DbContext Scaffold
**Deliverables:**
- `/src/IKMS.Domain/` — empty class library (domain markers, future entities)
- `/src/IKMS.Application/` — empty class library (application services, validators, mappers)
- `/src/IKMS.Infrastructure/` — EF Core DbContext scaffolded from existing DB (all 39 tables matched exactly, `HasColumnName()` for legacy names like `NewsCtegory`), connection string configuration
- `/src/IKMS.WebApi/` — empty ASP.NET Core Web API project with minimal boilerplate (Program.cs with Serilog, health check endpoint, Swagger setup)
- `/tests/IKMS.Domain.Tests/`, `/tests/IKMS.Application.Tests/`, `/tests/IKMS.WebApi.IntegrationTests/` — empty test projects with xUnit
- `setup.ps1` / `setup.sh` — restore NuGet/npm packages, verify DB connection, seed sample data (Domains, Modules, Terms, TMD, Relations, sample users/roles)
- `docs/ERD.md` — Mermaid ERD documenting existing schema
- `appsettings.Example.json`, `.env.example` — templates for configuration

### Phase 2 — Auth (Users/Organizations/Roles/Permissions/JWT+Refresh+Session+Blacklist+Lockout)
**Deliverables:**
- `IKMS.Application/Features/Auth/` — `LoginCommand`, `RefreshTokenCommand`, `LogoutCommand`, `RegisterUserCommand`, validators, DTOs
- `IKMS.Application/Features/Users/` — CRUD commands/queries, `GetUserProfileQuery`
- `IKMS.Application/Features/Organizations/` — CRUD commands/queries
- `IKMS.Application/Features/Roles/` — CRUD commands/queries
- `IKMS.Application/Features/Permissions/` — sync `[RequirePermission]` attributes to `API`/`Permissions` tables at startup
- `IKMS.Infrastructure/Services/` — `JwtTokenService`, `RefreshTokenService`, `PasswordHasher` (BCrypt), `SessionManager`
- `IKMS.WebApi/Controllers/` — `AuthController`, `UsersController`, `OrganizationsController`, `RolesController`, `PermissionsController`
- `IKMS.WebApi/Filters/` — `[RequirePermission]` attribute, authorization policy provider
- `IKMS.WebApi/Middleware/` — global exception handler (ProblemDetails), rate limiting middleware for auth endpoints
- Integration tests for all auth endpoints (Swagger-verifiable)

### Phase 3 — Graph Engine (Domains/Modules/Terms/TMD/RelationsTypes/MRT/RelationConstraints/Relations)
**Deliverables:**
- `IKMS.Application/Features/Domains/` — hierarchical CRUD, `GetDomainTreeQuery`
- `IKMS.Application/Features/Modules/` — CRUD, `GetModuleTreeQuery`
- `IKMS.Application/Features/Terms/` — CRUD
- `IKMS.Application/Features/Tmd/` — CRUD with dual-status handling (`State_Id` authoritative)
- `IKMS.Application/Features/RelationsTypes/` — CRUD with graph-theory flag validation
- `IKMS.Application/Features/Mrt/` — CRUD (module–relation-type mapping)
- `IKMS.Application/Features/RelationConstraints/` — CRUD with cardinality parsing (`"0..3"` convention), `SqlCondition` whitelist parser
- `IKMS.Application/Features/Relations/` — CRUD with constraint validation (cardinality, graph rules)
- `IKMS.WebApi/Controllers/` — corresponding controllers for each feature
- Unit tests for constraint validation, graph rule enforcement
- Integration tests for building a domain hierarchy, creating relations validated against constraints

### Phase 4 — Content Variants (Layer 2: TMD variants + DocContent + workflow linkage)
**Deliverables:**
- `IKMS.Application/Features/DocContent/` — CRUD with volume/section/page/paragraph granularity
- `IKMS.Application/Features/ContentVariants/` — `CreateContentVariantCommand` (creates TMD variant + links to canonical TMD via audience/language Relations), `UpdateContentVariantCommand`, `SubmitForReviewCommand` (creates initial TMDP entry)
- `IKMS.WebApi/Controllers/` — `DocContentController`, `ContentVariantsController`
- Integration tests for creating/editing/submitting a content variant in multiple languages and audience levels

### Phase 5 — Library Conventions (Resource-as-TMD + AccessPolicy/Loan as ProjectType + Payments)
**Deliverables:**
- `IKMS.Application/Features/Resources/` — `CreateResourceCommand` (creates TMD under Library module + author/publisher/subject/tag Relations), `GetResourceDetailQuery`
- `IKMS.Application/Features/Files/` — `UploadFileCommand` with `TableName` whitelist enforcement, `GetFileQuery`
- `IKMS.Application/Features/AccessPolicies/` — `DefineAccessPolicyProjectTypeCommand` (creates ProjectType + Process steps: Requested → Payment → Granted), `RequestAccessCommand` (creates Project + TMDP)
- `IKMS.Application/Features/Loans/` — `DefineLoanProjectTypeCommand` (Requested → Approved → Borrowed → Returned), `RequestLoanCommand`, `ApproveLoanCommand`, `ReturnResourceCommand`
- `IKMS.Application/Features/Payments/` — `ProcessPaymentCommand` (links Payment to Project + OrganizationUser)
- `IKMS.WebApi/Controllers/` — `ResourcesController`, `FilesController`, `AccessPoliciesController`, `LoansController`, `PaymentsController`
- Integration tests for end-to-end: add book TMD with author/publisher relations, upload file, run 3-page-preview + paywall flow, simulate full loan lifecycle

### Phase 6 — Indexing & Search
**Deliverables:**
- `IKMS.Application/Features/Indexing/` — `GetLocatorIndexQuery` (hierarchical/locator over DocContent), `GetLinearIndexQuery` (computed from Terms + Relations + reverse titles), `GetTimeBasedIndexQuery` (filters Relations by "MentionedAt" type + parses timecode from Description)
- `IKMS.Application/Features/Search/` — `SearchQuery` (cross-field over Terms/DocContent with status/domain/field filters, starts-with/contains/exact-phrase operators), SQL Server Full-Text Search implementation (justified choice in DECISIONS.md)
- `IKMS.WebApi/Controllers/` — `IndexingController`, `SearchController`
- Integration tests for locator/time-based queries, search with filters/operators

### Phase 7 — Workflow Engine (States/Process/ProjectType/Projects/ProjectUsers/TMDP/Workbox/Logs)
**Deliverables:**
- `IKMS.Application/Features/States/` — CRUD
- `IKMS.Application/Features/WorkflowDefinitions/` — `CreateProcessStepCommand` (defines Process with Next/Previous/Duration/Condition/RoleId), `UpdateProcessStepCommand`
- `IKMS.Application/Features/ProjectTypes/` — CRUD
- `IKMS.Application/Features/Projects/` — `CreateProjectCommand`, `TransitionProjectCommand` (approve/reject/revise with Condition parsing via whitelist rule parser), `GetProjectHistoryQuery`
- `IKMS.Application/Features/ProjectUsers/` — `AddUserToProjectCommand`
- `IKMS.Application/Features/Tmdp/` — `CreateTmdpCommand` (links TMD to Project), `UpdateTmdpStateCommand`
- `IKMS.Application/Features/Workbox/` — `GetWorkboxQuery` (items whose current Process step assigned to caller's role)
- `IKMS.Application/Features/AuditTrail/` — `WriteLogCommand` (JSON snapshot to Log_Activity on every change), `RevertToSnapshotCommand` (replays prior Log_Activity)
- `IKMS.WebApi/Controllers/` — `StatesController`, `WorkflowDefinitionsController`, `ProjectTypesController`, `ProjectsController`, `ProjectUsersController`, `TmdpController`, `WorkboxController`, `AuditTrailController`
- Integration tests for full workflow (approve/reject/revise), Logs history recording, revert to prior snapshot

### Phase 8 — Reporting
**Deliverables:**
- `IKMS.Application/Features/Reporting/` — `GetThesaurusTreeReportQuery` (recursive CTE over Domains), `GetKnowledgeGraphReportQuery` (traversal over Relations/RelationsTypes), `GetTabularReportQuery` (configurable tabular output)
- `IKMS.Infrastructure/Services/` — `ExcelExportService`, `PdfExportService`, `CsvExportService`
- `IKMS.WebApi/Controllers/` — `ReportingController` with export endpoints
- Integration tests for 3 report types with Excel/PDF export

### Phase 9 — Admin Panel Frontend
**Deliverables:**
- `/src/IKMS.AdminPanel/` — React 18 + TypeScript + Vite + MUI/AntD project structure
- RTL-first layout, Persian language default, Jalali date display
- i18n architecture (`react-i18next`), extensible to other languages
- Screens: Login, Dashboard, Domain/Module/Term/TMD management, RelationsTypes/MRT/Relations editors, Content variant editor (multi-language/audience), Resource manager, File uploader, AccessPolicy/Loan configurator, Workflow designer, Workbox, Reports viewer/exporter, User/Organization/Role/Permission managers
- Shared components: tree view, graph visualizer, data grid with filters, form inputs with validation
- Smoke E2E tests for key admin journeys

### Phase 10 — Public Portal Frontend
**Deliverables:**
- `/src/IKMS.PublicPortal/` — Next.js + TypeScript project structure
- RTL-first layout, Persian language default, Jalali date display
- SEO-optimized pages: Home, Search results, Browse by domain/module, Term/Concept detail, Resource detail (with 3-page preview), Article/Encyclopedia entry view
- User journeys: Register (individual/corporate), Login, Request loan/access, Payment flow, Profile management
- Shared components/i18n/RTL setup with Admin Panel
- Smoke E2E tests for key public user journeys

### Phase 11 — Security Hardening, Performance Tuning, Documentation, Sample Data, Full Regression
**Deliverables:**
- Security audit: OWASP checklist applied, rate limiting tuned, CORS policy finalized, HTTPS enforced
- Performance: pagination verified everywhere, indexes added where helpful (no column/table changes), async/await throughout, Redis caching for frequently-read thesaurus/domain tree (optional)
- Complete documentation: README (step-by-step setup on clean machine), `docs/DECISIONS.md`, `docs/ERD.md`, `docs/PROJECT_UNDERSTANDING.md`, `docs/PROGRESS.md`, Swagger XML comments
- Sample data seed script: Domains, Modules, Terms, TMDs forming sample "books" with author/publisher relations, sample Projects for access/loan, sample users with different roles (rows only, no DDL)
- Final regression pass: `dotnet build` zero errors/warnings, `dotnet test` 100% green, frontend tests green
- Final validation report: build status, test status, how to run whole stack with single command, checklist mapping every requirement in prompt to codebase locations

---

## 5. Assumptions, Ambiguities & Resolutions

| # | Assumption/Ambiguity | Resolution |
|---|----------------------|------------|
| 1 | **Domain-scoped ABAC**: `UserRoles` has no domain column, but Layer 6 requires domain-scoped permissions. | Implement via **domain-scoped role definitions**: e.g., "Term Editor — Jurisprudence" and "Term Editor — Management" are separate `Roles` rows. The domain filter is attached to the role name/definition itself, not to the assignment. Documented in `DECISIONS.md`. |
| 2 | **TMD dual status columns**: `TMD` has both `TMD_StateId` and `State_Id`. | Treat **`State_Id` as authoritative** everywhere in new code; never write to `TMD_StateId`. Documented in `DECISIONS.md`. |
| 3 | **RelationsTypes dual role**: table serves as both semantic relation type AND attribute/field type via `IsNodeLabel`/`DataTypeId`. | This is the intended mechanism (Section 3a), not a defect. Infer role from whether `RelationsType_DataTypeId` is set. No discriminator column added. |
| 4 | **Modules has no status column**. | Treat all Modules as always-active. Accepted limitation, not worked around. |
| 5 | **Files/Logs string-based TableName+RecordId pattern** lacks referential integrity. | Mitigate with fixed, code-level whitelist of valid `TableName` values enforced on every write, covered by tests. |
| 6 | **RelationConstraints.SqlCondition / Process.Process_Condition** could be executed as arbitrary SQL/code. | Never evaluate as executable SQL/code. Only a small, fixed, whitelisted rule parser in Application layer may interpret them. |
| 7 | **Permission keys storage**: `API_ControllerName` column holds stable permission keys (e.g., `"Domains.Term.Create"`), not real controller names. | Auto-discover `[RequirePermission(...)]` attributes at startup and sync to `API`/`Permissions` tables. |
| 8 | **Legacy column names** (e.g., `NewsCtegory`). | Map to clean C# property names via EF Core's `HasColumnName()`; physical column name untouched. |
| 9 | **Password hashing**: `User_Password nvarchar(255)` stores plain text in legacy system. | Hash all passwords with BCrypt before writing; verify against hash on login. |
| 10 | **Indexes/unique constraints**: allowed to add since they don't rename/restructure tables/columns. | May add indexes (e.g., unique index on `Users.User_UserName`) after confirming they don't cross the line into schema restructuring. |
| 11 | **Search engine choice**. | Use SQL Server Full-Text Search (justified: avoids external dependency, sufficient for MVP; can extend to Elasticsearch/OpenSearch later if needed). Documented in `DECISIONS.md`. |
| 12 | **Locator/timecode convention in `TermsRelation_Description`**. | Documented convention: e.g., `"00:12:30-00:14:00"` for timecodes, `"vol.2/p.45/¶3"` for print locators. Parsed by Application layer utilities. |
| 13 | **Payment "status"**. | Derived from containing project's current `Process` step and `TMDP`/`Project` timestamps, not from new columns on `Payments`. |
| 14 | **Loan window tracking**. | Uses existing `Project_StartDate`/`Project_EndDate` on `Projects`; no new columns. |
| 15 | **News routing**. | Use existing `News`/`NewsCategory`/`NewsRelNewsCategory`/`NewsRelTags` tables directly; do NOT route News through `TMD`/`Modules`. |

---

## 6. Architecture-Changing Questions

None at this time. All ambiguities identified above have been resolved via documented conventions that work within the frozen schema constraints.

---

## 7. Commitment to Phase-Gated Delivery

I confirm that I will:
- **Not write any code** until this `PROJECT_UNDERSTANDING.md` is explicitly approved.
- Deliver **one phase at a time, in strict order** (Phases 1–11).
- After each phase: build, test, fix every error myself, verify **100% green** against all Definition-of-Done criteria, then **stop and wait for explicit approval** before starting the next phase.
- Produce complete, bug-free code in every phase—no stubs, no TODOs, no fake/hardcoded data pretending to be real logic.
- Document all decisions in `docs/DECISIONS.md`.
- At the end (after Phase 11 approval), deliver a **final validation report** mapping every requirement to codebase locations.

---

**Ready for your review and explicit approval before proceeding to Phase 1.**
