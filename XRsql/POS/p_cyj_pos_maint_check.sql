if exists(select 1 from sysobjects where name='p_cyj_pos_maint_check' and type ='P')
	drop proc p_cyj_pos_maint_check;
create proc p_cyj_pos_maint_check
	@parm			char(20) = ''
as
-- ------------------------------------------------------------------------------------------------------------
-- 餐饮系统数据检测
-- @parm : '' - 全部检测, 'plu' - 菜谱, 'kitchen' - 厨房打印, 'touch' - 触摸屏，'code' - 其他代码设置
-- ------------------------------------------------------------------------------------------------------------

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


if @parm = ''
	begin
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
	insert #syscheck_result(flag,des) select '1', 'jierep: toclass / rectype / toop 为空 class = '+ class
		from jierep where class<>'999' and (rtrim(rectype) is null or rtrim(toop) is null or rtrim(toclass) is null)
	end
---------------------
-- pccode - 公共部分
---------------------
if @parm = ''
	begin
	insert #syscheck_result(flag,des) select '1', 'pccode: 无效的 argcode =' + pccode + ' ' + descript + ' ' + isnull(argcode,'')
		from pccode where rtrim(argcode) is null or argcode not in (select argcode from argcode)
	insert #syscheck_result(flag,des) select '1', 'pccode: Rebate & Reason 不匹配 = ' + pccode+' '+descript+' '+reason+' '+deptno8
		from pccode where deptno8='RB' and reason='F'
	insert #syscheck_result(flag,des) select '1', 'pccode: Rebate & tail 不匹配 = ' + pccode+' '+descript+' '+tail+' '+deptno8
		from pccode where deptno8='RB' and tail<>'07'
	insert #syscheck_result(flag,des) select '2', 'pccode: 非法的 tail = ' + pccode+' '+descript+' '+tail
		from pccode where rtrim(tail) is null or tail<'01' or tail>='1'
	end
---------------------
-- pccode - 费用部分
---------------------
if @parm = ''
	begin
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
		insert #syscheck_result(flag,des) select '1', '系统启用了积分功能，但是没有设置积分付款方式'
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
	insert #syscheck_result(flag,des) select '1', 'pccode: 未定义刷卡行 = ' + a.pccode+' '+a.descript
		from pccode a where a.argcode>='9' and a.deptno in ('C','D') and pccode not in (select pccode from bankcard)
	insert #syscheck_result(flag,des) select '1', 'bankcard: 错误的刷卡行 = ' + bankcode
		from bankcard where bankcode not in (select code from basecode where cat='bankcode')
	end	

if @parm = ''
	begin
	
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
	
	end	

if @parm='' or charindex('plu',@parm)>0
	begin
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	insert #syscheck_result(flag,des) select '0', '. '
	insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
	insert #syscheck_result(flag,des) select '0', '. 菜谱检测部分 '
	insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	delete pos_price where id not in(select id from pos_plu_all)
	if exists(select 1 from  pos_price a,pos_plu_all b  where a.id=b.id and a.price<=0  and a.halt='F' and b.flag1='F' and b.flag11='F')
		insert #syscheck_result(flag,des) select '2', '存在菜价为0的菜:'+'菜本-'+b.plucode+'菜类-'+b.sort+'菜名:'+b.name1  from pos_price a,pos_plu_all b 
		where a.id=b.id and a.price<=0  and a.halt='F' and b.flag1='F' and b.flag11='F'
	end
	insert #syscheck_result(flag,des) select '0', '. 报表定义'
	delete pos_sort_all where halt ='T'
	delete pos_sort where halt ='T'
	if exists(select 1 from pos_sort_all where tocode='')
		insert #syscheck_result(flag,des) select '1', '菜类没有定义报表项:'+'菜本-'+a.plucode+'菜类-'+a.sort+'类名:'+a.name1  from pos_sort a where a.tocode =''
	if exists(select 1 from pos_plu a,pos_sort b where a.pluid=b.pluid and a.plucode=b.plucode and a.sort=b.sort and a.tocode<>b.tocode and a.tocode<>'')
		insert #syscheck_result(flag,des) select '2', '菜和菜类的报表定义不一致:'+'菜本-'+a.plucode+'菜类-'+a.sort+'菜名:'+a.name1  from pos_plu a,pos_sort b where a.pluid=b.pluid and a.plucode=b.plucode and a.sort=b.sort and a.tocode<>b.tocode and a.tocode<>''
	insert #syscheck_result(flag,des) select '0', '. 菜本使用'
	if exists(select 1 from pos_plucode where pccodes='')
		insert #syscheck_result(flag,des) select '1', '菜本没有被任何餐厅使用:'+'菜本-'+a.plucode+'名称:'+a.descript  from pos_plucode a where a.pccodes =''
	insert #syscheck_result(flag,des) select '0', '. 餐厅菜本'
	if exists(select 1 from pos_pccode c where c.pccode not in (select a.pccode from pos_pccode a, pos_plucode b where c.pccode=a.pccode and charindex(a.pccode,b.pccodes)>0))
		insert #syscheck_result(flag,des) select '1', '餐厅没有定义菜本:'+'代码-'+c.pccode+'名称:'+c.descript from pos_pccode c where c.pccode not in (select a.pccode from pos_pccode a, pos_plucode b where c.pccode=a.pccode and charindex(a.pccode,b.pccodes)>0)
	insert #syscheck_result(flag,des) select '0', '. 厨房打印'
	if exists(select  1 from pos_prnscope a, pos_prnscope b where a.id >0 and a.plusort=b.plusort and a.kitchens<>b.kitchens)
		insert #syscheck_result(flag,des) select '2', '菜和菜类的厨房打印定义不一致:'+'菜本-'+c.plucode+'菜类-'+c.sort+'菜名:'+c.name1  from pos_prnscope a, pos_prnscope b, pos_plu_all c where a.id=c.id and a.id >0 and a.plusort=b.plusort and a.kitchens<>b.kitchens

if @parm = ''
	begin
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	insert #syscheck_result(flag,des) select '0', '. '
	insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
	insert #syscheck_result(flag,des) select '0', '. 其他部分 '
	insert #syscheck_result(flag,des) select '0', '--------------------------------------------------------'
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
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
	end
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

return 0;
