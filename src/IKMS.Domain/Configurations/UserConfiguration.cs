using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using IKMS.Domain.Entities;

namespace IKMS.Domain.Configurations;

/// <summary>
/// User entity configuration - maps to Users table with exact physical column names (INV-01, CONV-10).
/// </summary>
public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("Users");

        builder.HasKey(u => u.User_Id);

        builder.Property(u => u.User_UserName)
            .HasColumnName("User_UserName")
            .HasColumnType("nvarchar(255)")
            .IsRequired();

        builder.Property(u => u.User_Password)
            .HasColumnName("User_Password")
            .HasColumnType("nvarchar(255)")
            .IsRequired();

        builder.Property(u => u.User_Name)
            .HasColumnName("User_Name")
            .HasColumnType("nvarchar(50)");

        builder.Property(u => u.User_Family)
            .HasColumnName("User_Family")
            .HasColumnType("nvarchar(50)");

        builder.Property(u => u.User_Email)
            .HasColumnName("User_Email")
            .HasColumnType("nchar(100)");

        builder.Property(u => u.User_Phone)
            .HasColumnName("User_Phone")
            .HasColumnType("varchar(50)");

        builder.Property(u => u.User_Address)
            .HasColumnName("User_Address")
            .HasColumnType("nvarchar(max)");

        builder.Property(u => u.User_RegistrationDate)
            .HasColumnName("User_RegistrationDate")
            .HasColumnType("datetime2(7)");

        builder.Property(u => u.User_LastLoginDate)
            .HasColumnName("User_LastLoginDate")
            .HasColumnType("datetime2(7)");

        builder.Property(u => u.User_Deleted)
            .HasColumnName("User_Deleted")
            .HasColumnType("datetime");

        // Unique index on username (INV-03 - allowed DB addition)
        builder.HasIndex(u => u.User_UserName)
            .IsUnique()
            .HasDatabaseName("IX_Users_User_UserName");

        // Relationships
        builder.HasMany(u => u.OrganizationUsers)
            .WithOne(ou => ou.User)
            .HasForeignKey(ou => ou.OrganizationUsers_UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(u => u.UserRoles)
            .WithOne(ur => ur.User)
            .HasForeignKey(ur => ur.UserRole_UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(u => u.AuthSessions)
            .WithOne(a => a.User)
            .HasForeignKey(a => a.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(u => u.AuthRefreshTokens)
            .WithOne(a => a.User)
            .HasForeignKey(a => a.UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(u => u.Logs)
            .WithOne(l => l.User)
            .HasForeignKey(l => l.Log_UserId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(u => u.ProjectUsers)
            .WithOne(pu => pu.User)
            .HasForeignKey(pu => pu.ProjectUser_UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
