//------------------------------------------------------------------------------
//  月初，年初的日期
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_gds_firstday' and type='P')
	drop proc p_gds_firstday
;
create proc  p_gds_firstday 
	@mode		char(1),		-- M, Y
	@retmode	char(1),		-- R, S
	@date		datetime	output   -- 这个参数传入，再传出
as

if @mode='M'
	select @date = max(firstday) from firstdays where firstday<=@date
else if @mode='Y'
begin
	declare	@year	int
	select @year = max(year) from firstdays where firstday<=@date
	select @date = min(firstday) from firstdays where year = @year
end

if @retmode = 'S'
	select @date
return 0
;
