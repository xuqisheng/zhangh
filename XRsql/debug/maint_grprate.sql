drop proc p_a;
create proc p_a
as

truncate table grprate

declare @grpaccnt char(10), @type char(5), @rate money

// master
declare	c_grprate cursor for select distinct groupno, type from master 
	where sta in ('R', 'I') and class='F' and groupno<>''
open c_grprate 
fetch c_grprate into @grpaccnt, @type
while @@sqlstatus = 0
begin
	select @rate = max(setrate) from master where groupno=@grpaccnt and type=@type and class='F'
	insert grprate(accnt,type,rate,oldrate,cby,changed)
		values(@grpaccnt,@type,@rate,@rate,'FOX',getdate())

	fetch c_grprate into @grpaccnt, @type
end
close c_grprate
deallocate cursor c_grprate

// rsvsrc 
declare	c_grprate1 cursor for select distinct accnt, type from rsvsrc where accnt not like 'F%'
open c_grprate1 
fetch c_grprate1 into @grpaccnt, @type
while @@sqlstatus = 0
begin
	if not exists(select 1 from grprate where accnt=@grpaccnt and type=@type)
	begin
		select @rate = max(rate) from rsvsrc where accnt=@grpaccnt and type=@type
		insert grprate(accnt,type,rate,oldrate,cby,changed)
			values(@grpaccnt,@type,@rate,@rate,'FOX',getdate())
	end

	fetch c_grprate1 into @grpaccnt, @type
end
close c_grprate1
deallocate cursor c_grprate1

return ;

exec p_a;
