USE [PayCenter]
GO
/****** Object:  StoredProcedure [dbo].[P_PayCenter_GatewayRecord_Update]    Script Date: 2015/7/9 19:52:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,caolh,曹立华>
-- Create date: <Create Date,2015-06-18,>
-- Description:	<Description,修改支付订单,>
-- ============================================
ALTER PROCEDURE [dbo].[P_PayCenter_GatewayRecord_Update] 
	@RecordID bigint output,
	@GatewayNumber bigint,
	@WxPayAppID nvarchar(18),
	@PayPlatId int,
	@PayChannelId int,
	@PayTypeId int,
	@CreateType int,
	@BankID nvarchar(10),
	@BankName nvarchar(20),
	@BankCardType int,
	@BankCardOwnerType int,
	@AppId nvarchar(50),
	@AppHistoryName nvarchar(200),
	@ClientIP nvarchar(20),
	@DealerID bigint,
	@DealOrderId varchar(50),
	@DealNotityUrl nvarchar(100),
	@TradeAmt decimal(18,4),
	@CurrencyType int,
	@GoodsName nvarchar(20),
	@GoodsNote nvarchar(50),
	@CustomerFlag nvarchar(50),
	@Timestamp nvarchar(20),
	@BillStatus int,
	@CreateUserId int,
	@CreateUserName varchar(50),
	@CreateTime DATETIME,
	@Ret_Msg                       nvarchar(255) output ,                   -- 返回信息 
	@ReturnGatewayNumber			bigint output
 AS 
	BEGIN
		
		-- 对传入敏感数据检查 交易金额 不能为0
        IF @RecordID <=0 OR @GatewayNumber <=0 OR @DealOrderId = '' OR @DealOrderId IS NULL OR @TradeAmt <= 0 
        BEGIN
			SET @Ret_Msg='传入的数据无效';
			RETURN -1;
        END
        
		BEGIN TRAN Tran_GatewayRecord_Create    --开始事务 

		-- 开始 Try
        BEGIN TRY  		

			DECLARE @NowTime DATETIME,@QueryBillStatus INT,@QueryRecordID BIGINT,@DetailID BIGINT
			SET @NowTime = GETDATE()
			SET @QueryBillStatus = 0
			SET @QueryRecordID = 0;

			--流水表下单
			INSERT INTO [GatewayRecordDetail](
				[GatewayNumber],[WxPayAppID],[PayPlatId],[PayChannelId],[PayTypeId],[CreateType],[BankID],[BankName],[BankCardType],[BankCardOwnerType],[AppId],[AppHistoryName],[ClientIP],[DealerID],[DealOrderId],[DealNotityUrl],[TradeAmt],[CurrencyType],[GoodsName],[GoodsNote],[CustomerFlag],[Timestamp],[BillStatus],[CreateUserId],[CreateUserName],[CreateTime]
			)VALUES(
				@GatewayNumber,@WxPayAppID,@PayPlatId,@PayChannelId,@PayTypeId,@CreateType,@BankID,@BankName,@BankCardType,@BankCardOwnerType,@AppId,@AppHistoryName,@ClientIP,@DealerID,@DealOrderId,@DealNotityUrl,@TradeAmt,@CurrencyType,@GoodsName,@GoodsNote,@CustomerFlag,@Timestamp,@BillStatus,@CreateUserId,@CreateUserName,@NowTime
			)

			SET @DetailID = @@IDENTITY
			IF @@ERROR<>0 OR @@ROWCOUNT=0
			BEGIN
				SET @Ret_Msg='更新网关流水表记录出错';
				ROLLBACK TRAN;
				RETURN 100;
			END  

			--查看记录表是否存在此数据
			SELECT @QueryRecordID = RecordID,@QueryBillStatus = BillStatus FROM GatewayRecord WHERE DealOrderId = @DealOrderId
			IF @QueryRecordID <= 0 
			BEGIN
				--不存在数据          
				INSERT INTO [GatewayRecord](
					[GatewayNumber],[WxPayAppID],[PayPlatId],[PayChannelId],[PayTypeId],[CreateType],[BankID],[BankName],[BankCardType],[BankCardOwnerType],[AppId],[AppHistoryName],[ClientIP],[DealerID],[DealOrderId],[DealNotityUrl],[TradeAmt],[CurrencyType],[GoodsName],[GoodsNote],[CustomerFlag],[Timestamp],[BillStatus],[CreateUserId],[CreateUserName],[CreateTime]
				)VALUES(
					@GatewayNumber,@WxPayAppID,@PayPlatId,@PayChannelId,@PayTypeId,@CreateType,@BankID,@BankName,@BankCardType,@BankCardOwnerType,@AppId,@AppHistoryName,@ClientIP,@DealerID,@DealOrderId,@DealNotityUrl,@TradeAmt,@CurrencyType,@GoodsName,@GoodsNote,@CustomerFlag,@Timestamp,@BillStatus,@CreateUserId,@CreateUserName,@NowTime
				)

				SET @RecordID = @@IDENTITY

				IF @@ERROR<>0 OR @@ROWCOUNT=0
				BEGIN
					SET @Ret_Msg='插入网关记录表出错';
					ROLLBACK TRAN;
					RETURN 100;
				END  
			END          
			ELSE IF @QueryRecordID > 0
			BEGIN
				--更新表
			    UPDATE [GatewayRecord] SET 
					[GatewayNumber] = @GatewayNumber,[WxPayAppID] = @WxPayAppID,[PayPlatId] = @PayPlatId,[PayChannelId] = @PayChannelId,
					[PayTypeId] = @PayTypeId,[CreateType] = @CreateType,[BankID] = @BankID,[BankName] = @BankName,
					[BankCardType] = @BankCardType,[BankCardOwnerType] = @BankCardOwnerType,[AppId] = @AppId,
					[AppHistoryName] = @AppHistoryName,[ClientIP] = @ClientIP,[DealerID] = @DealerID,
					[DealOrderId] = @DealOrderId,[DealNotityUrl] = @DealNotityUrl,[TradeAmt] = @TradeAmt,[CurrencyType] = @CurrencyType,
					[GoodsName] = @GoodsName,[GoodsNote] = @GoodsNote,
					[CustomerFlag] = @CustomerFlag,[Timestamp] = @Timestamp,
					[BillStatus] = @BillStatus,[UpdateTime] = @NowTime
				WHERE RecordID=@QueryRecordID
				
				SET @RecordID = @QueryRecordID 

				IF @@ERROR<>0 OR @@ROWCOUNT=0
				BEGIN
					SET @Ret_Msg='更新网关记录表出错';
					ROLLBACK TRAN;
					RETURN 100;
				END  
			END          
			     
			SET @ReturnGatewayNumber = @GatewayNumber 

			COMMIT TRAN;
			SET @Ret_Msg='更新记录成功';
            RETURN 0;        
        END TRY
        -- 结束Try
        -- 开始对抛出的例外处理
        BEGIN CATCH
			SET @Ret_Msg=ERROR_MESSAGE();
			ROLLBACK TRAN;
			RETURN ERROR_NUMBER();
        END CATCH;   
	END    