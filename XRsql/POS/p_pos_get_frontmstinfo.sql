IF OBJECT_ID('p_pos_get_frontmstinfo') IS NOT NULL
    DROP PROCEDURE p_pos_get_frontmstinfo
;
create proc p_pos_get_frontmstinfo
	@accnt 		char(10)
as
-----------------------------------------------------------------------------------------------
--
--		����ϵͳȡǰ̨�ʻ���Ϣ������, ״̬, �����, �������, ��Ӧ����ģʽ.      Ver X5.
--
-----------------------------------------------------------------------------------------------
declare
	@mode			char(3)


-- תǰ̨Ҫ�����Ƿ���Э��, �ٸ���Э���޸�ģʽ
if substring(@accnt, 1, 2) <> 'AR'  	--  �ҷ�����˵�ģʽ
	begin
	select @mode=b.code2  from master a, guest b where a.haccnt = b.no and a.accnt = @accnt
	if rtrim(@mode) is null -- �ҷ��䵥λ��ģʽ
		select @mode = b.code2 from master a, guest b where a.cusno = b.no  and a.accnt = @accnt
	if rtrim(@mode) is null -- �ҷ���agent��ģʽ
		select @mode = b.code2 from master a, guest b where a.agent = b.no  and a.accnt = @accnt
	if rtrim(@mode) is null -- �ҷ���source��ģʽ
		select  @mode = b.code2 from master a, guest b where  a.source = b.no and a.accnt = @accnt
	end
else
	begin 	--  ��AR�ʵ�ģʽ
	if exists(select 1 from sysoption where catalog = 'hotel' and (item ='lic_buy.1' or item ='lic_buy.2') and charindex('nar',value )>0)
		select @mode = b.code2 from ar_master a, guest b where a.accnt = rtrim(@accnt) and a.haccnt = b.no
	else
		select @mode = b.code2 from master a, guest b where a.accnt = rtrim(@accnt) and a.haccnt = b.no
	end

if exists(select 1 from sysoption where catalog = 'hotel' and (item ='lic_buy.1' or item ='lic_buy.2') and charindex('nar',value )>0)
	and @accnt like 'AR%'
	select '',rtrim(b.name) + '/' + rtrim(b.name2), a.sta,balance = a.charge+a.charge0-a.credit-a.credit0,a.accredit,@mode from ar_master a, guest b where a.accnt = @accnt and a.haccnt = b.no
else
	select a.roomno,rtrim(b.name) + '/' + rtrim(b.name2), a.sta,balance =a.charge-a.credit,a.accredit,@mode from master a, guest b where a.accnt = @accnt and a.haccnt = b.no

return 0
;
