
if exists(select 1 from sysobjects where type='P' and name='p_cyj_bar_month_sfc')
  drop procedure p_cyj_bar_month_sfc;

create proc  p_cyj_bar_month_sfc
	@month		datetime,     	-- yyyy/mm/dd
   @condid   	int,  			-- 物品代码
   @name       char(30),
   @storecode 	char(3),			-- 吧台代码
   @date       datetime
as
--------------------------------------------------------------------------------------------
--	
--		月结： 收发存报表，按吧台中每个物品统计
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
	@lastmonth	datetime			-- 上月月份

select @lastmonth = max(month)  from pos_store_month where month < @month

select @inumber = isnull(sum(number), 0) from pos_store_mst a, pos_store_dtl b
	 where b.storecode=@storecode and b.condid=@condid and  b.no = a.no and a.type='0'
 
select @tnumber1 = isnull(sum(number), 0) from pos_store_mst a, pos_store_dtl b
	 where b.storecode=@storecode and b.condid=@condid and  b.no = a.no and a.type='1'

select @tnumber2 = isnull(sum(number), 0) from pos_store_mst a, pos_store_dtl b
	 where b.storecode1=@storecode and b.condid=@condid and b.no = a.no and a.type='1'

select @xnumber = isnull(sum(number), 0) from pos_sale
	 where storecode=@storecode and condid=@condid 

select @pnumber = isnull(sum(number), 0) from pos_store_mst a, pos_store_dtl b
	 where b.storecode1=@storecode and b.condid=@condid and  b.no = a.no and a.type='2'

if exists (select 1 from pos_store_sfc where storecode=@storecode and condid=@condid and month = @lastmonth)
	select @begin = enumber,@samount = eamount from pos_store_sfc where storecode=@storecode and condid=@condid and month = @lastmonth
else
	select @begin=0, @samount = 0

select @end=number from pos_store_store where storecode=@storecode and condid=@condid
if @end is null
	select @end = 0
select @eamount = @end * price from pos_condst where condid = @condid
select @famount = (@inumber + @tnumber1 - @tnumber2 - @xnumber + @pnumber) * price from pos_condst where condid = @condid
select @camount = @eamount - @famount - @samount

if not exists (select 1 from pos_store_sfc where storecode=@storecode and condid=@condid and date = @date)
	insert into pos_store_sfc(month, date, storecode, condid,descript, bnumber, snumber, fnumber, enumber,inumber,xnumber,pnumber,tnumber1,tnumber2,bamount,famount,camount,eamount)
		 values(@month,@date, @storecode, @condid, @name, @begin, @inumber+@tnumber1, @tnumber2+@xnumber, @end,@inumber,@xnumber,@pnumber,@tnumber1,@tnumber2, isnull(@samount,0),isnull(@famount,0),isnull(@camount,0),isnull(@eamount,0))
else
	update pos_store_sfc set date=@date,bnumber=@begin,snumber=@inumber+@tnumber1,fnumber=@tnumber2+@xnumber,enumber=@end,xnumber=@xnumber,pnumber=@pnumber,tnumber1=@tnumber1,tnumber2=@tnumber2,bamount=isnull(@samount,0),famount=isnull(@famount,0),camount=isnull(@camount,0),eamount=isnull(@eamount,0) where storecode=@storecode and condid=@condid and date = @date 
;
