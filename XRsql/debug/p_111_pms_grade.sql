
IF OBJECT_ID('p_111_pms_grade') IS NOT NULL
    DROP PROCEDURE p_111_pms_grade;
create proc p_111_pms_grade
as
-- 重新刷新所有电话等级 - 针对在住客人 
declare @accnt char(10),  @phonesta char(1), @extra char(15), @roomno char(5) 
declare	c_guest cursor for select accnt, extra, roomno from master where accnt=master and accnt like 'F%' and sta ='I' 
open c_guest
fetch c_guest into @accnt, @extra, @roomno  
while @@sqlstatus = 0
begin
	select @phonesta = substring(@extra,6,1)
	exec p_gds_phone_grade @roomno, 'ckin', @phonesta, @accnt
	exec p_gds_phone_grade @roomno, 'grad', @phonesta, @accnt
	fetch c_guest into @accnt, @extra , @roomno  
end
close c_guest
deallocate cursor c_guest
return ;


exec p_111_pms_grade ;

select * from phteleclos where changed='F';

