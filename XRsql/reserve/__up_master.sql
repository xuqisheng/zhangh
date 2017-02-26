// 1. 
//exec sp_rename  master, a_master;
//exec sp_rename  master_till, a_master_till;
//exec sp_rename  master_last, a_master_last;
//exec sp_rename  master_del, a_master_del;
//exec sp_rename  master_middle, a_master_middle;
//exec sp_rename  master_log, a_master_log;
//exec sp_rename  hmaster, a_hmaster;


// 2. 
//  --- create new table 

// 3. 
//insert master SELECT accnt,haccnt,groupno,type,otype,up_type,up_reason,rmnum,ormnum,roomno,oroomno,bdate,sta,osta,ressta,exp_sta,
//	sta_tm,rmpoststa,rmposted,tag0,arr,dep,resdep,oarr,odep,agent,cusno,source,class,src,market,restype,channel,artag1,
//	artag2,share,gstno,children,rmreason,ratecode,packages,fixrate,rmrate,qtrate,setrate,rtreason,discount,discount1,
//	addbed,addbed_rate,crib,crib_rate,paycode,limit,credcode,credman,credunit,applname,applicant,araccnt,phone,fax,
//	email,wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,extra,charge,
//	credit,accredit,lastnumb,lastinumb,srqs,amenities,master,saccnt,pcrec,pcrec_pkg,resno,crsno,ref,comsg,card,
//	saleid,'','','',resby,restime,ciby,citime,coby,cotime,depby,deptime,cby,changed,exp_m1,exp_m2,
//	exp_dt1,exp_dt2,exp_s1,exp_s2,exp_s3,logmark  FROM a_master;
//
//insert master_till SELECT accnt,haccnt,groupno,type,otype,up_type,up_reason,rmnum,ormnum,roomno,oroomno,bdate,sta,osta,ressta,exp_sta,
//	sta_tm,rmpoststa,rmposted,tag0,arr,dep,resdep,oarr,odep,agent,cusno,source,class,src,market,restype,channel,artag1,
//	artag2,share,gstno,children,rmreason,ratecode,packages,fixrate,rmrate,qtrate,setrate,rtreason,discount,discount1,
//	addbed,addbed_rate,crib,crib_rate,paycode,limit,credcode,credman,credunit,applname,applicant,araccnt,phone,fax,
//	email,wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,extra,charge,
//	credit,accredit,lastnumb,lastinumb,srqs,amenities,master,saccnt,pcrec,pcrec_pkg,resno,crsno,ref,comsg,card,
//	saleid,'','','',resby,restime,ciby,citime,coby,cotime,depby,deptime,cby,changed,exp_m1,exp_m2,
//	exp_dt1,exp_dt2,exp_s1,exp_s2,exp_s3,logmark  FROM a_master_till;
//
//insert master_last SELECT accnt,haccnt,groupno,type,otype,up_type,up_reason,rmnum,ormnum,roomno,oroomno,bdate,sta,osta,ressta,exp_sta,
//	sta_tm,rmpoststa,rmposted,tag0,arr,dep,resdep,oarr,odep,agent,cusno,source,class,src,market,restype,channel,artag1,
//	artag2,share,gstno,children,rmreason,ratecode,packages,fixrate,rmrate,qtrate,setrate,rtreason,discount,discount1,
//	addbed,addbed_rate,crib,crib_rate,paycode,limit,credcode,credman,credunit,applname,applicant,araccnt,phone,fax,
//	email,wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,extra,charge,
//	credit,accredit,lastnumb,lastinumb,srqs,amenities,master,saccnt,pcrec,pcrec_pkg,resno,crsno,ref,comsg,card,
//	saleid,'','','',resby,restime,ciby,citime,coby,cotime,depby,deptime,cby,changed,exp_m1,exp_m2,
//	exp_dt1,exp_dt2,exp_s1,exp_s2,exp_s3,logmark  FROM a_master_last;
//
//insert master_log SELECT accnt,haccnt,groupno,type,otype,up_type,up_reason,rmnum,ormnum,roomno,oroomno,bdate,sta,osta,ressta,exp_sta,
//	sta_tm,rmpoststa,rmposted,tag0,arr,dep,resdep,oarr,odep,agent,cusno,source,class,src,market,restype,channel,artag1,
//	artag2,share,gstno,children,rmreason,ratecode,packages,fixrate,rmrate,qtrate,setrate,rtreason,discount,discount1,
//	addbed,addbed_rate,crib,crib_rate,paycode,limit,credcode,credman,credunit,applname,applicant,araccnt,phone,fax,
//	email,wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,extra,charge,
//	credit,accredit,lastnumb,lastinumb,srqs,amenities,master,saccnt,pcrec,pcrec_pkg,resno,crsno,ref,comsg,card,
//	saleid,'','','',resby,restime,ciby,citime,coby,cotime,depby,deptime,cby,changed,exp_m1,exp_m2,
//	exp_dt1,exp_dt2,exp_s1,exp_s2,exp_s3,logmark  FROM a_master_log;
//
//insert master_middle SELECT accnt,haccnt,groupno,type,otype,up_type,up_reason,rmnum,ormnum,roomno,oroomno,bdate,sta,osta,ressta,exp_sta,
//	sta_tm,rmpoststa,rmposted,tag0,arr,dep,resdep,oarr,odep,agent,cusno,source,class,src,market,restype,channel,artag1,
//	artag2,share,gstno,children,rmreason,ratecode,packages,fixrate,rmrate,qtrate,setrate,rtreason,discount,discount1,
//	addbed,addbed_rate,crib,crib_rate,paycode,limit,credcode,credman,credunit,applname,applicant,araccnt,phone,fax,
//	email,wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,extra,charge,
//	credit,accredit,lastnumb,lastinumb,srqs,amenities,master,saccnt,pcrec,pcrec_pkg,resno,crsno,ref,comsg,card,
//	saleid,'','','',resby,restime,ciby,citime,coby,cotime,depby,deptime,cby,changed,exp_m1,exp_m2,
//	exp_dt1,exp_dt2,exp_s1,exp_s2,exp_s3,logmark  FROM a_master_middle;
//
//insert master_del SELECT accnt,haccnt,groupno,type,otype,up_type,up_reason,rmnum,ormnum,roomno,oroomno,bdate,sta,osta,ressta,exp_sta,
//	sta_tm,rmpoststa,rmposted,tag0,arr,dep,resdep,oarr,odep,agent,cusno,source,class,src,market,restype,channel,artag1,
//	artag2,share,gstno,children,rmreason,ratecode,packages,fixrate,rmrate,qtrate,setrate,rtreason,discount,discount1,
//	addbed,addbed_rate,crib,crib_rate,paycode,limit,credcode,credman,credunit,applname,applicant,araccnt,phone,fax,
//	email,wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,extra,charge,
//	credit,accredit,lastnumb,lastinumb,srqs,amenities,master,saccnt,pcrec,pcrec_pkg,resno,crsno,ref,comsg,card,
//	saleid,'','','',resby,restime,ciby,citime,coby,cotime,depby,deptime,cby,changed,exp_m1,exp_m2,
//	exp_dt1,exp_dt2,exp_s1,exp_s2,exp_s3,logmark  FROM a_master_del;
//
//insert hmaster SELECT accnt,haccnt,groupno,type,otype,up_type,up_reason,rmnum,ormnum,roomno,oroomno,bdate,sta,osta,ressta,exp_sta,
//	sta_tm,rmpoststa,rmposted,tag0,arr,dep,resdep,oarr,odep,agent,cusno,source,class,src,market,restype,channel,artag1,
//	artag2,share,gstno,children,rmreason,ratecode,packages,fixrate,rmrate,qtrate,setrate,rtreason,discount,discount1,
//	addbed,addbed_rate,crib,crib_rate,paycode,limit,credcode,credman,credunit,applname,applicant,araccnt,phone,fax,
//	email,wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,extra,charge,
//	credit,accredit,lastnumb,lastinumb,srqs,amenities,master,saccnt,pcrec,pcrec_pkg,resno,crsno,ref,comsg,card,
//	saleid,'','','',resby,restime,ciby,citime,coby,cotime,depby,deptime,cby,changed,exp_m1,exp_m2,
//	exp_dt1,exp_dt2,exp_s1,exp_s2,exp_s3,logmark  FROM a_hmaster;

//
//
// 4. trigger 
//
//