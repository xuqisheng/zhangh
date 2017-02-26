// ------------------------------------------------------------------------
//	 CRS 统计报表
// ------------------------------------------------------------------------ 
if exists (select 1 from sysobjects where name = 'p_crs_statistic_report'  and type = 'P')
	drop procedure p_crs_statistic_report;

create  procedure p_crs_statistic_report  
	@rpttime	char(7) ,   -- FORMAT: yyyy/mm 
	@rptmode char(1)     -- A:agent C:cousno S:source R:src M:market N:channel H:hotel
                        -- E:employee Y:!RSVN  X:RSVN
as
begin 

	create table #rpt
	(
		id 			char(10)		null,
		no 			char(7)		null,
		code 			char(3)		null,
		gstno			int			null,
		rmnum			int			null,
		i_days      int			null,
		tl          money			null 
	)

	if @rptmode = 'A'
	begin
		insert into #rpt (no,gstno,rmnum,i_days,tl) 
			select a.no,sum(a.gstno),sum(a.rmnum),sum(a.i_days),sum(a.tl) 
			from guest_income a, vhmaster b 
			where a.no = b.agent and a.accnt = b.accnt0 and 
				convert(char(4),datepart(yy,b.cotime))+'/'+ substring(convert(char(3),datepart(mm,b.cotime) + 100),2,2)  = @rpttime 	
			group by a.no 
					
		select a.no,b.name,b.name2,a.gstno,a.rmnum,a.rmnum*a.i_days,a.tl,a.tl/(a.rmnum*a.i_days)  
			from #rpt a,guest b
			where a.no = b.no 
		return 0
	end 

	if @rptmode = 'C'
	begin
		insert into #rpt (no,gstno,rmnum,i_days,tl) 
			select a.no,sum(a.gstno),sum(a.rmnum),sum(a.i_days),sum(a.tl) 
			from guest_income a, vhmaster b 
			where a.no = b.cusno and a.accnt = b.accnt0 and 
				convert(char(4),datepart(yy,b.cotime))+'/'+ substring(convert(char(3),datepart(mm,b.cotime) + 100),2,2)  = @rpttime 	
			group by a.no 
	
		select a.no,b.name,b.name2,a.gstno,a.rmnum,a.rmnum*a.i_days,a.tl,a.tl/(a.rmnum*a.i_days)
			from #rpt a,guest b
			where a.no = b.no 
		return 0
	end 

	if @rptmode = 'S'
	begin
		insert into #rpt (no,gstno,rmnum,i_days,tl) 
			select a.no,sum(a.gstno),sum(a.rmnum),sum(a.i_days),sum(a.tl) 
			from guest_income a, vhmaster b 
			where a.no = b.source and a.accnt = b.accnt0 and 
				convert(char(4),datepart(yy,b.cotime))+'/'+ substring(convert(char(3),datepart(mm,b.cotime) + 100),2,2)  = @rpttime 	
			group by a.no 
	
		select a.no,b.name,b.name2,a.gstno,a.rmnum,a.rmnum*a.i_days,a.tl,a.tl/(a.rmnum*a.i_days)
			from #rpt a,guest b
			where a.no = b.no 
		return 0
	end 

	if @rptmode = 'R'
	begin
		insert into #rpt (code,gstno,rmnum,i_days,tl) 
			select b.src,sum(a.gstno),sum(a.rmnum),sum(a.i_days),sum(a.tl) 
			from guest_income a, vhmaster b 
			where a.accnt = b.accnt0 and 
				convert(char(4),datepart(yy,b.cotime))+'/'+ substring(convert(char(3),datepart(mm,b.cotime) + 100),2,2)  = @rpttime 	
			group by b.src 
	
		select a.code,b.descript,b.descript1,a.gstno,a.rmnum,a.rmnum*a.i_days,a.tl,a.tl/(a.rmnum*a.i_days)
			from #rpt a,srccode b
			where a.code = b.code 
		return 0
	end 

	if @rptmode = 'M'
	begin
		insert into #rpt (code,gstno,rmnum,i_days,tl) 
			select b.market,sum(a.gstno),sum(a.rmnum),sum(a.i_days),sum(a.tl) 
			from guest_income a, vhmaster b 
			where a.accnt = b.accnt0 and 
				convert(char(4),datepart(yy,b.cotime))+'/'+ substring(convert(char(3),datepart(mm,b.cotime) + 100),2,2)  = @rpttime 	
			group by b.market 
	
		select a.code,b.descript,b.descript1,a.gstno,a.rmnum,a.rmnum*a.i_days,a.tl,a.tl/(a.rmnum*a.i_days)
			from #rpt a,mktcode b
			where a.code = b.code 
		return 0 
	end 

	if @rptmode = 'N'
	begin
		insert into #rpt (code,gstno,rmnum,i_days,tl) 
			select b.channel,sum(a.gstno),sum(a.rmnum),sum(a.i_days),sum(a.tl) 
			from guest_income a, vhmaster b 
			where a.accnt = b.accnt0 and 
				convert(char(4),datepart(yy,b.cotime))+'/'+ substring(convert(char(3),datepart(mm,b.cotime) + 100),2,2)  = @rpttime 	
			group by b.channel 
	
		select a.code,b.descript,b.descript1,a.gstno,a.rmnum,a.rmnum*a.i_days,a.tl,a.tl/(a.rmnum*a.i_days)
			from #rpt a,basecode b
			where a.code = b.code and b.cat='channel'
		return 0
	end 

	if @rptmode = 'H'
	begin
		insert into #rpt (id,gstno,rmnum,i_days,tl) 
			select b.hotelid,sum(a.gstno),sum(a.rmnum),sum(a.i_days),sum(a.tl) 
			from guest_income a, vhmaster b 
			where a.accnt = b.accnt0 and 
				convert(char(4),datepart(yy,b.cotime))+'/'+ substring(convert(char(3),datepart(mm,b.cotime) + 100),2,2)  = @rpttime 	
			group by b.hotelid 
	
		select a.id,b.descript,b.descript1,a.gstno,a.rmnum,a.rmnum*a.i_days,a.tl,a.tl/(a.rmnum*a.i_days)
			from #rpt a,hotelinfo b
			where a.id = b.hotelid  
		return 0
	end 

	if @rptmode = 'E'
	begin
		insert into #rpt (code,gstno,rmnum,i_days,tl) 
			select b.resby,sum(a.gstno),sum(a.rmnum),sum(a.i_days),sum(a.tl) 
			from guest_income a, vhmaster b 
			where a.accnt = b.accnt0 and 
				convert(char(4),datepart(yy,b.cotime))+'/'+ substring(convert(char(3),datepart(mm,b.cotime) + 100),2,2)  = @rpttime 	
			group by b.resby 
	
		select a.code,b.name,a.gstno,a.rmnum,a.rmnum*a.i_days,a.tl,a.tl/(a.rmnum*a.i_days)
			from #rpt a,sys_empno b
			where a.code = b.empno  
		return 0
	end 


	if @rptmode = 'Y'
	begin
		insert into #rpt (no,gstno,rmnum,i_days,tl) 
			select a.no,sum(a.gstno),sum(a.rmnum),sum(a.i_days),sum(a.tl) 
			from guest_income a, vhmaster b ,guest c 
			where a.no = b.cusno and a.accnt = b.accnt0 and b.cusno = c.no and c.name not like 'RSVN%' and 
				convert(char(4),datepart(yy,b.cotime))+'/'+ substring(convert(char(3),datepart(mm,b.cotime) + 100),2,2)  = @rpttime 	
			group by a.no 
	
		select a.no,b.name,b.name2,a.gstno,a.rmnum,a.rmnum*a.i_days,a.tl,a.tl/(a.rmnum*a.i_days)
			from #rpt a,guest b
			where a.no = b.no 
		return 0
	end 


	if @rptmode = 'X'
	begin
		insert into #rpt (no,gstno,rmnum,i_days,tl) 
			select a.no,sum(a.gstno),sum(a.rmnum),sum(a.i_days),sum(a.tl) 
			from guest_income a, vhmaster b ,guest c 
			where a.no = b.cusno and a.accnt = b.accnt0 and b.cusno = c.no and c.name like 'RSVN%' and 
				convert(char(4),datepart(yy,b.cotime))+'/'+ substring(convert(char(3),datepart(mm,b.cotime) + 100),2,2)  = @rpttime 	
			group by a.no 
	
		select a.no,b.name,b.name2,a.gstno,a.rmnum,a.rmnum*a.i_days,a.tl,a.tl/(a.rmnum*a.i_days)
			from #rpt a,guest b
			where a.no = b.no 
		return 0
	end 

	return 1 
end
;
