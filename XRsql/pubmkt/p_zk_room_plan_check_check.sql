if exists (select * from sysobjects where name ='p_zk_room_plan_check_check' and type ='P')
	drop proc p_zk_room_plan_check_check;
create proc p_zk_room_plan_check_check
	@pc_id			char(4),
	@begin			datetime,
	@end				datetime,
	@no				char(10),
	@roomtype		char(5),
	@ratecode		char(10),
	@retmode			char(1) 	= 'S',
	@rmnum			integer	=  0,
	@class			char(1) 	= 'A',
	@rmnum_before	integer	=	0
	
as
	
---------------------------------------------
-- 住店时间段房价与房数预测
---------------------------------------------
declare
	@bdate		datetime,
	@msg			varchar(100) ,
	@ret			int			 

exec p_zk_room_plan_check @pc_id,@begin,@end,@no,'D',@rmnum,@class,0

select @ret = 0,@msg = ''

if exists(select 1 from rsv_plan_check where pc_id = @pc_id and leftn < 0
		and charindex(','+rtrim(@ratecode)+',',','+rtrim(ratecodes)+',')>0 and charindex(','+rtrim(@roomtype)+',',','+rtrim(rmtypes)+',')>0
		and leaf = 1)
	begin
	if @rmnum > @rmnum_before 
		begin
		select @ret = 1,@msg = "配额房数已超，无法继续"
		--return 1
		end
	end
if exists(select 1 from rsv_plan_check where pc_id = @pc_id and leftn < 0
	and charindex(','+rtrim(@ratecode)+',',','+rtrim(ratecodes)+',')>0 and charindex(','+rtrim(@roomtype)+',',','+rtrim(rmtypes)+',')>0
	and leaf = 0)
	begin
	if @rmnum > @rmnum_before 
		begin
		select @ret = 2,@msg = "配额房数已超，是否要继续"
		--return 2
		end
	end

select @ret,@msg
return @ret


;




