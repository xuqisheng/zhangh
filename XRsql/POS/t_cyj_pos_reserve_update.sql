drop  trigger t_cyj_pos_reserve_update;
create trigger t_cyj_pos_reserve_update
	on pos_reserve for update
as
declare
	@resno 			char(10),
	@bdate			datetime,
	@shift			char(1),
	@tables 			int,
	@guest			int,
	@sta				char(1),
	@meet				char(1),							-- 管理会议
	@type				char(1),							-- 0-用餐, 1-会议
	@code				char(5),
	@pccode			char(3),
	@empno			char(10),
	@btime			datetime,                  -- 开始时间
	@etime			datetime,						-- 结束时间
	@date0			datetime,
	@stats			money,							-- 标准
	@statstype		char(1),							-- 1 -人, 2-桌
	@guests			int,								-- 人数
	@msg				char(32)

select @resno = resno, @sta = sta, @pccode = pccode , @bdate = bdate, @shift = shift, @tables = tables, @guest = guest from inserted
if update(tableno)
	begin
	if exists(select 1 from deleted where rtrim(tableno) <> null)
		delete pos_tblav from pos_tblav,deleted where pos_tblav.menu = resno and pos_tblav.tableno = deleted.tableno

	if exists(select 1 from inserted where rtrim(tableno) <> null)
		begin
		delete pos_tblav from pos_tblav b, inserted a where b.menu = a.resno and b.tableno = a.tableno
		insert pos_tblav(menu,tableno,inumber,empno,bdate,shift,sta,begin_time,end_time,pcrec,amount)
		 select resno, tableno, 0, empno, convert(datetime, convert(char(8),date0,1)), shift,'1',convert(datetime, convert(char(8),date0,1)),null,'',0 from inserted
		end
	end
if update(logmark)
	insert into pos_reserve_log select * from deleted

  if @sta <>'1' or @sta <> '2'
	begin
	update pos_tblav set sta = '0' where menu = @resno and charindex('R',menu)=0
   update pos_tblav set sta = '0' where menu = (select resno from pos_reserve where resno=@resno and sta='7')
	select @tables = 0
	end


if (@sta = '1' or @sta ='2') and (update(date0)  or update(shift) or update(pccode) or update(tableno))
	begin
	--   增加pos_plaav 新预定场地记录
	select @resno = resno, @empno = empno, @shift = shift, @date0 = date0, @meet = meet, @bdate = bdate, @stats = standent, @statstype = stdunit, @guests = guest, @tables = tables  from inserted

	if @meet = 'Y'
		select @type = '1'
	else
		select @type = '0'

	if @date0 <> convert(datetime, convert(char(8), @date0, 1))       -- 预定单上设定时间
		select @btime = @date0, @etime = dateadd(hh, 1, @date0)
	else
		begin
		if @shift = '1'
			select @btime = dateadd(hh, 7, @date0), @etime = dateadd(hh, 8, @date0)
		else if @shift = '2'
			select @btime = dateadd(hh, 11, @date0), @etime = dateadd(hh, 12, @date0)
		else if @shift = '3'
			select @btime = dateadd(hh, 18, @date0), @etime = dateadd(hh, 19, @date0)
		else
			select @btime = dateadd(hh, 18, @date0), @etime = dateadd(hh, 19, @date0)
		end
	if update(date0)
		begin
		if not exists(select 1 from pos_tblav where menu = @resno)
			insert pos_tblav(menu,tableno,inumber,empno,bdate,shift,sta,begin_time,end_time,pcrec,amount)
				select resno, tableno, 0, empno, convert(datetime, convert(char(8),date0,1)), shift,'1',convert(datetime, convert(char(8),date0,1)),null,'',0 from inserted
		end
	-- 可能一单有多台
	update pos_tblav set shift = inserted.shift,bdate = convert(datetime,convert(char(12),inserted.date0,12)),begin_time = inserted.date0 from pos_tblav,inserted where pos_tblav.menu = inserted.resno

	if exists(select 1 from inserted where rtrim(tableno) <> null)        --  预定到桌号
		begin
		delete pos_tblav from pos_tblav,inserted where pos_tblav.menu = inserted.resno and pos_tblav.tableno = inserted.tableno
		insert pos_tblav(menu,tableno,inumber,empno,bdate,shift,sta,begin_time,end_time,pcrec,amount)
		select resno, tableno, 0, empno, convert(datetime, convert(char(8),date0,1)), shift,'1',convert(datetime, convert(char(8),date0,1)),null,'',0 from inserted
		end
	end
if update(sta)         -- 状态变化，注意删除时是否有定金
	if exists(select 1 from inserted a, pos_pay b where a.resno = b.menu and a.sta = '0' and b.sta = '1' and charindex(b.crradjt, 'C CO') = 0 and rtrim(b.menu0) is null)
		begin
		select @msg = "该预定单有定金输入，不能删除！"
		rollback trigger with raiserror 20000 @msg
		end


;