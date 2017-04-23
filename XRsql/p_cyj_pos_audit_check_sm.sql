drop  proc p_cyj_pos_audit_check_sm;
create proc p_cyj_pos_audit_check_sm
	@date		datetime
as
----------------------------------------------------------------------------------------------*/
--
-- �������ݼ�飬�ᵼ�µױ�ƽ���������
-- ���÷�Χ smart �����汾  cyj 20100331
----------------------------------------------------------------------------------------------*/

declare
	@count1			int,
	@bdate			datetime

create	table	 #list(
	sort		char(10),
	des		char(60),
	menu		char(10),
	msg		char(200)
)


select @bdate = bdate1 from sysdata
select @count1 = 0

-- ������Ӧǰ̨���������һ
insert #list
	select '100', '������Ӧǰ̨���������' +' pos_pccode.chgcod','','������:'+pccode+'  ����:'+descript
	from pos_pccode where chgcod not in(select pccode from pccode)

-- ������Ӧǰ̨����������
insert #list
	select '100', '��������Ӧǰ̨���������'+' pos_int_pccode.pccode','','������:'+b.pos_pccode+'  ����:'+rtrim(b.name1) +' ǰ̨������:'+b.pccode+'���:'+b.shift
	from pos_pccode a, pos_int_pccode b where a.pccode=b.pos_pccode and b.class='2' and b.pccode not in(select pccode from pccode)

-- itemdefû�ж��屨����Ŀ
select @count1 = count(1) from pos_itemdef a,pos_pccode b where a.pccode=b.pccode  
	and a.code not in( select c.code from  pos_namedef c where b.deptno=c.deptno and a.code=c.code)
if @count1 > 0 
	insert #list
	select '110','itemdefû�ж���ı������'+'pos_itemdef','','���ź�:'+b.deptno+' ����:'+a.pccode+'����:'+a.code from pos_itemdef a,pos_pccode b where a.pccode=b.pccode  
	and a.code not in( select c.code from  pos_namedef c where b.deptno=c.deptno and a.code=c.code)

-- ����û�ж��屨��������Ŀ
select @count1 = count(1) from pos_detail_jie where date = @bdate and tocode = '099'
if @count1 > 0 
	insert #list
	select '120', '�в���û�ж��屨��������Ŀ,����׺�itemdef',menu,'����:'+menu+' �˺�:'+code+'  ����:'+name1 
	from pos_detail_jie where date = @bdate and tocode = '099'

-- ����û�ж��屨��������Ŀ
select @count1 = count(1) from pos_sort where rtrim(ltrim(tocode)) is null and halt <>'T'
if @count1 > 0 
	insert #list
	select '125', '�в���û�ж��屨��������Ŀ','','���:'+sort+'  ����:'+name1 
	from pos_sort where  rtrim(ltrim(tocode)) is null and halt <>'T'

--����û�ж���ױ���Ŀ
select @count1 = count(1) from pos_itemdef a,pos_pccode b where a.pccode=b.pccode and a.jierep not in(select class from jierep)
if @count1 > 0 
	insert #list
	select distinct '130','����û�ж���ױ���Ŀ'+'itemdef.jierep','',' ����:'+b.pccode+'�ױ���:'+a.jierep
	from pos_itemdef a,pos_pccode b where a.pccode=b.pccode and a.jierep not in(select class from jierep)

--pccode ����
select @count1 = count(1) from pccode where pccode>'9' and deptno8>'' and deptno8 not in(select code from pos_namedef)
if @count1 > 0 
	insert #list
	select distinct '150','�ۿۿ���ึ����û�ж����Ӧnamedef������','',' ������:'+pccode+'������deptno8='+deptno8
	from pccode  where pccode>'9' and deptno8>'' and deptno8 not in(select code from pos_namedef)
select @count1 = count(1) from pccode a where  a.pccode > '9' and a.deptno8>' ' and  (select count(1) from pccode b where a.deptno8 = b.deptno8 and b.pccode>'9')>1
if @count1 > 0 
	insert #list
	select distinct '170','�ۿۿ���ึ����deptno8�������ظ�','',' ������:'+pccode+'������deptno8='+deptno8
	 from pccode a where  a.pccode > '9' and a.deptno8>' ' and  (select count(1) from pccode b where a.deptno8 = b.deptno8 and b.pccode>'9')>1

-- **���¼��Ӫҵ����**
-- תǰ̨���������ݺ�ǰ̨���ݲ�һ��
if exists(select 1 from sysoption where catalog ='hotel' and (item ='lic_buy.1' or item ='lic_buy.2') and charindex('nar,',value)>0)
	begin          
    -- ��ar�����ÿ�ͨ��ar����
	select @count1 = count(1) from pos_menu a where a.sta='3' 
	and isnull((select sum(b.charge) from ar_account b where b.ref1=a.menu and b.modu_id='04'),0)
	+isnull((select sum(e.charge) from account e where e.ref1=a.menu and e.modu_id='04'),0)
	<>isnull((select sum(c.amount) from pos_pay c, pccode d where c.menu=a.menu and c.crradjt='NR' and c.sta='3' and c.paycode=d.pccode and (d.deptno2='TOR' or d.deptno2='TOA' or deptno4='ISC')),0)
	if @count1 > 0 
		insert #list
		select '300','תǰ̨�������ݺ�ǰ̨���ݲ�һ��',a.menu,a.menu+"  ����:"+f.descript+ "  ����:"+a.tableno+"  ���:"+convert(varchar,a.amount) from pos_menu a,pos_pccode f where  a.sta='3' and a.pccode=f.pccode
		and isnull((select sum(b.charge) from ar_account b where b.ref1=a.menu and b.modu_id='04'),0)
		+isnull((select sum(e.charge) from account e where e.ref1=a.menu and e.modu_id='04'),0)
		<>isnull((select sum(c.amount) from pos_pay c, pccode d where c.menu=a.menu and c.crradjt='NR' and c.sta='3' and c.paycode=d.pccode and (d.deptno2='TOR' or d.deptno2='TOA' or deptno4='ISC')),0)
	end
else
	begin
    -- ��ar�����ÿ���ͨ��ar����
	select @count1 = count(1) from pos_menu a where a.sta='3' 
	and isnull((select sum(b.charge) from ar_account b where b.ref1=a.menu and b.modu_id='04'),0)
	+isnull((select sum(e.charge) from account e where e.ref1=a.menu and e.modu_id='04'),0)
	<>isnull((select sum(c.amount) from pos_pay c, pccode d where c.menu=a.menu and c.crradjt='NR' and c.sta='3' and c.paycode=d.pccode and (d.deptno2='TOR' or d.deptno2='TOA')),0)
	if @count1 > 0 
		insert #list
		select '300','תǰ̨�������ݺ�ǰ̨���ݲ�һ��',a.menu,a.menu+"  ����:"+f.descript+ "  ����:"+a.tableno+"  ���:"+convert(varchar,a.amount) from pos_menu a,pos_pccode f where  a.sta='3' and a.pccode=f.pccode
		and isnull((select sum(b.charge) from ar_account b where b.ref1=a.menu and b.modu_id='04'),0)
		+isnull((select sum(e.charge) from account e where e.ref1=a.menu and e.modu_id='04'),0)
		<>isnull((select sum(c.amount) from pos_pay c, pccode d where c.menu=a.menu and c.crradjt='NR' and c.sta='3' and c.paycode=d.pccode and (d.deptno2='TOR' or d.deptno2='TOA' )),0)
	end

-- У����������
---- �޳�״̬��һ�µ�δ���˵�����
update pos_menu set pcrec ='' from pos_menu where pcrec in (select pcrec from pos_menu where sta='3' and pcrec >'') and sta<>'3'	
update pos_tmenu set pcrec ='' from pos_tmenu where pcrec in (select pcrec from pos_tmenu where sta='3' and pcrec >'') and sta<>'3'	
update pos_hmenu set pcrec ='' from pos_hmenu where bdate = dateadd(day,-1, @bdate) and pcrec in (select pcrec from pos_hmenu where bdate = dateadd(day,-1, @bdate) and sta='3' and pcrec >'') and sta<>'3'	
---- �������������������ŵ�����
update  pos_menu set pcrec =(select min(c.menu) from pos_menu c where a.pcrec = c.pcrec and c.pcrec>'')
	from pos_menu a where a.pcrec>'' and a.pcrec not in (select b.menu from pos_menu b where a.pcrec = b.pcrec and b.pcrec>'')
update  pos_tmenu set pcrec =(select min(c.menu) from pos_tmenu c where a.pcrec = c.pcrec and c.pcrec>'')
	from pos_tmenu a where a.pcrec>'' and a.pcrec not in (select b.menu from pos_tmenu b where a.pcrec = b.pcrec and b.pcrec>'')
update  pos_hmenu set pcrec =(select min(c.menu) from pos_hmenu c where a.pcrec = c.pcrec and c.pcrec>'' and c.bdate = dateadd(day,-1, @bdate))
	from pos_hmenu a where a.pcrec>'' and a.bdate = dateadd(day,-1, @bdate) and a.pcrec not in (select b.menu from pos_hmenu b where a.pcrec = b.pcrec and b.pcrec>'' and b.bdate = dateadd(day,-1, @bdate))

--	��� menu,dish,pay �Ľ���Ƿ���ȷ
create table #pcrec (menu char(10) default '' not null)
select * into #menu from pos_menu where 1=2
select * into #dish from pos_dish where 1=2
select * into #pay from pos_pay where 1=2
if @date = @bdate 
	begin
	insert into #menu select * from pos_menu where sta ='2'
	insert into #dish select a.* from pos_dish a,#menu b where a.menu=b.menu and charindex(a.sta,'03579A')>0
	insert into #pay  select a.* from pos_pay  a,#menu b where a.menu=b.menu
	end
else
	begin
	insert into #menu select * from pos_hmenu where sta ='2' and bdate=@date
	insert into #dish select a.* from pos_hdish a,#menu b where a.menu=b.menu  and charindex(a.sta,'03579A')>0
	insert into #pay  select a.* from pos_hpay  a,#menu b where a.menu=b.menu
	end
update #menu set pcrec = menu where pcrec = '' or pcrec is null
insert into #pcrec select distinct pcrec from #menu
insert #list 
select '800','dish�ϼƺ�pay�ϼƲ�һ��', a.menu, convert(varchar,(select sum(b.amount - b.dsc + b.tax + b.srv) from #dish b, #menu d where d.pcrec=a.menu and d.menu = b.menu and charindex(b.sta,'03579A')>0 and b.code <>'Y' and b.code<>'Z')) + ','
	+ convert(varchar,(select sum(c.amount) from #pay c, #menu e where e.pcrec=a.menu and e.menu = c.menu) )
	from #pcrec a 
	where (select sum(b.amount - b.dsc + b.tax + b.srv) from #dish b, #menu d where d.pcrec=a.menu and d.menu = b.menu and charindex(b.sta,'03579A')>0 and b.code <>'Y' and b.code<>'Z') 
	<> (select sum(c.amount) from #pay c, #menu e where e.pcrec=a.menu and e.menu = c.menu) 

insert #list 
select '830','����ึ�����Ʒ���ϼ�',a.menu,'����ึ�����Ʒ���ϼƣ����޷���̯�����±���ƽ��'
	from #pcrec a 
	where (select sum(b.amount - b.dsc + b.tax + b.srv) from #dish b, #menu d where d.pcrec=a.menu and d.menu = b.menu and charindex(b.sta,'03579A')>0 and b.code <>'Y' and b.code<>'Z') 
	< (select sum(c.amount) from #pay c, #menu e, pccode f where e.pcrec=a.menu and e.menu = c.menu and c.paycode=f.pccode and f.deptno8<'' ) 

-- У��Ӫҵ����
update pos_pay set bdate = a.bdate from pos_menu a where a.menu = pos_pay.menu
update pos_tpay set bdate = a.bdate from pos_tmenu a where a.menu = pos_tpay.menu


select sort,des,menu,msg from #list order by sort
;