USE [JWMSH_2016]
GO
/****** Object:  StoredProcedure [dbo].[AddMidOrder]    Script Date: 2016/3/6 21:53:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



USE [JWMSH_2016]
GO

if OBJECT_ID('ProDelivery') is not null
drop table ProDelivery


if OBJECT_ID('ProDeliveryDetail') is not null
drop table ProDeliveryDetail


if OBJECT_ID('ProStoreDetail') is not null
drop table ProStoreDetail


if OBJECT_ID('Rm_Po') is not null
drop table Rm_Po


if OBJECT_ID('Rm_StoreDetail') is not null
drop table Rm_StoreDetail

-- =============================================
-- Author:		upjd
-- Create date: 20160305
-- Description:	添加中间接口任务指令记录
-- =============================================
CREATE PROCEDURE [dbo].[AddMidOrder]
	@cGuid nvarchar(50)
	,@cType nvarchar(50)
	,@cTable nvarchar(50)
	,@cOrderNumber nvarchar(50)
AS
BEGIN
	INSERT INTO [dbo].[Wms_M_Order]
           ([cGuid]
           ,[cType]
           ,[cTable]
           ,[cOrderNumber]
           ,[bUpdate])
     VALUES
           (@cGuid,
			@cType,
			@cTable,
			@cOrderNumber,
			0)

END
GO
/****** Object:  StoredProcedure [dbo].[AddProDelivery]    Script Date: 2016/3/6 21:53:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:upjd
-- Create date: 20140713
-- Description:	添加产品出库单
-- =============================================
CREATE PROCEDURE [dbo].[AddProDelivery]
(
	@AutoID int = NULL output,
	@cCode nvarchar(30) output,
	@dDate datetime = NULL,
	@cOrderCode nvarchar(30) = NULL,       
	@cCusCode nvarchar(30) = NULL,
	@cCusName nvarchar(50) = NULL,
	@cMaker nvarchar(50) = NULL,
	@cMemo nvarchar(255) = NULL,
	@cOrderType NVARCHAR(40),
	@OrderDate DATE,
	@DeliveryDate DATE,
	@cDepCode NVARCHAR(20) = NULL,
	@cDepName NVARCHAR(50) = NULL,
	@cOutType NVARCHAR(20) = NULL
)
AS
BEGIN

	SET NOCOUNT OFF
	DECLARE @Err int

	--定义变量
	declare  @temp nvarchar(50),@itemp int
	--取年月日121116
	set @temp=right((select convert(varchar(10),getdate(),112)),6)
	--判断当天是否开始入库
	set @itemp=(select COUNT(*) from ProDelivery where substring(cCode,len(cCode)-8,6) =@temp)
	--如果大于零则是开始采购
	if @itemp>0
	set @cCode='PD'+(select top 1 @temp+
	Right('000'+cast(convert(integer,right(cCode,3))+1 as varchar),3)
	from ProDelivery where substring(cCode,len(cCode)-8,6) =@temp
	order by cCode desc)
	else
	set @cCode='PD'+(@temp+'001')

	INSERT
	INTO [ProDelivery]
	(
		[cCode],
		[dDate],
		[cOrderCode],
		[cCusCode],
		[cCusName],
		[cMaker],
		[dMaketime],
		[cVerifyState],
		[dAddTime],
		[cMemo],
		cOrderType,
		OrderDate,
		DeliveryDate,
		cDepCode,
		cDepName,
		cOutType
	)
	VALUES
	(
		@cCode,
		@dDate,
		@cOrderCode,
		@cCusCode,
		@cCusName,
		@cMaker,
		GETDATE(),
		'未审',
		GETDATE(),
		@cMemo,
		@cOrderType,
		@OrderDate,
		@DeliveryDate,
		@cDepCode,
		@cDepName,
		@cOutType
	)

	SET @Err = @@Error

	SELECT @AutoID = SCOPE_IDENTITY()

	RETURN @Err
END




GO
/****** Object:  StoredProcedure [dbo].[ApproveProDelivery]    Script Date: 2016/3/6 21:53:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:upjd
-- Create date: 20140711
-- Description:	审核商品出库单
-- =============================================
Create PROCEDURE [dbo].[ApproveProDelivery]
	@AutoID INT,
	@cHandler NVARCHAR(50)
AS
BEGIN
	----将没有在库存现量表中的记录，写入
	--INSERT INTO ProCurrentStock(cLotNo,[cInvCode],[cInvName],iQuantity,dDate)
	--SELECT  cLotNo,[cInvCode],[cInvName],0,dDate
	--FROM ProBarCode
	--WHERE 
	--cLotNo+cInvCode NOT IN 
	--(SELECT cLotNo+cInvCode FROM ProCurrentStock)
	
	
	----更新库存数据
	--UPDATE ProCurrentStock 
	--SET iQuantity = ISNULL(rcs.iQuantity,0)-ISNULL(a.iQuantity,0),
	--	dLastCheckDate = GETDATE()
	--FROM
	--(
	--SELECT cInvCode,rdd.cLotNo,rdd.iQuantity
	--FROM ProDelivery AS rd
	--INNER JOIN ProDeliveryDetail AS rdd ON rd.AutoID=rdd.ID
	--WHERE rd.AutoID=@AutoID AND rd.cVerifyState='未审'
	--)a 
	--INNER JOIN ProCurrentStock AS rcs ON a.cInvCode=rcs.cInvCode AND a.cLotNo=rcs.cLotNo
	
	
	UPDATE	ProDelivery
	SET cVerifyState = '已审',dVeriDate=GetDate(),cHandler=@cHandler
	WHERE AutoID=@AutoID
	
END



GO
/****** Object:  StoredProcedure [dbo].[ManualAddFunction]    Script Date: 2016/3/6 21:53:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		upjd
-- Create date: 20160302
-- Description:	Manual Add Function
-- =============================================
CREATE PROCEDURE [dbo].[ManualAddFunction] 
	@cFunction nvarchar(50),
	@cModule nvarchar(50),
	@bMenu bit,
	@cClass nvarchar(255)
AS
BEGIN
	if exists(select * from BFunction where cFunction=@cFunction or cClass=@cClass)
		return -1;

	INSERT INTO [dbo].[BFunction]
           ([cFunction]
           ,[cModule]
           ,[bMenu]
           ,[cClass])
     VALUES(
	 @cFunction, 
	 @cModule,
	 @bMenu,
	 @cClass
	)

	return 1
	 
END

GO
/****** Object:  StoredProcedure [dbo].[Upload_ProDeliveryDetail]    Script Date: 2016/3/6 21:53:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		upjd
-- Create date: 20160229
-- Description:	AddProDeliveryDetail
-- =============================================
CREATE PROCEDURE [dbo].[Upload_ProDeliveryDetail]
	@cGuid nvarchar(50),
	@ID int ,
	@FItemID int ,
	@cBarCode nvarchar(50) ,
	@cCode nvarchar(30) ,
	@cLotNo nvarchar(30) ,
	@cInvCode nvarchar(30) ,
	@cInvName nvarchar(50) ,
	@iQuantity decimal(14, 6) ,
	@FSPNumber nvarchar(50) ,
	@dScanTime datetime ,
	@cBoxNumber nvarchar(50) ,
	@cOperator nvarchar(50) ,
	@cMemo nvarchar(255) 
AS
BEGIN
	INSERT INTO [dbo].[ProDeliveryDetail]
           (cGuid
		   ,[ID]
           ,[FItemID]
           ,[cBarCode]
           ,[cCode]
           ,[cLotNo]
           ,[cInvCode]
           ,[cInvName]
           ,[iQuantity]
           ,[FSPNumber]
           ,[dAddTime]
           ,[dScanTime]
           ,[cBoxNumber]
           ,[cOperator]
           ,[cMemo])
     VALUES
	 (
	 @cGuid,
		 @ID,
		 @FItemID,
		 @cBarCode,
		 @cCode,
		 @cLotNo,
		 @cInvCode,
		 @cInvName,
		 @iQuantity,
		 @FSPNumber,
		 getdate(),
		 @dScanTime,
		 @cBoxNumber,
		 @cOperator,
		 @cMemo
	  )
END

GO
/****** Object:  StoredProcedure [dbo].[Upload_ProStoreDetail]    Script Date: 2016/3/6 21:53:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		upjd
-- Create date: 20160302
-- Description:	上传入库记录
-- =============================================
CREATE PROCEDURE [dbo].[Upload_ProStoreDetail]
	@cGuid nvarchar(50),
	@FItemID int ,
	@cBoxNumber nvarchar(50) ,
	@cBarCode nvarchar(50) ,
	@cLotNo nvarchar(50) ,
	@cInvCode nvarchar(30) ,
	@cInvName nvarchar(50) ,
	@iQuantity decimal(14, 6) ,
	@FSPNumber nvarchar(50) ,
	@cMemo nvarchar(255) ,
	@cPdaSN nvarchar(50) ,
	@cUser nvarchar(50) ,
	@dScanTime datetime 
AS
BEGIN
	INSERT INTO [dbo].[ProStoreDetail]
           (cGuid
		   ,[FItemID]
           ,[cBoxNumber]
           ,[cBarCode]
           ,[cLotNo]
           ,[cInvCode]
           ,[cInvName]
           ,[iQuantity]
           ,[FSPNumber]
           ,[bDelivery]
           ,[cMemo]
           ,[dDate]
           ,[cPdaSN]
           ,[cUser]
           ,[dScanTime]
           ,[bUpdate])
     VALUES
           (@cGuid,
		   @FItemID,
			@cBoxNumber,
			@cBarCode,
			@cLotNo,
			@cInvCode,
			@cInvName,
			@iQuantity,
			@FSPNumber,
			0,
			@cMemo,
			getdate(),
			@cPdaSN,
			@cUser,
			@dScanTime,
			0)

END
GO
/****** Object:  StoredProcedure [dbo].[Upload_RmPo]    Script Date: 2016/3/6 21:53:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		upjd
-- Create date: 2014-12-21
-- Description:	上传二次拣货出库单
-- =============================================
CREATE PROCEDURE [dbo].[Upload_RmPo]
	@cOrderNumber       nvarchar(50), 
	@cInvCode       nvarchar(50), 
	@cInvName       nvarchar(255), 
	@cUnit       nvarchar(30)=null, 
	@iQuantity       decimal(18,4), 
	@iScanQuantity       decimal(18,4), 
	@cVendor       nvarchar(50),
	@cMemo	nvarchar(255),
	@cUser       nvarchar(50), 
	@cGuid       nvarchar(50),
	@FEntryID	int,
	@FItemID int
AS
BEGIN
	INSERT INTO [dbo].[Rm_Po]
           ([cOrderNumber]
           ,[cInvCode]
           ,[cInvName]
           ,[cUnit]
           ,[iQuantity]
           ,[iScanQuantity]
           ,[cVendor]
		   ,[cMemo]
           ,[dDate]
           ,[cUser]
           ,[cGuid]
		   ,FEntryID
		   ,FItemID)
	Values(	@cOrderNumber,
			@cInvCode,
			@cInvName,
			@cUnit,
			@iQuantity,
			@iScanQuantity,
			@cVendor,
			@cMemo,
			getdate(),
			@cUser,
			@cGuid,
			@FEntryID,
			@FItemID)

	--if  not exists(select * from Wms_M_Eas where cGuid=@cGuid)
	--begin 
	--	--定义变量
	--	declare  @temp nvarchar(50),@itemp int,@cEasNewOrder nvarchar(50)
	--	--取年月日121116
	--	set @temp=right((select convert(varchar(10),getdate(),112)),6)
	--	--判断当天是否开始入库
	--	set @itemp=(select COUNT(*) from Wms_M_Eas where substring(cEasNewOrder,len(cEasNewOrder)-8,6) =@temp and cType='采购收货')
	--	--如果大于零则是开始采购
	--	if @itemp>0
	--	set @cEasNewOrder='RO'+(select top 1 @temp+
	--	Right('000'+cast(convert(integer,right(cEasNewOrder,3))+1 as varchar),3)
	--	from Wms_M_Eas where substring(cEasNewOrder,len(cEasNewOrder)-8,6) =@temp and cType='采购收货'
	--	order by cEasNewOrder desc)
	--	else
	--	set @cEasNewOrder='RO'+(@temp+'001')

	--	INSERT INTO [dbo].[Wms_M_Eas]
 --          ([cType]
 --          ,[cGuid]
 --          ,[cOrderNumber]
	--	   ,cEasNewOrder
 --          ,[cState])
 --    VALUES
 --          ('采购收货',
	--	   @cGuid,
	--	   @cOrderNumber,
	--	   @cEasNewOrder,
	--	   '初始化'
	--	   )
		
	--end
			
END




GO
/****** Object:  StoredProcedure [dbo].[Upload_RmStoreDetail]    Script Date: 2016/3/6 21:53:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		upjd
-- Create date: 2014-12-21
-- Description:	上传采购收货记录
-- =============================================
CREATE PROCEDURE [dbo].[Upload_RmStoreDetail]
	@cSerialNumber nvarchar(50),
	@cOrderNumber     nvarchar(50),
	@cLotNo     nvarchar(50)=null, 
	@cInvCode       nvarchar(50), 
	@cInvName       nvarchar(255), 
	@cUnit       nvarchar(30)=null, 
	@iQuantity       decimal(18,4), 
	@dScanTime       datetime=null,  
	@cUser       nvarchar(50), 
	@cGuid       nvarchar(50),
	@FEntryID	int,
	@FitemID	int,
	@FSPNumber	nvarchar(50)
AS
BEGIN
	INSERT INTO [dbo].[Rm_StoreDetail]
           ([cSerialNumber]
           ,[cOrderNumber]
		   ,[cLotNo]
           ,[cInvCode]
           ,[cInvName]
           ,[cUnit]
           ,[iQuantity]
		   ,[dDate]
           ,[dScanTime]
           ,[cUser]
		   ,cGuid
		   ,FEntryID
		   ,FitemID	
		   ,FSPNumber
		   )
	Values(	@cSerialNumber,
			@cOrderNumber,
			@cLotNo,
			@cInvCode,
			@cInvName,
			@cUnit,
			@iQuantity,
			getdate(),
			@dScanTime,
			@cUser,
			@cGuid,
			@FEntryID,
			@FitemID,	
			@FSPNumber
			)
			
END




GO
/****** Object:  Table [dbo].[ProDelivery]    Script Date: 2016/3/6 21:53:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProDelivery](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[cCode] [nvarchar](30) NOT NULL,
	[dDate] [datetime] NULL,
	[cOrderCode] [nvarchar](30) NULL,
	[cCusCode] [nvarchar](30) NULL,
	[cCusName] [nvarchar](50) NULL,
	[cMaker] [nvarchar](50) NULL,
	[dMaketime] [datetime] NULL,
	[cModifyPerson] [nvarchar](50) NULL,
	[dModifyDate] [datetime] NULL,
	[cHandler] [nvarchar](50) NULL,
	[dVeriDate] [datetime] NULL,
	[cVerifyState] [nvarchar](50) NULL,
	[dAddTime] [datetime] NULL,
	[cMemo] [nvarchar](255) NULL,
	[cOrderType] [nvarchar](40) NULL,
	[OrderDate] [date] NULL,
	[DeliveryDate] [date] NULL,
	[cDepCode] [nvarchar](20) NULL,
	[cDepName] [nvarchar](50) NULL,
	[cOutType] [nvarchar](20) NULL,
 CONSTRAINT [PK_ProDelivery] PRIMARY KEY CLUSTERED 
(
	[cCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProDeliveryDetail]    Script Date: 2016/3/6 21:53:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProDeliveryDetail](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[ID] [int] NULL,
	[cGuid] [nvarchar](50) NULL,
	[FItemID] [int] NULL,
	[cBarCode] [nvarchar](50) NULL,
	[cCode] [nvarchar](30) NULL,
	[cLotNo] [nvarchar](30) NULL,
	[cInvCode] [nvarchar](30) NULL,
	[cInvName] [nvarchar](50) NULL,
	[iQuantity] [decimal](14, 6) NULL,
	[FSPNumber] [nvarchar](50) NULL,
	[dAddTime] [datetime] NULL,
	[dScanTime] [datetime] NULL,
	[cBoxNumber] [nvarchar](50) NULL,
	[cOperator] [nvarchar](50) NULL,
	[cMemo] [nvarchar](255) NULL,
 CONSTRAINT [PK_ProDeliveryDetail] PRIMARY KEY CLUSTERED 
(
	[AutoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProStoreDetail]    Script Date: 2016/3/6 21:53:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProStoreDetail](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[cGuid] [nvarchar](50) NULL,
	[FItemID] [int] NULL,
	[cBoxNumber] [nvarchar](50) NULL,
	[cBarCode] [nvarchar](50) NULL,
	[cLotNo] [nvarchar](50) NULL,
	[cInvCode] [nvarchar](30) NULL,
	[cInvName] [nvarchar](50) NULL,
	[iQuantity] [decimal](14, 6) NULL,
	[FSPNumber] [nvarchar](50) NULL,
	[bDelivery] [bit] NULL CONSTRAINT [DF_ProStoreDetail_bDelivery]  DEFAULT ((0)),
	[cMemo] [nvarchar](255) NULL,
	[dDate] [datetime] NULL,
	[cPdaSN] [nvarchar](50) NULL,
	[cUser] [nvarchar](50) NULL,
	[dScanTime] [datetime] NULL,
	[bUpdate] [bit] NULL CONSTRAINT [DF_ProStoreDetail_bUpdate]  DEFAULT ((0)),
 CONSTRAINT [PK_ProStoreDetail] PRIMARY KEY CLUSTERED 
(
	[AutoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Rm_Po]    Script Date: 2016/3/6 21:53:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Rm_Po](
	[AutoID] [bigint] IDENTITY(1,1) NOT NULL,
	[cOrderNumber] [nvarchar](50) NULL,
	[cInvCode] [nvarchar](50) NULL,
	[cInvName] [nvarchar](255) NULL,
	[cUnit] [nvarchar](30) NULL,
	[iQuantity] [decimal](18, 4) NULL,
	[iScanQuantity] [decimal](18, 4) NULL,
	[cVendor] [nvarchar](50) NULL,
	[cMemo] [nvarchar](255) NULL,
	[dDate] [datetime] NULL,
	[cUser] [nvarchar](50) NULL,
	[cGuid] [nvarchar](50) NULL,
	[FEntryID] [int] NULL,
	[FItemID] [int] NULL,
 CONSTRAINT [PK_RmPo] PRIMARY KEY CLUSTERED 
(
	[AutoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Rm_StoreDetail]    Script Date: 2016/3/6 21:53:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Rm_StoreDetail](
	[AutoID] [bigint] IDENTITY(1,1) NOT NULL,
	[cSerialNumber] [nvarchar](50) NULL,
	[cLotNo] [nvarchar](50) NULL,
	[cOrderNumber] [nvarchar](50) NULL,
	[cInvCode] [nvarchar](50) NULL,
	[cInvName] [nvarchar](255) NULL,
	[cUnit] [nvarchar](50) NULL,
	[iQuantity] [decimal](18, 4) NULL,
	[dDate] [datetime] NULL,
	[dScanTime] [datetime] NULL,
	[cUser] [nvarchar](50) NULL,
	[cGuid] [nvarchar](50) NULL,
	[FEntryID] [int] NULL,
	[FSPNumber] [nvarchar](50) NULL,
	[FitemID] [int] NULL,
 CONSTRAINT [PK_Rm_StoreDetail] PRIMARY KEY CLUSTERED 
(
	[AutoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Wms_M_Order]    Script Date: 2016/3/6 21:53:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Wms_M_Order](
	[AutoID] [bigint] IDENTITY(1,1) NOT NULL,
	[cGuid] [nvarchar](50) NULL,
	[cType] [nvarchar](50) NULL,
	[cTable] [nvarchar](50) NULL,
	[cOrderNumber] [nvarchar](255) NULL,
	[bUpdate] [bit] NULL,
 CONSTRAINT [PK_Wms_M_Order] PRIMARY KEY CLUSTERED 
(
	[AutoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  View [dbo].[View_ProductLabel]    Script Date: 2016/3/6 21:53:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[View_ProductLabel]
AS
SELECT   a.AutoID, a.cSerialNumber, a.cBarCode, a.iQuantity, a.cDefine1, a.cDefine2, a.cDefine3, a.cDefine4, a.cMemo, b.BomID, 
                b.cFitemID, b.cInvCode, b.cInvName, b.cInvStd, b.cFullName, b.cOrderNumber, b.iQuantity AS iSheduleQty, b.dDate, 
                b.cMemo AS iSheduleMemo, b.cDeptName, b.dAddTime, b.FBatchNo, 'P*' + CONVERT(nvarchar(20), b.cFitemID) 
                + '*L*' + ISNULL(b.FBatchNo, N'') + '*S*' + a.cBarCode AS ProBarCode
FROM      dbo.ProductLabel AS a INNER JOIN
                dbo.Shift AS b ON a.cSerialNumber = b.cSerialNumber

GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[50] 4[14] 2[18] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "a"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 145
               Right = 213
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "b"
            Begin Extent = 
               Top = 6
               Left = 251
               Bottom = 145
               Right = 429
            End
            DisplayFlags = 280
            TopColumn = 2
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 24
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 3375
         Alias = 1695
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_ProductLabel'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'View_ProductLabel'
GO
