//------------------------------------------------------------------------------
//		�ڼ��ռ�¼
//------------------------------------------------------------------------------
if object_id('p_gds_holiday_create') is not null
	drop proc p_gds_holiday_create
;
create proc p_gds_holiday_create
as
declare	@beg_year		int,
			@end_year		int,
			@date				char(10)

delete basecode where cat='holiday'
--------------------------------------------------------------------------
--  basecode : holiday  -- ���ҷ����ڼ���
--------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='holiday')
	delete basecode_cat where cat='holiday'
insert basecode_cat(cat,descript,descript1,len) select 'holiday', '���ҷ����ڼ���', '���ҷ����ڼ���', 10

select @beg_year=2005, @end_year=2011

while @beg_year < @end_year
	begin
	-- Ԫ��
	select @date = convert(char(4), @beg_year)+'/01/01'
	insert basecode(cat,code,descript,descript1) select 'holiday',@date,@date,@date
	-- �Ͷ���
	select @date = convert(char(4), @beg_year)+'/05/01'
	insert basecode(cat,code,descript,descript1) select 'holiday',@date,@date,@date
	select @date = convert(char(4), @beg_year)+'/05/02'
	insert basecode(cat,code,descript,descript1) select 'holiday',@date,@date,@date
	select @date = convert(char(4), @beg_year)+'/05/03'
	insert basecode(cat,code,descript,descript1) select 'holiday',@date,@date,@date
	-- �����
	select @date = convert(char(4), @beg_year)+'/10/01'
	insert basecode(cat,code,descript,descript1) select 'holiday',@date,@date,@date
	select @date = convert(char(4), @beg_year)+'/10/02'
	insert basecode(cat,code,descript,descript1) select 'holiday',@date,@date,@date
	select @date = convert(char(4), @beg_year)+'/10/03'
	insert basecode(cat,code,descript,descript1) select 'holiday',@date,@date,@date
	-- ����
	-- ......  
	
	select @beg_year = @beg_year + 1
	end

return 0
;

exec p_gds_holiday_create;
select * from basecode where cat='holiday' order by code;


				