IF OBJECT_ID ('sqlt.assertlog') IS NOT NULL
BEGIN
	DROP TABLE sqlt.assertlog
END
/****** Object:  Table [sqlt].[assertlog]    Script Date: 4/15/2022 9:07:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [sqlt].[assertlog](
	[id] [int] IDENTITY(1000,1) NOT NULL,
	[object_name] [varchar](100) NOT NULL,
	[assert_type] [varchar](100) NOT NULL,
	[column_name] [varchar](100) NULL,
	[column_type] [varchar](50) NULL,
	[actual_value] [nvarchar](max) NULL,
	[predicted_value] [nvarchar](max) NULL,
	[error] [varchar](500) NULL,
	[message] [varchar](500) NULL,
	[IsOk] [bit] NULL,
	[created_on] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [sqlt].[assertlog] ADD  DEFAULT (NULL) FOR [predicted_value]
GO

ALTER TABLE [sqlt].[assertlog] ADD  DEFAULT (getdate()) FOR [created_on]
GO


