if exists (select * from sysobjects where name ='p_gds_guest_nts_check' and type ='P')
	drop proc p_gds_guest_nts_check;
create proc p_gds_guest_nts_check
	@pc_id				char(4),
	@master				char(10),			-- 同住标记 或者房号 
	@guest				char(10), 			-- 各种档案，或者销售员 
	@sta					char(1),				-- 状态 I, N, X 
	@nt					money,				-- 消费记录本来的房晚
	@nt_set				money output  		-- 输出需要计算的房晚
as
-----------------------------------------------------------
-- 同住房晚计算核对, 借用 accnt_set 作为判断临时表 
-- 把要计算的房晚存起来，如果后续房晚更大，要继续计算差额 
-----------------------------------------------------------

-- 
declare	@roomno  		char(5)
select @roomno=isnull(substring(@master,1,5), '') 
select @nt_set = 0
if @nt = 0 or @nt is null 
	return 

-- 考虑到 accnt_set 的索引问题， sta 放到 subaccnt 列 
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
