using System;
using System.Collections.Generic;

namespace IKMS.Domain.Entities;

/// <summary>
/// News — خبرها و محتوای اطلاع‌رسانی سامانه را شامل عنوان، خلاصه، متن کامل و پیوند…
/// Note: News uses direct tables, NOT routed through TMD/Modules (§6/L6).
/// </summary>
public class News
{
    public int News_Id { get; set; }  // PK
    public string News_Title { get; set; } = null!;  // NN nvarchar(max)
    public string? News_Abstract { get; set; }  // nvarchar(max)
    public string? News_Content { get; set; }  // text
    public string? News_Link { get; set; }  // nvarchar(4000)
    public DateTime? News_Deleted { get; set; }  // datetime

    public virtual ICollection<NewsRelNewsCategory> NewsRelNewsCategories { get; set; } = new List<NewsRelNewsCategory>();
    public virtual ICollection<NewsRelTag> NewsRelTags { get; set; } = new List<NewsRelTag>();
}

/// <summary>
/// NewsCategory — دسته‌بندی‌های خبر متعلق به هر سازمان را همراه با عنوان، توضیح و تصویر…
/// Note: Column names preserve legacy misspelling NewsCtegory_* (INV-01).
/// </summary>
public class NewsCategory
{
    public int NewsCtegory_Id { get; set; }  // PK - legacy spelling preserved
    public string NewsCtegory_Title { get; set; } = null!;  // NN nvarchar(max)
    public string NewsCtegory_Description { get; set; } = null!;  // NN nvarchar(max)
    public string? NewsCtegory_Image { get; set; }  // NN nvarchar(max)
    public int? NewsCtegory_OrganizationId { get; set; }  // →Organizations.Organization_Id
    public DateTime? NewsCtegory_Deleted { get; set; }  // datetime

    public virtual Organization? Organization { get; set; }
    public virtual ICollection<NewsRelNewsCategory> NewsRelNewsCategories { get; set; } = new List<NewsRelNewsCategory>();
}

/// <summary>
/// NewsRelNewsCategory — جدول واسط میان خبرها و دسته‌بندی‌های خبری است و امکان انتساب هر خبر به یک…
/// </summary>
public class NewsRelNewsCategory
{
    public int NewsRelNewsCategory_Id { get; set; }  // PK
    public int NewsRelNewsCategory_NewsId { get; set; }  // →News.News_Id
    public int NewsRelNewsCategory_NewsCategoryId { get; set; }  // →NewsCategory.NewsCtegory_Id
    public DateTime? NewsRelNewsCategory_Deleted { get; set; }  // datetime

    public virtual News News { get; set; } = null!;
    public virtual NewsCategory NewsCategory { get; set; } = null!;
}

/// <summary>
/// NewsRelTags — جدول واسط میان خبرها و اصطلاحات مورد استفاده به‌عنوان برچسب است.
/// </summary>
public class NewsRelTag
{
    public int NewsRelTags_Id { get; set; }  // PK
    public int NewsRelTags_NewsId { get; set; }  // →News.News_Id
    public int NewsRelTags_TagId { get; set; }  // →Terms.Term_Id
    public DateTime? NewsRelTags_Deleted { get; set; }  // datetime

    public virtual News News { get; set; } = null!;
    public virtual Term Tag { get; set; } = null!;
}

/// <summary>
/// ProjectType — انواع قابل تعریف پروژه یا فعالیت را برای هر سازمان نگهداری می‌کند.
/// Workflow engine root: defines process chains for AccessPolicy, Loan, Review, etc. (§5B).
/// </summary>
public class ProjectType
{
    public int ProjectType_Id { get; set; }  // PK
    public string ProjectType_Name { get; set; } = null!;  // NN nvarchar(max)
    public int? ProjectType_OrganizationId { get; set; }  // →Organizations.Organization_Id
    public DateTime? ProjectType_Deleted { get; set; }  // datetime

    public virtual Organization? Organization { get; set; }
    public virtual ICollection<Project> Projects { get; set; } = new List<Project>();
    public virtual ICollection<Process> Processes { get; set; } = new List<Process>();
}

/// <summary>
/// Projects — نمونه‌های اجرایی فعالیت‌ها یا پروژه‌های سامانه را نگهداری می‌کند.
/// Workflow instance: tracks state transitions via Process chain.
/// </summary>
public class Project
{
    public int Project_Id { get; set; }  // PK
    public string Project_Title { get; set; } = null!;  // NN nvarchar(500)
    public int Project_ProjectTypeId { get; set; }  // →ProjectType.ProjectType_Id
    public int Project_ProcessId { get; set; }  // →Process.Process_Id
    public DateTime? Project_StartDate { get; set; }  // datetime2(7) - e.g., loan start
    public DateTime? Project_EndDate { get; set; }  // datetime2(7) - e.g., loan end
    public DateTime? Project_ChangeProcessDate { get; set; }  // datetime2(7) - state transition time
    public DateTime? Project_Deleted { get; set; }  // datetime
    public string? Project_PreviousStepText { get; set; }  // nvarchar(max) - per-stage notes (L5)

    public virtual ProjectType ProjectType { get; set; } = null!;
    public virtual Process Process { get; set; } = null!;
    public virtual ICollection<ProjectUser> ProjectUsers { get; set; } = new List<ProjectUser>();
    public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();
    public virtual ICollection<Tmdp> TMDPs { get; set; } = new List<Tmdp>();
}

/// <summary>
/// Process — مراحل و قواعد اجرایی فرایند مربوط به هر نوع پروژه را تعریف می‌کند.
/// Workflow step: defines state, sequencing, SLA, and transition conditions.
/// Process_Condition is read ONLY by whitelisted parser (INV-07).
/// </summary>
public class Process
{
    public int Process_Id { get; set; }  // PK
    public int Process_StateId { get; set; }  // →States.State_Id
    public int Process_ProjectTypeId { get; set; }  // →ProjectType.ProjectType_Id
    public int? Process_ApiId { get; set; }  // →API.API_Id
    public int? Process_Next { get; set; }  // int - next process step
    public int? Process_Previous { get; set; }  // int - previous process step
    public int? Process_Duration { get; set; }  // int - SLA duration (minutes/hours?)
    public string? Process_Condition { get; set; }  // text - NEVER executed directly (INV-07)
    public DateTime? Process_Deleted { get; set; }  // datetime
    public int? Process_RoleId { get; set; }  // →Roles.Role_Id - assigned role for this step

    public virtual State State { get; set; } = null!;
    public virtual ProjectType ProjectType { get; set; } = null!;
    public virtual ApiEndpoint? ApiEndpoint { get; set; }
    public virtual Role? Role { get; set; }
    public virtual ICollection<Project> Projects { get; set; } = new List<Project>();
}

/// <summary>
/// ProjectUsers — جدول واسط میان کاربران و پروژه‌ها است و اعضا، مشارکت‌کنندگان یا کاربران…
/// </summary>
public class ProjectUser
{
    public int ProjectUser_Id { get; set; }  // PK
    public int ProjectUser_UserId { get; set; }  // →Users.User_Id
    public int ProjectUser_ProjectId { get; set; }  // →Projects.Project_Id
    public DateTime? ProjectUser_Deleted { get; set; }  // datetime

    public virtual User User { get; set; } = null!;
    public virtual Project Project { get; set; } = null!;
}

/// <summary>
/// Payments — مبالغ یا پرداخت‌های مرتبط با یک پروژه و یکی از اعضای سازمان را نگهداری…
/// Payment "status" is derived from containing project's current Process step (§5B).
/// </summary>
public class Payment
{
    public int Payment_Id { get; set; }  // PK
    public int Payment_OrganizationUserId { get; set; }  // →OrganizationUsers.OrganizationUsers_Id
    public int Payment_Cost { get; set; }  // NN int
    public int Payment_ProjectId { get; set; }  // →Projects.Project_Id
    public DateTime? Payment_Deleted { get; set; }  // datetime

    public virtual OrganizationUser OrganizationUser { get; set; } = null!;
    public virtual Project Project { get; set; } = null!;
}

/// <summary>
/// TMDP — جدول واسط میان موجودیت‌های زمینه‌مند TMD و پروژه‌ها است.
/// Tracks workflow instance for a TMD/content variant with state and time window.
/// </summary>
public class Tmdp
{
    public int TMDP_Id { get; set; }  // PK
    public int TMDP_TMDId { get; set; }  // →TMD.TMD_Id
    public int TMDP_ProjectId { get; set; }  // →Projects.Project_Id
    public int TMDP_StateId { get; set; }  // →States.State_Id
    public DateTime? TMDP_StartDate { get; set; }  // datetime2(7)
    public DateTime? TMDP_EndDate { get; set; }  // datetime2(7)
    public DateTime? TMDP_Deleted { get; set; }  // datetime

    public virtual Tmd Tmd { get; set; } = null!;
    public virtual Project Project { get; set; } = null!;
    public virtual State State { get; set; } = null!;
}

/// <summary>
/// Themes — رابط‌های کاربری پویا و قابل پیکربندی سامانه را ذخیره می‌کند.
/// </summary>
public class Theme
{
    public int Themes_Id { get; set; }  // PK
    public string Themes_Name { get; set; } = null!;  // NN nvarchar(max)
    public int? Themes_OrganizationId { get; set; }  // →Organizations.Organization_Id
    public int? Themes_ModuleId { get; set; }  // →Modules.Module_Id
    public int? Themes_DomainId { get; set; }  // →Domains.Domain_Id
    public int? Themes_ThemeTypeId { get; set; }  // →ThemeTypes.ThemeType_Id
    public string Themes_Code { get; set; } = null!;  // NN nvarchar(max)
    public DateTime? Themes_Deleted { get; set; }  // datetime

    public virtual Organization? Organization { get; set; }
    public virtual Module? Module { get; set; }
    public virtual Domain? Domain { get; set; }
    public virtual ThemeType? ThemeType { get; set; }
}

/// <summary>
/// ThemeTypes — انواع رابط‌های کاربری قابل تعریف در سامانه را نگهداری می‌کند.
/// </summary>
public class ThemeType
{
    public int ThemeType_Id { get; set; }  // PK
    public string ThemeType_Name { get; set; } = null!;  // NN nvarchar(max)
    public DateTime? ThemeTypes_Deleted { get; set; }  // datetime

    public virtual ICollection<Theme> Themes { get; set; } = new List<Theme>();
}
