# IKMS Requirements Traceability Matrix

## Legend
- **Status**: `Planned` | `In Progress` | `Done` | `Blocked`
- **Phase**: Assigned implementation phase
- **Implementing Files**: Path patterns to code files
- **Test IDs**: Test class/method or Playwright test describing the AC coverage
- **AC Coverage**: Which Acceptance Criteria this requirement satisfies

---

## L1 — Semantic Knowledge Organization

| ID | Requirement | Phase | Implementing Files | Test IDs | Status |
|----|-------------|-------|-------------------|----------|--------|
| REQ-L1-01 | Hierarchical domains with parent references and state | 3 | `Domains` entity, `DomainService` | `DomainServiceTests.CreateHierarchy_CycleRejected` | Planned |
| REQ-L1-02 | Modules as extensible content types (always active) | 3 | `Modules` entity, `ModuleService` | `ModuleServiceTests.GetAll_AlwaysActive` | Planned |
| REQ-L1-03 | Terms with title, description, state | 3 | `Terms` entity, `TermService` | `TermServiceTests.Create_ValidatesState` | Planned |
| REQ-L1-04 | TMD as Term×Module×Domain intersection with preferred flag | 3 | `TMD` entity, `TMDService` | `TMDServiceTests.Create_SetsStateId_NotTMDStateId` | Planned |
| REQ-L1-05 | RelationsTypes with graph-theory flags enforced at write time | 3 | `RelationsTypes` entity, `RelationTypeService`, `GraphFlagValidator` | `GraphFlagValidatorTests.Irreflexive_SelfLoopRejected` | Planned |
| REQ-L1-06 | MRT declares valid relation types per module | 3 | `MRT` entity, `MRTService` | `MRTServiceTests.Validate_RelationTypeNotAllowed_Rejected` | Planned |
| REQ-L1-07 | RelationConstraints with cardinality and whitelisted rules | 3 | `RelationConstraints` entity, `CardinalityStringParser`, `RuleParser` | `CardinalityStringParserTests.Parse_ValidFormats`, `RuleParserTests.MaliciousSql_Rejected` | Planned |
| REQ-L1-08 | Relations as typed edges with priority, level, description | 3 | `Relations` entity, `RelationService` | `RelationServiceTests.Create_ValidatesCardinality` | Planned |
| REQ-L1-09 | Only one preferred TMD per term/module/domain scope | 3 | `TMDService.EnforceSinglePreferred` | `TMDServiceTests.MultiplePreferred_Enforcement` | Planned |

**AC Coverage:** AC-3.1, AC-3.2, AC-3.3, AC-3.4, AC-3.5, AC-3.6, AC-3.7, AC-3.8

---

## L2 — Content Production & Delivery

| ID | Requirement | Phase | Implementing Files | Test IDs | Status |
|----|-------------|-------|-------------------|----------|--------|
| REQ-L2-01 | Multi-language variants as separate TMD rows linked by Relations | 4 | `TMDService.CreateVariant`, `RelationService` | `TMDServiceTests.CreateLanguageVariants` | Planned |
| REQ-L2-02 | Multi-audience variants (General/Student/Researcher) | 4 | `TMDService.CreateVariant`, `RelationService` | `TMDServiceTests.CreateAudienceVariants` | Planned |
| REQ-L2-03 | Variant resolution with fallback when absent | 4 | `TMDService.GetVariant`, `VariantFallbackStrategy` | `TMDServiceTests.GetVariant_FallbackLogic` | Planned |
| REQ-L2-04 | DocContent CRUD at volume/section/page/paragraph granularity | 4 | `DocContent` entity, `DocContentService` | `DocContentServiceTests.Create_AtGranularity` | Planned |
| REQ-L2-05 | Draft submission creates TMDP workflow entry | 4 | `TMDService.SubmitDraft`, `TMDPService` | `TMDServiceTests.SubmitDraft_CreatesTMDP` | Planned |

**AC Coverage:** AC-4.1, AC-4.2, AC-4.3, AC-4.4, AC-4.5

---

## L3 — Resources, Library & Access Control

| ID | Requirement | Phase | Implementing Files | Test IDs | Status |
|----|-------------|-------|-------------------|----------|--------|
| REQ-L3-01 | Resource as TMD under Library module with metadata relations | 5 | `ResourceService`, `RelationService` | `ResourceServiceTests.CreateBook_WithMetadata` | Planned |
| REQ-L3-02 | Files upload with polymorphic key whitelist validation | 5 | `Files` entity, `FileService`, `TableNameWhitelist` | `FileServiceTests.Upload_NonWhitelistedTable_Rejected` | Planned |
| REQ-L3-03 | AccessPolicy ProjectType: Requested→Payment→Granted | 5 | `ProjectTypeService`, `ProcessService`, `AccessPolicyHandler` | `AccessPolicyHandlerTests.Lifecycle_GrantedUnlocks` | Planned |
| REQ-L3-04 | Loan ProjectType: Requested→Approved→Borrowed→Returned/Overdue | 5 | `ProjectTypeService`, `ProcessService`, `LoanHandler` | `LoanHandlerTests.Lifecycle_OverdueComputed` | Planned |
| REQ-L3-05 | Payments linked to project; status derived from Process step | 5 | `Payments` entity, `PaymentStatusResolver` | `PaymentStatusResolverTests.Status_FromProcessStep` | Planned |
| REQ-L3-06 | Limited preview enforcement (default 3 pages) server-side | 5 | `PreviewService`, `DocContentService` | `PreviewServiceTests.Page4Direct_Returns403` | Planned |
| REQ-L3-07 | Concurrent loan requests cannot both be approved | 5 | `LoanHandler.Approve`, database locking | `LoanHandlerTests.ConcurrentRequests_OneApproved` | Planned |

**AC Coverage:** AC-5.1, AC-5.2, AC-5.3, AC-5.4, AC-5.5, AC-5.6, AC-5.7

---

## L4 — Indexing & Retrieval

| ID | Requirement | Phase | Implementing Files | Test IDs | Status |
|----|-------------|-------|-------------------|----------|--------|
| REQ-L4-01 | Locator index query over DocContent joined to TMD/Terms | 6 | `LocatorIndexService` | `LocatorIndexServiceTests.Query_ReturnsCorrectHits` | Planned |
| REQ-L4-02 | Linear/abstract index composed from Terms + Relations with ReverseTitle | 6 | `AbstractIndexComposer` | `AbstractIndexComposerTests.Compose_UsesReverseTitle` | Planned |
| REQ-L4-03 | Time-based index from Relations edge with time-code payload | 6 | `TimeBasedIndexService` | `TimeBasedIndexServiceTests.Query_ReturnsTimeRanges` | Planned |
| REQ-L4-04 | Locator/time-code parser with round-trip validation | 6 | `LocatorStringParser`, `TimeCodeStringParser` | `LocatorStringParserTests.RoundTrip`, `TimeCodeStringParserTests.RejectMalformed` | Planned |
| REQ-L4-05 | Search operators: starts-with, contains, exact-phrase | 6 | `SearchService` | `SearchServiceTests.Operators_CorrectResults` | Planned |
| REQ-L4-06 | Filters: status, domain, module, subject with pagination | 6 | `SearchService`, `PaginationMiddleware` | `SearchServiceTests.Filters_CombineAndPaginate` | Planned |
| REQ-L4-07 | Persian text normalization (ی/ك, ZWNJ, diacritics) | 6 | `PersianTextNormalizer` | `PersianTextNormalizerTests.Normalize_ArabicChars` | Planned |

**AC Coverage:** AC-6.1, AC-6.2, AC-6.3, AC-6.4, AC-6.5, AC-6.6, AC-6.7

---

## L5 — Workflow, Review & QC

| ID | Requirement | Phase | Implementing Files | Test IDs | Status |
|----|-------------|-------|-------------------|----------|--------|
| REQ-L5-01 | Full review workflow: submit→review→approve | 7 | `WorkflowService`, `ProcessService` | `WorkflowServiceTests.FullReview_Approved` | Planned |
| REQ-L5-02 | Reject and revise paths return to correct previous step | 7 | `WorkflowService.Reject`, `WorkflowService.Revise` | `WorkflowServiceTests.Reject_ReturnsToPrevious` | Planned |
| REQ-L5-03 | Workbox shows items where current Process matches user's role | 7 | `WorkboxService` | `WorkboxServiceTests.Filter_ByRole` | Planned |
| REQ-L5-04 | Illegal transitions (skipping steps) rejected | 7 | `ProcessService.ValidateTransition` | `ProcessServiceTests.SkipStep_Rejected` | Planned |
| REQ-L5-05 | SLA tracking: items exceeding Process_Duration marked overdue | 7 | `SLAService` | `SLAServiceTests.ExceedDuration_MarkedOverdue` | Planned |
| REQ-L5-06 | Every change writes Logs JSON snapshot with correct Log_TypeId | 7 | `AuditService` | `AuditServiceTests.Change_WritesSnapshot` | Planned |
| REQ-L5-07 | Revert replays prior snapshot restoring exact field values | 7 | `AuditService.Revert` | `AuditServiceTests.Revert_RestoresFields` | Planned |
| REQ-L5-08 | Process_Condition read only by whitelisted parser (never executed) | 7 | `ProcessConditionParser` | `ProcessConditionParserTests.NeverExecutes` | Planned |

**AC Coverage:** AC-7.1, AC-7.2, AC-7.3, AC-7.4, AC-7.5, AC-7.6, AC-7.7, AC-7.8

---

## L6 — Users, Roles & Access Control

| ID | Requirement | Phase | Implementing Files | Test IDs | Status |
|----|-------------|-------|-------------------|----------|--------|
| REQ-L6-01 | User registration/login with Argon2id password hashing | 2 | `AuthService`, `PasswordHasher` | `AuthServiceTests.Register_Login_PasswordHashed` | Planned |
| REQ-L6-02 | JWT access token + rotating refresh token + session management | 2 | `JwtService`, `RefreshTokenService`, `AuthSessionService` | `AuthServiceTests.Refresh_Rotation` | Planned |
| REQ-L6-03 | Access token blacklist on logout/revoke | 2 | `AuthAccessTokenBlacklistService` | `AuthServiceTests.Logout_TokenBlacklisted` | Planned |
| REQ-L6-04 | Account lockout after N failed logins with expiry | 2 | `AuthLoginLockoutService` | `AuthServiceTests.FailedLogins_LockoutExpiry` | Planned |
| REQ-L6-05 | Domain-scoped roles via naming convention (CONV-08) | 2 | `DomainScopedRoleParser`, `UserRoleService` | `UserRoleServiceTests.DomainScoped_CrossDomain403` | Planned |
| REQ-L6-06 | Permission keys discovered from [RequirePermission] and synced | 2 | `PermissionDiscoveryService`, `PermissionSyncService` | `PermissionSyncServiceTests.Discovery_Idempotent` | Planned |
| REQ-L6-07 | Rate limiting on auth endpoints returns 429 | 2 | `RateLimitMiddleware` | `RateLimitMiddlewareTests.AuthFlooding_429` | Planned |
| REQ-L6-08 | Organizations and OrganizationUsers management | 2 | `OrganizationService` | `OrganizationServiceTests.CRUD` | Planned |
| REQ-L6-09 | News subsystem using News tables directly (not via TMD) | 9/10 | `NewsService` | `NewsServiceTests.CRUD` | Planned |

**AC Coverage:** AC-2.1, AC-2.2, AC-2.3, AC-2.4, AC-2.5, AC-2.6, AC-2.7

---

## L7 — Reporting

| ID | Requirement | Phase | Implementing Files | Test IDs | Status |
|----|-------------|-------|-------------------|----------|--------|
| REQ-L7-01 | Tree report via recursive CTE over Domains/Modules with depth limit | 8 | `TreeReportService` | `TreeReportServiceTests.RecursiveCTE_DepthLimited` | Planned |
| REQ-L7-02 | Graph report traversing Relations/RelationsTypes with cycle safety | 8 | `GraphReportService` | `GraphReportServiceTests.Traverse_CycleSafe` | Planned |
| REQ-L7-03 | Tabular report with filters, sorting, pagination | 8 | `TabularReportService` | `TabularReportServiceTests.FilterSortPaginate` | Planned |
| REQ-L7-04 | Excel/PDF/CSV exports with Persian RTL rendering | 8 | `ExportService` | `ExportServiceTests.Export_RTLRendering` | Planned |
| REQ-L7-05 | Large report (≥50k rows) streams without memory exhaustion | 8 | `ExportService.Streaming` | `ExportServiceTests.LargeReport_Streaming` | Planned |

**AC Coverage:** AC-8.1, AC-8.2, AC-8.3, AC-8.4, AC-8.5

---

## Cross-Cutting / Non-Functional Requirements

| ID | Requirement | Phase | Implementing Files | Test IDs | Status |
|----|-------------|-------|-------------------|----------|--------|
| REQ-NF-01 | OWASP security best practices (input validation, CORS, HTTPS) | 11 | Security middleware, validation filters | `SecurityTests.OWASPChecklist` | Planned |
| REQ-NF-02 | Pagination everywhere | 1+ | `PaginationMiddleware` | `PaginationMiddlewareTests.AllEndpoints` | Planned |
| REQ-NF-03 | Async/await throughout | 1+ | All services | Code review | Planned |
| REQ-NF-04 | Structured logging with request ID tracing | 1+ | Serilog configuration | `LoggingTests.RequestIdTracing` | Planned |
| REQ-NF-05 | Health check endpoint | 1 | `HealthController` | `HealthControllerTests.Healthy` | Planned |
| REQ-NF-06 | Swagger/OpenAPI documentation | 1 | Swagger configuration | Manual verification | Planned |
| REQ-NF-07 | API versioning | 1 | API versioning configuration | `VersioningTests.BackwardCompatible` | Planned |
| REQ-NF-08 | ProblemDetails on all error paths | 1+ | Exception middleware | `ExceptionMiddlewareTests.ProblemDetails` | Planned |
| REQ-NF-09 | RTL + Persian by default in frontends | 9/10 | Frontend i18n setup | Playwright RTL tests | Planned |
| REQ-NF-10 | Jalali dates in UI, UTC/Gregorian in API payload | 9/10 | Date formatting utilities | Playwright date display tests | Planned |
| REQ-NF-11 | No secrets in git (config via appsettings.*.json / .env) | 1 | Configuration setup | Scanner test | Planned |
| REQ-NF-12 | Seed script idempotent, rows only | 11 | `SeedService` | `SeedServiceTests.Idempotent` | Planned |
| REQ-NF-13 | Clean-machine startup documented | 11 | README.md | Manual verification | Planned |
| REQ-NF-14 | Basic WCAG accessibility on public portal | 10 | Frontend components | Playwright accessibility tests | Planned |
| REQ-NF-15 | Optional Redis cache for thesaurus/domain tree | 11 | `RedisCacheService` | `RedisCacheServiceTests.CacheHit` | Planned |

**AC Coverage:** AC-11.1, AC-11.2, AC-11.3, AC-11.4, AC-11.5, AC-11.6, AC-9.2, AC-9.3, AC-10.2, AC-10.5

---

## Phase 0 Deliverables

| ID | Requirement | Phase | Implementing Files | Test IDs | Status |
|----|-------------|-------|-------------------|----------|--------|
| REQ-P0-01 | PROJECT_UNDERSTANDING.md with vision, layers, phases, assumptions | 0 | `docs/PROJECT_UNDERSTANDING.md` | Gate G9 structural check | Done |
| REQ-P0-02 | TRACEABILITY.md with full REQ register | 0 | `docs/TRACEABILITY.md` | Gate G9 structural check | Done |
| REQ-P0-03 | ASSUMPTIONS.md with all ambiguities resolved | 0 | `docs/ASSUMPTIONS.md` | Gate G9 structural check | In Progress |
| REQ-P0-04 | db/schema.snapshot.json from Appendix | 0 | `db/schema.snapshot.json` | Gate G4 completeness | Blocked (CQ-1) |
| REQ-P0-05 | AC register in TRACEABILITY.md | 0 | `docs/TRACEABILITY.md` | Gate G6 | Done |

---

## Summary Statistics

- **Total Requirements:** 67 (L1: 9, L2: 5, L3: 7, L4: 7, L5: 8, L6: 9, L7: 5, NF: 15, P0: 5)
- **Planned:** 62
- **In Progress:** 1 (REQ-P0-03)
- **Done:** 4 (REQ-P0-01, REQ-P0-02, REQ-P0-05, plus this file)
- **Blocked:** 1 (REQ-P0-04 awaiting Appendix schema)

---

## Notes

- Every test must be tagged with `[Trait("Phase", "n")]` and `[Trait("AC", "AC-n.k")]`
- Playwright E2E tests use equivalent tagging in test descriptions
- Gate G6 asserts that executed AC traits ⊇ declared AC list for the phase
- This document is updated at the end of each phase with actual implementing files and test IDs
