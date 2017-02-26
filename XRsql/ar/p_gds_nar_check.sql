if exists (select * from sysobjects where name ='p_gds_nar_check' and type ='P')
	drop proc p_gds_nar_check;
create proc p_gds_nar_check
	@accnt			varchar(10) = '' 
as
------------------------------------------------------
-- 检查 新AR 帐务  
-- 
--   发现余额不一致 simon 2008.3.12    
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
	-- 1. 余额对照 
	delete #numb
	delete #tmp 
	insert #numb select distinct ar_pnumber from ar_account where ar_accnt=@maccnt and ar_pnumber<>0 
	-- 计算 ar_account 余额 
	insert #tmp(m1) select isnull((select sum(charge-credit) 
		from ar_account 
			where ar_accnt=@maccnt and ar_subtotal='F' 
				and ar_number not in (select numb from #numb)),0) 
	-- 计算 ar_detail 余额 
	insert #tmp(m1) select isnull((select sum(charge+charge0-charge9 - (credit+credit0-credit9))  
		from ar_detail where accnt=@maccnt)*-1, 0) 
	select @amount = sum(m1) from #tmp 
	if @amount <> 0 
	begin
		insert #error select @maccnt, '余额对照错误' 
		fetch c_arlist into @maccnt 
		break 
	end 
	
--	--查ar_detail, ar_account的一致：
--	--1.检查 detail 在 account 中的明细是否正确 
--	select a.accnt, a.number, 
--			'ERR-C'=(a.charge+a.charge0) - (select sum(b.charge) from ar_account b where b.ar_accnt=a.accnt and b.ar_inumber=a.number and (b.ar_subtotal='F') ),
--			'ERR-D'=(a.credit+a.credit0) - (select sum(c.credit) from ar_account c where c.ar_accnt=a.accnt and c.ar_inumber=a.number and (c.ar_subtotal='F') ),
--			'ERR-CC'=(a.charge9) - (select sum(d.charge9) from ar_account d where d.ar_accnt=a.accnt and d.ar_inumber=a.number and (d.ar_subtotal='F') ),
--			'ERR-DD'=(a.credit9) - (select sum(e.credit9) from ar_account e where e.ar_accnt=a.accnt and e.ar_inumber=a.number and (e.ar_subtotal='F') )
--		from ar_detail a where a.accnt = @maccnt
--	
--	--2.检查 account 在 detail 中是否没有对应的记录  
--	select * from ar_account a
--		where a.ar_accnt=@maccnt 
--			and a.ar_inumber not in (select b.number from ar_detail b where b.accnt=a.ar_accnt)
--	
--	--查 核销借贷 
--	select billno, c_accnt, d_accnt, sum(amount) from ar_apply where c_accnt=@maccnt or d_accnt=@maccnt group by billno, c_accnt, d_accnt
--	--* update #tmp set amount= -1 * amount where rtrim(c_accnt) is null（假定上面结果插入#tmp）
--	--* select sum(amount) from #tmp    -- 不等于0表示有问题  
--	
--	--查 核销借方明细：apply->detail/account 不一定错，
--	--因detail/account 里的核销可能包含多次 
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
--	--查 核销贷方明细：apply->detail/account  不一定错，
--	--因detail/account 里的核销可能包含多次 
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
--	--查 detail 核销明细：detail->apply一定错，因detail里的核销一定能在apply中找到
--	select a.accnt, a.number, 
--		'error-d' = a.charge9 - (select sum(b.amount) from ar_apply b where b.d_accnt=a.accnt and b.d_number=a.number), 
--		'error-c' = a.credit9 - (select sum(c.amount) from ar_apply c where c.c_accnt=a.accnt and c.c_number=a.number) 
--		from ar_detail a where a.accnt=@maccnt
--	
--	--查 account 核销明细：account->apply一定错，因account里的核销一定能在apply中找到 
--	select a.ar_number, a.ar_inumber,
--			'error-d' = a.charge9 - (select sum(b.amount) from ar_apply b where a.ar_accnt=b.d_accnt and a.ar_number=b.d_inumber),
--			'error-c' = a.credit9 - (select sum(c.amount) from ar_apply c where a.ar_accnt=c.c_accnt and a.ar_number=c.c_inumber),
--			a.ar_tag,a.ar_subtotal
--		from ar_account a where a.ar_accnt=@maccnt 
--			order by a.ar_number
--	
--	
--	--查 detail 遗漏核销记录的帐次 
--	select * from ar_detail where accnt=@maccnt and charge9<>0 
--		and number not in (select d_number from ar_apply where d_accnt=@maccnt) 
--	select * from ar_detail where accnt=@maccnt and credit9<>0 
--		and number not in (select c_number from ar_apply where c_accnt=@maccnt) 
--	
--	--查 account 遗漏核销记录的帐次 (省略)


	fetch c_arlist into @maccnt 
end 
close c_arlist
deallocate cursor c_arlist 

-- output error list 
select * from #error 

return 0;

