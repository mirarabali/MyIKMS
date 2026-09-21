using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using IKMS.Domain.Entities;

namespace IKMS.Domain.Configurations;

public class NewsConfiguration : IEntityTypeConfiguration<News>
{
    public void Configure(EntityTypeBuilder<News> builder)
    {
        builder.ToTable("News");
        builder.HasKey(n => n.News_Id);
        builder.Property(n => n.News_Title).HasColumnName("News_Title").IsRequired();
        builder.Property(n => n.News_Abstract).HasColumnName("News_Abstract");
        builder.Property(n => n.News_Content).HasColumnName("News_Content").HasColumnType("text");
        builder.Property(n => n.News_Link).HasColumnName("News_Link").HasColumnType("nvarchar(4000)");
        builder.Property(n => n.News_Deleted).HasColumnName("News_Deleted").HasColumnType("datetime");
    }
}

public class NewsCategoryConfiguration : IEntityTypeConfiguration<NewsCategory>
{
    public void Configure(EntityTypeBuilder<NewsCategory> builder)
    {
        builder.ToTable("NewsCategory");
        builder.HasKey(n => n.NewsCtegory_Id); // Legacy spelling (INV-01)
        builder.Property(n => n.NewsCtegory_Title).HasColumnName("NewsCtegory_Title").IsRequired();
        builder.Property(n => n.NewsCtegory_Description).HasColumnName("NewsCtegory_Description").IsRequired();
        builder.Property(n => n.NewsCtegory_Image).HasColumnName("NewsCtegory_Image");
        builder.Property(n => n.NewsCtegory_OrganizationId).HasColumnName("NewsCtegory_OrganizationId");
        builder.Property(n => n.NewsCtegory_Deleted).HasColumnName("NewsCtegory_Deleted").HasColumnType("datetime");
        builder.HasOne(n => n.Organization).WithMany(o => o.NewsCategories).HasForeignKey(n => n.NewsCtegory_OrganizationId).OnDelete(DeleteBehavior.SetNull);
    }
}

public class NewsRelNewsCategoryConfiguration : IEntityTypeConfiguration<NewsRelNewsCategory>
{
    public void Configure(EntityTypeBuilder<NewsRelNewsCategory> builder)
    {
        builder.ToTable("NewsRelNewsCategory");
        builder.HasKey(n => n.NewsRelNewsCategory_Id);
        builder.Property(n => n.NewsRelNewsCategory_NewsId).HasColumnName("NewsRelNewsCategory_NewsId").IsRequired();
        builder.Property(n => n.NewsRelNewsCategory_NewsCategoryId).HasColumnName("NewsRelNewsCategory_NewsCategoryId").IsRequired();
        builder.Property(n => n.NewsRelNewsCategory_Deleted).HasColumnName("NewsRelNewsCategory_Deleted").HasColumnType("datetime");
        builder.HasOne(n => n.News).WithMany(news => news.NewsRelNewsCategories).HasForeignKey(n => n.NewsRelNewsCategory_NewsId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(n => n.NewsCategory).WithMany(nc => nc.NewsRelNewsCategories).HasForeignKey(n => n.NewsRelNewsCategory_NewsCategoryId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class NewsRelTagConfiguration : IEntityTypeConfiguration<NewsRelTag>
{
    public void Configure(EntityTypeBuilder<NewsRelTag> builder)
    {
        builder.ToTable("NewsRelTags");
        builder.HasKey(n => n.NewsRelTags_Id);
        builder.Property(n => n.NewsRelTags_NewsId).HasColumnName("NewsRelTags_NewsId").IsRequired();
        builder.Property(n => n.NewsRelTags_TagId).HasColumnName("NewsRelTags_TagId").IsRequired();
        builder.Property(n => n.NewsRelTags_Deleted).HasColumnName("NewsRelTags_Deleted").HasColumnType("datetime");
        builder.HasOne(n => n.News).WithMany(news => news.NewsRelTags).HasForeignKey(n => n.NewsRelTags_NewsId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(n => n.Tag).WithMany(t => t.NewsRelTags).HasForeignKey(n => n.NewsRelTags_TagId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class ProjectTypeConfiguration : IEntityTypeConfiguration<ProjectType>
{
    public void Configure(EntityTypeBuilder<ProjectType> builder)
    {
        builder.ToTable("ProjectType");
        builder.HasKey(p => p.ProjectType_Id);
        builder.Property(p => p.ProjectType_Name).HasColumnName("ProjectType_Name").IsRequired();
        builder.Property(p => p.ProjectType_OrganizationId).HasColumnName("ProjectType_OrganizationId");
        builder.Property(p => p.ProjectType_Deleted).HasColumnName("ProjectType_Deleted").HasColumnType("datetime");
        builder.HasOne(p => p.Organization).WithMany(o => o.ProjectTypes).HasForeignKey(p => p.ProjectType_OrganizationId).OnDelete(DeleteBehavior.SetNull);
    }
}

public class ProjectConfiguration : IEntityTypeConfiguration<Project>
{
    public void Configure(EntityTypeBuilder<Project> builder)
    {
        builder.ToTable("Projects");
        builder.HasKey(p => p.Project_Id);
        builder.Property(p => p.Project_Title).HasColumnName("Project_Title").IsRequired();
        builder.Property(p => p.Project_ProjectTypeId).HasColumnName("Project_ProjectTypeId").IsRequired();
        builder.Property(p => p.Project_ProcessId).HasColumnName("Project_ProcessId").IsRequired();
        builder.Property(p => p.Project_StartDate).HasColumnName("Project_StartDate").HasColumnType("datetime2(7)");
        builder.Property(p => p.Project_EndDate).HasColumnName("Project_EndDate").HasColumnType("datetime2(7)");
        builder.Property(p => p.Project_ChangeProcessDate).HasColumnName("Project_ChangeProcessDate").HasColumnType("datetime2(7)");
        builder.Property(p => p.Project_Deleted).HasColumnName("Project_Deleted").HasColumnType("datetime");
        builder.Property(p => p.Project_PreviousStepText).HasColumnName("Project_PreviousStepText").HasColumnType("nvarchar(max)");
        builder.HasOne(p => p.ProjectType).WithMany(pt => pt.Projects).HasForeignKey(p => p.Project_ProjectTypeId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(p => p.Process).WithMany(pr => pr.Projects).HasForeignKey(p => p.Project_ProcessId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class ProcessConfiguration : IEntityTypeConfiguration<Process>
{
    public void Configure(EntityTypeBuilder<Process> builder)
    {
        builder.ToTable("Process");
        builder.HasKey(p => p.Process_Id);
        builder.Property(p => p.Process_StateId).HasColumnName("Process_StateId").IsRequired();
        builder.Property(p => p.Process_ProjectTypeId).HasColumnName("Process_ProjectTypeId").IsRequired();
        builder.Property(p => p.Process_ApiId).HasColumnName("Process_ApiId");
        builder.Property(p => p.Process_Next).HasColumnName("Process_Next");
        builder.Property(p => p.Process_Previous).HasColumnName("Process_Previous");
        builder.Property(p => p.Process_Duration).HasColumnName("Process_Duration");
        builder.Property(p => p.Process_Condition).HasColumnName("Process_Condition").HasColumnType("text"); // NEVER executed (INV-07)
        builder.Property(p => p.Process_Deleted).HasColumnName("Process_Deleted").HasColumnType("datetime");
        builder.Property(p => p.Process_RoleId).HasColumnName("Process_RoleId");
        builder.HasOne(p => p.State).WithMany(s => s.Processes).HasForeignKey(p => p.Process_StateId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(p => p.ProjectType).WithMany(pt => pt.Processes).HasForeignKey(p => p.Process_ProjectTypeId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(p => p.ApiEndpoint).WithMany(a => a.Permissions).HasForeignKey(p => p.Process_ApiId).OnDelete(DeleteBehavior.SetNull);
        builder.HasOne(p => p.Role).WithMany(r => r.Processes).HasForeignKey(p => p.Process_RoleId).OnDelete(DeleteBehavior.SetNull);
    }
}

public class ProjectUserConfiguration : IEntityTypeConfiguration<ProjectUser>
{
    public void Configure(EntityTypeBuilder<ProjectUser> builder)
    {
        builder.ToTable("ProjectUsers");
        builder.HasKey(p => p.ProjectUser_Id);
        builder.Property(p => p.ProjectUser_UserId).HasColumnName("ProjectUser_UserId").IsRequired();
        builder.Property(p => p.ProjectUser_ProjectId).HasColumnName("ProjectUser_ProjectId").IsRequired();
        builder.Property(p => p.ProjectUser_Deleted).HasColumnName("ProjectUser_Deleted").HasColumnType("datetime");
        builder.HasOne(p => p.User).WithMany(u => u.ProjectUsers).HasForeignKey(p => p.ProjectUser_UserId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(p => p.Project).WithMany(pr => pr.ProjectUsers).HasForeignKey(p => p.ProjectUser_ProjectId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class PaymentConfiguration : IEntityTypeConfiguration<Payment>
{
    public void Configure(EntityTypeBuilder<Payment> builder)
    {
        builder.ToTable("Payments");
        builder.HasKey(p => p.Payment_Id);
        builder.Property(p => p.Payment_OrganizationUserId).HasColumnName("Payment_OrganizationUserId").IsRequired();
        builder.Property(p => p.Payment_Cost).HasColumnName("Payment_Cost").IsRequired();
        builder.Property(p => p.Payment_ProjectId).HasColumnName("Payment_ProjectId").IsRequired();
        builder.Property(p => p.Payment_Deleted).HasColumnName("Payment_Deleted").HasColumnType("datetime");
        builder.HasOne(p => p.OrganizationUser).WithMany(o => o.Payments).HasForeignKey(p => p.Payment_OrganizationUserId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(p => p.Project).WithMany(pr => pr.Payments).HasForeignKey(p => p.Payment_ProjectId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class TmdpConfiguration : IEntityTypeConfiguration<Tmdp>
{
    public void Configure(EntityTypeBuilder<Tmdp> builder)
    {
        builder.ToTable("TMDP");
        builder.HasKey(t => t.TMDP_Id);
        builder.Property(t => t.TMDP_TMDId).HasColumnName("TMDP_TMDId").IsRequired();
        builder.Property(t => t.TMDP_ProjectId).HasColumnName("TMDP_ProjectId").IsRequired();
        builder.Property(t => t.TMDP_StateId).HasColumnName("TMDP_StateId").IsRequired();
        builder.Property(t => t.TMDP_StartDate).HasColumnName("TMDP_StartDate").HasColumnType("datetime2(7)");
        builder.Property(t => t.TMDP_EndDate).HasColumnName("TMDP_EndDate").HasColumnType("datetime2(7)");
        builder.Property(t => t.TMDP_Deleted).HasColumnName("TMDP_Deleted").HasColumnType("datetime");
        builder.HasOne(t => t.Tmd).WithMany(tm => tm.TMDPs).HasForeignKey(t => t.TMDP_TMDId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(t => t.Project).WithMany(p => p.TMDPs).HasForeignKey(t => t.TMDP_ProjectId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(t => t.State).WithMany(s => s.TMDPs).HasForeignKey(t => t.TMDP_StateId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class ThemeConfiguration : IEntityTypeConfiguration<Theme>
{
    public void Configure(EntityTypeBuilder<Theme> builder)
    {
        builder.ToTable("Themes");
        builder.HasKey(t => t.Themes_Id);
        builder.Property(t => t.Themes_Name).HasColumnName("Themes_Name").IsRequired();
        builder.Property(t => t.Themes_OrganizationId).HasColumnName("Themes_OrganizationId");
        builder.Property(t => t.Themes_ModuleId).HasColumnName("Themes_ModuleId");
        builder.Property(t => t.Themes_DomainId).HasColumnName("Themes_DomainId");
        builder.Property(t => t.Themes_ThemeTypeId).HasColumnName("Themes_ThemeTypeId");
        builder.Property(t => t.Themes_Code).HasColumnName("Themes_Code").IsRequired();
        builder.Property(t => t.Themes_Deleted).HasColumnName("Themes_Deleted").HasColumnType("datetime");
        builder.HasOne(t => t.Organization).WithMany(o => o.Themes).HasForeignKey(t => t.Themes_OrganizationId).OnDelete(DeleteBehavior.SetNull);
        builder.HasOne(t => t.Module).WithMany(m => m.Themes).HasForeignKey(t => t.Themes_ModuleId).OnDelete(DeleteBehavior.SetNull);
        builder.HasOne(t => t.Domain).WithMany(d => d.Themes).HasForeignKey(t => t.Themes_DomainId).OnDelete(DeleteBehavior.SetNull);
        builder.HasOne(t => t.ThemeType).WithMany(tt => tt.Themes).HasForeignKey(t => t.Themes_ThemeTypeId).OnDelete(DeleteBehavior.SetNull);
    }
}

public class ThemeTypeConfiguration : IEntityTypeConfiguration<ThemeType>
{
    public void Configure(EntityTypeBuilder<ThemeType> builder)
    {
        builder.ToTable("ThemeTypes");
        builder.HasKey(t => t.ThemeType_Id);
        builder.Property(t => t.ThemeType_Name).HasColumnName("ThemeType_Name").IsRequired();
        builder.Property(t => t.ThemeTypes_Deleted).HasColumnName("ThemeTypes_Deleted").HasColumnType("datetime");
    }
}
