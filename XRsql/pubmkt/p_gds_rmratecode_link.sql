
if  exists(select * from sysobjects where name = "p_gds_rmratecode_link")
	drop proc p_gds_rmratecode_link;
create proc p_gds_rmratecode_link
	@ratecode		char(10),					--	������
	@ratedef			char(10)						--	��ϸ��
as
-- --------------------------------------------------------------------------
--		���������ж�����ϸ���� -- ע�ⷿ��۸����ظ�
-----------------------------------------------------------------------------
declare	@id			int,
			@ret			int,
			@msg			varchar(60)

select @ret = 0, @msg = ''

-- Test code
if not exists(select 1 from rmratecode where code = @ratecode)
begin
	select @ret = 1, @msg = '%1������^������'
	goto p_out
end
if exists(select 1 from rmratecode_link where code = @ratecode and rmcode = @ratedef)
begin
	select @ret = 1, @msg = '%1�Ѿ�����^������ϸ��'
	goto p_out
end

-- begin
create table #cross (type char(5) null, code char(10) null, begin_ datetime null, end_ datetime null)
begin tran
save tran s_input

select @id = isnull((select max(pri) from rmratecode_link where code=@ratecode), 0) + 10

insert rmratecode_link(code,pri,rmcode) values(@ratecode, @id, @ratedef)
insert #cross select  a.type, b.code, b.begin_, b.end_ 
	from typim a, rmratedef b, rmratecode_link c
		where c.code=@ratecode and b.code=c.rmcode 
			and ( charindex(','+rtrim(a.type)+',',','+rtrim(b.type)+',')>0 or rtrim(b.type) is null)
			and ( charindex(','+rtrim(a.gtype)+',',','+rtrim(b.gtype)+',')>0 or rtrim(b.gtype) is null)

update #cross set begin_ = convert(datetime, '1990/1/1') where begin_ is null
update #cross set end_ = convert(datetime, '2020/1/1') where end_ is null
if exists(select 1 from #cross a, #cross b 
				where a.type=b.type and a.code<>b.code 
					and a.begin_<=b.begin_ and a.end_>=b.begin_)  -- ʱ�䲻�ܽ���
	select @ret = 1, @msg = '����ʧ�ܣ�����۸�������ظ�������'

if @ret <> 0
	rollback tran s_input
commit

p_out:
select @ret, @msg
return @ret
;
