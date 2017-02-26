IF OBJECT_ID('p_cq_cmscode_get_add') IS NOT NULL
    DROP PROCEDURE p_cq_cmscode_get_add
;
create proc p_cq_cmscode_get_add
		@upmode				char(1),  --时段'Y','M','J','A'
		@rmtype_s			char(1),  --是否分房类
		@accnt				char(10), --
		@cmscode				char(10), --佣金码
		@cms_code			char(10), --明细码
		@rm_type				char(5),  --房类
		@bdate				datetime,	
		@id					int			--cms_rec id
as
----------------------------------------------------------------------
--	佣金计算并且更新 cms_rec - 针对：阶梯奖励
--
-- 这里的阶梯佣金处理，到达下一个阶梯，需要重新计算以前的佣金计算。
-- 因此，在实时扣减房费的时候不能使用，因为它会更新原来的已经记帐的 cms_rec 纪录
-- simon 2006.5.8
--
-- 奖励只统计按间天的cmsunit<>'1'
--
-- 这里暂时不判断佣金是否大于房费
----------------------------------------------------------------------

declare
		@pri				integer,
		@cmscode_detail char(10),
		@unit				 char(1),
		@type				 char(1),
		@rmtype			 char(255),
		@amount			 money,
		@dayuse			 char(2),
		@uproom1			 money,		@upamount1      money,
		@uproom2			 money,		@upamount2      money,
		@uproom3			 money,		@upamount3      money,
		@uproom4			 money,		@upamount4      money,
		@uproom5			 money,		@upamount5      money,
		@uproom6			 money,		@upamount6      money,
		@uproom7			 money,		@upamount7      money,
		@upamount       money,
		@week           varchar(30),
		@weeknow    	 char(1),
		@rmmode         char(8),
		@nights		    integer,
		@datecond		 varchar(80),
		@ret        	 integer,
		@extra 			char(10),
		@d_line			money,
		@packrate		int,
		@srvrate       int

select @unit = unit,@type=type,@rmtype=rmtype,@amount=amount,@dayuse=dayuse,
		@uproom1=uproom1,@upamount1=upamount1,@uproom2=uproom2,@upamount2=upamount2,
		@uproom3=uproom3,@upamount3=upamount3,@uproom4=uproom4,@upamount4=upamount4,
		@uproom5=uproom5,@upamount5=upamount5,@uproom6=uproom6,@upamount6=upamount6,
		@uproom7=uproom7,@datecond = datecond,@extra=extra,@d_line=d_line
from cms_defitem where no=@cms_code

select @packrate = convert(integer,substring(@extra,1,1)),@srvrate = convert(integer,substring(@extra,2,1))

--加收是否返佣
select @rmmode = 'JjBb'
if substring(@dayuse,1,1) = 'T'		-- 加收全天
	select @rmmode = rtrim(@rmmode) + 'N'
if substring(@dayuse,2,1) = 'T'		-- 加收半天
	select @rmmode = rtrim(@rmmode) + 'P'

-----------------
--阶梯不分时段
-----------------
if @upmode = 'A'
begin
	--奖励只统计按间天的cmsunit<>'1'
	select @nights = isnull(sum(w_or_h),0) from cms_rec where belong=@accnt and cmscode=@cmscode		 and sta = 'I' and cmsunit <> '1' and (@rmtype_s = 'F' or (@rmtype_s = 'T' and rtrim(type)=@rm_type)) and id <= @id and cmsdetail <> '----------'
	if @nights <  @uproom1
	begin
		--type = 1 按金额 0 按比例  2 - 底价
		--unit = 1 按次   0 按间天

		if @unit = '0'	and @type='0'
			update cms_rec set cms0 = ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 - @srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))*@amount,
						cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
						and sta = 'I'  and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
							and (@d_line=0 or ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line)
		else if 	@unit = '0'	and @type='1'
			update cms_rec set cms0 = @amount,cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
						and sta = 'I'  and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
							and (@d_line=0 or @d_line < (rmrate+rmsur) )
		else if 	@unit = '0'	and @type='2'
			update cms_rec set cms0 = (rmrate-@amount),cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
						and sta = 'I'  and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
		else if 	@unit = '1' and @type='0'
			update cms_rec set cms0 = ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))*@amount,
						cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and datediff(day,arr,bdate) = 0 and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
						and sta = 'I' and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
							and (@d_line=0 or ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line)
		else if 	@unit = '1' and @type='1'
			update cms_rec set cms0 = @amount,cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and datediff(day,arr,bdate) = 0 and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
						and sta = 'I' and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
							and (@d_line=0 or @d_line < (rmrate+rmsur) )
		else if 	@unit = '1' and @type='2'
			update cms_rec set cms0 = (rmrate-@amount),cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and datediff(day,arr,bdate) = 0 and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
						and sta = 'I' and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
	end
	else if @nights >=  @uproom1 and (@nights< @uproom2 or @uproom2 = 0)
		select @upamount = @upamount1
	else if @nights >=  @uproom2 and (@nights< @uproom3 or @uproom3 = 0)
		select @upamount = @upamount2
	else if @nights >=  @uproom3 and (@nights< @uproom4 or @uproom4 = 0)
		select @upamount = @upamount3
	else if @nights >=  @uproom4 and (@nights< @uproom5 or @uproom5 = 0)
		select @upamount = @upamount4
	else if @nights >=  @uproom5 and (@nights< @uproom6 or @uproom6 = 0)
		select @upamount = @upamount5
	else if @nights >=  @uproom6 and (@nights< @uproom7 or @uproom7 = 0)
		select @upamount = @upamount6
	else if @nights >=  @uproom7
		select @upamount = @upamount7

	if @nights >=  @uproom1
	begin
		if @unit = '0'	and @type='0'
		begin
			update cms_rec set cms=cms0,changed = getdate() where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				 and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>(rmrate*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate+(rmsur+netrate)*@srvrate)*@upamount
						and (@d_line=0 or ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line) 
			update cms_rec set cms0 = ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))*@upamount,cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code,
				changed = getdate(),back='F' where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				 and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>(rmrate*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate+(rmsur+netrate)*@srvrate)*@upamount
						and (@d_line=0 or ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line) 
		end
		else if 	@unit = '0'	and @type='1'
		begin
			update cms_rec set cms=cms0,changed = getdate() where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>@upamount
						and (@d_line=0 or @d_line < (rmrate+rmsur))
			update cms_rec set cms0 = @upamount,cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code,
				changed = getdate(),back='F' where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>@upamount
						and (@d_line=0 or @d_line < (rmrate+rmsur))
		end
		else if 	@unit = '0'	and @type='2'
		begin
			update cms_rec set cms=cms0,changed = getdate() where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>(rmrate-@upamount)
			update cms_rec set cms0 = (rmrate-@upamount),cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code,
				changed = getdate(),back='F' where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>(rmrate-@upamount)
		end
	end
end

-----------------
--阶梯时段按年
-----------------
if @upmode = 'Y'
begin
	--奖励只统计按间天的cmsunit<>'1'
	select @nights = isnull(sum(w_or_h),0) from cms_rec where belong=@accnt and cmscode=@cmscode
		and datepart(year,bdate) = datepart(year,@bdate)
			 and sta = 'I' and cmsunit <> '1' and (@rmtype_s = 'F' or (@rmtype_s = 'T' and rtrim(type)=@rm_type)) and id <= @id and cmsdetail <> '----------'
	if @nights <  @uproom1
	begin
		if @unit = '0'	and @type='0'
			update cms_rec set cms0 = ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))*@amount,
						cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
						and sta = 'I'  and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
							and (@d_line=0 or ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line)
		else if 	@unit = '0'	and @type='1'
			update cms_rec set cms0 = @amount,cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I'  and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
					and (@d_line=0 or @d_line < (rmrate+rmsur) )
		else if 	@unit = '0'	and @type='2'
			update cms_rec set cms0 = (rmrate-@amount),cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I'  and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
		else if 	@unit = '1' and @type='0'
			update cms_rec set cms0 = ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))*@amount,
						cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and datediff(day,arr,bdate) = 0 and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
						and sta = 'I' and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
							and (@d_line=0 or ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line)
		else if 	@unit = '1' and @type='1'
			update cms_rec set cms0 = @amount,cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and datediff(day,arr,bdate) = 0 and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
					and (@d_line=0 or @d_line < (rmrate+rmsur))
		else if 	@unit = '1' and @type='2'
			update cms_rec set cms0 = (rmrate-@amount),cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and datediff(day,arr,bdate) = 0 and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
	end
	else if @nights >=  @uproom1 and (@nights< @uproom2 or @uproom2 = 0)
		select @upamount = @upamount1
	else if @nights >=  @uproom2 and (@nights< @uproom3 or @uproom3 = 0)
		select @upamount = @upamount2
	else if @nights >=  @uproom3 and (@nights< @uproom4 or @uproom4 = 0)
		select @upamount = @upamount3
	else if @nights >=  @uproom4 and (@nights< @uproom5 or @uproom5 = 0)
		select @upamount = @upamount4
	else if @nights >=  @uproom5 and (@nights< @uproom6 or @uproom6 = 0)
		select @upamount = @upamount5
	else if @nights >=  @uproom6 and (@nights< @uproom7 or @uproom7 = 0)
		select @upamount = @upamount6
	else if @nights >=  @uproom7
		select @upamount = @upamount7

	if @nights >=  @uproom1
	begin
		if @unit = '0'	and @type='0'
		begin
			update cms_rec set cms=cms0,changed = getdate() where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				and datepart(year,bdate) = datepart(year,@bdate)
				 and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>(rmrate*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate+(rmsur+netrate)*@srvrate)*@upamount
						and (@d_line=0 or (rmrate*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate+(rmsur+netrate)*@srvrate)>@d_line) 
			update cms_rec set cms0 = ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))*@upamount,
				cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code,changed = getdate(),back='F' 
				where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				 and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>(rmrate*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate+(rmsur+netrate)*@srvrate)*@upamount
						and (@d_line=0 or ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line) 
		end
		else if 	@unit = '0'	and @type='1'
		begin
			update cms_rec set cms=cms0,changed = getdate() where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				 and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and datepart(year,bdate) = datepart(year,@bdate)
					 and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>@upamount
					  and (@d_line=0 or @d_line < (rmrate+rmsur))
			update cms_rec set cms0 = @upamount,cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code,
				changed = getdate(),back='F' where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				 and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and datepart(year,bdate) = datepart(year,@bdate)
					 and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>@upamount
					  and (@d_line=0 or @d_line < (rmrate+rmsur))
		end
		else if 	@unit = '0'	and @type='2'
		begin
			update cms_rec set cms=cms0,changed = getdate() where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				and datepart(year,bdate) = datepart(year,@bdate)
				 and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>(rmrate-@upamount)
			update cms_rec set cms0 = (rmrate-@upamount),cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code,
				changed = getdate(),back='F' where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				 and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and datepart(year,bdate) = datepart(year,@bdate)
					 and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>(rmrate-@upamount)
		end
	end
end

-----------------
--阶梯时段按月
-----------------
if @upmode = 'M'
begin
	--奖励只统计按间天的cmsunit<>'1'
	select @nights = isnull(sum(w_or_h),0) from cms_rec where belong=@accnt and cmscode=@cmscode
		and datepart(year,bdate) = datepart(year,@bdate) and datepart(month,bdate) = datepart(month,@bdate)
			 and sta = 'I' and cmsunit <> '1' and (@rmtype_s = 'F' or (@rmtype_s = 'T' and rtrim(type)=@rm_type)) and id <= @id and cmsdetail <> '----------'
	if @nights <  @uproom1
	begin
		if @unit = '0'	and @type='0'
			update cms_rec set cms0 = ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))*@amount,
						cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
						and sta = 'I'  and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
							and (@d_line=0 or ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line)
		else if 	@unit = '0'	and @type='1'
			update cms_rec set cms0 = @amount,cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I'  and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
					and (@d_line=0 or @d_line < (rmrate+rmsur))
		else if 	@unit = '0'	and @type='2'
			update cms_rec set cms0 = (rmrate-@amount),cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I'  and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
		else if 	@unit = '1' and @type='0'
			update cms_rec set cms0 = ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))*@amount,
						cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and datediff(day,arr,bdate) = 0 and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
						and sta = 'I' and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
							and (@d_line=0 or ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line)
		else if 	@unit = '1' and @type='1'
			update cms_rec set cms0 = @amount,cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and datediff(day,arr,bdate) = 0 and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
					and (@d_line=0 or @d_line < (rmrate+rmsur))
		else if 	@unit = '1' and @type='2'
			update cms_rec set cms0 = (rmrate-@amount),cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and datediff(day,arr,bdate) = 0 and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
	end
	else if @nights >=  @uproom1 and (@nights< @uproom2 or @uproom2 = 0)
		select @upamount = @upamount1
	else if @nights >=  @uproom2 and (@nights< @uproom3 or @uproom3 = 0)
		select @upamount = @upamount2
	else if @nights >=  @uproom3 and (@nights< @uproom4 or @uproom4 = 0)
		select @upamount = @upamount3
	else if @nights >=  @uproom4 and (@nights< @uproom5 or @uproom5 = 0)
		select @upamount = @upamount4
	else if @nights >=  @uproom5 and (@nights< @uproom6 or @uproom6 = 0)
		select @upamount = @upamount5
	else if @nights >=  @uproom6 and (@nights< @uproom7 or @uproom7 = 0)
		select @upamount = @upamount6
	else if @nights >=  @uproom7
		select @upamount = @upamount7

	if @nights >=  @uproom1
	begin
		if @unit = '0'	and @type='0'
		begin
			update cms_rec set cms=cms0,changed = getdate() where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				 and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and datepart(year,bdate) = datepart(year,@bdate) and datepart(month,bdate) = datepart(month,@bdate)
						and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))*@upamount
						and (@d_line=0 or ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line) 
			update cms_rec set cms0 = ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))*@upamount,
				cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code,changed = getdate(),back='F' 
				where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				 and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and datepart(year,bdate) = datepart(year,@bdate) and datepart(month,bdate) = datepart(month,@bdate)
						and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))*@upamount
						and (@d_line=0 or ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line) 
		end
		else if 	@unit = '0'	and @type='1'
		begin
			update cms_rec set cms=cms0,changed = getdate() where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				 and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and datepart(year,bdate) = datepart(year,@bdate) and datepart(month,bdate) = datepart(month,@bdate)
					 and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>@upamount
					  and (@d_line=0 or @d_line < (rmrate+rmsur))
			update cms_rec set cms0 = @upamount,cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code,
				changed = getdate(),back='F' where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				 and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and datepart(year,bdate) = datepart(year,@bdate) and datepart(month,bdate) = datepart(month,@bdate)
					 and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>@upamount
					  and (@d_line=0 or @d_line < (rmrate+rmsur))
		end
		else if 	@unit = '0'	and @type='2'
		begin
			update cms_rec set cms=cms0,changed = getdate() where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				and datepart(year,bdate) = datepart(year,@bdate) and datepart(month,bdate) = datepart(month,@bdate)
				 and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>(rmrate-@upamount)
			update cms_rec set cms0 = (rmrate-@upamount),cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code,
				changed = getdate(),back='F' where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				 and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and datepart(year,bdate) = datepart(year,@bdate) and datepart(month,bdate) = datepart(month,@bdate)
					 and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>(rmrate-@upamount)
		end
	end
end

-----------------
--阶梯时段按季
-----------------
if @upmode = 'J'
begin
	--奖励只统计按间天的cmsunit<>'1'
	select @nights = isnull(sum(w_or_h),0) from cms_rec where id = @id and belong=@accnt and cmscode=@cmscode
		and ((datepart(month,@bdate) >= 1 and datepart(month,@bdate) <= 3 and datepart(month,bdate) >= 1 and datepart(month,bdate)<=3)
				or (datepart(month,@bdate) >= 4 and datepart(month,@bdate) <= 6 and datepart(month,bdate) >= 4 and datepart(month,bdate)<=6)
				or (datepart(month,@bdate) >= 7 and datepart(month,@bdate) <= 9 and datepart(month,bdate) >= 7 and datepart(month,bdate)<=9)
				or (datepart(month,@bdate) >= 10 and datepart(month,@bdate) <= 12 and datepart(month,bdate) >= 10 and datepart(month,bdate)<=12))
			 and sta = 'I' and cmsunit <> '1' and (@rmtype_s = 'F' or (@rmtype_s = 'T' and rtrim(type)=@rm_type)) and id <= @id and cmsdetail <> '----------'
	if @nights <  @uproom1
	begin
		if @unit = '0'	and @type='0'
			update cms_rec set cms0 = ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))*@amount,
						cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
						and sta = 'I'  and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
							and (@d_line=0 or ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line)
		else if 	@unit = '0'	and @type='1'
			update cms_rec set cms0 = @amount,cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I'  and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
					and (@d_line=0 or @d_line < (rmrate+rmsur))
		else if 	@unit = '0'	and @type='2'
			update cms_rec set cms0 = (rmrate-@amount),cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I'  and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
		else if 	@unit = '1' and @type='0'
			update cms_rec set cms0 = ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))*@amount,
						cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and datediff(day,arr,bdate) = 0 and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
						and sta = 'I' and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
							and (@d_line=0 or ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line)
		else if 	@unit = '1' and @type='1'
			update cms_rec set cms0 = @amount,cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and datediff(day,arr,bdate) = 0 and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
					and (@d_line=0 or @d_line < (rmrate+rmsur))
		else if 	@unit = '1' and @type='2'
			update cms_rec set cms0 = (rmrate-@amount),cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code
				where id = @id and bdate = @bdate and datediff(day,arr,bdate) = 0 and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
					and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and rtrim(cmsdetail) is null and charindex(substring(mode,1,1),@rmmode)>0
	end
	else if @nights >=  @uproom1 and (@nights< @uproom2 or @uproom2 = 0)
		select @upamount = @upamount1
	else if @nights >=  @uproom2 and (@nights< @uproom3 or @uproom3 = 0)
		select @upamount = @upamount2
	else if @nights >=  @uproom3 and (@nights< @uproom4 or @uproom4 = 0)
		select @upamount = @upamount3
	else if @nights >=  @uproom4 and (@nights< @uproom5 or @uproom5 = 0)
		select @upamount = @upamount4
	else if @nights >=  @uproom5 and (@nights< @uproom6 or @uproom6 = 0)
		select @upamount = @upamount5
	else if @nights >=  @uproom6 and (@nights< @uproom7 or @uproom7 = 0)
		select @upamount = @upamount6
	else if @nights >=  @uproom7
		select @upamount = @upamount7

	if @nights >=  @uproom1
	begin
		if @unit = '0'	and @type='0'
		begin
			update cms_rec set cms=cms0,changed = getdate() where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
								and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and ((datepart(month,@bdate) >= 1 and datepart(month,@bdate) <= 3 and datepart(month,bdate) >= 1 and datepart(month,bdate)<=3)
					or (datepart(month,@bdate) >= 4 and datepart(month,@bdate) <= 6 and datepart(month,bdate) >= 4 and datepart(month,bdate)<=6)
					or (datepart(month,@bdate) >= 7 and datepart(month,@bdate) <= 9 and datepart(month,bdate) >= 7 and datepart(month,bdate)<=9)
					or (datepart(month,@bdate) >= 10 and datepart(month,@bdate) <= 12 and datepart(month,bdate) >= 10 and datepart(month,bdate)<=12))
					and sta = 'I' and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>(rmrate*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate+(rmsur+netrate)*@srvrate)*@upamount
					and (@d_line=0 or ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line) 
			update cms_rec set cms0 = ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))*@upamount,
						cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code,changed = getdate(),back='F' 
				 			where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
								and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and ((datepart(month,@bdate) >= 1 and datepart(month,@bdate) <= 3 and datepart(month,bdate) >= 1 and datepart(month,bdate)<=3)
					or (datepart(month,@bdate) >= 4 and datepart(month,@bdate) <= 6 and datepart(month,bdate) >= 4 and datepart(month,bdate)<=6)
					or (datepart(month,@bdate) >= 7 and datepart(month,@bdate) <= 9 and datepart(month,bdate) >= 7 and datepart(month,bdate)<=9)
					or (datepart(month,@bdate) >= 10 and datepart(month,@bdate) <= 12 and datepart(month,bdate) >= 10 and datepart(month,bdate)<=12))
					and sta = 'I' and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>(rmrate*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate+(rmsur+netrate)*@srvrate)*@upamount
					and (@d_line=0 or ((rmrate+rmsur)*abs(1 -@packrate)*abs(1 -@srvrate)+netrate*@packrate*@srvrate+(packrate+netrate)*@packrate*(1 -@srvrate)+(rmsur+netrate)*@srvrate*(1 -@packrate))>@d_line) 
		end
		else if 	@unit = '0'	and @type='1'
		begin
			update cms_rec set cms=cms0,changed = getdate() where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				and ((datepart(month,@bdate) >= 1 and datepart(month,@bdate) <= 3 and datepart(month,bdate) >= 1 and datepart(month,bdate)<=3)
				or (datepart(month,@bdate) >= 4 and datepart(month,@bdate) <= 6 and datepart(month,bdate) >= 4 and datepart(month,bdate)<=6)
				or (datepart(month,@bdate) >= 7 and datepart(month,@bdate) <= 9 and datepart(month,bdate) >= 7 and datepart(month,bdate)<=9)
				or (datepart(month,@bdate) >= 10 and datepart(month,@bdate) <= 12 and datepart(month,bdate) >= 10 and datepart(month,bdate)<=12))
				 and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>@upamount
					 and (@d_line=0 or @d_line < (rmrate+rmsur))
			update cms_rec set cms0 = @upamount,cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code,
				changed = getdate(),back='F' where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				 and (((charindex(type,@rmtype)>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and ((datepart(month,@bdate) >= 1 and datepart(month,@bdate) <= 3 and datepart(month,bdate) >= 1 and datepart(month,bdate)<=3)
					or (datepart(month,@bdate) >= 4 and datepart(month,@bdate) <= 6 and datepart(month,bdate) >= 4 and datepart(month,bdate)<=6)
					or (datepart(month,@bdate) >= 7 and datepart(month,@bdate) <= 9 and datepart(month,bdate) >= 7 and datepart(month,bdate)<=9)
					or (datepart(month,@bdate) >= 10 and datepart(month,@bdate) <= 12 and datepart(month,bdate) >= 10 and datepart(month,bdate)<=12))
					and sta = 'I' and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>@upamount
					and (@d_line=0 or @d_line < (rmrate+rmsur))
					
		end
		else if 	@unit = '0'	and @type='2'
		begin
			update cms_rec set cms=cms0,changed = getdate() where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				and ((datepart(month,@bdate) >= 1 and datepart(month,@bdate) <= 3 and datepart(month,bdate) >= 1 and datepart(month,bdate)<=3)
				or (datepart(month,@bdate) >= 4 and datepart(month,@bdate) <= 6 and datepart(month,bdate) >= 4 and datepart(month,bdate)<=6)
				or (datepart(month,@bdate) >= 7 and datepart(month,@bdate) <= 9 and datepart(month,bdate) >= 7 and datepart(month,bdate)<=9)
				or (datepart(month,@bdate) >= 10 and datepart(month,@bdate) <= 12 and datepart(month,bdate) >= 10 and datepart(month,bdate)<=12))
				 and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and sta = 'I' and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>(rmrate-@upamount)
			update cms_rec set cms0 = (rmrate-@upamount),cmsunit=@unit,cmstype=@type,cmsdetail=@cms_code,
				changed = getdate(),back='F' where id = @id and belong=@accnt and cmscode=@cmscode and rtrim(cmsdetail)=null
				 and (((charindex(rtrim(type)+',',@rmtype+',')>0 or rtrim(@rmtype) is null) and @rmtype_s = 'F') or (@rmtype_s = 'T' and rtrim(type)=@rm_type))
					and ((datepart(month,@bdate) >= 1 and datepart(month,@bdate) <= 3 and datepart(month,bdate) >= 1 and datepart(month,bdate)<=3)
					or (datepart(month,@bdate) >= 4 and datepart(month,@bdate) <= 6 and datepart(month,bdate) >= 4 and datepart(month,bdate)<=6)
					or (datepart(month,@bdate) >= 7 and datepart(month,@bdate) <= 9 and datepart(month,bdate) >= 7 and datepart(month,bdate)<=9)
					or (datepart(month,@bdate) >= 10 and datepart(month,@bdate) <= 12 and datepart(month,bdate) >= 10 and datepart(month,bdate)<=12))
					and sta = 'I' and charindex(substring(mode,1,1),@rmmode)>0 and cms0<>(rmrate-@upamount)
		end
	end
end


return
;