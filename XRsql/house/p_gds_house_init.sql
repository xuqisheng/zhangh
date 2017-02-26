-- ------------------------------------------------------------------------------
--   客房中心初始化
-- ------------------------------------------------------------------------------

--  初始化
if exists (select 1 from sysobjects where name = 'p_gds_house_init' and type='P')
	drop proc p_gds_house_init
;
create proc  p_gds_house_init 
as

--  工作量管理
truncate table task_assignment
truncate table attendant_info

--  维修房管理
truncate table rm_ooo
truncate table rm_ooo_log
truncate table hrm_ooo

truncate table discrepant_room

--  房态表 2
truncate table hsmap
truncate table hsmap_new
truncate table hsmap_des
truncate table hsmap_bu
truncate table hsmap_term_end
truncate table hsmapsel

truncate table checkroom
truncate table room_input

--  失物招领管理
truncate table swreg
truncate table hswreg
truncate table swrep
truncate table hswrep
truncate table swreg_log
truncate table swrep_log

truncate table attendant_allot

--  单据号码
declare @bdate datetime, @mapcode varchar(10)
select @bdate = bdate1 from sysdata
select @mapcode = isnull((select mapcode from hs_sysdata), 'XR')
delete hs_sysdata
insert hs_sysdata values(	
			@mapcode,
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
			'F',
			null,
			null,
			null,
			null
		   )

--  报表
--  ......

return 0
;
