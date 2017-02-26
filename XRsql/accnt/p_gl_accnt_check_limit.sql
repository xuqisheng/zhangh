IF OBJECT_ID('p_gl_accnt_check_limit') IS NOT NULL
    DROP PROCEDURE p_gl_accnt_check_limit
;
create proc p_gl_accnt_check_limit
	@accnt			char(10),				--�ʺ�
	@charge			money,					--�跽
	@credit			money,					--����
   @msg				varchar(60) out		--������Ϣ
as
declare
	@martag2			char(1),
	@mcharge			money,					--�跽
	@mcredit			money,					--����
	@maccredit		money,					--�跽
	@mlimit			money,					--����
	@ret				integer

-- Caution : - gds
--		1. @maccredit = @mlimit ������ͬ�ˣ������ʱ�����ظ�
--		2. �������ֻ�и�����Բ��ж��ˡ�

select @ret = 0, @msg = ''
if @accnt like 'A%' and @charge > 0
	begin

	-- accredit
	declare	@accredit	money
	select @accredit = isnull((select sum(b.amount) from master a, accredit b, pccode c
											where a.accnt=@accnt and a.accnt=b.cardno and b.tag='0' and b.pccode=c.pccode and c.deptno2='TOR'
									), 0)

	-- 
	select @martag2 = artag2, @mcharge = charge, @mcredit = credit, @maccredit = accredit, @mlimit = limit from master where accnt = @accnt
	if @martag2 = '2' and @mcharge - @mcredit + @charge - @credit + @accredit > @maccredit
	select @ret = 1, @msg = '��%1�����������޶�, ���������ϵ^' + @accnt
	end

---- GDS(SCJJ 2000/11/12)
--if @accnt not like 'AR%'
--	begin
--	if exists(select 1 from armst where accnt = @accnt and artag2 = 'L')
--		select @ret = 1, @msg = 'IC���ʺš�%1�����ʧ�Ѷ���, û�ոÿ�^' + @accnt
--	else if exists(select 1 from armst where accnt = @accnt and rmb_db - depr_cr - addrmb + @charge - @credit > limit)
--		select @ret = 1, @msg = '��%1�����������޶�, ���������ϵ^' + @accnt
--	end
---- GDS(SCJJ 2000/11/12)

return @ret
;
