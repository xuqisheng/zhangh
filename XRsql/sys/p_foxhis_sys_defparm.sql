if exists (select * from sysobjects where name='p_foxhis_sys_defparm' and type='P')
   drop proc p_foxhis_sys_defparm;
create proc p_foxhis_sys_defparm
   @initmode varchar(10) = ''
as 
----------------------------------------------------------
--	����ȱʡϵͳ����
----------------------------------------------------------

--***********************
-- sysoption 
--***********************
------------------
-- front 
------------------
-- �ֹ��Ǽ����ȯ
update sysoption set value='0' where catalog='account' and item='reg_bf_ticket'
-- �ͷ����ú�ռ����ʾ����
update sysoption set value='10' where catalog='reserve' and item='type_detail_avail'
-- �ͷ���Դ������ƣ�һ�㲻����
update sysoption set value='f' where catalog='reserve' and item='cntlblock'
update sysoption set value='0' where catalog='reserve' and item='cntlquan'
-- ����֤��ɨ�蹦�ܣ�
update sysoption set value='F' where catalog='reserve' and item='idscan'

-- ��̬,һ�㲻���� T, I 
update rmstalist set instready='F' where sta in ('I', 'T')

-- About AR 
update pccode set deptno3='', deptno6='' where deptno2='TOR'


------------------
-- pos
------------------


--***********************
-- Other 
--***********************
update bos_posdef set mode='2' 	-- bos ����ģʽ����Ϊ ��ϸ


return 0
;
