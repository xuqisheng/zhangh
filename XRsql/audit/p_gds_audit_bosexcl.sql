if exists (select * from sysobjects where name = 'p_gds_audit_bosexcl' and type ='P')
   drop proc p_gds_audit_bosexcl;
create proc p_gds_audit_bosexcl
   @ret     int  out,
   @msg     varchar(70) out
as
-- --------------------------------------------------------------------------
--		夜审处理
-- --------------------------------------------------------------------------

select @ret = 0,@msg = ''
declare @bdate1 datetime
select  @bdate1 = bdate1 from sysdata  -- 夜审后的营业日期

begin tran 
-- 'BUS' -- 帐务指针(BOS)
update sysdata set fbase = datepart(yy,@bdate1) % 100 * 100000000.0 + datepart(mm,@bdate1) * 1000000.0 + datepart(dd,@bdate1) * 10000.0 + 1  
-- 'BKC' -- 库存指针(BOS)
update sysdata set ebase3 = datepart(yy,@bdate1) % 100 * 100000000.0 + datepart(mm,@bdate1) * 1000000.0 + datepart(dd,@bdate1) * 10000.0 + 1  
update sysdata set fsetnumb = fbase
commit tran

begin  tran
delete bos_account where setnumb not in (select setnumb from bos_folio where rtrim(setnumb) is not null)
insert bos_hdish select a.* from bos_dish a, bos_folio b where a.foliono=b.foliono and ((b.setnumb is not null and b.setnumb <> space(10)) or charindex(b.sta,'cCX')>0)
delete bos_dish from bos_folio b where bos_dish.foliono=b.foliono and ((b.setnumb is not null and b.setnumb <> space(10)) or charindex(b.sta,'cCX')>0)
insert bos_hfolio select * from bos_folio where (setnumb is not null and setnumb <> space(10)) or charindex(sta,'cCX') > 0
insert bos_haccount select * from bos_account where setnumb is not null and setnumb <> space(10)
delete bos_folio where (setnumb is not null and setnumb <> space(10)) or charindex(sta,'cCX') > 0
delete bos_account where setnumb is not null and setnumb <> space(10)
commit tran

-- -----------------------------
-- BOS 库存的月结 -- 月末结转
-- -----------------------------
begin tran 
if exists(select 1 from bos_kcdate where begin_=@bdate1)	-- 是否为第一天
begin
	declare @id	char(6)
	select @id = id from bos_kcdate where begin_=@bdate1  -- 新的帐务区间标志

	-- 去掉无效记录
	delete bos_store where number0=0 and number1=0 and number2=0 and number3=0
								and number4=0 and number5=0 and number6=0 and number7=0 
								and number8=0 and number9=0
								and amount0=0 and amount1=0 and amount2=0 and amount3=0
								and amount4=0 and amount5=0 and amount6=0 and amount7=0 
								and amount8=0 and amount9=0
								and sale0=0 and sale1=0 and sale2=0 and sale3=0
								and sale4=0 and sale5=0 and sale6=0 and sale7=0 
								and sale8=0 and sale9=0
								and profit0=0 and profit1=0 and profit2=0 and profit3=0
								and profit4=0 and profit5=0 and profit6=0 and profit7=0 
								and profit8=0 and profit9=0

	-- bos_store 
	insert bos_hstore select * from bos_store
	update bos_store set id=@id,number0=number9,amount0=amount9,sale0=sale9,profit0=profit9,
			number1=0,amount1=0,sale1=0,profit1=0,
			number2=0,amount2=0,sale2=0,profit2=0,
			number3=0,amount3=0,sale3=0,profit3=0,
			number4=0,amount4=0,sale4=0,profit4=0,
			number5=0,amount5=0,sale5=0,profit5=0,disc=0,
			number6=0,amount6=0,sale6=0,profit6=0,
			number7=0,amount7=0,sale7=0,profit7=0,
			number8=0,amount8=0,sale8=0,profit8=0

	-- bos_detail；注意产生‘续’
	insert bos_hdetail select * from bos_detail
	delete bos_detail
	insert bos_detail select pccode,site,code,@id,1,'续','期初余额','','',0,'',@bdate1,@bdate1,@bdate1,'',
			number9,amount9,sale9,0,profit9,number9,amount9,sale9,profit9,price0,price1
		from bos_store 

end
commit tran 

--
--begin tran 
--declare @isfstday char(1), @isyfstday char(1), @curdate datetime
--exec p_hry_audit_fstday @bdate1, @isfstday out, @isyfstday out
--if (@isfstday ='T' or @isyfstday ='T') 
--begin
--	select @curdate=dateadd(dd,-1,@bdate1)  -- 结转日期
--	if not exists(select 1 from bos_hstore where date=@curdate)		
--	begin
--		update bos_store set date=@curdate
--		insert bos_hstore select * from bos_store
--		update bos_store set date=@bdate1,number0=number9,amount0=amount9,
--			number1=0,amount1=0,number2=0,amount2=0,number3=0,amount3=0,
--			number4=0,amount4=0,number5=0,amount5=0,number6=0,amount6=0,
--			number7=0,amount7=0,number8=0,amount8=0
--	end
--end
--commit tran 

return @ret
;
