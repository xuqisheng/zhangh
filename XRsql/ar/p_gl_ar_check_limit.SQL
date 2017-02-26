IF OBJECT_ID('p_gl_ar_check_limit') IS NOT NULL
    DROP PROCEDURE p_gl_ar_check_limit
;
create proc p_gl_ar_check_limit
	@accnt			char(10),
	@charge			money,
	@credit			money,
   @msg				varchar(60) out
as
declare
	@martag2			char(1),
	@mcharge			money,
	@mcredit			money,
	@maccredit		money,
	@mlimit			money,
	@ret				integer

select @ret = 0, @msg = ''
if @accnt like 'A%'
	begin
	-- accredit
	declare	@accredit	money
	select @accredit = isnull((select sum(b.amount) from ar_master a, accredit b, pccode c
											where a.accnt=@accnt and a.accnt=b.cardno and b.tag='0' and b.pccode=c.pccode and c.deptno2='TOR'
									), 0)

	-- 
	select @martag2 = artag2, @mcharge = charge, @mcredit = credit, @maccredit = accredit, @mlimit = limit from ar_master where accnt = @accnt
	if @martag2 = '2' and @mcharge - @mcredit + @charge - @credit + @accredit > @maccredit
	select @ret = 1, @msg = '『%1』超过消费限额, 请与财务联系^'  + @accnt
	end

return @ret
;
