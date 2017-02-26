if exists(select 1 from sysobjects where name = "p_gds_reserve_rsv_index")
	drop proc p_gds_reserve_rsv_index;
create proc p_gds_reserve_rsv_index
	@date			datetime,
	@types		varchar(255),
	@index		varchar(30),   -- ͳ��ָ��
	@retmode		char(1)='R',
	@result		money		output
as
-----------------------------------------------
--		ϵͳ�ͷ���Դ����ͳ��ָ�� 
--
--		�ù�����Ҫ�� p_gds_reserve_rsv_index_list ����һ�� 
-----------------------------------------------
--	����˵��
--			@types: ��֤��λ���೤�ȣ��ٷֺŷָ�. eg.  %BJ %HHT%ZTD%
--				---> ��֤������ʹ��
--
--		�����������ָ�����໥�Ĺ�ϵ����proc����Ƕ�����á�
--
-----------------------------------------------
declare		@mm1			money,
				@mm2			money,
				@mm3			money,
				@type			char(5),
				@bdate		datetime,
				@resno 		char(6),
				@duin			char(1)

select @result=0, @bdate = bdate1 from sysdata
select @resno = substring(convert(char(8),@date,112),3,6)
select @duin=value from sysoption where catalog='reserve' and item='day_use_in'

-- ƴ�ַ���
if @types='%' 
begin
	select @types='_'
	select @type=isnull((select min(type) from typim where type>'' and tag='K'), '')
	while @type <> ''
	begin
		select @types = @types+substring(@type+space(5), 1, 5)+'_'
		select @type=isnull((select min(type) from typim where type>@type and tag='K'), '')
	end
end

-------------------------------------------
--	�ܷ���
-------------------------------------------
if @index = 'Total Rooms' 
begin	 -- Ŀǰ��û��δ�����ĸ���
	select @result = count(1) from rmsta where charindex(type,@types)>0 and tag='K' 
end

-------------------------------------------
--	ά�޷� 
-------------------------------------------
else if @index = 'Out of Order'
begin
	select @result= count(1) from rmsta where locked='L' and futbegin<=@date and (futend > @date or futend is null)	
			and (sta='O' or futsta='O') and charindex(type,@types)>0 and tag='K' 
end

-------------------------------------------
-- ������
-------------------------------------------
else if @index = 'Out of Service'		
begin
	select @result=count(1) from rmsta where locked='L' and futbegin<=@date and (futend > @date or futend is null)	
			and (sta='S' or futsta='S') and charindex(type,@types)>0 and tag='K' 
end

-------------------------------------------
-- ������ = �ܷ��� - ά�޷� (���ܼ�ȥ��ά������ ???)
-------------------------------------------
else if @index = 'Room to Rent'
begin
	exec p_gds_reserve_rsv_index @date, @types, 'Total Rooms', 'R', @mm1 output
	exec p_gds_reserve_rsv_index @date, @types, 'Out of Order', 'R', @mm2 output
	exec p_gds_reserve_rsv_index @date, @types, 'HSE', 'R', @mm3 output

	select @result = @mm1 - @mm2 - @mm3

--	select @result = isnull((select sum(blockcnt) from rsvtype 
--			where begin_ <= @date and end_ > @date and charindex(type,@types)>0),0)
end

-------------------------------------------
--	��ѷ�
-------------------------------------------
else if @index = 'COM'
begin
	select @result = isnull((select sum(a.quantity) from rsvsaccnt a, master b, mktcode c 
		where a.accnt=b.accnt and b.market=c.code and c.flag='COM'
			and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0
		),0)
end

-------------------------------------------
--	���÷�
-------------------------------------------
else if @index = 'HSE'
begin
	select @result = isnull((select sum(a.quantity) from rsvsaccnt a, master b, mktcode c 
		where a.accnt=b.accnt and b.market=c.code and c.flag='HSE'
			and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0
		),0)
end

-------------------------------------------
--	���÷�����
-------------------------------------------
else if @index = 'PN_HSE'
begin
	select @result = isnull((select sum(a.gstno*a.quantity) 
		from rsvsrc a, master b, mktcode c 
		 where a.accnt=b.accnt and b.market=c.code and c.flag='HSE' 
			and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno*a.quantity) 
		from rsvsrc a, sc_master b, mktcode c 
		 where b.foact='' and a.accnt=b.accnt and b.market=c.code and c.flag='HSE' 
			and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
end


-----------------------------------------------------------------
-- ȷ��Ԥ���ͷ� ( Include Checked/In, Not include day-use)
-----------------------------------------------------------------
else if @index = 'Definite Reservations'
begin
	select @result = isnull((select sum(a.quantity) from rsvsaccnt a, master b
		where charindex(a.type,@types)>0 and a.begin_<>a.end_ and a.begin_<=@date and a.end_>@date
			and a.accnt=b.accnt and b.restype in (select code from restype where definite='T')),0)
	select @result = @result + isnull((select sum(a.quantity) from rsvsaccnt a, sc_master b
		where charindex(a.type,@types)>0 and a.begin_<>a.end_ and a.begin_<=@date and a.end_>@date
			and a.accnt=b.accnt and b.restype in (select code from restype where definite='T')),0)
end

-------------------------------------------
--	��ȷ��Ԥ�� ( Not include day-use)
-------------------------------------------
else if @index = 'Tentative Reservation'
begin
	select @result = isnull((select sum(a.quantity) from rsvsaccnt a, master b
		where charindex(a.type,@types)>0 and a.begin_<>a.end_ and a.begin_<=@date and a.end_>@date
			and a.accnt=b.accnt and b.restype not in (select code from restype where definite='T')),0)
	select @result = @result + isnull((select sum(a.quantity) from rsvsaccnt a, sc_master b
		where charindex(a.type,@types)>0 and a.begin_<>a.end_ and a.begin_<=@date and a.end_>@date
			and a.accnt=b.accnt and b.restype not in (select code from restype where definite='T')),0)
end

-------------------------------------------
-- ���÷� = ������ - ȷ��Ԥ���ͷ�
-------------------------------------------
else if @index = 'Available Rooms'
begin
	exec p_gds_reserve_rsv_index @date, @types, 'Room to Rent', 'R', @mm1 output
	exec p_gds_reserve_rsv_index @date, @types, 'Definite Reservations', 'R', @mm2 output
	select @result = @mm1 - @mm2
end

-------------------------------------------
--	��С���÷� = ���÷� - ��ȷ��Ԥ��
-------------------------------------------
else if @index = 'Minimum Availability'
begin
	exec p_gds_reserve_rsv_index @date, @types, 'Available Rooms', 'R', @mm1 output
	exec p_gds_reserve_rsv_index @date, @types, 'Tentative Reservation', 'R', @mm2 output
	select @result = @mm1 - @mm2
end

-------------------------------------------
--	��Ԥ����Ŀ 1 : �����Ƶ귶��Ľ綨
-------------------------------------------
else if @index = 'House Overbooking'
begin
	-- ������ȡ����ĳ�Ԥ�� 
	exec p_gds_reserve_rsv_index @date, @types, 'Room Type Overbooking', 'R', @mm1 output
	
	if exists(select 1 from sysoption where catalog = "reserve" and item = "cntlblock" and charindex(substring(value,1,1), 'TtYy')>0) 
	begin  -- ������������ 
		select @result = overbook from rsvlimit where date=@date and gtype='' and type='' 
		if @@rowcount=0 
			select @result = convert(int,value) from sysoption where catalog = "reserve" and item = "cntlquan"
		if @mm1 < @result 
			select @result = @mm1 
	end 
	else 
		select @result = @mm1 

	if @result is null or @result < 0
		select @result = 0
end

-------------------------------------------
--	��Ԥ����Ŀ 2 : ���෶��Ľ綨
-------------------------------------------
else if @index = 'Room Type Overbooking'
begin
	select @result = 0, @type = isnull((select min(type) from typim where charindex(type,@types)>0 and tag<>'P'), '') 
	while @type <> ''
	begin 
		if exists(select 1 from rsvlimit where date=@date and type=@type)
			select @result = @result + overbook from rsvlimit where date=@date and type=@type
		else 
			select @result = @result + overquan from typim where type=@type
		select @type = isnull((select min(type) from typim where type>@type and charindex(type,@types)>0 and tag<>'P'), '') 
	end 
end

-------------------------------------------
--	�ɶ��� = ���÷� + ��Ԥ����Ŀ
-------------------------------------------
else if @index = 'Rooms to Sell'
begin
	exec p_gds_reserve_rsv_index @date, @types, 'Available Rooms', 'R', @mm1 output
	exec p_gds_reserve_rsv_index @date, @types, 'House Overbooking', 'R', @mm2 output
	select @result = @mm1 + @mm2
end

-------------------------------------------
--	���յ��� dayuse 
-------------------------------------------
else if @index = 'Day Use'
begin
	select @result = isnull((select sum(quantity) from rsvsrc 
		where charindex(type,@types)>0 and begin_=end_ and begin_=@date and roomno=''),0)
	select @result = @result + (select count(distinct roomno) from rsvsrc 
		where charindex(type,@types)>0 and begin_=end_ and begin_=@date and roomno<>'')
end
else if @index = 'Day Use Persons'
begin
	select @result = isnull((select sum(gstno*quantity) from rsvsrc 
		where charindex(type,@types)>0 and begin_=end_ and begin_=@date),0)
end

-------------------------------------------
--	��Ԥ���� = ȷ��Ԥ���ͷ� + ��ȷ��Ԥ��
-------------------------------------------
else if @index = 'Total Reserved'
begin
	exec p_gds_reserve_rsv_index @date, @types, 'Definite Reservations', 'R', @mm1 output
	exec p_gds_reserve_rsv_index @date, @types, 'Tentative Reservation', 'R', @mm2 output
	select @result = @mm1 + @mm2
end

-------------------------------------------
--	diff = ��Ԥ���� - ������
--	��Ԥ���� = if(diff>0, diff, 0)
-------------------------------------------
else if @index = 'Over Reserved'
begin
	exec p_gds_reserve_rsv_index @date, @types, 'Total Reserved', 'R', @mm1 output
	exec p_gds_reserve_rsv_index @date, @types, 'Room to Rent', 'R', @mm2 output
	if @mm1 > @mm2 
		select @result = @mm1 - @mm2
	else
		select @result = 0
end

-------------------------------------------
--	������ = ȷ��Ԥ���ͷ� / ������
-------------------------------------------
else if @index = 'Occupancy %'
begin
	exec p_gds_reserve_rsv_index @date, @types, 'Definite Reservations', 'R', @mm1 output
	exec p_gds_reserve_rsv_index @date, @types, 'Room to Rent', 'R', @mm2 output
	if @mm2 <> 0 
		select @result = round(@mm1*100/@mm2, 2)
	else
		select @result = 0
end

-------------------------------------------
--	�������� = (ȷ��Ԥ���ͷ� + ��ȷ��Ԥ��) / ������
-------------------------------------------
else if @index = 'Maximum Occ. %'
begin
	exec p_gds_reserve_rsv_index @date, @types, 'Definite Reservations', 'R', @mm1 output
	exec p_gds_reserve_rsv_index @date, @types, 'Tentative Reservation', 'R', @mm2 output
	exec p_gds_reserve_rsv_index @date, @types, 'Room to Rent', 'R', @mm3 output
	if @mm3 <> 0
		select @result = round((@mm1+@mm2)*100/@mm3, 2)
	else
		select @result = 0
end

-------------------------------------------
--	��ҹ����  -hu
-------------------------------------------
else if @index = 'People In-House-HU'  			-- ����
begin
	select @result = isnull((select sum(a.gstno*a.quantity) 
		from rsvsrc a, master b, mktcode c 
		 where a.accnt=b.accnt and b.market=c.code and c.flag<>'HSE' 
			and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno*a.quantity) 
		from rsvsrc a, sc_master b, mktcode c 
		 where b.foact='' and a.accnt=b.accnt and b.market=c.code and c.flag<>'HSE' 
			and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
end

-------------------------------------------
--	��ҹ����  +ɢ��/����/����
-------------------------------------------
else if @index = 'People In-House'  			-- ����
begin
	select @result = isnull((select sum(gstno*quantity) from rsvsrc where begin_<=@date and end_>@date and charindex(type,@types)>0),0)
end
else if @index = 'People In-House/FIT'			-- ɢ��
begin
	select @result = isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='F' and b.groupno='' 
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
end
else if @index = 'People In-House/GRP'			-- ����
begin
	select @result = isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='F' and b.groupno like 'G%'
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='G' 
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno*a.quantity) from rsvsrc a, sc_master b 
		where b.foact='' and a.accnt=b.accnt and b.class='G' 
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
end
else if @index = 'People In-House/MET'			-- ����
begin
	select @result = isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='F' and b.groupno like 'M%'
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='M' 
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno*a.quantity) from rsvsrc a, sc_master b 
		where b.foact='' and a.accnt=b.accnt and b.class='M' 
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
end

-------------------------------------------
--	��ǰ Q-room (��ǰ)
-------------------------------------------
else if @index = 'Q-room'
begin
	select @result = count(distinct a.roomno) from qroom a, master b 
		where a.accnt=b.accnt and a.status='I' and b.sta in ('R', 'I') and charindex(b.type,@types)>0
end

-------------------------------------------
--	��ǰ Walk-Ins
-------------------------------------------
else if @index = 'Walk-Ins'
begin
	select @result = isnull((select count(distinct roomno) from master where sta='I' and class='F' and datediff(dd,bdate,@bdate)=0 and substring(extra,9,1)='1' and charindex(type,@types)>0),0)
end
else if @index = 'Walk-Ins Persons'
begin
	select @result = isnull((select sum(gstno) from master where sta='I' and class='F' and datediff(dd,bdate,@bdate)=0 and substring(extra,9,1)='1' and charindex(type,@types)>0),0)
end

-------------------------------------------
--	Stay Over �ͷ�
-------------------------------------------
else if @index = 'Stay Over'
begin
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and a.roomno=''
				and a.begin_<@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select count(distinct a.roomno) from rsvsrc a, master b 
		where a.accnt=b.accnt and a.roomno<>''
				and a.begin_<@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.quantity) from rsvsrc a, sc_master b 
		where b.foact='' and a.accnt=b.accnt and a.roomno=''
				and a.begin_<@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select count(distinct a.roomno) from rsvsrc a, sc_master b 
		where b.foact='' and a.accnt=b.accnt and a.roomno<>''
				and a.begin_<@date and a.end_>@date and charindex(a.type,@types)>0),0)
end

-------------------------------------------
--	��ҹ�ͷ�  - hu
-------------------------------------------
else if @index = 'Occupied Tonight-HU'
begin
	select @result = isnull((select sum(a.quantity) from rsvsaccnt a, master b, mktcode c 
		where a.accnt=b.accnt and b.market=c.code and c.flag<>'HSE'
			and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0
		),0)
end

-------------------------------------------
--	��ҹ�ͷ�  +ɢ��/����/����
-------------------------------------------
else if @index = 'Occupied Tonight'
begin
	select @result = isnull((select sum(quantity) from rsvsaccnt where begin_<=@date and end_>@date and charindex(type,@types)>0),0)
end
else if @index = 'Occupied Tonight/FIT'
begin
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='F' and b.groupno='' and a.roomno=''
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select count(distinct a.roomno) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='F' and b.groupno='' and a.roomno<>''
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
end
else if @index = 'Occupied Tonight/GRP'
begin
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='F' and b.groupno like 'G%' and a.roomno=''
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select count(distinct a.roomno) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='F' and b.groupno like 'G%' and a.roomno<>''
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='G' 
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.quantity) from rsvsrc a, sc_master b 
		where b.foact='' and a.accnt=b.accnt and b.class='G' 
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
end
else if @index = 'Occupied Tonight/MET'
begin
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='F' and b.groupno like 'M%' and a.roomno=''
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select count(distinct a.roomno) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='F' and b.groupno like 'M%' and a.roomno<>''
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.class='M' 
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.quantity) from rsvsrc a, sc_master b 
		where b.foact='' and a.accnt=b.accnt and b.class='M' 
				and a.begin_<=@date and a.end_>@date and charindex(a.type,@types)>0),0)
end

---------------------------------------------------------
--	Ԥ�ƿͷ����� -- ����day-use. ���ǰ��ۡ����ռ��յ�δ֪
---------------------------------------------------------
else if @index = 'Room Revenue'
begin  -- ���ﲻ�������Ƿ��Ѿ��ַ�����Ϊ��ʹ�Ѿ��ַ�������ͬס��ʱ�򣬷���Ҳ����Ҫ�����
	select @result = isnull((select sum(rate*quantity) from rsvsrc where begin_<=@date and end_>@date and charindex(type,@types)>0),0)
end

---------------------------------------------------------
--	Ԥ�ƿͷ����� -- ����
---------------------------------------------------------
else if @index = 'Room Revenue Net'
begin  -- ���ﲻ�������Ƿ��Ѿ��ַ�����Ϊ��ʹ�Ѿ��ַ�������ͬס��ʱ�򣬷���Ҳ����Ҫ�����
	exec @result = p_gl_audit_rmpost_index @date, @types, @index
end

---------------------------------------------------------
--	Ԥ�ƿͷ����� -- ����day-use. �����
---------------------------------------------------------
else if @index = 'Room Revenue Include SVC'
begin  -- ���ﲻ�������Ƿ��Ѿ��ַ�����Ϊ��ʹ�Ѿ��ַ�������ͬס��ʱ�򣬷���Ҳ����Ҫ�����
	exec @result = p_gl_audit_rmpost_index @date, @types, @index
end

---------------------------------------------------------
--	Ԥ�ƿͷ����� -- ����day-use. �����. Packages
---------------------------------------------------------
else if @index = 'Room Revenue Include Packages'
begin  -- ���ﲻ�������Ƿ��Ѿ��ַ�����Ϊ��ʹ�Ѿ��ַ�������ͬס��ʱ�򣬷���Ҳ����Ҫ�����
	exec @result = p_gl_audit_rmpost_index @date, @types, @index
end

-------------------------------------------
--	ƽ������
-------------------------------------------
else if @index = 'Average Room Rate'
begin
	exec p_gds_reserve_rsv_index @date, @types, 'Room Revenue', 'R', @mm1 output
	exec p_gds_reserve_rsv_index @date, @types, 'Occupied Tonight', 'R', @mm2 output
	if @mm2 <> 0 
		select @result = round(@mm1/@mm2, 2)
	else
		select @result = 0
end

---------------------------------------------------------------
--	Same Day Reservations ����Ԥ�����յ���ͷ�
---------------------------------------------------------------
else if @index = 'Same Day Reservations' 		-- �Ѿ��˷��Ĳ���
begin
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno=''
			and b.resno like @resno+'%' ),0)
	select @result = @result + (select count(distinct a.roomno) from rsvsrc a, master b
			where a.accnt=b.accnt and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno<>''
				and b.resno like @resno+'%' )
end
else if @index = 'Same Day Reservations Persons'  -- �Ѿ��˷��Ĳ���
begin
	-- ��������û�б�Ҫ�����Ƿ�ַ� 
	select @result = isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.resno like @resno+'%' and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 ),0)

--	select @result = isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b 
--		where a.accnt=b.accnt and b.resno like @resno+'%' and a.begin_=@date and a.begin_<>a.end_ and charindex(a.type,@types)>0 and a.roomno=''),0)
--	select @result = @result + isnull((select sum(a.gstno) from rsvsrc a, master b 
--		where a.accnt=b.accnt and b.resno like @resno+'%' and b.sta in ('R','I') and a.begin_=@date and a.begin_<>a.end_ and charindex(a.type,@types)>0 and a.roomno<>''),0)
end


-------------------------------------------------------------------------
--	���յ���ͷ�	+ɢ��/����/����  (δ��)
-------------------------------------------------------------------------
else if @index = 'Arrival Rooms'   -- δ�ַ�(sum(quantity)) + �ַ�(count(distinct roomno))
begin
	select @result = isnull((select sum(quantity) from rsvsrc where begin_=@date and (begin_<>end_ or @duin='T') and charindex(type,@types)>0 and roomno=''),0)
	select @result = @result + (select count(distinct a.roomno) from rsvsrc a, master b
			where a.accnt=b.accnt and b.sta='R' and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno<>'')
end
else if @index = 'Arrival Rooms/FIT'
begin
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno=''
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno=''),0)
	select @result = @result + (select count(distinct a.roomno) from rsvsrc a, master b where a.accnt=b.accnt and b.sta='R' and b.class='F' and b.groupno=''
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno<>'')
end
else if @index = 'Arrival Rooms/GRP'
begin
	-- ����������Ԥ��
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='G'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
	-- ��Ա����-δ�ַ�
	select @result = @result + isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.sta='R' and b.class='F' and b.groupno like 'G%'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno=''),0)
	-- ��Ա����-�ַ�
	select @result = @result + (select count(distinct a.roomno) from rsvsrc a, master b where a.accnt=b.accnt and b.sta='R' and b.class='F' and b.groupno like 'G%'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno<>'')
end
else if @index = 'Arrival Rooms/MET'
begin
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='M'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.sta='R' and b.class='F' and b.groupno like 'M%'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno=''),0)
	select @result = @result + (select count(distinct a.roomno) from rsvsrc a, master b where a.accnt=b.accnt and b.sta='R' and b.class='F' and b.groupno like 'M%'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno<>'')
end

-------------------------------------------------------------------------
--	���յ������	+ɢ��/����/���� (δ��)
-------------------------------------------------------------------------
else if @index = 'Arrival Persons'
begin
	select @result = isnull((select sum(gstno*quantity) from rsvsrc where begin_=@date and (begin_<>end_ or @duin='T') and charindex(type,@types)>0 and roomno=''),0)
	select @result = @result + isnull((select sum(a.gstno) from rsvsrc a, master b 
		where a.accnt=b.accnt and b.sta='R' and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno<>''),0)
end 
else if @index = 'Arrival Persons/FIT'
begin
	select @result = isnull((select sum(a.gstno) from rsvsrc a, master b where a.accnt=b.accnt and b.sta='R' and b.class='F' and b.groupno=''
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
end
else if @index = 'Arrival Persons/GRP'  -- ��Ԥ��������*������ + ��Ա
begin
	select @result = isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='G'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno) from rsvsrc a, master b where a.accnt=b.accnt and b.sta='R' and b.class='F' and b.groupno like 'G%'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
end
else if @index = 'Arrival Persons/MET'
begin
	select @result = isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='M'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno) from rsvsrc a, master b where a.accnt=b.accnt and b.sta='R' and b.class='F' and b.groupno like 'M%'
			and a.begin_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
end

-------------------------------------------------------------------------
--	ʵ�ʵ���ͷ�/����  -- ��Ҫ����Ӫҵ����
-------------------------------------------------------------------------
else if @index = 'Arrival Rooms Actual'
begin
	select @result = isnull((select count(distinct roomno) from master where sta='I' and class='F' and bdate=@bdate and charindex(type,@types)>0),0)
end
else if @index = 'Arrival Persons Actual'
begin
	select @result = isnull((select sum(gstno) from master where sta='I' and class='F' and bdate=@bdate and charindex(type,@types)>0),0)
end

-------------------------------------------
--	�������ͷ�	+ɢ��/����/����
-------------------------------------------
else if @index = 'Departure Rooms'   -- δ�ַ�(sum(quantity)) + �ַ�(count(distinct roomno))
begin
	select @result = isnull((select sum(quantity) from rsvsrc where end_=@date and (begin_<>end_ or @duin='T') and charindex(type,@types)>0 and roomno=''),0)
	select @result = @result + (select count(distinct roomno) from rsvsrc 
			where end_=@date and (begin_<>end_ or @duin='T') and charindex(type,@types)>0 and roomno<>'')
end
else if @index = 'Departure Rooms/FIT'
begin
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno=''
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno=''),0)
	select @result = @result + (select count(distinct a.roomno) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno=''
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno<>'')
end
else if @index = 'Departure Rooms/GRP'
begin
	-- ����������Ԥ��
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='G'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
	-- ��Ա����-δ�ַ�
	select @result = @result + isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno like 'G%'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno=''),0)
	-- ��Ա����-�ַ�
	select @result = @result + (select count(distinct a.roomno) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno like 'G%'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno<>'')
end
else if @index = 'Departure Rooms/MET'
begin
	select @result = isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='M'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno like 'M%'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno=''),0)
	select @result = @result + (select count(distinct a.roomno) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno like 'M%'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0 and a.roomno<>'')
end

-------------------------------------------
--	����������	+ɢ��/����/����
-------------------------------------------
else if @index = 'Departure Persons'
begin
	select @result = isnull((select sum(gstno) from rsvsrc where end_=@date and (begin_<>end_ or @duin='T') and charindex(type,@types)>0),0)
end
else if @index = 'Departure Persons/FIT'
begin
	select @result = isnull((select sum(a.gstno) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno=''
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
end
else if @index = 'Departure Persons/GRP'  -- ��Ԥ��������*������ + ��Ա
begin
	select @result = isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='G'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno like 'G%'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
end
else if @index = 'Departure Persons/MET'
begin
	select @result = isnull((select sum(a.gstno*a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.class='M'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
	select @result = @result + isnull((select sum(a.gstno) from rsvsrc a, master b where a.accnt=b.accnt and b.class='F' and b.groupno like 'M%'
			and a.end_=@date and (a.begin_<>a.end_ or @duin='T') and charindex(a.type,@types)>0),0)
end

-------------------------------------------
--	����ʵ�����ͷ� / ����
-------------------------------------------
else if @index = 'Departure Rooms Actual'
begin
	select @result = count(distinct roomno) from master where sta='O' and class='F' and ressta='I'  and charindex(type,@types)>0
end
else if @index = 'Departure Persons Actual'
begin
	select @result = isnull((select sum(gstno) from master where sta='O' and class='F' and ressta='I' and charindex(type,@types)>0),0)
end

-------------------------------------------
--	Extended Stays / �ӷ� -- ��ס���ˡ������ӷ�����Ҫ�ο� master_till
-------------------------------------------
else if @index = 'Extended Stays Rooms'
begin
--	select @result = isnull((select count(distinct a.roomno) from master a where a.sta='I' and a.class='F' and datediff(dd,@bdate,a.dep)>0  and charindex(a.type,@types)>0
--		and exists(select 1 from master_till b where a.accnt=b.accnt and b.sta='I' and datediff(dd,b.dep,@bdate)=0)),0)
	-- �����ǲ�д������Ƕ��̫����ݿⱨ����� 
	select @result = count(distinct a.roomno) from master a where a.sta='I' and a.class='F' and datediff(dd,@bdate,a.dep)>0  and charindex(a.type,@types)>0
		and exists(select 1 from master_till b where a.accnt=b.accnt and b.sta='I' and datediff(dd,b.dep,@bdate)=0)
	if @result is null 
		select @result = 0 
end
else if @index = 'Extended Stays Persons'
begin
--	select @result = isnull((select sum(a.gstno) from master a where a.sta='I' and a.class='F' and datediff(dd,@bdate,a.dep)>0  and charindex(a.type,@types)>0
--		and exists(select 1 from master_till b where a.accnt=b.accnt and b.sta='I' and datediff(dd,b.dep,@bdate)=0)),0)
	-- �����ǲ�д������Ƕ��̫����ݿⱨ����� 
	select @result = sum(a.gstno) from master a where a.sta='I' and a.class='F' and datediff(dd,@bdate,a.dep)>0  and charindex(a.type,@types)>0
		and exists(select 1 from master_till b where a.accnt=b.accnt and b.sta='I' and datediff(dd,b.dep,@bdate)=0)
	if @result is null 
		select @result = 0 
end

-------------------------------------------
--	Early Departures / ��ǰ��
-------------------------------------------
else if @index = 'Early Departures Rooms'
begin
	-- ��ǰ�� ed  -- ���ս��ˡ���������<>���죻��Ҫ�ο� master_till
--	select @result = isnull((select count(distinct a.roomno) from master a where a.sta='O' and a.class='F'  and charindex(a.type,@types)>0
--		and exists(select 1 from master_till b where a.accnt=b.accnt and b.sta='I' and datediff(dd,b.dep,@bdate)<0)),0)
	-- �����ǲ�д������Ƕ��̫����ݿⱨ����� 
	select @result = count(distinct a.roomno) from master a where a.sta='O' and a.class='F'  and charindex(a.type,@types)>0
		and exists(select 1 from master_till b where a.accnt=b.accnt and b.sta='I' and datediff(dd,b.dep,@bdate)<0)
	if @result is null 
		select @result = 0 
end
else if @index = 'Early Departures Persons'
begin
--	select @result = isnull((select sum(a.gstno) from master a where a.sta='O' and a.class='F'  and charindex(a.type,@types)>0
--		and exists(select 1 from master_till b where a.accnt=b.accnt and b.sta='I' and datediff(dd,b.dep,@bdate)<0)),0)
	-- �����ǲ�д������Ƕ��̫����ݿⱨ����� 
	select @result = sum(a.gstno) from master a where a.sta='O' and a.class='F'  and charindex(a.type,@types)>0
		and exists(select 1 from master_till b where a.accnt=b.accnt and b.sta='I' and datediff(dd,b.dep,@bdate)<0)
	if @result is null 
		select @result = 0 
end

-------------------------------------------
-- �¼��ĸ���
-------------------------------------------
else if @index in ('Event', 'Events')  
begin
	select @result = count(1) from events where sta='I' and @date>=begin_ and @date<=end_
end

-------------------------------------------
--	Turnaway
-------------------------------------------
else if @index = 'Turnaway'
begin
--	select @result = isnull((select sum(rmnum) from turnaway where sta='I' and @date>=arr and datediff(dd,arr,@date)<=days), 0)

	-- Turnaway (ֻ���㵽��) -- �� p_gds_reserve_daily_info ����һ�� 2007.4.24 simon 
--	select @result	= isnull((select sum(a.rmnum) from turnaway a, typim b 
--		where b.tag='K' and a.type=b.type and datediff(dd,a.arr,@date)=0 and a.sta='T'), 0)

	-- turnaway.type ���Զ�ѡ�ģ��������û�з����ж��ˣ�������ʾ��������
	select @result	= isnull((select sum(a.rmnum) from turnaway a  
		where datediff(dd,a.arr,@date)=0 and a.sta='T'), 0)

end

-------------------------------------------
--	Waitlist
-------------------------------------------
else if @index = 'Waitlist'
begin
	select @result = isnull((select sum(rmnum) from master where sta='W' and datediff(dd,arr,@date)>=0 and datediff(dd,dep,@date)<=0), 0)
end

-------------------------------------------
--	����δ֪ ͳ��ָ��
-------------------------------------------
else 
	select @result = 0
-------------------------------------------
--	��ס��ѷ�
-------------------------------------------
if @index = 'COM_IN'
begin
	select @result = isnull((select sum(a.quantity) from rsvsaccnt a, master b, mktcode c 
		where a.accnt=b.accnt and b.market=c.code and c.flag='COM'
			and b.sta = 'I'
		),0)
end
-------------------------------------------
--	Blocks
-------------------------------------------
if @index = 'Blocks'
begin
	select @result = isnull((select sum(a.quantity) from rsvsaccnt a, sc_master b
		where charindex(a.type,@types)>0 and a.begin_<>a.end_ and a.begin_<=@date and a.end_>@date
			and a.accnt=b.accnt ),0)
end
-------------------------------------------
--	������
-------------------------------------------
if @result is null
	select @result = 0
if @retmode = 'S'
	select @result
return 0
;