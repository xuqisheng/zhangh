-- ------------------------------------------------------------------------------------
--  Forecast 
-- ------------------------------------------------------------------------------------
//if object_id('forecast') is not null
//	drop table forecast
//;
//create table forecast(
//	pc_id		char(4)			null,
//	id			int default 0	null,			-- ��Ŀ��־ - ���мӼ������ϵ
//	date		datetime			null,			-- ����
//	datedes	char(10)			null,			-- ���ڵ�����
//	sort		char(4)			null,			-- �����з���
//	type		char(5)			null,			-- ���� - Ϊ�˱�֤������Ҫ���ڷ����Ϸ������� like #%, �·������� like ZZ%
//													-- for the actual room type, it is typiml.sequence 
//	des		varchar(30)		null,			-- ��������
//	quan		money default 0	null		-- ����
//);

if object_id("p_gds_reserve_mkt_forecast") is not null
	drop proc p_gds_reserve_mkt_forecast;
create proc p_gds_reserve_mkt_forecast
	@s_time			datetime,       	-- ��ʼʱ��
	@e_time			datetime,       	-- ��ʼʱ��
	@langid			int=0,
	@types			char(255) = '%',		--����
	@pc_id			char(4)
as

declare 
			@id				int,
			@sort				char(2),
			@ttl				int,
			@value			int,
			@occ				int

if datediff(dd,@s_time,@e_time) > 31
	select @e_time  =dateadd(dd, 31, @s_time)    -- 30 days
else if datediff(dd,@s_time,@e_time) <= 0
	select @e_time  =dateadd(dd, 15, @s_time)    -- 15 days

delete from forecast where  pc_id = @pc_id
create table #mkt (code char(3) null, quan int null, sequence int null)

if exists(select 1 from sysoption where catalog = 'hotel' and item = 'allotment' and charindex(rtrim(value),'TYty') > 0 )
	exec p_zk_room_plan_check 'pcid',@s_time,@e_time,'%','D'

select @id = 1
while	@s_time <= @e_time
begin
  -- �ͷ�����
	select @value = sum(quantity) from typim where (charindex(type,@types) > 0 or @types = '%') and tag = 'K'
	if @langid=0
		insert forecast	values(@pc_id,@id, @s_time, '','#000', '#00', '   �ܷ���',	@value)
	else
		insert forecast	values(@pc_id,@id, @s_time, '','#000', '#00', '   Rooms Available',	@value)
	  
	-- ��ά��
	exec p_gds_reserve_rsv_index @s_time, @types, 'Out of Order', 'R', @value output
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', '#444', '#Z4', '   ��ά��', @value
	else
		insert forecast	select @pc_id,@id, @s_time, '', '#444', '#Z4', '   Rooms Out of Order', @value
	  
   -- ������
	exec p_gds_reserve_rsv_index @s_time, @types, 'Out of Service', 'R', @value output
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', '#445', '#Z4', '   ������', @value
	else
		insert forecast	select @pc_id,@id, @s_time, '', '#445', '#Z4', '   Rooms Outof Service', @value

---------------------------------------------------------------------------------------------------------
	-- ռ��  ���� - 1
---------------------------------------------------------------------------------------------------------
--	insert forecast
--		select @pc_id,@id, @s_time, '', right('0000'+rtrim(convert(char(10),a.sequence)),4), a.code, '',0
--			from mktcode a
--	update forecast set quan=quan + isnull((select sum(a.quantity) from rsvsrc a, master b 
--															where a.accnt=b.accnt and a.roomno='' and b.market=forecast.type
--																and a.begin_<=@s_time and a.end_>@s_time),0)
--		where date=@s_time
--	update forecast set quan=quan + isnull((select count(distinct a.roomno) from rsvsrc a, master b  -- ����䲻�ɹ��� why ? - gds
--															where a.accnt=b.accnt and a.roomno<>'' and b.market=forecast.type
--																and a.begin_<=@s_time and a.end_>@s_time),0)
--		where date=@s_time
---------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------
	-- ռ��  ���� - 2
---------------------------------------------------------------------------------------------------------
	truncate table #mkt
	insert #mkt select b.market, count(distinct a.roomno), 0 from rsvsrc_detail a, master b 
			where b.sta in ('I','R') and a.accnt=b.accnt and a.roomno<>'' and datediff(dd,a.arr,@s_time)>=0 and datediff(dd,a.dep,@s_time)<0 and a.date_=@s_time and (charindex(b.type,@types)>0 or @types = '%')
				group by b.market
	insert #mkt select code, 0, 0 from mktcode where code not in (select code from #mkt)
	delete #mkt from mktcode a where #mkt.code=a.code and a.flag='HSE'
	update #mkt set quan=quan + isnull((select count(distinct a.saccnt) from rsvsrc_detail a, master b 
															where b.sta in ('I','R') and a.accnt=b.accnt and a.roomno='' and b.market=#mkt.code and a.arr<>a.dep and a.quantity=1
																and datediff(dd,a.arr,@s_time)>=0 and datediff(dd,a.dep,@s_time)<0 and a.date_=@s_time and (charindex(b.type,@types)>0 or @types = '%')),0)														 
									  + isnull((select sum(a.quantity) from rsvsrc_detail a, master b 
															where b.sta in ('I','R') and a.accnt=b.accnt and a.roomno='' and b.market=#mkt.code and a.arr<>a.dep and a.quantity>1
																and datediff(dd,a.arr,@s_time)>=0 and datediff(dd,a.dep,@s_time)<0 and a.date_=@s_time and (charindex(b.type,@types)>0 or @types = '%')),0)
									  + isnull((select sum(a.quantity) from rsvsrc a, sc_master b 
															where a.accnt=b.accnt and a.roomno='' and b.market=#mkt.code and a.begin_<>a.end_
																and a.begin_<=@s_time and a.end_>@s_time and (charindex(b.type,@types)>0 or @types = '%')),0)
	update #mkt set sequence = b.sequence from mktcode a,basecode b where rtrim(#mkt.code) = rtrim(a.code) 
						and rtrim(a.grp) = rtrim(b.code) and b.cat = 'market_cat' 
	--update #mkt set sequence = a.sequence from mktcode a where #mkt.code=a.code
	select @occ = isnull((select sum(quan) from #mkt), 0)  -- ��ռ��
	insert forecast select @pc_id,@id, @s_time, '', right('0000'+rtrim(convert(char(10),a.sequence)),4), a.code, '',quan
			from #mkt a 

---------------------------------------------------------------------------------------------------------
	

	-- HU
	exec p_gds_reserve_rsv_index @s_time, @types, 'HSE', 'R', @value output
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', '#500', '', '   ���÷�', @value
	else
		insert forecast	select @pc_id,@id, @s_time, '', '#500', '', '   House Use', @value
	
	-- ���յ�
	exec p_gds_reserve_rsv_index @s_time, @types, 'Arrival Rooms', 'R', @value output
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ20', 'ZZ2', '   ���յ�', @value
	else
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ20', 'ZZ2', '   Arrival', @value
	
	-- ������
	exec p_gds_reserve_rsv_index @s_time, @types, 'Departure Rooms', 'R', @value output
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ30', 'ZZ3','   ������', @value
	else
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ30', 'ZZ3', '   Departure', @value


	-- �ڵ���� Guest in house
	exec p_gds_reserve_rsv_index @s_time, @types, 'People In-House-HU', 'R', @value output
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', '#892', '#ZZ6','   �ڵ����', @value
	else
		insert forecast	select @pc_id,@id, @s_time, '', '#892', '#ZZ6', '   Guest In House', @value

//	-- Room Revenue
//	exec p_gds_reserve_rsv_index @s_time, '%', 'Room Revenue','R', @value output
//	if @langid=0
//		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ90', 'ZZ6', '   �ͷ�����', @value
//	else
//		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ90', 'ZZ6', '   Gross Rooms Revenue', @value

	-- Room Revenue Net
	exec p_gds_reserve_rsv_index @s_time, @types, 'Room Revenue Net','R', @value output
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ91', 'ZZ6', '   ���ͷ�����', @value
	else
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ91', 'ZZ6', '   Net Net Revenue', @value
	if @occ <> 0 
		select @value = round(@value/@occ, 2)
	else
		select @value = 0
	-- Average Room Rate-1
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ96', 'ZZ6', '   ƽ������', @value
	else
		insert forecast	select @pc_id,@id, @s_time,'', 'ZZ96', 'ZZ6', '   Net Net AVR', @value

	-- Room Revenue Include SVC
	exec p_gds_reserve_rsv_index @s_time, @types, 'Room Revenue Include SVC','R', @value output
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ92', 'ZZ6', '   ���ͷ�����+SVC', @value
	else
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ92', 'ZZ6', '   Net Rooms Revenue', @value
	if @occ <> 0 
		select @value = round(@value/@occ, 2)
	else
		select @value = 0
	-- Average Room Rate-2
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ97', 'ZZ6', '   ƽ������+SVC', @value
	else
		insert forecast	select @pc_id,@id, @s_time,'', 'ZZ97', 'ZZ6', '   Net Average Rate', @value

	-- Room Revenue Include Package
	exec p_gds_reserve_rsv_index @s_time, @types, 'Room Revenue Include Packages','R', @value output
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ93', 'ZZ6', '   ���ͷ�����+SVC+PAK', @value
	else
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ93', 'ZZ6', '   Gross Rooms Revenue', @value
	if @occ <> 0 
		select @value = round(@value/@occ, 2)
	else
		select @value = 0
	-- Average Room Rate-3
	if @langid=0
		insert forecast	select @pc_id,@id, @s_time, '', 'ZZ98', 'ZZ6', '   ƽ������+SVC+PAK', @value
	else
		insert forecast	select @pc_id,@id, @s_time,'', 'ZZ98', 'ZZ6', '   Gross Average Rate', @value
	
	-- ��
//	if exists (select 1 from sysoption where catalog = 'hotel' and item = 'lic_buy.1' and charindex(',allot,',','+rtrim(value)+',') > 0)
//			or exists (select 1 from sysoption where catalog = 'hotel' and item = 'lic_buy.2' and charindex(',allot,',','+rtrim(value)+',') > 0)
	if exists(select 1 from sysoption where catalog = 'hotel' and item = 'allotment' and charindex(rtrim(value),'TYty') > 0 )
		begin
		if @langid=0 
			insert forecast	select @pc_id,@id, @s_time, '', 'ZZ99', 'ZZ8', '   ʣ����(ɢ��)', sum(leftn) from rsv_plan_check where date = @s_time and leftn >= 0 and class = 'F' and pc_id = 'pcid'
		else
			insert forecast	select @pc_id,@id, @s_time,'', 'ZZ99', 'ZZ8', '   Avl. Allotment(FIT)', sum(leftn) from rsv_plan_check where date = @s_time and leftn >= 0 and class = 'F' and pc_id = 'pcid'

		if @langid=0
			insert forecast	select @pc_id,@id, @s_time, '', 'ZZZ9', 'ZZ9', '   ʣ����(�Ŷ�)', sum(leftn) from rsv_plan_check where date = @s_time and leftn >= 0 and class = 'G' and pc_id = 'pcid'
		else
			insert forecast	select @pc_id,@id, @s_time,'', 'ZZZ9', 'ZZ9', '   Avl. Allotment(GRP)', sum(leftn) from rsv_plan_check where date = @s_time and leftn >= 0 and class = 'G' and pc_id = 'pcid'
		end

	-- Next Date
	select @s_time = dateadd(day, 1, @s_time)
	select @id = @id + 1
end

insert forecast select distinct @pc_id,id,date,datedes,sort,'','С��'
		,sum(quan) from forecast  where sort not like '#%' and sort not like 'Z%' and type <> '' and pc_id = @pc_id group by date,sort
update forecast set des = 'С�� '+rtrim((select max(grp) from mktcode a,forecast b where rtrim(b.type) = rtrim(a.code) and pc_id = @pc_id and b.sort = forecast.sort ))+'--------------------------'
 where sort not like '#%' and sort not like 'Z%' and type = '' and pc_id = @pc_id

-- ��ռ�� 
if @langid=0
	insert forecast
		select @pc_id,id, date, '', '#890', 'ZZ5', '   ��ռ��', sum(quan)
			from forecast where sort not like 'ZZ%' and sort not like '#%' and type <> '' and pc_id = @pc_id group by id, date
else
	insert forecast
		select @pc_id,id, date, '', '#890', 'ZZ5', '   Rooms Occupied', sum(quan)
			from forecast where sort not like 'ZZ%' and sort not like '#%' and type <> '' and pc_id = @pc_id group by id, date

-- �ܴ��� -- ʣ����� = ���з���Ŀ��������
select @ttl = sum(quantity) from typim where (charindex(type,@types) > 0 or @types = '%') and tag = 'K'
if @langid=0
	insert forecast
		select @pc_id,id, date, '', '#895', 'ZZ1', '   �ܴ���', @ttl - isnull(sum(quan),0)
			from forecast where sort in ('#890','#444','#445','#500') and pc_id = @pc_id group by id, date
else
	insert forecast
		select @pc_id,id, date, '', '#895', 'ZZ1', '   Available', @ttl - isnull(sum(quan),0)
			from forecast where sort in ('#890','#444','#445','#500') and pc_id = @pc_id group by id, date

-- ���÷� = ttl - oo - os - hu
if @langid=0
	insert forecast
		select @pc_id,id, date, '', '#888', '#88', '   ���÷�', @ttl-sum(quan)
			from forecast where sort in ('#444','#500') and pc_id = @pc_id group by id, date
else
	insert forecast
		select @pc_id,id, date, '', '#888', '#88', '   Rooms Available for Sale', @ttl-sum(quan)
			from forecast where sort in ('#444','#500') and pc_id = @pc_id group by id, date

-- ռ����1
if @langid=0
	insert forecast
		select @pc_id,a.id, a.date, '', 'ZZ80', 'ZZZ', '   ռ����1(%)', 
				round(a.quan*100.0/(select b.quan from forecast b where a.date=b.date and b.sort='#000' and pc_id = @pc_id),2)
			from forecast a where a.sort='#890' and pc_id = @pc_id
else
	insert forecast
		select @pc_id,a.id, a.date, '','ZZ80', 'ZZZ', '   Occupancy1(%)', 
				round(a.quan*100.0/(select b.quan from forecast b where a.date=b.date and b.sort='#000' and pc_id = @pc_id),2)
			from forecast a where a.sort='#890' and pc_id = @pc_id

-- ռ����3
if @langid=0
	insert forecast
		select @pc_id,a.id, a.date, '', 'ZZ81', 'ZZZ', '   ռ����3(%)', 
				round(a.quan*100.0/(select b.quan from forecast b where a.date=b.date and b.sort='#888' and pc_id = @pc_id),2)
			from forecast a where a.sort='#890' and pc_id = @pc_id
else
	insert forecast
		select @pc_id,a.id, a.date, '','ZZ81', 'ZZZ', '   Occupancy3(%)', 
				round(a.quan*100.0/(select b.quan from forecast b where a.date=b.date and b.sort='#888' and pc_id = @pc_id),2)
			from forecast a where a.sort='#890' and pc_id = @pc_id


if @langid=0
	update forecast set des = a.code+':'+rtrim(a.descript)
		from mktcode a where forecast.type=a.code and pc_id = @pc_id
else
	update forecast set des = a.code+':'+rtrim(a.descript1)
		from mktcode a where forecast.type=a.code and pc_id = @pc_id

update forecast set datedes=convert(char(2),date,3) + '(S)'
	where datepart(weekday,date) = 1 and pc_id = @pc_id
update forecast set datedes=convert(char(2),date,3) + '(M)'
	where datepart(weekday,date) = 2 and pc_id = @pc_id
update forecast set datedes=convert(char(2),date,3) + '(T)'
	where datepart(weekday,date) = 3 and pc_id = @pc_id
update forecast set datedes=convert(char(2),date,3) + '(W)'
	where datepart(weekday,date) = 4 and pc_id = @pc_id
update forecast set datedes=convert(char(2),date,3) + '(T)'
	where datepart(weekday,date) = 5 and pc_id = @pc_id
update forecast set datedes=convert(char(2),date,3) + '(F)'
	where datepart(weekday,date) =6 and pc_id = @pc_id
update forecast set datedes=convert(char(2),date,3) + '(S)'
	where datepart(weekday,date) = 7 and pc_id = @pc_id

-- ����ϼƵ�����
insert forecast   -- Insert a row
	select @pc_id,99,'2020.01.01','TOTAL',sort,type,des,0 from forecast where id = 1 and pc_id = @pc_id
update forecast set quan = isnull((select sum(b.quan) from forecast b      -- summary
					where b.sort=forecast.sort and b.type=forecast.type and pc_id = @pc_id),0) 
	where date='2020.01.01'  and pc_id = @pc_id
-- Occupancy3
select @value = b.quan from forecast b where b.sort='#888' and b.date='2020.01.01' and pc_id = @pc_id  
if @value<> 0   
	update forecast set quan = round((select b.quan from forecast b where b.sort='#890' and b.date='2020.01.01' and pc_id = @pc_id)*100/@value,2)
		where datedes='TOTAL' and sort='ZZ81' and pc_id = @pc_id
-- Occupancy1
select @value = b.quan from forecast b where b.sort='#000' and b.date='2020.01.01'  and pc_id = @pc_id 
if @value<> 0   
	update forecast set quan = round((select b.quan from forecast b where b.sort='#890' and b.date='2020.01.01' and pc_id = @pc_id)*100/@value,2)
		where datedes='TOTAL' and sort='ZZ80' and pc_id = @pc_id
-- AVR
select @value = b.quan from forecast b where b.sort='#890' and b.date='2020.01.01' and pc_id = @pc_id
if @value<> 0
begin
	update forecast set quan = ROUND((select b.quan from forecast b where b.sort='ZZ91' and b.date='2020.01.01' and pc_id = @pc_id)/@value,0)
		where datedes='TOTAL' and sort='ZZ96' and pc_id = @pc_id
	update forecast set quan = ROUND((select b.quan from forecast b where b.sort='ZZ92' and b.date='2020.01.01' and pc_id = @pc_id)/@value,0)
		where datedes='TOTAL' and sort='ZZ97' and pc_id = @pc_id
	update forecast set quan = ROUND((select b.quan from forecast b where b.sort='ZZ93' and b.date='2020.01.01' and pc_id = @pc_id)/@value,0)
		where datedes='TOTAL' and sort='ZZ98' and pc_id = @pc_id
end

return 0;
