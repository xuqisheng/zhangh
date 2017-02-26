IF OBJECT_ID('dbo.p_hry_phone_addmod_room') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_hry_phone_addmod_room
END;
create proc p_hry_phone_addmod_room
	@dept			char(4) ,
	@room			char(8) ,
	@class		char(1) ,
	@opmode		char(1)
as

declare
	@ret			integer,
	@msg			varchar(70),
	@rentdept	char(4)

select @ret = 0, @msg = ''
begin tran
save tran p_hry_phone_addmod_room_s1
select @dept = dept from phdeptdef holdlock where dept = @dept
if @@rowcount = 0
	select @ret = 1,  @msg = '������������' + @dept + '����Ӧ���û���'
if @ret = 0
	begin
	if @opmode = 'A'
		begin
		select @rentdept = dept from phdeptroom holdlock where room = @room
		if @@rowcount > 0
			begin
			if @rentdept = @dept
				select @ret = 1, @msg = '���û��Ѿ��Ǽ������˷ֻ�'+@room
			else
				select @ret = 1, @msg = '�ֻ�'+@room+'�Ѿ�������'+@rentdept+'��Ӧ�û��Ǽ�����'
			end
		else
			insert phdeptroom (dept, room, date, class) values (@dept, @room, getdate(), @class)
		end
	else if @opmode = 'M'
		begin
		select @rentdept = dept from phdeptroom holdlock where room = @room
		if @@rowcount =  0
			select @ret = 1, @msg = '��δ�Ǽ����÷ֻ�' + @room
		else if @rentdept <> @dept
			select @ret = 0, @msg = '�ֻ�' + @room + '�Ѿ�������' + @rentdept + '��Ӧ�û��Ǽ�����'
		else
			update phdeptroom set class = @class where dept = @dept and room = @room
		end
	else if @opmode = 'D'
		begin
		select @rentdept = dept from phdeptroom holdlock where room = @room
		if @@rowcount =  0
			select @ret = 1, @msg = '��δ�Ǽ����÷ֻ�' + @room
		else if @rentdept <> @dept
			select @ret = 1, @msg = '����ɾ�������û�' + @rentdept + '�Ǽ�ʹ�õķֻ�' + @room
		else
			begin
			update phdeptroom set  ddate = getdate() where dept = @dept and room = @room
			insert phhisdeptroom	(room, dept, date, ddate, class)
				select @room, @dept, date, ddate, class from phdeptroom
				where dept = @dept and room = @room
			delete phdeptroom where dept = @dept and room = @room
			end
		end
	end
if @ret <> 0
	rollback tran p_hry_phone_addmod_room_s1
commit tran
select @ret, @msg
return @ret
;