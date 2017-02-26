
IF OBJECT_ID('p_gds_sc_master_haccnt_create') IS NOT NULL
    DROP PROCEDURE p_gds_sc_master_haccnt_create
;
create proc p_gds_sc_master_haccnt_create
   @accnt  	char(10),
   @empno  	char(10),
	@retmode	char(1) = 'S',
	@ret		int				output,
	@msg		varchar(60)		output
as

--------------------------------------------------------------------
--	���ݶ�����Ϣ, �Զ��������������嵵��  
--------------------------------------------------------------------
declare
   @sta       	char(1),
	@bdate		datetime,
	@haccnt		char(7)

select @ret = 0,@msg = ""
select @bdate = bdate1 from sysdata

begin tran
save  tran p_gds_sc_haccnt_create_s1

select @sta=sta, @haccnt=haccnt from sc_master where accnt=@accnt
if @@rowcount = 0 
begin
	select @ret=1, @msg='��ǰ%1������^�˻�'
	goto gout 
end
if @haccnt<>''
begin
	select @ret=0, @msg='�Ѿ�����%1^���嵵��'
	goto gout 
end

update sc_master set sta = sta where accnt = @accnt

-- ע�⼸����Ӧ��ϵ 
exec p_GetAccnt1 'HIS', @haccnt output
insert guest(no,sta,name,name2,class,type,src,market,keep,saleid,crtby,crttime,cby,changed,country,nation)
SELECT @haccnt,'I',name,name2,'G','N',src,market,'F',saleid,@empno,getdate(),@empno,getdate(),'CN','CN'
	FROM sc_master where accnt=@accnt
if @@rowcount = 1
begin
	update sc_master set haccnt=@haccnt,cby=@empno, changed=getdate(), logmark=logmark+1 where accnt=@accnt
	if @@rowcount = 0
		select @ret=1, @msg='����%1ʧ��^����'
	else
		exec p_gds_guest_name4 @haccnt  
end
else
begin
	select @ret=1, @msg='����%1ʧ��^����'
end

-- 
gout:
if @ret <> 0
   rollback tran p_gds_sc_haccnt_create_s1
commit tran

if @retmode = 'S'
	select @ret,@msg
return @ret
;

