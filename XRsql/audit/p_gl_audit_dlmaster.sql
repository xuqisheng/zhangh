drop proc p_gl_audit_dlmaster
;
create proc p_gl_audit_dlmaster
	@empno		char(10),
	@ret			integer			out,
	@msg			varchar(70)		out
as

-- 1.自动转储Billno <> ''的账目，当天结账、转账、冲账当晚转储
-- 2."O"状态的账目当晚转储，Account不再保留

declare
	@accnt		char(10),
	@class		char(1),
	@haccnt		char(7),
	@sta			char(1),
	@tag0			char(1),
	@bdate		datetime,
	@bdate1		datetime,
	@billno		char(15),
	@arr			datetime,
	@dep			datetime

-- Delete Guest_log
declare c_haccnt cursor for select distinct no from guest_log order by no
open c_haccnt
fetch c_haccnt into @haccnt
while @@sqlstatus = 0
	begin
	exec p_gl_lgfl_guest @haccnt
	fetch c_haccnt into @haccnt
	end
close c_haccnt
deallocate cursor c_haccnt

-- Dlmaster
select @ret = 0, @msg = '', @bdate = bdate, @bdate1 = bdate1 from sysdata
declare c_dlmaster cursor for select accnt, class, sta, tag0, arr, dep from master where sta = sta_tm order by accnt
open c_dlmaster
fetch c_dlmaster into @accnt, @class, @sta, @tag0, @arr, @dep
while (@@sqlstatus = 0 )
	begin
	if @sta = 'O' and exists (select 1 from master where accnt = @accnt and charge - credit = 0) 
		and not exists (select 1 from account where accnt = @accnt and billno = '')
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

		delete haccount from account b  -- 防止插入重复键 simon 2008.4.10 
			where b.accnt=@accnt and haccount.accnt=b.accnt and haccount.number=b.number
		insert haccount select * from account where accnt = @accnt

		insert hsubaccnt select * from subaccnt where accnt = @accnt
		delete account where accnt = @accnt
		update master set tag0 = 'O', sta = 'D', osta = 'D', logmark = logmark + 1, cby = @empno, changed = getdate()  where accnt = @accnt
		exec p_gds_guest_income @accnt
--		exec p_gl_audit_vipcard_point @accnt, @empno   -- p_gds_guest_income @accnt deal with this.
		end
	else if @sta = 'D'
		begin
		exec p_gl_lgfl_master @accnt
		delete master_log where accnt = @accnt

		delete master where accnt = @accnt
--		delete rsvsrc_detail where accnt = @accnt -- add by zk 2008-11-19
		delete master_middle where accnt = @accnt
		delete subaccnt where accnt = @accnt

		-- 保留，早餐报表等 需要；
		delete hpackage_detail where accnt = @accnt   
		insert hpackage_detail select * from package_detail where accnt = @accnt
		delete package_detail where accnt = @accnt

--		insert into au_hremark select * from au_remark where type ='act' and auaccnt = @accnt
--		delete from au_remark where  type ='act' and auaccnt = @accnt
		end
	else if @sta = 'N' and exists (select 1 from master where accnt = @accnt and charge - credit = 0)
		and not exists (select 1 from account where accnt = @accnt and billno = '')
		and datediff(day, @bdate, @dep) <= 0   -- 始终保留到超过离开日期
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

		delete haccount from account b  -- 防止插入重复键 simon 2008.4.10 
			where b.accnt=@accnt and haccount.accnt=b.accnt and haccount.number=b.number
		insert haccount select * from account where accnt = @accnt

		insert hsubaccnt select * from subaccnt where accnt = @accnt
		exec p_gl_lgfl_master @accnt

		delete master where accnt = @accnt
		delete rsvsrc_detail where accnt = @accnt -- add by zk 2008-11-19
		delete master_middle where accnt = @accnt
		delete master_log where accnt = @accnt
		delete account where accnt = @accnt
		delete subaccnt where accnt = @accnt
		exec p_gds_guest_income @accnt
		end
	else if charindex(@sta, 'LX') > 0
		begin
	   if @sta <> @tag0
		   update master set tag0 = @sta where accnt = @accnt
	   else
			begin
			if exists (select 1 from master where accnt = @accnt and charge - credit = 0)
				and not exists (select 1 from account where accnt = @accnt and billno = '')
				and datediff(day, @bdate, @dep) <= 0   -- 始终保留到超过离开日期
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

				delete haccount from account b  -- 防止插入重复键 simon 2008.4.10 
					where b.accnt=@accnt and haccount.accnt=b.accnt and haccount.number=b.number
				insert haccount select * from account where accnt = @accnt

				insert hsubaccnt select * from subaccnt where accnt = @accnt
				exec p_gl_lgfl_master @accnt

				delete master where accnt = @accnt
				delete rsvsrc_detail where accnt = @accnt -- add by zk 2008-11-19
				delete master_log where accnt = @accnt
				delete master_middle where accnt = @accnt
				delete account where accnt = @accnt
				delete subaccnt where accnt = @accnt
				exec p_gds_guest_income @accnt
				end
			end
		end
	else if charindex(@sta, 'RCG') > 0 and @class in ('F', 'G', 'M') and datediff(day, @bdate, @arr) <= 0
		begin
			begin tran
			save  tran p_dlmaster_rcgsta

			if @class='F'
				begin
				update master set tag0 = 'N', sta = 'N', logmark = logmark + 1, cby = @empno, changed = getdate()
					where accnt = @accnt and datediff(day, @bdate, arr) <= 0
				if @@rowcount > 0
					exec @ret = p_gds_reserve_chktprm @accnt, '2', '', @empno, '', 1, 1, @msg output
				end
			else
				exec @ret = p_gds_master_sta @accnt, 'hungN', @empno, 'R', @ret output, @msg output

			if @ret <> 0
				begin
				rollback tran p_dlmaster_rcgsta
				commit tran
				break
				end
			commit tran
		end

	fetch c_dlmaster into @accnt, @class, @sta, @tag0, @arr, @dep
	end
close c_dlmaster
deallocate cursor c_dlmaster

-- Dlar_master
if @ret = 0 
begin 
	select @ret = 0, @msg = '', @bdate = bdate, @bdate1 = bdate1 from sysdata
	declare c_dlar_master cursor for select accnt, class, sta, arr, dep from ar_master where sta = sta_tm order by accnt
	open c_dlar_master
	fetch c_dlar_master into @accnt, @class, @sta, @arr, @dep
	while (@@sqlstatus = 0 )
		begin
		if @sta = 'O' and exists (select 1 from ar_master where accnt = @accnt and charge - charge0 - credit + credit0 = 0) 
			and not exists (select 1 from ar_detail where accnt = @accnt and charge + charge0 - charge9 - credit - credit0 + credit9 != 0)
			begin
			insert har_master select * from ar_master where accnt = @accnt
			insert hsubaccnt select * from subaccnt where accnt = @accnt
			update ar_master set sta = 'D', osta = 'D', logmark = logmark + 1, cby = @empno, changed = getdate()  where accnt = @accnt
			end
		else if @sta = 'D'
			begin
			exec p_gl_lgfl_ar_master @accnt
			delete ar_master_log where accnt = @accnt
	
			delete ar_master where accnt = @accnt
			delete subaccnt where accnt = @accnt
	
	--		insert into au_hremark select * from au_remark where type ='act' and auaccnt = @accnt
	--		delete from au_remark where  type ='act' and auaccnt = @accnt
			end
	
		fetch c_dlar_master into @accnt, @class, @sta, @arr, @dep
		end
	close c_dlar_master
	deallocate cursor c_dlar_master
end 

-- Dlaccount
select @billno = '[B,C,T]' + substring(convert(char(10), @bdate1, 111), 4, 1) + substring(convert(char(10), @bdate1, 111), 6, 2) + substring(convert(char(10), @bdate1, 111), 9, 2) + '%'
delete haccount from account b  -- 防止插入重复键 simon 2008.4.10 
	where b.billno<>'' and not b.billno like @billno and haccount.accnt=b.accnt and haccount.number=b.number
insert haccount select * from account where billno <> '' and not billno like @billno
delete account where billno <> '' and not billno like @billno

return @ret
;