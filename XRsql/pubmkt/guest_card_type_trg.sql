-----------------------------
-- guest_card_type trigger 
-----------------------------

--@@@@@@@@@@@@@@@
--	insert 
--@@@@@@@@@@@@@@@
if exists (select * from sysobjects where name = 't_gds_guest_card_type_insert' and type = 'TR')
   drop trigger t_gds_guest_card_type_insert;
create trigger t_gds_guest_card_type_insert
   on guest_card_type
   for insert as
begin
declare	@pccodes	varchar(30),
			@code		varchar(10)
select @code=code, @pccodes = pccodes from inserted
if @@rowcount = 0 
   rollback trigger with raiserror 20000 "增加代码错误HRY_MARK"

-----------------------------
-- 注意重复 
-----------------------------
select @pccodes = isnull(rtrim(@pccodes), '')
if @pccodes <> '' 
begin 
	if exists(select 1 from guest_card_type a, pccode b
					where a.pccodes<>'' and a.code<>@code 
						and charindex(','+rtrim(b.pccode)+',', ','+rtrim(a.pccodes)+',')>0
						and charindex(','+rtrim(b.pccode)+',', ','+rtrim(@pccodes)+',')>0
				)
	   rollback trigger with raiserror 20000 "代码有重复，请检查HRY_MARK"
end 
end
;


--@@@@@@@@@@@@@@@
--	update
--@@@@@@@@@@@@@@@
if exists (select * from sysobjects where name = 't_gds_guest_card_type_update' and type = 'TR')
   drop trigger t_gds_guest_card_type_update;
create trigger t_gds_guest_card_type_update
   on guest_card_type
   for update as
begin
declare	@pccodes	varchar(30),
			@code		varchar(10)
select @code=code, @pccodes = pccodes from inserted
if @@rowcount = 0 
   rollback trigger with raiserror 20000 "增加代码错误HRY_MARK"

-----------------------------
-- 注意重复 
-----------------------------
select @pccodes = isnull(rtrim(@pccodes), '')
if update(pccodes) and @pccodes <> '' 
begin 
	if exists(select 1 from guest_card_type a, pccode b
					where a.pccodes<>'' and a.code<>@code 
						and charindex(','+rtrim(b.pccode)+',', ','+rtrim(a.pccodes)+',')>0
						and charindex(','+rtrim(b.pccode)+',', ','+rtrim(@pccodes)+',')>0
				)
	   rollback trigger with raiserror 20000 "代码有重复，请检查HRY_MARK"
end 
end
;


--@@@@@@@@@@@@@@@
--	delete
--@@@@@@@@@@@@@@@
if exists (select * from sysobjects where name = 't_gds_guest_card_type_delete' and type = 'TR')
   drop trigger t_gds_guest_card_type_delete;
create trigger t_gds_guest_card_type_delete
   on guest_card_type
   for delete as
begin
declare	@code		varchar(10)
select @code=code from deleted
if @@rowcount = 0 
   rollback trigger with raiserror 20000 "删除代码错误HRY_MARK"

if exists ( select 1 from guest_card where cardcode=@code )
   rollback trigger with raiserror 20000 "代码还在使用, 不能删除HRY_MARK"
else if exists ( select 1 from vipcard_type where guestcard=@code )
   rollback trigger with raiserror 20000 "代码还在使用, 不能删除HRY_MARK"

end
;

