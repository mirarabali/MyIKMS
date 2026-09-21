using System;
using System.Collections.Generic;

namespace IKMS.Domain.Entities;

/// <summary>
/// Organizations — سازمان‌ها، واحدها و مجموعه‌های استفاده‌کننده از سامانه را به‌صورت…
/// </summary>
public class Organization
{
    public int Organization_Id { get; set; }  // PK
    public string Organization_Name { get; set; } = null!;  // NN nvarchar(500)
    public string? Oranization_Description { get; set; }  // nvarchar(1000) - legacy misspelling preserved (INV-01)
    public int? Organization_ParentId { get; set; }  // →Organizations.Organization_Id
    public string? Organization_Email { get; set; }  // nvarchar(100)
    public string? Organization_Address { get; set; }  // nvarchar(max)
    public string? Organization_Phone { get; set; }  // varchar(50)
    public DateTime? Organization_Deleted { get; set; }  // datetime

    public virtual ICollection<Organization> Children { get; set; } = new List<Organization>();
    public virtual ICollection<OrganizationUser> OrganizationUsers { get; set; } = new List<OrganizationUser>();
    public virtual ICollection<NewsCategory> NewsCategories { get; set; } = new List<NewsCategory>();
    public virtual ICollection<ProjectType> ProjectTypes { get; set; } = new List<ProjectType>();
    public virtual ICollection<Theme> Themes { get; set; } = new List<Theme>();
}

/// <summary>
/// OrganizationUsers — جدول عضویت کاربران در سازمان‌ها است.
/// </summary>
public class OrganizationUser
{
    public int OrganizationUsers_Id { get; set; }  // PK
    public int OrganizationUsers_OrganizationId { get; set; }  // →Organizations.Organization_Id
    public int OrganizationUsers_UserId { get; set; }  // →Users.User_Id
    public bool OrganizationUsers_isAgent { get; set; }  // NN bit - legacy casing preserved (INV-01)
    public DateTime? OrganizationUsers_Deleted { get; set; }  // datetime

    public virtual Organization Organization { get; set; } = null!;
    public virtual User User { get; set; } = null!;
    public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();
}

/// <summary>
/// Roles — نقش‌های سامانه مانند مدیر سیستم، مدیر سازمان، کارشناس یا ناظر را تعریف…
/// </summary>
public class Role
{
    public int Role_Id { get; set; }  // PK
    public string Role_Name { get; set; } = null!;  // NN nvarchar(500)
    public DateTime? Role_Deleted { get; set; }  // datetime

    public virtual ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
    public virtual ICollection<Permission> Permissions { get; set; } = new List<Permission>();
    public virtual ICollection<Process> Processes { get; set; } = new List<Process>();
}

/// <summary>
/// UserRoles — جدول واسط میان کاربران و نقش‌ها است و امکان اختصاص یک یا چند نقش به هر…
/// </summary>
public class UserRole
{
    public int UserRole_Id { get; set; }  // PK
    public int UserRole_UserId { get; set; }  // →Users.User_Id
    public int UserRole_RoleId { get; set; }  // →Roles.Role_Id
    public DateTime? UserRole_Deleted { get; set; }  // datetime

    public virtual User User { get; set; } = null!;
    public virtual Role Role { get; set; } = null!;
}

/// <summary>
/// API — فهرست Endpointها و عملیات API سامانه را شامل نام کنترلر، نشانی مسیر و نوع…
/// </summary>
public class ApiEndpoint
{
    public int API_Id { get; set; }  // PK
    public string API_ControllerName { get; set; } = null!;  // NN nvarchar(100)
    public string API_URL { get; set; } = null!;  // NN nvarchar(max)
    public string API_ActionType { get; set; } = null!;  // NN nvarchar(50)
    public DateTime? API_Deleted { get; set; }  // datetime

    public virtual ICollection<Permission> Permissions { get; set; } = new List<Permission>();
    public virtual ICollection<Process> Processes { get; set; } = new List<Process>();
}

/// <summary>
/// Permissions — مجوز دسترسی نقش‌ها به Endpointها و عملیات API را تعریف می‌کند.
/// </summary>
public class Permission
{
    public int Permission_Id { get; set; }  // PK
    public int Permission_RoleId { get; set; }  // →Roles.Role_Id
    public int Permission_APIId { get; set; }  // →API.API_Id
    public string? Permission_Value { get; set; }  // nvarchar(max)
    public DateTime? Permission_Deleted { get; set; }  // datetime

    public virtual Role Role { get; set; } = null!;
    public virtual ApiEndpoint ApiEndpoint { get; set; } = null!;
}

/// <summary>
/// AuthSessions — نشست‌های ورود کاربران را همراه با شناسه نشست، زمان ایجاد و آخرین فعالیت،…
/// </summary>
public class AuthSession
{
    public Guid SessionId { get; set; }  // PK uniqueidentifier
    public int UserId { get; set; }  // →Users.User_Id
    public DateTime CreatedAt { get; set; }  // NN datetime2(7)
    public DateTime LastSeenAt { get; set; }  // NN datetime2(7)
    public string? UserAgent { get; set; }  // nvarchar(512)
    public string? Ip { get; set; }  // nvarchar(64)
    public bool IsRevoked { get; set; }  // NN bit
    public DateTime? RevokedAt { get; set; }  // datetime2(7)
    public string? RevokeReason { get; set; }  // nvarchar(256)

    public virtual User User { get; set; } = null!;
    public virtual ICollection<AuthRefreshToken> AuthRefreshTokens { get; set; } = new List<AuthRefreshToken>();
}

/// <summary>
/// AuthRefreshTokens — Refresh Tokenهای کاربران را به‌صورت Hash‌شده ذخیره می‌کند و اطلاعات چرخه…
/// </summary>
public class AuthRefreshToken
{
    public long Id { get; set; }  // PK bigint
    public int UserId { get; set; }  // →Users.User_Id
    public Guid SessionId { get; set; }  // →AuthSessions.SessionId
    public string TokenHash { get; set; } = null!;  // NN nvarchar(256)
    public DateTime CreatedAt { get; set; }  // NN datetime2(7)
    public DateTime ExpiresAt { get; set; }  // NN datetime2(7)
    public DateTime? ConsumedAt { get; set; }  // datetime2(7)
    public DateTime? RevokedAt { get; set; }  // datetime2(7)
    public string? ReplacedByTokenHash { get; set; }  // nvarchar(256)
    public string? ParentTokenHash { get; set; }  // nvarchar(256)
    public DateTime? LastUsedAt { get; set; }  // datetime2(7)
    public string? LastUsedIp { get; set; }  // nvarchar(64)
    public string? LastUsedUserAgent { get; set; }  // nvarchar(512)

    public virtual User User { get; set; } = null!;
    public virtual AuthSession Session { get; set; } = null!;
}

/// <summary>
/// AuthAccessTokenBlacklists — شناسه Access Tokenهای باطل‌شده را تا زمان انقضای آن‌ها نگهداری می‌کند تا…
/// </summary>
public class AuthAccessTokenBlacklist
{
    public long Id { get; set; }  // PK bigint
    public string TokenId { get; set; } = null!;  // NN nvarchar(200)
    public DateTime CreatedAt { get; set; }  // NN datetime2(7)
    public DateTime ExpiresAt { get; set; }  // NN datetime2(7)
}

/// <summary>
/// AuthLoginLockouts — تعداد تلاش‌های ناموفق ورود هر نام کاربری، زمان آخرین تلاش، IP و مدت…
/// </summary>
public class AuthLoginLockout
{
    public long Id { get; set; }  // PK bigint
    public string Username { get; set; } = null!;  // NN nvarchar(255)
    public int FailedAttempts { get; set; }  // NN int
    public DateTime? LockoutUntil { get; set; }  // datetime2(7)
    public DateTime LastFailedAt { get; set; }  // NN datetime2(7)
    public string? LastFailedIp { get; set; }  // nvarchar(64)
}
