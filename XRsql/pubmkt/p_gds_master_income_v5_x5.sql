////================================================================================
////	 v5:hmaster_income ---->  x5:master_income / ycus_xf
////================================================================================
//if  exists(select * from sysobjects where name = "p_gds_master_income_v5_x5")
//	drop proc p_gds_master_income_v5_x5;
//create proc p_gds_master_income_v5_x5
//as
//;
//

// 1 -- ycus_xf 
//insert ycus_xf(date,actcls,accnt,saleid,gstno,i_days,rm,fb,en,sp,ot,ttl,zc)
//  SELECT dep, 'F', 'F0'+accnt+'0',sta,gstno,days,rm,fb,en,0,ot,tl,99
//    FROM v5..hmaster_income;
//
// select * from ycus_xf where zc=99 and haccnt<>'';

//update ycus_xf set x_times=1 where zc=99 and saleid='X';
//update ycus_xf set n_times=1 where zc=99 and saleid='N';
//update ycus_xf set saleid='' where zc=99;

//update ycus_xf set haccnt=a.haccnt, cusno=a.cusno, agent=a.agent, source=a.source, 
//	market=a.market, src=a.src, channel=a.channel, saleid=a.saleid
// from hmaster a where ycus_xf.accnt=a.accnt and ycus_xf.actcls='F' and ycus_xf.zc=99;
//

// 2- master_income


//insert master_income select 'F0'+accnt+'0', 'rm', '', rm, days 
//	from v5..hmaster_income where rm>0;
//insert master_income select 'F0'+accnt+'0', 'fb', '', fb, 1
//	from v5..hmaster_income where fb>0;
//insert master_income select 'F0'+accnt+'0', 'en', '', en, 1
//	from v5..hmaster_income where en>0;
//insert master_income select 'F0'+accnt+'0', 'ot', '', ot, 1
//	from v5..hmaster_income where ot>0;
//
//insert master_income select 'F0'+accnt+'0', '', 'I_GUESTS', gstno, 1
//	from v5..hmaster_income where rm>0;
//insert master_income select 'F0'+accnt+'0', '', 'N_TIMES', 1, 1
//	from v5..hmaster_income where sta='N';
//insert master_income select 'F0'+accnt+'0', '', 'X_TIMES', 1, 1
//	from v5..hmaster_income where sta='X';
//
