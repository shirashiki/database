

/****** Object:  Table [dbo].[DBobject_baseline]    Script Date: 06/03/2010 12:02:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[DBobject_baseline](
	[id_record] [int] IDENTITY(1,1) NOT NULL,
	[baseline_date] [datetime] NOT NULL,
	[xtype] [varchar](50) NOT NULL,
	[xtype_description] [varchar](150) NOT NULL,
	[object_name] [varchar](250) NOT NULL,
	[line_number] [int] NOT NULL,
	[line_content] [varchar](max) NOT NULL,
 CONSTRAINT [PK_DBobject_baseline] PRIMARY KEY CLUSTERED 
(
	[id_record] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

