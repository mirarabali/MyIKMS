using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using IKMS.Domain.Entities;

namespace IKMS.Domain.Configurations;

public class OrganizationConfiguration : IEntityTypeConfiguration<Organization>
{
    public void Configure(EntityTypeBuilder<Organization> builder)
    {
        builder.ToTable("Organizations");
        builder.HasKey(o => o.Organization_Id);

        builder.Property(o => o.Organization_Name)
            .HasColumnName("Organization_Name").HasColumnType("nvarchar(500)").IsRequired();
        builder.Property(o => o.Oranization_Description)
            .HasColumnName("Oranization_Description").HasColumnType("nvarchar(1000)"); // Legacy spelling (INV-01)
        builder.Property(o => o.Organization_ParentId)
            .HasColumnName("Organization_ParentId");
        builder.Property(o => o.Organization_Email)
            .HasColumnName("Organization_Email").HasColumnType("nvarchar(100)");
        builder.Property(o => o.Organization_Address)
            .HasColumnName("Organization_Address").HasColumnType("nvarchar(max)");
        builder.Property(o => o.Organization_Phone)
            .HasColumnName("Organization_Phone").HasColumnType("varchar(50)");
        builder.Property(o => o.Organization_Deleted)
            .HasColumnName("Organization_Deleted").HasColumnType("datetime");

        builder.HasOne(o => o.Parent)
            .WithMany(o => o.Children)
            .HasForeignKey(o => o.Organization_ParentId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(o => o.OrganizationUsers)
            .WithOne(ou => ou.Organization)
            .HasForeignKey(ou => ou.OrganizationUsers_OrganizationId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(o => o.NewsCategories)
            .WithOne(nc => nc.Organization)
            .HasForeignKey(nc => nc.NewsCtegory_OrganizationId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasMany(o => o.ProjectTypes)
            .WithOne(pt => pt.Organization)
            .HasForeignKey(pt => pt.ProjectType_OrganizationId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasMany(o => o.Themes)
            .WithOne(t => t.Organization)
            .HasForeignKey(t => t.Themes_OrganizationId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}
