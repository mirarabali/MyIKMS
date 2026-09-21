using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using IKMS.Domain.Entities;

namespace IKMS.Domain.Configurations;

public class DomainConfiguration : IEntityTypeConfiguration<Domain>
{
    public void Configure(EntityTypeBuilder<Domain> builder)
    {
        builder.ToTable("Domains");
        builder.HasKey(d => d.Domain_Id);
        builder.Property(d => d.Domain_Title).HasColumnName("Domain_Title").HasColumnType("nvarchar(50)").IsRequired();
        builder.Property(d => d.Domain_Parent).HasColumnName("Domain_Parent");
        builder.Property(d => d.Domain_Description).HasColumnName("Domain_Description").HasColumnType("nvarchar(50)");
        builder.Property(d => d.Domain_StateId).HasColumnName("Domain_StateId");
        builder.Property(d => d.Domain_Deleted).HasColumnName("Domain_Deleted").HasColumnType("datetime");
        builder.HasOne(d => d.Parent).WithMany(d => d.Children).HasForeignKey(d => d.Domain_Parent).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(d => d.State).WithMany(s => s.Domains).HasForeignKey(d => d.Domain_StateId).OnDelete(DeleteBehavior.SetNull);
    }
}

public class ModuleConfiguration : IEntityTypeConfiguration<Module>
{
    public void Configure(EntityTypeBuilder<Module> builder)
    {
        builder.ToTable("Modules");
        builder.HasKey(m => m.Module_Id);
        builder.Property(m => m.Module_Name).HasColumnName("Module_Name").HasColumnType("nvarchar(50)").IsRequired();
        builder.Property(m => m.Module_ParentId).HasColumnName("Module_ParentId");
        builder.Property(m => m.Module_Description).HasColumnName("Module_Description").HasColumnType("nvarchar(50)");
        builder.Property(m => m.Module_Deleted).HasColumnName("Module_Deleted").HasColumnType("datetime");
        builder.HasOne(m => m.Parent).WithMany(m => m.Children).HasForeignKey(m => m.Module_ParentId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class StateConfiguration : IEntityTypeConfiguration<State>
{
    public void Configure(EntityTypeBuilder<State> builder)
    {
        builder.ToTable("States");
        builder.HasKey(s => s.State_Id);
        builder.Property(s => s.State_Title).HasColumnName("State_Title").HasColumnType("nvarchar(50)").IsRequired();
        builder.Property(s => s.State_Deleted).HasColumnName("State_Deleted").HasColumnType("datetime");
    }
}

public class TermConfiguration : IEntityTypeConfiguration<Term>
{
    public void Configure(EntityTypeBuilder<Term> builder)
    {
        builder.ToTable("Terms");
        builder.HasKey(t => t.Term_Id);
        builder.Property(t => t.Term_Title).HasColumnName("Term_Title").HasColumnType("nvarchar(4000)");
        builder.Property(t => t.Term_Description).HasColumnName("Term_Description").HasColumnType("nvarchar(max)");
        builder.Property(t => t.Term_StateId).HasColumnName("Term_StateId");
        builder.Property(t => t.Term_Deleted).HasColumnName("Term_Deleted").HasColumnType("datetime");
        builder.HasOne(t => t.State).WithMany(s => s.Terms).HasForeignKey(t => t.Term_StateId).OnDelete(DeleteBehavior.SetNull);
    }
}

public class TmdConfiguration : IEntityTypeConfiguration<Tmd>
{
    public void Configure(EntityTypeBuilder<Tmd> builder)
    {
        builder.ToTable("TMD");
        builder.HasKey(t => t.TMD_Id);
        builder.Property(t => t.TMD_ModuleId).HasColumnName("TMD_ModuleId").IsRequired();
        builder.Property(t => t.TMD_DomainId).HasColumnName("TMD_DomainId").IsRequired();
        builder.Property(t => t.TMD_TermId).HasColumnName("TMD_TermId").IsRequired();
        builder.Property(t => t.TMD_StateId).HasColumnName("TMD_StateId"); // Legacy - do not write (CONV-04)
        builder.Property(t => t.TMD_IsPreferred).HasColumnName("TMD_IsPreferred");
        builder.Property(t => t.TMD_Deleted).HasColumnName("TMD_Deleted").HasColumnType("datetime");
        builder.Property(t => t.State_Id).HasColumnName("State_Id"); // Authoritative (CONV-04)
        builder.HasOne(t => t.Module).WithMany(m => m.TMDs).HasForeignKey(t => t.TMD_ModuleId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(t => t.Domain).WithMany(d => d.TMDs).HasForeignKey(t => t.TMD_DomainId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(t => t.Term).WithMany(t => t.TMDs).HasForeignKey(t => t.TMD_TermId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(t => t.State).WithMany(s => s.TMDs).HasForeignKey(t => t.State_Id).OnDelete(DeleteBehavior.SetNull);
    }
}

public class RelationsTypeConfiguration : IEntityTypeConfiguration<RelationsType>
{
    public void Configure(EntityTypeBuilder<RelationsType> builder)
    {
        builder.ToTable("RelationsTypes");
        builder.HasKey(r => r.RelationsType_Id);
        builder.Property(r => r.RelationsType_ParentId).HasColumnName("RelationsType_ParentId");
        builder.Property(r => r.RelationsType_Title).HasColumnName("RelationsType_Title").HasColumnType("nvarchar(50)").IsRequired();
        builder.Property(r => r.RelationsType_Description).HasColumnName("RelationsType_Description").HasColumnType("nvarchar(max)");
        builder.Property(r => r.RelationsType_Deleted).HasColumnName("RelationsType_Deleted").HasColumnType("datetime");
        builder.Property(r => r.RelationsType_ReverseTitle).HasColumnName("RelationsType_ReverseTitle").HasColumnType("nvarchar(50)");
        builder.Property(r => r.RelationsType_IsNodeLabel).HasColumnName("RelationsType_IsNodeLabel").IsRequired();
        builder.Property(r => r.RelationsType_DataTypeId).HasColumnName("RelationsType_DataTypeId"); // Duality marker (CONV-05)
        builder.Property(r => r.RelationsType_IsSystemDefined).HasColumnName("RelationsType_IsSystemDefined").IsRequired();
        builder.Property(r => r.RelationsType_Code).HasColumnName("RelationsType_Code").HasColumnType("nvarchar(150)");
        builder.Property(r => r.RelationsType_IsHierarchical).HasColumnName("RelationsType_IsHierarchical").IsRequired();
        builder.Property(r => r.RelationsType_IsTransitive).HasColumnName("RelationsType_IsTransitive").IsRequired();
        builder.Property(r => r.RelationsType_IsAsymmetric).HasColumnName("RelationsType_IsAsymmetric").IsRequired();
        builder.Property(r => r.RelationsType_IsEquivalence).HasColumnName("RelationsType_IsEquivalence").IsRequired();
        builder.Property(r => r.RelationsType_IsIrreflexive).HasColumnName("RelationsType_IsIrreflexive").IsRequired();
        builder.HasOne(r => r.Parent).WithMany(r => r.Children).HasForeignKey(r => r.RelationsType_ParentId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(r => r.DataType).WithMany(r => r.DataTypes).HasForeignKey(r => r.RelationsType_DataTypeId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class MrtConfiguration : IEntityTypeConfiguration<Mrt>
{
    public void Configure(EntityTypeBuilder<Mrt> builder)
    {
        builder.ToTable("MRT");
        builder.HasKey(m => m.MRT_Id);
        builder.Property(m => m.MRT_ModuleId).HasColumnName("MRT_ModuleId").IsRequired();
        builder.Property(m => m.MRT_RelationTypeId).HasColumnName("MRT_RelationTypeId").IsRequired();
        builder.Property(m => m.MRT_Deleted).HasColumnName("MRT_Deleted").HasColumnType("datetime");
        builder.HasOne(m => m.Module).WithMany(mod => mod.MRTs).HasForeignKey(m => m.MRT_ModuleId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(m => m.RelationType).WithMany(r => r.MRTs).HasForeignKey(m => m.MRT_RelationTypeId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class RelationConstraintConfiguration : IEntityTypeConfiguration<RelationConstraint>
{
    public void Configure(EntityTypeBuilder<RelationConstraint> builder)
    {
        builder.ToTable("RelationConstraints");
        builder.HasKey(r => r.Id);
        builder.Property(r => r.Mrt_Id).HasColumnName("Mrt_Id").IsRequired();
        builder.Property(r => r.ConstraintName).HasColumnName("ConstraintName").HasColumnType("nvarchar(100)");
        builder.Property(r => r.SqlCondition).HasColumnName("SqlCondition").HasColumnType("nvarchar(max)"); // NEVER executed (INV-07)
        builder.Property(r => r.ErrorMessage).HasColumnName("ErrorMessage").HasColumnType("nvarchar(500)");
        builder.Property(r => r.MinCardinallity).HasColumnName("MinCardinallity").HasColumnType("nvarchar(max)"); // Legacy spelling (CONV-03)
        builder.Property(r => r.MaxCardinallity).HasColumnName("MaxCardinallity").HasColumnType("nvarchar(max)");
        builder.Property(r => r.IsActive).HasColumnName("IsActive");
        builder.Property(r => r.Deleted).HasColumnName("Deleted").HasColumnType("datetime");
        builder.HasOne(r => r.Mrt).WithMany(m => m.Constraints).HasForeignKey(r => r.Mrt_Id).OnDelete(DeleteBehavior.Restrict);
    }
}

public class RelationConfiguration : IEntityTypeConfiguration<Relation>
{
    public void Configure(EntityTypeBuilder<Relation> builder)
    {
        builder.ToTable("Relations");
        builder.HasKey(r => r.TermsRelation_Id);
        builder.Property(r => r.First_TMDId).HasColumnName("First_TMDId").IsRequired();
        builder.Property(r => r.TermsRelation_TypeId).HasColumnName("TermsRelation_TypeId").IsRequired();
        builder.Property(r => r.Second_TMDId).HasColumnName("Second_TMDId").IsRequired();
        builder.Property(r => r.TermsRelation_Priority).HasColumnName("TermsRelation_Priority");
        builder.Property(r => r.TermsRelation_Level).HasColumnName("TermsRelation_Level");
        builder.Property(r => r.TermsRelation_Description).HasColumnName("TermsRelation_Description").HasColumnType("nvarchar(max)"); // Locator/time-code (CONV-01/02)
        builder.Property(r => r.Deleted).HasColumnName("Deleted").HasColumnType("datetime");
        builder.HasOne(r => r.FirstTmd).WithMany(t => t.FirstRelations).HasForeignKey(r => r.First_TMDId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(r => r.RelationType).WithMany(rt => rt.Relations).HasForeignKey(r => r.TermsRelation_TypeId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(r => r.SecondTmd).WithMany(t => t.SecondRelations).HasForeignKey(r => r.Second_TMDId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class DocContentConfiguration : IEntityTypeConfiguration<DocContent>
{
    public void Configure(EntityTypeBuilder<DocContent> builder)
    {
        builder.ToTable("DocContent");
        builder.HasKey(d => d.DocContent_Id);
        builder.Property(d => d.DocContent_TMDId).HasColumnName("DocContent_TMDId").IsRequired();
        builder.Property(d => d.DocContent_VolumeNo).HasColumnName("DocContent_VolumeNo");
        builder.Property(d => d.DocContent_SectionNo).HasColumnName("DocContent_SectionNo");
        builder.Property(d => d.DocContent_PageNo).HasColumnName("DocContent_PageNo");
        builder.Property(d => d.DocContent_ParagraphNo).HasColumnName("DocContent_ParagraphNo");
        builder.Property(d => d.DocContent_Text).HasColumnName("DocContent_Text").HasColumnType("text");
        builder.Property(d => d.DocContent_Deleted).HasColumnName("DocContent_Deleted").HasColumnType("datetime");
        builder.HasOne(d => d.Tmd).WithMany(t => t.DocContents).HasForeignKey(d => d.DocContent_TMDId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class FileConfiguration : IEntityTypeConfiguration<File>
{
    public void Configure(EntityTypeBuilder<File> builder)
    {
        builder.ToTable("Files");
        builder.HasKey(f => f.File_Id);
        builder.Property(f => f.File_Title).HasColumnName("File_Title").IsRequired();
        builder.Property(f => f.File_TableName).HasColumnName("File_TableName").HasColumnType("varchar(50)").IsRequired(); // Whitelist validated (CONV-07)
        builder.Property(f => f.File_TableRecordId).HasColumnName("File_TableRecordId").IsRequired();
        builder.Property(f => f.File_Description).HasColumnName("File_Description").IsRequired();
        builder.Property(f => f.File_Address).HasColumnName("File_Address").HasColumnType("nvarchar(max)").IsRequired();
        builder.Property(f => f.File_Deleted).HasColumnName("File_Deleted").HasColumnType("datetime");
    }
}

public class LogConfiguration : IEntityTypeConfiguration<Log>
{
    public void Configure(EntityTypeBuilder<Log> builder)
    {
        builder.ToTable("Logs");
        builder.HasKey(l => l.Log_Id);
        builder.Property(l => l.Log_TableName).HasColumnName("Log_TableName").HasColumnType("nvarchar(200)").IsRequired();
        builder.Property(l => l.Log_TableRecordId).HasColumnName("Log_TableRecordId").IsRequired();
        builder.Property(l => l.Log_TypeId).HasColumnName("Log_TypeId").IsRequired();
        builder.Property(l => l.Log_Activity).HasColumnName("Log_Activity").IsRequired(); // JSON snapshot (CONV-09)
        builder.Property(l => l.Log_UserId).HasColumnName("Log_UserId").IsRequired();
        builder.Property(l => l.Log_CreatedDateTime).HasColumnName("Log_CreatedDateTime").IsRequired();
        builder.HasOne(l => l.LogType).WithMany(lt => lt.Logs).HasForeignKey(l => l.Log_TypeId).OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(l => l.User).WithMany(u => u.Logs).HasForeignKey(l => l.Log_UserId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class LogTypeConfiguration : IEntityTypeConfiguration<LogType>
{
    public void Configure(EntityTypeBuilder<LogType> builder)
    {
        builder.ToTable("LogType");
        builder.HasKey(l => l.LogType_Id);
        builder.Property(l => l.LogType_Name).HasColumnName("LogType_Name").HasColumnType("nvarchar(100)");
        builder.Property(l => l.LogType_Deleted).HasColumnName("LogType_Deleted").HasColumnType("datetime");
    }
}
