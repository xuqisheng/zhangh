if  exists(select * from sysobjects where name = "p_gds_reserve_daily_info" and type = "P")
	drop proc p_gds_reserve_daily_info;
create proc p_gds_reserve_daily_info
	@s_time			datetime,       	-- ��ʼʱ��
	@e_time			datetime,     		-- ����ʱ��
	@types			varchar(255) = '%'
as
-- ------------------------------------------------------------------------------------
--  ǰ̨�ͷ���Ϣ��ѯ  -- �ͷ�������ռ�õ� �°벿��
-- ------------------------------------------------------------------------------------
declare	
	@arrivals		int,
	@departures		int,
	@adults			int,
	@child			int,
	@overrsv			int,
	@oo				int,
	@os				int,
	@overbook		int,
	@datetype		char(1),
	@waitlist_rm	int,
	@waitlist_ps	int,
	@turnaway		int,
	@ttl_avl			money,
	@max_avl			money,
	@min_avl			money,
	@ttl_occ			money,
	@max_occ			money,
	@min_occ			money,
	@event			varchar(60)

create table #info
(
	date			datetime					not null,
	arrivals		int		default 0	not null,		-- ����ͷ�
	departures	int		default 0	not null,		-- �뿪����
	adults		int		default 0	not null,		-- ��������
	child			int		default 0	not null,		-- �����ͯ  => �뿪����
	overrsv		int		default 0	not null,		-- ��Ԥ����  = ��
	oo				int		default 0	not null,		-- ά��
	overbook		int		default 0	not null,		-- ��Ԥ����  = ��
	datetype		char(1)	default ''		null,			
	waitlist_rm		int		default 0	not null,
	waitlist_ps		int		default 0	not null,
	turnaway		int		default 0	not null,
	ttl_avl		money		default 0	not null,
	max_avl		money		default 0	not null,
	min_avl		money		default 0	not null,
	ttl_occ		money		default 0	not null,		-- ������
	max_occ		money		default 0	not null,
	min_occ		money		default 0	not null,
	event			varchar(60)	default '' 	null,
	os				int		default 0	not null			-- ����
)

while	@s_time <= @e_time
begin
	-- ���﷿��
	exec p_gds_reserve_rsv_index @s_time, @types, 'Arrival Rooms', 'R', @arrivals output
	-- �뿪����
	exec p_gds_reserve_rsv_index @s_time, @types, 'Departure Rooms', 'R', @departures output

	-- ��������
	exec p_gds_reserve_rsv_index @s_time, @types, 'Arrival Persons', 'R', @adults output
	-- �뿪����
	exec p_gds_reserve_rsv_index @s_time, @types, 'Departure Persons', 'R', @child output

	-- ��Ԥ��  Over Reserved
	exec p_gds_reserve_rsv_index @s_time, @types, 'Over Reserved', 'R', @overrsv output

	-- ά����
	exec p_gds_reserve_rsv_index @s_time, @types, 'Out of Order', 'R', @oo output
	exec p_gds_reserve_rsv_index @s_time, @types, 'Out of Service', 'R', @os output

	-- ����Ԥ����
	exec p_gds_reserve_rsv_index @s_time, @types, 'House Overbooking', 'R', @overbook output
	
	-- �������ͣ�������أ�
	select @datetype = factor from rmrate_calendar where date=@s_time
	if @@rowcount = 0
		select @datetype = ''

	-- Waitlist (ֻ���㵽��)
	select @waitlist_rm = isnull((select sum(a.rmnum) from master a, typim b 
		where b.tag='K' and a.type=b.type and (@types='%' or charindex(a.type,@types)>0) and datediff(dd,a.arr,@s_time)=0 and a.sta='W'), 0)
	select @waitlist_ps = isnull((select sum(a.gstno) from master a, typim b 
		where b.tag='K' and a.type=b.type and (@types='%' or charindex(a.type,@types)>0) and datediff(dd,a.arr,@s_time)=0 and a.sta='W'), 0)

	-- Turnaway (ֻ���㵽��)
--	select @turnaway	= isnull((select sum(a.rmnum) from turnaway a, typim b 
--		where b.tag='K' and a.type=b.type and (@types='%' or charindex(a.type,@types)>0) and datediff(dd,a.arr,@s_time)=0 and a.sta='T'), 0)

	-- turnaway.type ���Զ�ѡ�ģ��������û�з����ж��ˣ�������ʾ�������� 
	select @turnaway	= isnull((select sum(a.rmnum) from turnaway a
		where datediff(dd,a.arr,@s_time)=0 and a.sta='T'), 0)

	-- ���÷���
	exec p_gds_reserve_rsv_index @s_time, @types, 'Available Rooms', 'R', @ttl_avl output
	exec p_gds_reserve_rsv_index @s_time, @types, 'Available Rooms', 'R', @max_avl output
	exec p_gds_reserve_rsv_index @s_time, @types, 'Minimum Availability', 'R', @min_avl output

	-- ռ�÷���
--	exec p_gds_reserve_rsv_index @s_time, @types, 'Total Reserved', 'R', @ttl_occ output
--	exec p_gds_reserve_rsv_index @s_time, @types, 'Total Reserved', 'R', @max_occ output
--	exec p_gds_reserve_rsv_index @s_time, @types, 'Definite Reservations', 'R', @min_occ output

	-- ������
	exec p_gds_reserve_rsv_index @s_time, @types, 'Maximum Occ. %', 'R', @ttl_occ output
	select @max_occ = @ttl_occ
	exec p_gds_reserve_rsv_index @s_time, @types, 'Occupancy %', 'R', @min_occ output

	-- �Ƶ�/�¼� (�ж���¼���ʱ��ֻȡid��С��һ��������ʱ����)
	declare 	@id		int
	select @id = min(id) from events where sta='I' and datediff(dd,begin_,@s_time)>=0 and datediff(dd,end_,@s_time)<=0
	if @id is not null
		select @event	= descript from events where id=@id
	else
		select @event	= 'Null'
	
	-- insert 
	insert #info 
		values(@s_time,@arrivals,@departures,@adults,@child,@overrsv,@oo,@overbook,@datetype,@waitlist_rm,@waitlist_ps,
			@turnaway,@ttl_avl,@max_avl,@min_avl,@ttl_occ,@max_occ,@min_occ,@event,@os)

	-- next date
	select @s_time = dateadd(day, 1, @s_time)
end

select * from #info order by date

return 0
;