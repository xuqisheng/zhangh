
if exists (select * from sysobjects where name ='p_zk_stt_regular' and type ='P')
	drop proc p_zk_stt_regular;
create proc p_zk_stt_regular
	@begin			datetime,
	@end				datetime
	
as
	
---------------------------------------------
-- 住店时间段房价与房数预测
---------------------------------------------
declare
	@bdate		datetime,
	@the_dat		datetime,
	@num			int,
	@totalfee		money,
	@totalrn		money,
	@sumrm		int,
	@long			int,
	@cday			datetime,
	@b1			int,
	@b2			int,
	@b3			int,
	@b4			int,
	@b5			int,
	@b6			int,
	@b7			int,
	@b8			int,
	@b9			int,
	@b10			int,
	@temp			char(10),
	@cnum			int

create table #rslt(
	date	datetime,
	b_rm			money,
	b_gstno		money,
	b_rm_xf		money,
	b_ot_xf		money,
	b_rm_av		money,
	b_ttl			money,
	rm				money,
	gstno			money,
	rm_xf			money,
	ot_xf			money,
	rm_av			money,
	ttl			money,
	r_rm			money,
	r_gstno		money,
	r_rm_xf		money,
	r_ot_xf		money,
	r_rm_av		money,
	r_ttl			money
)

select @the_dat = @begin

select @bdate = bdate1 from sysdata

while @the_dat <= @end
	begin
	insert #rslt select @the_dat,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	select @the_dat = dateadd(dd,1,@the_dat)
	if @the_dat = @bdate
		break
	end

update #rslt set b_rm = b.amount from yaudit_impdata b where b.class = 'back_rmnum' and b.date = #rslt.date
update #rslt set b_gstno = b.amount from yaudit_impdata b where b.class = 'back_gstno' and b.date = #rslt.date
update #rslt set b_rm_xf = b.amount from yaudit_impdata b where b.class = 'back_income_rm' and b.date = #rslt.date
update #rslt set b_ot_xf = b.amount from yaudit_impdata b where b.class = 'back_income_ot' and b.date = #rslt.date
update #rslt set b_rm_av = isnull(b_rm_xf/b_rm,0) where b_rm <> 0
update #rslt set b_ttl = isnull(b_rm_xf,0)+isnull(b_ot_xf,0)

update #rslt set rm = b.amount from yaudit_impdata b where b.class = 'sold' and b.date = #rslt.date
update #rslt set gstno = b.amount from yaudit_impdata b where b.class = 'gst' and b.date = #rslt.date
update #rslt set rm_xf = b.amount from yaudit_impdata b where b.class = 'income' and b.date = #rslt.date
update #rslt set rm_av = b.amount from yaudit_impdata b where b.class = 'income%' and b.date = #rslt.date
update #rslt set ttl = b.amount from yaudit_impdata b where b.class = 'total' and b.date = #rslt.date
update #rslt set ot_xf = ttl - rm_xf

update #rslt set r_rm = b_rm *100 / rm where rm <> 0
update #rslt set r_gstno = b_gstno *100 / gstno where gstno <> 0
update #rslt set r_rm_xf = b_rm_xf *100 / rm_xf where rm_xf <> 0
update #rslt set r_rm_av = b_rm_av *100 / rm_av where rm_av <> 0
update #rslt set r_ttl = b_ttl *100 / ttl where ttl <> 0
update #rslt set r_ot_xf = b_ot_xf *100 / ot_xf where ot_xf <> 0



select * from #rslt order by date


;




