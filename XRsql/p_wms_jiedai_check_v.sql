drop proc p_wms_jiedai_check_v;
create proc p_wms_jiedai_check_v
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
	select '0000','借贷平',0
	return 
end
insert #gout select '0000','借贷差额',@balance

insert #gout select '1000',pccode+descript+'：未对应底表行',0 from chgcod where jierep not in (select class from jierep) and pccode <'9' 
insert #gout select '1001','gltemp中金额等于差额的付款码'+pccode,abs(sum(charge-credit)) from gltemp 
	group by pccode having abs(sum(charge-credit)) = @balance
insert #gout select '1002',code,0 from mktcode where jierep not in (select class from jierep)


insert #gout
select '1003','款待付款码在sysoption未定义:'+b.pccode+b.descript,0 from sysoption a,pccode b where a.catalog = 'audit' and a.item = 'en_str' and charindex(b.deptno2,a.value) =0 
and b.deptno8 <> '' and b.pccode >'9' and tail <>'07'

insert #gout 
select '1004','p_gl_audit_jiedai_jie 过程中房费默认class错误',0 from gltemp a,pccode b where a.pccode=b.pccode and b.jierep='010' and a.tag not in (select code from mktcode)

insert #gout
select '1005',a.billno+'前台结账款待折扣与其他付款一起结账，可能会引起底表不平',0 from outtemp a,pccode b where a.pccode =b.pccode and b.pccode >'9' and b.deptno8 <>'' 
group by a.billno having count(distinct a.pccode) > 1

insert #gout
select '1006',code+descript+'-->'+accnt+'包价对应的账号系统中不存在',0 from package where accnt not in (select accnt from master) and accnt <>''

insert #gout select 'pos1001','pos_pccode表的chgcod对应pccode表错误'+pccode,0 from pos_pccode where chgcod not in (select pccode from pccode )

insert #gout
select 'pos1002','餐饮收入报表借贷不平'+a.pccode,a.feed-b.creditd  from deptjie a,deptdai b where a.shift='9' and a.empno ='{{{' and a.code ='6'
and b.shift='9' and b.empno ='{{{' and b.paycode ='C99' and a.pccode=b.pccode  and a.feed<>b.creditd

insert #gout
select  'pos1003',a.pccode+':'+a.code+'->'+a.jierep,c.feed from pos_itemdef a,pos_pccode b,deptjie c 
	where a.pccode=b.pccode and b.pccode=c.pccode and a.code = c.code and c.feed <>0 and a.jierep not in (select class from jierep) 

insert #gout
select 'pos1004',menu+'联单付款记录不在主联单号',0 from pos_tpay where menu in (
select menu from pos_tmenu where pcrec <>'') and menu not in (select pcrec from pos_tmenu where pcrec <>'')

insert #gout
select 'pos1005',a.paycode+'餐饮押金用信用卡有问题',a.creditd from deptdai a,pccode b,bankcard c 
	where a.paycode like 'B%' and 'C'+substring(a.paycode,2,2)=b.deptno1 and b.pccode=c.pccode and a.shift='9' and a.empno ='{{{'  

if not exists(select 1 from pos_tmenu )
begin
	insert #gout
	select 'pos1006','pos_tmenu数据未生成',0 
//	insert pos_tmenu select a.* from pos_hmenu a,accthead b where datediff(dd,a.bdate,b.bdate)=0
//	insert pos_tdish select a.* from pos_hdish a,pos_tmenu b where a.menu=b.menu 
//	insert pos_tpay select a.* from pos_hpay a,pos_tmenu b where a.menu=b.menu 

end

insert #gout
	select 'pos1007','有未定义项',sum(feed) from deptjie where shift='9' and empno ='{{{' and code='099' group by code having sum(feed)<>0
if exists(select 1 from pos_detail_jie where tocode='099')
	select * from pos_detail_jie where tocode ='099'
--begin pos1004
//select * from auditprg where charindex('p_gl_audit_jiedai',callform)>0 
//delete from deptjie
//delete from deptdai 
//update sysoption set value = rtrim(value)+'04#' where catalog = 'audit' and item = 'modu_id' 
//exec p_gl_audit_jiedai_nar 0,''
//if exists(select 1 from jierep a,dairep b where a.class ='999' and b.class='09000' and a.day99=b.sumcre)
//	insert #gout select 'pos1004','餐饮引起底表不平',0 
//insert deptjie select a.* from ydeptjie a,sysdata b where datediff(dd,a.date,b.bdate)=1
//insert deptdai  select a.* from ydeptdai a,sysdata b where datediff(dd,a.date,b.bdate)=1
//
//update sysoption set value = substring(value,1,datalength(value)-3) where catalog = 'audit' and item = 'modu_id'
//exec p_gl_audit_jiedai_nar 0,''
--end pos1004

select * from #gout order by code
;
exec p_wms_jiedai_check_v;