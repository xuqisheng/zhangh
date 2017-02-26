
if exists(select * from sysobjects where name = "p_gds_reserve_release_block")
   drop proc p_gds_reserve_release_block;

create proc p_gds_reserve_release_block
   @grpaccnt char(10),
	@empno	char(10) = 'FOX'
as
------------------------------------------------------------------
--	释放某团体所有 纯预留房
------------------------------------------------------------------
declare
   @rm_type  char(5),
   @pbeg     datetime,
   @pend     datetime,
   @_quan    int,
   @ret      int,
   @sta      char(1),
	@msg		 varchar(60)

select @ret=0, @msg='ok'

begin tran
save  tran p_gds_reserve_release_block_s1

update master set sta = sta where accnt = @grpaccnt
select @sta = sta from master where accnt = @grpaccnt

update chktprm set code = 'A'

declare	@id		int
declare c_update_group cursor for select id from rsvsrc where accnt = @grpaccnt and id>0 
open c_update_group
fetch c_update_group into @id
while @@sqlstatus = 0
begin
	delete rsvsrc_cxl where accnt=@grpaccnt and id=@id 
	insert rsvsrc_cxl select * from rsvsrc where accnt=@grpaccnt and id=@id 

	exec p_gds_reserve_rsv_del @grpaccnt,@id,'R',@empno,@ret output, @msg output
	fetch c_update_group into @id
end
close c_update_group
deallocate cursor c_update_group

commit tran 
return @ret
;