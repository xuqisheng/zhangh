--------------------------------------------------
--		通过触发器 维护  armst 的分账号
--------------------------------------------------


-----------------------
--	Insert
-----------------------
create trigger t_gds_argst_insert
   on argst
   for insert as
begin
declare		@empno		char(10),
				@accnt		char(10),
				@tag2			char(1)
select @accnt=accnt, @tag2=tag2, @empno = cby from inserted 
if @@rowcount=1 and @tag2='T'
	exec p_gds_master_ar_subaccnt @accnt, @empno
end
;


-----------------------
--	Update
-----------------------
create trigger t_gds_argst_update
   on argst
   for update as
begin
declare		@empno		char(10),
				@accnt		char(10)

if update(logmark)
   insert argst_log select * from inserted

if update(tag2) 
	begin
	select @accnt=accnt, @empno = cby from inserted 
	exec p_gds_master_ar_subaccnt @accnt, @empno

	select @accnt=accnt, @empno = cby from deleted 
	exec p_gds_master_ar_subaccnt @accnt, @empno
	end
end
;


-----------------------
--	Delete
-----------------------
create trigger t_gds_argst_delete
   on argst
   for delete as
begin
declare		@empno		char(10),
				@accnt		char(10),
				@tag2			char(1)
select @accnt=accnt, @tag2=tag2, @empno = cby from deleted 
if @@rowcount=1 and @tag2='T' 
	exec p_gds_master_ar_subaccnt @accnt, @empno
end
;