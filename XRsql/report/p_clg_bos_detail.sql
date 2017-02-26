IF OBJECT_ID('dbo.p_clg_bos_detail') IS NOT NULL
    DROP PROCEDURE dbo.p_clg_bos_detail
;
create proc p_clg_bos_detail
	@posno	char(2),
	@pccodes char(100),
	@items   char(200),
	@sta		char(1),
	@begin	datetime,
	@end		datetime,
	@history	char(1),
	@detail	char(1),
	@sort		char(1),
	@empno	char(10),
	@shift	char(1)
as
--declare
create table #rslt(
	foliono	char(10),
	pccode	char(24),
	code		char(8),
	name		char(18),
	price		money,
	number	money,
	pfee_base	money,
	fee_disc		money,
	fee_serve	money,
	fee_tax		money,
	fee			money,
	sfolio	char(10),
	aname			char(24),
	roomno		char(5)
)

select @pccodes = rtrim(@pccodes), @items = rtrim(@items)

insert into #rslt select b.foliono,a.name,b.code,b.name,b.price,b.number,b.pfee_base,b.fee_disc,b.fee_serve,b.fee_tax,b.fee,a.sfoliono,'',''
	from bos_folio a,bos_dish b where a.foliono=b.foliono and a.pccode=b.pccode and b.sta='I'
	 and (@pccodes is null or charindex(','+rtrim(a.pccode)+',',','+rtrim(@pccodes)+',')>0)
	 and (@items is null or charindex(','+rtrim(b.pccode)+rtrim(b.code)+',',','+rtrim(@items)+',')>0) and (@sta='A' or a.sta=@sta)
	 and datediff(dd,  a.bdate1,  @begin)<=0 and datediff(dd,  a.bdate1,  @end)>=0
	 and (a.empno1=@empno or @empno='') and (a.shift1=@shift or @shift='')
	 and (@posno='##' or a.posno=@posno)
update #rslt set aname=b.name, roomno=b.room from bos_folio a, bos_account b 
	where #rslt.foliono=a.foliono and a.setnumb=b.setnumb 

if @history='T'
begin 
	insert into #rslt select b.foliono,a.name,b.code,b.name,b.price,b.number,b.pfee_base,b.fee_disc,b.fee_serve,b.fee_tax,b.fee,a.sfoliono,'',''
		from bos_hfolio a,bos_hdish b where a.foliono=b.foliono and a.pccode=b.pccode and b.sta='I'
		 and (@pccodes is null or charindex(','+rtrim(a.pccode)+',',','+rtrim(@pccodes)+',')>0)
		 and (@items is null or charindex(','+rtrim(b.pccode)+rtrim(b.code)+',',','+rtrim(@items)+',')>0) and (@sta='A' or a.sta=@sta)
		 and datediff(dd,  a.bdate1,  @begin)<=0 and datediff(dd,  a.bdate1,  @end)>=0
		 and (a.empno1=@empno or @empno='') and (a.shift1=@shift or @shift='')
		 and (@posno='##' or a.posno=@posno)
update #rslt set aname=b.name, roomno=b.room from bos_hfolio a, bos_haccount b 
	where #rslt.foliono=a.foliono and a.setnumb=b.setnumb 
end 
if @detail='T'
	begin
		if @sort='1'
			select * from #rslt order by foliono,pccode,code
		else if @sort='2'
			select * from #rslt order by pccode,code,foliono
	end
else
	select '',pccode,code,name,sum(fee)/sum(number),sum(number),sum(pfee_base),sum(fee_disc),sum(fee_serve),sum(fee_tax),sum(fee),'-','',''
	 from #rslt group by pccode,code,name having sum(number)<>0 order by pccode,code,name
;