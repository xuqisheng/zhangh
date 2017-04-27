drop proc p_wms_jiedai_check_x;
create proc p_wms_jiedai_check_x
as
create table #gout
(
	code		char(10) null,
	descript	char(60) null,
	amount	money default 0 null
)
declare @balance		money
select @balance = a.day99-b.sumcre from jierep a,dairep b where a.class ='999' and b.class='09000' 
if @balance =0 
begin
	select '0000','���ƽ',0
	return 
end
insert #gout select '0000','������',@balance

insert #gout select '1000',pccode+descript+'��δ��Ӧ�ױ���',0 from pccode where jierep not in (select class from jierep) and pccode <'9' 
insert #gout select '1001','gltemp�н����ڲ��ĸ�����'+pccode,abs(sum(charge-credit)) from gltemp 
	group by pccode having abs(sum(charge-credit)) = @balance
insert #gout select '1002',code,0 from mktcode where jierep not in (select class from jierep)


insert #gout
select '1003','�����������sysoptionδ����:'+b.pccode+b.descript,0 from sysoption a,pccode b where a.catalog = 'audit' and a.item = 'en_str' and charindex(b.deptno2,a.value) =0 
and b.deptno8 <> '' and b.pccode >'9' and tail <>'07'

insert #gout 
select '1004','p_gl_audit_jiedai_jie �����з���Ĭ��class����',0 from gltemp a,pccode b where a.pccode=b.pccode and b.jierep='010' and a.tag not in (select code from mktcode)

insert #gout
select '1005',a.billno+'ǰ̨���˿���ۿ�����������һ����ˣ����ܻ�����ױ���ƽ',0 from outtemp a,pccode b where a.pccode =b.pccode and b.pccode >'9' and b.deptno8 <>'' 
group by a.billno having count(distinct a.pccode) > 1

insert #gout
select '1006',code+descript+'-->'+accnt+'���۶�Ӧ���˺�ϵͳ�в�����',0 from package where accnt not in (select accnt from master) and accnt <>''

insert #gout 
	select '1007','bos������3λС��'+code+descript,fee_ttl from bosjie where empno='{{{' and shift='9' and fee_ttl<>round(fee_ttl,2) and code <>'999'

insert #gout select 'pos1001','pos_pccode����chgcod��Ӧpccode������'+pccode,0 from pos_pccode where chgcod not in (select pccode from pccode )

insert #gout
select 'pos1002','�������뱨�������ƽ'+a.pccode,a.feed-b.creditd  from deptjie a,deptdai b where a.shift='9' and a.empno ='{{{' and a.code ='6'
and b.shift='9' and b.empno ='{{{' and b.paycode ='C99' and a.pccode=b.pccode  and a.feed<>b.creditd

insert #gout
select  'pos1003',a.pccode+':'+a.code+'->'+a.jierep,c.feed from pos_itemdef a,pos_pccode b,deptjie c 
	where a.pccode=b.pccode and b.pccode=c.pccode and a.code = c.code and c.feed <>0 and a.jierep not in (select class from jierep) 

insert #gout
select 'pos1004',menu+'���������¼������������',0 from pos_tpay where menu in (
select menu from pos_tmenu where pcrec <>'') and menu not in (select pcrec from pos_tmenu where pcrec <>'')

insert #gout
select 'pos1005',a.paycode+'����Ѻ�������ÿ�������',a.creditd from deptdai a,pccode b,bankcard c 
	where a.paycode like 'B%' and 'C'+substring(a.paycode,2,2)=b.deptno1 and b.pccode=c.pccode and a.shift='9' and a.empno ='{{{'  

if not exists(select 1 from pos_tmenu )
begin
	insert #gout
	select 'pos1006','pos_tmenu����δ����',0 
//	insert pos_tmenu select a.* from pos_hmenu a,accthead b where datediff(dd,a.bdate,b.bdate)=0
//	insert pos_tdish select a.* from pos_hdish a,pos_tmenu b where a.menu=b.menu 
//	insert pos_tpay select a.* from pos_hpay a,pos_tmenu b where a.menu=b.menu 

end

insert #gout
	select 'pos1007','��δ������',sum(feed) from deptjie where shift='9' and empno ='{{{' and code='099' group by code having sum(feed)<>0
if exists(select 1 from pos_detail_jie where tocode='099')
	select * from pos_detail_jie where tocode ='099'

insert #gout 
select 'pos1008','����תӦ����ǰ̨�������ݲ���',(select sum(creditd) from deptdai where shift='9' and empno ='{{{' and paycode in ('C88','C86')) -
(select sum(charge) from gltemp where modu_id ='04')

insert #gout
select  'pos1010',a.menu+'�͵���ͷδ����',sum(a.amount)+sum(a.srv)-sum(a.dsc)-b.amount from pos_tdish a,pos_tmenu b 
	where a.menu=b.menu and a.code not in ('X','Y','Z') group by a.menu,b.menu having b.amount<>sum(a.amount)+sum(a.srv)-sum(a.dsc)

--begin pos1004
//select * from auditprg where charindex('p_gl_audit_jiedai',callform)>0 
//delete from deptjie
//delete from deptdai 
//update sysoption set value = rtrim(value)+'04#' where catalog = 'audit' and item = 'modu_id' 
//exec p_gl_audit_jiedai_nar 0,''
//if exists(select 1 from jierep a,dairep b where a.class ='999' and b.class='09000' and a.day99=b.sumcre)
//	insert #gout select 'pos1004','��������ױ���ƽ',0 
//insert deptjie select a.* from ydeptjie a,sysdata b where datediff(dd,a.date,b.bdate)=1
//insert deptdai  select a.* from ydeptdai a,sysdata b where datediff(dd,a.date,b.bdate)=1
//
//update sysoption set value = substring(value,1,datalength(value)-3) where catalog = 'audit' and item = 'modu_id'
//exec p_gl_audit_jiedai_nar 0,''
--end pos1004

select * from #gout order by code
;
exec p_wms_jiedai_check_x;