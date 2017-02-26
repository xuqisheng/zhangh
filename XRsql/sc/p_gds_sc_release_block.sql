

if exists(select * from sysobjects where name = "p_gds_sc_release_block")
   drop proc p_gds_sc_release_block;
create proc p_gds_sc_release_block
   @grpaccnt char(10),
	@empno	char(10) = 'FOX'
as
-------------------------------------------
-- �ͷ� block ���� ��Ԥ���� -- id > 0 
--
--  �ͷ�֮ǰ���ʻ�״̬�����Ѿ���� W, N, X 
-------------------------------------------
declare
   @rm_type  char(5),
   @pbeg     datetime,
   @pend     datetime,
   @_quan    int,
   @ret      int,
   @sta      char(1),
	@msg		 varchar(60)

select @ret=0, @msg='ok'
select @sta = sta from sc_master where accnt = @grpaccnt
if @@rowcount=0 
begin 
	select @ret=1, @msg='�ʻ�������'
	return @ret 
end 
if @sta not in ('R', 'I', 'W', 'X', 'N')
begin 
	select @ret=1, @msg='��ǰ״̬���ô���'
	return @ret 
end 

begin tran
save  tran p_gds_sc_release_block_s1

update sc_master set sta = sta where accnt = @grpaccnt
update chktprm set code = 'A'

if @sta = 'W' 
begin 
	delete rsvsrc_wait where accnt=@grpaccnt 
end
else
begin 
	declare	@id		int
	declare c_update_group cursor for select id from rsvsrc where accnt = @grpaccnt and id>0 
	open c_update_group
	fetch c_update_group into @id
	while @@sqlstatus = 0
	begin
		exec p_gds_reserve_rsv_del @grpaccnt,@id,'R',@empno,@ret output, @msg output
		if @ret<>0 
			break 
		fetch c_update_group into @id
	end
	close c_update_group
	deallocate cursor c_update_group
end 

commit tran 
return @ret
;