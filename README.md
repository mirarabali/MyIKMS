# IKMS — Intelligent Knowledge Management System

A multi-domain platform for the full lifecycle of structured knowledge, built on top of an existing SQL Server database.

## Prerequisites

- **.NET 9 SDK** (https://dotnet.microsoft.com/download/dotnet/9.0)
- **Node.js 20.x** (https://nodejs.org/)
- **SQL Server** (Developer, Express, or LocalDB) with the legacy schema applied
- **PowerShell 7+** (for setup scripts on Windows) or **Bash** (Linux/macOS)

## Quick Start

### 1. Clone and Configure

```bash
git clone <repository-url> ikms
cd ikms

# Copy configuration templates
cp appsettings.Example.json src/IKMS.WebApi/appsettings.Development.json
cp .env.example .env

# Edit .env with your database connection details
```

### 2. Run Setup Script

**Windows (PowerShell):**
```powershell
.\setup.ps1
```

**Linux/macOS (Bash):**
```bash
./setup.sh
```

### 3. Start Backend API

```bash
cd src/IKMS.WebApi
dotnet run
```

The API will be available at `https://localhost:5001` and `http://localhost:5000`.

### 4. Swagger Documentation

Open `https://localhost:5001/swagger` to view the API documentation.

### 5. Health Check

```bash
curl https://localhost:5001/health
```

## Running Tests

```bash
# All tests
dotnet test

# Phase-specific tests
dotnet test --filter "Trait(Phase=1)"

# With coverage
dotnet test --collect:"XPlat Code Coverage"
```

## Gate Verification

```bash
# PowerShell
./tools/verify.ps1 -Phase 1

# Bash
./tools/verify.sh 1
```

## Project Structure

```
/workspace
├── src/
│   ├── IKMS.Domain/          # Domain entities, value objects
│   ├── IKMS.Application/     # Business logic, validators, mappers
│   ├── IKMS.Infrastructure/  # EF Core, external services
│   └── IKMS.WebApi/          # API controllers, middleware
├── tests/
│   ├── IKMS.Domain.Tests/
│   ├── IKMS.Application.Tests/
│   └── IKMS.WebApi.IntegrationTests/
├── db/
│   └── schema.snapshot.json  # Authoritative schema snapshot
├── tools/
│   ├── verify.ps1/sh         # Gate verification scripts
│   ├── scan-forbidden.ps1/sh # Forbidden pattern scanner
│   └── schema-guard.ps1/sh   # Schema drift detector
├── docs/                     # Documentation
├── artifacts/                # Build/test artifacts
└── .ikms/                    # Autonomous execution state
```

## Key Architecture Decisions

- **Database-First EF Core**: Schema is frozen (INV-01), no migrations allowed
- **Clean Architecture**: Domain → Application → Infrastructure → WebApi
- **JWT Auth**: Short-lived access tokens + rotating refresh tokens
- **Domain-scoped RBAC**: Roles include domain suffix (e.g., "Term Editor — Jurisprudence")
- **Knowledge Graph**: TMD + Relations + RelationsTypes encode all entities and relationships
- **Workflow Engine**: ProjectType + Projects + Process drive all business processes

## Documentation

- [Project Understanding](docs/PROJECT_UNDERSTANDING.md)
- [Traceability Matrix](docs/TRACEABILITY.md)
- [Architectural Decisions](docs/DECISIONS.md)
- [Assumptions](docs/ASSUMPTIONS.md)
- [Progress Report](docs/PROGRESS.md)
- [ERD Diagram](docs/ERD.md)

## License

Proprietary — All rights reserved.
