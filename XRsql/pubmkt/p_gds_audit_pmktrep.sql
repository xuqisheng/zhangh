//
//-- 来源分析报表打印临时表
//
//if exists (select * from sysobjects where name ='pmktsummaryrep' and type ='U')
//	drop table pmktsummaryrep;
//create table  pmktsummaryrep
//(
//	pc_id			char(4), 
//	class			char(16)  not null, -- 大类, A=散客, B=会议, C=团体 
//	class1		char(3)  null, 	  -- 小类 
//	descript1	char(20) null, 	  -- 描述 
//	pquan			integer	default 0 not null, 
//	rquan			numeric(10, 1) default 0 not null, 
//	rincome		money		default 0 not null, 
//	tincome		money		default 0 not null
//)
//create index index1 on pmktsummaryrep(pc_id, class, class1)
//;
//
//-- 来源分析报表打印准备 
//
//if exists (select * from sysobjects where name ='p_gds_audit_pmktrep' and type ='P')
//	drop proc p_gds_audit_pmktrep;
//create proc p_gds_audit_pmktrep
//	@pc_id		char(4), 
//	@pmark		char(2),		-- 'D', 某日, 'W' 某日周累计, 'M', 某日月累计 
//	@beg_			datetime,	-- 日期 
//	@end_			datetime		-- 预留出区间报表 
//as
//
//declare 
//	@monthbeg	datetime, 
//	@isfstday	char(1), 
//	@isyfstday	char(1)
//
//select @monthbeg = @beg_, @isfstday = 'F'
//delete pmktsummaryrep where pc_id = @pc_id 
//
//if @pmark = 'D'
//	select @monthbeg = @beg_
//else 
//	begin
//	if @pmark = 'W'
//		begin
//		while datepart(dw, @monthbeg) <> 2 
//			select @monthbeg=dateadd(dd, -1, @monthbeg)
//		end 
//	else
//		begin
//		exec p_hry_audit_fstday @monthbeg, @isfstday out, @isyfstday out
//		while @isfstday = 'F'
//			begin
//			select @monthbeg = dateadd(dd, -1, @monthbeg)
//			exec p_hry_audit_fstday @monthbeg, @isfstday out, @isyfstday out
//			end 
//		end 
//	end 
//
//insert pmktsummaryrep
//	select @pc_id, '', market, '', sum(gstno), sum(i_days), sum(rm), sum(ttl)
//	from  ycus_xf
//	where date >= @monthbeg and date <= @beg_ and actcls='F'
//	group by market 
//update pmktsummaryrep set class=a.grp from mktcode a where pmktsummaryrep.class1=a.code
//
////update pmktsummaryrep set descript='散客' where class='A'
////update pmktsummaryrep set descript='会议' where class='C'
////update pmktsummaryrep set descript='团体' where class='G'
//
//update pmktsummaryrep set descript1=a.descript from mktcode a 
//	where pmktsummaryrep.class1=a.code
//
//select * from pmktsummaryrep
//
//return 0
//;
//
//