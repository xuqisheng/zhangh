-- ------------------------------------------------------------------------
-- message_leaveword 触发器，关联电话 pms  -- lamp 
-- ------------------------------------------------------------------------

-- ------------------------------------------------------------------------
--		insert 
-- ------------------------------------------------------------------------
create trigger t_gds_message_leaveword_insert
   on message_leaveword
   for insert 
as
declare 		@roomno 		char(5),
				@lamp 		char(1),
				@sta 			char(1),
				@accnt 		char(10),
				@sort			char(3),
				@tag			char(1)

select @accnt=accnt, @sort=sort, @lamp=lamp, @tag=tag from inserted
if @@rowcount=0 or substring(@accnt,1,1)<>'F' or @sort<>'LWD' or @lamp<>'2' or @tag>='2'
	return

select @roomno=roomno, @sta=sta from master where accnt=@accnt
if @@rowcount=1 and @sta='I'
	exec p_gds_phone_grade @roomno, 'mail', '1', @accnt  -- Lamp on 
;

-- ------------------------------------------------------------------------
--		update
-- ------------------------------------------------------------------------
create trigger t_gds_message_leaveword_update
   on message_leaveword
   for update 
as
declare 	@new_tag 	char(1),	@old_tag 	char(1),
        	@new_lamp 	char(1),	@old_lamp 	char(1),
			@accnt 		char(10), @sta			char(2),
			@sort			char(3),	@roomno		char(5)

select @accnt=accnt, @new_lamp=lamp, @new_tag=tag, @sort=sort from inserted
if @@rowcount=0 or substring(@accnt,1,1) <> 'F' or @new_lamp<>'LWD'
	return

if update(lamp) or update(tag)
begin
	if @new_tag<'2' and @new_lamp='2'
		select @new_lamp = '1'
	else
		select @new_lamp = '0'

	select @old_lamp=lamp, @old_tag=tag from deleted
	if @old_tag<'2' and @old_lamp='2'
		select @old_lamp = '1'
	else
		select @old_lamp = '0'

	if @new_lamp <> @old_lamp 
	begin
		select @roomno=roomno, @sta=sta from master where accnt=@accnt
		if @@rowcount=1 and @sta='I'
			exec p_gds_phone_grade @roomno, 'mail', @new_lamp, @accnt   -- Lamp on/off
	end
end
;

-- ------------------------------------------------------------------------
--		Delete 
-- ------------------------------------------------------------------------
create trigger t_gds_message_leaveword_delete
   on message_leaveword
   for delete
as
declare 		@roomno 		char(5),
				@lamp 		char(1),
				@sta 			char(1),
				@accnt 		char(10),
				@sort			char(3),
				@tag			char(1)

select @accnt=accnt, @sort=sort, @lamp=lamp, @tag=tag from deleted
if @@rowcount=0 or substring(@accnt,1,1)<>'F' or @sort<>'LWD' or @lamp<>'2' or @tag>='2'
	return

select @roomno=roomno, @sta=sta from master where accnt=@accnt
if @@rowcount=1 and @sta='I'
	exec p_gds_phone_grade @roomno, 'mail', '0', @accnt   -- lamp off
;
