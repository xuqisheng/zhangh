
IF OBJECT_ID('p_gds_master_income_reb') IS NOT NULL
    DROP PROCEDURE p_gds_master_income_reb
;
create proc p_gds_master_income_reb
as
-----------------------------------------------------------------------
--	�������ѽ��ʺ�ͳ�� - �ؽ����пͻ� master_income
--	��괦���ٶȺ���
-----------------------------------------------------------------------
declare  @count  int
select @count = 0
if not exists(select 1 from process_flag where flag='master_reb')
	insert process_flag(flag,value) values('master_reb', '0')

-- delete old data
truncate table master_income

-- �����ʡ�Ӧ���� ������ͳ��
declare	@accnt	char(10)
declare	c_accnt cursor for select accnt from hmaster 
	where class not in ('C', 'A') order by accnt
open c_accnt
fetch c_accnt into @accnt
while @@sqlstatus = 0
begin
	exec p_gds_master_income @accnt, 'R'
	select @count = @count + 1
	update process_flag set value = convert(char(10), @count) where flag='master_reb'

	fetch c_accnt into @accnt
end
close c_accnt
deallocate cursor c_accnt

-- maint
update statistics master_income

return 0
;

