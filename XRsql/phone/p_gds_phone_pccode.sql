
if exists(select 1 from sysobjects where name = 'p_gds_phone_pccode' and type='P')
	drop proc p_gds_phone_pccode;
create proc p_gds_phone_pccode
	@p_extno		varchar(8),
	@mode			char(2),
	@phcode		varchar(15),
	@calltype	char(1),
	@pccode		char(5)		output
as

declare 		@class		varchar(10), 
				@ret 			int, 
				@address 	varchar(20)

-- 取得常规入账费用代码
declare		@bs_idd		char(5),			@bs_ddd		char(5),
				@rm_idd		char(5),			@rm_ddd		char(5)
select @bs_idd = rtrim(value) from sysoption where catalog='phone' and item='bsidd_pccode'
if @@rowcount=0 or @bs_idd is null
	select @bs_idd = '???'
select @bs_ddd = rtrim(value) from sysoption where catalog='phone' and item='bsddd_pccode'
if @@rowcount=0 or @bs_idd is null
	select @bs_ddd = '???'
select @rm_idd = rtrim(value) from sysoption where catalog='phone' and item='rmidd_pccode'
if @@rowcount=0 or @rm_idd is null
	select @rm_idd = '???'
select @rm_ddd = rtrim(value) from sysoption where catalog='phone' and item='rmddd_pccode'
if @@rowcount=0 or @rm_idd is null
	select @rm_ddd = '???'

--
select 	@pccode = '', @ret = 0

--
if rtrim(@calltype) is null
	begin
	exec @ret = p_gds_phone_calltype @phcode, @calltype output, @address output, 'R'
	if @ret <> 0
		begin
		select @pccode='', @ret = 1
		return @ret
		end
	end

if @mode = 'RM'
	begin
	if exists(select 1 from sysoption a, phncls b where a.catalog='phone' and a.item='citycall_class' and charindex(b.class,rtrim(a.value))>0 )
		begin
			select @class = rtrim(value) from sysoption where catalog='phone' and item='citycall_class'
			if charindex(@calltype, @class) > 0
				select @pccode = rtrim(value) from sysoption where catalog='phone' and item='rmcity_pccode'
		end
	if @pccode = '' or not exists(select 1 from pccode where pccode=@pccode)
		begin
	   if substring(@phcode,1,2) = '00'
			select @pccode = @rm_idd
		else
			select @pccode = @rm_ddd
		end
	end

else if @mode = 'BS'
	begin
	if exists(select 1 from sysoption a, phncls b where a.catalog='phone' and a.item='citycall_class' and charindex(b.class, rtrim(a.value))>0 )
		begin
			select @class = rtrim(value) from sysoption where catalog='phone' and item='citycall_class'
			if charindex(@calltype, @class) > 0
				select @pccode = rtrim(value) from sysoption where catalog='phone' and item='bscity_pccode'
		end
	if @pccode = '' or not exists(select 1 from pccode where pccode=@pccode)
		begin
	   if substring(@phcode,1,2) = '00'
			select @pccode = @bs_idd
		else
			select @pccode = @bs_ddd
		end
	end

else
	select @pccode = '', @ret = 1

return @ret
;

