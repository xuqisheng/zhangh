/* 

grprate 重建  系统升级用

*/

if exists(select * from sysobjects where name = "p_gds_group_rate_maint")
   drop proc p_gds_group_rate_maint
;
create proc p_gds_group_rate_maint
as

declare	@accnt		char(10),
			@type			char(5),
			@rate			money

-- 1.
delete grprate where accnt not in (select accnt from master where class in ('G', 'M'))
delete grprate where type not in (select type from typim )

-- 2.
declare c_rsv_rate cursor for select a.accnt, a.type, a.rate 
	from rsvsrc a, master b where a.accnt=b.accnt and b.class in ('G', 'M') 
open c_rsv_rate
fetch c_rsv_rate into @accnt, @type, @rate
while @@sqlstatus = 0
begin
	if not exists(select 1 from grprate where accnt=@accnt and type=@type)
	begin
		insert grprate(accnt,type,rate,oldrate,cby,changed)
			values(@accnt,@type,@rate,@rate,'GDS',getdate())
	end

	fetch c_rsv_rate into @accnt, @type, @rate
end
close c_rsv_rate
deallocate cursor c_rsv_rate

-- 3.
declare c_mem_rate cursor for select groupno, type, setrate 
	from master where groupno<>'' and class='F'
open c_mem_rate
fetch c_mem_rate into @accnt, @type, @rate
while @@sqlstatus = 0
begin
	if not exists(select 1 from grprate where accnt=@accnt and type=@type)
	begin
		insert grprate(accnt,type,rate,oldrate,cby,changed)
			values(@accnt,@type,@rate,@rate,'GDS',getdate())
	end

	fetch c_mem_rate into @accnt, @type, @rate
end
close c_mem_rate
deallocate cursor c_mem_rate

return 0
;
      

//exec p_gds_group_rate_maint;
//select * from grprate;
