-- ---------------------------------------------------------
--		p_crs_dlmaster  
-- ---------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_crs_dlmaster'  and type = 'P')
	drop procedure p_crs_dlmaster;

create proc p_crs_dlmaster
	@accnt			char(10)				
as
begin
	declare	@hotelid			char(20), 				
				@accnt0			char(10)				

	if exists (select 1 from master where accnt = @accnt)
	begin
		insert hmaster   -- hmaster 字段比master 多一部分 guest 简要内容 
			select a.accnt,a.haccnt,a.groupno,a.type,a.otype,a.up_type,a.up_reason,a.rmnum,
				a.ormnum,a.roomno,a.oroomno,a.bdate,a.sta,a.osta,a.ressta,a.exp_sta,a.sta_tm,
				a.rmpoststa,a.rmposted,a.tag0,a.arr,a.dep,a.resdep,a.oarr,a.odep,a.agent,a.cusno,
				a.source,a.class,a.src,a.market,a.restype,a.channel,a.artag1,a.artag2,a.share,a.gstno,
				a.children,a.rmreason,a.ratecode,a.packages,a.fixrate,a.rmrate,a.qtrate,a.setrate,
				a.rtreason,a.discount,a.discount1,a.addbed,a.addbed_rate,a.crib,a.crib_rate,a.paycode,
				a.limit,a.credcode,a.credman,a.credunit,a.applname,a.applicant,a.araccnt,a.phone,a.fax,
				a.email,a.wherefrom,a.whereto,a.purpose,a.arrdate,a.arrinfo,a.arrcar,a.arrrate,a.depdate,
				a.depinfo,a.depcar,a.deprate,a.extra,a.charge,a.credit,a.accredit,a.lastnumb,a.lastinumb,
				a.srqs,a.amenities,a.master,a.saccnt,a.blkcode,a.oblkcode,a.pcrec,a.pcrec_pkg,a.resno,a.crsno,a.ref,
				a.comsg,a.card,a.saleid,a.cmscode,a.cardcode,a.cardno,a.resby,a.restime,a.ciby,a.citime,
				a.coby,a.cotime,a.depby,a.deptime,a.cby,a.changed,a.exp_m1,a.exp_m2,a.exp_dt1,a.exp_dt2,
				a.exp_s1,a.exp_s2,a.exp_s3,a.exp_s4,a.exp_s5,a.exp_s6,
				b.name,b.fname,b.lname,b.name2,b.name3,b.name4,b.class1,b.class2,b.class3,b.class4,
				b.vip,b.sex,b.birth,b.nation,b.country,b.state,b.town,b.city,b.street,b.idcls,b.ident,
				'',a.logmark  
			 from master a, guest b 
			where a.accnt = @accnt and a.haccnt=b.no 

		delete from master where accnt = @accnt 
		select @accnt0 = accnt0,@hotelid = hotelid from master_hotel where accnt = @accnt
		exec p_guest_income_resum_accnt @hotelid,@accnt0 
	end 
	return 0
end
;
