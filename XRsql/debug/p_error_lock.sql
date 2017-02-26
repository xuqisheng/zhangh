
if object_id ('p_error_lock') is not null 
	drop proc p_error_lock
;
create procedure p_error_lock
as
-----------------------------------------------------
-- ��ʾ�����������ì�ܵļ�¼
-----------------------------------------------------

create table #wangzhen (accnt char(10) null,  haccnt varchar(60) null, locksta char(1) null, pccodes varchar(255) null)

insert #wangzhen
	select a.accnt, b.haccnt, locksta=substring(a.extra,10,1), 
			tree=isnull((select c.pccodes from subaccnt c where a.accnt=c.accnt and c.type='0'), '')
		from master a, master_des b where a.accnt=b.accnt

select * from #wangzhen 
	where (locksta='0' and pccodes<>'')
		or (locksta='1' and pccodes<>'*')
		or (locksta='2' and (pccodes='' or pccodes='.' or pccodes='*'))
	order by locksta, pccodes

return 
;

exec p_error_lock;
