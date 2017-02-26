if exists (select * from sysobjects where name ='p_gds_nar_check' and type ='P')
	drop proc p_gds_nar_check;
create proc p_gds_nar_check
	@accnt			varchar(10) = '' 
as
------------------------------------------------------
-- ��� ��AR ����  
-- 
--   ������һ�� simon 2008.3.12    
------------------------------------------------------
declare
	@maccnt			char(10),
	@amount			money 

if rtrim(@accnt) is null 
	select @accnt = '%'

--
create table #numb
(
	numb		int			default 0 null,
)
create table #error
(
	accnt		char(10)			default '' null,
	msg		varchar(60)		default '' null
)
create table #tmp 
(
	c1			char(10)		default '' null,
	c2			char(10)		default '' null,
	c3			char(10)		default '' null,
	m1			money			default 0 null,
	m2			money			default 0 null,
	m3			money			default 0 null,
	m4			money			default 0 null
)

declare c_arlist cursor for select accnt from ar_master where accnt like @accnt and sta='I'
open c_arlist 
fetch c_arlist into @maccnt 
while @@sqlstatus = 0 
begin 
	-- 1. ������ 
	delete #numb
	delete #tmp 
	insert #numb select distinct ar_pnumber from ar_account where ar_accnt=@maccnt and ar_pnumber<>0 
	-- ���� ar_account ��� 
	insert #tmp(m1) select isnull((select sum(charge-credit) 
		from ar_account 
			where ar_accnt=@maccnt and ar_subtotal='F' 
				and ar_number not in (select numb from #numb)),0) 
	-- ���� ar_detail ��� 
	insert #tmp(m1) select isnull((select sum(charge+charge0-charge9 - (credit+credit0-credit9))  
		from ar_detail where accnt=@maccnt)*-1, 0) 
	select @amount = sum(m1) from #tmp 
	if @amount <> 0 
	begin
		insert #error select @maccnt, '�����մ���' 
		fetch c_arlist into @maccnt 
		break 
	end 
	
--	--��ar_detail, ar_account��һ�£�
--	--1.��� detail �� account �е���ϸ�Ƿ���ȷ 
--	select a.accnt, a.number, 
--			'ERR-C'=(a.charge+a.charge0) - (select sum(b.charge) from ar_account b where b.ar_accnt=a.accnt and b.ar_inumber=a.number and (b.ar_subtotal='F') ),
--			'ERR-D'=(a.credit+a.credit0) - (select sum(c.credit) from ar_account c where c.ar_accnt=a.accnt and c.ar_inumber=a.number and (c.ar_subtotal='F') ),
--			'ERR-CC'=(a.charge9) - (select sum(d.charge9) from ar_account d where d.ar_accnt=a.accnt and d.ar_inumber=a.number and (d.ar_subtotal='F') ),
--			'ERR-DD'=(a.credit9) - (select sum(e.credit9) from ar_account e where e.ar_accnt=a.accnt and e.ar_inumber=a.number and (e.ar_subtotal='F') )
--		from ar_detail a where a.accnt = @maccnt
--	
--	--2.��� account �� detail ���Ƿ�û�ж�Ӧ�ļ�¼  
--	select * from ar_account a
--		where a.ar_accnt=@maccnt 
--			and a.ar_inumber not in (select b.number from ar_detail b where b.accnt=a.ar_accnt)
--	
--	--�� ������� 
--	select billno, c_accnt, d_accnt, sum(amount) from ar_apply where c_accnt=@maccnt or d_accnt=@maccnt group by billno, c_accnt, d_accnt
--	--* update #tmp set amount= -1 * amount where rtrim(c_accnt) is null���ٶ�����������#tmp��
--	--* select sum(amount) from #tmp    -- ������0��ʾ������  
--	
--	--�� �����跽��ϸ��apply->detail/account ��һ����
--	--��detail/account ��ĺ������ܰ������ 
--	select a.d_accnt,a.d_number,'diff' = sum(a.amount) - 
--		(select sum(b.charge9) from ar_detail b where a.d_accnt=b.accnt and a.d_number=b.number) 
--		from ar_apply a where a.d_accnt=@maccnt and a.d_number<>0 
--			group by a.d_accnt, a.d_number 
--	
--	select a.d_accnt,a.d_number,a.d_inumber,'diff' = sum(a.amount) - 
--		(select sum(b.charge9) from ar_account b where a.d_accnt=b.ar_accnt and a.d_inumber=b.ar_number) 
--		from ar_apply a where a.d_accnt=@maccnt and a.d_inumber<>0 
--			group by a.d_accnt, a.d_number, a.d_inumber  
--	
--	--�� ����������ϸ��apply->detail/account  ��һ����
--	--��detail/account ��ĺ������ܰ������ 
--	select a.c_accnt,a.c_number,'diff' = sum(a.amount) - 
--		(select sum(b.credit9) from ar_detail b where a.c_accnt=b.accnt and a.c_number=b.number) 
--		from ar_apply a where a.c_accnt=@maccnt and a.c_number<>0 
--			group by a.c_accnt, a.c_number 
--	
--	select a.c_accnt,a.c_number,a.c_inumber,'diff' = sum(a.amount) - 
--		(select sum(b.credit9) from ar_account b where a.c_accnt=b.ar_accnt and a.c_inumber=b.ar_number) 
--		from ar_apply a where a.c_accnt=@maccnt and a.c_number<>0 
--			group by a.c_accnt, a.c_number,a.c_inumber 
--	
--	--�� detail ������ϸ��detail->applyһ������detail��ĺ���һ������apply���ҵ�
--	select a.accnt, a.number, 
--		'error-d' = a.charge9 - (select sum(b.amount) from ar_apply b where b.d_accnt=a.accnt and b.d_number=a.number), 
--		'error-c' = a.credit9 - (select sum(c.amount) from ar_apply c where c.c_accnt=a.accnt and c.c_number=a.number) 
--		from ar_detail a where a.accnt=@maccnt
--	
--	--�� account ������ϸ��account->applyһ������account��ĺ���һ������apply���ҵ� 
--	select a.ar_number, a.ar_inumber,
--			'error-d' = a.charge9 - (select sum(b.amount) from ar_apply b where a.ar_accnt=b.d_accnt and a.ar_number=b.d_inumber),
--			'error-c' = a.credit9 - (select sum(c.amount) from ar_apply c where a.ar_accnt=c.c_accnt and a.ar_number=c.c_inumber),
--			a.ar_tag,a.ar_subtotal
--		from ar_account a where a.ar_accnt=@maccnt 
--			order by a.ar_number
--	
--	
--	--�� detail ��©������¼���ʴ� 
--	select * from ar_detail where accnt=@maccnt and charge9<>0 
--		and number not in (select d_number from ar_apply where d_accnt=@maccnt) 
--	select * from ar_detail where accnt=@maccnt and credit9<>0 
--		and number not in (select c_number from ar_apply where c_accnt=@maccnt) 
--	
--	--�� account ��©������¼���ʴ� (ʡ��)


	fetch c_arlist into @maccnt 
end 
close c_arlist
deallocate cursor c_arlist 

-- output error list 
select * from #error 

return 0;

