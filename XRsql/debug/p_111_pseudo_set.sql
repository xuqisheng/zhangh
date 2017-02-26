
// 给当前团体\消费帐户加入 假房  
drop  proc p_111_pseudo_set;
create proc p_111_pseudo_set
as
declare	@accnt		char(10),
			@roomno		char(5),
			@type			char(5)


-- house account 
select @roomno = isnull((select max(roomno) from master where accnt like 'C%' and type='PM'), '')
declare c_1 cursor for select accnt from master where accnt like 'C%' and rtrim(type) is null 
open c_1
fetch c_1 into @accnt
while @@sqlstatus = 0
begin
	select @roomno = isnull((select min(roomno) from rmsta where type='PM' and roomno > @roomno), '')
	if @roomno=''
	begin
		close c_1
		deallocate cursor c_1
		goto p_out		
	end
	
	update master set osta=sta, type='PM', otype='PM', roomno=@roomno, oroomno=@roomno, rmnum=1, ormnum=1 where accnt=@accnt

	fetch c_1 into @accnt
end
close c_1
deallocate cursor c_1

-- grp - in house 
select @roomno = isnull((select max(roomno) from master where accnt like '[GM]%' and type='PM'), '')
if @roomno='' 
	select @roomno = '91'    -- 选择团体其始号码  
declare c_2 cursor for select accnt from master where accnt like '[GM]%' and rtrim(type) is null and sta in ('I', 'O', 'D', 'S')
open c_2
fetch c_2 into @accnt
while @@sqlstatus = 0
begin
	select @roomno = isnull((select min(roomno) from rmsta where type='PM' and roomno > @roomno), '')
	if @roomno=''
	begin
		close c_2
		deallocate cursor c_2
		goto p_out		
	end
	
	update master set osta=sta, type='PM', otype='PM', roomno=@roomno, oroomno=@roomno where accnt=@accnt

	fetch c_2 into @accnt
end
close c_2
deallocate cursor c_2

-- grp - R, X, N 
update master set osta=sta, type='PM', otype='PM' where accnt like '[GM]%' and rtrim(type) is null and sta in ('X', 'N', 'R')

p_out:
return ;

exec p_111_pseudo_set ;

select accnt, sta, type, roomno from master where accnt like 'C%' order by accnt ;
select accnt, sta, type, roomno from master where accnt like '[GM]%' order by accnt ;



