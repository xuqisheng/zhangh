
if  exists(select * from sysobjects where name = "p_cq_cmscode_judge")
	drop proc p_cq_cmscode_judge;
create proc p_cq_cmscode_judge
		@type					char(5),
		@cmscode				char(10),
		@weekday				char(1),
		@bdate				datetime,
		@cms_code			char(10) out
as
----------------------------------------------------------------------------
--	���ݷ��ࡢ���ڡ�Ӷ���� --�� ȡ�ö�Ӧ��Ӷ����ϸ��
----------------------------------------------------------------------------
declare
		@cms_item_w			integer,
		@cms_item_d			integer,
		@cms_item			char(10),
		@pri					integer,
		@begin				datetime,
		@end					datetime,
		@datecond			char(100),
		@datecond1			char(100),
		@rmtype				char(255),  -- 100  xia 
		@exit					char(1)

select @cms_item_d = 0, @cms_item_w = 0

declare c_cms_item cursor for
	select pri from cmscode_link where code = @cmscode and cmscode in (
		select no from cms_defitem where lower(substring(datecond,1,1)) = 'd')
		and code in (select code from cmscode where (@bdate>=begin_ or begin_ = null) and (@bdate<=end_ or end_ = null) and halt='F') order by pri

-- ���жϸ�Ӷ�������Ƿ��ж�����"w:1234567"������ȡ��С��pri(���ȼ��ߵ�)
if exists(select 1 from cms_defitem where no in (select cmscode from cmscode_link where code = @cmscode)
		and lower(substring(datecond,1,1)) = 'w' and charindex(@weekday,datecond) > 0
			and (charindex(rtrim(@type),rmtype) > 0 or rtrim(rmtype) is null) )
	select @cms_item_w = min(a.pri) from cmscode_link a ,cms_defitem b where a.cmscode = b.no and a.code = @cmscode
		and lower(substring(b.datecond,1,1)) = 'w' and charindex(@weekday,b.datecond) > 0
			and (charindex(rtrim(@type),b.rmtype) > 0 or rtrim(b.rmtype) is null)

-- ���жϸ�Ӷ�������Ƿ��ж�����d:yy/mm/dd-yy/mm/dd��yy/mm/dd-yy/mm/dd��������ȡ��С��pri(���ȼ��ߵ�)
if exists(select 1 from cms_defitem where no in (select cmscode from cmscode_link where code = @cmscode)
		and lower(substring(datecond,1,1)) = 'd' )
	begin

	open c_cms_item
	fetch c_cms_item into @pri
	while @@sqlstatus = 0 and @exit <> 'T'
		begin
		select @datecond = datecond,@rmtype = rmtype from cms_defitem where no =
				(select cmscode from cmscode_link where code = @cmscode and pri = @pri)
		select @datecond = substring(@datecond,3,datalength(@datecond) -2)
		while charindex(';',@datecond) > 0
			begin
			select @datecond1 = substring(@datecond,1,charindex(';',@datecond) - 1)
			select @datecond  = substring(@datecond,charindex(';',@datecond) + 1,datalength(@datecond) - charindex(';',@datecond))
			select @begin = convert(datetime,substring(@datecond1,1,charindex('-',@datecond1) - 1))
			select @end   = convert(datetime,substring(@datecond1,charindex('-',@datecond1) + 1,datalength(@datecond1) - charindex('-',@datecond1)))
			if @bdate >= @begin and @bdate <= @end and (charindex(rtrim(@type),@rmtype) > 0 or rtrim(@rmtype)is null)
				begin
				select @cms_item_d = @pri,@exit = 'T'
				break
				end
			end
		fetch c_cms_item into @pri
		end
	close c_cms_item
	deallocate cursor c_cms_item 
	end


--�ڶ��߶����ڵ�����»������ȼ�
if @cms_item_d > @cms_item_w and @cms_item_w >0
	select @cms_item = cmscode from cmscode_link where code = @cmscode and pri = @cms_item_w
if @cms_item_w > @cms_item_d and @cms_item_d > 0
	select @cms_item = cmscode from cmscode_link where code = @cmscode and pri = @cms_item_d

--����ĳһ�����ھ�����
if @cms_item_d > 0 and @cms_item_w = 0
	select @cms_item = cmscode from cmscode_link where code = @cmscode and pri = @cms_item_d
if @cms_item_w > 0 and @cms_item_d = 0
	select @cms_item = cmscode from cmscode_link where code = @cmscode and pri = @cms_item_w

--�ڶ��߶������ڵ������ȡ��С��

if @cms_item_d = @cms_item_w and @cms_item_d = 0
begin
	select @cms_item_w = min(pri) from cmscode_link where code = @cmscode and cmscode in (select no from cms_defitem where (datecond = '' or datecond is null) and (charindex(rtrim(@type),rmtype) > 0 or rtrim(rmtype) is null))	
   if @cms_item_w is not null
		select @cms_item = cmscode from cmscode_link where code= @cmscode and pri = @cms_item_w
	else
		select @cms_item = ''
end


--
if @cms_item <> ''  and @cms_item is not null
	select @cms_code = rtrim(@cms_item)
else
	select @cms_code = ''
return 0;
