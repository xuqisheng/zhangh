
drop  proc p_cyj_bar_audit_exec;
create proc p_cyj_bar_audit_exec
	@ret			integer		output,
	@msg			char(80)		output
as
--------------------------------------------------------------------------------
--
--ÿ�ս�ת��û���½����
--
--------------------------------------------------------------------------------
declare	
	@bdate		datetime,
	@truedate	datetime,
	@count	int


select @bdate = bdate1 from sysdata				--����ϵͳʱ��

select @truedate = convert(datetime,convert(char(10),truedate,111)) from pos_st_sysdata			--��̨ϵͳʱ��,ȡ��ʱ��

-- �����̨�Ѿ���ת��ͨ��ϵͳ����һ�������ж��Ƿ��ѽ�ת
if @bdate = @truedate
	return

select @count = count(1) from pos_sale
insert pos_hsale select * from pos_sale								--���ʧ�ܸ���ô����pos_sale�еڶ��������ϻ���������
if @@rowcount <> @count
begin 
	select @msg = '������������ת����ʷʧ�ܣ����飡'
	return
end
else
	delete from pos_sale

begin tran 
save  tran t_bar_audit
select @ret = 0, @msg = ''

exec p_fhb_docu_dayturn @pc_id='0.00',@vdate=@truedate,@ret=@ret out,@msg=@msg out

if @ret <> 1
	rollback tran         --��ת�����ع����ڶ������ֹ���ת

commit tran



select @ret =0,@msg =''
return @ret
;
