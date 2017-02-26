
if exists (select 1 from sysobjects where name = 'p_gds_house_rm_ooo_del')
	drop proc p_gds_house_rm_ooo_del
;
create proc p_gds_house_rm_ooo_del
    @sfolio     char(10),
	@gmode		char(1),			--  X-ȡ��, O-���
	@roomno		char(5),
	@sta			char(1),
	@empno		char(10)
as
-- -----------------------------------------------------------------------
-- 		ά���������  --- ά�޵���ȡ��,���
-- 		���ṩ�ָ�ά�޵�
--
-- 				�ر�ע��: ��ϵͳû�иõ��ݵ�ʱ��,ҲҪ��ά�������!!!
-- -----------------------------------------------------------------------
declare 	@ret	int,
			@msg	varchar(60),
            @begin  datetime,
            @end    datetime

select @ret = 0, @msg = 'OK!'

begin tran
save tran p_gds_house_rm_ooo_del1

if not exists ( select 1 from rmsta where roomno = @roomno)
begin
	select @ret=1,@msg='���Ų�����'
	goto gds
end
if @gmode='O' and charindex(@sta, 'R,D,I,T') <= 0
begin
	select @ret=1,@msg='ά�������״̬���� ! --- %1^' + @sta
	goto gds
end
if charindex(@gmode, 'X,O') <= 0
begin
	select @ret=1,@msg='ά��������״̬���� ! --- %1^' + @gmode
	goto gds
end

if @gmode = 'O' or (@gmode = 'X' and not exists(select 1 from rmsta where sta in ('O','S')))--ȡ��״̬����ǰ����ά�ޣ���Ӱ��rmsta
    exec @ret = p_gds_update_room_status @roomno, 'l', @sta, null, null, @empno, 'R', @msg output
    if @ret <> 0
    	goto gds

if exists ( select 1 from rm_ooo where roomno = @roomno and status = 'I')
begin  --  �õ���
   	--select @msg = folio from rm_ooo where roomno=@roomno and status = 'I'

	--  ���,ȡ�� ��Ӧ�Ĺ��Ų�һ�� !
	if @gmode = 'X'
		update rm_ooo set status=@gmode, empno4=@empno, date4=getdate(), logmark = logmark + 1
			where roomno=@roomno and status = 'I' and  folio=@sfolio
	else
		update rm_ooo set status=@gmode, empno3=@empno, date3=getdate(), logmark = logmark + 1
			where roomno=@roomno and status = 'I' and folio=@sfolio

	if @@error <> 0
		select @ret = 1, @msg = '���ݸ���ʧ�� !'
   else
      begin
      select @begin=min(dbegin) from rm_ooo where roomno=@roomno and status='I'
      if @begin<>'' and @begin is not null
        	begin
         select @end=dend,@sta=sta from rm_ooo where roomno=@roomno and status='I' and dbegin=@begin
         exec p_gds_update_room_status @roomno, 'L', @sta, @begin, @end, @empno, 'R', @msg output
         end
      end
end

gds:
if @ret <> 0
	rollback tran p_gds_house_rm_ooo_del1
commit tran

select @ret, @msg
return @ret
;