if exists (select 1 from sysobjects where name='p_gds_maint_main')
   drop proc p_gds_maint_main;
create proc p_gds_maint_main
as
-- ---------------------------------------------------------------------------------------
-- ϵͳ���ݼ��
-- 
-- --- ���򵥵Ĵ����ڼ��Ĺ������Զ����
-- ---------------------------------------------------------------------------------------

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
insert #syscheck_result(flag,des) select '1', 'jierep: toclass / rectype / toop Ϊ�� class = ' + class 
	from jierep where class<>'999' and (rtrim(rectype) is null or rtrim(toop) is null or rtrim(toclass) is null)
---------------------
-- pccode - ��������
---------------------
insert #syscheck_result(flag,des) select '1', 'pccode: ��Ч�� argcode = ' + pccode + ' ' + descript + ' ' + isnull(argcode,'')
	from pccode where rtrim(argcode) is null or argcode not in (select argcode from argcode)
insert #syscheck_result(flag,des) select '1', 'pccode: Rebate & Reason ��ƥ�� = ' + pccode+' '+descript+' '+reason+' '+deptno8
	from pccode where deptno8='RB' and reason='F'
insert #syscheck_result(flag,des) select '1', 'pccode: Rebate & tail ��ƥ�� = ' + pccode+' '+descript+' '+tail+' '+deptno8
	from pccode where deptno8='RB' and tail<>'07'
insert #syscheck_result(flag,des) select '2', 'pccode: �Ƿ��� tail = ' + pccode+' '+descript+' '+tail
	from pccode where rtrim(tail) is null or tail<'01' or tail>='1'
---------------------
-- pccode - ���ò���
---------------------
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
if not exists(select 1 from sysoption where catalog='hotel' and item='lic_buy.1' and charindex(',nar,', value)>0)
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
	insert #syscheck_result(flag,des) select '2', 'ϵͳ�����˻��ֹ��ܣ�����û�����û��ָ��ʽ'


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
insert #syscheck_result(flag,des) select '0', '. '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '. Ԥ���Ӵ����� '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
update typim set quantity =(select count(1) from rmsta where rmsta.type=typim.type)
insert #syscheck_result(flag,des) select '1', '��ֹʹ�õķ�����룺'+type from typim where type='TEN'
if exists(select 1 from typim where gtype not in (select code from gtype))
	insert #syscheck_result(flag,des) select '1', '���ඨ�壺�в����ڵĴ���'
if exists(select 1 from rmsta where roomno>='A')
	insert #syscheck_result(flag,des) select '1', '���Ŷ��壺���Ų�������ĸ'
if exists(select 1 from rmsta where charindex(' ',roomno)>0)
	insert #syscheck_result(flag,des) select '1', '���Ŷ��壺�����м䲻���пո�'
if exists(select 1 from rmsta where type not in (select type from typim))
	insert #syscheck_result(flag,des) select '1', '���Ŷ��壺�в����ڵķ���'
if exists(select 1 from rmsta where flr not in (select code from flrcode))
	insert #syscheck_result(flag,des) select '1', '���Ŷ��壺�в����ڵ�¥��'
if exists(select 1 from rmsta where hall not in (select code from basecode where cat='hall'))
	insert #syscheck_result(flag,des) select '1', '���Ŷ��壺�в����ڵ�¥��'

if exists(select 1 from mktcode where jierep not in (select class from jierep))
	insert #syscheck_result(flag,des) select '1', '�г��붨�� jierep error'
if exists(select 1 from mktcode where rtrim(grp) is null or (grp<>'' and grp not in (select code from basecode where cat='market_cat')))
	insert #syscheck_result(flag,des) select '1', '�г��붨�� grp error'
if exists(select 1 from srccode where rtrim(grp) is null or (grp<>'' and grp not in (select code from basecode where cat='src_cat')))
	insert #syscheck_result(flag,des) select '1', '��Դ�붨�� grp error'
if not exists(select 1 from mktcode where flag='HSE')
	insert #syscheck_result(flag,des) select '2', '�г��붨��: û�ж������÷��г��� '
if not exists(select 1 from mktcode where flag='COM')
	insert #syscheck_result(flag,des) select '2', '�г��붨��: û�ж�����ѷ��г��� '
if not exists(select 1 from mktcode where flag='LON')
	insert #syscheck_result(flag,des) select '2', '�г��붨��: û�ж��峤�����г��� '

-- sysdefault extra - ¥�ż�� 
if exists(select 1 from sysdefault where columnname='extra' and char_length(rtrim(defaultvalue))=15
	and substring(defaultvalue,2,1) not in (select code from basecode where cat='hall')) 
	insert #syscheck_result(flag,des) select '1', '����ȱʡֵ����: ¥�Ŷ��������� '


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
insert #syscheck_result(flag,des) select '0', '. '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '. ������˲��� '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
---------------------
-- package
---------------------
insert #syscheck_result(flag,des) select '1', 'package: �Ƿ��� pccode = '+code+' '+descript+' '+isnull(pccode,'')
	from package where rtrim(pccode) is null or (rtrim(pccode) is null and pccode not in (select pccode from pccode where argcode<'9'))
insert #syscheck_result(flag,des) select '1', 'package: �Ƿ��� pos_pccode = '+code+' '+descript+' '+pos_pccode
	from package where rtrim(pos_pccode) is not null and pos_pccode not in (select pccode from pccode where argcode<'9')
insert #syscheck_result(flag,des) select '1', 'package: �Ƿ��Ķ�Ӧ�����ʻ� = '+code+' '+descript+' '+accnt
	from package where rtrim(accnt) is not null and accnt not in (select accnt from master where class='C')
insert #syscheck_result(flag,des) select '1', 'package: credit < amount '+code+' '+descript
	from package where credit<>0 and credit<amount 
insert #syscheck_result(flag,des) select '1', 'package: ���Ƿ��� package_type = '+code+' '+descript+' '+isnull(grp,'')
	from basecode where cat='package_type' and (grp='' or grp not in ('BF','FB','SVC','TAX','LAU')) 
---------------------
-- artag1
---------------------
insert #syscheck_result(flag,des) select '1', 'Basecode: artag1 grp error = '+code+' '+descript+' '+grp
	from basecode where cat='artag1' and (grp='' or grp not in (select code from basecode where cat='argrp1'))
---------------------
-- bankcode
---------------------
insert #syscheck_result(flag,des) select '1', 'pccode: δ����ˢ���� = ' + a.pccode+' '+a.descript
	from pccode a where a.argcode>='9' and a.deptno in ('C','D') and pccode not in (select pccode from bankcard)
insert #syscheck_result(flag,des) select '1', 'bankcard: �����ˢ���� = ' + bankcode
	from bankcard where bankcode not in (select code from basecode where cat='bankcode')



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

delete rmratecode_link where code not in (select code from rmratecode)
delete rmratecode_link where rmcode not in (select code from rmratedef)
if exists(select 1 from rmratedef where market<>'' and market not in (select code from mktcode))
	insert #syscheck_result(flag,des) select '1', '������ϸ����: ������Ч�г���'
if exists(select 1 from rmratedef where src<>'' and src not in (select code from srccode))
	insert #syscheck_result(flag,des) select '1', '������ϸ����: ������Ч��Դ��'
if exists(select 1 from rmratecode where cat='' or (cat<>'' and cat not in (select code from basecode where cat='rmratecat')))
	insert #syscheck_result(flag,des) select '1', '�����붨��: ������Ч���'
if exists(select 1 from rmratecode where market<>'' and market not in (select code from mktcode))
	insert #syscheck_result(flag,des) select '1', '�����붨��: ������Ч�г���'
if exists(select 1 from rmratecode where src<>'' and src not in (select code from srccode))
	insert #syscheck_result(flag,des) select '1', '�����붨��: ������Ч��Դ��'

if not exists(select 1 from basecode where cat='guestcard_cat' and code='CC')
	insert #syscheck_result(flag,des) select '1', 'Basecode - guestcard_cat: û�����ÿ���� CC'
if exists(select 1 from guest_card_type where cat='' or (cat<>'' and cat not in (select code from basecode where cat='guestcard_cat')))
	insert #syscheck_result(flag,des) select '1', 'Guest_card_type : ������Ч���'

--<<<  ע�������д����һ�����ԣ�һ��������  simon  2006.3.14 
--insert #syscheck_result(flag,des) select '1', 'Guest_card_type: ������ pccodes �����ظ� = ' + b.pccode 
--	from guest_card_type a, pccode b 
--		where a.pccodes<>'' and charindex(','+rtrim(b.pccode)+',', ','+rtrim(a.pccodes)+',')>0
--			group by b.pccode having count(1)>1
if exists(select 1 from guest_card_type a, pccode b 
		where a.pccodes<>'' and charindex(','+rtrim(b.pccode)+',', ','+rtrim(a.pccodes)+',')>0
			group by b.pccode having count(1)>1)
	insert #syscheck_result(flag,des) select '1', 'Guest_card_type: ���ڷ����� pccodes �����ظ�'
insert #syscheck_result(flag,des) select '1', 'pccode: ���ÿ�����û�ж��嵽 guest_card_type -'+a.pccode
	from pccode a where a.deptno4='ISC' and not exists(select 1 from guest_card_type b where charindex(a.pccode,b.pccodes)>0)

--->>>


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
insert #syscheck_result(flag,des) select '0', '. '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '. BOS ���� '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
update bos_pccode set jxc=1 where tag='S' and jxc<>1
if exists(select 1 from bos_pccode where chgcod='' or (chgcod<>'' and chgcod not in (select pccode from pccode)))
	insert #syscheck_result(flag,des) select '1', 'Bos_pccode : ������Ч������ chgcod'
if exists(select 1 from bos_pccode where site0='' or (site0<>'' and site0 not in (select site from bos_site)))
	insert #syscheck_result(flag,des) select '1', 'Bos_pccode : ������Ч������ site0'
if exists(select 1 from bos_pccode where smode<>'0' and smode<>'1')
	insert #syscheck_result(flag,des) select '1', 'Bos_pccode : �����ģʽ����'
if exists(select 1 from bos_pccode where tmode<>'0' and tmode<>'1')
	insert #syscheck_result(flag,des) select '1', 'Bos_pccode : ���ӷ�ģʽ����'
if exists(select 1 from bos_pccode where dmode<>'0' and dmode<>'1')
	insert #syscheck_result(flag,des) select '1', 'Bos_pccode : �ۿ�ģʽ����'

delete bos_site where pccode not in (select pccode from bos_pccode)
delete bos_site_sort where site not in (select site from bos_site)
delete bos_station where posno not in (select posno from bos_posdef)
update bos_posdef set def='T' where rtrim(def) is null or (def<>'T' and def<>'F')

if exists(select 1 from bos_extno where posno='' or (posno<>'' and posno not in (select posno from bos_posdef)))
	insert #syscheck_result(flag,des) select '1', 'Bos_extno : ������Ч posno'
if exists(select 1 from bos_posdef where pccodes='' or sites='')
	insert #syscheck_result(flag,des) select '1', 'Bos_posno : ������Ч pccodes or sites'

if exists(select 1 from bos_posdef where modu='03')
	and (select count(1) from bos_posdef where def='T' and modu='03') <> 1
	insert #syscheck_result(flag,des) select '1', 'Bos_posdef : �ͷ�����ȱʡ������������ã�Ҳֻ������һ��'
if exists(select 1 from bos_posdef where modu='06')
	and (select count(1) from bos_posdef where def='T' and modu='06') <> 1
	insert #syscheck_result(flag,des) select '1', 'Bos_posdef : ��������ȱʡ������������ã�Ҳֻ������һ��'
if exists(select 1 from bos_posdef where modu='07')
	and (select count(1) from bos_posdef where def='T' and modu='07') <> 1
	insert #syscheck_result(flag,des) select '1', 'Bos_posdef : �̳�ȱʡ������������ã�Ҳֻ������һ��'

insert #syscheck_result(flag,des) select '1', 'Bos_poscode : �̳��������� tag = S : ' + a.pccode
	from bos_pccode a, bos_posdef b where b.modu='09' and charindex(','+rtrim(a.pccode)+',', ','+rtrim(b.pccodes)+',') > 0 and a.tag<>'S'

insert #syscheck_result(flag,des) select '1', 'Bos_poscode : �̳��������ý����湦�� : ' + a.pccode
	from bos_pccode a, bos_posdef b where b.modu='09' and charindex(','+rtrim(a.pccode)+',', ','+rtrim(b.pccodes)+',') > 0 and a.jxc<>1

insert #syscheck_result(flag,des) select '1', 'Bos_poscode : �̳�������������һ���ֿ� : ' + a.pccode
	from bos_pccode a, bos_posdef b where b.modu='09' and charindex(','+rtrim(a.pccode)+',', ','+rtrim(b.pccodes)+',') > 0
		and not exists (select 1 from bos_site c where a.pccode=c.pccode and c.tag='��')

insert #syscheck_result(flag,des) select '0', ''
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '�绰�ƷѲ���'
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
--ADD BY ZK 2006.8.1
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
if exists(select 1 from rmsta where roomno not in (select roomno from phextroom))
	insert #syscheck_result(flag,des) select '1', 'phextroom: ĳһ����ĵ绰�ֻ�δ����'
--if exists(select 1 from phcoden where groupno not in (select groupno from phcodeg))
--	insert #syscheck_result(flag,des) select '1', 'phcoden: ���ڻ������δ������'
if exists (select 1 from phdeptdef where dept not in (select dept from phdeptdex)) or exists(select 1 from phdeptdef where dept not in (select dept from phdepthis))  or exists(select 1 from phdepthis where dept not in (select dept from phdeptdex))
   insert #syscheck_result(flag,des) select '1', 'phdeptdef��phdeptdex��phdepthis���ű����ݲ��������飡'
if exists(select 1 from phdeptroom where room not in (select roomno from phextroom) )
if exists(select 1 from phextroom where rgid='')
   insert #syscheck_result(flag,des) select '1', 'phdeptroom���к���δ����������飡'
if exists(select 1 from phcodeg where (rate1<>0 and rate2<>0) and (basesnd=stepsnd) )
   insert #syscheck_result(flag,des) select '1', 'phcodeg���е�basesnd=stepsndʱrate2�Ƿ��б�Ҫ���ã�'
if ((select count(*)  from phcoden)+(select count(*) from phncls)<>(select count(*) from phparms_setup))
   insert #syscheck_result(flag,des) select '1', 'phparms_setup���м�¼<>phcoden��phncls��¼֮�ͣ������Ƿ���ȱʧ'
if exists(select 1 from phcoden where pgid = '' or pgid is null)
	insert #syscheck_result(flag,des) select '1', 'phcoden: ���ڱ��к���δ���飬phcoden���ֶ�pgidΪ��'
if exists(select 1 from phcoden where descript = '' or descript is null)
	insert #syscheck_result(flag,des) select '1', 'phcoden: ���ڱ��к��������δ������'
if exists(select 1 from phparms where pvalue = '' or svalue='' or cutfee='')
	insert #syscheck_result(flag,des) select '1', 'phparms: �Ʒ���Ŀ������pvalue = '' or svalue='' or cutfee=''����'


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
insert #syscheck_result(flag,des) select '0', '. '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '. POS ���� '
insert #syscheck_result(flag,des) select '0', ''
insert #syscheck_result(flag,des) select '0', '  ����POSϵͳʹ����ؼ�⹦�ܣ�����ʡ��'
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//---------------
//-- pos_pccode
//---------------
//if exists(select 1 from pos_pccode where rtrim(chgcod) is null or chgcod not in(select pccode from pccode))
//	insert #syscheck_result(flag,des) select '1', 'pos_pccode: chgcod �����ͷ������Ӧ��ϵ�д�'
//if exists(select 1 from pos_pccode where rtrim(mode) is null)
//	insert #syscheck_result(flag,des) select '1', 'pos_pccode: û�ж���ȱʡģʽ'
//if exists(select 1 from pos_pccode where rtrim(mode) is not null and mode not in(select code from pos_mode_name))
//	insert #syscheck_result(flag,des) select '1', 'pos_pccode: ��������Щȱʡģʽ������'
//if exists(select 1 from pos_pccode where rtrim(dec_mode)  is not null and rtrim(dec_code) is null)
//	insert #syscheck_result(flag,des) select '1', 'pos_pccode: �� ȡ��Ҫ��, ��û�ж��� ��ͷ��'
//if exists(select 1 from pos_pccode where rtrim(dec_code) is not null and dec_code not in(select convert(char(10),id) from pos_plu_all))
//	insert #syscheck_result(flag,des) select '1', 'pos_pccode: ��ͷ�벻����'
//---------------
//-- pos_namedef
//---------------
//if exists(select 1 from  pos_namedef a, pos_namedef b where a.code = b.code and a.descript <> b.descript)
//	or exists(select 1 from  pos_namedef a, pos_namedef b where a.code = b.code and a.descript1 <> b.descript1)
//	insert #syscheck_result(flag,des) select '1', 'pos_namedef: ��ͬ������ͬ������������һ��'
//if not exists(select 1 from pos_namedef where code = '602' and descript = '<����>')
//	insert #syscheck_result(flag,des) select '1', 'pos_namedef: code = 602 ����Ϊ <����>'
//if not exists(select 1 from pos_namedef where code = '605' and descript = '<ȫ��>')
//	insert #syscheck_result(flag,des) select '1', 'pos_namedef: code = 605 ����Ϊ <ȫ��>'
//if not exists(select 1 from pos_namedef where code = '607' and descript = '<�����ۿ�>')
//	insert #syscheck_result(flag,des) select '1', 'pos_namedef: code = 607 ����Ϊ <�����ۿ�>'
//if not exists(select 1 from pos_namedef where code = '610' and descript = '�ٷֱ��ۿ�')
//	insert #syscheck_result(flag,des) select '1', 'pos_namedef: code = 610 ����Ϊ �ٷֱ��ۿ�'
//if not exists(select 1 from pos_namedef where code = '620' and descript = '�������ۿ�')
//	insert #syscheck_result(flag,des) select '1', 'pos_namedef: code = 620 ����Ϊ �������ۿ�'
//if not exists(select 1 from pos_namedef where code = '650' and descript = '�º��ۿ�')
//	insert #syscheck_result(flag,des) select '1', 'pos_namedef: code = 650 ����Ϊ �º��ۿ�'
//if not exists(select 1 from pos_namedef where code = '099' )
//	insert #syscheck_result(flag,des) select '1', 'pos_namedef: û�ж��� code = 099 (<δ����>) ��'
//if not exists(select 1 from pos_namedef where code = '099' and descript = '<δ����>')
//	insert #syscheck_result(flag,des) select '1', 'pos_namedef: code = 099 ����Ϊ <δ����>'
//---------------
//-- pos_itemdef
//---------------
//delete pos_itemdef where pccode not in (select pccode from pos_pccode)
//delete pos_itemdef where code not in (select code from pos_namedef)
//if exists(select 1 from pos_pccode where pccode not in(select pccode from pos_itemdef))
//	insert #syscheck_result(flag,des) select '1', 'pos_itemdef: ��Щ��������itemdef û�ж��� -' + pccode from pos_pccode where pccode not in (select distinct pccode from pos_itemdef)
//if exists(select 1 from pos_itemdef a, pos_pccode b, pccode c  where a.pccode = b.pccode and b.chgcod = c.pccode and a.jierep <> c.jierep)
//	insert #syscheck_result(flag,des) select '1', 'pos_itemdef: ע����� jierep <> pccode.jierep'
//if exists(select 1 from pos_itemdef where rtrim(jierep) is null or jierep not in (select class from jierep))
//	insert #syscheck_result(flag,des) select '1', 'pos_itemdef: '+pos_itemdef.pccode+pos_itemdef.jierep+' ������Чjierep���ݶ���' from pos_itemdef where jierep not in(select class from jierep)
//if exists(select 1 from pos_pccode a where exists(select 1 from pos_itemdef b where a.pccode = b.pccode  ) and not exists(select 1 from pos_itemdef c where a.pccode = c.pccode and c.code = '099' ))
//	insert #syscheck_result(flag,des) select '1',  'pos_itemdef: pccode=' + pccode +' û�ж���code=099' from pos_pccode a where exists(select 1 from pos_itemdef b where a.pccode = b.pccode  ) and not exists(select 1 from pos_itemdef c where a.pccode = c.pccode and c.code = '099' )
//declare	@pccode 	char(3),
//			@code0 	char(15),
//			@plucode char(2),
//			@plucodes char(100),
//			@sort		char(4),
//			@code 	char(6),
//			@name1 	varchar(30),
//			@name2 	varchar(50),
//			@id		integer,
//			@ret		char(3)
//create table #list(
//	pccode	char(3),
//	id			int,
//	plucode	char(2),
//	sort		char(4),
//	code		char(6),
//	name1		varchar(30),
//	name2		varchar(50)
//)
//declare 	link_cur cursor for select pccode, plucode from pos_plucode_link order by pccode
//declare	plu_cur cursor for select id,plucode,sort,code,name1,name2,sort+code from pos_plu_all where charindex(plucode, @plucodes) >0 order by plucode,sort,code
//open link_cur 
//fetch link_cur into @pccode,@plucodes
//while @@sqlstatus = 0 
//	begin
//	open plu_cur
//	fetch plu_cur into @id,@plucode,@sort,@code,@name1,@name2,@code0
//	while @@sqlstatus = 0 
//		begin
//		exec 	p_gl_pos_get_item_code 	@pccode,	@code, @ret	 out
//		if @ret = '099' and not exists(select 1 from #list where id = @id and pccode = @pccode)
//			insert into #list(pccode,id,plucode,sort,code,name1,name2) select @pccode,@id,@plucode,@sort,@code,@name1,@name2 
//		fetch plu_cur into @id,@plucode,@sort,@code,@name1,@name2,@code0
//		end
//	close plu_cur
//	fetch link_cur into @pccode,@plucodes
//	end
//close link_cur
//deallocate cursor link_cur
//deallocate cursor plu_cur
//insert #syscheck_result(flag,des) select '1',  'pos_itemdef: ����û�ж���:'+pccode +'--'+ plucode+sort+code+ltrim(rtrim(name1)) from #list
//
//---------------
//-- pos ������ӡ����
//---------------
//if exists(select 1 from pos_printer where pcode not in(select code from pos_pserver))
//	insert #syscheck_result(flag,des) select '1', 'pos_printer: ����û�ж�����Ч��ӡ�������Ĵ�ӡ������'
//if exists(select 1 from pos_kitchen where printer not in(select code from pos_printer))
//	insert #syscheck_result(flag,des) select '1', 'pos_kitchen: ����û�ж�����Ч��ӡ���ĳ�������'
//if exists(select 1 from pos_prnscope where code not in(select code from pos_kitchen))
//	insert #syscheck_result(flag,des) select '1', 'pos_prnscope: ����û�ж�����Ч��������ͳ�����Ӧ��ϵ����'
//---------------
//-- pos ���׶���
//---------------
//if exists(select 1 from pos_sort_all where plucode not in(select plucode from pos_plucode))
//	insert #syscheck_result(flag,des) select '1', 'pos_sort_all: ����û�ж�����Ч�˱��Ĳ��ඨ��'
//if exists(select 1 from pos_plu_all a where plucode + sort not in(select plucode + sort from pos_sort_all))
//	insert #syscheck_result(flag,des) select '1', 'pos_plu_all: ����û�ж�����Ч����Ĳ��׶���'
//if exists(select 1 from pos_std where std_id not in(select id from pos_plu_all) or id not in (select id from pos_plu_all))
//	insert #syscheck_result(flag,des) select '1', 'pos_std: �ײ˶���������Ч�˴��ڣ�����pos_plu_all�У�'
//delete pos_plucode_link where pccode not in(select pccode from pos_pccode)
//if exists(select 1 from pos_pccode where pccode not in(select pccode from pos_plucode_link))
//	insert #syscheck_result(flag,des) select '1', 'pos_plucode_link: ��Щ����û�ж����Ӧ�˱�'
//---------------
//-- pos pda 
//---------------
//if exists(select 1 from pos_reg where pccode not in(select pccode from pos_pccode))
//	insert #syscheck_result(flag,des) select '1', 'pos_reg: PDA���������еĲ������д�'
//if exists(select 1 from pos_pda where pccode not in(select pccode from pos_pccode))
//	insert #syscheck_result(flag,des) select '1', 'pos_pda: PDA�������еĲ������д�'
//if exists(select 1 from pos_pda where regcode not in(select regcode from pos_reg))
//	insert #syscheck_result(flag,des) select '1', 'pos_pda: PDA�������е�������д�'
//---------------
//-- pos_station
//---------------
//if exists(select 1 from pos_station where posno not in(select posno from pos_posdef))
//	insert #syscheck_result(flag,des) select '1', 'pos_posdef: ���ڹ���վ����û�ж�Ӧ�������㶨��'
//---------------
//-- pos other
//---------------
//if exists(select 1 from pos_plu_rela where store_id not in(select id from pos_store_plu))
//	insert #syscheck_result(flag,des) select '1', 'pos_plu_rela: ��Ʒ����Ʒ��Ӧ��ϵ���в����ڵ���Ʒ��'
//if exists(select 1 from pos_plu_rela where plu_id not in(select id from pos_plu_all))
//	insert #syscheck_result(flag,des) select '1', 'pos_plu_rela: ��Ʒ����Ʒ��Ӧ��ϵ���в����ڵĲ�Ʒ��'
//
//if exists(select 1 from pos_tblsta where pccode not in(select pccode from pos_pccode))
//	insert #syscheck_result(flag,des) select '1', 'pos_tblsta: ������Ч������������Ŷ���'
//if exists(select 1 from pos_tblsta where mapcode not in(select code from pos_mapcode))
//	insert #syscheck_result(flag,des) select '1', 'pos_tblsta: ������Ч��λͼ��������Ŷ���'
//
//if exists(select 1 from pos_int_pccode where class = '2' and pos_pccode not in(select pccode from pos_pccode))
//	insert #syscheck_result(flag,des) select '1', 'pos_int_pccode: ������Ч��������Ĳͱ�����붨��'
//if exists(select 1 from pos_int_pccode where class = '2' and pccode not in(select pccode from pccode))
//	insert #syscheck_result(flag,des) select '1', 'pos_int_pccode: ������Ч�����붨��Ĳͱ�����붨��'


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
insert #syscheck_result(flag,des) select '0', '. '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '. �ӿڲ���'
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'

//insert #syscheck_result(flag,des) select '1', 'phextroom: ����ĵ绰�ֻ�δ���� - ' + roomno
//	from rmsta where roomno not in (select roomno from phextroom)
//insert #syscheck_result(flag,des) select '1', 'phcoden: ���ڻ������δ������ - ' + code+':'+address
//	from phcoden where groupno not in (select groupno from phcodeg)
//insert #syscheck_result(flag,des) select '1', 'phcoden: ���ڵ�ַδ������ - ' + code
//	from phcoden where rtrim(address) is null

//if exists(select 1 from interface_option a,interface b where a.groupid = b.groupid and a.interface_id = b.id 
//	and charindex('�绰�Ʒ�',b.descript) > 0 and a.descript = 'empty_select' and value = '1')
//	begin
//	if not exists(select 1 from master where accnt = (select rtrim(value) from sysoption where catalog = 'phone' and 
//		item = 'empty_accnt') and sta = 'I')
//		insert #syscheck_result(flag,des) select '1', 'sysoption: ©���Զ�ת���˺�δ����,���ʺ�����!'
//	end
//if not exists(select 1 from interface_option a,interface b where a.groupid = b.groupid and a.interface_id = b.id 
//	and charindex('�绰�Ʒ�',b.descript) > 0 and a.descript = 'device_type' )
//	insert #syscheck_result(flag,des) select '1', 'interface_option: �̿ؽ������豸�ͺ�δ����'
//if exists(select 1 from interface where charindex('�绰�Ʒ�',descript) > 0 and (svr_ip = '' or svr_ip is null))
//	and not exists(select 1 from interface_option a,interface b where a.groupid = b.groupid and a.interface_id = b.id 
//	and charindex('�绰�Ʒ�',b.descript) > 0 and a.descript = 'server_ip' and a.value <> '' and a.value is not null)
//	insert #syscheck_result(flag,des) select '1', 'interface_option: �������е绰�Ʒѽӿڵķ�������ַδ����'
//
//if exists(select 1 from phcoden where basesnd <= 0 or stepsnd <= 0 or grpsnd <= 0)
//	insert #syscheck_result(flag,des) select '1', 'phcoden: �𲽻򲽳��Լ��ƴ�ʱ�䲻����С��0������phcoden'
//if exists(select 1 from phncls where basesnd <= 0 or stepsnd <= 0 or grpsnd <= 0)
//	insert #syscheck_result(flag,des) select '1', 'phncls: �𲽻򲽳��Լ��ƴ�ʱ�䲻����С��0������phncls'
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
insert #syscheck_result(flag,des) select '0', '. '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '. ��������� '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
insert #syscheck_result(flag,des) select '0', '. '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '. �������� '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- ---------------------------------------------------------------------------------------
--	Ĭ�ϲ������ü�� hbb 2006.12.29 һЩ��Ҫ��Ĭ��ֵ
-- ---------------------------------------------------------------------------------------
insert #syscheck_result(flag,des) select '1', '����Ĭ�ϵ��г��� - ' + defaultvalue + ' ������'
	from sysdefault where columnname = 'market' and rtrim(defaultvalue) is not null and rtrim(defaultvalue) not in ( select code from mktcode )
insert #syscheck_result(flag,des) select '1', '����Ĭ�ϵ���Դ�� - ' + defaultvalue + ' ������'
	from sysdefault where columnname = 'src' and rtrim(defaultvalue) not in ( select code from srccode )
insert #syscheck_result(flag,des) select '1', '����Ĭ�ϵ�Ԥ������ - ' + defaultvalue + ' ������'
	from sysdefault where columnname = 'restype' and rtrim(defaultvalue) is not null and rtrim(defaultvalue) not in ( select code from restype )

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
-- ---------------------------------------------------------------------------------------
--	Message
-- ---------------------------------------------------------------------------------------
if not exists(select 1 from message_notify_type)
	insert #syscheck_result(flag,des) select '1', 'message_notify_type: δ�����κ���Ϣ����'
if not exists(select 1 from sysoption where catalog='hotel' and item='message_x')
	insert sysoption (catalog,item,value) select 'hotel','message_x','90'
if not exists(select 1 from sysoption where catalog='hotel' and item='dpbserver_port')
	insert sysoption (catalog,item,value) select 'hotel','dpbserver_port','20022'

if not exists(select 1 from sysoption where catalog='hotel' and item='dpbserver_pcid')
	insert sysoption (catalog,item,value) select 'hotel','dpbserver_pcid',''
if not exists(select 1 from sysoption where catalog='hotel' and item='dpbserver_pcid' and value <> '')
	insert #syscheck_result(flag,des) select '1', 'sysoption(hotel,dpbserver_pcid): δ������Ϣ������pc_id'

if not exists(select 1 from sysoption where catalog='hotel' and item='leaveword_pc')
	insert sysoption (catalog,item,value) select 'hotel','leaveword_pc',''

if not exists(select 1 from sysoption where catalog='hotel' and item='trace_canundo')
	insert sysoption (catalog,item,value) select 'hotel','trace_canundo','F'

if not exists(select 1 from sysoption where catalog='hotel' and item='leaveword_pc' and value <> '')
	insert #syscheck_result(flag,des) select '1', 'sysoption(hotel,leaveword_pc): δ����ʵʱ��ӡ���Դ�ӡ����վip��ַ��һ��Ϊ�����'

if not exists(select 1 from sysoption where catalog='house' and item='checkroom_sound')
	insert sysoption (catalog,item,value) select 'house','checkroom_sound','F'

if not exists(select 1 from sysoption where catalog='house' and item='checkroom_sound' and value <> '')
	insert #syscheck_result(flag,des) select '1', 'sysoption(house,checkroom_sound): δ����ͷ����Ĳ鷿������ʾ�ļ�'

-- ---------------------------------------------------------------------------------------
--	CRS
-- ---------------------------------------------------------------------------------------
if not exists(select 1 from sysoption where catalog='hotel' and item='crs_using')
	insert sysoption (catalog,item,value) select 'hotel','crs_using','false'
if exists(select 1 from sysoption where catalog='hotel' and item='crs_using' and value='true')
begin
	if not exists(select 1 from sysoption where catalog='hotel' and item='dpbserver_ntf_crsdept')
		insert sysoption (catalog,item,value) select 'hotel','dpbserver_ntf_crsdept',''
	if not exists(select 1 from sysoption where catalog='hotel' and item='dpbserver_ntf_newcrs')
		insert sysoption (catalog,item,value) select 'hotel','dpbserver_ntf_newcrs','300'
	if not exists(select 1 from sysoption where catalog='hotel' and item='dpbserver_ntf_timer')
		insert sysoption (catalog,item,value) select 'hotel','dpbserver_ntf_timer','300'

	if not exists(select 1 from sysoption where catalog='hotel' and item='dpbserver_ntf_crsdept' and value <> '')
		insert #syscheck_result(flag,des) select '1', 'sysoption(hotel,dpbserver_ntf_crsdept): δ����CRSԤ��֪ͨ��Ϣ���ղ���'

end
-- ---------------------------------------------------------------------------------------
--	email
-- ---------------------------------------------------------------------------------------
if not exists(select 1 from sysoption where catalog='hotel' and item='email_mode')
	insert sysoption (catalog,item,value) select 'hotel','email_mode','pbmail'

if not exists(select 1 from sysoption where catalog='hotel' and item='mail_attachment_maxsize')
	insert sysoption (catalog,item,value) select 'hotel','mail_attachment_maxsize','10'
-- ---------------------------------------------------------------------------------------
--	theme
-- ---------------------------------------------------------------------------------------
if not exists(select 1 from sysoption where catalog='hotel' and item='backupcolor_self')
	insert sysoption (catalog,item,value) select 'hotel','backupcolor_self','T'

if not exists(select 1 from sysoption where catalog='hotel' and item='theme_using')
	insert sysoption (catalog,item,value) select 'hotel','theme_using','F'

-- ---------------------------------------------------------------------------------------
--	afterlogin/ notice
-- ---------------------------------------------------------------------------------------
if not exists(select 1 from sysoption where catalog='hotel' and item='afterlogin')
	insert sysoption (catalog,item,value) select 'hotel','afterlogin','F'

if not exists(select 1 from sysoption where catalog='hotel' and item='foxnotice')
	insert sysoption (catalog,item,value) select 'hotel','foxnotice','T'
-- ---------------------------------------------------------------------------------------
--	report
-- ---------------------------------------------------------------------------------------
if not exists(select 1 from sysoption where catalog='hotel' and item='report_width')
	insert sysoption (catalog,item,value) select 'hotel','report_width','80'
-- ---------------------------------------------------------------------------------------
--	dump
-- ---------------------------------------------------------------------------------------
if not exists(select 1 from sysoption where catalog='hotel' and item='dump_path')
	insert #syscheck_result(flag,des) select '2', 'sysoption(hotel,dump_path): δ�������ݿⱸ��·��'
if not exists(select 1 from sysoption where catalog='hotel' and item='dump_files')
	insert #syscheck_result(flag,des) select '2', 'sysoption(hotel,dump_files): δ�������ݿⱸ�ݷָ��ļ���'
-- ---------------------------------------------------------------------------------------
--	genput
-- ---------------------------------------------------------------------------------------
if not exists(select 1 from sysoption where catalog='genput' and item='def_font')
	insert sysoption (catalog,item,value) select 'genput','def_font','����;����_GB2312;����;'
if not exists(select 1 from sysoption where catalog='genput' and item='title_font')
	insert sysoption (catalog,item,value) select 'genput','title_font','font.height="-12" font.italic="0"'

-- ---------------------------------------------------------------------------------------
--	ÿ�շ���
-- ---------------------------------------------------------------------------------------
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
insert #syscheck_result(flag,des) select '0', '. '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '. ÿ�շ��۹̶��ķ��۱䶯���� '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
if not exists(select 1 from reason where code ='ER')
	insert #syscheck_result(flag,des) select '1', 'δ����ÿ�շ���ר�õķ��۱䶯����--ER'

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

return 0
;
-- exec p_gds_maint_main;