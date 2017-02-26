
if  exists(select * from sysobjects where name = "p_gds_rmratedef_timechk")
	drop proc p_gds_rmratedef_timechk;
create proc p_gds_rmratedef_timechk
	@code				char(10),					--	��ϸ��
	@gtype			varchar(100),				-- ����
	@type				varchar(100),				-- ����
	@begin_			datetime,
	@end_				datetime,
	@retmode			char(1) = 'S',
	@msg				varchar(60)='' output  
as
-- --------------------------------------------------------------------------
--		������ϸ�뷿��ʱ����Ч���ж�  
-- @gtype,type,begin_,end_ = '' ��ʱ�����ʾ���÷�����ϸ���ʱ����Ч��  
-- �����ʾ ��ϸ���޸ĵ�����֮ ʱ����Ч��  
-----------------------------------------------------------------------------
declare	@ret			int,
			@ratecode	char(10)

select @ret = 0, @msg = '', @ratecode='' 

-- begin
create table #cross (type char(5) null, code char(10) null, begin_ datetime null, end_ datetime null)

select @ratecode=isnull((select min(code) from rmratecode_link where code>@ratecode and rmcode=@code), '') 
while @ratecode <> ''
begin
	delete #cross 
	if rtrim(@type) is null 
	begin
		insert #cross select  a.type, b.code, b.begin_, b.end_ 
			from typim a, rmratedef b, rmratecode_link c
				where c.code=@ratecode and b.code=c.rmcode 
					and ( charindex(','+rtrim(a.type)+',',','+rtrim(b.type)+',')>0 or rtrim(b.type) is null)
					and ( charindex(','+rtrim(a.gtype)+',',','+rtrim(b.gtype)+',')>0 or rtrim(b.gtype) is null)
	end
	else
	begin
		insert #cross select  a.type, b.code, b.begin_, b.end_ 
			from typim a, rmratedef b, rmratecode_link c
				where c.code=@ratecode and b.code=c.rmcode and c.rmcode<>@code 
					and ( charindex(','+rtrim(a.type)+',',','+rtrim(b.type)+',')>0 or rtrim(b.type) is null)
					and ( charindex(','+rtrim(a.gtype)+',',','+rtrim(b.gtype)+',')>0 or rtrim(b.gtype) is null)
		insert #cross select  a.type, @code, @begin_, @end_ 
			from typim a where charindex(','+rtrim(a.type)+',',','+rtrim(@type)+',')>0 
	end	

	update #cross set begin_ = convert(datetime, '1990/1/1') where begin_ is null
	update #cross set end_ = convert(datetime, '2020/1/1') where end_ is null
	if exists(select 1 from #cross a, #cross b 
					where a.type=b.type and a.code<>b.code 
						and a.begin_<=b.begin_ and a.end_>=b.begin_)  -- ʱ�䲻�ܽ���
		select @ret = 1, @msg = '����۸�������ظ�������'
	
	if @ret<>0 
		break
	else
		select @ratecode=isnull((select min(code) from rmratecode_link where code>@ratecode and rmcode=@code), '') 
end

if @retmode='S' 
	select @ret, @msg
return @ret
;
