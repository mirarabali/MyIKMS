-- =============================================================================
-- IKMS — Legacy Reference Schema
-- =============================================================================
-- This is the OLD system's SQL Server schema. It is attached to the project
-- prompt purely as conceptual inspiration (entities, relationships, business
-- intent) — see Section 4 (blockquote) and Section 9 ("Corrections to Make
-- Relative to the Reference Schema") of the project prompt.
--
-- Do NOT copy this structure as-is. The new Code-First EF Core model must be
-- designed fresh, fixing every issue listed in Section 9 of the prompt
-- (weak polymorphic FKs, raw-SQL condition columns, string-based permissions,
-- duplicate/ambiguous columns, inconsistent date types, missing indexes, etc.).
--
-- Read alongside TABLE_GUIDE.md, which explains what each table below was for
-- and how it relates — conceptually — to the others.
-- =============================================================================

USE [IKMS_Full]
GO
/****** Object:  Table [dbo].[__EFMigrationsHistory]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[__EFMigrationsHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[API]    Script Date: 8/24/2026 10:53:41 AM ******/
/*این جدول مخصوص ذخیره سازی نام apiهای سامانه است*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[API](
	[API_Id] [int] IDENTITY(1,1) NOT NULL,
	[API_ControllerName] [nvarchar](100) NOT NULL,
	[API_URL] [nvarchar](max) NOT NULL,
	[API_ActionType] [nvarchar](50) NOT NULL,
	[API_Deleted] [datetime2](7) NULL,
 CONSTRAINT [PK_API] PRIMARY KEY CLUSTERED 
(
	[API_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AuthAccessTokenBlacklists]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuthAccessTokenBlacklists](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[TokenId] [nvarchar](200) NOT NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
	[ExpiresAt] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_AuthAccessTokenBlacklists] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AuthLoginLockouts]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuthLoginLockouts](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Username] [nvarchar](255) NOT NULL,
	[FailedAttempts] [int] NOT NULL,
	[LockoutUntil] [datetime2](7) NULL,
	[LastFailedAt] [datetime2](7) NOT NULL,
	[LastFailedIp] [nvarchar](64) NULL,
 CONSTRAINT [PK_AuthLoginLockouts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AuthRefreshTokens]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuthRefreshTokens](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NOT NULL,
	[SessionId] [uniqueidentifier] NOT NULL,
	[TokenHash] [nvarchar](256) NOT NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
	[ExpiresAt] [datetime2](7) NOT NULL,
	[ConsumedAt] [datetime2](7) NULL,
	[RevokedAt] [datetime2](7) NULL,
	[ReplacedByTokenHash] [nvarchar](256) NULL,
	[ParentTokenHash] [nvarchar](256) NULL,
	[LastUsedAt] [datetime2](7) NULL,
	[LastUsedIp] [nvarchar](64) NULL,
	[LastUsedUserAgent] [nvarchar](512) NULL,
 CONSTRAINT [PK_AuthRefreshTokens] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AuthSessions]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuthSessions](
	[SessionId] [uniqueidentifier] NOT NULL,
	[UserId] [int] NOT NULL,
	[CreatedAt] [datetime2](7) NOT NULL,
	[LastSeenAt] [datetime2](7) NOT NULL,
	[UserAgent] [nvarchar](512) NULL,
	[Ip] [nvarchar](64) NULL,
	[IsRevoked] [bit] NOT NULL,
	[RevokedAt] [datetime2](7) NULL,
	[RevokeReason] [nvarchar](256) NULL,
 CONSTRAINT [PK_AuthSessions] PRIMARY KEY CLUSTERED 
(
	[SessionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DocContent]    Script Date: 8/24/2026 10:53:41 AM ******/
/*این جدول مخصوص ذخیره سازی صفحات محتوای منابع دیجیتال  است. در این جدول متن منابعی که در ماژول کتابخانه تعریف می شوند ذخیره می شود*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocContent](
	[DocContent_Id] [int] IDENTITY(1,1) NOT NULL,
	[DocContent_TMDId] [int] NULL,
	[DocContent_VolumeNo] [int] NULL,
	[DocContent_SectionNo] [int] NULL,
	[DocContent_PageNo] [int] NULL,
	[DocContent_ParagraphNo] [int] NULL,
	[DocContent_Text] [text] NULL,
	[DocContent_Deleted] [datetime] NULL,
 CONSTRAINT [PK_DocContent] PRIMARY KEY CLUSTERED 
(
	[DocContent_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Domains]    Script Date: 8/24/2026 10:53:41 AM ******/
/*این جدول مخصوص دامنه های موضوعی است. مثل فقه، کلام، مدیریت اطلاعات و غیره*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Domains](
	[Domain_Id] [int] IDENTITY(1,1) NOT NULL,
	[Domain_Title] [nvarchar](50) NOT NULL,
	[Domain_Parent] [int] NULL,
	[Domain_Description] [nvarchar](50) NULL,
	[Domain_StateId] [int] NULL,
	[Domain_Deleted] [datetime] NULL,
 CONSTRAINT [PK_Domain] PRIMARY KEY CLUSTERED 
(
	[Domain_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Files]    Script Date: 8/24/2026 10:53:41 AM ******/
/*جدول مخصوص تمام فایل هایی که در سامانه از آن ها استفاده می شود. از یک عکس برای خبر گرفته تا فایل یک مقاله در ماژول کتابخانه یا تصویر لوگو یک سازمان و غیره*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Files](
	[File_Id] [int] IDENTITY(1,1) NOT NULL,
	[File_Title] [text] NOT NULL,
	[File_TableName] [varchar](50) NOT NULL,
	[File_TableRecordId] [int] NOT NULL,
	[File_Description] [text] NOT NULL,
	[File_Address] [nvarchar](max) NOT NULL,
	[File_Deleted] [datetime] NULL,
 CONSTRAINT [files_file_id_primary] PRIMARY KEY CLUSTERED 
(
	[File_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Logs]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Logs](
	[Log_Id] [int] IDENTITY(1,1) NOT NULL,
	[Log_TableName] [nvarchar](200) NOT NULL,
	[Log_TableRecordId] [int] NOT NULL,
	[Log_TypeId] [int] NOT NULL,
	[Log_Activity] [text] NOT NULL,
	[Log_UserId] [int] NOT NULL,
	[Log_CreatedDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_Logs] PRIMARY KEY CLUSTERED 
(
	[Log_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LogType]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LogType](
	[LogType_Id] [int] IDENTITY(1,1) NOT NULL,
	[LogType_Name] [nvarchar](100) NULL,
	[LogType_Deleted] [datetime] NULL,
 CONSTRAINT [PK_LogType] PRIMARY KEY CLUSTERED 
(
	[LogType_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Modules]    Script Date: 8/24/2026 10:53:41 AM ******/
/*جدول ذخیره  سازی ماژول های سامانه مانند اصطلاحنامه، هستی شناسی، گراف دانش، دائره المعارف، دانشنامه، کتابخانه، نمایه سازی و غیره. این جدول سلسله مراتبی است و ارث بری دارد. مثلا زیر ماژول کتابخانه شامل کتابخانه فیزیکی و کتابخانه دیجیتال است. 
مهم ترین نکته در این جدول پوییا و انعطاف پذیری آن است که هر مژولی در آن قابل تعریف است*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Modules](
	[Module_Id] [int] IDENTITY(1,1) NOT NULL,
	[Module_Name] [nvarchar](50) NOT NULL,
	[Module_ParentId] [int] NULL,
	[Module_Description] [nvarchar](50) NULL,
	[Module_Deleted] [datetime] NULL,
 CONSTRAINT [PK_Modules] PRIMARY KEY CLUSTERED 
(
	[Module_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MRT]    Script Date: 8/24/2026 10:53:41 AM ******/
/*جدول رابطه بین ماژول و نوع رابطه است. مثلا رابطه سلسله مراتبی در اصطلاحنامه هست. رابطه isa در هستی شناسی است. رابطه نویسندگی در کتابخانه است. */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MRT](
	[MRT_Id] [int] IDENTITY(1,1) NOT NULL,
	[MRT_ModuleId] [int] NOT NULL,
	[MRT_RelationTypeId] [int] NOT NULL,
	[MRT_Deleted] [datetime] NULL,
 CONSTRAINT [PK_MRT] PRIMARY KEY CLUSTERED 
(
	[MRT_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[News]    Script Date: 8/24/2026 10:53:41 AM ******/
/*جدول خبرهای سایت برای بخش اطلاع رسانی*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[News](
	[News_Id] [int] IDENTITY(1,1) NOT NULL,
	[News_Title] [nvarchar](max) NOT NULL,
	[News_Abstract] [nvarchar](max) NULL,
	[News_Content] [text] NULL,
	[News_Link] [nvarchar](4000) NULL,
	[News_Deleted] [datetime] NULL,
 CONSTRAINT [news_news_id_primary] PRIMARY KEY CLUSTERED 
(
	[News_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NewsCategory]    Script Date: 8/24/2026 10:53:41 AM ******/
/*جدول ذخیره سازی دسته بندی خبرهای سایت*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewsCategory](
	[NewsCtegory_Id] [int] IDENTITY(1,1) NOT NULL,
	[NewsCtegory_Title] [nvarchar](max) NOT NULL,
	[NewsCtegory_Description] [nvarchar](max) NOT NULL,
	[NewsCtegory_Image] [nvarchar](max) NOT NULL,
	[NewsCtegory_OrganizationId] [int] NOT NULL,
	[NewsCtegory_Deleted] [datetime] NULL,
 CONSTRAINT [newscategory_newsctegory_id_primary] PRIMARY KEY CLUSTERED 
(
	[NewsCtegory_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NewsRelNewsCategory]    Script Date: 8/24/2026 10:53:41 AM ******/
/*جدول ارتباط بین یک خبر و دسته بندی مرتبط با آن*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewsRelNewsCategory](
	[NewsRelNewsCategory_Id] [int] IDENTITY(1,1) NOT NULL,
	[NewsRelNewsCategory_NewsId] [int] NOT NULL,
	[NewsRelNewsCategory_NewsCategoryId] [int] NOT NULL,
	[NewsRelNewsCategory_Deleted] [datetime] NULL,
 CONSTRAINT [newsrelnewscategory_newsrelnewscategory_id_primary] PRIMARY KEY CLUSTERED 
(
	[NewsRelNewsCategory_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NewsRelTags]    Script Date: 8/24/2026 10:53:41 AM ******/
/*جدول رابطه بین خبر و برچسب های مرتبط با هر خبر*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewsRelTags](
	[NewsRelTags_Id] [int] IDENTITY(1,1) NOT NULL,
	[NewsRelTags_NewsId] [int] NOT NULL,
	[NewsRelTags_TagId] [int] NOT NULL,
	[NewsRelTags_Deleted] [datetime] NULL,
 CONSTRAINT [newsreltags_newsreltags_id_primary] PRIMARY KEY CLUSTERED 
(
	[NewsRelTags_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Organizations]    Script Date: 8/24/2026 10:53:41 AM ******/
/*جدول تعریف سازمان های مختلف که می خواهند با سیستم کار کنند. هر سازمان هم به یک سری از apiها می تواند دسترسی پیدا کند یا به کل سیستم دسترسی داشته باشد که کاملا قابل تعریف است. 
هر سازمان در رابط کاربری می تواند صفحه مخصوص خود را داشته باشد.هر سازمان می تواند یک نماینده داشته باشد که تنظیمات سازمان مرتبط را انجام دهد*/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Organizations](
	[Organization_Id] [int] IDENTITY(1,1) NOT NULL,
	[Organization_Name] [nvarchar](500) NOT NULL,
	[Oranization_Description] [nvarchar](1000) NULL,
	[Organization_ParentId] [int] NULL,
	[Organization_Email] [nvarchar](100) NULL,
	[Organization_Address] [nvarchar](max) NULL,
	[Organization_Phone] [varchar](50) NULL,
	[Organization_Deleted] [datetime] NULL,
 CONSTRAINT [PK_Organizations] PRIMARY KEY CLUSTERED 
(
	[Organization_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrganizationUsers]    Script Date: 8/24/2026 10:53:41 AM ******/
/**/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrganizationUsers](
	[OrganizationUsers_Id] [int] IDENTITY(1,1) NOT NULL,
	[OrganizationUsers_OrganizationId] [int] NOT NULL,
	[OrganizationUsers_UserId] [int] NOT NULL,
	[OrganizationUsers_isAgent] [bit] NOT NULL,
	[OrganizationUsers_Deleted] [datetime] NULL,
 CONSTRAINT [PK_OrganizationUsers] PRIMARY KEY CLUSTERED 
(
	[OrganizationUsers_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Payments]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Payments](
	[Payment_Id] [int] IDENTITY(1,1) NOT NULL,
	[Payment_OrganizationUserId] [int] NOT NULL,
	[Payment_Cost] [int] NOT NULL,
	[Payment_ProjectId] [int] NOT NULL,
	[Payment_Deleted] [datetime] NULL,
 CONSTRAINT [PK_Payments] PRIMARY KEY CLUSTERED 
(
	[Payment_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Permissions]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Permissions](
	[Permission_Id] [int] IDENTITY(1,1) NOT NULL,
	[Permission_RoleId] [int] NOT NULL,
	[Permission_APIId] [int] NOT NULL,
	[Permission_Value] [nvarchar](max) NULL,
	[Permission_Deleted] [datetime] NULL,
 CONSTRAINT [PK_Permissions] PRIMARY KEY CLUSTERED 
(
	[Permission_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Process]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Process](
	[Process_Id] [int] IDENTITY(1,1) NOT NULL,
	[Process_StateId] [int] NOT NULL,
	[Process_ProjectTypeId] [int] NOT NULL,
	[Process_ApiId] [int] NULL,
	[Process_Next] [int] NULL,
	[Process_Previous] [int] NULL,
	[Process_Duration] [int] NULL,
	[Process_Condition] [text] NULL,
	[Process_Deleted] [datetime] NULL,
	[Process_RoleId] [int] NOT NULL,
 CONSTRAINT [PK_Process] PRIMARY KEY CLUSTERED 
(
	[Process_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Projects]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Projects](
	[Project_Id] [int] IDENTITY(1,1) NOT NULL,
	[Project_Title] [nvarchar](500) NOT NULL,
	[Project_ProjectTypeId] [int] NULL,
	[Project_ProcessId] [int] NULL,
	[Project_StartDate] [datetime2](7) NULL,
	[Project_EndDate] [datetime2](7) NULL,
	[Project_ChangeProcessDate] [datetime2](7) NULL,
	[Project_Deleted] [datetime] NULL,
	[Project_PreviousStepText] [nvarchar](max) NULL,
 CONSTRAINT [PK_Projects] PRIMARY KEY CLUSTERED 
(
	[Project_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProjectType]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProjectType](
	[ProjectType_Id] [int] IDENTITY(1,1) NOT NULL,
	[ProjectType_Name] [nvarchar](max) NOT NULL,
	[ProjectType_OrganizationId] [int] NOT NULL,
	[ProjectType_Deleted] [datetime] NULL,
 CONSTRAINT [PK_ProjectType] PRIMARY KEY CLUSTERED 
(
	[ProjectType_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProjectUsers]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProjectUsers](
	[ProjectUser_Id] [int] IDENTITY(1,1) NOT NULL,
	[ProjectUser_UserId] [int] NOT NULL,
	[ProjectUser_ProjectId] [int] NOT NULL,
	[ProjectUser_Deleted] [datetime] NULL,
 CONSTRAINT [PK_ProjectUsers] PRIMARY KEY CLUSTERED 
(
	[ProjectUser_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RelationConstraints]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RelationConstraints](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Mrt_Id] [int] NOT NULL,
	[ConstraintName] [nvarchar](100) NULL,
	[SqlCondition] [nvarchar](max) NULL,
	[ErrorMessage] [nvarchar](500) NULL,
	[MinCardinallity] [nvarchar](max) NULL,
	[MaxCardinallity] [nvarchar](max) NULL,
	[IsActive] [bit] NULL,
	[Deleted] [datetime] NULL,
 CONSTRAINT [PK__tmp_ms_x__3214EC073239AA1C] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Relations]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Relations](
	[TermsRelation_Id] [int] IDENTITY(1,1) NOT NULL,
	[First_TMDId] [int] NOT NULL,
	[TermsRelation_TypeId] [int] NOT NULL,
	[Second_TMDId] [int] NOT NULL,
	[TermsRelation_Priority] [int] NULL,
	[TermsRelation_Level] [int] NULL,
	[TermsRelation_Description] [nvarchar](max) NULL,
	[Deleted] [datetime] NULL,
 CONSTRAINT [PK_TermsRelations] PRIMARY KEY CLUSTERED 
(
	[TermsRelation_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RelationsTypes]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RelationsTypes](
	[RelationsType_Id] [int] IDENTITY(1,1) NOT NULL,
	[RelationsType_ParentId] [int] NULL,
	[RelationsType_Title] [nvarchar](50) NOT NULL,
	[RelationsType_ReverseTitle] [nvarchar](50) NULL,
	[RelationsType_IsNodeLabel] [bit] NOT NULL,
	[RelationsType_DataTypeId] [int] NULL,
	[RelationsType_IsSystemDefined] [bit] NOT NULL,
	[RelationsType_Code] [nvarchar](150) NULL,
	[RelationsType_IsHierarchical] [bit] NOT NULL,
	[RelationsType_IsTransitive] [bit] NOT NULL,
	[RelationsType_IsAsymmetric] [bit] NOT NULL,
	[RelationsType_IsEquivalence] [bit] NOT NULL,
	[RelationsType_IsIrreflexive] [bit] NOT NULL,
	[RelationsType_Description] [nvarchar](max) NULL,
	[RelationsType_Deleted] [datetime] NULL,
 CONSTRAINT [relationstype_relationstype_id_primary] PRIMARY KEY CLUSTERED 
(
	[RelationsType_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[Role_Id] [int] IDENTITY(1,1) NOT NULL,
	[Role_Name] [nvarchar](500) NOT NULL,
	[Role_Deleted] [datetime] NULL,
 CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED 
(
	[Role_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[States]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[States](
	[State_Id] [int] IDENTITY(1,1) NOT NULL,
	[State_Title] [nvarchar](50) NOT NULL,
	[State_Deleted] [datetime] NULL,
 CONSTRAINT [PK_States] PRIMARY KEY CLUSTERED 
(
	[State_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Terms]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Terms](
	[Term_Id] [int] IDENTITY(1,1) NOT NULL,
	[Term_Title] [nvarchar](4000) NULL,
	[Term_Description] [nvarchar](max) NULL,
	[Term_StateId] [int] NULL,
	[Term_Deleted] [datetime] NULL,
 CONSTRAINT [terms_term_id_primary] PRIMARY KEY CLUSTERED 
(
	[Term_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Themes]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Themes](
	[Themes_Id] [int] IDENTITY(1,1) NOT NULL,
	[Themes_Name] [nvarchar](max) NOT NULL,
	[Themes_OrganizationId] [int] NOT NULL,
	[Themes_ModuleId] [int] NOT NULL,
	[Themes_DomainId] [int] NULL,
	[Themes_ThemeTypeId] [int] NULL,
	[Themes_Code] [nvarchar](max) NOT NULL,
	[Themes_Deleted] [datetime] NULL,
 CONSTRAINT [PK_ModulesMarkup] PRIMARY KEY CLUSTERED 
(
	[Themes_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ThemeTypes]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ThemeTypes](
	[ThemeType_Id] [int] IDENTITY(1,1) NOT NULL,
	[ThemeType_Name] [nvarchar](max) NOT NULL,
	[ThemeTypes_Deleted] [datetime] NULL,
 CONSTRAINT [PK_ThemeTypes] PRIMARY KEY CLUSTERED 
(
	[ThemeType_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TMD]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TMD](
	[TMD_Id] [int] IDENTITY(1,1) NOT NULL,
	[TMD_ModuleId] [int] NOT NULL,
	[TMD_DomainId] [int] NULL,
	[TMD_TermId] [int] NOT NULL,
	[TMD_StateId] [int] NULL,
	[TMD_IsPreferred] [bit] NULL,
	[TMD_Deleted] [datetime] NULL,
	[State_Id] [int] NOT NULL,
 CONSTRAINT [PK_TMD] PRIMARY KEY CLUSTERED 
(
	[TMD_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TMDP]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TMDP](
	[TMDP_Id] [int] IDENTITY(1,1) NOT NULL,
	[TMDP_TMDId] [int] NOT NULL,
	[TMDP_ProjectId] [int] NOT NULL,
	[TMDP_StateId] [int] NULL,
	[TMDP_StartDate] [datetime2](7) NULL,
	[TMDP_EndDate] [datetime2](7) NULL,
	[TMDP_Deleted] [datetime] NULL,
 CONSTRAINT [PK_TMDP] PRIMARY KEY CLUSTERED 
(
	[TMDP_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserRoles]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRoles](
	[UserRole_Id] [int] IDENTITY(1,1) NOT NULL,
	[UserRole_UserId] [int] NOT NULL,
	[UserRole_RoleId] [int] NOT NULL,
	[UserRole_Deleted] [datetime] NULL,
 CONSTRAINT [PK_UserRoles] PRIMARY KEY CLUSTERED 
(
	[UserRole_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 8/24/2026 10:53:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[User_Id] [int] IDENTITY(1,1) NOT NULL,
	[User_UserName] [nvarchar](255) NOT NULL,
	[User_Password] [nvarchar](255) NOT NULL,
	[User_Name] [nvarchar](50) NULL,
	[User_Family] [nvarchar](50) NULL,
	[User_Email] [nchar](100) NULL,
	[User_Phone] [varchar](50) NULL,
	[User_Address] [nvarchar](max) NULL,
	[User_RegistrationDate] [datetime2](7) NULL,
	[User_LastLoginDate] [datetime2](7) NULL,
	[User_Deleted] [datetime] NULL,
 CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED 
(
	[User_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[AuthSessions] ADD  DEFAULT (CONVERT([bit],(0))) FOR [IsRevoked]
GO
ALTER TABLE [dbo].[RelationConstraints] ADD  DEFAULT (CONVERT([bit],(1))) FOR [IsActive]
GO
ALTER TABLE [dbo].[RelationConstraints] ADD  CONSTRAINT [DF_RC_Severity]  DEFAULT ((2)) FOR [Severity]
GO
ALTER TABLE [dbo].[RelationConstraints] ADD  CONSTRAINT [DF_RC_CreatedAt]  DEFAULT (sysdatetime()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[RelationsTypes] ADD  CONSTRAINT [DF_RelationsTypes_IsNodeLabel]  DEFAULT ((0)) FOR [RelationsType_IsNodeLabel]
GO
ALTER TABLE [dbo].[RelationsTypes] ADD  CONSTRAINT [DF_RelationsTypes_IsSystemDefined]  DEFAULT ((1)) FOR [RelationsType_IsSystemDefined]
GO
ALTER TABLE [dbo].[RelationsTypes] ADD  CONSTRAINT [DF_RT_IsHierarchical]  DEFAULT ((0)) FOR [RelationsType_IsHierarchical]
GO
ALTER TABLE [dbo].[RelationsTypes] ADD  CONSTRAINT [DF_RT_IsTransitive]  DEFAULT ((0)) FOR [RelationsType_IsTransitive]
GO
ALTER TABLE [dbo].[RelationsTypes] ADD  CONSTRAINT [DF_RT_IsAsymmetric]  DEFAULT ((0)) FOR [RelationsType_IsAsymmetric]
GO
ALTER TABLE [dbo].[RelationsTypes] ADD  CONSTRAINT [DF_RT_IsEquivalence]  DEFAULT ((0)) FOR [RelationsType_IsEquivalence]
GO
ALTER TABLE [dbo].[RelationsTypes] ADD  CONSTRAINT [DF_RT_IsIrreflexive]  DEFAULT ((1)) FOR [RelationsType_IsIrreflexive]
GO
ALTER TABLE [dbo].[AuthRefreshTokens]  WITH CHECK ADD  CONSTRAINT [FK_AuthRefreshTokens_AuthSessions_SessionId] FOREIGN KEY([SessionId])
REFERENCES [dbo].[AuthSessions] ([SessionId])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AuthRefreshTokens] CHECK CONSTRAINT [FK_AuthRefreshTokens_AuthSessions_SessionId]
GO
ALTER TABLE [dbo].[AuthRefreshTokens]  WITH CHECK ADD  CONSTRAINT [FK_AuthRefreshTokens_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([User_Id])
GO
ALTER TABLE [dbo].[AuthRefreshTokens] CHECK CONSTRAINT [FK_AuthRefreshTokens_Users_UserId]
GO
ALTER TABLE [dbo].[AuthSessions]  WITH CHECK ADD  CONSTRAINT [FK_AuthSessions_Users_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([User_Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AuthSessions] CHECK CONSTRAINT [FK_AuthSessions_Users_UserId]
GO
ALTER TABLE [dbo].[DocContent]  WITH CHECK ADD  CONSTRAINT [FK_DocContent_TMD] FOREIGN KEY([DocContent_TMDId])
REFERENCES [dbo].[TMD] ([TMD_Id])
GO
ALTER TABLE [dbo].[DocContent] CHECK CONSTRAINT [FK_DocContent_TMD]
GO
ALTER TABLE [dbo].[Domains]  WITH CHECK ADD  CONSTRAINT [FK_Domains_Domains] FOREIGN KEY([Domain_Parent])
REFERENCES [dbo].[Domains] ([Domain_Id])
GO
ALTER TABLE [dbo].[Domains] CHECK CONSTRAINT [FK_Domains_Domains]
GO
ALTER TABLE [dbo].[Domains]  WITH CHECK ADD  CONSTRAINT [FK_Domains_States] FOREIGN KEY([Domain_StateId])
REFERENCES [dbo].[States] ([State_Id])
GO
ALTER TABLE [dbo].[Domains] CHECK CONSTRAINT [FK_Domains_States]
GO
ALTER TABLE [dbo].[Logs]  WITH CHECK ADD  CONSTRAINT [FK_Logs_LogType] FOREIGN KEY([Log_TypeId])
REFERENCES [dbo].[LogType] ([LogType_Id])
GO
ALTER TABLE [dbo].[Logs] CHECK CONSTRAINT [FK_Logs_LogType]
GO
ALTER TABLE [dbo].[Logs]  WITH CHECK ADD  CONSTRAINT [FK_Logs_Users_Log_UserId] FOREIGN KEY([Log_UserId])
REFERENCES [dbo].[Users] ([User_Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Logs] CHECK CONSTRAINT [FK_Logs_Users_Log_UserId]
GO
ALTER TABLE [dbo].[Modules]  WITH CHECK ADD  CONSTRAINT [FK_Modules_Modules] FOREIGN KEY([Module_ParentId])
REFERENCES [dbo].[Modules] ([Module_Id])
GO
ALTER TABLE [dbo].[Modules] CHECK CONSTRAINT [FK_Modules_Modules]
GO
ALTER TABLE [dbo].[MRT]  WITH CHECK ADD  CONSTRAINT [FK_MRT_Modules] FOREIGN KEY([MRT_ModuleId])
REFERENCES [dbo].[Modules] ([Module_Id])
GO
ALTER TABLE [dbo].[MRT] CHECK CONSTRAINT [FK_MRT_Modules]
GO
ALTER TABLE [dbo].[MRT]  WITH CHECK ADD  CONSTRAINT [FK_MRT_RelationsTypes] FOREIGN KEY([MRT_RelationTypeId])
REFERENCES [dbo].[RelationsTypes] ([RelationsType_Id])
GO
ALTER TABLE [dbo].[MRT] CHECK CONSTRAINT [FK_MRT_RelationsTypes]
GO
ALTER TABLE [dbo].[NewsCategory]  WITH CHECK ADD  CONSTRAINT [FK_NewsCategory_Organizations] FOREIGN KEY([NewsCtegory_OrganizationId])
REFERENCES [dbo].[Organizations] ([Organization_Id])
GO
ALTER TABLE [dbo].[NewsCategory] CHECK CONSTRAINT [FK_NewsCategory_Organizations]
GO
ALTER TABLE [dbo].[NewsRelNewsCategory]  WITH CHECK ADD  CONSTRAINT [FK_NewsRelNewsCategory_News] FOREIGN KEY([NewsRelNewsCategory_NewsId])
REFERENCES [dbo].[News] ([News_Id])
GO
ALTER TABLE [dbo].[NewsRelNewsCategory] CHECK CONSTRAINT [FK_NewsRelNewsCategory_News]
GO
ALTER TABLE [dbo].[NewsRelNewsCategory]  WITH CHECK ADD  CONSTRAINT [FK_NewsRelNewsCategory_NewsCategory_1] FOREIGN KEY([NewsRelNewsCategory_NewsCategoryId])
REFERENCES [dbo].[NewsCategory] ([NewsCtegory_Id])
GO
ALTER TABLE [dbo].[NewsRelNewsCategory] CHECK CONSTRAINT [FK_NewsRelNewsCategory_NewsCategory_1]
GO
ALTER TABLE [dbo].[NewsRelTags]  WITH CHECK ADD  CONSTRAINT [FK_NewsRelTags_News] FOREIGN KEY([NewsRelTags_NewsId])
REFERENCES [dbo].[News] ([News_Id])
GO
ALTER TABLE [dbo].[NewsRelTags] CHECK CONSTRAINT [FK_NewsRelTags_News]
GO
ALTER TABLE [dbo].[NewsRelTags]  WITH CHECK ADD  CONSTRAINT [FK_NewsRelTags_Terms_1] FOREIGN KEY([NewsRelTags_TagId])
REFERENCES [dbo].[Terms] ([Term_Id])
GO
ALTER TABLE [dbo].[NewsRelTags] CHECK CONSTRAINT [FK_NewsRelTags_Terms_1]
GO
ALTER TABLE [dbo].[Organizations]  WITH CHECK ADD  CONSTRAINT [FK_Organizations_Organizations] FOREIGN KEY([Organization_ParentId])
REFERENCES [dbo].[Organizations] ([Organization_Id])
GO
ALTER TABLE [dbo].[Organizations] CHECK CONSTRAINT [FK_Organizations_Organizations]
GO
ALTER TABLE [dbo].[OrganizationUsers]  WITH CHECK ADD  CONSTRAINT [FK_OrganizationUsers_Organizations] FOREIGN KEY([OrganizationUsers_OrganizationId])
REFERENCES [dbo].[Organizations] ([Organization_Id])
GO
ALTER TABLE [dbo].[OrganizationUsers] CHECK CONSTRAINT [FK_OrganizationUsers_Organizations]
GO
ALTER TABLE [dbo].[OrganizationUsers]  WITH CHECK ADD  CONSTRAINT [FK_OrganizationUsers_Users] FOREIGN KEY([OrganizationUsers_UserId])
REFERENCES [dbo].[Users] ([User_Id])
GO
ALTER TABLE [dbo].[OrganizationUsers] CHECK CONSTRAINT [FK_OrganizationUsers_Users]
GO
ALTER TABLE [dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [FK_Payments_OrganizationUsers] FOREIGN KEY([Payment_OrganizationUserId])
REFERENCES [dbo].[OrganizationUsers] ([OrganizationUsers_Id])
GO
ALTER TABLE [dbo].[Payments] CHECK CONSTRAINT [FK_Payments_OrganizationUsers]
GO
ALTER TABLE [dbo].[Payments]  WITH CHECK ADD  CONSTRAINT [FK_Payments_Projects] FOREIGN KEY([Payment_ProjectId])
REFERENCES [dbo].[Projects] ([Project_Id])
GO
ALTER TABLE [dbo].[Payments] CHECK CONSTRAINT [FK_Payments_Projects]
GO
ALTER TABLE [dbo].[Permissions]  WITH CHECK ADD  CONSTRAINT [FK_Permissions_API] FOREIGN KEY([Permission_APIId])
REFERENCES [dbo].[API] ([API_Id])
GO
ALTER TABLE [dbo].[Permissions] CHECK CONSTRAINT [FK_Permissions_API]
GO
ALTER TABLE [dbo].[Permissions]  WITH CHECK ADD  CONSTRAINT [FK_Permissions_Roles] FOREIGN KEY([Permission_RoleId])
REFERENCES [dbo].[Roles] ([Role_Id])
GO
ALTER TABLE [dbo].[Permissions] CHECK CONSTRAINT [FK_Permissions_Roles]
GO
ALTER TABLE [dbo].[Process]  WITH CHECK ADD  CONSTRAINT [FK_Process_Api] FOREIGN KEY([Process_ApiId])
REFERENCES [dbo].[API] ([API_Id])
GO
ALTER TABLE [dbo].[Process] CHECK CONSTRAINT [FK_Process_Api]
GO
ALTER TABLE [dbo].[Process]  WITH CHECK ADD  CONSTRAINT [FK_Process_ProjectType] FOREIGN KEY([Process_ProjectTypeId])
REFERENCES [dbo].[ProjectType] ([ProjectType_Id])
GO
ALTER TABLE [dbo].[Process] CHECK CONSTRAINT [FK_Process_ProjectType]
GO
ALTER TABLE [dbo].[Process]  WITH CHECK ADD  CONSTRAINT [FK_Process_Role] FOREIGN KEY([Process_RoleId])
REFERENCES [dbo].[Roles] ([Role_Id])
GO
ALTER TABLE [dbo].[Process] CHECK CONSTRAINT [FK_Process_Role]
GO
ALTER TABLE [dbo].[Process]  WITH CHECK ADD  CONSTRAINT [FK_Process_States] FOREIGN KEY([Process_StateId])
REFERENCES [dbo].[States] ([State_Id])
GO
ALTER TABLE [dbo].[Process] CHECK CONSTRAINT [FK_Process_States]
GO
ALTER TABLE [dbo].[Projects]  WITH CHECK ADD  CONSTRAINT [FK_Projects_Process] FOREIGN KEY([Project_ProcessId])
REFERENCES [dbo].[Process] ([Process_Id])
GO
ALTER TABLE [dbo].[Projects] CHECK CONSTRAINT [FK_Projects_Process]
GO
ALTER TABLE [dbo].[Projects]  WITH CHECK ADD  CONSTRAINT [FK_Projects_ProjectType] FOREIGN KEY([Project_ProjectTypeId])
REFERENCES [dbo].[ProjectType] ([ProjectType_Id])
GO
ALTER TABLE [dbo].[Projects] CHECK CONSTRAINT [FK_Projects_ProjectType]
GO
ALTER TABLE [dbo].[ProjectType]  WITH CHECK ADD  CONSTRAINT [FK_ProjectType_Organizations] FOREIGN KEY([ProjectType_OrganizationId])
REFERENCES [dbo].[Organizations] ([Organization_Id])
GO
ALTER TABLE [dbo].[ProjectType] CHECK CONSTRAINT [FK_ProjectType_Organizations]
GO
ALTER TABLE [dbo].[ProjectUsers]  WITH CHECK ADD  CONSTRAINT [FK_ProjectUsers_Projects] FOREIGN KEY([ProjectUser_ProjectId])
REFERENCES [dbo].[Projects] ([Project_Id])
GO
ALTER TABLE [dbo].[ProjectUsers] CHECK CONSTRAINT [FK_ProjectUsers_Projects]
GO
ALTER TABLE [dbo].[ProjectUsers]  WITH CHECK ADD  CONSTRAINT [FK_ProjectUsers_Users] FOREIGN KEY([ProjectUser_UserId])
REFERENCES [dbo].[Users] ([User_Id])
GO
ALTER TABLE [dbo].[ProjectUsers] CHECK CONSTRAINT [FK_ProjectUsers_Users]
GO
ALTER TABLE [dbo].[RelationConstraints]  WITH CHECK ADD  CONSTRAINT [FK_RelationConstraints_MRT] FOREIGN KEY([Mrt_Id])
REFERENCES [dbo].[MRT] ([MRT_Id])
GO
ALTER TABLE [dbo].[RelationConstraints] CHECK CONSTRAINT [FK_RelationConstraints_MRT]
GO
ALTER TABLE [dbo].[Relations]  WITH CHECK ADD  CONSTRAINT [FK_TermsRelations_RelationsTypes] FOREIGN KEY([TermsRelation_TypeId])
REFERENCES [dbo].[RelationsTypes] ([RelationsType_Id])
GO
ALTER TABLE [dbo].[Relations] CHECK CONSTRAINT [FK_TermsRelations_RelationsTypes]
GO
ALTER TABLE [dbo].[Relations]  WITH CHECK ADD  CONSTRAINT [FK_TermsRelations_TMDFirst] FOREIGN KEY([First_TMDId])
REFERENCES [dbo].[TMD] ([TMD_Id])
GO
ALTER TABLE [dbo].[Relations] CHECK CONSTRAINT [FK_TermsRelations_TMDFirst]
GO
ALTER TABLE [dbo].[Relations]  WITH CHECK ADD  CONSTRAINT [FK_TermsRelations_TMDSecond] FOREIGN KEY([Second_TMDId])
REFERENCES [dbo].[TMD] ([TMD_Id])
GO
ALTER TABLE [dbo].[Relations] CHECK CONSTRAINT [FK_TermsRelations_TMDSecond]
GO
ALTER TABLE [dbo].[RelationsTypes]  WITH CHECK ADD  CONSTRAINT [FK_RelationsTypes_RelationsTypes_DataTypeId] FOREIGN KEY([RelationsType_DataTypeId])
REFERENCES [dbo].[RelationsTypes] ([RelationsType_Id])
GO
ALTER TABLE [dbo].[RelationsTypes] CHECK CONSTRAINT [FK_RelationsTypes_RelationsTypes_DataTypeId]
GO
ALTER TABLE [dbo].[RelationsTypes]  WITH CHECK ADD  CONSTRAINT [FK_RelationsTypes_RelationsTypes_RelationsType_ParentId] FOREIGN KEY([RelationsType_ParentId])
REFERENCES [dbo].[RelationsTypes] ([RelationsType_Id])
GO
ALTER TABLE [dbo].[RelationsTypes] CHECK CONSTRAINT [FK_RelationsTypes_RelationsTypes_RelationsType_ParentId]
GO
ALTER TABLE [dbo].[Terms]  WITH CHECK ADD  CONSTRAINT [FK_Terms_States] FOREIGN KEY([Term_StateId])
REFERENCES [dbo].[States] ([State_Id])
GO
ALTER TABLE [dbo].[Terms] CHECK CONSTRAINT [FK_Terms_States]
GO
ALTER TABLE [dbo].[Themes]  WITH CHECK ADD  CONSTRAINT [FK_Themes_Domains] FOREIGN KEY([Themes_DomainId])
REFERENCES [dbo].[Domains] ([Domain_Id])
GO
ALTER TABLE [dbo].[Themes] CHECK CONSTRAINT [FK_Themes_Domains]
GO
ALTER TABLE [dbo].[Themes]  WITH CHECK ADD  CONSTRAINT [FK_Themes_Modules] FOREIGN KEY([Themes_ModuleId])
REFERENCES [dbo].[Modules] ([Module_Id])
GO
ALTER TABLE [dbo].[Themes] CHECK CONSTRAINT [FK_Themes_Modules]
GO
ALTER TABLE [dbo].[Themes]  WITH CHECK ADD  CONSTRAINT [FK_Themes_Organizations] FOREIGN KEY([Themes_OrganizationId])
REFERENCES [dbo].[Organizations] ([Organization_Id])
GO
ALTER TABLE [dbo].[Themes] CHECK CONSTRAINT [FK_Themes_Organizations]
GO
ALTER TABLE [dbo].[Themes]  WITH CHECK ADD  CONSTRAINT [FK_Themes_ThemeTypes] FOREIGN KEY([Themes_ThemeTypeId])
REFERENCES [dbo].[ThemeTypes] ([ThemeType_Id])
GO
ALTER TABLE [dbo].[Themes] CHECK CONSTRAINT [FK_Themes_ThemeTypes]
GO
ALTER TABLE [dbo].[TMD]  WITH CHECK ADD  CONSTRAINT [FK_TMD_Domain] FOREIGN KEY([TMD_DomainId])
REFERENCES [dbo].[Domains] ([Domain_Id])
GO
ALTER TABLE [dbo].[TMD] CHECK CONSTRAINT [FK_TMD_Domain]
GO
ALTER TABLE [dbo].[TMD]  WITH CHECK ADD  CONSTRAINT [FK_TMD_Modules] FOREIGN KEY([TMD_ModuleId])
REFERENCES [dbo].[Modules] ([Module_Id])
GO
ALTER TABLE [dbo].[TMD] CHECK CONSTRAINT [FK_TMD_Modules]
GO
ALTER TABLE [dbo].[TMD]  WITH CHECK ADD  CONSTRAINT [FK_TMD_States_State_Id] FOREIGN KEY([State_Id])
REFERENCES [dbo].[States] ([State_Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[TMD] CHECK CONSTRAINT [FK_TMD_States_State_Id]
GO
ALTER TABLE [dbo].[TMD]  WITH CHECK ADD  CONSTRAINT [FK_TMD_Terms] FOREIGN KEY([TMD_TermId])
REFERENCES [dbo].[Terms] ([Term_Id])
GO
ALTER TABLE [dbo].[TMD] CHECK CONSTRAINT [FK_TMD_Terms]
GO
ALTER TABLE [dbo].[TMDP]  WITH CHECK ADD  CONSTRAINT [FK_TMDP_Projects] FOREIGN KEY([TMDP_ProjectId])
REFERENCES [dbo].[Projects] ([Project_Id])
GO
ALTER TABLE [dbo].[TMDP] CHECK CONSTRAINT [FK_TMDP_Projects]
GO
ALTER TABLE [dbo].[TMDP]  WITH CHECK ADD  CONSTRAINT [FK_TMDP_States] FOREIGN KEY([TMDP_StateId])
REFERENCES [dbo].[States] ([State_Id])
GO
ALTER TABLE [dbo].[TMDP] CHECK CONSTRAINT [FK_TMDP_States]
GO
ALTER TABLE [dbo].[TMDP]  WITH CHECK ADD  CONSTRAINT [FK_TMDP_TMD] FOREIGN KEY([TMDP_TMDId])
REFERENCES [dbo].[TMD] ([TMD_Id])
GO
ALTER TABLE [dbo].[TMDP] CHECK CONSTRAINT [FK_TMDP_TMD]
GO
ALTER TABLE [dbo].[UserRoles]  WITH CHECK ADD  CONSTRAINT [FK_UserRoles_Roles] FOREIGN KEY([UserRole_RoleId])
REFERENCES [dbo].[Roles] ([Role_Id])
GO
ALTER TABLE [dbo].[UserRoles] CHECK CONSTRAINT [FK_UserRoles_Roles]
GO
ALTER TABLE [dbo].[UserRoles]  WITH CHECK ADD  CONSTRAINT [FK_UserRoles_Users] FOREIGN KEY([UserRole_UserId])
REFERENCES [dbo].[Users] ([User_Id])
GO
ALTER TABLE [dbo].[UserRoles] CHECK CONSTRAINT [FK_UserRoles_Users]
GO
