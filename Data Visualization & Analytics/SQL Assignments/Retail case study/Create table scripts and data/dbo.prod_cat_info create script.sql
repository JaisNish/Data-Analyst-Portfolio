USE [SQLCaseStudy1_Retail]
GO

/****** Object:  Table [dbo].[prod_cat_info]    Script Date: 10-03-2022 21:46:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[prod_cat_info](
	[prod_cat_code] [tinyint] NOT NULL,
	[prod_cat] [nvarchar](50) NOT NULL,
	[prod_sub_cat_code] [tinyint] NOT NULL,
	[prod_subcat] [nvarchar](50) NOT NULL
) ON [PRIMARY]
GO

