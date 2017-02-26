IF OBJECT_ID('p_gds_audit_bursar') IS NOT NULL
    DROP PROCEDURE p_gds_audit_bursar
;
create proc p_gds_audit_bursar
	@date		datetime = null
as
----------------------------------------------------------------
-- ����ƾ֤ ÿ��ҹ������
----------------------------------------------------------------
declare
	@duringaudit	char(1),
	@bdate			datetime

-- Init 
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
if @date is null
	select @date = @bdate
delete bursar_out

--
CREATE TABLE #def (
	code 			char(15)							not null,		-- ���ƾ֤����  bursar_code
	id				int								not null,
	remark		varchar(30)	 default '' 	null,				-- ժҪ
	bursar		char(20) 						not null,		-- ��Ŀ bursar
	tag 			char(2)  	 default '��' 	not null,		-- �� / ��
	src 			char(10)  	 default '' 	not null,		-- ����Դ���   basecode = bursar_src 
	classes		varchar(255) default '' 	not null,		-- ����Դ����
	amount		money			default 0 		not null
)
insert #def select code,id,remark,bursar,tag,src,classes,0 from bursar_def 
declare	@code		char(15),
			@id		int,
			@src		char(10),
			@classes	varchar(255),
			@amount	money
declare c_def cursor for select code,id,src,classes from #def 
open c_def
fetch c_def into @code,@id,@src,@classes
while @@sqlstatus = 0
begin
	exec p_gds_audit_bursar_item @date, @src, @classes, @amount output
	if @amount <> 0
		update #def set amount=@amount where code=@code and id=@id

	fetch c_def into @code,@id,@src,@classes
end
close c_def
deallocate cursor c_def

-- ����
delete #def where amount = 0
insert bursar_out (date,code,id,remark,bursar,kind,tag,amount)
	select @date, a.code, a.id, a.remark, a.bursar, b.kind, a.tag, a.amount 
		from #def a, bursar b where a.bursar=b.code 

-- Saving ......
delete ybursar_out where date=@date
insert ybursar_out select * from bursar_out

return 0
;