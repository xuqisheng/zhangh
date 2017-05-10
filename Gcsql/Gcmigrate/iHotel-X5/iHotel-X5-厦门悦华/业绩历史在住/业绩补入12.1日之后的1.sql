	DELETE FROM production_detail WHERE hotel_group_id = 1 AND hotel_id = 1 AND biz_date = '2014.12.7';

	INSERT INTO production_detail(hotel_group_id,hotel_id,biz_date,master_type,accnt,master_id,grpaccnt,NAME,sta,
		rmtype,rmno,rmnum,arr,dep,adult,children,rack_rate,nego_rate,real_rate,dsc_reason,dsc_amount,
		guest_id,group_id,company_id,agent_id,source_id,member_type,member_no,card_id,salesman,
		src,market,rsv_type,channel,ratecode,cmscode,packages,is_today_arr,is_today_dep,
		nights,nights2,times_cxl,times_noshow,last_charge,last_pay,last_balance,
		production_rm,production_rm_svc,production_rm_bf,production_rm_cms,production_rm_lau,production_rm_pkg,
		production_fb,production_mt,production_en,production_sp,production_ot,production_ttl)
	SELECT 1,1,DATE,'master',accnt_id,master_id,groupno_id,'','I',
		'',roomno,1,t_arr,t_dep,gstno,0,0,0,0,'',0,
		haccnt_id,groupno_id,c_id,a_id,s_id,'',cardno,'',saleid,
		src,market,'',channel,'','','','F','F',
		i_days,i_days,x_times,n_times,0,0,0,
		rm,0,0,0,0,0,fb,0,en,sp,ot,ttl
	FROM migrate_xmyh.ycus_xf WHERE tag1 = 'A1' AND DATE <='2014.12.7' AND actcls='F' AND accnt LIKE 'F%';
	
	INSERT INTO production_detail(hotel_group_id,hotel_id,biz_date,master_type,accnt,master_id,grpaccnt,NAME,sta,
		rmtype,rmno,rmnum,arr,dep,adult,children,rack_rate,nego_rate,real_rate,dsc_reason,dsc_amount,
		guest_id,group_id,company_id,agent_id,source_id,member_type,member_no,card_id,salesman,
		src,market,rsv_type,channel,ratecode,cmscode,packages,is_today_arr,is_today_dep,
		nights,nights2,times_cxl,times_noshow,last_charge,last_pay,last_balance,
		production_rm,production_rm_svc,production_rm_bf,production_rm_cms,production_rm_lau,production_rm_pkg,
		production_fb,production_mt,production_en,production_sp,production_ot,production_ttl)
	SELECT 1,1,DATE,'master',accnt_id,master_id,groupno_id,'','I',
		'',roomno,1,t_arr,t_dep,gstno,0,0,0,0,'',0,
		haccnt_id,groupno_id,c_id,a_id,s_id,'',cardno,'',saleid,
		src,market,'',channel,'','','','F','F',
		i_days,i_days,x_times,n_times,0,0,0,
		rm,0,0,0,0,0,fb,0,en,sp,ot,ttl
	FROM migrate_xmyh.ycus_xf WHERE tag1 = 'A1' AND DATE <='2014.12.7' AND  actcls='F' AND accnt LIKE 'G%';

	INSERT INTO production_detail(hotel_group_id,hotel_id,biz_date,master_type,accnt,master_id,grpaccnt,NAME,sta,
		rmtype,rmno,rmnum,arr,dep,adult,children,rack_rate,nego_rate,real_rate,dsc_reason,dsc_amount,
		guest_id,group_id,company_id,agent_id,source_id,member_type,member_no,card_id,salesman,
		src,market,rsv_type,channel,ratecode,cmscode,packages,is_today_arr,is_today_dep,
		nights,nights2,times_cxl,times_noshow,last_charge,last_pay,last_balance,
		production_rm,production_rm_svc,production_rm_bf,production_rm_cms,production_rm_lau,production_rm_pkg,
		production_fb,production_mt,production_en,production_sp,production_ot,production_ttl)
	SELECT 1,1,DATE,'master',accnt_id,master_id,groupno_id,'','I',
		'',roomno,1,t_arr,t_dep,gstno,0,0,0,0,'',0,
		haccnt_id,groupno_id,c_id,a_id,s_id,'',cardno,'',saleid,
		src,market,'',channel,'','','','F','F',
		i_days,i_days,x_times,n_times,0,0,0,
		rm,0,0,0,0,0,fb,0,en,sp,ot,ttl
	FROM migrate_xmyh.ycus_xf WHERE tag1 = 'A1' AND DATE <='2014.12.7' AND  actcls='F' AND accnt LIKE 'M%';	
	
	-- master_type = 'armaster'
	INSERT INTO production_detail(hotel_group_id,hotel_id,biz_date,master_type,accnt,master_id,grpaccnt,NAME,sta,
		rmtype,rmno,rmnum,arr,dep,adult,children,rack_rate,nego_rate,real_rate,dsc_reason,dsc_amount,
		guest_id,group_id,company_id,agent_id,source_id,member_type,member_no,card_id,salesman,
		src,market,rsv_type,channel,ratecode,cmscode,packages,is_today_arr,is_today_dep,
		nights,nights2,times_cxl,times_noshow,last_charge,last_pay,last_balance,
		production_rm,production_rm_svc,production_rm_bf,production_rm_cms,production_rm_lau,production_rm_pkg,
		production_fb,production_mt,production_en,production_sp,production_ot,production_ttl)
	SELECT 1,1,DATE,'armaster',accnt_id,master_id,groupno_id,'','I',
		'',roomno,1,t_arr,t_dep,gstno,0,0,0,0,'',0,
		haccnt_id,groupno_id,c_id,a_id,s_id,'',cardno,'',saleid,
		src,market,'',channel,'','','','F','F',
		i_days,i_days,x_times,n_times,0,0,0,
		rm,0,0,0,0,0,fb,0,en,sp,ot,ttl
	FROM migrate_xmyh.ycus_xf WHERE tag1 = 'A1' AND DATE <='2014.12.7' AND actcls='F' AND accnt LIKE 'AR%';
	
	-- master_type = 'consume'
	INSERT INTO production_detail(hotel_group_id,hotel_id,biz_date,master_type,accnt,master_id,grpaccnt,NAME,sta,
		rmtype,rmno,rmnum,arr,dep,adult,children,rack_rate,nego_rate,real_rate,dsc_reason,dsc_amount,
		guest_id,group_id,company_id,agent_id,source_id,member_type,member_no,card_id,salesman,
		src,market,rsv_type,channel,ratecode,cmscode,packages,is_today_arr,is_today_dep,
		nights,nights2,times_cxl,times_noshow,last_charge,last_pay,last_balance,
		production_rm,production_rm_svc,production_rm_bf,production_rm_cms,production_rm_lau,production_rm_pkg,
		production_fb,production_mt,production_en,production_sp,production_ot,production_ttl)
	SELECT 1,1,DATE,'consume',accnt_id,master_id,groupno_id,'','I',
		'',roomno,1,t_arr,t_dep,gstno,0,0,0,0,'',0,
		haccnt_id,groupno_id,c_id,a_id,s_id,'',cardno,'',saleid,
		src,market,'',channel,'','','','F','F',
		i_days,i_days,x_times,n_times,0,0,0,
		rm,0,0,0,0,0,fb,0,en,sp,ot,ttl
	FROM migrate_xmyh.ycus_xf WHERE tag1 = 'A1' AND DATE <='2014.12.7' AND actcls='F' AND accnt LIKE 'C%';
	
	-- master_type = 'pos'
	INSERT INTO production_detail(hotel_group_id,hotel_id,biz_date,master_type,accnt,master_id,grpaccnt,NAME,sta,
		rmtype,rmno,rmnum,arr,dep,adult,children,rack_rate,nego_rate,real_rate,dsc_reason,dsc_amount,
		guest_id,group_id,company_id,agent_id,source_id,member_type,member_no,card_id,salesman,
		src,market,rsv_type,channel,ratecode,cmscode,packages,is_today_arr,is_today_dep,
		nights,nights2,times_cxl,times_noshow,last_charge,last_pay,last_balance,
		production_rm,production_rm_svc,production_rm_bf,production_rm_cms,production_rm_lau,production_rm_pkg,
		production_fb,production_mt,production_en,production_sp,production_ot,production_ttl)
	SELECT 1,1,DATE,'pos',accnt_id,master_id,groupno_id,'','I',
		'',roomno,1,t_arr,t_dep,gstno,0,0,0,0,'',0,
		haccnt_id,groupno_id,c_id,a_id,s_id,'',cardno,'',saleid,
		src,market,'',channel,'','','','F','F',
		i_days,i_days,x_times,n_times,0,0,0,
		rm,0,0,0,0,0,fb,0,en,sp,ot,ttl
	FROM migrate_xmyh.ycus_xf WHERE tag1 = 'A1' AND DATE <='2014.12.7' AND actcls='P';