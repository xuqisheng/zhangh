if exists(select 1 from sysobjects where name ='p_cyj_pos_audit_check' and type ='P')
	drop  proc p_cyj_pos_audit_check;
create proc p_cyj_pos_audit_check
as
/*--------------------------------------------------------------------------------------------*/
//
// �������ݼ�飬�ᵼ�µױ�ƽ���������
//
/*--------------------------------------------------------------------------------------------*/

declare
	@count1			int,
	@bdate			datetime

create	table	 #list(
	sort		char(10),
	des		char(60),
	menu		char(10),
	msg		char(200)
)

select @bdate = bdate from sysdata
select @count1 = 0

-- ������Ӧǰ̨���������һ
insert #list
	select '100', '������Ӧǰ̨���������:' +' pos_pccode.chgcod','','������:'+pccode+'  ����:'+descript
	from pos_pccode where chgcod not in(select pccode from pccode)

-- ������Ӧǰ̨����������
insert #list
	select '110', '��������Ӧǰ̨���������:'+' pos_int_pccode.pccode','','������:'+b.pos_pccode+'  ����:'+b.name1 +' ǰ̨������:'+b.pccode+'���:'+b.shift
	from pos_pccode a, pos_int_pccode b where a.pccode=b.pos_pccode and b.class='2' and b.pccode not in(select pccode from pccode)

-- itemdefû�ж��屨����Ŀ
select @count1 = count(1) from pos_itemdef a,pos_pccode b where a.pccode=b.pccode  
	and a.code not in( select c.code from  pos_namedef c where b.deptno=c.deptno and a.code=c.code)
if @count1 > 0 
	insert #list
	select '120','pos_itemdef��û�ж���ı������:'+'pos_itemdef','','���ź�:'+b.deptno+' ����:'+a.pccode+'����:'+a.code from pos_itemdef a,pos_pccode b where a.pccode=b.pccode  
	and a.code not in( select c.code from  pos_namedef c where b.deptno=c.deptno and a.code=c.code)

-- ����û�ж��屨��������Ŀ
select @count1 = count(1) from pos_detail_jie where date = @bdate and tocode = '099'
if @count1 > 0 
	insert #list
	select '130', '�в���û�ж��屨��������Ŀ:',menu,'����:'+menu+' �˺�:'+code+'  ����:'+name1 
	from pos_detail_jie where date = @bdate and tocode = '099'

--����û�ж���ױ���Ŀ
select @count1 = count(1) from pos_itemdef a,pos_pccode b where a.pccode=b.pccode and a.jierep not in(select class from jierep)
if @count1 > 0 
	insert #list
	select distinct '140','����û�ж���ױ���Ŀ:'+'pos_itemdef.jierep','',' ����:'+b.pccode+'  �ױ���:'+a.jierep
	from pos_itemdef a,pos_pccode b where a.pccode=b.pccode and a.jierep not in(select class from jierep)

-- תǰ̨���������ݺ�ǰ̨���ݲ�һ��
select @count1 = count(1) from pos_menu a where a.sta='3' 
and isnull((select sum(b.charge) from ar_account b where b.ref1=a.menu and b.modu_id='04'),0)
+isnull((select sum(e.charge) from account e where e.ref1=a.menu and e.modu_id='04'),0)
<>isnull((select sum(c.amount) from pos_pay c, pccode d where c.menu=a.menu and c.crradjt='NR' and c.sta='3' and c.paycode=d.pccode and (d.deptno2='TOR' or d.deptno2='TOA')),0)
if @count1 > 0 
	insert #list
	select '200','תǰ̨�������ݺ�ǰ̨���ݲ�һ��',a.menu,a.menu+"  ����:"+f.descript+ "  ����:"+a.tableno+"  ���:"+convert(varchar,a.amount) from pos_menu a,pos_pccode f where  a.sta='3' and a.pccode=f.pccode
	and isnull((select sum(b.charge) from ar_account b where b.ref1=a.menu and b.modu_id='04'),0)
	+isnull((select sum(e.charge) from account e where e.ref1=a.menu and e.modu_id='04'),0)
	<>isnull((select sum(c.amount) from pos_pay c, pccode d where c.menu=a.menu and c.crradjt='NR' and c.sta='3' and c.paycode=d.pccode and (d.deptno2='TOR' or d.deptno2='TOA')),0)

-- �͵����Ͳ˺ϼƲ�һ��
select @count1 = count(1) from pos_menu a where a.sta='3'
and a.amount<>isnull((select sum(b.amount - b.dsc + b.srv + b.tax) from pos_dish b where a.menu=b.menu and charindex(rtrim(ltrim(b.code)),'YZ')=0),0)
if @count1 > 0 
	insert #list
	select '210','menu.amount��dish�ϼƲ�һ��',a.menu,a.menu+"  ����:"+f.descript+ "  ����:"+a.tableno+"  ���:"+convert(varchar,a.amount) from pos_menu a,pos_pccode f where  a.sta='3' and a.pccode=f.pccode
	and a.amount<>isnull((select sum(b.amount - b.dsc + b.srv + b.tax) from pos_dish b where a.menu=b.menu and charindex(rtrim(ltrim(b.code)),'YZ')=0),0)

-- �͵�����ѺͲ˷���ѺϼƲ�һ��
select @count1 = count(1) from pos_menu a where a.sta='3'
and isnull((select b.amount from pos_dish b where a.menu=b.menu and rtrim(ltrim(b.code)) ='Z'),0)
  <>isnull((select sum(c.srv) from pos_dish c where a.menu=c.menu and charindex(rtrim(ltrim(c.code)),'YZ')=0),0)
if @count1 > 0 
	insert #list
	select '220','dish.Z��dish����ѺϼƲ�һ��',a.menu,a.menu+"  ����:"+f.descript+ "  ����:"+a.tableno+"  ���:"+convert(varchar,a.amount) from pos_menu a,pos_pccode f where  a.sta='3' and a.pccode=f.pccode
	and isnull((select b.amount from pos_dish b where a.menu=b.menu and rtrim(ltrim(b.code)) ='Z'),0)
  	<>isnull((select sum(c.srv) from pos_dish c where a.menu=c.menu and charindex(rtrim(ltrim(c.code)),'YZ')=0),0)

-- �����Ѿ������������ú����ݱ�־
update sysoption set value ='T' where catalog='pos' and item='audit_check'

select * from #list
;
