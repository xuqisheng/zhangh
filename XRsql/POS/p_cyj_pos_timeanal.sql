
if not exists(select 1  from sysobjects where name ='pos_timedef_pcid' and type ='U')
	create table pos_timedef_pcid (
		pc_id		char(4)	not null,
		id			char(2)	not null,
		thisid	char(2)	not null,
		timedesc char(30)	not null,
		datecond	char(60)	not null,
		start_t	char(8)	not null,
		end_t		char(8)	not null,
		leng_		integer	not null,
		factor	money		not null
	)
;

if exists (select * from sysobjects where name = 'p_cyj_pos_timeanal')
	drop proc p_cyj_pos_timeanal;
create proc p_cyj_pos_timeanal
	@pc_id			char(4), 
	@id				char(2),            -- pos_time_code.timecode
	@begin_			datetime,           -- 开始时间
	@end_				datetime            -- 结束时间
as
-----------------------------------------------------------------------------------
-- 餐饮计时分解
-- 考虑计时跨日处理      cyj 20090708
-----------------------------------------------------------------------------------
declare
	@thisid			char(2), 
	@thisid_b		char(2), 
	@thisid_l		char(2), 
	@tbegin_			datetime, 
	@begintime		char(8), 
	@beginday		char(5), 
	@begindw			char(1), 
	@start_t			char(8), 
	@end_t			char(8), 
	@tstart_t		char(8), 
	@tend_t			char(8), 
	@end_t_l			char(8), 
	@length			integer,
	@leng				integer,
	@tlength			integer,
	@iii				integer,
	@icnt				integer,
	@factor			money,
	@datecond		char(60)

delete pos_timedef_pcid where pc_id = @pc_id
insert into  pos_timedef_pcid select @pc_id,* from pos_timedef where id = @id
declare c_cur cursor for select thisid,datecond,start_t,end_t,leng_,factor from pos_timedef where id = @id order by thisid
open c_cur
fetch c_cur into @thisid,@datecond,@start_t,@end_t,@leng,@factor
while @@sqlstatus = 0 
	begin
		if not exists(select 1 from pos_timedef_pcid where pc_id = @pc_id and thisid = @thisid)
			begin
			fetch c_cur into @thisid,@datecond,@start_t,@end_t,@leng,@factor
			continue
			end
		select @icnt = count(1) from pos_timedef_pcid where pc_id = @pc_id and  id = @id and thisid <> @thisid and datecond = @datecond and leng_ = @leng and factor = @factor
			and (start_t = @end_t or datediff(ss,convert(datetime, @end_t),convert(datetime, start_t)) = 1 or datediff(ss,convert(datetime, @end_t),dateadd(day,1,convert(datetime, start_t))) = 1)
		while @icnt >=1 
			begin
			select @thisid_l = min(thisid) from pos_timedef_pcid where pc_id = @pc_id and thisid <> @thisid and datecond = @datecond and leng_ = @leng and factor = @factor
			and (start_t = @end_t or datediff(ss,convert(datetime, @end_t),convert(datetime, start_t)) = 1 or datediff(ss,convert(datetime, @end_t),dateadd(day,1,convert(datetime, start_t))) = 1)
			select @end_t_l = end_t from pos_timedef_pcid where  pc_id = @pc_id and thisid = @thisid_l
			update pos_timedef_pcid set end_t = @end_t_l where  pc_id = @pc_id and thisid = @thisid 
			delete pos_timedef_pcid where  pc_id = @pc_id and thisid = @thisid_l
			select @icnt = count(1) from pos_timedef_pcid where  pc_id = @pc_id and id = @id and thisid <> @thisid and datecond = @datecond and leng_ = @leng and factor = @factor
				and (start_t = @end_t or datediff(ss,convert(datetime, @end_t),convert(datetime, start_t)) = 1 or datediff(ss,convert(datetime, @end_t),dateadd(day,1,convert(datetime, start_t))) = 1)
			end
	fetch c_cur into @thisid,@datecond,@start_t,@end_t,@leng,@factor
	end

delete from pos_timeanal where pc_id = @pc_id
select @tbegin_ = @begin_
select @length = datediff(minute, @begin_, @end_)
while 1 = 1 
	begin
	select @begintime = convert(char(8), @tbegin_, 8)
	select @beginday  = substring(convert(char(8), @tbegin_, 1), 1, 5)
	select @begindw	= convert(char(1), datepart(dw, @tbegin_)-1)
//	if @begindw = '0'
//		select @begindw = '7'
	/* consider date before day of the week */
	select @thisid = max(thisid) from pos_timedef_pcid
		where  pc_id = @pc_id and id = @id and charindex(substring(datecond, 1, 1), 'dD') > 0 and charindex(@beginday, datecond) > 0
		and (( start_t < end_t and  @begintime >= start_t and @begintime <= end_t)
		or  ( start_t > end_t and  @begintime >= start_t and convert(datetime, @begintime) <= dateadd(day,1,convert(datetime, end_t)))
		or  ( start_t > end_t and  @begintime <= end_t and dateadd(day,1,convert(datetime, @begintime)) >= convert(datetime, start_t))
		)

	if @thisid is null 
		select @thisid = max(thisid) from pos_timedef_pcid
			where  pc_id = @pc_id and id = @id and charindex(substring(datecond, 1, 1), 'wW') > 0 and charindex(@begindw, datecond) > 0 
			and (( start_t < end_t and  @begintime >= start_t and @begintime <= end_t)
			or  ( start_t > end_t and  @begintime >= start_t and convert(datetime, @begintime) <= dateadd(day,1,convert(datetime, end_t)))
			or  ( start_t > end_t and  @begintime <= end_t and dateadd(day,1,convert(datetime, @begintime)) >= convert(datetime, start_t))
			)

	if @thisid is null
		break  

	if not exists (select 1 from pos_timeanal where pc_id = @pc_id and id = @id and thisid = @thisid )
		insert pos_timeanal select @pc_id, @id, @thisid, start_t, end_t, factor, leng_, 0 from pos_timedef_pcid where  pc_id = @pc_id and id = @id and thisid = @thisid 
	select @tstart_t = start_t, @tend_t = end_t from pos_timeanal where pc_id = @pc_id and  id = @id and thisid = @thisid 
	if @begintime <= @tend_t
		select @tlength = datediff(minute, convert(datetime, @begintime), convert(datetime, @tend_t))+1
	else
		select @tlength = datediff(minute, convert(datetime, @begintime), dateadd(day,1,convert(datetime, @tend_t)))+1

	if @length <= @tlength
		begin
		update pos_timeanal set duration = duration + @length where pc_id = @pc_id and  id = @id and thisid = @thisid 
		break
		end 
	else
		begin
		update pos_timeanal set duration = duration + @tlength where pc_id = @pc_id and  id = @id and thisid = @thisid 
		select @length = @length - @tlength
		select @tbegin_ = dateadd(minute, @tlength, @tbegin_)
		end 
	end
--if not exists (select 1 from pos_timeanal where pc_id = @pc_id and id = @id)
--	insert pos_timeanal values (@pc_id,  @id, '01', '00:00:00', '23:59:59', 1,60, @length)

return 0
;

