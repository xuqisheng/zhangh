/* 

到期散客续住 

凌晨可以做 --- 没有必要修改到日 !

*/

if exists(select * from sysobjects where name = "p_gds_reserve_delay_dep")
   drop proc p_gds_reserve_delay_dep
;
create  proc p_gds_reserve_delay_dep
	@empno    char(10),
	@retmode  char(1),
	@ret      int,
	@msg      varchar(70)

as

declare
	@sta     char(1),
	@accnt   char(10),
	@today   datetime,
	@dep     datetime,
	@ghour	int

select @ret=0, @msg ="", @today=convert(datetime,convert(char(10),getdate(),111))
select @ghour = datepart(hour,getdate())
if  @ghour > 4 and @ghour < 20 
   begin
   select @ret=1,@msg='请在20点以后 或者凌晨 5点之前 做此功能'
   if @retmode ='S'
      select @ret,@msg
   return @ret
   end 

-- begin 
if @ghour < 10  							-- 早上作续住，是针对上日未延住的客人
	declare c_delay_dep cursor for
		select accnt from master where class='F' and groupno='' and sta = 'I' and datediff(day,@today,dep) < 0
        order by accnt
else    										-- 晚上作续住，是针对本日未延住的客人
	declare c_delay_dep cursor for
		select accnt from master where class='F' and groupno='' and sta = 'I' and datediff(day,@today,dep) <= 0
        order by accnt

open  c_delay_dep
fetch c_delay_dep into @accnt
while @@sqlstatus = 0
begin
	begin tran
	save  tran p_gds_reserve_delay_dep_s1

	update master set sta = sta where accnt = @accnt 
	select @sta = sta, @dep = dep from master where accnt = @accnt
	
	if @sta='I' and datediff(day,@today,@dep) <= 0
	begin
		if @ghour < 10 
			update master set dep = @today where accnt = @accnt
		else
			update master set dep = dateadd(day,1,@today) where accnt = @accnt
		
		exec @ret = p_gds_reserve_chktprm @accnt,'0','',@empno,'',1,0,@msg out
		if @ret = 0
			update master set logmark=logmark+1, cby=@empno,changed = getdate() where accnt = @accnt
	end
	
	if @ret <> 0
		rollback tran p_gds_reserve_delay_dep_s1
	commit tran

	select @ret=0,@msg=''
	fetch c_delay_dep into @accnt
end
close  c_delay_dep
deallocate cursor c_delay_dep

if @retmode ='S'
	select @ret,@msg
return @ret
;

