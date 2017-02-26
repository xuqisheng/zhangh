
if  exists(select * from sysobjects where name = "p_tcr_cmscode_link")
	drop proc p_tcr_cmscode_link
;
create proc p_tcr_cmscode_link
	@cmscode		char(10),					--	������
	@cmsdef		char(10)						--	��ϸ��
as
declare	@id			int,
			@ret			int,
			@msg			varchar(60)

select @ret = 0, @msg = ''

-- Test code
if not exists(select 1 from cmscode where code = @cmscode)
begin
	select @ret = 1, @msg = '%1������^Ӷ����'
	goto p_out
end
if exists(select 1 from cmscode_link where code = @cmscode and cmscode = @cmsdef)
begin
	select @ret = 1, @msg = '%1�Ѿ�����^Ӷ����ϸ��'
	goto p_out
end

-- begin
create table #cross (type char(5) null, code char(10) null)
begin tran
save tran s_input

select @id = isnull((select max(pri) from cmscode_link where code=@cmscode), 0) + 10
insert cmscode_link(code,pri,cmscode) values(@cmscode, @id, @cmsdef)
insert #cross select  a.type, b.no from typim a, cms_defitem b, cmscode_link c
	where c.code=@cmscode and b.no=c.cmscode and charindex(','+rtrim(a.type)+',',','+rtrim(b.type)+',')>0
if exists(select 1 from #cross a, #cross b where a.type=b.type and a.code<>b.code)
	select @ret = 1, @msg = '����Ӷ��������ظ�������'

if @ret <> 0
	rollback tran s_input
commit

p_out:
select @ret, @msg

return @ret
;
