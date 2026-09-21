using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using IKMS.Domain.Entities;

namespace IKMS.Domain.Configurations;

// OrganizationUser configuration
public class OrganizationUserConfiguration : IEntityTypeConfiguration<OrganizationUser>
{
    public void Configure(EntityTypeBuilder<OrganizationUser> builder)
    {
        builder.ToTable("OrganizationUsers");
        builder.HasKey(ou => ou.OrganizationUsers_Id);

        builder.Property(ou => ou.OrganizationUsers_OrganizationId).HasColumnName("OrganizationUsers_OrganizationId").IsRequired();
        builder.Property(ou => ou.OrganizationUsers_UserId).HasColumnName("OrganizationUsers_UserId").IsRequired();
        builder.Property(ou => ou.OrganizationUsers_isAgent).HasColumnName("OrganizationUsers_isAgent").IsRequired(); // Legacy casing (INV-01)
        builder.Property(ou => ou.OrganizationUsers_Deleted).HasColumnName("OrganizationUsers_Deleted").HasColumnType("datetime");

        builder.HasOne(ou => ou.Organization)
            .WithMany(o => o.OrganizationUsers)
            .HasForeignKey(ou => ou.OrganizationUsers_OrganizationId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(ou => ou.User)
            .WithMany(u => u.OrganizationUsers)
            .HasForeignKey(ou => ou.OrganizationUsers_UserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

// Role configuration
public class RoleConfiguration : IEntityTypeConfiguration<Role>
{
    public void Configure(EntityTypeBuilder<Role> builder)
    {
        builder.ToTable("Roles");
        builder.HasKey(r => r.Role_Id);

        builder.Property(r => r.Role_Name).HasColumnName("Role_Name").HasColumnType("nvarchar(500)").IsRequired();
        builder.Property(r => r.Role_Deleted).HasColumnName("Role_Deleted").HasColumnType("datetime");
    }
}

// UserRole configuration
public class UserRoleConfiguration : IEntityTypeConfiguration<UserRole>
{
    public void Configure(EntityTypeBuilder<UserRole> builder)
    {
        builder.ToTable("UserRoles");
        builder.HasKey(ur => ur.UserRole_Id);

        builder.Property(ur => ur.UserRole_UserId).HasColumnName("UserRole_UserId").IsRequired();
        builder.Property(ur => ur.UserRole_RoleId).HasColumnName("UserRole_RoleId").IsRequired();
        builder.Property(ur => ur.UserRole_Deleted).HasColumnName("UserRole_Deleted").HasColumnType("datetime");

        builder.HasOne(ur => ur.User)
            .WithMany(u => u.UserRoles)
            .HasForeignKey(ur => ur.UserRole_UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(ur => ur.Role)
            .WithMany(r => r.UserRoles)
            .HasForeignKey(ur => ur.UserRole_RoleId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

// ApiEndpoint configuration
public class ApiEndpointConfiguration : IEntityTypeConfiguration<ApiEndpoint>
{
    public void Configure(EntityTypeBuilder<ApiEndpoint> builder)
    {
        builder.ToTable("API");
        builder.HasKey(a => a.API_Id);

        builder.Property(a => a.API_ControllerName).HasColumnName("API_ControllerName").HasColumnType("nvarchar(100)").IsRequired();
        builder.Property(a => a.API_URL).HasColumnName("API_URL").HasColumnType("nvarchar(max)").IsRequired();
        builder.Property(a => a.API_ActionType).HasColumnName("API_ActionType").HasColumnType("nvarchar(50)").IsRequired();
        builder.Property(a => a.API_Deleted).HasColumnName("API_Deleted").HasColumnType("datetime");
    }
}

// Permission configuration
public class PermissionConfiguration : IEntityTypeConfiguration<Permission>
{
    public void Configure(EntityTypeBuilder<Permission> builder)
    {
        builder.ToTable("Permissions");
        builder.HasKey(p => p.Permission_Id);

        builder.Property(p => p.Permission_RoleId).HasColumnName("Permission_RoleId").IsRequired();
        builder.Property(p => p.Permission_APIId).HasColumnName("Permission_APIId").IsRequired();
        builder.Property(p => p.Permission_Value).HasColumnName("Permission_Value").HasColumnType("nvarchar(max)");
        builder.Property(p => p.Permission_Deleted).HasColumnName("Permission_Deleted").HasColumnType("datetime");

        builder.HasOne(p => p.Role)
            .WithMany(r => r.Permissions)
            .HasForeignKey(p => p.Permission_RoleId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(p => p.ApiEndpoint)
            .WithMany(a => a.Permissions)
            .HasForeignKey(p => p.Permission_APIId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

// AuthSession configuration
public class AuthSessionConfiguration : IEntityTypeConfiguration<AuthSession>
{
    public void Configure(EntityTypeBuilder<AuthSession> builder)
    {
        builder.ToTable("AuthSessions");
        builder.HasKey(a => a.SessionId);

        builder.Property(a => a.UserId).HasColumnName("UserId").IsRequired();
        builder.Property(a => a.CreatedAt).HasColumnName("CreatedAt").HasColumnType("datetime2(7)").IsRequired();
        builder.Property(a => a.LastSeenAt).HasColumnName("LastSeenAt").HasColumnType("datetime2(7)").IsRequired();
        builder.Property(a => a.UserAgent).HasColumnName("UserAgent").HasColumnType("nvarchar(512)");
        builder.Property(a => a.Ip).HasColumnName("Ip").HasColumnType("nvarchar(64)");
        builder.Property(a => a.IsRevoked).HasColumnName("IsRevoked").IsRequired();
        builder.Property(a => a.RevokedAt).HasColumnName("RevokedAt").HasColumnType("datetime2(7)");
        builder.Property(a => a.RevokeReason).HasColumnName("RevokeReason").HasColumnType("nvarchar(256)");

        builder.HasOne(a => a.User)
            .WithMany(u => u.AuthSessions)
            .HasForeignKey(a => a.UserId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

// AuthRefreshToken configuration
public class AuthRefreshTokenConfiguration : IEntityTypeConfiguration<AuthRefreshToken>
{
    public void Configure(EntityTypeBuilder<AuthRefreshToken> builder)
    {
        builder.ToTable("AuthRefreshTokens");
        builder.HasKey(a => a.Id);

        builder.Property(a => a.UserId).HasColumnName("UserId").IsRequired();
        builder.Property(a => a.SessionId).HasColumnName("SessionId").IsRequired();
        builder.Property(a => a.TokenHash).HasColumnName("TokenHash").HasColumnType("nvarchar(256)").IsRequired();
        builder.Property(a => a.CreatedAt).HasColumnName("CreatedAt").HasColumnType("datetime2(7)").IsRequired();
        builder.Property(a => a.ExpiresAt).HasColumnName("ExpiresAt").HasColumnType("datetime2(7)").IsRequired();
        builder.Property(a => a.ConsumedAt).HasColumnName("ConsumedAt").HasColumnType("datetime2(7)");
        builder.Property(a => a.RevokedAt).HasColumnName("RevokedAt").HasColumnType("datetime2(7)");
        builder.Property(a => a.ReplacedByTokenHash).HasColumnName("ReplacedByTokenHash").HasColumnType("nvarchar(256)");
        builder.Property(a => a.ParentTokenHash).HasColumnName("ParentTokenHash").HasColumnType("nvarchar(256)");
        builder.Property(a => a.LastUsedAt).HasColumnName("LastUsedAt").HasColumnType("datetime2(7)");
        builder.Property(a => a.LastUsedIp).HasColumnName("LastUsedIp").HasColumnType("nvarchar(64)");
        builder.Property(a => a.LastUsedUserAgent).HasColumnName("LastUsedUserAgent").HasColumnType("nvarchar(512)");

        builder.HasOne(a => a.User)
            .WithMany(u => u.AuthRefreshTokens)
            .HasForeignKey(a => a.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(a => a.Session)
            .WithMany(s => s.AuthRefreshTokens)
            .HasForeignKey(a => a.SessionId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}

// AuthAccessTokenBlacklist configuration
public class AuthAccessTokenBlacklistConfiguration : IEntityTypeConfiguration<AuthAccessTokenBlacklist>
{
    public void Configure(EntityTypeBuilder<AuthAccessTokenBlacklist> builder)
    {
        builder.ToTable("AuthAccessTokenBlacklists");
        builder.HasKey(a => a.Id);

        builder.Property(a => a.TokenId).HasColumnName("TokenId").HasColumnType("nvarchar(200)").IsRequired();
        builder.Property(a => a.CreatedAt).HasColumnName("CreatedAt").HasColumnType("datetime2(7)").IsRequired();
        builder.Property(a => a.ExpiresAt).HasColumnName("ExpiresAt").HasColumnType("datetime2(7)").IsRequired();
    }
}

// AuthLoginLockout configuration
public class AuthLoginLockoutConfiguration : IEntityTypeConfiguration<AuthLoginLockout>
{
    public void Configure(EntityTypeBuilder<AuthLoginLockout> builder)
    {
        builder.ToTable("AuthLoginLockouts");
        builder.HasKey(a => a.Id);

        builder.Property(a => a.Username).HasColumnName("Username").HasColumnType("nvarchar(255)").IsRequired();
        builder.Property(a => a.FailedAttempts).HasColumnName("FailedAttempts").IsRequired();
        builder.Property(a => a.LockoutUntil).HasColumnName("LockoutUntil").HasColumnType("datetime2(7)");
        builder.Property(a => a.LastFailedAt).HasColumnName("LastFailedAt").HasColumnType("datetime2(7)").IsRequired();
        builder.Property(a => a.LastFailedIp).HasColumnName("LastFailedIp").HasColumnType("nvarchar(64)");
    }
}
