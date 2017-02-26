
if  exists(select * from sysobjects where name = "p_gds_house_map_tip")
	drop proc  p_gds_house_map_tip;
create proc  p_gds_house_map_tip
   @entry 	 varchar(20),
	@langid	int
as
------------------
--	房态表 TIPS
------------------
declare
	@accnt	char(10),
	@haccnt	char(7),
	@sta		char(1),
	@groupno	char(10),
	@pcrec	char(10),
	@roomno	char(5),
   @fir		varchar(100),
   @name		varchar(255),
	@arrdep	varchar(100),
	@sex		varchar(4),
	@vip		varchar(10),
	@secret  varchar(1),
	@len		int,
	@country	varchar(30),
	@arr		datetime,
	@cond		varchar(10)

create table #tips
(
	tips		varchar(200) 		not null,
	len		int default 0 		not null
)


if substring(@entry,1,3)='OOO'
begin
	insert #tips(tips) 
		select reason+':'+isnull(rtrim(remark),'--')+'-['+substring(convert(char(10), dbegin, 1),1,5)+'->'+substring(convert(char(10), dend, 1),1,5)+']' 
			from rm_ooo where folio = substring(@entry,5,10)
	select @roomno = roomno from rm_ooo where folio = substring(@entry,5,10)
end
else if substring(@entry,1,3)='GST' or substring(@entry,1,3)='ACT'
begin
	if substring(@entry,1,3)='GST'
	begin 
		select @cond = substring(@entry, 5, 5)
		declare c_accnt cursor for select accnt, sta, arr, roomno 
			from master where roomno=@cond order by accnt
	end
	else
	begin 
		select @cond = substring(@entry, 5, 10)
		declare c_accnt cursor for select accnt, sta, arr, roomno 
			from master where accnt=@cond
	end
	open c_accnt
	fetch c_accnt into @accnt, @sta, @arr, @roomno 
	while @@sqlstatus = 0
	begin
		if substring(@entry,1,3)='GST' 
		begin 
			if not (@sta='I' or (charindex(@sta,'RCG')>0 and datediff(dd,@arr,getdate())>=-2))
			begin
				fetch c_accnt into @accnt, @sta, @arr, @roomno 
				continue
			end
		end  

		if exists(select 1 from #tips)
			insert #tips(tips) select '─────────────────────────────────────────'
		
		select @haccnt= a.haccnt,@name=b.name,@fir=isnull(a.applicant,''),@groupno=a.groupno,@pcrec=a.pcrec,
				@sta=a.sta,	@arrdep=convert(char(5),a.arr,1)+'('+convert(char(1),datepart(dw,a.arr)-1)+')'+"->"
				+convert(char(5),a.dep,1)+'('+convert(char(1),datepart(dw,a.dep)-1)+')   '
				+convert(char(4),datediff(dd,a.arr,a.dep))+' Nights',@country=b.country,@vip=b.vip,
				@secret=substring(a.extra,4,1)
			from master a,guest b    -- 这里需要取得 country, vip 等，必须与 guest 关联；
			where a.accnt=@accnt and a.haccnt = b.no 
		if @langid = 0
		begin
			select @country=descript from countrycode where code=@country
			insert #tips(tips) select "账号:"+@accnt +'-'+@sta+"  房号:" + @roomno
			insert #tips(tips) select "姓名:" + @name
			insert #tips(tips) select "国籍:" + @country
			if @secret<>'0' insert #tips(tips) select "保密:√"
			if @vip>'0' insert #tips(tips) select "V I P:"+@vip
			if rtrim(@pcrec) is not null
			begin
				select @len = count(roomno) from master where charindex(sta,'RCGI')>0 and pcrec=@pcrec
				insert #tips(tips) select "联房: "+convert(char(4),@len) +" 间"
			end
	
			insert #tips(tips) select "抵离:" + @arrdep
			if @fir<>'' insert #tips(tips) select "单位:" + @fir
			if rtrim(@groupno) is not null 
				insert #tips(tips) select "团体:"+a.accnt+'-'+b.name from master a, guest b where a.haccnt=b.no and a.accnt=@groupno
		end
		else
		begin
			select @country=descript1 from countrycode where code=@country
			insert #tips(tips) select "Act#:"+@accnt +'-'+@sta+"  Room:" + @roomno
			insert #tips(tips) select "Name:" + @name
			insert #tips(tips) select "Country:" + @country
			if @secret<>'0' insert #tips(tips) select "Secret:√"
			if @vip>'0' insert #tips(tips) select "V I P:"+@vip
			if rtrim(@pcrec) is not null
			begin
				select @len = count(roomno) from master where charindex(sta,'RCGI')>0 and pcrec=@pcrec
				insert #tips(tips) select "LinkRoom: " + convert(char(4),@len) + " Rms"
			end
	
			insert #tips(tips) select "Arr./Dep.:" + @arrdep
			if @fir<>'' insert #tips(tips) select "Company:" + @fir
			if rtrim(@groupno) is not null 
				insert #tips(tips) select "Group:"+a.accnt+'-'+b.name from master a, guest b where a.haccnt=b.no and a.accnt=@groupno
		end

		fetch c_accnt into @accnt, @sta, @arr, @roomno 
	end
	close c_accnt
	deallocate cursor c_accnt
end


if exists(select 1 from #tips)
	insert #tips(tips) select '─────────────────────────────────────────'
else
	select @roomno = @entry

if @langid = 0 
begin
	insert #tips(tips) select '房号:' + a.roomno +'房类:'  + a.type +'-'+ b.descript
		from rmsta a, typim b where roomno = @roomno and a.type = b.type
	insert #tips(tips) select '临时房态:' +c.descript+'-'+b.remark 
		from rmsta a, rmtmpsta b, rmstalist1 c
		where a.roomno=b.roomno and b.tmpsta=c.code and a.roomno=@roomno
end
else
begin
	insert #tips(tips) select 'Room:' + a.roomno +'Type:'+ a.type +'-'+ b.descript1
		from rmsta a, typim b where roomno = @roomno and a.type = b.type
	insert #tips(tips) select 'Assignment:' +c.descript1+'-'+b.remark 
		from rmsta a, rmtmpsta b, rmstalist1 c
		where a.roomno=b.roomno and b.tmpsta=c.code and a.roomno=@roomno
end

select @len = max(datalength(tips)) from #tips where tips<>'─────────────────────────────────────────'
update #tips set tips='  '+tips where tips<>'─────────────────────────────────────────'
update #tips set len = @len

select tips,len from #tips

return 0;
