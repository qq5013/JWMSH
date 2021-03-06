USE [JWMSH_2016]
GO
/****** Object:  StoredProcedure [dbo].[proc_ShiftInsert]    Script Date: 2016/1/14 0:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		upjd
-- Create date: 20160112
-- Description:	新增班次制令单
-- =============================================
Create PROCEDURE [dbo].[proc_ShiftInsert] 
	@AutoID bigint output,
	@cSerialNumber nvarchar(155) = NULL output,
	@BomID bigint,
	@cFitemID nvarchar(30),
	@cInvCode nvarchar(50),
	@cInvName nvarchar(255),
	@cInvStd nvarchar(255),
	@cFullName nvarchar(255),
	@cOrderNumber nvarchar(50),
	@iQuantity int,
	@dDate date,
	@cDeptName nvarchar(255),
	@cMemo nvarchar(255)
AS
BEGIN

	--定义变量
	declare  @temp nvarchar(50),@itemp int
	--取年月日121116
	set @temp=right((select convert(varchar(10),getdate(),112)),6)
	--判断当天是否开始入库
	set @itemp=(select COUNT(*) from Shift where substring(cSerialNumber,len(cSerialNumber)-9,6) =@temp)
	--如果大于零则是开始采购
	if @itemp>0
	set @cSerialNumber='SF'+(select top 1 @temp+
	Right('0000'+cast(convert(integer,right(cSerialNumber,4))+1 as varchar),4)
	from Shift where substring(cSerialNumber,len(cSerialNumber)-9,6) =@temp
	order by cSerialNumber desc)
	else
	set @cSerialNumber='SF'+(@temp+'0001')

	INSERT INTO [dbo].[Shift]
           ([cSerialNumber]
           ,[BomID]
           ,[cFitemID]
           ,[cInvCode]
           ,[cInvName]
           ,[cInvStd]
           ,[cFullName]
           ,[cOrderNumber]
           ,[iQuantity]
           ,[dDate]
           ,[cMemo]
           ,[cDeptName]
           ,[dAddTime])
     VALUES
           (@cSerialNumber
		   ,@BomID
		   ,@cFitemID
		   ,@cInvCode
		   ,@cInvName
		   ,@cInvStd
		   ,@cFullName
		   ,@cOrderNumber
		   ,@iQuantity
		   ,@dDate
		   ,@cMemo
		   ,@cDeptName
		   ,getdate())

	set @AutoID=@@IDENTITY
END

GO
/****** Object:  StoredProcedure [dbo].[proc_ShiftUpdate]    Script Date: 2016/1/14 0:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		upjd
-- Create date: 20160112
-- Description:	新增班次制令单
-- =============================================
Create PROCEDURE [dbo].[proc_ShiftUpdate] 
	@AutoID bigint,
	@BomID bigint,
	@cFitemID nvarchar(30),
	@cInvCode nvarchar(50),
	@cInvName nvarchar(255),
	@cInvStd nvarchar(255),
	@cFullName nvarchar(255),
	@cOrderNumber nvarchar(50),
	@iQuantity int,
	@dDate date,
	@cDeptName nvarchar(255),
	@cMemo nvarchar(255)
AS
BEGIN

	UPDATE [dbo].[Shift]
   SET [BomID] = @BomID
      ,[cFitemID] = @cFitemID
      ,[cInvCode] = @cInvCode
      ,[cInvName] =@cInvName
      ,[cInvStd] =@cInvStd
      ,[cFullName] = @cFullName
      ,[cOrderNumber] = @cOrderNumber
      ,[iQuantity] = @iQuantity
      ,[dDate] = @dDate
      ,[cMemo] = @cMemo
      ,[cDeptName] = @cDeptName
	where AutoID=@AutoID
END

GO
/****** Object:  Table [dbo].[Shift]    Script Date: 2016/1/14 0:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Shift](
	[AutoID] [bigint] IDENTITY(1,1) NOT NULL,
	[cSerialNumber] [nvarchar](30) NULL,
	[BomID] [bigint] NOT NULL,
	[cFitemID] [int] NULL,
	[cInvCode] [nvarchar](50) NULL,
	[cInvName] [nvarchar](255) NULL,
	[cInvStd] [nvarchar](255) NULL,
	[cFullName] [nvarchar](255) NULL,
	[cOrderNumber] [nvarchar](50) NULL,
	[iQuantity] [int] NULL,
	[dDate] [date] NULL,
	[cMemo] [nchar](10) NULL,
	[cDeptName] [nvarchar](255) NULL,
	[dAddTime] [datetime] NULL CONSTRAINT [DF_Shift_dAddTime]  DEFAULT (getdate()),
 CONSTRAINT [PK_Shift] PRIMARY KEY CLUSTERED 
(
	[AutoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ShiftDetail]    Script Date: 2016/1/14 0:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShiftDetail](
	[AutoID] [bigint] IDENTITY(1,1) NOT NULL,
	[cSerialNumber] [nvarchar](30) NULL,
	[cFitemID] [int] NULL,
	[cInvCode] [nvarchar](50) NULL,
	[cInvName] [nvarchar](255) NULL,
	[cInvStd] [nvarchar](255) NULL,
	[cFullName] [nvarchar](255) NULL,
	[iQuantity] [decimal](18, 4) NULL,
	[FBatchNo] [nvarchar](50) NULL,
	[FStockID] [int] NULL,
	[FStockNumber] [nvarchar](50) NULL,
	[FStockName] [nvarchar](50) NULL,
	[FStockPlaceID] [int] NULL,
	[FStockPlaceNumber] [nvarchar](50) NULL,
	[FStockPlaceName] [nvarchar](50) NULL,
	[cMemo] [nchar](10) NULL,
	[dAddTime] [datetime] NULL,
 CONSTRAINT [PK_ShiftDetail] PRIMARY KEY CLUSTERED 
(
	[AutoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
