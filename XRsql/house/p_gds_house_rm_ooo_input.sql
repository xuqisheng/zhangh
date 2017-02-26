if object_id('p_gds_house_rm_ooo_input') is not null
drop proc p_gds_house_rm_ooo_input
;
create proc p_gds_house_rm_ooo_input
	@sfolio		char(10),
	@roomno		char(5),
	@sta			char(1),
	@dbegin		datetime,
	@dend			datetime,
	@reason		char(3),
	@remark		varchar(255),
	@empno		char(10)
as
-- -----------------------------------------------------------------------
-- 		ά���������  --- ά�޵���¼��,�޸�
-- -----------------------------------------------------------------------
declare 	@ret	int,
			@msg	varchar(60),
			@osta	char(1)

select @ret = 0, @msg = 'OK!'

begin tran
save tran p_gds_house_rm_ooo_input1

if not exists ( select 1 from rmsta where roomno = @roomno)
begin
	select @ret=1,@msg=@roomno + ' - ���Ų����� !'
	goto gds
end
if not exists(select 1 from rmstalist where sta = @sta and maintnmark = 'T')
begin
	select @ret=1,@msg='ά��������״̬���� ! --- %1^' + @sta
	goto gds
end
if @dbegin is null or datediff(dd, @dbegin, getdate()) > 0
begin
	select @ret=1,@msg='ά����������ʼ�������ô��� !'
	goto gds
end
if @dend is not null and datediff(dd, @dbegin, @dend) < 0
begin
	select @ret=1,@msg='ά����������ֹ�������ô��� !'
	goto gds
end
select @reason = rtrim(@reason)
if @reason is null
begin
	select @ret=1,@msg='���ɲ���Ϊ�� !'
	goto gds
end
if not exists(select 1 from basecode where cat='rmmaint_reason' and code = @reason)
begin
	select @ret=1,@msg='ά��������ԭ����� ! --- %1^' + @reason
	goto gds
end
if @remark is null select @remark=''

-- Ŀǰ���κοͷ�ֻ����һ����Ч��ά�޼�¼
--select @osta=sta from rmsta where roomno=@roomno
-- if charindex(@osta,'OS')>0 and datediff(dd, getdate(), @dbegin)>0
-- begin
-- 	select @ret=1,@msg='�ÿͷ���ǰ������ά��״̬�����Ƚ��'
-- 	goto gds
-- end
-- if charindex(@osta,'OS')=0 and datediff(dd, getdate(), @dbegin)<=0
-- 	and exists(select 1 from rm_ooo where roomno=@roomno and status='I')

if @sfolio is null --clg
    select @sfolio=''
--2008-11-13 yjw room os status multi setting
--if  exists(select 1 from rm_ooo where roomno=@roomno and status='I' and (dbegin>@dend or dend<@dbegin) ) or not exists(select 1 from rm_ooo where roomno=@roomno and status='I')
--    select @ret=0
--else if @sfolio='' or @sfolio is null
if exists(select 1 from rm_ooo where status='I' and roomno=@roomno and folio<>@sfolio and not (dbegin>=@dend or dend<=@dbegin))
    begin
	    select @ret=1,@msg='�ÿͷ�Ŀǰ��ά�޼ƻ������Ƚ��'
	    goto gds
    end
else
    select @ret=0

declare @begin_min datetime

select @begin_min=min(dbegin) from rm_ooo where roomno=@roomno and status='I'
if @begin_min>=@dbegin or @begin_min is null
    begin
        exec @ret = p_gds_update_room_status @roomno, 'L', @sta, @dbegin, @dend, @empno, 'R', @msg output
        if @ret <> 0
	        goto gds
    end 
else if exists(select 1 from rm_ooo where folio=@sfolio and dbegin=@begin_min and roomno=@roomno and status='I')
     begin
		  if @begin_min < @dbegin and datediff(dd,getdate(),@dbegin)>0 and exists(select 1 from rmsta where roomno=@roomno and charindex(sta,'OS')>0 )
				begin
				 select @ret=1,@msg='�ÿͷ���ǰ������ά��״̬�����Ƚ��'
				 goto gds
			 end
        exec @ret = p_gds_update_room_status @roomno, 'L', @sta, @dbegin, @dend, @empno, 'R', @msg output
        if @ret <> 0
	        goto gds
    end 
----    yjw

--  �ر�ע�� : folio + sta('I')  --- Ψһ
--  @msg �����洢 ���Կ���

-- if exists(select 1 from rm_ooo where roomno = @roomno and status = 'I')  	--  �޸�
if @sfolio<>'' and @sfolio is not null
begin
	select @msg= folio from rm_ooo where roomno=@roomno and status = 'I' and folio=@sfolio
	update rm_ooo set sfolio=@sfolio, sta=@sta, dbegin=@dbegin, dend=@dend, reason=@reason, remark=@remark, empno1=@empno, date1=getdate()
		where roomno=@roomno and status = 'I' and folio=@sfolio
end
else																								--  ����
begin
	declare @folio 	char(10)
	exec p_hs_GetAccnt1 'OO',  @folio output
	select @msg = @folio
	insert rm_ooo (folio, sfolio, status, roomno, oroomno, sta, dbegin, dend, reason, remark, empno1, date1)
		select @folio, @sfolio, 'I', @roomno, @roomno, @sta, @dbegin, @dend, @reason, @remark, @empno, getdate()
end
if @@error <> 0
	select @ret = 1, @msg = '���ݸ���ʧ�� ! --- @@error<>0 '

update rm_ooo set logmark = logmark + 1 where roomno = @roomno and status = 'I'

gds:
if @ret <> 0
	rollback tran p_gds_house_rm_ooo_input1
commit tran

select @ret, @msg
return @ret
;