if exists (select 1 from sysobjects where name='p_gds_maint_main')
   drop proc p_gds_maint_main;
create proc p_gds_maint_main
as
-- ---------------------------------------------------------------------------------------
-- 系统数据检测
-- 
-- --- 许多简单的错误，在检测的过程中自动清除
-- ---------------------------------------------------------------------------------------

-- 保存数据
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
insert #syscheck_result(flag,des) select '0', '检测开始......'
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'



--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
insert #syscheck_result(flag,des) select '0', '. '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '. 基础设置部分 '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
---------------
-- jierep
---------------
insert #syscheck_result(flag,des) select '2', 'jierep: 存在无对应费用码的 class = ' + class 
	from jierep where class not in (select distinct jierep from pccode where jierep<>'') 
						and rectype='B' and mode<>'E' and class not like '010%'
insert #syscheck_result(flag,des) select '2', 'jierep: 没有子项的 C 项 class = ' + a.class 
	from jierep a where a.class ='C' and not exists(select 1 from jierep b where a.class=b.toclass)
insert #syscheck_result(flag,des) select '1', 'jierep: toclass / rectype / toop 为空 class = ' + class 
	from jierep where class<>'999' and (rtrim(rectype) is null or rtrim(toop) is null or rtrim(toclass) is null)
---------------------
-- pccode - 公共部分
---------------------
insert #syscheck_result(flag,des) select '1', 'pccode: 无效的 argcode = ' + pccode + ' ' + descript + ' ' + isnull(argcode,'')
	from pccode where rtrim(argcode) is null or argcode not in (select argcode from argcode)
insert #syscheck_result(flag,des) select '1', 'pccode: Rebate & Reason 不匹配 = ' + pccode+' '+descript+' '+reason+' '+deptno8
	from pccode where deptno8='RB' and reason='F'
insert #syscheck_result(flag,des) select '1', 'pccode: Rebate & tail 不匹配 = ' + pccode+' '+descript+' '+tail+' '+deptno8
	from pccode where deptno8='RB' and tail<>'07'
insert #syscheck_result(flag,des) select '2', 'pccode: 非法的 tail = ' + pccode+' '+descript+' '+tail
	from pccode where rtrim(tail) is null or tail<'01' or tail>='1'
---------------------
-- pccode - 费用部分
---------------------
if not exists(select 1 from pccode where jierep like '010%' and tail='07' and commission=3 and argcode<'9')
	insert #syscheck_result(flag,des) select '2', 'pccode: 没有定义房费服务费代码,或者定义不正确'
insert #syscheck_result(flag,des) select '1', 'pccode: 无效的 jierep = ' + pccode+' '+descript+' '+jierep
	from pccode where argcode<'9' and jierep<>'010' and (rtrim(jierep) is null or jierep not in (select class from jierep))
insert #syscheck_result(flag,des) select '1', 'pccode: 同一个 pccode 有不同的 jierep = ' + a.pccode +' '+descript
	from pccode a where a.argcode<'9' and exists(select 1 from pccode b where a.pccode=b.pccode and b.jierep<>a.jierep)

insert #syscheck_result(flag,des) select '1', 'pccode: 非法的 deptno = ' + a.pccode+' '+a.descript+isnull(a.deptno,'')
	from pccode a where a.argcode<'9' and (rtrim(a.deptno) is null or a.deptno not in (select code from basecode where cat='chgcod_deptno'))
insert #syscheck_result(flag,des) select '1', 'pccode: 非法的 deptno1 = ' + a.pccode+' '+a.descript+isnull(a.deptno1,'')
	from pccode a where a.argcode<'9' and (rtrim(a.deptno1) is null or a.deptno1 not in (select code from basecode where cat='chgcod_deptno1'))
insert #syscheck_result(flag,des) select '1', 'pccode: 非法的 deptno2 = ' + a.pccode+' '+a.descript+isnull(a.deptno2,'')
	from pccode a where a.argcode<'9' and (rtrim(a.deptno2) is null or a.deptno2 not in (select code from basecode where cat='chgcod_deptno2'))
insert #syscheck_result(flag,des) select '1', 'pccode: 非法的 deptno3 = ' + a.pccode+' '+a.descript+isnull(a.deptno3,'')
	from pccode a where a.argcode<'9' and (rtrim(a.deptno3) is null or a.deptno3 not in (select code from basecode where cat='chgcod_deptno3'))
insert #syscheck_result(flag,des) select '1', 'pccode: 非法的 deptno4 = ' + a.pccode+' '+a.descript+isnull(a.deptno4,'')
	from pccode a where a.argcode<'9' and (rtrim(a.deptno4) is null or a.deptno4 not in (select code from basecode where cat='chgcod_deptno4'))
insert #syscheck_result(flag,des) select '1', 'pccode: 非法的 deptno5 = ' + a.pccode+' '+a.descript+isnull(a.deptno5,'')  -- 适用范围 AFP 
	from pccode a where a.argcode<'9' 
		and ( rtrim(a.deptno5) is null 
			or (substring(a.deptno5,1,1)<>'' and substring(a.deptno5,1,1) not in ('A','F','P'))
			or (substring(a.deptno5,2,1)<>'' and substring(a.deptno5,2,1) not in ('A','F','P'))
			or (substring(a.deptno5,3,1)<>'' and substring(a.deptno5,3,1) not in ('A','F','P'))
			) 
		
insert #syscheck_result(flag,des) select '1', 'pccode: 非法的 deptno6 = ' + a.pccode+' '+a.descript+isnull(a.deptno6,'')
	from pccode a where a.argcode<'9' and (rtrim(a.deptno6) is null or a.deptno6 not in (select code from basecode where cat='chgcod_deptno6'))
insert #syscheck_result(flag,des) select '1', 'pccode: 非法的 deptno7 = ' + a.pccode+' '+a.descript+isnull(a.deptno7,'')
	from pccode a where a.argcode<'9' and (rtrim(a.deptno7) is null or a.deptno7 not in (select code from basecode where cat='chgcod_deptno7'))
--  deptno8 --> rebate define 
--insert #syscheck_result(flag,des) select '1', 'pccode: 非法的 deptno8 = ' + a.pccode+' '+a.descript+isnull(a.deptno8,'')
--	from pccode a where a.argcode<'9' and (rtrim(a.deptno8) is null or a.deptno8 not in (select code from basecode where cat='chgcod_deptno8'))

---------------------
-- pccode - 付款部分
---------------------
insert #syscheck_result(flag,des) select '1', 'pccode: 无效的付款 deptno = ' + pccode+' '+descript+' '+deptno
	from pccode where argcode>='9' and (rtrim(deptno) is null or deptno not in (select code from basecode where cat='paymth_deptno'))
insert #syscheck_result(flag,des) select '1', 'pccode: 无效的付款 deptno1 = ' + pccode+' '+descript+' '
	from pccode where argcode>='9' and rtrim(deptno1) is null 
insert #syscheck_result(flag,des) select '1', 'pccode: 重复的付款 deptno1 = ' + a.pccode+' '+a.descript+' '+a.deptno1
	from pccode a where a.argcode>='9' and exists(select 1 from pccode b where a.pccode<>b.pccode and a.deptno1=b.deptno1)
insert #syscheck_result(flag,des) select '1', 'pccode: 重复的付款 deptno2 = ' + a.pccode+' '+a.descript+' '+a.deptno1
	from pccode a where a.argcode>='9' and exists(select 1 from pccode b where a.pccode<>b.pccode and a.deptno2=b.deptno2)
insert #syscheck_result(flag,des) select '1', 'pccode: 折扣类付款 reason error = ' + a.pccode+' '+a.descript+' '+a.reason
	from pccode a where a.argcode>='9' and a.deptno='H' and a.reason<>'T'
insert #syscheck_result(flag,des) select '1', 'pccode: 非折扣类付款 reason error = ' + a.pccode+' '+a.descript+' '+a.reason
	from pccode a where a.argcode>='9' and a.deptno<>'H' and a.reason='T'
insert #syscheck_result(flag,des) select '1', 'pccode: 信用卡类付款 no ISC flag = ' + a.pccode+' '+a.descript+' '+a.deptno4
	from pccode a where a.argcode>='9' and a.deptno in ('C','D') and a.deptno4<>'ISC'
insert #syscheck_result(flag,des) select '1', 'pccode: 非信用卡类付款 has ISC flag = ' + a.pccode+' '+a.descript+' '+a.deptno4
	from pccode a where a.argcode>='9' and a.deptno not in ('C','D') and a.deptno4='ISC'
insert #syscheck_result(flag,des) select '1', 'pccode: 不能作为定金 = ' + a.pccode+' '+a.descript
	from pccode a where a.argcode>='9' and a.deptno >='G' and a.deptno3='98'
if not exists(select 1 from sysoption where catalog='hotel' and item='lic_buy.1' and charindex(',nar,', value)>0)
	insert #syscheck_result(flag,des) select '1', 'pccode: 不能作为前台结帐 = ' + a.pccode+' '+a.descript
		from pccode a where a.argcode>='9' and a.deptno >='I' and a.deptno6='99'
insert #syscheck_result(flag,des) select '1', 'pccode: 外币对应代码错误 = ' + a.pccode+' '+a.descript+' '+a.deptno7
	from pccode a where a.argcode>='9' and a.deptno7<>'' and a.deptno7 not in (select code from fec_def)
insert #syscheck_result(flag,des) select '1', 'pccode: POS折扣对应代码错误 = ' + a.pccode+' '+a.descript+' '+a.deptno8
	from pccode a where a.argcode>='9' and a.deptno8<>'' and a.deptno8 not in (select code from pos_namedef)
insert #syscheck_result(flag,des) select '1', 'pccode: pos_item对应代码错误 = ' + a.pccode+' '+a.descript+' '+a.pos_item
	from pccode a where a.argcode>='9' and a.pos_item<>'' and a.pos_item not in (select code from pos_namedef)

if ( exists(select 1 from sysoption where catalog='hotel' and item='lic_buy.1' and charindex('vippts', value)>0 )
	or exists(select 1 from sysoption where catalog='hotel' and item='lic_buy.2' and charindex('vippts', value)>0 ) )
	and not exists(select 1 from pccode where argcode>'9' and deptno2='PTS')
	insert #syscheck_result(flag,des) select '2', '系统启用了积分功能，但是没有设置积分付款方式'


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
insert #syscheck_result(flag,des) select '0', '. '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '. 预订接待部分 '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
update typim set quantity =(select count(1) from rmsta where rmsta.type=typim.type)
insert #syscheck_result(flag,des) select '1', '禁止使用的房类代码：'+type from typim where type='TEN'
if exists(select 1 from typim where gtype not in (select code from gtype))
	insert #syscheck_result(flag,des) select '1', '房类定义：有不存在的大房类'
if exists(select 1 from rmsta where roomno>='A')
	insert #syscheck_result(flag,des) select '1', '房号定义：房号不能有字母'
if exists(select 1 from rmsta where charindex(' ',roomno)>0)
	insert #syscheck_result(flag,des) select '1', '房号定义：房号中间不能有空格'
if exists(select 1 from rmsta where type not in (select type from typim))
	insert #syscheck_result(flag,des) select '1', '房号定义：有不存在的房类'
if exists(select 1 from rmsta where flr not in (select code from flrcode))
	insert #syscheck_result(flag,des) select '1', '房号定义：有不存在的楼层'
if exists(select 1 from rmsta where hall not in (select code from basecode where cat='hall'))
	insert #syscheck_result(flag,des) select '1', '房号定义：有不存在的楼层'

if exists(select 1 from mktcode where jierep not in (select class from jierep))
	insert #syscheck_result(flag,des) select '1', '市场码定义 jierep error'
if exists(select 1 from mktcode where rtrim(grp) is null or (grp<>'' and grp not in (select code from basecode where cat='market_cat')))
	insert #syscheck_result(flag,des) select '1', '市场码定义 grp error'
if exists(select 1 from srccode where rtrim(grp) is null or (grp<>'' and grp not in (select code from basecode where cat='src_cat')))
	insert #syscheck_result(flag,des) select '1', '来源码定义 grp error'
if not exists(select 1 from mktcode where flag='HSE')
	insert #syscheck_result(flag,des) select '2', '市场码定义: 没有定义自用房市场码 '
if not exists(select 1 from mktcode where flag='COM')
	insert #syscheck_result(flag,des) select '2', '市场码定义: 没有定义免费房市场码 '
if not exists(select 1 from mktcode where flag='LON')
	insert #syscheck_result(flag,des) select '2', '市场码定义: 没有定义长包房市场码 '

-- sysdefault extra - 楼号检测 
if exists(select 1 from sysdefault where columnname='extra' and char_length(rtrim(defaultvalue))=15
	and substring(defaultvalue,2,1) not in (select code from basecode where cat='hall')) 
	insert #syscheck_result(flag,des) select '1', '主单缺省值定义: 楼号定义有问题 '


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
insert #syscheck_result(flag,des) select '0', '. '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '. 收银审核部分 '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
---------------------
-- package
---------------------
insert #syscheck_result(flag,des) select '1', 'package: 非法的 pccode = '+code+' '+descript+' '+isnull(pccode,'')
	from package where rtrim(pccode) is null or (rtrim(pccode) is null and pccode not in (select pccode from pccode where argcode<'9'))
insert #syscheck_result(flag,des) select '1', 'package: 非法的 pos_pccode = '+code+' '+descript+' '+pos_pccode
	from package where rtrim(pos_pccode) is not null and pos_pccode not in (select pccode from pccode where argcode<'9')
insert #syscheck_result(flag,des) select '1', 'package: 非法的对应消费帐户 = '+code+' '+descript+' '+accnt
	from package where rtrim(accnt) is not null and accnt not in (select accnt from master where class='C')
insert #syscheck_result(flag,des) select '1', 'package: credit < amount '+code+' '+descript
	from package where credit<>0 and credit<amount 
insert #syscheck_result(flag,des) select '1', 'package: 类别非法的 package_type = '+code+' '+descript+' '+isnull(grp,'')
	from basecode where cat='package_type' and (grp='' or grp not in ('BF','FB','SVC','TAX','LAU')) 
---------------------
-- artag1
---------------------
insert #syscheck_result(flag,des) select '1', 'Basecode: artag1 grp error = '+code+' '+descript+' '+grp
	from basecode where cat='artag1' and (grp='' or grp not in (select code from basecode where cat='argrp1'))
---------------------
-- bankcode
---------------------
insert #syscheck_result(flag,des) select '1', 'pccode: 未定义刷卡行 = ' + a.pccode+' '+a.descript
	from pccode a where a.argcode>='9' and a.deptno in ('C','D') and pccode not in (select pccode from bankcard)
insert #syscheck_result(flag,des) select '1', 'bankcard: 错误的刷卡行 = ' + bankcode
	from bankcard where bankcode not in (select code from basecode where cat='bankcode')



--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
insert #syscheck_result(flag,des) select '0', '. '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '. 公关销售部分 '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
if exists(select 1 from basecode where cat='guest_class' and code not in ('F','G','C','A','S','R','H'))
	insert #syscheck_result(flag,des) select '1', '客户档案类别不能随意添加'
if exists(select 1 from basecode where cat='guest_type' and code not in ('N','B','C','R'))
	insert #syscheck_result(flag,des) select '1', '客户档案附加类别不能随意添加'
if exists(select 1 from saleid where grp not in (select code from salegrp))
	insert #syscheck_result(flag,des) select '1', '销售员类别有问题'
if exists(select 1 from saleid where empno<>'' and empno not in (select empno from sys_empno))
	insert #syscheck_result(flag,des) select '1', '销售员对应电脑工号错误'

delete rmratecode_link where code not in (select code from rmratecode)
delete rmratecode_link where rmcode not in (select code from rmratedef)
if exists(select 1 from rmratedef where market<>'' and market not in (select code from mktcode))
	insert #syscheck_result(flag,des) select '1', '房价明细定义: 包含无效市场码'
if exists(select 1 from rmratedef where src<>'' and src not in (select code from srccode))
	insert #syscheck_result(flag,des) select '1', '房价明细定义: 包含无效来源码'
if exists(select 1 from rmratecode where cat='' or (cat<>'' and cat not in (select code from basecode where cat='rmratecat')))
	insert #syscheck_result(flag,des) select '1', '房价码定义: 包含无效类别'
if exists(select 1 from rmratecode where market<>'' and market not in (select code from mktcode))
	insert #syscheck_result(flag,des) select '1', '房价码定义: 包含无效市场码'
if exists(select 1 from rmratecode where src<>'' and src not in (select code from srccode))
	insert #syscheck_result(flag,des) select '1', '房价码定义: 包含无效来源码'

if not exists(select 1 from basecode where cat='guestcard_cat' and code='CC')
	insert #syscheck_result(flag,des) select '1', 'Basecode - guestcard_cat: 没有信用卡类别 CC'
if exists(select 1 from guest_card_type where cat='' or (cat<>'' and cat not in (select code from basecode where cat='guestcard_cat')))
	insert #syscheck_result(flag,des) select '1', 'Guest_card_type : 包含无效类别'

--<<<  注意这里的写法，一个可以，一个不可以  simon  2006.3.14 
--insert #syscheck_result(flag,des) select '1', 'Guest_card_type: 费用码 pccodes 定义重复 = ' + b.pccode 
--	from guest_card_type a, pccode b 
--		where a.pccodes<>'' and charindex(','+rtrim(b.pccode)+',', ','+rtrim(a.pccodes)+',')>0
--			group by b.pccode having count(1)>1
if exists(select 1 from guest_card_type a, pccode b 
		where a.pccodes<>'' and charindex(','+rtrim(b.pccode)+',', ','+rtrim(a.pccodes)+',')>0
			group by b.pccode having count(1)>1)
	insert #syscheck_result(flag,des) select '1', 'Guest_card_type: 存在费用码 pccodes 定义重复'
insert #syscheck_result(flag,des) select '1', 'pccode: 信用卡代码没有定义到 guest_card_type -'+a.pccode
	from pccode a where a.deptno4='ISC' and not exists(select 1 from guest_card_type b where charindex(a.pccode,b.pccodes)>0)

--->>>


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
insert #syscheck_result(flag,des) select '0', '. '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '. BOS 部分 '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
update bos_pccode set jxc=1 where tag='S' and jxc<>1
if exists(select 1 from bos_pccode where chgcod='' or (chgcod<>'' and chgcod not in (select pccode from pccode)))
	insert #syscheck_result(flag,des) select '1', 'Bos_pccode : 包含无效费用码 chgcod'
if exists(select 1 from bos_pccode where site0='' or (site0<>'' and site0 not in (select site from bos_site)))
	insert #syscheck_result(flag,des) select '1', 'Bos_pccode : 包含无效费用码 site0'
if exists(select 1 from bos_pccode where smode<>'0' and smode<>'1')
	insert #syscheck_result(flag,des) select '1', 'Bos_pccode : 服务费模式错误'
if exists(select 1 from bos_pccode where tmode<>'0' and tmode<>'1')
	insert #syscheck_result(flag,des) select '1', 'Bos_pccode : 附加费模式错误'
if exists(select 1 from bos_pccode where dmode<>'0' and dmode<>'1')
	insert #syscheck_result(flag,des) select '1', 'Bos_pccode : 折扣模式错误'

delete bos_site where pccode not in (select pccode from bos_pccode)
delete bos_site_sort where site not in (select site from bos_site)
delete bos_station where posno not in (select posno from bos_posdef)
update bos_posdef set def='T' where rtrim(def) is null or (def<>'T' and def<>'F')

if exists(select 1 from bos_extno where posno='' or (posno<>'' and posno not in (select posno from bos_posdef)))
	insert #syscheck_result(flag,des) select '1', 'Bos_extno : 包含无效 posno'
if exists(select 1 from bos_posdef where pccodes='' or sites='')
	insert #syscheck_result(flag,des) select '1', 'Bos_posno : 包含无效 pccodes or sites'

if exists(select 1 from bos_posdef where modu='03')
	and (select count(1) from bos_posdef where def='T' and modu='03') <> 1
	insert #syscheck_result(flag,des) select '1', 'Bos_posdef : 客房中心缺省收银点必须设置，也只能设置一个'
if exists(select 1 from bos_posdef where modu='06')
	and (select count(1) from bos_posdef where def='T' and modu='06') <> 1
	insert #syscheck_result(flag,des) select '1', 'Bos_posdef : 商务中心缺省收银点必须设置，也只能设置一个'
if exists(select 1 from bos_posdef where modu='07')
	and (select count(1) from bos_posdef where def='T' and modu='07') <> 1
	insert #syscheck_result(flag,des) select '1', 'Bos_posdef : 商场缺省收银点必须设置，也只能设置一个'

insert #syscheck_result(flag,des) select '1', 'Bos_poscode : 商场必须设置 tag = S : ' + a.pccode
	from bos_pccode a, bos_posdef b where b.modu='09' and charindex(','+rtrim(a.pccode)+',', ','+rtrim(b.pccodes)+',') > 0 and a.tag<>'S'

insert #syscheck_result(flag,des) select '1', 'Bos_poscode : 商场必须设置进销存功能 : ' + a.pccode
	from bos_pccode a, bos_posdef b where b.modu='09' and charindex(','+rtrim(a.pccode)+',', ','+rtrim(b.pccodes)+',') > 0 and a.jxc<>1

insert #syscheck_result(flag,des) select '1', 'Bos_poscode : 商场必须至少设置一个仓库 : ' + a.pccode
	from bos_pccode a, bos_posdef b where b.modu='09' and charindex(','+rtrim(a.pccode)+',', ','+rtrim(b.pccodes)+',') > 0
		and not exists (select 1 from bos_site c where a.pccode=c.pccode and c.tag='仓')

insert #syscheck_result(flag,des) select '0', ''
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '电话计费部分'
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
--ADD BY ZK 2006.8.1
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
if exists(select 1 from rmsta where roomno not in (select roomno from phextroom))
	insert #syscheck_result(flag,des) select '1', 'phextroom: 某一房间的电话分机未定义'
--if exists(select 1 from phcoden where groupno not in (select groupno from phcodeg))
--	insert #syscheck_result(flag,des) select '1', 'phcoden: 存在话费组别未定义项'
if exists (select 1 from phdeptdef where dept not in (select dept from phdeptdex)) or exists(select 1 from phdeptdef where dept not in (select dept from phdepthis))  or exists(select 1 from phdepthis where dept not in (select dept from phdeptdex))
   insert #syscheck_result(flag,des) select '1', 'phdeptdef，phdeptdex，phdepthis三张表数据不符，请检查！'
if exists(select 1 from phdeptroom where room not in (select roomno from phextroom) )
if exists(select 1 from phextroom where rgid='')
   insert #syscheck_result(flag,des) select '1', 'phdeptroom中有号码未定义组别，请检查！'
if exists(select 1 from phcodeg where (rate1<>0 and rate2<>0) and (basesnd=stepsnd) )
   insert #syscheck_result(flag,des) select '1', 'phcodeg表中当basesnd=stepsnd时rate2是否有必要设置？'
if ((select count(*)  from phcoden)+(select count(*) from phncls)<>(select count(*) from phparms_setup))
   insert #syscheck_result(flag,des) select '1', 'phparms_setup表中记录<>phcoden与phncls记录之和，请检查是否有缺失'
if exists(select 1 from phcoden where pgid = '' or pgid is null)
	insert #syscheck_result(flag,des) select '1', 'phcoden: 存在被叫号码未分组，phcoden表字段pgid为空'
if exists(select 1 from phcoden where descript = '' or descript is null)
	insert #syscheck_result(flag,des) select '1', 'phcoden: 存在被叫号码归属地未定义项'
if exists(select 1 from phparms where pvalue = '' or svalue='' or cutfee='')
	insert #syscheck_result(flag,des) select '1', 'phparms: 计费项目不完整pvalue = '' or svalue='' or cutfee=''请检查'


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
insert #syscheck_result(flag,des) select '0', '. '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '. POS 部分 '
insert #syscheck_result(flag,des) select '0', ''
insert #syscheck_result(flag,des) select '0', '  请在POS系统使用相关检测功能，这里省略'
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//---------------
//-- pos_pccode
//---------------
//if exists(select 1 from pos_pccode where rtrim(chgcod) is null or chgcod not in(select pccode from pccode))
//	insert #syscheck_result(flag,des) select '1', 'pos_pccode: chgcod 餐厅和费用码对应关系有错'
//if exists(select 1 from pos_pccode where rtrim(mode) is null)
//	insert #syscheck_result(flag,des) select '1', 'pos_pccode: 没有定义缺省模式'
//if exists(select 1 from pos_pccode where rtrim(mode) is not null and mode not in(select code from pos_mode_name))
//	insert #syscheck_result(flag,des) select '1', 'pos_pccode: 餐厅中有些缺省模式不存在'
//if exists(select 1 from pos_pccode where rtrim(dec_mode)  is not null and rtrim(dec_code) is null)
//	insert #syscheck_result(flag,des) select '1', 'pos_pccode: 有 取整要求, 但没有定义 零头码'
//if exists(select 1 from pos_pccode where rtrim(dec_code) is not null and dec_code not in(select convert(char(10),id) from pos_plu_all))
//	insert #syscheck_result(flag,des) select '1', 'pos_pccode: 零头码不存在'
//---------------
//-- pos_namedef
//---------------
//if exists(select 1 from  pos_namedef a, pos_namedef b where a.code = b.code and a.descript <> b.descript)
//	or exists(select 1 from  pos_namedef a, pos_namedef b where a.code = b.code and a.descript1 <> b.descript1)
//	insert #syscheck_result(flag,des) select '1', 'pos_namedef: 不同部门相同代码描述必须一样'
//if not exists(select 1 from pos_namedef where code = '602' and descript = '<赠送>')
//	insert #syscheck_result(flag,des) select '1', 'pos_namedef: code = 602 必须为 <赠送>'
//if not exists(select 1 from pos_namedef where code = '605' and descript = '<全免>')
//	insert #syscheck_result(flag,des) select '1', 'pos_namedef: code = 605 必须为 <全免>'
//if not exists(select 1 from pos_namedef where code = '607' and descript = '<单菜折扣>')
//	insert #syscheck_result(flag,des) select '1', 'pos_namedef: code = 607 必须为 <单菜折扣>'
//if not exists(select 1 from pos_namedef where code = '610' and descript = '百分比折扣')
//	insert #syscheck_result(flag,des) select '1', 'pos_namedef: code = 610 必须为 百分比折扣'
//if not exists(select 1 from pos_namedef where code = '620' and descript = '特优码折扣')
//	insert #syscheck_result(flag,des) select '1', 'pos_namedef: code = 620 必须为 特优码折扣'
//if not exists(select 1 from pos_namedef where code = '650' and descript = '事后折扣')
//	insert #syscheck_result(flag,des) select '1', 'pos_namedef: code = 650 必须为 事后折扣'
//if not exists(select 1 from pos_namedef where code = '099' )
//	insert #syscheck_result(flag,des) select '1', 'pos_namedef: 没有定义 code = 099 (<未定义>) 项'
//if not exists(select 1 from pos_namedef where code = '099' and descript = '<未定义>')
//	insert #syscheck_result(flag,des) select '1', 'pos_namedef: code = 099 必须为 <未定义>'
//---------------
//-- pos_itemdef
//---------------
//delete pos_itemdef where pccode not in (select pccode from pos_pccode)
//delete pos_itemdef where code not in (select code from pos_namedef)
//if exists(select 1 from pos_pccode where pccode not in(select pccode from pos_itemdef))
//	insert #syscheck_result(flag,des) select '1', 'pos_itemdef: 有些餐厅代码itemdef 没有定义 -' + pccode from pos_pccode where pccode not in (select distinct pccode from pos_itemdef)
//if exists(select 1 from pos_itemdef a, pos_pccode b, pccode c  where a.pccode = b.pccode and b.chgcod = c.pccode and a.jierep <> c.jierep)
//	insert #syscheck_result(flag,des) select '1', 'pos_itemdef: 注意存在 jierep <> pccode.jierep'
//if exists(select 1 from pos_itemdef where rtrim(jierep) is null or jierep not in (select class from jierep))
//	insert #syscheck_result(flag,des) select '1', 'pos_itemdef: '+pos_itemdef.pccode+pos_itemdef.jierep+' 存在无效jierep数据定义' from pos_itemdef where jierep not in(select class from jierep)
//if exists(select 1 from pos_pccode a where exists(select 1 from pos_itemdef b where a.pccode = b.pccode  ) and not exists(select 1 from pos_itemdef c where a.pccode = c.pccode and c.code = '099' ))
//	insert #syscheck_result(flag,des) select '1',  'pos_itemdef: pccode=' + pccode +' 没有定义code=099' from pos_pccode a where exists(select 1 from pos_itemdef b where a.pccode = b.pccode  ) and not exists(select 1 from pos_itemdef c where a.pccode = c.pccode and c.code = '099' )
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
//insert #syscheck_result(flag,des) select '1',  'pos_itemdef: 菜谱没有定义:'+pccode +'--'+ plucode+sort+code+ltrim(rtrim(name1)) from #list
//
//---------------
//-- pos 厨房打印部分
//---------------
//if exists(select 1 from pos_printer where pcode not in(select code from pos_pserver))
//	insert #syscheck_result(flag,des) select '1', 'pos_printer: 存在没有定义有效打印服务器的打印机定义'
//if exists(select 1 from pos_kitchen where printer not in(select code from pos_printer))
//	insert #syscheck_result(flag,des) select '1', 'pos_kitchen: 存在没有定义有效打印机的厨房定义'
//if exists(select 1 from pos_prnscope where code not in(select code from pos_kitchen))
//	insert #syscheck_result(flag,des) select '1', 'pos_prnscope: 存在没有定义有效厨房菜码和厨房对应关系定义'
//---------------
//-- pos 菜谱定义
//---------------
//if exists(select 1 from pos_sort_all where plucode not in(select plucode from pos_plucode))
//	insert #syscheck_result(flag,des) select '1', 'pos_sort_all: 存在没有定义有效菜本的菜类定义'
//if exists(select 1 from pos_plu_all a where plucode + sort not in(select plucode + sort from pos_sort_all))
//	insert #syscheck_result(flag,des) select '1', 'pos_plu_all: 存在没有定义有效菜类的菜谱定义'
//if exists(select 1 from pos_std where std_id not in(select id from pos_plu_all) or id not in (select id from pos_plu_all))
//	insert #syscheck_result(flag,des) select '1', 'pos_std: 套菜定义里有无效菜存在（不在pos_plu_all中）'
//delete pos_plucode_link where pccode not in(select pccode from pos_pccode)
//if exists(select 1 from pos_pccode where pccode not in(select pccode from pos_plucode_link))
//	insert #syscheck_result(flag,des) select '1', 'pos_plucode_link: 有些餐厅没有定义对应菜本'
//---------------
//-- pos pda 
//---------------
//if exists(select 1 from pos_reg where pccode not in(select pccode from pos_pccode))
//	insert #syscheck_result(flag,des) select '1', 'pos_reg: PDA区域定义中有的餐厅号有错'
//if exists(select 1 from pos_pda where pccode not in(select pccode from pos_pccode))
//	insert #syscheck_result(flag,des) select '1', 'pos_pda: PDA定义中有的餐厅号有错'
//if exists(select 1 from pos_pda where regcode not in(select regcode from pos_reg))
//	insert #syscheck_result(flag,des) select '1', 'pos_pda: PDA定义中有的区域号有错'
//---------------
//-- pos_station
//---------------
//if exists(select 1 from pos_station where posno not in(select posno from pos_posdef))
//	insert #syscheck_result(flag,des) select '1', 'pos_posdef: 存在工作站定义没有对应的收银点定义'
//---------------
//-- pos other
//---------------
//if exists(select 1 from pos_plu_rela where store_id not in(select id from pos_store_plu))
//	insert #syscheck_result(flag,des) select '1', 'pos_plu_rela: 菜品和物品对应关系中有不存在的物品码'
//if exists(select 1 from pos_plu_rela where plu_id not in(select id from pos_plu_all))
//	insert #syscheck_result(flag,des) select '1', 'pos_plu_rela: 菜品和物品对应关系中有不存在的菜品码'
//
//if exists(select 1 from pos_tblsta where pccode not in(select pccode from pos_pccode))
//	insert #syscheck_result(flag,des) select '1', 'pos_tblsta: 存在无效餐厅定义的桌号定义'
//if exists(select 1 from pos_tblsta where mapcode not in(select code from pos_mapcode))
//	insert #syscheck_result(flag,des) select '1', 'pos_tblsta: 存在无效餐位图定义的桌号定义'
//
//if exists(select 1 from pos_int_pccode where class = '2' and pos_pccode not in(select pccode from pos_pccode))
//	insert #syscheck_result(flag,des) select '1', 'pos_int_pccode: 存在无效餐厅定义的餐别费用码定义'
//if exists(select 1 from pos_int_pccode where class = '2' and pccode not in(select pccode from pccode))
//	insert #syscheck_result(flag,des) select '1', 'pos_int_pccode: 存在无效费用码定义的餐别费用码定义'


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
insert #syscheck_result(flag,des) select '0', '. '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '. 接口部分'
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'

//insert #syscheck_result(flag,des) select '1', 'phextroom: 房间的电话分机未定义 - ' + roomno
//	from rmsta where roomno not in (select roomno from phextroom)
//insert #syscheck_result(flag,des) select '1', 'phcoden: 存在话费组别未定义项 - ' + code+':'+address
//	from phcoden where groupno not in (select groupno from phcodeg)
//insert #syscheck_result(flag,des) select '1', 'phcoden: 存在地址未定义项 - ' + code
//	from phcoden where rtrim(address) is null

//if exists(select 1 from interface_option a,interface b where a.groupid = b.groupid and a.interface_id = b.id 
//	and charindex('电话计费',b.descript) > 0 and a.descript = 'empty_select' and value = '1')
//	begin
//	if not exists(select 1 from master where accnt = (select rtrim(value) from sysoption where catalog = 'phone' and 
//		item = 'empty_accnt') and sta = 'I')
//		insert #syscheck_result(flag,des) select '1', 'sysoption: 漏单自动转账账号未设置,或帐号有误!'
//	end
//if not exists(select 1 from interface_option a,interface b where a.groupid = b.groupid and a.interface_id = b.id 
//	and charindex('电话计费',b.descript) > 0 and a.descript = 'device_type' )
//	insert #syscheck_result(flag,des) select '1', 'interface_option: 程控交换机设备型号未设置'
//if exists(select 1 from interface where charindex('电话计费',descript) > 0 and (svr_ip = '' or svr_ip is null))
//	and not exists(select 1 from interface_option a,interface b where a.groupid = b.groupid and a.interface_id = b.id 
//	and charindex('电话计费',b.descript) > 0 and a.descript = 'server_ip' and a.value <> '' and a.value is not null)
//	insert #syscheck_result(flag,des) select '1', 'interface_option: 允许运行电话计费接口的服务器地址未设置'
//
//if exists(select 1 from phcoden where basesnd <= 0 or stepsnd <= 0 or grpsnd <= 0)
//	insert #syscheck_result(flag,des) select '1', 'phcoden: 起步或步长以及计次时间不允许小于0，请检查phcoden'
//if exists(select 1 from phncls where basesnd <= 0 or stepsnd <= 0 or grpsnd <= 0)
//	insert #syscheck_result(flag,des) select '1', 'phncls: 起步或步长以及计次时间不允许小于0，请检查phncls'
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
insert #syscheck_result(flag,des) select '0', '. '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '. 贵宾卡部分 '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
insert #syscheck_result(flag,des) select '0', '. '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '. 其他部分 '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- ---------------------------------------------------------------------------------------
--	默认参数设置检查 hbb 2006.12.29 一些重要的默认值
-- ---------------------------------------------------------------------------------------
insert #syscheck_result(flag,des) select '1', '主单默认的市场码 - ' + defaultvalue + ' 不存在'
	from sysdefault where columnname = 'market' and rtrim(defaultvalue) is not null and rtrim(defaultvalue) not in ( select code from mktcode )
insert #syscheck_result(flag,des) select '1', '主单默认的来源码 - ' + defaultvalue + ' 不存在'
	from sysdefault where columnname = 'src' and rtrim(defaultvalue) not in ( select code from srccode )
insert #syscheck_result(flag,des) select '1', '主单默认的预订类型 - ' + defaultvalue + ' 不存在'
	from sysdefault where columnname = 'restype' and rtrim(defaultvalue) is not null and rtrim(defaultvalue) not in ( select code from restype )

-- ---------------------------------------------------------------------------------------
--	EDP
-- ---------------------------------------------------------------------------------------
if not exists(select 1 from sysoption where catalog='hotel' and item='edp_group')
	insert sysoption (catalog,item,value) select 'hotel','edp_group',''

if not exists(select 1 from sysoption where catalog='hotel' and item='edp_group' and value <> '')
	insert #syscheck_result(flag,des) select '1', 'sysoption(hotel,edp_group): 未定义EDP所在用户组'
-- ---------------------------------------------------------------------------------------
--	DocMgr
-- ---------------------------------------------------------------------------------------
if not exists(select 1 from sysoption where catalog='hotel' and item='docftpserver')
	insert sysoption (catalog,item,value) select 'hotel','docftpserver',''

if not exists(select 1 from sysoption where catalog='hotel' and item='docftpserver' and value <> '')
	insert #syscheck_result(flag,des) select '1', 'sysoption(hotel,docftpserver): 未定义前台系统文档中心服务器'
-- ---------------------------------------------------------------------------------------
--	AutoUpdate
-- ---------------------------------------------------------------------------------------
if not exists(select 1 from sysoption where catalog='hotel' and item='updateftpserver')
	insert sysoption (catalog,item,value) select 'hotel','updateftpserver',''

if not exists(select 1 from sysoption where catalog='hotel' and item='updateftpserver' and value <> '')
	insert #syscheck_result(flag,des) select '1', 'sysoption(hotel,updateftpserver): 未定义前台系统自动更新服务器参数'
-- ---------------------------------------------------------------------------------------
--	Message
-- ---------------------------------------------------------------------------------------
if not exists(select 1 from message_notify_type)
	insert #syscheck_result(flag,des) select '1', 'message_notify_type: 未定义任何消息类型'
if not exists(select 1 from sysoption where catalog='hotel' and item='message_x')
	insert sysoption (catalog,item,value) select 'hotel','message_x','90'
if not exists(select 1 from sysoption where catalog='hotel' and item='dpbserver_port')
	insert sysoption (catalog,item,value) select 'hotel','dpbserver_port','20022'

if not exists(select 1 from sysoption where catalog='hotel' and item='dpbserver_pcid')
	insert sysoption (catalog,item,value) select 'hotel','dpbserver_pcid',''
if not exists(select 1 from sysoption where catalog='hotel' and item='dpbserver_pcid' and value <> '')
	insert #syscheck_result(flag,des) select '1', 'sysoption(hotel,dpbserver_pcid): 未定义消息服务器pc_id'

if not exists(select 1 from sysoption where catalog='hotel' and item='leaveword_pc')
	insert sysoption (catalog,item,value) select 'hotel','leaveword_pc',''

if not exists(select 1 from sysoption where catalog='hotel' and item='trace_canundo')
	insert sysoption (catalog,item,value) select 'hotel','trace_canundo','F'

if not exists(select 1 from sysoption where catalog='hotel' and item='leaveword_pc' and value <> '')
	insert #syscheck_result(flag,des) select '1', 'sysoption(hotel,leaveword_pc): 未定义实时打印留言打印工作站ip地址。一般为礼宾部'

if not exists(select 1 from sysoption where catalog='house' and item='checkroom_sound')
	insert sysoption (catalog,item,value) select 'house','checkroom_sound','F'

if not exists(select 1 from sysoption where catalog='house' and item='checkroom_sound' and value <> '')
	insert #syscheck_result(flag,des) select '1', 'sysoption(house,checkroom_sound): 未定义客房中心查房声音提示文件'

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
		insert #syscheck_result(flag,des) select '1', 'sysoption(hotel,dpbserver_ntf_crsdept): 未定义CRS预定通知消息接收部门'

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
	insert #syscheck_result(flag,des) select '2', 'sysoption(hotel,dump_path): 未定义数据库备份路径'
if not exists(select 1 from sysoption where catalog='hotel' and item='dump_files')
	insert #syscheck_result(flag,des) select '2', 'sysoption(hotel,dump_files): 未定义数据库备份分割文件数'
-- ---------------------------------------------------------------------------------------
--	genput
-- ---------------------------------------------------------------------------------------
if not exists(select 1 from sysoption where catalog='genput' and item='def_font')
	insert sysoption (catalog,item,value) select 'genput','def_font','宋体;楷体_GB2312;黑体;'
if not exists(select 1 from sysoption where catalog='genput' and item='title_font')
	insert sysoption (catalog,item,value) select 'genput','title_font','font.height="-12" font.italic="0"'

-- ---------------------------------------------------------------------------------------
--	每日房价
-- ---------------------------------------------------------------------------------------
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
insert #syscheck_result(flag,des) select '0', '. '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
insert #syscheck_result(flag,des) select '0', '. 每日房价固定的房价变动理由 '
insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
if not exists(select 1 from reason where code ='ER')
	insert #syscheck_result(flag,des) select '1', '未定义每日房价专用的房价变动理由--ER'

-- ---------------------------------------------------------------------------------------
--	记录执行时间
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