
// sc_maser 增加 blockcode 和一些预留字段，blkcode 含义改变

// 1. 
//exec sp_rename  sc_master, a_sc_master;
//exec sp_rename  sc_master_till, a_sc_master_till;
//exec sp_rename  sc_master_last, a_sc_master_last;
//exec sp_rename  sc_master_del, a_sc_master_del;
//exec sp_rename  sc_master_log, a_sc_master_log;
//exec sp_rename  sc_hmaster, a_sc_hmaster;


// 2. 
//  --- create new table 

// 3. 
//insert sc_master 
//	SELECT accnt,foact,haccnt,type,otype,rmnum,roomno,oroomno,bdate,sta,osta,sta_tm,tag0,arr,dep,oarr,odep,agent,cusno,source,
//	class,src,market,restype,channel,gstno,children,ratecode,packages,setrate,paycode,limit,credcode,credman,credunit,araccnt,
//	wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,extra,charge,credit,accredit,lastnumb,
//	lastinumb,srqs,amenities,master,saccnt,'',pcrec,pcrec_pkg,resno,crsno,ref,comsg,saleid,cmscode,cardcode,cardno,contact,name,
//	name2,isnull(blkcode,''),status,btype,bscope,potential,saleid2,peakrms,avrate,cutoff,follow,decision,rmlistdate,currency,tracecode,
//	triggers,porterage,ptgrate,breakfast,bfrate,bfdes,c_status,c_attendees,c_guaranteed,c_infoboard,c_follow,c_decision,c_function,
//	c_contract,c_detailok,c_distributed,c_saleid,resby,restime,defby,deftime,tfby,tftime,coby,cotime,depby,deptime,cby,changed,exp_m1,
//	exp_m2,0,0,exp_dt1,exp_dt2,null,null,exp_s1,exp_s2,exp_s3,null,null,null,logmark  FROM a_sc_master  ;
//update sc_master set foact='SS' where foact='';
//update sc_master set foact='SF' where foact<>'';
//
//insert sc_master_till 
//	SELECT accnt,foact,haccnt,type,otype,rmnum,roomno,oroomno,bdate,sta,osta,sta_tm,tag0,arr,dep,oarr,odep,agent,cusno,source,
//	class,src,market,restype,channel,gstno,children,ratecode,packages,setrate,paycode,limit,credcode,credman,credunit,araccnt,
//	wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,extra,charge,credit,accredit,lastnumb,
//	lastinumb,srqs,amenities,master,saccnt,'',pcrec,pcrec_pkg,resno,crsno,ref,comsg,saleid,cmscode,cardcode,cardno,contact,name,
//	name2,isnull(blkcode,''),status,btype,bscope,potential,saleid2,peakrms,avrate,cutoff,follow,decision,rmlistdate,currency,tracecode,
//	triggers,porterage,ptgrate,breakfast,bfrate,bfdes,c_status,c_attendees,c_guaranteed,c_infoboard,c_follow,c_decision,c_function,
//	c_contract,c_detailok,c_distributed,c_saleid,resby,restime,defby,deftime,tfby,tftime,coby,cotime,depby,deptime,cby,changed,exp_m1,
//	exp_m2,0,0,exp_dt1,exp_dt2,null,null,exp_s1,exp_s2,exp_s3,null,null,null,logmark  FROM a_sc_master_till  ;
//update sc_master_till set foact='SS' where foact='';
//update sc_master_till set foact='SF' where foact<>'';
//
//insert sc_master_last 
//	SELECT accnt,foact,haccnt,type,otype,rmnum,roomno,oroomno,bdate,sta,osta,sta_tm,tag0,arr,dep,oarr,odep,agent,cusno,source,
//	class,src,market,restype,channel,gstno,children,ratecode,packages,setrate,paycode,limit,credcode,credman,credunit,araccnt,
//	wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,extra,charge,credit,accredit,lastnumb,
//	lastinumb,srqs,amenities,master,saccnt,'',pcrec,pcrec_pkg,resno,crsno,ref,comsg,saleid,cmscode,cardcode,cardno,contact,name,
//	name2,isnull(blkcode,''),status,btype,bscope,potential,saleid2,peakrms,avrate,cutoff,follow,decision,rmlistdate,currency,tracecode,
//	triggers,porterage,ptgrate,breakfast,bfrate,bfdes,c_status,c_attendees,c_guaranteed,c_infoboard,c_follow,c_decision,c_function,
//	c_contract,c_detailok,c_distributed,c_saleid,resby,restime,defby,deftime,tfby,tftime,coby,cotime,depby,deptime,cby,changed,exp_m1,
//	exp_m2,0,0,exp_dt1,exp_dt2,null,null,exp_s1,exp_s2,exp_s3,null,null,null,logmark  FROM a_sc_master_last  ;
//update sc_master_last set foact='SS' where foact='';
//update sc_master_last set foact='SF' where foact<>'';
//
//
//insert sc_master_del 
//	SELECT accnt,foact,haccnt,type,otype,rmnum,roomno,oroomno,bdate,sta,osta,sta_tm,tag0,arr,dep,oarr,odep,agent,cusno,source,
//	class,src,market,restype,channel,gstno,children,ratecode,packages,setrate,paycode,limit,credcode,credman,credunit,araccnt,
//	wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,extra,charge,credit,accredit,lastnumb,
//	lastinumb,srqs,amenities,master,saccnt,'',pcrec,pcrec_pkg,resno,crsno,ref,comsg,saleid,cmscode,cardcode,cardno,contact,name,
//	name2,isnull(blkcode,''),status,btype,bscope,potential,saleid2,peakrms,avrate,cutoff,follow,decision,rmlistdate,currency,tracecode,
//	triggers,porterage,ptgrate,breakfast,bfrate,bfdes,c_status,c_attendees,c_guaranteed,c_infoboard,c_follow,c_decision,c_function,
//	c_contract,c_detailok,c_distributed,c_saleid,resby,restime,defby,deftime,tfby,tftime,coby,cotime,depby,deptime,cby,changed,exp_m1,
//	exp_m2,0,0,exp_dt1,exp_dt2,null,null,exp_s1,exp_s2,exp_s3,null,null,null,logmark  FROM a_sc_master_del  ;
//update sc_master_del set foact='SS' where foact='';
//update sc_master_del set foact='SF' where foact<>'';
//
//
//insert sc_master_log 
//	SELECT accnt,foact,haccnt,type,otype,rmnum,roomno,oroomno,bdate,sta,osta,sta_tm,tag0,arr,dep,oarr,odep,agent,cusno,source,
//	class,src,market,restype,channel,gstno,children,ratecode,packages,setrate,paycode,limit,credcode,credman,credunit,araccnt,
//	wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,extra,charge,credit,accredit,lastnumb,
//	lastinumb,srqs,amenities,master,saccnt,'',pcrec,pcrec_pkg,resno,crsno,ref,comsg,saleid,cmscode,cardcode,cardno,contact,name,
//	name2,isnull(blkcode,''),status,btype,bscope,potential,saleid2,peakrms,avrate,cutoff,follow,decision,rmlistdate,currency,tracecode,
//	triggers,porterage,ptgrate,breakfast,bfrate,bfdes,c_status,c_attendees,c_guaranteed,c_infoboard,c_follow,c_decision,c_function,
//	c_contract,c_detailok,c_distributed,c_saleid,resby,restime,defby,deftime,tfby,tftime,coby,cotime,depby,deptime,cby,changed,exp_m1,
//	exp_m2,0,0,exp_dt1,exp_dt2,null,null,exp_s1,exp_s2,exp_s3,null,null,null,logmark  FROM a_sc_master_log  ;
//update sc_master_log set foact='SS' where foact='';
//update sc_master_log set foact='SF' where foact<>'';
//
//
//insert sc_hmaster 
//	SELECT accnt,foact,haccnt,type,otype,rmnum,roomno,oroomno,bdate,sta,osta,sta_tm,tag0,arr,dep,oarr,odep,agent,cusno,source,
//	class,src,market,restype,channel,gstno,children,ratecode,packages,setrate,paycode,limit,credcode,credman,credunit,araccnt,
//	wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,extra,charge,credit,accredit,lastnumb,
//	lastinumb,srqs,amenities,master,saccnt,'',pcrec,pcrec_pkg,resno,crsno,ref,comsg,saleid,cmscode,cardcode,cardno,contact,name,
//	name2,isnull(blkcode,''),status,btype,bscope,potential,saleid2,peakrms,avrate,cutoff,follow,decision,rmlistdate,currency,tracecode,
//	triggers,porterage,ptgrate,breakfast,bfrate,bfdes,c_status,c_attendees,c_guaranteed,c_infoboard,c_follow,c_decision,c_function,
//	c_contract,c_detailok,c_distributed,c_saleid,resby,restime,defby,deftime,tfby,tftime,coby,cotime,depby,deptime,cby,changed,exp_m1,
//	exp_m2,0,0,exp_dt1,exp_dt2,null,null,exp_s1,exp_s2,exp_s3,null,null,null,logmark  FROM a_sc_hmaster  ;
//update sc_hmaster set foact='SS' where foact='';
//update sc_hmaster set foact='SF' where foact<>'';



// 3-add. 
//update sc_master set class='B',accnt=stuff(accnt,1,1,'B') ;
//update sc_master_till set class='B',accnt=stuff(accnt,1,1,'B') ;
//update sc_master_last set class='B',accnt=stuff(accnt,1,1,'B') ;
//update sc_master_log set class='B',accnt=stuff(accnt,1,1,'B') ;
//update sc_master_del set class='B',accnt=stuff(accnt,1,1,'B') ;
//update sc_hmaster set class='B',accnt=stuff(accnt,1,1,'B') ;
//
// 对于已经转移到前台的，需要仔细替换 
// ??? 




// 4. trigger 
//
//


// 5. drop table a_* 



