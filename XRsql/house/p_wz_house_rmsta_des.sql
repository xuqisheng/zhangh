if object_id('p_wz_house_rmsta_des') is not null 
drop proc p_wz_house_rmsta_des
;
create proc p_wz_house_rmsta_des
	@rmno			char(5),
	@lanuage		integer

as
--====================================================================
-- 客房中心房态描述  --- 该过程使用在‘房态管理’左下角的地方
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
	@msta			char(1),
	@mreas		char(3),
	@msta_des   char(10),
	@mreas_des  char(10),
	@remark		varchar(255),
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
	@amenities  varchar(30),
	@unit			varchar(250),
	@lv_date		datetime,
	@lv_room		char(5),
	@refer1     varchar(250),
    @begin_min      datetime,
   @count        int   


create table #tmp(
	reg		char(1)			not null,
	des		char(200) 		not null,
	color		int		default 0		not null
)

select @count=0

select @sta = sta ,@ocsta = ocsta,@tmpsta = isnull(tmpsta,'')  from rmsta where roomno = @rmno
if @tmpsta <> ''
	select @tsta_des = isnull((select descript from rmstalist1 where code = @tmpsta), '')
else
	select @tsta_des = ''

--
declare c_getdate cursor for select dbegin from rm_ooo where roomno=@rmno and status='I'
--select @begin_min=min(dbegin) from rm_ooo where roomno=@rmno and status='I'
open c_getdate
fetch c_getdate into @begin_min
while @@sqlstatus=0
begin
   select @count=@count+1
	if (select count(1) from rm_ooo where roomno=@rmno and status='I' and dbegin=@begin_min) = 1
	begin
		select @msta = sta ,@mreas = reason,@remark = isnull(remark,''),@begin_ = convert(char(10),dbegin,2),@end_ = convert(char(10),dend,2)
					from rm_ooo where roomno = @rmno and status = 'I' and dbegin=@begin_min
		select @mreas_des = descript from basecode where cat = 'rmmaint_reason' and code = @mreas
		select @msta_des = descript from rmstalist where maintnmark = 'T' and sta = @msta
	end
	else
		select @msta='', @msta_des='', @mreas='', @mreas_des='', @remark='', @begin_=null, @end_=null
	
	if @lanuage = 0 
	begin
		--
      if @count=1
         begin
				insert #tmp(reg, des) select '1', '房号:'+@rmno +'   房态:' +isnull(descript,'')+'     '+@ocsta_des from rmstalist where sta = @sta
				insert #tmp(reg, des) select '1', '房类:'+a.type+'  '+b.descript from rmsta a ,typim b
							where a.roomno = @rmno and a.type = b.type
				insert #tmp(reg, des) select '1', '─────────────────────────────────────────'
         end
	
		--oo or os / tmp descript
		if charindex(@sta,'OS') > 0
		 begin
			insert #tmp(reg, des) select '1', substring('维修:'+@msta_des+ ' - '+ @mreas_des+space(200),1,199)+'|'
			insert #tmp(reg, des) select '1', substring('备注:'+ @remark	+ space(200),1,199)+'|'
			insert #tmp(reg, des) select '1', substring('时间:'+@begin_+'--->'+@end_ + space(200),1,199)+'|'
		 end
	
		if exists(select 1 from rm_ooo where roomno = @rmno and status = 'I') and charindex(@sta,'OS') = 0
		begin
			insert #tmp(reg, des) select '1', substring('请注意有未来维修' + space(200),1,199) + '|'
			insert #tmp(reg, des) select '1', substring('理由:'+ @mreas_des +'   备注:'+@remark + space(200),1,199) + '|'
			insert #tmp(reg, des) select '1', substring('时间:'+@begin_+'--->'+@end_  + space(200),1,199) + '|'
			insert #tmp(reg, des) select '1', '─────────────────────────────────────────'
		end
	
		if @tmpsta <> ''
		begin
			select @remark = remark from rmtmpsta where roomno = @rmno
			insert #tmp(reg, des) select '1', substring('临时态:'+@tsta_des + space(200),1,199) + '!'
			insert #tmp(reg, des) select '1', substring('备  注:'+@remark + space(200),1,199) + '!'
			insert #tmp(reg, des) select '1', '─────────────────────────────────────────'
		end

		select @ret = 0,@msg = ''
		select @ocsta_des = descript from basecode where code = @ocsta and	cat='ocsta' order by code
		if @rmno = ''
			select @ret = 1, @msg = '请选择房间!'
		if not exists(select 1 from rmsta where roomno = @rmno)
			select @ret = 1, @msg = '此房号不存在!'
  end
else
	begin
      if @count=1
		begin
			insert #tmp(reg, des) select '1', 'Room :'+@rmno +'   State:' +isnull(descript1,'')+'     '+@ocsta_des from rmstalist where sta = @sta
			insert #tmp(reg, des) select '1', 'Type:'+a.type+'  '+b.descript1  from rmsta a ,typim b
						where a.roomno = @rmno and a.type = b.type
			insert #tmp(reg, des) select '1', '─────────────────────────────────────────'
       end

	
		if charindex(@sta,'OS') >0
		begin
			insert #tmp(reg, des) select '1', substring('oo/os :'+@msta_des+ ' - '+ @mreas_des + space(200),1,199) + '|'
			insert #tmp(reg, des) select '1', substring('remark:'+@remark + space(200),1,199) + '|'
			insert #tmp(reg, des) select '1', substring('time  :'+@begin_+'--->'+@end_  + space(200),1,199) + '|'
			insert #tmp(reg, des) select '1', '─────────────────────────────────────────'
		end
		if exists(select 1 from rm_ooo where roomno = @rmno and status = 'I') and charindex(@sta,'OS') = 0
		begin
			insert #tmp(reg, des) select '1', 'Caution: future maintain settings'
			insert #tmp(reg, des) select '1', substring('reason:'+ @mreas_des +'   remark:'+@remark + space(200),1,199) + '|'
			insert #tmp(reg, des) select '1', substring('time  :'+@begin_+'--->'+@end_ + space(200),1,199) + '|'
			insert #tmp(reg, des) select '1', '─────────────────────────────────────────'
		end
	
		if @tmpsta <> ''
		begin
			select @remark = remark from rmtmpsta where roomno = @rmno
			insert #tmp(reg, des) select '1', substring('temporary:'+@tsta_des + space(200),1,199) + '!'
			insert #tmp(reg, des) select '1', substring('Remark   :' + @remark + space(100),1,199) + '!'
			insert #tmp(reg, des) select '1', '─────────────────────────────────────────'
		end
	
		select @ret = 0,@msg = ''
		select @ocsta_des = descript1 from basecode where code = @ocsta and	cat='ocsta' order by code
		if @rmno = ''
			select @ret = 1, @msg = 'Please choose the room number!'
		if not exists(select 1 from rmsta where roomno = @rmno)
			select @ret = 1, @msg = 'The room number is not exists!'
	end
	fetch c_getdate into @begin_min	
end
--close c_getdate
if @lanuage = 0
	begin
   if @count=0 
   begin
		insert #tmp(reg, des) select '1', '房号:'+@rmno +'   房态:' +isnull(descript,'')+'     '+@ocsta_des from rmstalist where sta = @sta
			insert #tmp(reg, des) select '1', '房类:'+a.type+'  '+b.descript from rmsta a ,typim b
						where a.roomno = @rmno and a.type = b.type
			insert #tmp(reg, des) select '1', '─────────────────────────────────────────'
    end
   
		declare c_accnt cursor for select accnt
			from master where (sta='I' or (charindex(sta,'RCG')>0 and datediff(dd,arr,getdate())>=-2))
				and roomno=@rmno order by accnt
	--如果有预定或在住的
		open c_accnt
		fetch c_accnt into @accnt
		while @@sqlstatus = 0
		begin
			select @name = isnull(b.name,''),@arr = convert(char(9), a.arr, 2) + convert(char(5), a.arr, 8),@dep = convert(char(10),a.dep,2),@haccnt =haccnt,@ident = isnull(b.ident,''),
					@sex=b.sex, @vip=b.vip, @i_times=b.i_times,@amenities=a.amenities,@lv_date=b.lv_date,@lv_room=b.lv_room,@refer1=b.refer1
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
				if @lv_date is null
					insert #tmp(reg, des) select '2', '布置:'+@amenities + '  上次入住: ---'
				else
					insert #tmp(reg, des) select '2', '布置:'+@amenities + '  上次入住:'+convert(char(8),@lv_date,1)+ ' ' + @lv_room
			 end
			insert #tmp(reg, des) select '2', '─────────────────────────────────────────'
			fetch c_accnt into @accnt
		end
	end
else
   begin
      if @count=0
       begin
			insert #tmp(reg, des) select '1', 'Room :'+@rmno +'   State:' +isnull(descript1,'')+'     '+@ocsta_des from rmstalist where sta = @sta
			insert #tmp(reg, des) select '1', 'Type:'+a.type+'  '+b.descript1  from rmsta a ,typim b
						where a.roomno = @rmno and a.type = b.type
			insert #tmp(reg, des) select '1', '─────────────────────────────────────────'
       end

		declare c_accnt cursor for select accnt
			from master where (sta='I' or (charindex(sta,'RCG')>0 and datediff(dd,arr,getdate())>=-2))
				and roomno=@rmno order by accnt
		open c_accnt
		fetch c_accnt into @accnt
		while @@sqlstatus = 0
		begin
			select @name = isnull(b.name,''),@arr = convert(char(9), a.arr, 2) + convert(char(5), a.arr, 8),@dep = convert(char(10),a.dep,2),@haccnt = haccnt,@ident = isnull(b.ident,''),
					@sex=b.sex, @vip=b.vip, @i_times=b.i_times,@amenities=a.amenities,@lv_date=b.lv_date,@lv_room=b.lv_room,@refer1=b.refer1
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
				if @lv_date is null
					insert #tmp(reg, des) select '2', 'Amenities:'+@amenities + '  Last Visit: ---'
				else
					insert #tmp(reg, des) select '2', 'Amenities:'+@amenities + '  Last Visit:'+convert(char(8),@lv_date,1)+ ' ' + @lv_room
			 end
			insert #tmp(reg, des) select '2', '─────────────────────────────────────────'
			fetch c_accnt into @accnt
	
		end
	close c_accnt
	deallocate cursor c_accnt
  end
  close c_getdate
  deallocate cursor c_getdate 

update #tmp set color=16777215 where color is null or color<=0

select * from #tmp


return 0
;