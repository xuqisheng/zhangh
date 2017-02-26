
if exists(select * from sysobjects where name = "p_gds_memlist_for_pmodi")
   drop proc p_gds_memlist_for_pmodi;

create proc p_gds_memlist_for_pmodi
	@pc_id		char(4),
	@class		char(1),
	@mode			char(2) ='01'		-- 是否显示取消、结账客人；
as
--------------------------------------------------------------------------
--	团体批量处理 - 预订单提取 
--------------------------------------------------------------------------
create table #memlist (
	accnt				char(10)			not null,
	sta				char(1)			not null,
	type				char(5)			not null,
	roomno			char(5)			null,
	haccnt			char(7)			not null,
	name				varchar(50)		null,
	arr				datetime			not null,
	dep				datetime			not null,
	ratecode			char(10) 			null,
	setrate			money default 0 not null,
	locksta			char(1)			null,
	phonesta			char(1)			null,
   intsta			char(1)			null,   -- added by pyn
	vodsta			char(1)			null,
	srqs				varchar(30)		null,
	ratelock			char(1)			null,
	barlock			char(1)			null,
	package			varchar(50)		null,
	ref				varchar(255)	null,
	comsg				varchar(255)	null,
	rmnum				int  default 0 not null,
	grpfee			varchar(255)		null,
	gstno				int	null,
	src			char(3)		null,
	market		char(3)		null,
	restype		char(3)		null,
	channel		char(3)		null,
	eccocode		char(3)		null,
	arrdate		datetime		null,
	arrinfo		varchar(30)	null,
	arrcar		varchar(10)	null,
	arrrate		money			null,
	depdate		datetime		null,
	depinfo		varchar(30)	null,
	depcar		varchar(10)	null,
	deprate		money			null,
	up_type		char(5)		null,
	up_reason	char(3)		null
)

declare	@count	int,
			@accnt	char(10)  

if @class='G' 
begin
	select @count = count(1) from selected_account where pc_id=@pc_id and type='m' and mdi_id=0
	if @count=1 
	begin
		select @accnt=accnt from selected_account where pc_id=@pc_id and type='m' and mdi_id=0
		insert #memlist select a.accnt,a.sta,a.type,a.roomno,a.haccnt,b.name,a.arr,a.dep,a.ratecode,a.setrate,
				substring(a.extra,10,1),substring(a.extra,6,1),substring(a.extra,8,1),substring(a.extra,7,1),a.srqs,
				substring(a.extra,5,1),substring(a.extra,12,1),a.packages,a.ref,a.comsg,a.rmnum,
				isnull((select min(c.pccodes) from subaccnt c where c.accnt=a.accnt and c.to_accnt=a.groupno and c.type='5' and c.tag<'2'), ''),
				a.gstno,a.src,a.market,a.restype,a.channel,'',
				a.arrdate,a.arrinfo,a.arrcar,a.arrrate,a.depdate,a.depinfo,a.depcar,a.deprate,a.up_type,a.up_reason
			from master a, guest b 
				where a.groupno=@accnt and a.haccnt=b.no and a.class like 'F%' 
	end
end
else
begin
	select @count = count(1) from selected_account where pc_id=@pc_id and type='m' and mdi_id=0
	if @count=1 
	begin
		declare	@saccnt  char(10),
					@pcrec	char(10),
					@resno	char(10),
					@grpno	char(10)   

		select @accnt=accnt from selected_account where pc_id=@pc_id and type='m' and mdi_id=0
		select @saccnt=isnull(rtrim(saccnt),'-'), @resno=isnull(rtrim(resno),'-'), @pcrec=isnull(rtrim(pcrec),'-') , @grpno=isnull(rtrim(groupno),'-') 
			from master where accnt=@accnt 
		insert #memlist select a.accnt,a.sta,a.type,a.roomno,a.haccnt,c.name,a.arr,a.dep,a.ratecode,a.setrate,substring(extra,10,1),
				substring(extra,6,1),substring(a.extra,8,1),substring(extra,7,1),a.srqs,
				substring(a.extra,5,1),substring(a.extra,12,1),a.packages,a.ref,a.comsg,a.rmnum,'',
				a.gstno,a.src,a.market,a.restype,a.channel,'',
				a.arrdate,a.arrinfo,a.arrcar,a.arrrate,a.depdate,a.depinfo,a.depcar,a.deprate,a.up_type,a.up_reason 
			from master a, guest c 
				where (a.accnt=@accnt or a.resno=@resno or a.saccnt=@saccnt or a.pcrec=@pcrec or a.groupno=@grpno) 
					and a.haccnt=c.no and a.class like 'F%' 
	end
	else
		insert #memlist select a.accnt,a.sta,a.type,a.roomno,a.haccnt,c.name,a.arr,a.dep,a.ratecode,a.setrate,substring(extra,10,1),
				substring(extra,6,1),substring(a.extra,8,1),substring(extra,7,1),a.srqs,
				substring(a.extra,5,1),substring(a.extra,12,1),a.packages,a.ref,a.comsg,a.rmnum,'',
				a.gstno,a.src,a.market,a.restype,a.channel,'',
				a.arrdate,a.arrinfo,a.arrcar,a.arrrate,a.depdate,a.depinfo,a.depcar,a.deprate,a.up_type,a.up_reason 
			from master a, selected_account b, guest c 
				where b.pc_id=@pc_id and b.type='m' and b.mdi_id=0
					and a.accnt=b.accnt and a.haccnt=c.no 
					and a.class like 'F%' 
end

if substring(@mode,1,1)='0' 
	delete #memlist where sta in ('X', 'N')
if substring(@mode,2,1)='0' 
	delete #memlist where sta in ('O', 'D')

update #memlist set eccocode = b.eccocode 
	from rmsta a, rmstamap b 
		where #memlist.roomno=a.roomno and a.ocsta+a.sta=b.code 

select accnt,sta,type,roomno,haccnt,name,arr,dep,ratecode,setrate,locksta,phonesta,intsta,vodsta,srqs,
	ratelock,barlock,package,ref,comsg,rmnum,grpfee,gstno,src,market,restype,channel,eccocode,
	arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,up_type,up_reason 
from #memlist order by sta, roomno

return 0
;

