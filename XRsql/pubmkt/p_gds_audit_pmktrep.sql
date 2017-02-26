//
//-- ��Դ���������ӡ��ʱ��
//
//if exists (select * from sysobjects where name ='pmktsummaryrep' and type ='U')
//	drop table pmktsummaryrep;
//create table  pmktsummaryrep
//(
//	pc_id			char(4), 
//	class			char(16)  not null, -- ����, A=ɢ��, B=����, C=���� 
//	class1		char(3)  null, 	  -- С�� 
//	descript1	char(20) null, 	  -- ���� 
//	pquan			integer	default 0 not null, 
//	rquan			numeric(10, 1) default 0 not null, 
//	rincome		money		default 0 not null, 
//	tincome		money		default 0 not null
//)
//create index index1 on pmktsummaryrep(pc_id, class, class1)
//;
//
//-- ��Դ���������ӡ׼�� 
//
//if exists (select * from sysobjects where name ='p_gds_audit_pmktrep' and type ='P')
//	drop proc p_gds_audit_pmktrep;
//create proc p_gds_audit_pmktrep
//	@pc_id		char(4), 
//	@pmark		char(2),		-- 'D', ĳ��, 'W' ĳ�����ۼ�, 'M', ĳ�����ۼ� 
//	@beg_			datetime,	-- ���� 
//	@end_			datetime		-- Ԥ�������䱨�� 
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
////update pmktsummaryrep set descript='ɢ��' where class='A'
////update pmktsummaryrep set descript='����' where class='C'
////update pmktsummaryrep set descript='����' where class='G'
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