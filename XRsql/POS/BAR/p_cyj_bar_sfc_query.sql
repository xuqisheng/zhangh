
if exists(select 1 from sysobjects where type='P' and name='p_cyj_bar_sfc_query')
  drop procedure p_cyj_bar_sfc_query;

create proc  p_cyj_bar_sfc_query
   @storecode 	char(3),			-- 吧台代码
	@date1		datetime,     	-- 开始日期
	@date2		datetime     	-- 结束日期
as
--------------------------------------------------------------------------------------------
--	
--		按时间段查询收发存报表
--
--------------------------------------------------------------------------------------------
declare 
	@type 		char(1),                                 
   @begin 		money,			--上月期末数
   @end  		money,			--本月期末数
   @inumber    money,			--入库数
   @outstore   money,
   @tnumber1   money,			--调进
   @tnumber2   money,			--调出数
   @xnumber    money,			--销售数
   @pnumber    money,			--盘点数
	@samount		money,			--期初金额
	@famount		money,			--本期发生金额
	@camount		money,			--单价变动金额差
	@eamount		money,			--期末金额
	@date		   datetime,		-- 
	@bdate		datetime,		-- 开始查询日期
	@edate		datetime			-- 结束查询日期

select * into #sfc from pos_store_sfc where 1=2
if @date1 > @date2               --  条件错误
	begin
	select a.date,b.descript,a.condid,a.descript,a.bnumber,a.snumber,a.fnumber,a.enumber,a.pnumber,a.inumber,a.xnumber,a.tnumber1,a.tnumber2,a.bamount,a.famount,a.camount,a.eamount from #sfc a,pos_store b,pos_condst c where a.storecode=b.code and a.condid = c.condid order by b.code,c.condgp,c.sequence
	return 
	end
else if @date1 = @date2           -- 查询一期
	begin
	insert into #sfc select * from pos_store_sfc where (storecode=@storecode or @storecode='###') and month = @date1
	select a.date,b.descript,a.condid,a.descript,a.bnumber,a.snumber,a.fnumber,a.enumber,a.pnumber,a.inumber,a.xnumber,a.tnumber1,a.tnumber2,a.bamount,a.famount,a.camount,a.eamount from #sfc a,pos_store b,pos_condst c where a.storecode=b.code and a.condid = c.condid order by b.code,c.condgp,c.sequence
	return 
	end 

-- 查询跨期
select @date = max(month)  from pos_store_month
if @date < @date2
	select @edate = @date
else
	select @edate = @date2
select @date = min(month)  from pos_store_month
if @date > @date1
	select @bdate = @date
else
	select @bdate = @date1

--  期末数
insert into #sfc(month,date,storecode,condid,descript,bnumber,snumber,fnumber,enumber,inumber,xnumber,pnumber,tnumber1,tnumber2,bamount,famount,camount,eamount)
select @edate,@edate,storecode,condid,descript,bnumber,snumber,fnumber,enumber,inumber,xnumber,pnumber,tnumber1,tnumber2,bamount,famount,camount,eamount from pos_store_sfc where (storecode=@storecode or @storecode='###') and month = @edate
update #sfc set bnumber = 0,snumber = 0,fnumber = 0,inumber=0,xnumber=0,pnumber=0,tnumber1=0,tnumber2=0,bamount=0,famount=0,camount=0
--  期初数
update #sfc set bnumber = b.bnumber, bamount = b.bamount from #sfc a, pos_store_sfc b
	where a.storecode = b.storecode and a.condid = b.condid and b.month = @bdate
--  发生数
update #sfc set snumber = isnull((select sum(b.snumber) from pos_store_sfc b
	where a.storecode = b.storecode and a.condid = b.condid and b.month >= @bdate and b.month <= @edate), 0) from #sfc a 
update #sfc set fnumber = isnull((select sum(b.fnumber) from pos_store_sfc b
	where a.storecode = b.storecode and a.condid = b.condid and b.month >= @bdate and b.month <= @edate), 0) from #sfc a 
update #sfc set enumber = isnull((select sum(b.enumber) from pos_store_sfc b
	where a.storecode = b.storecode and a.condid = b.condid and b.month >= @bdate and b.month <= @edate), 0) from #sfc a 
update #sfc set inumber = isnull((select sum(b.inumber) from pos_store_sfc b
	where a.storecode = b.storecode and a.condid = b.condid and b.month >= @bdate and b.month <= @edate), 0) from #sfc a 
update #sfc set xnumber = isnull((select sum(b.xnumber) from pos_store_sfc b
	where a.storecode = b.storecode and a.condid = b.condid and b.month >= @bdate and b.month <= @edate), 0) from #sfc a 
update #sfc set pnumber = isnull((select sum(b.pnumber) from pos_store_sfc b
	where a.storecode = b.storecode and a.condid = b.condid and b.month >= @bdate and b.month <= @edate), 0) from #sfc a 
update #sfc set tnumber1 = isnull((select sum(b.tnumber1) from pos_store_sfc b
	where a.storecode = b.storecode and a.condid = b.condid and b.month >= @bdate and b.month <= @edate), 0) from #sfc a 
update #sfc set tnumber2 = isnull((select sum(b.tnumber2) from pos_store_sfc b
	where a.storecode = b.storecode and a.condid = b.condid and b.month >= @bdate and b.month <= @edate), 0) from #sfc a 
update #sfc set famount = isnull((select sum(b.famount) from pos_store_sfc b
	where a.storecode = b.storecode and a.condid = b.condid and b.month >= @bdate and b.month <= @edate), 0) from #sfc a 
update #sfc set camount = isnull((select sum(b.camount) from pos_store_sfc b
	where a.storecode = b.storecode and a.condid = b.condid and b.month >= @bdate and b.month <= @edate), 0) from #sfc a 
select a.date,b.descript,a.condid,a.descript,a.bnumber,a.snumber,a.fnumber,a.enumber,a.pnumber,a.inumber,a.xnumber,a.tnumber1,a.tnumber2,a.bamount,a.famount,a.camount,a.eamount from #sfc a,pos_store b,pos_condst c where a.storecode=b.code and a.condid = c.condid order by b.code,c.condgp,c.sequence
;
