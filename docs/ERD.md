# IKMS Entity Relationship Diagram (ERD)

## Status: PROVISIONAL — Awaiting Appendix Schema

This document describes the database schema based on entity descriptions in §6 of the requirements. **All table names, column names, and relationships must be verified against the official Appendix schema** per INV-01. Once the Appendix is provided, this document will be updated with exact types, nullability, and constraints.

---

## Legend

- **PK**: Primary Key
- **FK**: Foreign Key
- **NN**: Not Null
- Relationships shown as `TableA (column) → TableB (column)`

---

## Core Knowledge Graph Tables

### Domains
```
Domains
├── Domain_Id [PK] [NN]
├── Domain_Parent [FK → Domains.Domain_Id] [Nullable]  -- Self-referencing hierarchy
├── Domain_Title [NN]
├── Domain_Description [Nullable]
├── Domain_StateId [FK → States.State_Id] [NN]
└── ... (additional columns per Appendix)
```

### Modules
```
Modules
├── Module_Id [PK] [NN]
├── Module_Parent [FK → Modules.Module_Id] [Nullable]  -- Self-referencing hierarchy
├── Module_Title [NN]
├── Module_Description [Nullable]
└── ... (CONV-11: No status column — always active)
```

### Terms
```
Terms
├── Term_Id [PK] [NN]
├── Term_Title [NN]
├── Term_Description [Nullable]
├── Term_StateId [FK → States.State_Id] [NN]
└── ... (additional columns per Appendix)
```

### TMD (Term × Module × Domain — Central Graph Node)
```
TMD
├── TMD_Id [PK] [NN]
├── TMD_TermId [FK → Terms.Term_Id] [NN]
├── TMD_ModuleId [FK → Modules.Module_Id] [NN]
├── TMD_DomainId [FK → Domains.Domain_Id] [NN]
├── TMD_IsPreferred [Bit/Boolean] [NN]  -- Only one preferred per scope (AC-3.8)
├── State_Id [FK → States.State_Id] [NN]  -- CONV-04: Authoritative (never write TMD_StateId)
├── TMD_StateId [FK → States.State_Id] [Nullable]  -- Legacy; do not write
└── ... (additional columns per Appendix)
```

### RelationsTypes (Relation/Attribute Type Definitions)
```
RelationsTypes
├── RelationsType_Id [PK] [NN]
├── RelationsType_Parent [FK → RelationsTypes.RelationsType_Id] [Nullable]  -- Hierarchy
├── RelationsType_Title [NN]
├── RelationsType_ReverseTitle [Nullable]  -- For linear index composition (L4)
├── RelationsType_DataTypeId [FK → ???] [Nullable]  -- CONV-05: NOT NULL = attribute type
├── IsHierarchical [Bit] [NN]
├── IsTransitive [Bit] [NN]
├── IsAsymmetric [Bit] [NN]
├── IsEquivalence [Bit] [NN]
├── IsIrreflexive [Bit] [NN]
├── IsSystemDefined [Bit] [NN]
└── ... (additional columns per Appendix)
```

### MRT (Module-Relation Type Mapping)
```
MRT
├── MRT_Id [PK] [NN]
├── MRT_ModuleId [FK → Modules.Module_Id] [NN]
├── MRT_RelationsTypeId [FK → RelationsTypes.RelationsType_Id] [NN]
└── ... (defines which relation types are valid per module)
```

### RelationConstraints
```
RelationConstraints
├── RelationConstraint_Id [PK] [NN]
├── ... (foreign keys to define scope)
├── MinCardinallity [String] [NN]  -- CONV-03: "0", "3", "*", "0..3"
├── MaxCardinallity [String] [NN]  -- CONV-03: "0", "3", "*", "0..3"
├── SqlCondition [String] [Nullable]  -- INV-07: Read only by whitelisted parser
├── ErrorMessage [String] [Nullable]
└── ... (additional columns per Appendix)
```

### Relations (Typed Edges Between TMD Nodes)
```
Relations
├── Relations_Id [PK] [NN]
├── First_TMDId [FK → TMD.TMD_Id] [NN]  -- Source node
├── TermsRelation_TypeId [FK → RelationsTypes.RelationsType_Id] [NN]  -- Edge type
├── Second_TMDId [FK → TMD.TMD_Id] [NN]  -- Target node
├── TermsRelation_Priority [Numeric] [Nullable]
├── TermsRelation_Level [Numeric] [Nullable]
├── TermsRelation_Description [String] [Nullable]  -- CONV-01/02: Locator or time-code
└── ... (additional columns per Appendix)
```

---

## Content & Workflow Tables

### DocContent (Content Body at Granular Level)
```
DocContent
├── DocContent_Id [PK] [NN]
├── DocContent_TMDId [FK → TMD.TMD_Id] [NN]  -- Links to variant TMD
├── DocContent_Volume [Nullable]
├── DocContent_Section [Nullable]
├── DocContent_Page [Nullable]
├── DocContent_Paragraph [Nullable]
├── DocContent_Body [Text/Nvarchar(max)] [Nullable]
└── ... (additional columns per Appendix)
```

### States (Workflow States)
```
States
├── State_Id [PK] [NN]
├── State_Title [NN]
├── State_Description [Nullable]
└── ... (used by TMD, Terms, Domains, workflow instances)
```

### Process (Workflow Steps)
```
Process
├── Process_Id [PK] [NN]
├── Process_ProjectTypeId [FK → ProjectType.ProjectType_Id] [NN]
├── Process_StateId [FK → States.State_Id] [NN]
├── Process_Next [FK → Process.Process_Id] [Nullable]
├── Process_Previous [FK → Process.Process_Id] [Nullable]
├── Process_Duration [TimeSpan/Numeric] [Nullable]  -- SLA tracking (AC-7.5)
├── Process_Condition [String] [Nullable]  -- INV-07: Whitelisted parser only
└── ... (additional columns per Appendix)
```

### ProjectType (Workflow Templates)
```
ProjectType
├── ProjectType_Id [PK] [NN]
├── ProjectType_Title [NN]
├── ProjectType_Description [Nullable]
└── ... (AccessPolicy, Loan, Review, etc.)
```

### Projects (Workflow Instances)
```
Projects
├── Projects_Id [PK] [NN]
├── Projects_ProjectTypeId [FK → ProjectType.ProjectType_Id] [NN]
├── Projects_CurrentState [FK → States.State_Id] [NN]
├── Project_StartDate [DateTime] [Nullable]  -- Used for loan window (L3)
├── Project_EndDate [DateTime] [Nullable]  -- Used for loan window (L3)
├── Project_PreviousStepText [String] [Nullable]  -- Per-stage notes (L5)
└── ... (additional columns per Appendix)
```

### ProjectUsers (User Assignment to Projects)
```
ProjectUsers
├── ProjectUser_Id [PK] [NN]
├── ProjectUser_ProjectId [FK → Projects.Projects_Id] [NN]
├── ProjectUser_UserId [FK → Users.User_Id] [NN]
├── ProjectUser_RoleId [FK → Roles.Role_Id] [NN]
└── ... (additional columns per Appendix)
```

### TMDP (TMD in Workflow Tracking)
```
TMDP
├── TMDP_Id [PK] [NN]
├── TMDP_TMDId [FK → TMD.TMD_Id] [NN]
├── TMDP_ProjectId [FK → Projects.Projects_Id] [NN]
├── TMDP_StateId [FK → States.State_Id] [NN]
├── TMDP_StartDate [DateTime] [Nullable]
├── TMDP_EndDate [DateTime] [Nullable]
└── ... (additional columns per Appendix)
```

### Payments
```
Payments
├── Payment_Id [PK] [NN]
├── Payment_ProjectId [FK → Projects.Projects_Id] [NN]
├── Payment_Amount [Decimal] [NN]
├── Payment_Date [DateTime] [Nullable]
├── Payment_Method [String/Numeric] [Nullable]
└── ... (status derived from project's current Process step — §5B)
```

---

## Users, Roles & Access Control Tables

### Users
```
Users
├── User_Id [PK] [NN]
├── User_UserName [NN] [Unique per CONV-03 suggested index]
├── User_Password [nvarchar(255)] [NN]  -- INV-13: Argon2id/BCrypt hash
├── User_Email [Nullable]
├── User_IsActive [Bit] [NN]
└── ... (additional columns per Appendix)
```

### Organizations
```
Organizations
├── Organization_Id [PK] [NN]
├── Organization_Title [NN]
├── Organization_Description [Nullable]
└── ... (corporate entities for AC-10.3)
```

### OrganizationUsers
```
OrganizationUsers
├── OrganizationUser_Id [PK] [NN]
├── OrganizationUser_OrganizationId [FK → Organizations.Organization_Id] [NN]
├── OrganizationUser_UserId [FK → Users.User_Id] [NN]
└── ... (many-to-many link)
```

### Roles
```
Roles
├── Role_Id [PK] [NN]
├── Role_Title [NN]  -- CONV-08: Domain-scoped via naming "{Role} — {Domain}"
├── Role_Description [Nullable]
└── ... (domain scope encoded in title)
```

### UserRoles
```
UserRoles
├── UserRole_Id [PK] [NN]
├── UserRole_UserId [FK → Users.User_Id] [NN]
├── UserRole_RoleId [FK → Roles.Role_Id] [NN]
└── ... (CONV-08: No domain column — domain encoded in role name)
```

### API (Controller Registry)
```
API
├── API_Id [PK] [NN]
├── API_ControllerName [NN]  -- CONV-06: Discovered from attributes
└── ... (synced from [RequirePermission] at startup)
```

### Permissions
```
Permissions
├── Permission_Id [PK] [NN]
├── Permission_APIId [FK → API.API_Id] [NN]
├── Permission_Key [NN]  -- Stable literal like "Domains.Term.Create"
├── Permission_Description [Nullable]
└── ... (synced from [RequirePermission] at startup)
```

### AuthSessions
```
AuthSessions
├── Session_Id [PK] [NN]
├── Session_UserId [FK → Users.User_Id] [NN]
├── Session_CreatedAt [DateTime] [NN]
├── Session_ExpiresAt [DateTime] [NN]
├── Session_IsRevoked [Bit] [NN]
└── ... (session management)
```

### AuthRefreshTokens
```
AuthRefreshTokens
├── RefreshToken_Id [PK] [NN]
├── RefreshToken_SessionId [FK → AuthSessions.Session_Id] [NN]
├── RefreshToken_Token [NN]
├── RefreshToken_ExpiresAt [DateTime] [NN]
├── RefreshToken_UsedAt [DateTime] [Nullable]  -- For rotation detection (AC-2.2)
└── ... (rotating refresh tokens)
```

### AuthAccessTokenBlacklists
```
AuthAccessTokenBlacklists
├── Blacklist_Id [PK] [NN]
├── Blacklist_TokenHash [NN]  -- Hash of blacklisted JWT
├── Blacklist_ExpiresAt [DateTime] [NN]
└── ... (logout/revoke tracking — AC-2.1)
```

### AuthLoginLockouts
```
AuthLoginLockouts
├── Lockout_Id [PK] [NN]
├── Lockout_UserId [FK → Users.User_Id] [NN]
├── Lockout_FailedAttempts [Int] [NN]
├── Lockout_LockedUntil [DateTime] [Nullable]
└── ... (account lockout — AC-2.3)
```

---

## Files & Logs Tables

### Files (Polymorphic File Storage)
```
Files
├── File_Id [PK] [NN]
├── File_TableName [NN]  -- CONV-07: Validated against whitelist
├── File_TableRecordId [NN]  -- Polymorphic key
├── File_Path [NN]
├── File_Name [NN]
├── File_Size [BigInt] [NN]
├── File_ContentType [Nullable]
└── ... (CONV-07: Whitelist validation on every write)
```

### Logs (Audit Trail)
```
Logs
├── Log_Id [PK] [NN]
├── Log_TableName [NN]  -- Polymorphic key
├── Log_TableRecordId [NN]
├── Log_TypeId [FK → LogType.LogType_Id] [NN]  -- CONV-09: Typed snapshots
├── Log_Activity [Nvarchar(max)/JSON] [NN]  -- JSON snapshot of changed fields
├── Log_Timestamp [DateTime] [NN]
├── Log_UserId [FK → Users.User_Id] [Nullable]
└── ... (CONV-09: Audit/version history)
```

### LogType
```
LogType
├── LogType_Id [PK] [NN]
├── LogType_Title [NN]
├── LogType_Description [Nullable]
└── ... (types of audit events)
```

---

## News Subsystem (Standalone — Not via TMD)

### News
```
News
├── News_Id [PK] [NN]
├── News_Title [NN]
├── News_Body [Nullable]
├── News_CreatedAt [DateTime] [NN]
├── News_StateId [FK → States.State_Id] [NN]
└── ... (§6 L6: Use directly, not via TMD/Modules)
```

### NewsCategory
```
NewsCategory
├── NewsCtegory_Id [PK] [NN]  -- Note: Misspelling preserved per INV-01
├── NewsCtegory_Title [NN]
├── NewsCtegory_Parent [FK → NewsCategory.NewsCtegory_Id] [Nullable]
└── ... (hierarchical categories)
```

### NewsRelNewsCategory
```
NewsRelNewsCategory
├── NewsRelNewsCategory_Id [PK] [NN]
├── NewsRelNewsCategory_NewsId [FK → News.News_Id] [NN]
├── NewsRelNewsCategory_CategoryId [FK → NewsCategory.NewsCtegory_Id] [NN]
└── ... (many-to-many news-category link)
```

### NewsRelTags
```
NewsRelTags
├── NewsRelTags_Id [PK] [NN]
├── NewsRelTags_NewsId [FK → News.News_Id] [NN]
├── NewsRelTags_TagId [FK → Terms.Term_Id] [NN]  -- Tags are Terms
└── ... (news tagging via Terms)
```

---

## Themes (Low Priority — Phase 11)

### ThemeTypes
```
ThemeTypes
├── ThemeType_Id [PK] [NN]
├── ThemeType_Title [NN]  -- Page kind
├── ThemeType_ModuleId [FK → Modules.Module_Id] [Nullable]
├── ThemeType_DomainId [FK → Domains.Domain_Id] [Nullable]
└── ... (§6 L6: Lowest priority)
```

### Themes
```
Themes
├── Theme_Id [PK] [NN]
├── Theme_OrganizationId [FK → Organizations.Organization_Id] [NN]
├── Theme_ThemeTypeId [FK → ThemeTypes.ThemeType_Id] [NN]
├── Theme_Definition [JSON/String] [Nullable]  -- UI definition
└── ... (named UI definition per Organization + Module + Domain)
```

---

## Relationships Summary

### Hierarchies
```
Domains (Domain_Parent) → Domains (self-referencing)
Modules (Module_Parent) → Modules (self-referencing)
RelationsTypes (RelationsType_Parent) → RelationsTypes (self-referencing)
NewsCategory (NewsCtegory_Parent) → NewsCategory (self-referencing)
```

### Core Graph
```
Terms (Term_Id) ← TMD (TMD_TermId)
Modules (Module_Id) ← TMD (TMD_ModuleId)
Domains (Domain_Id) ← TMD (TMD_DomainId)

TMD (TMD_Id) ← Relations (First_TMDId)
RelationsTypes (RelationsType_Id) ← Relations (TermsRelation_TypeId)
TMD (TMD_Id) ← Relations (Second_TMDId)
```

### Workflow
```
ProjectType (ProjectType_Id) ← Process (Process_ProjectTypeId)
States (State_Id) ← Process (Process_StateId)
Process (Process_Id) ← Process (Process_Next/Previous)

ProjectType (ProjectType_Id) ← Projects (Projects_ProjectTypeId)
States (State_Id) ← Projects (Projects_CurrentState)
Projects (Projects_Id) ← ProjectUsers (ProjectUser_ProjectId)
Users (User_Id) ← ProjectUsers (ProjectUser_UserId)
Roles (Role_Id) ← ProjectUsers (ProjectUser_RoleId)

TMD (TMD_Id) ← TMDP (TMDP_TMDId)
Projects (Projects_Id) ← TMDP (TMDP_ProjectId)
States (State_Id) ← TMDP (TMDP_StateId)

Projects (Projects_Id) ← Payments (Payment_ProjectId)
```

### Auth & RBAC
```
Users (User_Id) ← AuthSessions (Session_UserId)
AuthSessions (Session_Id) ← AuthRefreshTokens (RefreshToken_SessionId)
Users (User_Id) ← AuthLoginLockouts (Lockout_UserId)

Users (User_Id) ← UserRoles (UserRole_UserId)
Roles (Role_Id) ← UserRoles (UserRole_RoleId)

Users (User_Id) ← OrganizationUsers (OrganizationUser_UserId)
Organizations (Organization_Id) ← OrganizationUsers (OrganizationUser_OrganizationId)

API (API_Id) ← Permissions (Permission_APIId)
```

### Audit & Files
```
LogType (LogType_Id) ← Logs (Log_TypeId)
Users (User_Id) ← Logs (Log_UserId)

[Whitelisted Tables] ← Files (File_TableName + File_TableRecordId)
```

### News
```
News (News_Id) ← NewsRelNewsCategory (NewsRelNewsCategory_NewsId)
NewsCategory (NewsCtegory_Id) ← NewsRelNewsCategory (NewsRelNewsCategory_CategoryId)

News (News_Id) ← NewsRelTags (NewsRelTags_NewsId)
Terms (Term_Id) ← NewsRelTags (NewsRelTags_TagId)
```

### Content
```
TMD (TMD_Id) ← DocContent (DocContent_TMDId)
```

---

## Notes

1. **Column names with typos** (e.g., `NewsCtegory_Id`, `MinCardinallity`, `MaxCardinallity`) are preserved exactly as they appear in the frozen schema per INV-01.

2. **Missing details:** This provisional ERD omits:
   - Exact data types (nvarchar vs varchar, lengths)
   - Nullability (where not obvious)
   - Default values
   - Indexes (except those implied by PK/FK)
   - Unique constraints
   - Check constraints
   - Triggers

3. **To be added when Appendix provided:**
   - Complete column definitions
   - All foreign key relationships
   - Existing indexes
   - Any computed columns
   - Any views or stored procedures

---

*Last updated: Phase 0 — Provisional pending Appendix schema*
