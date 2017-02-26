
drop proc  p_hry_accnt_get_name;
create proc  p_hry_accnt_get_name
	@accnt			char(10)
as

declare
	@name				varchar(60)

select @name = b.name from master a, guest b where a.haccnt=b.no and a.accnt=@accnt
if @@rowcount = 0
begin
	select @name = b.name from ar_master a, guest b where a.haccnt=b.no and a.accnt=@accnt
	if @@rowcount = 0
		select @name = 'No Name'
end
select @name
return 0
;
