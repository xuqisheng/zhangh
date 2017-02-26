if exists (select * from sysobjects where name='p_foxhis_sys_defparm' and type='P')
   drop proc p_foxhis_sys_defparm;
create proc p_foxhis_sys_defparm
   @initmode varchar(10) = ''
as 
----------------------------------------------------------
--	设置缺省系统参数
----------------------------------------------------------

--***********************
-- sysoption 
--***********************
------------------
-- front 
------------------
-- 手工登记早餐券
update sysoption set value='0' where catalog='account' and item='reg_bf_ticket'
-- 客房可用和占用显示天数
update sysoption set value='10' where catalog='reserve' and item='type_detail_avail'
-- 客房资源总体控制，一般不采用
update sysoption set value='f' where catalog='reserve' and item='cntlblock'
update sysoption set value='0' where catalog='reserve' and item='cntlquan'
-- 自用证件扫描功能？
update sysoption set value='F' where catalog='reserve' and item='idscan'

-- 房态,一般不采用 T, I 
update rmstalist set instready='F' where sta in ('I', 'T')

-- About AR 
update pccode set deptno3='', deptno6='' where deptno2='TOR'


------------------
-- pos
------------------


--***********************
-- Other 
--***********************
update bos_posdef set mode='2' 	-- bos 收银模式设置为 明细


return 0
;
