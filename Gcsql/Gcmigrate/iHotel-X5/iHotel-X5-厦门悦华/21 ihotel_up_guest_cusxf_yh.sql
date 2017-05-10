DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_guest_cusxf_yh`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_guest_cusxf_yh`(
	arg_hotel_group_id	BIGINT(16),
	arg_hotel_id		BIGINT(16)
)
SQL SECURITY INVOKER
label_0:
BEGIN
	/*
	
	SELECT * FROM migrate_xmyh.ycus_xf a WHERE NOT EXISTS(SELECT 1 FROM migrate_xmyh.hmaster b WHERE a.accnt=b.accnt)
AND a.accnt NOT LIKE 'AR%'
	*/


	DELETE FROM up_status WHERE hotel_id=arg_hotel_id AND up_step='CUSXF';
	INSERT INTO up_status(hotel_id,up_step,time_begin,time_end,time_long,remark) VALUES(arg_hotel_id,'CUSXF',NOW(),NULL,0,''); 
	/*
	ALTER TABLE migrate_xmyh.ycus_xf ADD c_id BIGINT(16);
	ALTER TABLE migrate_xmyh.ycus_xf ADD a_id BIGINT(16);
	ALTER TABLE migrate_xmyh.ycus_xf ADD s_id BIGINT(16);
	ALTER TABLE migrate_xmyh.ycus_xf ADD accnt_id BIGINT(16);
	ALTER TABLE migrate_xmyh.ycus_xf ADD groupno_id BIGINT(16);
	ALTER TABLE migrate_xmyh.ycus_xf ADD haccnt_id BIGINT(16);
	ALTER TABLE migrate_xmyh.ycus_xf ADD master_id BIGINT(16);	
	CREATE INDEX cusno 	ON migrate_xmyh.ycus_xf(cusno);
	CREATE INDEX agent 	ON migrate_xmyh.ycus_xf(agent);
	CREATE INDEX source ON migrate_xmyh.ycus_xf(source);
	CREATE INDEX accnt 	ON migrate_xmyh.ycus_xf(accnt);	
	CREATE INDEX haccnt ON migrate_xmyh.ycus_xf(haccnt);
	CREATE INDEX master ON migrate_xmyh.ycus_xf(master);
	CREATE INDEX saleid ON migrate_xmyh.ycus_xf(saleid);
	CREATE INDEX groupno ON migrate_xmyh.ycus_xf(groupno);
	
	UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.c_id=b.accnt_new 		WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.actcls='F' AND a.cusno=b.accnt_old 		AND b.accnt_type='COMPANY';   -- 协议公司。 
	UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.a_id=b.accnt_new 		WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.actcls='F' AND a.agent=b.accnt_old 		AND b.accnt_type='COMPANY';   -- 旅行社。 
	UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.s_id=b.accnt_new 		WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.actcls='F' AND a.source=b.accnt_old 	AND b.accnt_type='COMPANY';  -- 订房中心。  
	UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.haccnt_id=b.accnt_new 	WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.actcls='F' AND a.haccnt=b.accnt_old 	AND b.accnt_type='GUEST_FIT';
	UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.haccnt_id=b.accnt_new 	WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.actcls='F' AND a.haccnt=b.accnt_old 	AND b.accnt_type='GUEST_GRP';	
	UPDATE migrate_xmyh.ycus_xf a,up_map_code b  SET a.src = b.code_new 	 	WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.actcls='F' AND a.src = b.code_old 		AND b.cat = 'srccode';
	UPDATE migrate_xmyh.ycus_xf a,up_map_code b  SET a.market = b.code_new  	WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.actcls='F' AND a.market = b.code_old 	AND b.cat = 'mktcode';
	UPDATE migrate_xmyh.ycus_xf a,up_map_code b  SET a.channel = b.code_new 	WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.actcls='F' AND a.channel = b.code_old 	AND b.cat = 'channel';
	UPDATE migrate_xmyh.ycus_xf a,up_map_code b  SET a.saleid = b.code_new 	WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.actcls='F' AND a.saleid = b.code_old 	AND b.cat = 'salesman';
	*/
	
	UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.accnt_id=b.accnt_new 	WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.actcls='F' AND a.accnt=b.accnt_old 		AND b.accnt_type='HMASTER';  
	UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.groupno_id=b.accnt_new WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.actcls='F' AND a.groupno=b.accnt_old 	AND b.accnt_type='HMASTER'; 
	UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.master_id=b.accnt_new 	WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.actcls='F' AND a.master=b.accnt_old 	AND b.accnt_type='HMASTER';
	
	UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.accnt_id=b.accnt_new 	WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.actcls='F' AND a.accnt=b.accnt_old 		AND b.accnt_type IN ('master_r','master_si','consume');  
	UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.groupno_id=b.accnt_new WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.actcls='F' AND a.groupno=b.accnt_old 	AND b.accnt_type IN ('master_r','master_si','consume');  
	UPDATE migrate_xmyh.ycus_xf a,up_map_accnt b SET a.master_id=b.accnt_new 	WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.actcls='F' AND a.master=b.accnt_old 	AND b.accnt_type IN ('master_r','master_si','consume');  
	-- master_type = 'master'
	INSERT INTO production_detail(hotel_group_id,hotel_id,biz_date,master_type,accnt,master_id,grpaccnt,NAME,sta,
		rmtype,rmno,rmnum,arr,dep,adult,children,rack_rate,nego_rate,real_rate,dsc_reason,dsc_amount,
		guest_id,group_id,company_id,agent_id,source_id,member_type,member_no,card_id,salesman,
		src,market,rsv_type,channel,ratecode,cmscode,packages,is_today_arr,is_today_dep,
		nights,nights2,times_cxl,times_noshow,last_charge,last_pay,last_balance,
		production_rm,production_rm_svc,production_rm_bf,production_rm_cms,production_rm_lau,production_rm_pkg,
		production_fb,production_mt,production_en,production_sp,production_ot,production_ttl)
	SELECT arg_hotel_group_id,arg_hotel_id,DATE,'master',accnt_id,master_id,groupno_id,'','I',
		'',roomno,1,t_arr,t_dep,gstno,0,0,0,0,'',0,
		haccnt_id,groupno_id,c_id,a_id,s_id,'',cardno,'',saleid,
		src,market,'',channel,'','','','F','F',
		i_days,i_days,x_times,n_times,0,0,0,
		rm,0,0,0,0,0,fb,0,en,sp,ot,ttl
	FROM migrate_xmyh.ycus_xf WHERE actcls='F' AND accnt LIKE 'F%';
	
	INSERT INTO production_detail(hotel_group_id,hotel_id,biz_date,master_type,accnt,master_id,grpaccnt,NAME,sta,
		rmtype,rmno,rmnum,arr,dep,adult,children,rack_rate,nego_rate,real_rate,dsc_reason,dsc_amount,
		guest_id,group_id,company_id,agent_id,source_id,member_type,member_no,card_id,salesman,
		src,market,rsv_type,channel,ratecode,cmscode,packages,is_today_arr,is_today_dep,
		nights,nights2,times_cxl,times_noshow,last_charge,last_pay,last_balance,
		production_rm,production_rm_svc,production_rm_bf,production_rm_cms,production_rm_lau,production_rm_pkg,
		production_fb,production_mt,production_en,production_sp,production_ot,production_ttl)
	SELECT arg_hotel_group_id,arg_hotel_id,DATE,'master',accnt_id,master_id,groupno_id,'','I',
		'',roomno,1,t_arr,t_dep,gstno,0,0,0,0,'',0,
		haccnt_id,groupno_id,c_id,a_id,s_id,'',cardno,'',saleid,
		src,market,'',channel,'','','','F','F',
		i_days,i_days,x_times,n_times,0,0,0,
		rm,0,0,0,0,0,fb,0,en,sp,ot,ttl
	FROM migrate_xmyh.ycus_xf WHERE actcls='F' AND accnt LIKE 'G%';

	INSERT INTO production_detail(hotel_group_id,hotel_id,biz_date,master_type,accnt,master_id,grpaccnt,NAME,sta,
		rmtype,rmno,rmnum,arr,dep,adult,children,rack_rate,nego_rate,real_rate,dsc_reason,dsc_amount,
		guest_id,group_id,company_id,agent_id,source_id,member_type,member_no,card_id,salesman,
		src,market,rsv_type,channel,ratecode,cmscode,packages,is_today_arr,is_today_dep,
		nights,nights2,times_cxl,times_noshow,last_charge,last_pay,last_balance,
		production_rm,production_rm_svc,production_rm_bf,production_rm_cms,production_rm_lau,production_rm_pkg,
		production_fb,production_mt,production_en,production_sp,production_ot,production_ttl)
	SELECT arg_hotel_group_id,arg_hotel_id,DATE,'master',accnt_id,master_id,groupno_id,'','I',
		'',roomno,1,t_arr,t_dep,gstno,0,0,0,0,'',0,
		haccnt_id,groupno_id,c_id,a_id,s_id,'',cardno,'',saleid,
		src,market,'',channel,'','','','F','F',
		i_days,i_days,x_times,n_times,0,0,0,
		rm,0,0,0,0,0,fb,0,en,sp,ot,ttl
	FROM migrate_xmyh.ycus_xf WHERE actcls='F' AND accnt LIKE 'M%';	
	
	-- master_type = 'armaster'
	INSERT INTO production_detail(hotel_group_id,hotel_id,biz_date,master_type,accnt,master_id,grpaccnt,NAME,sta,
		rmtype,rmno,rmnum,arr,dep,adult,children,rack_rate,nego_rate,real_rate,dsc_reason,dsc_amount,
		guest_id,group_id,company_id,agent_id,source_id,member_type,member_no,card_id,salesman,
		src,market,rsv_type,channel,ratecode,cmscode,packages,is_today_arr,is_today_dep,
		nights,nights2,times_cxl,times_noshow,last_charge,last_pay,last_balance,
		production_rm,production_rm_svc,production_rm_bf,production_rm_cms,production_rm_lau,production_rm_pkg,
		production_fb,production_mt,production_en,production_sp,production_ot,production_ttl)
	SELECT arg_hotel_group_id,arg_hotel_id,DATE,'armaster',accnt_id,master_id,groupno_id,'','I',
		'',roomno,1,t_arr,t_dep,gstno,0,0,0,0,'',0,
		haccnt_id,groupno_id,c_id,a_id,s_id,'',cardno,'',saleid,
		src,market,'',channel,'','','','F','F',
		i_days,i_days,x_times,n_times,0,0,0,
		rm,0,0,0,0,0,fb,0,en,sp,ot,ttl
	FROM migrate_xmyh.ycus_xf WHERE actcls='F' AND accnt LIKE 'AR%';
	
	-- master_type = 'consume'
	INSERT INTO production_detail(hotel_group_id,hotel_id,biz_date,master_type,accnt,master_id,grpaccnt,NAME,sta,
		rmtype,rmno,rmnum,arr,dep,adult,children,rack_rate,nego_rate,real_rate,dsc_reason,dsc_amount,
		guest_id,group_id,company_id,agent_id,source_id,member_type,member_no,card_id,salesman,
		src,market,rsv_type,channel,ratecode,cmscode,packages,is_today_arr,is_today_dep,
		nights,nights2,times_cxl,times_noshow,last_charge,last_pay,last_balance,
		production_rm,production_rm_svc,production_rm_bf,production_rm_cms,production_rm_lau,production_rm_pkg,
		production_fb,production_mt,production_en,production_sp,production_ot,production_ttl)
	SELECT arg_hotel_group_id,arg_hotel_id,DATE,'consume',accnt_id,master_id,groupno_id,'','I',
		'',roomno,1,t_arr,t_dep,gstno,0,0,0,0,'',0,
		haccnt_id,groupno_id,c_id,a_id,s_id,'',cardno,'',saleid,
		src,market,'',channel,'','','','F','F',
		i_days,i_days,x_times,n_times,0,0,0,
		rm,0,0,0,0,0,fb,0,en,sp,ot,ttl
	FROM migrate_xmyh.ycus_xf WHERE actcls='F' AND accnt LIKE 'C%';
	
	-- master_type = 'pos'
	INSERT INTO production_detail(hotel_group_id,hotel_id,biz_date,master_type,accnt,master_id,grpaccnt,NAME,sta,
		rmtype,rmno,rmnum,arr,dep,adult,children,rack_rate,nego_rate,real_rate,dsc_reason,dsc_amount,
		guest_id,group_id,company_id,agent_id,source_id,member_type,member_no,card_id,salesman,
		src,market,rsv_type,channel,ratecode,cmscode,packages,is_today_arr,is_today_dep,
		nights,nights2,times_cxl,times_noshow,last_charge,last_pay,last_balance,
		production_rm,production_rm_svc,production_rm_bf,production_rm_cms,production_rm_lau,production_rm_pkg,
		production_fb,production_mt,production_en,production_sp,production_ot,production_ttl)
	SELECT arg_hotel_group_id,arg_hotel_id,DATE,'pos',accnt_id,master_id,groupno_id,'','I',
		'',roomno,1,t_arr,t_dep,gstno,0,0,0,0,'',0,
		haccnt_id,groupno_id,c_id,a_id,s_id,'',cardno,'',saleid,
		src,market,'',channel,'','','','F','F',
		i_days,i_days,x_times,n_times,0,0,0,
		rm,0,0,0,0,0,fb,0,en,sp,ot,ttl
	FROM migrate_xmyh.ycus_xf WHERE actcls='P';

	UPDATE production_detail SET grpaccnt=0 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND grpaccnt IS NULL;
	UPDATE production_detail SET group_id=0 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND group_id IS NULL;
	UPDATE production_detail SET company_id=0 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND company_id IS NULL;
	UPDATE production_detail SET agent_id=0 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND agent_id IS NULL;
	UPDATE production_detail SET source_id=0 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND source_id IS NULL;
		
	UPDATE production_detail a,master_base_history b SET a.arr=b.arr,a.dep=b.dep,a.rmtype=b.rmtype
	WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id
	AND a.accnt=b.id AND a.biz_date<='2014-02-27';

	UPDATE production_detail a,master_guest_history b SET a.name=b.name
	WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id
	AND a.accnt=b.id AND a.biz_date<='2014-02-27';
	
	UPDATE production_detail a,master_base b SET a.arr=b.arr,a.dep=b.dep,a.rmtype=b.rmtype
	WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id
	AND a.accnt=b.id AND a.biz_date<='2014-02-27';

	UPDATE production_detail a,master_guest b SET a.name=b.name
	WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id
	AND a.accnt=b.id AND a.biz_date<='2014-02-27';	
			
	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='CUSXF';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='CUSXF';
		
END$$

DELIMITER ;