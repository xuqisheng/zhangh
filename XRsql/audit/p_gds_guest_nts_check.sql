if exists (select * from sysobjects where name ='p_gds_guest_nts_check' and type ='P')
	drop proc p_gds_guest_nts_check;
create proc p_gds_guest_nts_check
	@pc_id				char(4),
	@master				char(10),			-- ͬס��� ���߷��� 
	@guest				char(10), 			-- ���ֵ�������������Ա 
	@sta					char(1),				-- ״̬ I, N, X 
	@nt					money,				-- ���Ѽ�¼�����ķ���
	@nt_set				money output  		-- �����Ҫ����ķ���
as
-----------------------------------------------------------
-- ͬס�������˶�, ���� accnt_set ��Ϊ�ж���ʱ�� 
-- ��Ҫ����ķ������������������������Ҫ���������� 
-----------------------------------------------------------

-- 
declare	@roomno  		char(5)
select @roomno=isnull(substring(@master,1,5), '') 
select @nt_set = 0
if @nt = 0 or @nt is null 
	return 

-- ���ǵ� accnt_set ���������⣬ sta �ŵ� subaccnt �� 
declare	@sta_num			int
if @sta='I'
	select @sta_num = 1
else if @sta='N'
	select @sta_num = 2
else if @sta='X'
	select @sta_num = 3
else 
	select @sta_num = 4

-- 
select @nt_set=isnull((select charge from accnt_set where pc_id=@pc_id and mdi_id=666 and accnt=@guest and roomno=@roomno and subaccnt=@sta_num), -1)
if @nt_set = -1 
	begin
	select @nt_set = @nt
	insert accnt_set(pc_id,mdi_id,accnt,haccnt,charge,sta,roomno,subaccnt,name,credit,tree_level,tree_children,tree_picture,tag,csta) 
		values(@pc_id,666,@guest, '', @nt_set,'',@roomno,@sta_num,'nts_check',0,0,'','','',0) 
	end 
else
	begin
	select @nt_set = @nt - @nt_set 
	if @nt_set > 0 
		update accnt_set set charge=@nt where pc_id=@pc_id and mdi_id=666 and accnt=@guest and roomno=@roomno and subaccnt=@sta_num
	end 

select @nt = @nt_set 

return;
