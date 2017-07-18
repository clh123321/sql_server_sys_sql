
--表变量
/****** Object:  UserDefinedTableType [dbo].[AdvertisingInfoList]    Script Date: 2017/7/18 16:34:18 ******/
CREATE TYPE [dbo].[AdvertisingInfoList] AS TABLE(
	[AdvertId] [INT] NOT NULL,
	[CityId] [INT] NULL,
	[ShowStatus] [INT] NULL,
	[VendorId] [INT] NULL,
	[BeginDate] [DATETIME] NULL,
	[MediaId] [SMALLINT] NULL,
	[CSID] [INT] NULL,
	[ImgUrl] [NVARCHAR](100) NULL,
	[ImgLinkUrl] [NVARCHAR](100) NULL,
	[PositionId] [SMALLINT] NULL,
	[AllocationCSID] [INT] NULL,
	[AdvertUpdateTime] [DATETIME] NULL
)
GO

--应用
ALTER PROCEDURE [dbo].[P_AdvertisingToShow_BulkCopy_Save]
    @ExecDuration INT
   ,@SendCount INT = 1
   ,@SendStatus INT
   ,@ExceptionMessage NVARCHAR(2000)
   ,@AdvertisingList AdvertisingInfoList READONLY
   ,@Ret_Msg NVARCHAR(255) = '' OUTPUT                   -- 返回信息 
AS
    BEGIN
		
		-- 对传入敏感数据检查
		/*
        IF @QueryType <=0 OR @AdvertDate IS NULL
        BEGIN
			SET @Ret_Msg='传入的数据无效';
			RETURN -1;
        END*/
		-- 开始 Try
        BEGIN TRY  		
			
            INSERT  INTO [dbo].[AdvertisingToShow]
                    ([AdvertId]
                    ,[CityId]
                    ,[SendStatus]
                    ,[SendCount]
                    ,[ShowStatus]
                    ,[VendorId]
                    ,[BeginDate]
                    ,[MediaId]
                    ,[CSID]
                    ,[ImgUrl]
                    ,[ImgLinkUrl]
                    ,[PositionId]
                    ,[AllocationCSID]
                    ,[ExecDuration]
                    ,[ExceptionMessage]
                    ,[AdvertUpdateTime]
                    ,[IsActive]
                    ,[CreateTime]
                    ,[UpdateTime]
                    )
            SELECT  list.AdvertId
                   ,list.CityId
                   ,@SendStatus
                   ,@SendCount
                   ,list.[ShowStatus]
                   ,list.[VendorId]
                   ,list.[BeginDate]
                   ,list.[MediaId]
                   ,list.[CSID]
                   ,list.[ImgUrl]
                   ,list.[ImgLinkUrl]
                   ,list.[PositionId]
                   ,list.[AllocationCSID]
                   ,@ExecDuration
                   ,@ExceptionMessage
                   ,list.[AdvertUpdateTime]
                   ,1
                   ,GETDATE()
                   ,GETDATE()
            FROM    @AdvertisingList AS list;
			
            SET @Ret_Msg = '保存成功';
            RETURN 0;        
        END TRY
        -- 结束Try
        -- 开始对抛出的例外处理
        BEGIN CATCH
            SET @Ret_Msg = ERROR_MESSAGE();
            RETURN ERROR_NUMBER();
        END CATCH;   
    END;
	
	
	--C#    调用
	/*
	/// <summary>
        /// 广告展示推送-批量
        /// </summary>
        /// <param name="list"></param>
        /// <returns></returns>
        public bool BulkCopy(List<Entity> list, int ExecDuration, int SendCount, int SendStatus, string ExceptionMessage)
        {
            bool result = false;
            try
            {
                #region 组织table
                DataTable dt = new DataTable();

                dt.Columns.Add("AdvertId", typeof(int));
                dt.Columns.Add("CityId", typeof(int));
                dt.Columns.Add("ShowStatus", typeof(int));
                dt.Columns.Add("VendorId", typeof(int));
                dt.Columns.Add("BeginDate", typeof(DateTime));
                dt.Columns.Add("MediaId", typeof(short));
                dt.Columns.Add("CSID", typeof(int));
                dt.Columns.Add("ImgUrl", typeof(string));
                dt.Columns.Add("ImgLinkUrl", typeof(string));
                dt.Columns.Add("PositionId", typeof(short));
                dt.Columns.Add("AllocationCSID", typeof(int));
                dt.Columns.Add("AdvertUpdateTime", typeof(DateTime));
                
                foreach (AdvertisingToShowEntity entity in list)
                {
                    DataRow dr = dt.NewRow();

                    dr["AdvertId"] = entity.AdvertId;
                    dr["CityId"] = entity.CityId;
                    dr["ShowStatus"] = entity.ShowStatus;
                    dr["VendorId"] = entity.VendorId;
                    dr["BeginDate"] = entity.BeginDate;
                    dr["MediaId"] = entity.MediaId;
                    dr["CSID"] = entity.Csid;
                    dr["ImgUrl"] = entity.ImgUrl;
                    dr["ImgLinkUrl"] = entity.ImgLinkUrl;
                    dr["PositionId"] = entity.PositionId;
                    dr["AllocationCSID"] = entity.AllocationCSID;
                    dr["AdvertUpdateTime"] = entity.AdvertUpdateTime;
                    dt.Rows.Add(dr);
                }
                #endregion

                //  返回值说明
                SqlParameter paramRetMsg = new SqlParameter("@Ret_Msg", SqlDbType.NVarChar, 255);
                paramRetMsg.Direction = ParameterDirection.Output;
                //  返回值，成功或者失败
                SqlParameter paramReturn = new SqlParameter("RETURN_VALUE", SqlDbType.Int);
                paramReturn.Direction = ParameterDirection.ReturnValue;

                SqlParameter[] paras = {
					    new SqlParameter("@ExecDuration", SqlDbType.Int),
                        new SqlParameter("@SendCount", SqlDbType.Int),
                        new SqlParameter("@SendStatus", SqlDbType.Int),
                        new SqlParameter("@ExceptionMessage", SqlDbType.NVarChar,2000),
                        new SqlParameter("@AdvertisingList", SqlDbType.Structured),
                        paramRetMsg,paramReturn
			    };
                paras[0].Value = ExecDuration;
                paras[1].Value = SendCount;
                paras[2].Value = SendStatus;
                paras[3].Value = string.IsNullOrWhiteSpace(ExceptionMessage) ? "" : ExceptionMessage;
                paras[4].Value = dt;

                int num = SqlHelper.ExecuteNonQuery(ModelConnection, CommandType.StoredProcedure, "P_AdvertisingToShow_BulkCopy_Save", paras);
                logger.Info(string.Format("num={0},list={1},paramRetMsg={2},paramReturn={3}",
                    num.ToString(), list.ObjToJson(),
                    paramRetMsg.Value, paramReturn.Value));
                return num > 0;
            }
            catch (Exception ex)
            {
                
            }

            return result;
        }
	*/