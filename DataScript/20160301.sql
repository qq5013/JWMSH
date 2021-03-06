USE [JWMSH_2016]
GO
/****** Object:  StoredProcedure [dbo].[AddProDelivery]    Script Date: 2016/3/1 17:13:46 ******/
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
/****** Object:  StoredProcedure [dbo].[ApproveProDelivery]    Script Date: 2016/3/1 17:13:46 ******/
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
/****** Object:  Table [dbo].[ProDelivery]    Script Date: 2016/3/1 17:13:46 ******/
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
/****** Object:  Table [dbo].[ProDeliveryDetail]    Script Date: 2016/3/1 17:13:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProDeliveryDetail](
	[AutoID] [int] IDENTITY(1,1) NOT NULL,
	[ID] [int] NULL,
	[FItemID] [int] NULL,
	[cCode] [nvarchar](30) NULL,
	[cLotNo] [nvarchar](30) NULL,
	[cInvCode] [nvarchar](30) NULL,
	[cInvName] [nvarchar](50) NULL,
	[iQuantity] [decimal](14, 6) NULL,
	[FSPNumber] [nvarchar](50) NULL,
	[dAddTime] [datetime] NULL,
	[dScanTime] [datetime] NULL,
	[cOperator] [nvarchar](50) NULL,
	[cMemo] [nvarchar](255) NULL,
 CONSTRAINT [PK_ProDeliveryDetail] PRIMARY KEY CLUSTERED 
(
	[AutoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
