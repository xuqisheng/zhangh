// 执行之前先删掉master的触发器？
if exists (select * from sysobjects where name = 'p_v5_to_x5_master' and type ='P')
	drop proc p_v5_to_x5_master;
create proc p_v5_to_x5_master
as

declare
	@laccnt		char(7),
	@caccnt		char(7),
	@cguestid	char(7),
	@groupno		char(7),
	@class		char(1),
	@market		char(3),
	@count		integer,
	@adjust		money,				// 调整系数，房费、余额在第一个客人身上
	//
	@haccnt		char(7),
	@master		char(10),
	@pcrec		char(10),
	@accnt		char(10)

// 转换Master
delete master where accnt like '[F,C]%'
delete master_des where accnt like '[F,C]%'
delete subaccnt where accnt like '[F,C]%'
//
declare c_guest cursor for 
	select a.accnt, a.guestid, a.haccnt, b.pcrec, c.newcode, b.groupno from v5..guest a,v5..master b, a_mktcode c
	where a.accnt = b.accnt and c.class = 'F' and b.class = c.code order by a.accnt, a.guestid
open c_guest
fetch c_guest into @caccnt, @cguestid, @haccnt, @pcrec, @market, @groupno
while @@sqlstatus = 0
	begin
	exec p_gds_guest_upgrade @cguestid, @haccnt out
	if @caccnt = @laccnt
		select @count = @count + 1
	else
		select @count = 0
	//
	if @market = '#'
		select @market = isnull((select b.newcode from v5..grpmst a, a_mktcode b where a.accnt = @groupno and a.class = b.code and b.class='G'), @market)
	//
	if substring(@caccnt,2,2) = '95'
		select @accnt = 'C00' + substring(@caccnt,1,1) + substring(@caccnt,5,3), @class = 'C'
	else
		select @accnt = 'F0' + @caccnt + convert(char(1), @count), @class = 'F'
	//
	if @count = 0
		select @master = @accnt, @adjust = 1.00
	else
		select @adjust = 0
	//
	if @pcrec is null
		select @pcrec = ''
	else
		select @pcrec = 'F0' + substring(@pcrec, 1, 7) + '0'
	//
	insert master
		(
		accnt		,haccnt		,groupno		,type			,otype		,up_type		,up_reason	,rmnum		,ormnum		,roomno,
		oroomno	,bdate		,sta			,osta			,ressta		,exp_sta		,sta_tm		,rmpoststa	,rmposted	,tag0,
		arr		,dep			,resdep		,oarr			,odep			,agent		,cusno		,source		,class		,src,
		market	,restype		,channel		,artag1		,artag2		,share		,gstno		,children	,rmreason	,ratecode,
		packages	,fixrate		,rmrate		,qtrate		,setrate		,rtreason	,discount	,discount1	,addbed		,addbed_rate,
		crib		,crib_rate	,paycode		,limit		,credcode	,credman		,credunit	,applname	,applicant	,araccnt,
		phone		,wherefrom	,whereto		,purpose		,arrdate		,arrinfo		,depdate		,depinfo		,extra		,charge,
		credit	,accredit	,lastnumb	,lastinumb	,srqs			,amenities	,master		,saccnt		,pcrec		,pcrec_pkg,
		resno		,crsno		,ref			,comsg		,card			,saleid		,resby		,restime		,ciby			,citime,
		coby		,cotime		,depby		,deptime		,cby			,changed		,exp_m1		,exp_m2		,exp_dt1		,exp_dt2,
		exp_s1	,exp_s2		,exp_s3		,logmark
		)
	select
		@accnt	,@haccnt		,a.groupno	,a.type		,a.otype		,''			,''			,a.rmnum		,a.ormnum	,a.roomno,
		a.oroomno,a.bdate		,a.sta		,a.osta		,a.ressta	,a.exp_sta	,isnull(a.sta_tm,''),isnull(a.rmpoststa,''),a.rmposted	,a.tag0,
		a.arr		,a.dep		,a.resdep	,a.oarr		,a.odep		,''			,isnull(a.cusno,''),''	,@class		,isnull(a.src,''),
		@market	,''			,''			,''			,''			,''			,a.gstno*@adjust,isnull(a.children,0)*@adjust,isnull(a.rmreason,''),'',
		''			,'F'			,isnull(c.rate,0),a.setrate*@adjust,a.setrate*(1-a.discount1)*@adjust,a.rtreason,a.discount*@adjust,a.discount1*@adjust,0,a.extrabed*@adjust,
		0			,0				,isnull(a.paycode,''),a.limit*@adjust,isnull(a.credcode,'')	,a.credman	,a.credunit	,a.applname	,isnull(a.applicant,''),isnull(a.araccnt,''),
		a.phoneetc,isnull(b.wherefrom,''),isnull(b.whereto,''),isnull(b.purpose,''),Null,arrinfo,Null,depinfo,''	,a.rmb_db*@adjust,
		(a.depr_cr+a.addrmb)*@adjust,0	,a.lastnumb*@adjust,a.lastinumb*@adjust,isnull(a.srqs,''),isnull(b.srqs,''),@master,''	,@pcrec		,'',
		isnull(a.resno,''),'',''			,''			,''			,''			,a.resby		,a.reserved	,''			,Null,
		''			,Null			,''			,Null			,a.cby		,a.changed	,0				,0				,Null			,Null,
		''			,''			,''			,a.logmark
		from v5..master a, v5..guest b, v5..rmsta c
		where a.accnt = @caccnt and b.guestid = @cguestid and a.roomno *= c.roomno
	select @laccnt = @caccnt
	fetch c_guest into @caccnt, @cguestid, @haccnt, @pcrec, @market, @groupno
	end
close c_guest
deallocate cursor c_guest
update master set sta = 'I' where sta = 'H'
update master set osta = 'I' where osta = 'H'
update master set sta_tm = 'I' where sta_tm = 'H'
update master set ressta = 'I' where ressta = 'H'

// 转换Master_till
delete master_till where accnt like '[F,C]%'
//
declare c_guest cursor for 
	select a.accnt, a.guestid, a.haccnt, b.pcrec, c.newcode, b.groupno from v5..guest a,v5..master_till b, a_mktcode c
	where a.accnt = b.accnt and c.class = 'F' and b.class = c.code order by a.accnt, a.guestid
open c_guest
fetch c_guest into @caccnt, @cguestid, @haccnt, @pcrec, @market, @groupno
while @@sqlstatus = 0
	begin
	exec p_gds_guest_upgrade @cguestid, @haccnt out
	if @caccnt = @laccnt
		select @count = @count + 1
	else
		select @count = 0
	//
	if @market = '#'
		select @market = isnull((select b.newcode from v5..grpmst_till a, a_mktcode b where a.accnt = @groupno and a.class = b.code and b.class='G'), @market)
	//
	if substring(@caccnt,2,2) = '95'
		select @accnt = 'C00' + substring(@caccnt,1,1) + substring(@caccnt,5,3), @class = 'C'
	else
		select @accnt = 'F0' + @caccnt + convert(char(1), @count), @class = 'F'
	//
	if @count = 0
		select @master = @accnt, @adjust = 1.00
	else
		select @adjust = 0
	//
	if @pcrec is null
		select @pcrec = ''
	else
		select @pcrec = 'F0' + substring(@pcrec, 1, 7) + '0'
	//
	insert master_till
		(
		accnt		,haccnt		,groupno		,type			,otype		,up_type		,up_reason	,rmnum		,ormnum		,roomno,
		oroomno	,bdate		,sta			,osta			,ressta		,exp_sta		,sta_tm		,rmpoststa	,rmposted	,tag0,
		arr		,dep			,resdep		,oarr			,odep			,agent		,cusno		,source		,class		,src,
		market	,restype		,channel		,artag1		,artag2		,share		,gstno		,children	,rmreason	,ratecode,
		packages	,fixrate		,rmrate		,qtrate		,setrate		,rtreason	,discount	,discount1	,addbed		,addbed_rate,
		crib		,crib_rate	,paycode		,limit		,credcode	,credman		,credunit	,applname	,applicant	,araccnt,
		phone		,wherefrom	,whereto		,purpose		,arrdate		,arrinfo		,depdate		,depinfo		,extra		,charge,
		credit	,accredit	,lastnumb	,lastinumb	,srqs			,amenities	,master		,saccnt		,pcrec		,pcrec_pkg,
		resno		,crsno		,ref			,comsg		,card			,saleid		,resby		,restime		,ciby			,citime,
		coby		,cotime		,depby		,deptime		,cby			,changed		,exp_m1		,exp_m2		,exp_dt1		,exp_dt2,
		exp_s1	,exp_s2		,exp_s3		,logmark
		)
	select
		@accnt	,@haccnt		,a.groupno	,a.type		,a.otype		,''			,''			,a.rmnum		,a.ormnum	,a.roomno,
		a.oroomno,a.bdate		,a.sta		,a.osta		,a.ressta	,a.exp_sta	,isnull(a.sta_tm,''),isnull(a.rmpoststa,''),a.rmposted	,a.tag0,
		a.arr		,a.dep		,a.resdep	,a.oarr		,a.odep		,''			,isnull(a.cusno,''),''	,@class		,isnull(a.src,''),
		@market	,''			,''			,''			,''			,''			,a.gstno*@adjust,isnull(a.children,0)*@adjust,isnull(a.rmreason,''),'',
		''			,'F'			,isnull(c.rate,0),a.setrate*@adjust,a.setrate*(1-a.discount1)*@adjust,a.rtreason,a.discount*@adjust,a.discount1*@adjust,0,a.extrabed*@adjust,
		0			,0				,isnull(a.paycode,''),a.limit*@adjust,isnull(a.credcode,'')	,a.credman	,a.credunit	,a.applname	,isnull(a.applicant,''),isnull(a.araccnt,''),
		a.phoneetc,isnull(b.wherefrom,''),isnull(b.whereto,''),isnull(b.purpose,''),Null,arrinfo,Null,depinfo,''	,a.rmb_db*@adjust,
		(a.depr_cr+a.addrmb)*@adjust,0	,a.lastnumb*@adjust,a.lastinumb*@adjust,isnull(a.srqs,''),isnull(b.srqs,''),@master,''	,@pcrec		,'',
		isnull(a.resno,''),'',''			,''			,''			,''			,a.resby		,a.reserved	,''			,Null,
		''			,Null			,''			,Null			,a.cby		,a.changed	,0				,0				,Null			,Null,
		''			,''			,''			,a.logmark
		from v5..master_till a, v5..guest b, v5..rmsta c
		where a.accnt = @caccnt and b.guestid = @cguestid and a.roomno *= c.roomno
	select @laccnt = @caccnt
	fetch c_guest into @caccnt, @cguestid, @haccnt, @pcrec, @market, @groupno
	end
close c_guest
deallocate cursor c_guest
update master_till set sta = 'I' where sta = 'H'
update master_till set osta = 'I' where osta = 'H'
update master_till set sta_tm = 'I' where sta_tm = 'H'
update master_till set ressta = 'I' where ressta = 'H'

//// 转换master_last
//delete master_last where accnt like '[F,C]%'
////
//declare c_guest cursor for 
//	select a.accnt, a.guestid, a.haccnt, b.pcrec, c.newcode, b.groupno from v5..guest a,v5..master_last b, a_mktcode c
//	where a.accnt = b.accnt and c.class = 'F' and b.class = c.code order by a.accnt, a.guestid
//open c_guest
//fetch c_guest into @caccnt, @cguestid, @haccnt, @pcrec, @market, @groupno
//while @@sqlstatus = 0
//	begin
//	exec p_gds_guest_upgrade @cguestid, @haccnt out
//	if @caccnt = @laccnt
//		select @count = @count + 1
//	else
//		select @count = 0
//	//
//	if @market = '#'
//		select @market = isnull((select b.newcode from v5..grpmst_last a, a_mktcode b where a.accnt = @groupno and a.class = b.code and b.class='G'), @market)
//	//
//	if substring(@caccnt,2,2) = '95'
//		select @accnt = 'C00' + substring(@caccnt,1,1) + substring(@caccnt,5,3), @class = 'C'
//	else
//		select @accnt = 'F0' + @caccnt + convert(char(1), @count), @class = 'F'
//	//
//	if @count = 0
//		select @master = @accnt, @adjust = 1.00
//	else
//		select @adjust = 0
//	//
//	if @pcrec is null
//		select @pcrec = ''
//	else
//		select @pcrec = 'F0' + substring(@pcrec, 1, 7) + '0'
//	//
//	insert master_last
//		(
//		accnt		,haccnt		,groupno		,type			,otype		,up_type		,up_reason	,rmnum		,ormnum		,roomno,
//		oroomno	,bdate		,sta			,osta			,ressta		,exp_sta		,sta_tm		,rmpoststa	,rmposted	,tag0,
//		arr		,dep			,resdep		,oarr			,odep			,agent		,cusno		,source		,class		,src,
//		market	,restype		,channel		,artag1		,artag2		,share		,gstno		,children	,rmreason	,ratecode,
//		packages	,fixrate		,rmrate		,qtrate		,setrate		,rtreason	,discount	,discount1	,addbed		,addbed_rate,
//		crib		,crib_rate	,paycode		,limit		,credcode	,credman		,credunit	,applname	,applicant	,araccnt,
//		phone		,wherefrom	,whereto		,purpose		,arrdate		,arrinfo		,depdate		,depinfo		,extra		,charge,
//		credit	,accredit	,lastnumb	,lastinumb	,srqs			,amenities	,master		,saccnt		,pcrec		,pcrec_pkg,
//		resno		,crsno		,ref			,comsg		,card			,saleid		,resby		,restime		,ciby			,citime,
//		coby		,cotime		,depby		,deptime		,cby			,changed		,exp_m1		,exp_m2		,exp_dt1		,exp_dt2,
//		exp_s1	,exp_s2		,exp_s3		,logmark
//		)
//	select
//		@accnt	,@haccnt		,a.groupno	,a.type		,a.otype		,''			,''			,a.rmnum		,a.ormnum	,a.roomno,
//		a.oroomno,a.bdate		,a.sta		,a.osta		,a.ressta	,a.exp_sta	,isnull(a.sta_tm,''),isnull(a.rmpoststa,''),a.rmposted	,a.tag0,
//		a.arr		,a.dep		,a.resdep	,a.oarr		,a.odep		,''			,isnull(a.cusno,''),''	,@class		,isnull(a.src,''),
//		@market	,''			,''			,''			,''			,''			,a.gstno*@adjust,isnull(a.children,0)*@adjust,isnull(a.rmreason,''),'',
//		''			,'F'			,isnull(c.rate,0),a.setrate*@adjust,a.setrate*(1-a.discount1)*@adjust,a.rtreason,a.discount*@adjust,a.discount1*@adjust,0,a.extrabed*@adjust,
//		0			,0				,isnull(a.paycode,''),a.limit*@adjust,isnull(a.credcode,'')	,a.credman	,a.credunit	,a.applname	,isnull(a.applicant,''),isnull(a.araccnt,''),
//		a.phoneetc,isnull(b.wherefrom,''),isnull(b.whereto,''),isnull(b.purpose,''),Null,arrinfo,Null,depinfo,''	,a.rmb_db*@adjust,
//		(a.depr_cr+a.addrmb)*@adjust,0	,a.lastnumb*@adjust,a.lastinumb*@adjust,isnull(a.srqs,''),isnull(b.srqs,''),@master,''	,@pcrec		,'',
//		isnull(a.resno,''),'',''			,''			,''			,''			,a.resby		,a.reserved	,''			,Null,
//		''			,Null			,''			,Null			,a.cby		,a.changed	,0				,0				,Null			,Null,
//		''			,''			,''			,a.logmark
//		from v5..master_last a, v5..guest b, v5..rmsta c
//		where a.accnt = @caccnt and b.guestid = @cguestid and a.roomno *= c.roomno
//	select @laccnt = @caccnt
//	fetch c_guest into @caccnt, @cguestid, @haccnt, @pcrec, @market, @groupno
//	end
//close c_guest
//deallocate cursor c_guest
//update master_last set sta = 'I' where sta = 'H'
//update master_last set osta = 'I' where osta = 'H'
//update master_last set sta_tm = 'I' where sta_tm = 'H'
//update master_last set ressta = 'I' where ressta = 'H'
return
;


if exists (select * from sysobjects where name = 'p_v5_to_x5_grpmst' and type ='P')
	drop proc p_v5_to_x5_grpmst;
create proc p_v5_to_x5_grpmst
as
declare
	@laccnt		char(7),
	@caccnt		char(7),
	@class		char(1),
	@market		char(3),
	@count		integer,
	//
	@haccnt		char(7),
	@master		char(10),
	@accnt		char(10)

// 转换grpmst
delete master where accnt like '[G,M]%'
delete master_des where accnt like '[G,M]%'
delete subaccnt where accnt like '[G,M]%'
//
declare c_grpmst cursor for 
	select a.accnt, a.class, b.newcode from v5..grpmst a, a_mktcode b where a.class = b.code and b.class = 'G' order by accnt
open c_grpmst
fetch c_grpmst into @caccnt, @class, @market
while @@sqlstatus = 0
	begin
	select @haccnt = ''
	exec p_GetAccnt1 'HIS', @haccnt output
	insert guest(no,class,type,sta,
				src,            name,            nation,country,            cusno,   
				code1,            arr,         dep,            liason,   
				unit,            araccnt1,            phone,            srqs,   
				remark,   			crtby,         crttime,            cby,   
				changed,            logmark,            vip  
	)
	  SELECT @haccnt, 'G','N','I',
				isnull(src,   ''),         isnull(name,  ''),          isnull(nation,   ''),isnull(nation,   ''),         isnull(cusno,   ''),
				isnull(tranlog,   ''),         arr,         dep,            isnull(applname,   ''),
				isnull(applicant,   ''),         isnull(araccnt,   ''),         isnull(phoneetc,   ''),         isnull(srqs,   ''),
				isnull(ref,   ''),         isnull(resby,   ''),         reserved,            isnull(cby,   ''),
				changed,            logmark,            isnull(vip,  '')
		 FROM v5..grpmst where accnt = @caccnt
	//
	if @class = 'D'
		select @accnt = 'M0' + @caccnt + '0', @class = 'M'
	else
		select @accnt = 'G0' + @caccnt + '0', @class = 'G'
	//
	insert master
		(
		accnt		,haccnt		,groupno		,type			,otype		,up_type		,up_reason	,rmnum		,ormnum		,roomno,
		oroomno	,bdate		,sta			,osta			,ressta		,exp_sta		,sta_tm		,rmpoststa	,rmposted	,tag0,
		arr		,dep			,resdep		,oarr			,odep			,agent		,cusno		,source		,class		,src,
		market	,restype		,channel		,artag1		,artag2		,share		,gstno		,children	,rmreason	,ratecode,
		packages	,fixrate		,rmrate		,qtrate		,setrate		,rtreason	,discount	,discount1	,addbed		,addbed_rate,
		crib		,crib_rate	,paycode		,limit		,credcode	,credman		,credunit	,applname	,applicant	,araccnt,
		phone		,wherefrom	,whereto		,purpose		,arrdate		,arrinfo		,depdate		,depinfo		,extra		,charge,
		credit	,accredit	,lastnumb	,lastinumb	,srqs			,amenities	,master		,saccnt		,pcrec		,pcrec_pkg,
		resno		,crsno		,ref			,comsg		,card			,saleid		,resby		,restime		,ciby			,citime,
		coby		,cotime		,depby		,deptime		,cby			,changed		,exp_m1		,exp_m2		,exp_dt1		,exp_dt2,
		exp_s1	,exp_s2		,exp_s3		,logmark
		)
	select
		@accnt	,@haccnt		,''			,''			,''			,''			,''			,a.rooms		,0				,'',
		'',convert(datetime,convert(char(10),a.reserved,101)),a.sta,'',a.ressta	,a.exp_sta	,isnull(a.sta_tm,''),''	,'F'	,a.tag0,
		a.arr		,a.dep		,a.resdep	,a.oarr		,a.odep		,''			,isnull(a.cusno,''),''	,@class		,isnull(a.src,''),
		@market	,''			,''			,''			,''			,''			,a.gstno		,isnull(a.children,0),'','',
		''			,'F'			,a.rate		,0				,a.rate		,''			,0				,0				,0				,0,
		0			,0				,isnull(substring(a.paycode,1,3),''),a.limit		,isnull(a.credcode,'')	,a.credman	,a.credunit	,a.applname	,isnull(a.applicant,''),isnull(a.araccnt,''),
		a.phoneetc,isnull(a.wherefrom,''),isnull(a.whereto,''),'',Null,arrinfo,Null,depinfo,''	,a.rmb_db,
		a.depr_cr+a.addrmb,0	,a.lastnumb	,a.lastinumb,isnull(a.srqs,''),''	,''			,''			,''			,		'',
		isnull(a.resno,''),'',''			,''			,''			,''			,a.resby		,a.reserved	,''			,Null,
		''			,Null			,''			,Null			,a.cby		,a.changed	,0				,0				,Null			,Null,
		''			,''			,''			,a.logmark
		from v5..grpmst a
		where a.accnt = @caccnt
	select @laccnt = @caccnt
	fetch c_grpmst into @caccnt, @class, @market
	end
close c_grpmst
deallocate cursor c_grpmst

// 转换grpmst_till
delete master_till where accnt like '[G,M]%'
//
declare c_grpmst cursor for 
	select a.accnt, a.class, b.newcode from v5..grpmst_till a, a_mktcode b where a.class = b.code and b.class = 'G' order by accnt
open c_grpmst
fetch c_grpmst into @caccnt, @class, @market
while @@sqlstatus = 0
	begin
	if @class = 'D'
		select @accnt = 'M0' + @caccnt + '0', @class = 'M'
	else
		select @accnt = 'G0' + @caccnt + '0', @class = 'G'
	//
	select @haccnt = ''
	select @haccnt = haccnt from master where accnt = @accnt
	if rtrim(@haccnt) is null
		begin
		exec p_GetAccnt1 'HIS', @haccnt output
		insert guest(no,class,type,sta,
					src,            name,            nation,country,            cusno,   
					code1,            arr,         dep,            liason,   
					unit,            araccnt1,            phone,            srqs,   
					remark,   			crtby,         crttime,            cby,   
					changed,            logmark,            vip  
		)
		  SELECT @haccnt, 'G','N','I',
					isnull(src,   ''),         isnull(name,  ''),          isnull(nation,   ''),isnull(nation,   ''),         isnull(cusno,   ''),
					isnull(tranlog,   ''),         arr,         dep,            isnull(applname,   ''),
					isnull(applicant,   ''),         isnull(araccnt,   ''),         isnull(phoneetc,   ''),         isnull(srqs,   ''),
					isnull(ref,   ''),         isnull(resby,   ''),         reserved,            isnull(cby,   ''),
					changed,            logmark,            isnull(vip,  '')
			 FROM v5..grpmst_till where accnt = @caccnt
		end
	//
	insert master_till
		(
		accnt		,haccnt		,groupno		,type			,otype		,up_type		,up_reason	,rmnum		,ormnum		,roomno,
		oroomno	,bdate		,sta			,osta			,ressta		,exp_sta		,sta_tm		,rmpoststa	,rmposted	,tag0,
		arr		,dep			,resdep		,oarr			,odep			,agent		,cusno		,source		,class		,src,
		market	,restype		,channel		,artag1		,artag2		,share		,gstno		,children	,rmreason	,ratecode,
		packages	,fixrate		,rmrate		,qtrate		,setrate		,rtreason	,discount	,discount1	,addbed		,addbed_rate,
		crib		,crib_rate	,paycode		,limit		,credcode	,credman		,credunit	,applname	,applicant	,araccnt,
		phone		,wherefrom	,whereto		,purpose		,arrdate		,arrinfo		,depdate		,depinfo		,extra		,charge,
		credit	,accredit	,lastnumb	,lastinumb	,srqs			,amenities	,master		,saccnt		,pcrec		,pcrec_pkg,
		resno		,crsno		,ref			,comsg		,card			,saleid		,resby		,restime		,ciby			,citime,
		coby		,cotime		,depby		,deptime		,cby			,changed		,exp_m1		,exp_m2		,exp_dt1		,exp_dt2,
		exp_s1	,exp_s2		,exp_s3		,logmark
		)
	select
		@accnt	,@haccnt		,''			,''			,''			,''			,''			,a.rooms		,0				,'',
		'',convert(datetime,convert(char(10),a.reserved,101)),a.sta,'',a.ressta	,a.exp_sta	,isnull(a.sta_tm,''),''	,'F'	,a.tag0,
		a.arr		,a.dep		,a.resdep	,a.oarr		,a.odep		,''			,isnull(a.cusno,''),''	,@class		,isnull(a.src,''),
		@market	,''			,''			,''			,''			,''			,a.gstno		,isnull(a.children,0),'','',
		''			,'F'			,a.rate		,0				,a.rate		,''			,0				,0				,0				,0,
		0			,0				,isnull(substring(a.paycode,1,3),''),a.limit		,isnull(a.credcode,'')	,a.credman	,a.credunit	,a.applname	,isnull(a.applicant,''),isnull(a.araccnt,''),
		a.phoneetc,isnull(a.wherefrom,''),isnull(a.whereto,''),'',Null,arrinfo,Null,depinfo,''	,a.rmb_db,
		a.depr_cr+a.addrmb,0	,a.lastnumb	,a.lastinumb,isnull(a.srqs,''),''	,''			,''			,''			,		'',
		isnull(a.resno,''),'',''			,''			,''			,''			,a.resby		,a.reserved	,''			,Null,
		''			,Null			,''			,Null			,a.cby		,a.changed	,0				,0				,Null			,Null,
		''			,''			,''			,a.logmark
		from v5..grpmst_till a
		where a.accnt = @caccnt
	select @laccnt = @caccnt
	fetch c_grpmst into @caccnt, @class, @market
	end
close c_grpmst
deallocate cursor c_grpmst

//// 转换grpmst_last
//delete master_last where accnt like '[G,M]%'
////
//declare c_grpmst cursor for 
//	select a.accnt, a.class, b.newcode from v5..grpmst_last a, a_mktcode b where a.class = b.code and b.class = 'G' order by accnt
//open c_grpmst
//fetch c_grpmst into @caccnt, @class, @market
//while @@sqlstatus = 0
//	begin
//	if @class = 'D'
//		select @accnt = 'M0' + @caccnt + '0', @class = 'M'
//	else
//		select @accnt = 'G0' + @caccnt + '0', @class = 'G'
//	//
//	select @haccnt = ''
//	select @haccnt = haccnt from master where accnt = @accnt
//	if rtrim(@haccnt) is null
//		begin
//		exec p_GetAccnt1 'HIS', @haccnt output
//		insert guest(no,class,type,sta,
//					src,            name,            nation,country,            cusno,   
//					code1,            arr,         dep,            liason,   
//					unit,            araccnt1,            phone,            srqs,   
//					remark,   			crtby,         crttime,            cby,   
//					changed,            logmark,            vip  
//		)
//		  SELECT @haccnt, 'G','N','I',
//					isnull(src,   ''),         isnull(name,  ''),          isnull(nation,   ''),isnull(nation,   ''),         isnull(cusno,   ''),
//					isnull(tranlog,   ''),         arr,         dep,            isnull(applname,   ''),
//					isnull(applicant,   ''),         isnull(araccnt,   ''),         isnull(phoneetc,   ''),         isnull(srqs,   ''),
//					isnull(ref,   ''),         isnull(resby,   ''),         reserved,            isnull(cby,   ''),
//					changed,            logmark,            isnull(vip,  '')
//			 FROM v5..grpmst_last where accnt = @caccnt
//		end
//	//
//	insert master_last
//		(
//		accnt		,haccnt		,groupno		,type			,otype		,up_type		,up_reason	,rmnum		,ormnum		,roomno,
//		oroomno	,bdate		,sta			,osta			,ressta		,exp_sta		,sta_tm		,rmpoststa	,rmposted	,tag0,
//		arr		,dep			,resdep		,oarr			,odep			,agent		,cusno		,source		,class		,src,
//		market	,restype		,channel		,artag1		,artag2		,share		,gstno		,children	,rmreason	,ratecode,
//		packages	,fixrate		,rmrate		,qtrate		,setrate		,rtreason	,discount	,discount1	,addbed		,addbed_rate,
//		crib		,crib_rate	,paycode		,limit		,credcode	,credman		,credunit	,applname	,applicant	,araccnt,
//		phone		,wherefrom	,whereto		,purpose		,arrdate		,arrinfo		,depdate		,depinfo		,extra		,charge,
//		credit	,accredit	,lastnumb	,lastinumb	,srqs			,amenities	,master		,saccnt		,pcrec		,pcrec_pkg,
//		resno		,crsno		,ref			,comsg		,card			,saleid		,resby		,restime		,ciby			,citime,
//		coby		,cotime		,depby		,deptime		,cby			,changed		,exp_m1		,exp_m2		,exp_dt1		,exp_dt2,
//		exp_s1	,exp_s2		,exp_s3		,logmark
//		)
//	select
//		@accnt	,@haccnt		,''			,''			,''			,''			,''			,a.rooms		,0				,'',
//		'',convert(datetime,convert(char(10),a.reserved,101)),a.sta,'',a.ressta	,a.exp_sta	,isnull(a.sta_tm,''),''	,'F'	,a.tag0,
//		a.arr		,a.dep		,a.resdep	,a.oarr		,a.odep		,''			,isnull(a.cusno,''),''	,@class		,isnull(a.src,''),
//		@market	,''			,''			,''			,''			,''			,a.gstno		,isnull(a.children,0),'','',
//		''			,'F'			,a.rate		,0				,a.rate		,''			,0				,0				,0				,0,
//		0			,0				,isnull(substring(a.paycode,1,3),''),a.limit		,isnull(a.credcode,'')	,a.credman	,a.credunit	,a.applname	,isnull(a.applicant,''),isnull(a.araccnt,''),
//		a.phoneetc,isnull(a.wherefrom,''),isnull(a.whereto,''),'',Null,arrinfo,Null,depinfo,''	,a.rmb_db,
//		a.depr_cr+a.addrmb,0	,a.lastnumb	,a.lastinumb,isnull(a.srqs,''),''	,''			,''			,''			,		'',
//		isnull(a.resno,''),'',''			,''			,''			,''			,a.resby		,a.reserved	,''			,Null,
//		''			,Null			,''			,Null			,a.cby		,a.changed	,0				,0				,Null			,Null,
//		''			,''			,''			,a.logmark
//		from v5..grpmst_last a
//		where a.accnt = @caccnt
//	select @laccnt = @caccnt
//	fetch c_grpmst into @caccnt, @class, @market
//	end
//close c_grpmst
//deallocate cursor c_grpmst
return
;

// ----------------------------------------------------------------------------------
//		v5:armst --> x5:master 
//			
//			这里先把armst 里面的信息全部作为单位加入，用户可以后期进行修改
// ----------------------------------------------------------------------------------
if object_id('p_gds_armst_trans') is not null
	drop proc p_gds_armst_trans;
create proc p_gds_armst_trans
as

declare	@accnt		char(10),
			@guest		char(7),
			@hno			char(7),
			@artag2		char(1),
			@bdate		datetime

// 转换armst
delete master where accnt like '[A]%'
delete master_des where accnt like '[A]%'
delete subaccnt where accnt like '[A]%'
//
select @bdate = bdate1 from sysdata

declare c_armst cursor for select accnt,class from v5..armst
open c_armst
fetch c_armst into @accnt, @artag2
while @@sqlstatus = 0
begin
	if exists(select 1 from master where accnt=@accnt)
	begin
		fetch c_armst into @accnt
		continue
	end

	begin tran 
	if @artag2 = 'L'
		select @artag2 = '2'
	else
		select @artag2 = '1'
	//
	exec p_GetAccnt1 'HIS', @hno output
	insert guest (no,sta,name,class,country,nation,address,phone,fax,zip,comment,srqs,
			market,email,sno,crtby,crttime,cby,changed,logmark,liason)
		select @hno,'I',name,'C',nation,nation,isnull(address,''),isnull(phone,''),isnull(fax,''),isnull(zip,''),isnull(ref,''),isnull(srqs,''),
			isnull(mkt,''),isnull(intinfo,''),isnull(cardno,''),isnull(cby,''),changed,isnull(cby,''),changed,logmark,isnull(c_name,'')
			from v5..armst where accnt=@accnt

	insert master(accnt,haccnt,class,sta,sta_tm,ressta,market,artag1,artag2,ref,arr,dep,
			limit,bdate,cby,changed,charge,credit,lastnumb,lastinumb,logmark)
		select @accnt,@hno,'A',sta,sta_tm,ressta,isnull(mkt,''),isnull(tag0,''),@artag2,ref,isnull(arr,'1980/10/10'),isnull(dep,'2020.1.1'),
			limit,@bdate,isnull(cby,''),changed,rmb_db,depr_cr+addrmb,lastnumb,lastinumb,logmark
			from v5..armst where accnt=@accnt
	commit tran 

	fetch c_armst into @accnt, @artag2
end
close c_armst
deallocate cursor c_armst

// 转换armst_till
delete master_till where accnt like '[A]%'
//
select @bdate = bdate1 from sysdata

declare c_armst cursor for select accnt, class from v5..armst_till
open c_armst
fetch c_armst into @accnt, @artag2
while @@sqlstatus = 0
begin
	select @hno = ''
	select @hno = haccnt from master where accnt = @accnt
	if rtrim(@hno) is null
		begin
		if @artag2 = 'L'
			select @artag2 = '2'
		else
			select @artag2 = '1'
		exec p_GetAccnt1 'HIS', @hno output
		insert guest (no,sta,name,class,country,nation,address,phone,fax,zip,comment,srqs,
				market,email,sno,crtby,crttime,cby,changed,logmark,liason)
			select @hno,'I',name,'C',nation,nation,isnull(address,''),isnull(phone,''),isnull(fax,''),isnull(zip,''),isnull(ref,''),isnull(srqs,''),
				isnull(mkt,''),isnull(intinfo,''),isnull(cardno,''),isnull(cby,''),changed,isnull(cby,''),changed,logmark,isnull(c_name,'')
				from v5..armst_till where accnt=@accnt
		end
	insert master_till(accnt,haccnt,class,sta,sta_tm,ressta,market,artag1,artag2,ref,arr,dep,
			limit,bdate,cby,changed,charge,credit,lastnumb,lastinumb,logmark)
		select @accnt,@hno,'A',sta,sta_tm,ressta,isnull(mkt,''),isnull(tag0,''),@artag2,ref,isnull(arr,'1980/10/10'),isnull(dep,'2020.1.1'),
			limit,@bdate,isnull(cby,''),changed,rmb_db,depr_cr+addrmb,lastnumb,lastinumb,logmark
			from v5..armst_till where accnt=@accnt

	fetch c_armst into @accnt, @artag2
end
close c_armst
deallocate cursor c_armst

//// 转换armst_last
//delete master_last where accnt like '[A]%'
////
//select @bdate = bdate1 from sysdata
//
//declare c_armst cursor for select accnt, class from v5..armst_last
//open c_armst
//fetch c_armst into @accnt, @artag2
//while @@sqlstatus = 0
//begin
//	select @hno = ''
//	select @hno = haccnt from master where accnt = @accnt
//	if rtrim(@hno) is null
//		begin
//		if @artag2 = 'L'
//			select @artag2 = '2'
//		else
//			select @artag2 = '1'
//		exec p_GetAccnt1 'HIS', @hno output
//		insert guest (no,sta,name,class,country,nation,address,phone,fax,zip,comment,srqs,
//				market,email,sno,crtby,crttime,cby,changed,logmark,liason)
//			select @hno,'I',name,'C',nation,nation,isnull(address,''),isnull(phone,''),isnull(fax,''),isnull(zip,''),isnull(ref,''),isnull(srqs,''),
//				isnull(mkt,''),isnull(intinfo,''),isnull(cardno,''),isnull(cby,''),changed,isnull(cby,''),changed,logmark,isnull(c_name,'')
//				from v5..armst_last where accnt=@accnt
//		end
//	insert master_last(accnt,haccnt,class,sta,sta_tm,ressta,market,artag1,artag2,ref,arr,dep,
//			limit,bdate,cby,changed,charge,credit,lastnumb,lastinumb,logmark)
//		select @accnt,@hno,'A',sta,sta_tm,ressta,isnull(mkt,''),isnull(tag0,''),@artag2,ref,isnull(arr,'1980/10/10'),isnull(dep,'2020.1.1'),
//			limit,@bdate,isnull(cby,''),changed,rmb_db,depr_cr+addrmb,lastnumb,lastinumb,logmark
//			from v5..armst_last where accnt=@accnt
//
//	fetch c_armst into @accnt, artag2
//end
//close c_armst
//deallocate cursor c_armst
;


truncate table master;
truncate table master_des;
truncate table subaccnt;
exec p_v5_to_x5_master;
exec p_v5_to_x5_grpmst;
update master set groupno = isnull((select a.accnt from master a where master.groupno = substring(a.accnt, 3, 7)), groupno)
	where groupno <> '';
update master set addbed = 1 where addbed_rate != 0
update master set packages ='BF1;'+packages where accnt like 'F%' and charindex('S1',srqs)=0;
update master_till set groupno = isnull((select a.accnt from master_till a where master_till.groupno = substring(a.accnt, 3, 7)), groupno)
	where groupno <> '';
update master_till set addbed = 1 where addbed_rate != 0
update master_till set packages ='BF1;'+packages where accnt like 'F%' and charindex('S1',srqs)=0;
//update master_last set groupno = isnull((select a.accnt from master_last a where master_last.groupno = substring(a.accnt, 3, 7)), groupno)
//	where groupno <> '';
//update master_last set addbed = 1 where addbed_rate != 0
//update master_last set packages ='BF1;'+packages where accnt like 'F%' and charindex('S1',srqs)=0;
exec p_gds_armst_trans;
//
update account set accnt = a.accnt from master a where account.accnt = substring(a.accnt,3,7); 
update account set accntof = a.accnt from master a where account.accntof = substring(a.accnt,3,7); 
update account set accnt = 'C00' + substring(accnt, 1, 1) + substring(accnt, 5, 3)
	where accnt like '_95%'; 
update account set accntof = a.accnt from master a where account.accntof = substring(a.accnt,3,7); 
update account set accntof = 'C00' + substring(accntof, 1, 1) + substring(accntof, 5, 3)
	where accntof like '_95%'; 
//
update account set tag = a.market from master a where account.accnt = a.accnt and account.pccode > '9'; 
update account set tag = a.newcode from a_mktcode a where substring(account.tag, 2, 1) = a.code and account.pccode < '9'; 
//
truncate table grprate;
insert grprate select * from v5..grprate;
update grprate set accnt = a.accnt from master a where grprate.accnt=substring(a.accnt,3,7);
