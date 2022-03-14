USE [SQLCaseStudy1_Retail]
GO

/****** Object:  Table [dbo].[Transactions]    Script Date: 10-03-2022 21:46:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Transactions](
	[transaction_id] [bigint] NOT NULL,
	[cust_id] [int] NOT NULL,
	[tran_date] [date] NOT NULL,
	[prod_subcat_code] [tinyint] NOT NULL,
	[prod_cat_code] [tinyint] NOT NULL,
	[Qty] [smallint] NOT NULL,
	[Rate] [smallint] NOT NULL,
	[Tax] [float] NOT NULL,
	[total_amt] [float] NOT NULL,
	[Store_type] [nvarchar](50) NOT NULL
) ON [PRIMARY]
GO

