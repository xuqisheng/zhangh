if exists(select 1 from sysobjects where name='p_cyj_pos_maint_check' and type ='P')
	drop proc p_cyj_pos_maint_check;
create proc p_cyj_pos_maint_check
	@parm			char(20) = ''
as
-- ------------------------------------------------------------------------------------------------------------
-- ����ϵͳ���ݼ��
-- @parm : '' - ȫ�����, 'plu' - ����, 'kitchen' - ������ӡ, 'touch' - ��������'code' - ������������
-- ------------------------------------------------------------------------------------------------------------

-- ��������
create table #syscheck_result
(
	id			numeric(10,0)	identity,
	flag		char(1)			not null,  -- 0-OK, 1-FAIL	, 2 -warning
	des		varchar(60)		null
)
insert #syscheck_result(flag,des) select '0', ''
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', convert(char(19), getdate())
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '��⿪ʼ......'
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'


if @parm = ''
	begin
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	insert #syscheck_result(flag,des) select '0', '. '
	insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
	insert #syscheck_result(flag,des) select '0', '. �������ò��� '
	insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
---------------
-- jierep
---------------
	insert #syscheck_result(flag,des) select '2', 'jierep: �����޶�Ӧ������� class = ' + class
		from jierep where class not in (select distinct jierep from pccode where jierep<>'')
							and rectype='B' and mode<>'E' and class not like '010%'
	insert #syscheck_result(flag,des) select '2', 'jierep: û������� C �� class = ' + a.class
		from jierep a where a.class ='C' and not exists(select 1 from jierep b where a.class=b.toclass)
	insert #syscheck_result(flag,des) select '1', 'jierep: toclass / rectype / toop Ϊ�� class = '+ class
		from jierep where class<>'999' and (rtrim(rectype) is null or rtrim(toop) is null or rtrim(toclass) is null)
	end
---------------------
-- pccode - ��������
---------------------
if @parm = ''
	begin
	insert #syscheck_result(flag,des) select '1', 'pccode: ��Ч�� argcode =' + pccode + ' ' + descript + ' ' + isnull(argcode,'')
		from pccode where rtrim(argcode) is null or argcode not in (select argcode from argcode)
	insert #syscheck_result(flag,des) select '1', 'pccode: Rebate & Reason ��ƥ�� = ' + pccode+' '+descript+' '+reason+' '+deptno8
		from pccode where deptno8='RB' and reason='F'
	insert #syscheck_result(flag,des) select '1', 'pccode: Rebate & tail ��ƥ�� = ' + pccode+' '+descript+' '+tail+' '+deptno8
		from pccode where deptno8='RB' and tail<>'07'
	insert #syscheck_result(flag,des) select '2', 'pccode: �Ƿ��� tail = ' + pccode+' '+descript+' '+tail
		from pccode where rtrim(tail) is null or tail<'01' or tail>='1'
	end
---------------------
-- pccode - ���ò���
---------------------
if @parm = ''
	begin
	if not exists(select 1 from pccode where jierep like '010%' and tail='07' and commission=3 and argcode<'9')
		insert #syscheck_result(flag,des) select '2', 'pccode: û�ж��巿�ѷ���Ѵ���,���߶��岻��ȷ'
	insert #syscheck_result(flag,des) select '1', 'pccode: ��Ч�� jierep = ' + pccode+' '+descript+' '+jierep
		from pccode where argcode<'9' and jierep<>'010' and (rtrim(jierep) is null or jierep not in (select class from jierep))
	insert #syscheck_result(flag,des) select '1', 'pccode: ͬһ�� pccode �в�ͬ�� jierep = ' + a.pccode +' '+descript
		from pccode a where a.argcode<'9' and exists(select 1 from pccode b where a.pccode=b.pccode and b.jierep<>a.jierep)
	
	insert #syscheck_result(flag,des) select '1', 'pccode: �Ƿ��� deptno = ' + a.pccode+' '+a.descript+isnull(a.deptno,'')
		from pccode a where a.argcode<'9' and (rtrim(a.deptno) is null or a.deptno not in (select code from basecode where cat='chgcod_deptno'))
	insert #syscheck_result(flag,des) select '1', 'pccode: �Ƿ��� deptno1 = ' + a.pccode+' '+a.descript+isnull(a.deptno1,'')
		from pccode a where a.argcode<'9' and (rtrim(a.deptno1) is null or a.deptno1 not in (select code from basecode where cat='chgcod_deptno1'))
	insert #syscheck_result(flag,des) select '1', 'pccode: �Ƿ��� deptno2 = ' + a.pccode+' '+a.descript+isnull(a.deptno2,'')
		from pccode a where a.argcode<'9' and (rtrim(a.deptno2) is null or a.deptno2 not in (select code from basecode where cat='chgcod_deptno2'))
	insert #syscheck_result(flag,des) select '1', 'pccode: �Ƿ��� deptno3 = ' + a.pccode+' '+a.descript+isnull(a.deptno3,'')
		from pccode a where a.argcode<'9' and (rtrim(a.deptno3) is null or a.deptno3 not in (select code from basecode where cat='chgcod_deptno3'))
	insert #syscheck_result(flag,des) select '1', 'pccode: �Ƿ��� deptno4 = ' + a.pccode+' '+a.descript+isnull(a.deptno4,'')
		from pccode a where a.argcode<'9' and (rtrim(a.deptno4) is null or a.deptno4 not in (select code from basecode where cat='chgcod_deptno4'))
	insert #syscheck_result(flag,des) select '1', 'pccode: �Ƿ��� deptno5 = ' + a.pccode+' '+a.descript+isnull(a.deptno5,'')  -- ���÷�Χ AFP
		from pccode a where a.argcode<'9'
			and ( rtrim(a.deptno5) is null
				or (substring(a.deptno5,1,1)<>'' and substring(a.deptno5,1,1) not in ('A','F','P'))
				or (substring(a.deptno5,2,1)<>'' and substring(a.deptno5,2,1) not in ('A','F','P'))
				or (substring(a.deptno5,3,1)<>'' and substring(a.deptno5,3,1) not in ('A','F','P'))
				)
	
	insert #syscheck_result(flag,des) select '1', 'pccode: �Ƿ��� deptno6 = ' + a.pccode+' '+a.descript+isnull(a.deptno6,'')
		from pccode a where a.argcode<'9' and (rtrim(a.deptno6) is null or a.deptno6 not in (select code from basecode where cat='chgcod_deptno6'))
	insert #syscheck_result(flag,des) select '1', 'pccode: �Ƿ��� deptno7 = ' + a.pccode+' '+a.descript+isnull(a.deptno7,'')
		from pccode a where a.argcode<'9' and (rtrim(a.deptno7) is null or a.deptno7 not in (select code from basecode where cat='chgcod_deptno7'))
	--  deptno8 --> rebate define
	--insert #syscheck_result(flag,des) select '1', 'pccode: �Ƿ��� deptno8 = ' + a.pccode+' '+a.descript+isnull(a.deptno8,'')
	--	from pccode a where a.argcode<'9' and (rtrim(a.deptno8) is null or a.deptno8 not in (select code from basecode where cat='chgcod_deptno8'))
	
	---------------------
	-- pccode - �����
	---------------------
	insert #syscheck_result(flag,des) select '1', 'pccode: ��Ч�ĸ��� deptno = ' + pccode+' '+descript+' '+deptno
		from pccode where argcode>='9' and (rtrim(deptno) is null or deptno not in (select code from basecode where cat='paymth_deptno'))
	insert #syscheck_result(flag,des) select '1', 'pccode: ��Ч�ĸ��� deptno1 = ' + pccode+' '+descript+' '
		from pccode where argcode>='9' and rtrim(deptno1) is null
	insert #syscheck_result(flag,des) select '1', 'pccode: �ظ��ĸ��� deptno1 = ' + a.pccode+' '+a.descript+' '+a.deptno1
		from pccode a where a.argcode>='9' and exists(select 1 from pccode b where a.pccode<>b.pccode and a.deptno1=b.deptno1)
	insert #syscheck_result(flag,des) select '1', 'pccode: �ظ��ĸ��� deptno2 = ' + a.pccode+' '+a.descript+' '+a.deptno1
		from pccode a where a.argcode>='9' and exists(select 1 from pccode b where a.pccode<>b.pccode and a.deptno2=b.deptno2)
	insert #syscheck_result(flag,des) select '1', 'pccode: �ۿ��ึ�� reason error = ' + a.pccode+' '+a.descript+' '+a.reason
		from pccode a where a.argcode>='9' and a.deptno='H' and a.reason<>'T'
	insert #syscheck_result(flag,des) select '1', 'pccode: ���ۿ��ึ�� reason error = ' + a.pccode+' '+a.descript+' '+a.reason
		from pccode a where a.argcode>='9' and a.deptno<>'H' and a.reason='T'
	insert #syscheck_result(flag,des) select '1', 'pccode: ���ÿ��ึ�� no ISC flag = ' + a.pccode+' '+a.descript+' '+a.deptno4
		from pccode a where a.argcode>='9' and a.deptno in ('C','D') and a.deptno4<>'ISC'
	insert #syscheck_result(flag,des) select '1', 'pccode: �����ÿ��ึ�� has ISC flag = ' + a.pccode+' '+a.descript+' '+a.deptno4
		from pccode a where a.argcode>='9' and a.deptno not in ('C','D') and a.deptno4='ISC'
	insert #syscheck_result(flag,des) select '1', 'pccode: ������Ϊ���� = ' + a.pccode+' '+a.descript
		from pccode a where a.argcode>='9' and a.deptno >='G' and a.deptno3='98'
	insert #syscheck_result(flag,des) select '1', 'pccode: ������Ϊǰ̨���� = ' + a.pccode+' '+a.descript
		from pccode a where a.argcode>='9' and a.deptno >='I' and a.deptno6='99'
	insert #syscheck_result(flag,des) select '1', 'pccode: ��Ҷ�Ӧ������� = ' + a.pccode+' '+a.descript+' '+a.deptno7
		from pccode a where a.argcode>='9' and a.deptno7<>'' and a.deptno7 not in (select code from fec_def)
	insert #syscheck_result(flag,des) select '1', 'pccode: POS�ۿ۶�Ӧ������� = ' + a.pccode+' '+a.descript+' '+a.deptno8
		from pccode a where a.argcode>='9' and a.deptno8<>'' and a.deptno8 not in (select code from pos_namedef)
	insert #syscheck_result(flag,des) select '1', 'pccode: pos_item��Ӧ������� = ' + a.pccode+' '+a.descript+' '+a.pos_item
		from pccode a where a.argcode>='9' and a.pos_item<>'' and a.pos_item not in (select code from pos_namedef)
	
	if ( exists(select 1 from sysoption where catalog='hotel' and item='lic_buy.1' and charindex('vippts', value)>0 )
		or exists(select 1 from sysoption where catalog='hotel' and item='lic_buy.2' and charindex('vippts', value)>0 ) )
		and not exists(select 1 from pccode where argcode>'9' and deptno2='PTS')
		insert #syscheck_result(flag,des) select '1', 'ϵͳ�����˻��ֹ��ܣ�����û�����û��ָ��ʽ'
end

---------------------
-- artag1
---------------------
if @parm = ''
	begin
	insert #syscheck_result(flag,des) select '1', 'Basecode: artag1 grp error = '+code+' '+descript+' '+grp
		from basecode where cat='artag1' and (grp='' or grp not in (select code from basecode where cat='argrp1'))
	---------------------
	-- bankcode
	---------------------
	insert #syscheck_result(flag,des) select '1', 'pccode: δ����ˢ���� = ' + a.pccode+' '+a.descript
		from pccode a where a.argcode>='9' and a.deptno in ('C','D') and pccode not in (select pccode from bankcard)
	insert #syscheck_result(flag,des) select '1', 'bankcard: �����ˢ���� = ' + bankcode
		from bankcard where bankcode not in (select code from basecode where cat='bankcode')
	end	

if @parm = ''
	begin
	
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	insert #syscheck_result(flag,des) select '0', '. '
	insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
	insert #syscheck_result(flag,des) select '0', '. �������۲��� '
	insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	if exists(select 1 from basecode where cat='guest_class' and code not in ('F','G','C','A','S','R','H'))
		insert #syscheck_result(flag,des) select '1', '�ͻ�����������������'
	if exists(select 1 from basecode where cat='guest_type' and code not in ('N','B','C','R'))
		insert #syscheck_result(flag,des) select '1', '�ͻ���������������������'
	if exists(select 1 from saleid where grp not in (select code from salegrp))
		insert #syscheck_result(flag,des) select '1', '����Ա���������'
	if exists(select 1 from saleid where empno<>'' and empno not in (select empno from sys_empno))
		insert #syscheck_result(flag,des) select '1', '����Ա��Ӧ���Թ��Ŵ���'
	
	end	

if @parm='' or charindex('plu',@parm)>0
	begin
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	insert #syscheck_result(flag,des) select '0', '. '
	insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
	insert #syscheck_result(flag,des) select '0', '. ���׼�ⲿ�� '
	insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	delete pos_price where id not in(select id from pos_plu_all)
	if exists(select 1 from  pos_price a,pos_plu_all b  where a.id=b.id and a.price<=0  and a.halt='F' and b.flag1='F' and b.flag11='F')
		insert #syscheck_result(flag,des) select '2', '���ڲ˼�Ϊ0�Ĳ�:'+'�˱�-'+b.plucode+'����-'+b.sort+'����:'+b.name1  from pos_price a,pos_plu_all b 
		where a.id=b.id and a.price<=0  and a.halt='F' and b.flag1='F' and b.flag11='F'
	end
	insert #syscheck_result(flag,des) select '0', '. ������'
	delete pos_sort_all where halt ='T'
	delete pos_sort where halt ='T'
	if exists(select 1 from pos_sort_all where tocode='')
		insert #syscheck_result(flag,des) select '1', '����û�ж��屨����:'+'�˱�-'+a.plucode+'����-'+a.sort+'����:'+a.name1  from pos_sort a where a.tocode =''
	if exists(select 1 from pos_plu a,pos_sort b where a.pluid=b.pluid and a.plucode=b.plucode and a.sort=b.sort and a.tocode<>b.tocode and a.tocode<>'')
		insert #syscheck_result(flag,des) select '2', '�˺Ͳ���ı����岻һ��:'+'�˱�-'+a.plucode+'����-'+a.sort+'����:'+a.name1  from pos_plu a,pos_sort b where a.pluid=b.pluid and a.plucode=b.plucode and a.sort=b.sort and a.tocode<>b.tocode and a.tocode<>''
	insert #syscheck_result(flag,des) select '0', '. �˱�ʹ��'
	if exists(select 1 from pos_plucode where pccodes='')
		insert #syscheck_result(flag,des) select '1', '�˱�û�б��κβ���ʹ��:'+'�˱�-'+a.plucode+'����:'+a.descript  from pos_plucode a where a.pccodes =''
	insert #syscheck_result(flag,des) select '0', '. �����˱�'
	if exists(select 1 from pos_pccode c where c.pccode not in (select a.pccode from pos_pccode a, pos_plucode b where c.pccode=a.pccode and charindex(a.pccode,b.pccodes)>0))
		insert #syscheck_result(flag,des) select '1', '����û�ж���˱�:'+'����-'+c.pccode+'����:'+c.descript from pos_pccode c where c.pccode not in (select a.pccode from pos_pccode a, pos_plucode b where c.pccode=a.pccode and charindex(a.pccode,b.pccodes)>0)
	insert #syscheck_result(flag,des) select '0', '. ������ӡ'
	if exists(select  1 from pos_prnscope a, pos_prnscope b where a.id >0 and a.plusort=b.plusort and a.kitchens<>b.kitchens)
		insert #syscheck_result(flag,des) select '2', '�˺Ͳ���ĳ�����ӡ���岻һ��:'+'�˱�-'+c.plucode+'����-'+c.sort+'����:'+c.name1  from pos_prnscope a, pos_prnscope b, pos_plu_all c where a.id=c.id and a.id >0 and a.plusort=b.plusort and a.kitchens<>b.kitchens

if @parm = ''
	begin
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	insert #syscheck_result(flag,des) select '0', '. '
	insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
	insert #syscheck_result(flag,des) select '0', '. �������� '
	insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	-- ---------------------------------------------------------------------------------------
	--	EDP
	-- ---------------------------------------------------------------------------------------
	if not exists(select 1 from sysoption where catalog='hotel' and item='edp_group')
		insert sysoption (catalog,item,value) select 'hotel','edp_group',''
	
	if not exists(select 1 from sysoption where catalog='hotel' and item='edp_group' and value <> '')
		insert #syscheck_result(flag,des) select '1', 'sysoption(hotel,edp_group): δ����EDP�����û���'
	-- ---------------------------------------------------------------------------------------
	--	DocMgr
	-- ---------------------------------------------------------------------------------------
	if not exists(select 1 from sysoption where catalog='hotel' and item='docftpserver')
		insert sysoption (catalog,item,value) select 'hotel','docftpserver',''
	
	if not exists(select 1 from sysoption where catalog='hotel' and item='docftpserver' and value <> '')
		insert #syscheck_result(flag,des) select '1', 'sysoption(hotel,docftpserver): δ����ǰ̨ϵͳ�ĵ����ķ�����'
	-- ---------------------------------------------------------------------------------------
	--	AutoUpdate
	-- ---------------------------------------------------------------------------------------
	if not exists(select 1 from sysoption where catalog='hotel' and item='updateftpserver')
		insert sysoption (catalog,item,value) select 'hotel','updateftpserver',''
	
	if not exists(select 1 from sysoption where catalog='hotel' and item='updateftpserver' and value <> '')
		insert #syscheck_result(flag,des) select '1', 'sysoption(hotel,updateftpserver): δ����ǰ̨ϵͳ�Զ����·���������'
	end
-- ---------------------------------------------------------------------------------------
--	��¼ִ��ʱ��
-- ---------------------------------------------------------------------------------------
declare	@settime	varchar(30)
select @settime = convert(char(10), getdate(), 111)+' '+convert(char(8), getdate(), 8)
if not exists(select 1 from sysoption where catalog='hotel' and item='check_parms')
	insert sysoption (catalog,item,value) select 'hotel','check_parms',''
update sysoption set value=@settime where catalog='hotel' and item='check_parms'

-- output
select * from #syscheck_result

return 0;
