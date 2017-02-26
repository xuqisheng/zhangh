if exists(select 1 from sysobjects where type='P' and name='p_cyj_bar_month_first_data')
  drop proc p_cyj_bar_month_first_data;

create proc  p_cyj_bar_month_first_data
	@month		datetime,
   @date       datetime,
   @empno      char(10)
as
----------------------------------------------------------------------------------------
--
--		吧台月结： 生成下月转入明细数据 pos_store_mst, pos_store_dtl
--
----------------------------------------------------------------------------------------
declare		
	@no			char(10),
	@storecode	char(3),
	@descript	char(30),
	@descript1	char(60),
	@inumber		int,
	@stdid		int

begin tran
save  tran t_bar_fir
declare	c_dtl cursor for select condid from pos_store_store where storecode = @storecode order by condid

declare	c_cur cursor for select distinct storecode from pos_store_store order by storecode 
open c_cur
fetch c_cur into @storecode
while @@sqlstatus = 0 
	begin

	exec p_cyj_create_bar_no	@no output, 'S'
	-- pos_store_mst.type = '3' 上期转入
	insert into pos_store_mst (no,sno,storecode,storecode1,type,date,empno,logdate,remark,sta)
	select @no,'',@storecode,@storecode,'3',@date,@empno,getdate(),'上期转入('+convert(char(8), @month, 11)+')','0'
	select @inumber = 1
	open c_dtl
	fetch c_dtl into @stdid
	while @@sqlstatus = 0 
		begin
		insert into pos_store_dtl (no,inumber,storecode,storecode1,plu_id,condid,descript,descript1,number,empno,logdate,remark)
		select @no, @inumber, storecode, storecode, 0, condid, descript, descript1, number, @empno, getdate(), '上期转入('+convert(char(8), @month, 11)+')' 
			from pos_store_store where storecode = @storecode and condid = @stdid
		select @inumber = @inumber + 1
		fetch c_dtl into @stdid
		end
		close c_dtl
	fetch c_cur into @storecode
	end 
	close c_cur
	deallocate cursor c_cur
	deallocate cursor c_dtl
commit t_bar_fir
;


