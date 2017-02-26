if exists (select 1 from sysobjects where name = 'p_house_checkroom_des')
	drop proc p_house_checkroom_des;
create proc p_house_checkroom_des
	@rmno			char(5),
	@lanuage		integer
		
as 
--====================================================================
-- 查房报房提示信息描述  --- 该过程使用在‘查房报房’右方
--====================================================================
-- Modify History:
----------------------------------------------------------------------
-- zhj 2008/01/07 增加资源内容显示
-- 
--====================================================================
declare
	@ret 			integer,
	@msg			varchar(60),
	@sta			char(1),
	@ocsta		char(1),
	@ocsta_des	char(8),
	@tmpsta		char(1),
	@accnt		char(10),
	@country 	varchar(20),
	@name			varchar(10),
	@tmpsta_des	varchar(10),
	@remark		varchar(20),
	@tsta_des	char(10),
	@arr			char(8),
	@dep			char(8),
	@begin_		char(8),
	@end_			char(8),
	@haccnt		char(7),
	@ident		char(20),
	@sex			varchar(20),
	@vip			varchar(20),
	@i_times		int,
	@s_times		varchar(20),
	@srqs			varchar(30),
	@amenities  varchar(30),
	@unit			varchar(250),
	@lv_date		datetime,
	@lv_room		char(5),
	@refer1     varchar(250),
	@feature		varchar(30),  	
	@rmpref		varchar(30),
	@packages   varchar(50) 

create table #tmp(
	reg		char(1)						not null,
	des		varchar(254) 				not null,
	color		int		default 0		not null
)

select @sta = sta ,@ocsta = ocsta,@tmpsta = isnull(tmpsta,'')  from rmsta where roomno = @rmno
if @tmpsta <> ''
	select @tsta_des = isnull((select descript from rmstalist1 where code = @tmpsta), '')
else
	select @tsta_des = ''

if @lanuage = 0
begin
	--
	insert #tmp(reg, des) select '1', '房号:'+@rmno +'   房态:' +isnull(descript,'')+'     '+@ocsta_des from rmstalist where sta = @sta
	insert #tmp(reg, des) select '1', '房类:'+a.type+'  '+b.descript from rmsta a ,typim b
				where a.roomno = @rmno and a.type = b.type
	insert #tmp(reg, des) select '1', '─────────────────────────────────────────'

	select @ret = 0,@msg = ''
	select @ocsta_des = descript from basecode where code = @ocsta and	cat='ocsta' order by code
	if @rmno = '' 
		select @ret = 1, @msg = '请选择房间!'
	if not exists(select 1 from rmsta where roomno = @rmno)
		select @ret = 1, @msg = '此房号不存在!'
	declare c_accnt cursor for select accnt
		from master where (sta='I' or (charindex(sta,'RCG')>0 and datediff(dd,arr,getdate())>=-2))
			and roomno=@rmno order by accnt
--如果有预定或在住的
	open c_accnt
	fetch c_accnt into @accnt
	while @@sqlstatus = 0
	begin
		select @name = isnull(b.name,''),@arr = convert(char(9), a.arr, 2) + convert(char(5), a.arr, 8),
				@dep = convert(char(10),a.dep,2),@haccnt =haccnt,@ident = isnull(b.ident,''),
				@sex=b.sex, @vip=b.vip, @i_times=b.i_times,@srqs = a.srqs, @amenities=a.amenities,
				@lv_date=b.lv_date,@lv_room=b.lv_room,@refer1=b.refer1, 
				@feature=b.feature,@rmpref=b.rmpref,@packages=a.packages 
			from master a,guest b where a.accnt = @accnt and  a.haccnt = b.no  
		select @unit=isnull(rtrim(groupno),'')+'/'+isnull(rtrim(cusno),'')+'/'+isnull(rtrim(agent),'')+'/'+isnull(rtrim(source),'') from master_des where accnt=@accnt
		select @country=isnull(descript,'') from countrycode where code=(select max(nation) from guest where no=@haccnt)
		select @sex=isnull((select descript from basecode where cat='sex' and code=@sex), '')
		if @vip>'0'
		begin
			select @vip=isnull((select descript from basecode where cat='vip' and code=@vip), '')
			if @vip<>''
				select @vip=' VIP:'+@vip
		end
		else
			select @vip=''
		if @i_times>0
			select @s_times=' 回头:'+rtrim(convert(char(3),@i_times))
		if @name <> '' 
		 begin
			insert #tmp(reg, des) select '2', '姓名:'+@name+' '+@sex+'  国籍:'+@country + @vip + @s_times
			insert #tmp(reg, des) select '2', '到店:'+@arr +'  离店:'+@dep + '   证件号码:'+ @ident
			insert #tmp(reg, des) select '2', '单位:'+@unit
			insert #tmp(reg, des) select '2', '包价:'+@packages
			insert #tmp(reg, des) select '2', '特殊要求:'+@srqs
			if @lv_date is null
				insert #tmp(reg, des) select '2', '客房布置:'+@amenities + '  上次入住: ---'
			else
				insert #tmp(reg, des) select '2', '客房布置:'+@amenities + '  上次入住:'+convert(char(8),@lv_date,1)+ ' ' + @lv_room
		 end	
		insert #tmp(reg, des) select '2', '排房要求:'+@feature
		insert #tmp(reg, des) select '2', '房号偏好:'+@rmpref
		insert #tmp(reg, des) select '2', '喜    好:'+@refer1
		insert #tmp(reg, des) select '2', '─────────────────────────────────────────'
		insert #tmp(reg, des) select '2', '租赁物品信息:'
		insert #tmp(reg, des) select '2', '─────────────────────────────────────────'
		insert #tmp(reg, des) select '2', '日期'+replicate(' ',45)+'状态  数量        名称'
		insert #tmp(reg, des) 
			select '2', 
			 (convert(char(10),a.stime,11)+' '+substring(convert(char(10),a.stime,8),1,5)+' - '
         + convert(char(10),a.etime,11)+' '+substring(convert(char(10),a.etime,8),1,5)+' '
			+ substring(rtrim(c.descript)+replicate(' ',60),1,8)+ ' '
         + substring(convert(char(8),a.qty)+replicate(' ',60),1,6)+ ' '  + rtrim(b.name))
			from res_av a,res_plu b ,basecode c 
			where a.resid = b.resid and b.chkmode <>"mtr" and rtrim(c.code) = a.sta and c.cat = 'GoodsAVStatus' and a.accnt = @accnt
		insert #tmp(reg, des) select '2', '─────────────────────────────────────────'

		fetch c_accnt into @accnt
	end 
end
else
begin
	insert #tmp(reg, des) select '1', 'Room :'+@rmno +'   State:' +isnull(descript1,'')+'     '+@ocsta_des from rmstalist where sta = @sta	
	insert #tmp(reg, des) select '1', 'Type:'+a.type+'  '+b.descript1  from rmsta a ,typim b
				where a.roomno = @rmno and a.type = b.type
	insert #tmp(reg, des) select '1', '─────────────────────────────────────────'
	
	select @ret = 0,@msg = ''
	select @ocsta_des = descript1 from basecode where code = @ocsta and	cat='ocsta' order by code
	if @rmno = '' 
		select @ret = 1, @msg = 'Please choose the room number!'
	if not exists(select 1 from rmsta where roomno = @rmno)
		select @ret = 1, @msg = 'The room number is not exists!'
	declare c_accnt cursor for select accnt
		from master where (sta='I' or (charindex(sta,'RCG')>0 and datediff(dd,arr,getdate())>=-2))
			and roomno=@rmno order by accnt
	open c_accnt
	fetch c_accnt into @accnt
	while @@sqlstatus = 0
	begin
		select @name = isnull(b.name,''),@arr = convert(char(9), a.arr, 2) + convert(char(5), a.arr, 8),
				@dep = convert(char(10),a.dep,2),@haccnt =haccnt,@ident = isnull(b.ident,''),
				@sex=b.sex, @vip=b.vip, @i_times=b.i_times,@srqs = a.srqs, @amenities=a.amenities,
				@lv_date=b.lv_date,@lv_room=b.lv_room,@refer1=b.refer1, 
				@feature=b.feature,@rmpref=b.rmpref,@packages=a.packages  
			from master a,guest b where a.accnt = @accnt and  a.haccnt = b.no  
		select @unit=isnull(rtrim(groupno),'')+'/'+isnull(rtrim(cusno),'')+'/'+isnull(rtrim(agent),'')+'/'+isnull(rtrim(source),'') from master_des where accnt=@accnt
		select @country=descript1 from countrycode where code=(select max(nation) from guest where no=@haccnt)
		select @sex=isnull((select descript1 from basecode where cat='sex' and code=@sex), '')
		if @vip>'0'
		begin
			select @vip=isnull((select descript1 from basecode where cat='vip' and code=@vip), '')
			if @vip<>''
				select @vip=' VIP:'+@vip
		end
		else
			select @vip=''
		if @i_times>0
			select @s_times=' Times:'+rtrim(convert(char(3),@i_times))
		if @name <> ''
		 begin
			insert #tmp(reg, des) select '2', 'Name:'+@name+' '+@sex+'  Nationality:'+@country + @vip + @s_times
			insert #tmp(reg, des) select '2', 'Arr:'+@arr +'  Dep:'+@dep + '   ID#:'+ @ident
			insert #tmp(reg, des) select '2', 'Company:'+@unit
			insert #tmp(reg, des) select '2', 'Packages:'+@packages
			insert #tmp(reg, des) select '2', 'Request:'+@srqs
			if @lv_date is null
				insert #tmp(reg, des) select '2', 'Amenities:'+@amenities + '  Last Visit: ---'
			else
				insert #tmp(reg, des) select '2', 'Amenities:'+@amenities + '  Last Visit:'+convert(char(8),@lv_date,1)+ ' ' + @lv_room
		 end	
		insert #tmp(reg, des) select '2', 'Feature :'+@feature
		insert #tmp(reg, des) select '2', 'Room   #:'+@rmpref
		insert #tmp(reg, des) select '2', 'Fond    :'+@refer1
		insert #tmp(reg, des) select '2', '─────────────────────────────────────────'
		insert #tmp(reg, des) select '2', 'Resource Info:'
		insert #tmp(reg, des) select '2', '─────────────────────────────────────────'
		insert #tmp(reg, des) select '2', 'DateTime'+replicate(' ',38)+'Status Quantity     Name'
		insert #tmp(reg, des) 
			select '2', 
			 (convert(char(10),a.stime,11)+' '+substring(convert(char(10),a.stime,8),1,5)+' - '
         + convert(char(10),a.etime,11)+' '+substring(convert(char(10),a.etime,8),1,5)+' '
			+ substring(rtrim(c.descript1)+replicate(' ',60),1,8)+ ' '
         + substring(convert(char(8),a.qty)+replicate(' ',60),1,6)+ ' '  + rtrim(b.ename))
			from res_av a,res_plu b ,basecode c 
			where a.resid = b.resid and b.chkmode <>"mtr" and rtrim(c.code) = a.sta and c.cat = 'GoodsAVStatus' and a.accnt = @accnt
		insert #tmp(reg, des) select '2', '─────────────────────────────────────────'

		fetch c_accnt into @accnt
	
	end
end 

close c_accnt
deallocate cursor c_accnt

update #tmp set color=16777215 where color is null or color<=0 

select * from #tmp


return 0
 ;