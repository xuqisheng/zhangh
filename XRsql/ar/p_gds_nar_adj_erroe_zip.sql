if exists(select * from sysobjects where name = 'p_gds_nar_adj_erroe_zip' and type='P')
	drop proc p_gds_nar_adj_erroe_zip;
create proc p_gds_nar_adj_erroe_zip
	@accnt					char(10)
as

-- Ñ°ÕÒ´íÎóµÄÑ¹Ëõ 
create table #error(
	number		int,
	amount		money
)
insert #error 
	select a.number,a.charge+a.charge0+a.charge1-(select sum(b.charge+b.charge0+b.charge1) from har_detail b where a.accnt=b.accnt and b.pnumber=a.number)
		from ar_detail a where a.accnt=@accnt and a.tag='Z' 
insert #error 
	select a.number,a.credit+a.credit0+a.credit1-(select sum(b.credit+b.credit0+b.credit1) from har_detail b where a.accnt=b.accnt and b.pnumber=a.number)
		from ar_detail a where a.accnt=@accnt and a.tag='Z' 

select * from #error 

-- ³·ÏúÑ¹Ëõ 
declare @number int 
declare c_adjust cursor for select distinct number from #error where amount<>0 
open c_adjust 
fetch c_adjust into @number
while @@sqlstatus = 0 
begin 
	exec p_gl_ar_cancel_compress @accnt, @number, 'FOX', '1' 
	fetch c_adjust into @number
end 
close c_adjust
deallocate cursor c_adjust 

return 0;
//
//
//exec p_gds_nar_adj_erroe_zip 'AR00000'; 

exec p_gds_nar_adj_erroe_zip 'AR00002'; 
exec p_gds_nar_reb_from_apply 'AR00002'; 
