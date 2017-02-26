
IF OBJECT_ID('p_foxhis_argcode_link') IS NOT NULL
    DROP PROCEDURE p_foxhis_argcode_link
;
create proc p_foxhis_argcode_link
as
---------------------------------------------------------------------
-- 帐单码 及其 pccode 列表
---------------------------------------------------------------------
declare
			@line					integer,
			@argcode				varchar(12),
			@pccode				varchar(12),
			@code_str			varchar(60),
			@count				int 

create table #gout
(
  code              varchar(12)		default '' null,
  line              integer			default 0 null,
  num             	integer			default 0 null,
  code1             varchar(12)		default '' null,
  descript          varchar(24)		default '' null,
  descript1         varchar(50)		default '' null,
  code_str          varchar(60)		default '' null 
)
insert #gout select argcode,1,0,argcode,descript,descript1,'' from argcode order by argcode

-- 
declare c_argcode cursor for select code from #gout order by code
declare c_pccode cursor for select pccode from pccode where argcode=@argcode order by pccode

-- 
open c_argcode
fetch c_argcode into @argcode
while @@sqlstatus = 0
begin
	select @code_str='#', @line = 1, @count = 0

	open c_pccode
	fetch c_pccode into @pccode
	while @@sqlstatus = 0
	begin
		select @count = @count + 1
		select @code_str = @code_str + ',' + rtrim(@pccode)
		if datalength(@code_str)>50
		begin
			select @code_str = substring(@code_str,3,58)
			if not exists(select 1 from #gout where code = @argcode and line = @line) 
				insert #gout select @argcode,@line,null,'','','',''
			update #gout set code_str = @code_str where code = @argcode and line = @line
			select @code_str = '#',@line = @line + 1
		end
		fetch c_pccode into @pccode
	end
	close c_pccode
	if @code_str<>'#'
	begin
		select @code_str = substring(@code_str,3,58)
		if not exists(select 1 from #gout where code = @argcode and line = @line) 
			insert #gout select @argcode,@line,null,'','','',''
		update #gout set code_str = @code_str where code = @argcode and line = @line
	end
	
	--
	update #gout set num = @count where code = @argcode and line = 1
	
	fetch c_argcode into @argcode
end
close c_argcode
deallocate cursor c_argcode
deallocate cursor c_pccode

select  * from #gout order by code ,line
return
;
