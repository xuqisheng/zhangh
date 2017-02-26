if  exists(select * from sysobjects where name = "p_gds_reserve_type_rsv_tend" and type = "P")
	drop proc p_gds_reserve_type_rsv_tend
;
create proc p_gds_reserve_type_rsv_tend
	@rm_type    	varchar(255),		-- ����ʾ�����ַ������, ��Ϊ"",���ʾ��ʾ���з���
	@s_time			datetime,       	-- ��ʼʱ��
	@e_time			datetime,       	-- ����ʱ��
	@entry			char(1),				-- ��ѯ���ݣ�Y-Ԥ����W-ά�ޣ�K-���� R-Ԥ��, D-���յ���, S-����
	@tentative		char(1)	= 'T'	,	-- ������ȷ��
	@pc_id			char(4)
as
update typim set sequence = 10 where sequence = 0
select @s_time = convert(datetime, convert(char(10), @s_time, 111))
select @e_time = convert(datetime, convert(char(10), @e_time, 111))

-- ------------------------------------------------------------------------------------
--  ������ϸ����
-- ------------------------------------------------------------------------------------
create table #inventory
(
	date		datetime		null,
	type		char(5)		null,
	sequence	int			null,
	quan		int			null
)
create table #tmp
(
	type		char(5)		null,
	quan		int			null
)

declare 	@type 		char(5),
			@tennum		int

-- ƴ�ַ���
if @rm_type='%' 
begin
	select @rm_type='_'
	select @type=isnull((select min(type) from typim where type>'' and tag='K'), '')
	while @type <> ''
	begin
		select @rm_type = @rm_type+substring(@type+space(5), 1, 5)+'_'
		select @type=isnull((select min(type) from typim where type>@type and tag='K'), '')
	end
end

while	@s_time < @e_time
begin
----------------------------------------------------------------------------
	if @entry = 'Y'			--Ԥ��
----------------------------------------------------------------------------
	begin
		if @tentative = 'T' 
		begin
			insert #inventory select @s_time, a.type, 0, 
					quan=(select isnull(sum(b.blockcnt),0) from rsvtype b 
							where b.begin_ <= @s_time and b.end_ > @s_time and a.type = b.type)
				from typim a where charindex(a.type, @rm_type) > 0
			-- ������һ�� = ten
			insert #inventory select @s_time, 'TEN', 0, -- fo 
				 isnull((select sum(a.quantity) from rsvsaccnt a, master b
					where a.begin_<>a.end_ and a.begin_<=@s_time and a.end_>@s_time and charindex(a.type, @rm_type) > 0
						and a.accnt=b.accnt and b.restype not in (select code from restype where definite='T')),0)
			insert #inventory select @s_time, 'TEN', 0, -- sc 
				 isnull((select sum(a.quantity) from rsvsaccnt a, sc_master b
					where a.begin_<>a.end_ and a.begin_<=@s_time and a.end_>@s_time and charindex(a.type, @rm_type) > 0
						and b.foact='' and a.accnt=b.accnt and b.restype not in (select code from restype where definite='T')),0)
		end
		else
		begin
			insert #inventory -- fo
				select @s_time, a.type, 0, quan = isnull(sum(a.quantity),0) from rsvsaccnt a, master b
					where charindex(a.type,@rm_type)>0 and a.begin_<>a.end_ and a.begin_<=@s_time and a.end_>@s_time
						and a.accnt=b.accnt and b.restype in (select code from restype where definite='T')
					group by a.type
			insert #inventory -- sc 
				select @s_time, a.type, 0, quan = isnull(sum(a.quantity),0) from rsvsaccnt a, sc_master b
					where charindex(a.type,@rm_type)>0 and a.begin_<>a.end_ and a.begin_<=@s_time and a.end_>@s_time
						and b.foact='' and a.accnt=b.accnt and b.restype in (select code from restype where definite='T')
					group by a.type
			insert #inventory select @s_time, type, 0, 0 from typim 
				where type not in (select type from #inventory where date=@s_time) and tag='K' and charindex(type, @rm_type) > 0
			insert #inventory select @s_time, 'TEN', 0, 0
		end
	end

-------------------------------------------------------------------------------------------
	else if @entry = 'R'   	-- Ԥ�� = Ԥ�� - ��ǰռ�� (in sc_master, not exists in-house )
-------------------------------------------------------------------------------------------
	begin
		insert #inventory select @s_time,a.type, 0,
			quan=(select isnull(sum(b.blockcnt),0) from rsvtype b 
					where b.begin_ <= @s_time and b.end_ > @s_time and a.type = b.type)
				 - ( select count(1) from master c where c.sta='I' and c.type=a.type and c.class='F'
						and datediff(dd, @s_time, c.arr)<=0	and datediff(dd,@s_time,c.dep)>0)
		from typim a where charindex(a.type, @rm_type) > 0
		insert #inventory select @s_time, 'TEN', 0, 0
	end

----------------------------------------------------------------------------
	else if @entry = 'D' 	-- ����Ԥ������ = (δ�ַ� + �ַ�)
----------------------------------------------------------------------------
	begin
		insert #inventory select @s_time, 'TEN', 0, 0
-- 		if @tentative = 'T'  -- �����д���ڽ������ݷ��ִ���ԭ���ǵ�@rm_type�ж�������ʱ��distinct ������Ĵ����С�
-- 			insert #inventory 	
-- 				select 	@s_time, 
-- 							a.type, 0,
-- 							(isnull((select sum(c.quantity) from rsvsrc c where c.begin_=@s_time and c.begin_<>c.end_ and c.type=a.type and c.roomno=''),0) 
-- 							+ isnull((select count(distinct d.roomno) from rsvsrc d, master b where d.accnt=b.accnt and b.sta='R' and d.begin_=@s_time and d.begin_<>d.end_ and d.type=a.type and d.roomno<>''),0))
-- 					from typim a
-- 						where charindex(a.type, @rm_type) > 0
-- 		else
-- 			insert #inventory 	
-- 				select 	@s_time, 
-- 							a.type, 0,
-- 							(isnull((select sum(c.quantity) from rsvsrc c, master e where c.accnt=e.accnt and c.begin_=@s_time and c.begin_<>c.end_ and c.type=a.type and c.roomno='' and e.restype in (select g.code from restype g where g.definite='T')),0) 
-- 							+ isnull((select sum(h.quantity) from rsvsrc h, sc_master i where i.foact='' and h.accnt=i.accnt and h.begin_=@s_time and h.begin_<>h.end_ and h.type=a.type and h.roomno='' and i.restype in (select g.code from restype g where g.definite='T')),0) 
-- 							+ isnull((select count(distinct d.roomno) from rsvsrc d, master b where d.accnt=b.accnt and b.sta='R' and d.begin_=@s_time and d.begin_<>d.end_ and d.type=a.type and d.roomno<>'' and b.restype in (select h.code from restype h where h.definite='T')),0))
-- 					from typim a
-- 						where charindex(a.type, @rm_type) > 0
					
		if @tentative = 'T' 
		begin
			insert #inventory 
				select @s_time, a.type, 0, count(distinct d.roomno)
					from typim a, rsvsrc d, master b 
						where charindex(a.type, @rm_type) > 0 and d.accnt=b.accnt -- and b.sta='R' 
							and d.begin_=@s_time and d.begin_<>d.end_ and d.type=a.type and d.roomno<>''
						group by a.type 
			
			insert #inventory 
				select @s_time, a.type, 0, 0
					from typim a
						where charindex(a.type, @rm_type) > 0 and a.type not in (select type from #inventory where date=@s_time) 

			update #inventory set quan=quan+ isnull((select sum(c.quantity) from rsvsrc c where c.begin_=@s_time and c.begin_<>c.end_ and c.type=#inventory.type and c.roomno=''),0) 
				where date=@s_time 
		end 
		else
		begin
			insert #inventory 
				select @s_time, a.type, 0, count(distinct d.roomno)
					from typim a, rsvsrc d, master b, restype h  
						where charindex(a.type, @rm_type) > 0 and d.accnt=b.accnt -- and b.sta='R' 
							and d.begin_=@s_time and d.begin_<>d.end_ and d.type=a.type and d.roomno<>''
							and b.restype=h.code and h.definite='T'
						group by a.type 
			
			insert #inventory 
				select @s_time, a.type, 0, 0
					from typim a
						where charindex(a.type, @rm_type) > 0 and a.type not in (select type from #inventory where date=@s_time) 

			update #inventory set quan=quan+ isnull((select sum(c.quantity) from rsvsrc c, master e, restype g where c.accnt=e.accnt and c.begin_=@s_time and c.begin_<>c.end_ and c.type=#inventory.type and c.roomno='' and e.restype=g.code and g.definite='T'),0) 
				where date=@s_time 

			update #inventory set quan=quan+ isnull((select sum(c.quantity) from rsvsrc c, sc_master e, restype g where c.accnt=e.accnt and e.foact='SS' and c.begin_=@s_time and c.begin_<>c.end_ and c.type=#inventory.type and c.roomno='' and e.restype=g.code and g.definite='T'),0) 
				where date=@s_time 
		end
	end

----------------------------------------------------------------------------
	else if @entry = 'W'   -- ά��(ֱ�Ӵ� rmsta ����ȡ) OOO
----------------------------------------------------------------------------
	begin
		insert #inventory select @s_time, 'TEN', 0, 0

--		insert #inventory select @s_time, a.type, 0,
--			quan=(select isnull(count(1),0) from rmsta b where b.locked='L' and b.futbegin <= @s_time 
--						and (b.futend > @s_time or b.futend is null)	and a.type=b.type)
--		from typim a where charindex(a.type, @rm_type) > 0

--		��������ռ����Դ 
		insert #inventory select @s_time, a.type, 0,
			quan=(select isnull(count(1),0) from rm_ooo b, rmsta c where b.status='I' and b.sta='O' 
						and b.dbegin <= @s_time and b.dend > @s_time and b.roomno=c.roomno and a.type=c.type)
		from typim a where charindex(a.type, @rm_type) > 0
	end

----------------------------------------------------------------------------
	else if @entry = 'S'   -- ����(ֱ�Ӵ� rmsta ����ȡ) OS
----------------------------------------------------------------------------
	begin
		insert #inventory select @s_time, 'TEN', 0, 0

--		insert #inventory select @s_time, a.type, 0,
--			quan=(select isnull(count(1),0) from rmsta b where b.locked='L' and b.futbegin <= @s_time 
--						and (b.futend > @s_time or b.futend is null)	and a.type=b.type)
--		from typim a where charindex(a.type, @rm_type) > 0

--		��������ռ����Դ 
		insert #inventory select @s_time, a.type, 0,
			quan=(select isnull(count(1),0) from rm_ooo b, rmsta c where b.status='I' and b.sta='S' 
						and b.dbegin <= @s_time and b.dend > @s_time and b.roomno=c.roomno and a.type=c.type)
		from typim a where charindex(a.type, @rm_type) > 0
	end

----------------------------------------------------------------------------
	else						-- ���� = ���� �� Ԥ�� �� ά�� . ������ʾ����������˲��ܿۼ� OS 
----------------------------------------------------------------------------
	begin
		-- ���Ȳ���Ԥ��
		if @tentative = 'T' 
		begin
			insert #inventory select @s_time, a.type, 0,
				quan=(select isnull(sum(b.blockcnt),0) from rsvtype b 
						where b.begin_ <= @s_time and b.end_ > @s_time and a.type = b.type)
			from typim a where charindex(a.type, @rm_type) > 0
			-- ������һ�� = ten
			select @tennum = isnull((select sum(a.quantity) from rsvsaccnt a, master b		-- fo 
					where a.begin_<>a.end_ and a.begin_<=@s_time and a.end_>@s_time and charindex(a.type, @rm_type) > 0
						and a.accnt=b.accnt and b.restype not in (select code from restype where definite='T')),0)
			select @tennum = @tennum + isnull((select sum(a.quantity) from rsvsaccnt a, sc_master b	-- sc 
					where a.begin_<>a.end_ and a.begin_<=@s_time and a.end_>@s_time and charindex(a.type, @rm_type) > 0
						and b.foact='' and a.accnt=b.accnt and b.restype not in (select code from restype where definite='T')),0)
			insert #inventory select @s_time, 'TEN', 0, @tennum 
		end
		else
		begin
			delete #tmp 
			insert #tmp 	-- fo
				select a.type, quan = isnull(sum(a.quantity),0) from rsvsaccnt a, master b
					where charindex(a.type,@rm_type)>0 and a.begin_<>a.end_ and a.begin_<=@s_time and a.end_>@s_time
						and a.accnt=b.accnt and b.restype in (select code from restype where definite='T')
					group by a.type
			insert #tmp 	-- sc 
				select a.type, quan = isnull(sum(a.quantity),0) from rsvsaccnt a, sc_master b
					where charindex(a.type,@rm_type)>0 and a.begin_<>a.end_ and a.begin_<=@s_time and a.end_>@s_time
						and b.foact='' and a.accnt=b.accnt and b.restype in (select code from restype where definite='T')
					group by a.type
			insert #inventory select @s_time, type,0, isnull(sum(quan),0) from #tmp group by type 
			insert #inventory select @s_time, a.type,0, 0 from typim a
				where a.type not in (select b.type from #inventory b where b.date=@s_time) and a.tag='K' and charindex(a.type, @rm_type) > 0
			insert #inventory select @s_time, 'TEN', 0, 0
		end

		update #inventory	set #inventory.quan =(select b.quantity from typim b where #inventory.type=b.type) - #inventory.quan 
			where #inventory.date = @s_time and #inventory.type<>'TEN'

		--	ά�޷�����ȡ���� rm_ooo 
--		update #inventory	set #inventory.quan = #inventory.quan - isnull((select isnull(count(1),0)
--							from rmsta b where  b.locked='L' and b.futbegin <= @s_time and (b.futend > @s_time or b.futend is null)
--								and #inventory.type=b.type	),0)
--			where #inventory.date = @s_time and #inventory.type<>'TEN'
		update #inventory	set #inventory.quan = #inventory.quan - isnull((select isnull(count(1),0)
							from rm_ooo b, rmsta c where  b.status='I' and b.sta='O' 
								and b.dbegin <= @s_time and b.dend > @s_time and b.roomno=c.roomno 
								and #inventory.type=c.type	),0)
			where #inventory.date = @s_time and #inventory.type<>'TEN'
	end

	select @s_time = dateadd(day, 1, @s_time)
end

----------------------------------------------------------------------------
-- output
----------------------------------------------------------------------------
update #inventory set sequence = a.sequence from typim a where rtrim(#inventory.type)=rtrim(a.type)
-- ��λ�����, �Լ�����
-- select type, convert(char(8),date,11)+'-'+convert(char(1),datepart(weekday, date)-1), quan  from #inventory order by date, type

-- ���׵����ڱ�ʾ + ���������
--select a.type+'--'+b.descript, convert(char(5),a.date,1), a.quan 

--
delete from inventory where pc_id = @pc_id
insert inventory select a.date,a.type,a.sequence,a.quan,@pc_id
	from #inventory a order by a.date, a.sequence
-- insert inventory select distinct '2099-1-1',type,sequence, sum(quan),@pc_id from inventory where pc_id=@pc_id group by type
insert inventory select date,'Sum',0,sum(quan),@pc_id from inventory where pc_id=@pc_id group by date


select a.date,a.type,a.sequence,a.quan
	from #inventory a order by a.date, a.sequence

return 0
;