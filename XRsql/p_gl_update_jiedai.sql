if exists(select 1 from sysobjects where name = 'p_gl_update_jiedai' and type = 'P')
	drop proc p_gl_update_jiedai;
create proc p_gl_update_jiedai
	@bdate_b 	datetime,
	@bdate_e		datetime
as 
	declare
		@bdate	datetime,
	@isfstday		char(1) , 
	@isyfstday		char(1)

-- 重算底表

select @bdate = @bdate_b
while datediff(day,@bdate,@bdate_e ) >= 0
	begin


		exec p_hry_audit_fstday @bdate, @isfstday out, @isyfstday out
		if @isfstday = 'T'
			begin
			update yjierep set month01 = day01,month02 = day02,month03 = day03,
				month04 = day04,month05 = day05,month06 = day06,month07 = day07,
				month08 = day08,month09 = day09,month99 = day99 where date = @bdate

			update ydairep set credit01m = credit01,credit02m = credit02,credit03m = credit03,
			credit04m = credit04,credit05m = credit05,credit06m = credit06,credit07m = credit07,
			sumcrem = sumcre where date = @bdate



			end

		else

		begin

		update yjierep set month01 = day01 + (select a.month01 from yjierep a 
			where yjierep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where yjierep.date = @bdate
		update yjierep set month02 = day02 + (select a.month02 from yjierep a 
			where yjierep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where yjierep.date = @bdate
		update yjierep set month03 = day03 + (select a.month03 from yjierep a 
			where yjierep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where yjierep.date = @bdate
		update yjierep set month04 = day04 + (select a.month04 from yjierep a 
			where yjierep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where yjierep.date = @bdate
		update yjierep set month05 = day05 + (select a.month05 from yjierep a 
			where yjierep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where yjierep.date = @bdate
		update yjierep set month06 = day06 + (select a.month06 from yjierep a 
			where yjierep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where yjierep.date = @bdate
		update yjierep set month07 = day07 + (select a.month07 from yjierep a 
			where yjierep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where yjierep.date = @bdate
		update yjierep set month08 = day08 + (select a.month08 from yjierep a 
			where yjierep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where yjierep.date = @bdate
		update yjierep set month09 = day09 + (select a.month09 from yjierep a 
			where yjierep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where yjierep.date = @bdate
		update yjierep set month99 = day99 + (select a.month99 from yjierep a 
			where yjierep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where yjierep.date = @bdate

		update ydairep set credit01m = credit01 + (select a.credit01m from ydairep a 
			where ydairep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where ydairep.date = @bdate
		update ydairep set credit02m = credit02 + (select a.credit02m from ydairep a 
			where ydairep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where ydairep.date = @bdate
		update ydairep set credit03m = credit03 + (select a.credit03m from ydairep a 
			where ydairep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where ydairep.date = @bdate
		update ydairep set credit04m = credit04 + (select a.credit04m from ydairep a 
			where ydairep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where ydairep.date = @bdate
		update ydairep set credit05m = credit05 + (select a.credit05m from ydairep a 
			where ydairep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where ydairep.date = @bdate
		update ydairep set credit06m = credit06 + (select a.credit06m from ydairep a 
			where ydairep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where ydairep.date = @bdate
		update ydairep set credit07m = credit07 + (select a.credit07m from ydairep a 
			where ydairep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where ydairep.date = @bdate
		update ydairep set sumcrem = sumcre + (select a.sumcrem from ydairep a 
			where ydairep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where ydairep.date = @bdate

		update ydairep set last_bl=(select a.till_bl from ydairep a 
			where ydairep.class = a.class and a.date = dateadd(day,-1,@bdate))
				where ydairep.date = @bdate
		update ydairep set till_bl=last_bl+debit-credit
				where ydairep.date = @bdate

		end
		select @bdate = dateadd(day,1,@bdate)
	end


return 0

;


