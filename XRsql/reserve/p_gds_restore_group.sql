if exists(select * from sysobjects where name = "p_gds_restore_group")
   drop proc p_gds_restore_group
;
create  proc p_gds_restore_group
   @grpaccnt char(10),
   @narr     datetime,       -- �ָ������������µĵ���
   @ndep     datetime,       -- �ָ������������µ�����
   @empno    char(10),
	@retmode		char(1),
	@ret			int	output,
	@msg			varchar(60) output
as
-- ����/����  Ԥ���ָ�

declare
   @sta     char(1)

select @ret=0, @msg=''

begin tran
save  tran p_gds_restore_group_s1

update master set sta = sta where accnt = @grpaccnt
select @sta = sta from master where accnt = @grpaccnt and class in ('G', 'M')
if @@rowcount = 0
begin
   select @ret = 1,@msg = "��������%1������^"+@grpaccnt
	goto gout
end

if charindex(@sta,'I') > 0
   select @ret = 1,@msg = "��������%1�Ѿ��Ǽ�,����ָ�^"+@grpaccnt
else if charindex(@sta,'RCG') > 0
   select @ret = 1,@msg = "��������%1�Ѿ�����ЧԤ��״̬,����ָ�^"+@grpaccnt
else if charindex(@sta,'XNL') = 0
   select @ret = 1,@msg = "��������%1����ȡ��Ԥ������,���ָܻ�^"+@grpaccnt
if @ret = 0
begin
   update master set sta = 'R',arr = @narr,dep=@ndep,logmark=logmark+1,cby=@empno,changed = getdate() where accnt = @grpaccnt

	-- �����ԭ��ȡ����Ԥ����Դ����ʱ�������Զ�׷�� 
	-- rsvsrc_cxl 

end 

gout:
if @ret <> 0
	rollback tran p_gds_restore_group_s1
commit tran
if @retmode='S'
	select @ret,@msg
return @ret
;
