if  exists(select * from sysobjects where name = "p_gds_reserve_type_avail" and type = "P")
	drop proc p_gds_reserve_type_avail;
create proc p_gds_reserve_type_avail
	@type    		varchar(5),
	@s_time			datetime,
	@e_time			datetime,
	@entry			char(1),				-- 0-������Ŀ 1-������Ԥ�� 2-�Ƶ����峬Ԥ���ж�
	@retmode			char(1),
	@value			int		output
as
-- ------------------------------------------------------------------------------------
--  ���������Ŀ  (ȡ������Сֵ)   ��� typim.overquan & rsvlimit ���� 
-- ------------------------------------------------------------------------------------
declare		@ttl			int,
				@rsv			int,
				@oo			int,
				@over			int,
				@over_type	int,
				@tmp			int,
				@tmp_type	char(5)

if rtrim(@type) is null
	select @type = '%'
if @entry is null or @entry not in ('0', '1', '2')
	select @entry = '0'
if @type<>'%' and @entry='2' 
	select @entry = '0'

-- ���� = ���� �� Ԥ�� �� ά�� + �ɳ�Ԥ��

select @s_time = convert(datetime,convert(char(8),@s_time,1))
select @e_time = convert(datetime,convert(char(8),@e_time,1))

if @s_time = @e_time
	select @e_time = dateadd(dd,1,@s_time)

-- �ܿͷ�
select @ttl = sum(quantity) from typim where type like @type

select @value = 10000
while @s_time < @e_time
begin
	select @rsv = isnull((select sum(blockcnt) from rsvtype where begin_ <= @s_time and end_ > @s_time and type like @type), 0)
--	select @oo = count(1) from rmsta 
--		where locked='L' 
--				and futbegin <= @s_time and (futend > @s_time or futend is null)
--				and type like @type
	select @oo = count(1) from rm_ooo a, rmsta b
		where a.status='I' and a.sta='O' 
				and a.dbegin <= @s_time and a.dend > @s_time 
				and a.roomno=b.roomno and b.type like @type
	
	-- ���Ҫ������Ԥ������
	if @entry = '1' 
	begin 
		select @over = 0 
		select @tmp_type = isnull((select min(type) from typim where tag='K' and type like @type), '')
		while @tmp_type <> ''
		begin 
			select @over_type=overbook from rsvlimit where date=@s_time and type=@tmp_type 
			if @@rowcount=0 
				select @over_type=overquan from typim where type=@tmp_type 
			select @over = @over + @over_type 

			select @tmp_type = isnull((select min(type) from typim where tag='K' and type like @type and type>@tmp_type), '')
		end 
	end 
	else if @entry = '2' -- ��ʱ���ڼ��������Գ�Ԥ����@type=% 
	begin 
		exec p_gds_reserve_rsv_index @s_time, '%', 'House Overbooking', 'R', @over output
	end 
	else
		select @over = 0

	if @over is null or @over<0 
		select @over = 0 		
	select @tmp = @ttl - @rsv - @oo + @over 
	if @tmp < @value
		select @value = @tmp

	select @s_time = dateadd(dd, 1, @s_time)
end

-- 
if @retmode = 'S'
	select @value
return 0
;