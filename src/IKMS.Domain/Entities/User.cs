using System;
using System.Collections.Generic;

namespace IKMS.Domain.Entities;

/// <summary>
/// Users — اطلاعات حساب کاربری و مشخصات فردی کاربران سامانه را نگهداری می‌کند.
/// Physical table name preserved exactly as in legacy schema (INV-01, CONV-10).
/// </summary>
public class User
{
    public int User_Id { get; set; }  // PK
    public string User_UserName { get; set; } = null!;  // NN nvarchar(255)
    public string User_Password { get; set; } = null!;  // NN nvarchar(255) - Argon2id hash (INV-13)
    public string? User_Name { get; set; }  // nvarchar(50)
    public string? User_Family { get; set; }  // nvarchar(50)
    public string? User_Email { get; set; }  // nchar(100)
    public string? User_Phone { get; set; }  // varchar(50)
    public string? User_Address { get; set; }  // nvarchar(max)
    public DateTime? User_RegistrationDate { get; set; }  // datetime2(7)
    public DateTime? User_LastLoginDate { get; set; }  // datetime2(7)
    public DateTime? User_Deleted { get; set; }  // datetime - soft delete marker

    // Navigation properties
    public virtual ICollection<OrganizationUser> OrganizationUsers { get; set; } = new List<OrganizationUser>();
    public virtual ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
    public virtual ICollection<AuthSession> AuthSessions { get; set; } = new List<AuthSession>();
    public virtual ICollection<AuthRefreshToken> AuthRefreshTokens { get; set; } = new List<AuthRefreshToken>();
    public virtual ICollection<Log> Logs { get; set; } = new List<Log>();
    public virtual ICollection<ProjectUser> ProjectUsers { get; set; } = new List<ProjectUser>();
}
