using System;
using System.Collections.Generic;

namespace IKMS.Domain.Entities;

/// <summary>
/// Domains — دامنه‌ها و حوزه‌های موضوعی مانند فقه، کلام و مدیریت اطلاعات را به‌صورت…
/// </summary>
public class Domain
{
    public int Domain_Id { get; set; }  // PK
    public string Domain_Title { get; set; } = null!;  // NN nvarchar(50)
    public int? Domain_Parent { get; set; }  // →Domains.Domain_Id
    public string? Domain_Description { get; set; }  // nvarchar(50)
    public int? Domain_StateId { get; set; }  // →States.State_Id
    public DateTime? Domain_Deleted { get; set; }  // datetime

    public virtual Domain? Parent { get; set; }
    public virtual ICollection<Domain> Children { get; set; } = new List<Domain>();
    public virtual State? State { get; set; }
    public virtual ICollection<Tmd> TMDs { get; set; } = new List<Tmd>();
    public virtual ICollection<Theme> Themes { get; set; } = new List<Theme>();
}

/// <summary>
/// Modules — ماژول‌های پویا و سلسله‌مراتبی سامانه، مانند اصطلاح‌نامه، هستی‌شناسی، گراف…
/// </summary>
public class Module
{
    public int Module_Id { get; set; }  // PK
    public string Module_Name { get; set; } = null!;  // NN nvarchar(50)
    public int? Module_ParentId { get; set; }  // →Modules.Module_Id
    public string? Module_Description { get; set; }  // nvarchar(50)
    public DateTime? Module_Deleted { get; set; }  // datetime

    public virtual Module? Parent { get; set; }
    public virtual ICollection<Module> Children { get; set; } = new List<Module>();
    public virtual ICollection<Tmd> TMDs { get; set; } = new List<Tmd>();
    public virtual ICollection<Mrt> MRTs { get; set; } = new List<Mrt>();
    public virtual ICollection<Theme> Themes { get; set; } = new List<Theme>();
}

/// <summary>
/// States — فهرست عمومی وضعیت‌های قابل استفاده در بخش‌های مختلف سامانه را نگهداری…
/// </summary>
public class State
{
    public int State_Id { get; set; }  // PK
    public string State_Title { get; set; } = null!;  // NN nvarchar(50)
    public DateTime? State_Deleted { get; set; }  // datetime

    public virtual ICollection<Domain> Domains { get; set; } = new List<Domain>();
    public virtual ICollection<Term> Terms { get; set; } = new List<Term>();
    public virtual ICollection<Tmd> TMDs { get; set; } = new List<Tmd>();
    public virtual ICollection<Tmdp> TMDPs { get; set; } = new List<Tmdp>();
    public virtual ICollection<Process> Processes { get; set; } = new List<Process>();
}

/// <summary>
/// Terms — اطلاعات پایه اصطلاحات، مفاهیم، عناوین، نام‌ها یا مدخل‌های دانشی را نگهداری…
/// </summary>
public class Term
{
    public int Term_Id { get; set; }  // PK
    public string? Term_Title { get; set; }  // nvarchar(4000)
    public string? Term_Description { get; set; }  // nvarchar(max)
    public int? Term_StateId { get; set; }  // →States.State_Id
    public DateTime? Term_Deleted { get; set; }  // datetime

    public virtual State? State { get; set; }
    public virtual ICollection<Tmd> TMDs { get; set; } = new List<Tmd>();
    public virtual ICollection<NewsRelTag> NewsRelTags { get; set; } = new List<NewsRelTag>();
}

/// <summary>
/// TMD — جدول محوری «اصطلاح ـ ماژول ـ دامنه» است و مشخص می‌کند یک اصطلاح در کدام…
/// Central graph node (Term × Module × Domain). State_Id is authoritative (CONV-04).
/// </summary>
public class Tmd
{
    public int TMD_Id { get; set; }  // PK
    public int TMD_ModuleId { get; set; }  // →Modules.Module_Id
    public int TMD_DomainId { get; set; }  // →Domains.Domain_Id
    public int TMD_TermId { get; set; }  // →Terms.Term_Id
    public int? TMD_StateId { get; set; }  // legacy - do not write (CONV-04)
    public bool? TMD_IsPreferred { get; set; }  // bit
    public DateTime? TMD_Deleted { get; set; }  // datetime
    public int? State_Id { get; set; }  // →States.State_Id - authoritative (CONV-04)

    public virtual Module Module { get; set; } = null!;
    public virtual Domain Domain { get; set; } = null!;
    public virtual Term Term { get; set; } = null!;
    public virtual State? State { get; set; }
    public virtual ICollection<Relation> FirstRelations { get; set; } = new List<Relation>();
    public virtual ICollection<Relation> SecondRelations { get; set; } = new List<Relation>();
    public virtual ICollection<DocContent> DocContents { get; set; } = new List<DocContent>();
    public virtual ICollection<Tmdp> TMDPs { get; set; } = new List<Tmdp>();
}

/// <summary>
/// RelationsTypes — انواع روابط، ویژگی‌ها و فیلدهای سفارشی قابل استفاده در ساختار پویای…
/// Duality: attribute/field type when DataTypeId is set, otherwise semantic relation type (CONV-05).
/// </summary>
public class RelationsType
{
    public int RelationsType_Id { get; set; }  // PK
    public int? RelationsType_ParentId { get; set; }  // →RelationsTypes.RelationsType_Id
    public string RelationsType_Title { get; set; } = null!;  // NN nvarchar(50)
    public string? RelationsType_Description { get; set; }  // nvarchar(max)
    public DateTime? RelationsType_Deleted { get; set; }  // datetime
    public string? RelationsType_ReverseTitle { get; set; }  // nvarchar(50)
    public bool RelationsType_IsNodeLabel { get; set; }  // NN bit
    public int? RelationsType_DataTypeId { get; set; }  // →RelationsTypes.RelationsType_Id - duality marker (CONV-05)
    public bool RelationsType_IsSystemDefined { get; set; }  // NN bit
    public string? RelationsType_Code { get; set; }  // nvarchar(150)
    public bool RelationsType_IsHierarchical { get; set; }  // NN bit
    public bool RelationsType_IsTransitive { get; set; }  // NN bit
    public bool RelationsType_IsAsymmetric { get; set; }  // NN bit
    public bool RelationsType_IsEquivalence { get; set; }  // NN bit
    public bool RelationsType_IsIrreflexive { get; set; }  // NN bit

    public virtual RelationsType? Parent { get; set; }
    public virtual ICollection<RelationsType> Children { get; set; } = new List<RelationsType>();
    public virtual RelationsType? DataType { get; set; }
    public virtual ICollection<RelationsType> DataTypes { get; set; } = new List<RelationsType>();
    public virtual ICollection<Mrt> MRTs { get; set; } = new List<Mrt>();
    public virtual ICollection<Relation> Relations { get; set; } = new List<Relation>();
}

/// <summary>
/// MRT — جدول واسط «ماژول ـ نوع رابطه» است و تعیین می‌کند در هر ماژول چه انواع…
/// </summary>
public class Mrt
{
    public int MRT_Id { get; set; }  // PK
    public int MRT_ModuleId { get; set; }  // →Modules.Module_Id
    public int MRT_RelationTypeId { get; set; }  // →RelationsTypes.RelationsType_Id
    public DateTime? MRT_Deleted { get; set; }  // datetime

    public virtual Module Module { get; set; } = null!;
    public virtual RelationsType RelationType { get; set; } = null!;
    public virtual ICollection<RelationConstraint> Constraints { get; set; } = new List<RelationConstraint>();
}

/// <summary>
/// RelationConstraints — محدودیت‌ها و قواعد اعتبارسنجی مربوط به یک نوع رابطه در یک ماژول را تعریف…
/// SqlCondition is read ONLY by whitelisted parser (INV-07). Cardinality strings per CONV-03.
/// </summary>
public class RelationConstraint
{
    public int Id { get; set; }  // PK
    public int Mrt_Id { get; set; }  // →MRT.MRT_Id
    public string? ConstraintName { get; set; }  // nvarchar(100)
    public string? SqlCondition { get; set; }  // nvarchar(max) - NEVER executed directly (INV-07)
    public string? ErrorMessage { get; set; }  // nvarchar(500)
    public string? MinCardinallity { get; set; }  // nvarchar(max) - legacy spelling (CONV-03)
    public string? MaxCardinallity { get; set; }  // nvarchar(max) - legacy spelling (CONV-03)
    public bool? IsActive { get; set; }  // bit
    public DateTime? Deleted { get; set; }  // datetime

    public virtual Mrt Mrt { get; set; } = null!;
}

/// <summary>
/// Relations — نمونه‌های واقعی رابطه میان دو موجودیت TMD را نگهداری می‌کند.
/// Description stores locator (CONV-01) or time-code (CONV-02) strings.
/// </summary>
public class Relation
{
    public int TermsRelation_Id { get; set; }  // PK
    public int First_TMDId { get; set; }  // →TMD.TMD_Id
    public int TermsRelation_TypeId { get; set; }  // →RelationsTypes.RelationsType_Id
    public int Second_TMDId { get; set; }  // →TMD.TMD_Id
    public int? TermsRelation_Priority { get; set; }  // int
    public int? TermsRelation_Level { get; set; }  // int
    public string? TermsRelation_Description { get; set; }  // nvarchar(max) - locator/time-code (CONV-01/02)
    public DateTime? Deleted { get; set; }  // datetime

    public virtual Tmd FirstTmd { get; set; } = null!;
    public virtual RelationsType RelationType { get; set; } = null!;
    public virtual Tmd SecondTmd { get; set; } = null!;
}

/// <summary>
/// DocContent — محتوای متنی منابع دیجیتال را در سطح جلد، بخش، صفحه و بند ذخیره می‌کند.
/// </summary>
public class DocContent
{
    public int DocContent_Id { get; set; }  // PK
    public int DocContent_TMDId { get; set; }  // →TMD.TMD_Id
    public int? DocContent_VolumeNo { get; set; }  // int
    public int? DocContent_SectionNo { get; set; }  // int
    public int? DocContent_PageNo { get; set; }  // int
    public int? DocContent_ParagraphNo { get; set; }  // int
    public string? DocContent_Text { get; set; }  // text
    public DateTime? DocContent_Deleted { get; set; }  // datetime

    public virtual Tmd Tmd { get; set; } = null!;
}

/// <summary>
/// Files — اطلاعات و نشانی تمام فایل‌های مورد استفاده سامانه، مانند تصویر خبر، فایل…
/// TableName must be validated against whitelist (CONV-07, INV-07).
/// </summary>
public class File
{
    public int File_Id { get; set; }  // PK
    public string File_Title { get; set; } = null!;  // NN text
    public string File_TableName { get; set; } = null!;  // NN varchar(50) - whitelist validated (CONV-07)
    public int File_TableRecordId { get; set; }  // NN int
    public string File_Description { get; set; } = null!;  // NN text
    public string File_Address { get; set; } = null!;  // NN nvarchar(max)
    public DateTime? File_Deleted { get; set; }  // datetime
}

/// <summary>
/// Logs — رویدادها و فعالیت‌های انجام‌شده روی رکوردهای سامانه را برای ثبت سابقه و…
/// Log_Activity stores JSON snapshot for audit/version history (CONV-09).
/// </summary>
public class Log
{
    public int Log_Id { get; set; }  // PK
    public string Log_TableName { get; set; } = null!;  // NN nvarchar(200)
    public int Log_TableRecordId { get; set; }  // NN int
    public int Log_TypeId { get; set; }  // →LogType.LogType_Id
    public string Log_Activity { get; set; } = null!;  // NN text - JSON snapshot (CONV-09)
    public int Log_UserId { get; set; }  // →Users.User_Id
    public DateTime Log_CreatedDateTime { get; set; }  // NN datetime

    public virtual LogType LogType { get; set; } = null!;
    public virtual User User { get; set; } = null!;
}

/// <summary>
/// LogType — انواع رویدادهای قابل ثبت در سیستم، مانند ایجاد، ویرایش، حذف، ورود، خروج یا…
/// </summary>
public class LogType
{
    public int LogType_Id { get; set; }  // PK
    public string? LogType_Name { get; set; }  // nvarchar(100)
    public DateTime? LogType_Deleted { get; set; }  // datetime

    public virtual ICollection<Log> Logs { get; set; } = new List<Log>();
}
