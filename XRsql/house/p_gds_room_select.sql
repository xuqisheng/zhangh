if object_id('p_gds_room_select') is not null
drop proc p_gds_room_select
;
create proc p_gds_room_select
   @accnt      char(10),
	@shall		varchar(20),
	@sflr			varchar(30),
   @stype    	varchar(255),
   @brm_no		varchar(20),
	@sfeature	varchar(30),
   @s_time		datetime,
   @e_time		datetime,
   @roption    char(20),		-- ����ƴ�ӵ�����
	@is			char(20)			-- ��ʱû������
as
-- ----------------------------------------------------------------------------------
--	�ͷ�ѡ��
--		d_gds_room_select, uo_room_select\
--
--		2003.5.3  ���ȷ��Ԥ���͹���в�ͬ����ʾ��ȷ��==�� ���**
-- ----------------------------------------------------------------------------------
declare
   @type   		char(5),
  	@roomno		char(5),
	@blk_mark	int,
   @blk_mark1  int,
   @futmark	 	varchar(50),
   @futdate		datetime,
   @locked		char(1),
   @futbegin	datetime,
	@futend		datetime,
	@allow_d    char(1),
	@ocsta      char(1),
	@sta        char(1),
   @brmno      char(5),				-- ��ʼ�ķ���
   @brmnos     varchar(20),		-- �����ķ���
	@tmpsta		char(2),
	@tmpstades	varchar(8),
	@gdsblk		varchar(12),			-- ���linux. ����� Unix Ҳ���� char(12) - simon 20080416 
	@ptypes		varchar(255)

create table #rmsta_report
(
	roomno		char(5)					default '' not null,
	type		   char(5)					default '' not null,
	status		char(2) 					default '' null,
	blk_mark	   int    					default 0 null,
	futmark		varchar(50) 			default '' null,
	locked		char(1)					default '' null,
	gmark			char(12)  				default '' null
)

declare
	@futsta		char(1),		-- future sta 
	@p_all		char(1),		-- all room
	@p_oo			char(1),		-- ooo 
	@p_os			char(1),		-- oos 
	@p_occ		char(1),		-- occ
	@p_due		char(1),		-- not =due out, but = current occ 
	@p_r			char(1),		-- clear / clean / inspected
	@p_is			char(1),		-- inspected 
	@p_d			char(1),		-- dirty, touch up
	@p_tmp		char(1),		-- assignment
	@p_dayuse	char(1),		-- dayuse 
	@occ			char(1)		

-- �ٷ���ʾ����
select @ptypes = ','+isnull((select rtrim(value) from sysoption where catalog='hotel' and item='proom_pick'), '')+','

-- 
select @p_all 	= isnull(rtrim(substring(@roption,1,1)), 'F')
select @p_oo 	= isnull(rtrim(substring(@roption,2,1)), 'F')
select @p_os 	= isnull(rtrim(substring(@roption,3,1)), 'F')
select @p_occ 	= isnull(rtrim(substring(@roption,4,1)), 'F')
select @p_due 	= isnull(rtrim(substring(@roption,5,1)), 'F')		-- current occ.
select @p_r 	= isnull(rtrim(substring(@roption,6,1)), 'F')		-- vc
select @p_is 	= isnull(rtrim(substring(@roption,7,1)), 'F')
select @p_d 	= isnull(rtrim(substring(@roption,8,1)), 'F')		-- vd
select @p_tmp 	= isnull(rtrim(substring(@roption,9,1)), 'F')		-- day use 
select @p_dayuse 	= isnull(rtrim(substring(@roption,10,1)), 'F')

if @p_is='T' 	select @p_r='T'

select @s_time = convert(datetime, convert(char(10), @s_time, 111))
select @e_time = convert(datetime, convert(char(10), @e_time, 111))

-- ��ʼ����
if rtrim(@brm_no) is not null
   begin
	if charindex(',', @brm_no) > 0 	-- �������
		begin
		select @brmno = '', @brmnos = ','+@brm_no+','
		end
	else										-- һ������
		begin
		select @brmnos = '' 
		select @brmno = min(roomno) from rmsta where roomno >= @brm_no
		if @brmno is null
		  select @brmno = min(oroomno) from rmsta
		else
			select @brmno = oroomno from rmsta where roomno = @brmno
		end
   end
else
   select @brmno = '', @brmnos = ''

if rtrim(@shall) is null
	select @shall = ''
if rtrim(@sflr) is null
	select @sflr = ''
if rtrim(@stype) is null
	select @stype = ''
if rtrim(@sfeature) is null
	select @sfeature = ''

-- �Ƿ������෿��ס ?
select @allow_d = isnull(value,'N') from sysoption where catalog='reserve' and item ='allow_dirty_register_in'

-- ���ݷ������� ������
declare c_room_select cursor for
		select type,roomno,ocsta,sta, ref, futdate, locked, futsta, futbegin, futend, tmpsta
		from rmsta
		where oroomno >= @brmno and (@brmnos='' or charindex(','+rtrim(roomno)+',', @brmnos)>0)
			and (@stype='' or charindex(','+rtrim(type)+',', ','+@stype+',')>0) 
			and (@shall='' or charindex(','+rtrim(hall)+',',','+@shall+',')>0) 
			and (@sflr='' or charindex(','+rtrim(flr)+',',','+@sflr+',')>0) 
			and (@sfeature='' or feature like @sfeature)
			and (tag<>'P' or (tag='P' and  charindex(','+rtrim(type)+',', @ptypes)>0)) 
		order by oroomno
open  c_room_select
fetch c_room_select into @type,@roomno,@ocsta,@sta,@futmark, @futdate, @locked, @futsta, @futbegin, @futend, @tmpsta
while @@sqlstatus = 0
	begin

	-- �����ж� - 1	
	if @p_all <> 'T'
		begin
		-- �Ƿ���ռ�ã� -- һ����Ĺؼ�ѡ�� 
		-- ������ѡ��Ƿ���� dayuse �ĺ����ǲ�ͬ�� 
		if @p_occ = 'T' -- ѡ��ռ�÷� 
		begin
			if exists(select roomno from rsvsrc where type=@type and roomno=@roomno and begin_ < @e_time and end_ > @s_time and quantity>0 and accnt<>@accnt and begin_ <> end_)
				select @occ = 'T'
			else
			begin
				-- ���� dayuse  
				if @p_dayuse = 'T' and exists(select roomno from rsvsrc where type=@type and roomno=@roomno and begin_ <= @e_time and end_ >= @s_time and quantity>0 and accnt<>@accnt and begin_=end_)
					select @occ = 'T'  -- ѡ��ռ�÷���ʱ����ѡ�� dayuse, ��ô�� dayuse ����ռ�÷�  
				else
					select @occ = 'F'
			end 
		end
		else  -- ѡ���ռ�÷� 
		begin
			if exists(select roomno from rsvsrc where type=@type and roomno=@roomno and begin_ < @e_time and end_ > @s_time and quantity>0 and accnt<>@accnt and begin_ <> end_)
				select @occ = 'T'
			else
			begin
				-- ���� dayuse  
				if @p_dayuse = 'F' and exists(select roomno from rsvsrc where type=@type and roomno=@roomno and begin_ <= @e_time and end_ >= @s_time and quantity>0 and accnt<>@accnt and begin_=end_)
					select @occ = 'T'  -- ѡ���ռ�÷���ʱ��û��ѡ�� dayuse, ��ô�� dayuse ����ռ�÷�  
				else
					select @occ = 'F'
			end 
		end
		
		-- ��Թؼ�ѡ����ж� - �Ƿ�ռ�� 
		if (@p_occ='T' and @occ='F') or (@p_occ='F' and @occ='T')
			begin
			fetch c_room_select into @type,@roomno,@ocsta,@sta,@futmark, @futdate, @locked, @futsta, @futbegin, @futend, @tmpsta
			continue
			end

		if not (	(@p_r='T' and @sta in ('R','I') and (@p_is='F' or @sta='I'))
					or (@p_d='T' and @sta in ('D','T'))
					or (@p_oo='T' and (@sta='O' ) and @futbegin < @e_time and (@futend > @s_time or @futend is null))
					or (@p_os='T' and (@sta='S' ) and @futbegin < @e_time and (@futend > @s_time or @futend is null))
	--				or (@p_oo='T' and (@sta='O' or @futsta='O') and @futbegin < @e_time and (@futend > @s_time or @futend is null))
	--				or (@p_os='T' and (@sta='S' or @futsta='S') and @futbegin < @e_time and (@futend > @s_time or @futend is null))
					)
			begin
			fetch c_room_select into @type,@roomno,@ocsta,@sta,@futmark, @futdate, @locked, @futsta, @futbegin, @futend, @tmpsta
			continue
			end
	
		-- �����ж� - 2 - ȥ����ʱ̬. ��ʱ̬�Ŀͷ�Ӧ��ֻ�����Ƶ����Ԥ�� 
		if @p_tmp='F' and @tmpsta<>'' and datediff(dd,getdate(),@s_time)=0 
			begin
			fetch c_room_select into @type,@roomno,@ocsta,@sta,@futmark, @futdate, @locked, @futsta, @futbegin, @futend, @tmpsta
			continue
			end
	
		-- �����ж� - 3 - ���� ��ǰ��ס(����Ԥ��) - ֻ�Ե��շַ���Ч 
		if datediff(dd, @s_time, getdate())=0 and @p_due='F' and @ocsta='O' 
			begin
			fetch c_room_select into @type,@roomno,@ocsta,@sta,@futmark, @futdate, @locked, @futsta, @futbegin, @futend, @tmpsta
			continue
			end

		end

   select @blk_mark=0, @gdsblk=space(12)

	-- ��������Ԥ��
--	if exists(select roomno from rsvsrc where type=@type and roomno=@roomno and begin_ <= @e_time and end_ >= @s_time and quantity>0 and accnt<>@accnt)  -- simon 2006/12/14 �����䵼��ֻҪ���ž���ʾΪ���� [--]
	if exists(select roomno from rsvsrc where type=@type and roomno=@roomno and begin_ < @e_time and end_ > @s_time and quantity>0 and accnt<>@accnt)
		begin

		select @blk_mark = 2, @gdsblk='    [--]    '
		--  vip ?
--		if exists(select 1 from guest a rsvsrc b where a.vip>'0' and a.no=b.haccnt and b.type=@type and b.roomno=@roomno and begin_ < @e_time and end_ > @s_time and b.quantity>0 and b.accnt<>@accnt)
--			select @blk_mark = 8, @gdsblk='    [**]    '
		end
	else
		begin
		if not exists(select 1 from rsvsrc a, rmsta b where a.roomno=b.roomno and a.type=@type and a.roomno=@roomno and a.quantity>0 and a.accnt<>@accnt)
		   select @blk_mark = 0, @gdsblk=space(12)
   	else
		   begin
			-- ����
		   if exists(select 1 from rsvsrc where type = @type and roomno=@roomno and end_ = @s_time and quantity>0 and accnt<>@accnt)
				begin
				select @blk_mark1 = 3, @gdsblk=stuff(@gdsblk, 1, 4, '----')
				end
		   else if exists(select 1 from rsvsrc where type = @type and roomno=@roomno and end_ < @s_time and quantity>0 and accnt<>@accnt)
				begin				
			  	select @blk_mark1 = 33, @gdsblk=stuff(@gdsblk, 1, 4, '--  ')
				end
		   else
				select @blk_mark1 = 0

			-- �ҿ���
		   if exists(select roomno from rsvsrc where type = @type and roomno=@roomno and begin_ = @e_time and quantity> 0 and accnt<>@accnt)
				begin
				select @blk_mark = 1, @gdsblk=stuff(@gdsblk, 9, 4, '----')
				end
		   else if exists(select roomno from rsvsrc where type = @type and roomno=@roomno and begin_ > @e_time and quantity> 0 and accnt<>@accnt)
				begin
				select @blk_mark = 11, @gdsblk=stuff(@gdsblk, 9, 4, '  --')
				end
		   else
			  select @blk_mark = 0

		   if @blk_mark1 <> 0
		      if @blk_mark = 0
			   	select @blk_mark=@blk_mark1
		      else
					select @blk_mark=convert(int,ltrim(str(@blk_mark))+ltrim(str(@blk_mark1)))
		  	end
		end
	
	-- ռ�ñ�־�����м���-- ����α�ʶ�� []
	if @gdsblk<>space(12)
		begin
		select @gdsblk=stuff(@gdsblk, 5, 1, '[')
		select @gdsblk=stuff(@gdsblk, 8, 1, ']')
		end

	-- ��ʱ̬���� add to futmark		
	if @tmpsta is null select @tmpsta=''
	if @tmpsta<>''
		begin
		select @tmpstades=descript from rmstalist1 where code=rtrim(@tmpsta)
		select @futmark=@tmpstades + ' - ' + @futmark
		end
	-- ��������
	insert #rmsta_report
		select roomno, type, ocsta + sta, @blk_mark, @futmark, @locked, isnull(@gdsblk,'') 
			from rmsta where roomno=@roomno

	 fetch c_room_select into @type,@roomno,@ocsta,@sta,@futmark, @futdate, @locked, @futsta, @futbegin, @futend, @tmpsta
    end

close c_room_select
deallocate cursor c_room_select
--�ų�������ά�޵ķ���  gzby    yjw 2009/11/23
delete #rmsta_report  where roomno in (select roomno from rm_ooo where status='I' and ((@s_time>=dbegin and @s_time<=dend) or (@e_time>=dbegin and @e_time<=dend) or 
                            (dbegin>=@s_time and dend<=@e_time) ))
--gzby     yjw 2009/11/23

-- ������� (ע������)



select a.roomno,a.type,a.status,a.blk_mark,a.futmark,a.locked,a.gmark,gsele='F',b.feature,b.bedno
	from #rmsta_report a, rmsta b where a.roomno=b.roomno   order by b.sequence

return 0
;