DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_master_history_x5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_master_history_x5`(
	IN arg_hotel_group_id INT,
	IN arg_hotel_id INT
)
label_0:
BEGIN
	-- ====================================================================================
	-- Smart,X历史散客入住记录迁移等
	-- 特别注意,不支持错误中断后,继续执行.一旦错误，就重新load 数据库，重新做
	-- 增加索引 
	-- 	migrate_db.hmaster:cusno; accnt+class+sta; 
	--  message:accnt+type
	--  hguest:logmark; haccnt;accnt+guestid 
	--  hguest_income: logmark, 
	--  特别注意:执行之后，需要手动执行:./idcheck fix
	
	-- ====================================================================================
	DECLARE var_int 		INT;
	DECLARE var_whereto 	VARCHAR(10); 
	DECLARE var_rsv_type 	VARCHAR(10);
	DECLARE var_channel 	VARCHAR(10);
	DECLARE	var_bigint 		BIGINT(16);
	DECLARE	var_bigint1 	BIGINT(16);
	-- ------------------------------------------------------------
	-- 相关代码更新 在中间库hmaster 表中新添加c_id,a_id,s_id字段
	-- ------------------------------------------------------------
	
	DELETE FROM up_map_accnt WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type='HMASTER';
	/*
	ALTER TABLE migrate_db.hmaster ADD c_id BIGINT(16);
	ALTER TABLE migrate_db.hmaster ADD a_id BIGINT(16);
	ALTER TABLE migrate_db.hmaster ADD s_id BIGINT(16);
	ALTER TABLE migrate_db.hmaster ADD h_id BIGINT(16);
	ALTER TABLE migrate_db.hmaster ADD m_id BIGINT(16);
	ALTER TABLE migrate_db.hmaster ADD l_id BIGINT(16);
	ALTER TABLE migrate_db.hmaster ADD new_id BIGINT(16);
	*/
	/*
	CREATE INDEX cusno 	ON migrate_db.hmaster(cusno);
	CREATE INDEX agent 	ON migrate_db.hmaster(agent);
	CREATE INDEX source ON migrate_db.hmaster(source);
	CREATE INDEX accnt 	ON migrate_db.hmaster(accnt);
	CREATE INDEX haccnt ON migrate_db.hmaster(haccnt);
	CREATE INDEX master ON migrate_db.hmaster(master);
	CREATE INDEX pcrec 	ON migrate_db.hmaster(pcrec);
	CREATE INDEX logmark ON migrate_db.hmaster(logmark);
	*/
	/*
	UPDATE migrate_db.hmaster a,up_map_accnt b SET a.c_id=b.accnt_new WHERE a.cusno=b.accnt_old AND b.accnt_type='COMPANY' AND b.hotel_id=arg_hotel_id AND b.accnt_class='C';   -- 协议公司 
	UPDATE migrate_db.hmaster a,up_map_accnt b SET a.a_id=b.accnt_new WHERE a.agent=b.accnt_old AND b.accnt_type='COMPANY' AND b.hotel_id=arg_hotel_id AND b.accnt_class='A';   -- 旅行社 
	UPDATE migrate_db.hmaster a,up_map_accnt b SET a.s_id=b.accnt_new WHERE a.source=b.accnt_old AND b.accnt_type='COMPANY' AND b.hotel_id=arg_hotel_id AND b.accnt_class='S';  -- 订房中心  
	UPDATE migrate_db.hmaster a,up_map_code b SET a.src = b.code_new WHERE b.cat = 'srccode'  AND a.src = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.hmaster a,up_map_code b SET a.market 	= b.code_new 	WHERE b.cat = 'mktcode'  AND a.market = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.hmaster a,up_map_code b SET a.restype = b.code_new 	WHERE b.cat = 'restype'  AND a.restype = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.hmaster a,up_map_code b SET a.channel = b.code_new 	WHERE b.cat = 'channel'  AND a.channel = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.hmaster a,up_map_code b SET a.ratecode = b.code_new 	WHERE b.cat = 'ratecode' AND a.ratecode = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.hmaster a,up_map_code b SET a.paycode = b.code_new 	WHERE b.cat = 'paymth'   AND a.paycode = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.hmaster a,up_map_code b SET a.saleid 	= b.code_new 	WHERE b.cat = 'salesman' AND a.saleid = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;
	UPDATE migrate_db.hmaster a,up_map_code b SET a.packages = b.code_new 	WHERE b.cat = 'package'  AND a.packages = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;	
	UPDATE migrate_db.hmaster a,up_map_code b SET a.rmtype 	= b.code_new 	WHERE b.cat = 'rmtype'  AND a.rmtype = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;	
	UPDATE migrate_db.hmaster a,up_map_code b SET a.up_type = b.code_new 	WHERE b.cat = 'rmtype'  AND a.up_type = b.code_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id;	
	UPDATE migrate_db.hmaster SET amenities = REPLACE(amenities,'CB','BB') WHERE amenities <> '';
	UPDATE migrate_db.hmaster SET amenities = REPLACE(amenities,'CK','PAT') WHERE amenities <> '';
	UPDATE migrate_db.hmaster SET amenities = REPLACE(amenities,'CL','CH') WHERE amenities <> '';
	UPDATE migrate_db.hmaster SET amenities = REPLACE(amenities,'CP','CHP') WHERE amenities <> '';
	UPDATE migrate_db.hmaster SET amenities = REPLACE(amenities,'F3','FB4') WHERE amenities <> '';
	UPDATE migrate_db.hmaster SET amenities = REPLACE(amenities,'FD','FL4') WHERE amenities <> '';
	UPDATE migrate_db.hmaster SET amenities = REPLACE(amenities,'NC','CN') WHERE amenities <> '';
	UPDATE migrate_db.hmaster SET amenities = REPLACE(amenities,'NE','EN') WHERE amenities <> '';
	UPDATE migrate_db.hmaster SET srqs = REPLACE(srqs,'CR','CB') WHERE srqs <> '';
	*/
	
	/*
	UPDATE migrate_db.hmaster a,up_map_accnt b SET a.h_id=b.accnt_new WHERE a.haccnt=b.accnt_old AND b.accnt_type='GUEST_FIT' AND b.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id;
	UPDATE migrate_db.hmaster a,up_map_accnt b SET a.h_id=b.accnt_new WHERE a.haccnt=b.accnt_old AND b.accnt_type='GUEST_GRP' AND b.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id;
	*/
	
	
	SELECT MIN(CODE) INTO var_rsv_type 	FROM code_rsv_type WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND is_halt = 'F';
	SELECT MIN(CODE) INTO var_channel 	FROM code_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND parent_code='channel'; 
	SELECT district_code INTO var_whereto FROM hotel WHERE hotel_group_id=arg_hotel_group_id AND id=arg_hotel_id; 
	
	UPDATE migrate_db.hmaster SET h_id=0,c_id=0,a_id=0,s_id=0,m_id=0,l_id=0;
	-- --------------------------------------
	-- 取得当前最大 master_base.id 
	-- --------------------------------------
	SELECT MAX(id) INTO var_bigint FROM master_base; 
	SELECT MAX(id) INTO var_bigint1 FROM master_base_history; 
	IF var_bigint1 > var_bigint THEN 
		SET var_bigint = var_bigint1; 
	END IF ; 
	SET var_bigint = var_bigint + 20000;   -- 预留id间隙，在迁移过程中，可能产生的新的id增长空间，完成之后使用./idcheck fix修复
	-- --------------------------------------------------------------------
	-- 待迁移数据id处理 - 说明：待迁移记录id放在 migrate_db.hmaster.logmark  
	-- SELECT DISTINCT (MID(accnt,4,1)) AS col2 FROM migrate_db.hmaster WHERE accnt NOT LIKE 'AR%' 检查账号前几位是否一致
	-- --------------------------------------------------------------------
	/*
	UPDATE migrate_db.hmaster SET logmark=0;	
	UPDATE migrate_db.hmaster SET logmark = var_bigint + CONVERT(SUBSTRING(accnt,2),SIGNED) WHERE accnt LIKE 'F%';
	UPDATE migrate_db.hmaster SET logmark = var_bigint + CONVERT(SUBSTRING(accnt,2),SIGNED) WHERE accnt LIKE 'G%';
	UPDATE migrate_db.hmaster SET logmark = var_bigint + CONVERT(SUBSTRING(accnt,2),SIGNED) WHERE accnt LIKE 'M%';
	UPDATE migrate_db.hmaster SET logmark = var_bigint + CONVERT(SUBSTRING(accnt,2),SIGNED) WHERE accnt LIKE 'C%';
	-- UPDATE migrate_db.hmaster a,migrate_db.guest b SET a.logmark=0 WHERE a.haccnt=b.no AND NOT (a.sta='O' AND a.class IN ('F','G','M')); 
	
	UPDATE migrate_db.hmaster SET m_id = var_bigint + CONVERT(SUBSTRING(master,2),SIGNED) WHERE master LIKE 'F%';
	UPDATE migrate_db.hmaster SET m_id = var_bigint + CONVERT(SUBSTRING(master,2),SIGNED) WHERE master LIKE 'G%';
	UPDATE migrate_db.hmaster SET m_id = var_bigint + CONVERT(SUBSTRING(master,2),SIGNED) WHERE master LIKE 'M%';
	UPDATE migrate_db.hmaster SET m_id = var_bigint + CONVERT(SUBSTRING(master,2),SIGNED) WHERE master LIKE 'C%';	
	UPDATE migrate_db.hmaster SET l_id = var_bigint + CONVERT(SUBSTRING(pcrec,2),SIGNED) WHERE pcrec LIKE 'F%';
	UPDATE migrate_db.hmaster SET l_id = logmark WHERE l_id = 0;
	*/
	UPDATE migrate_db.hmaster SET logmark=0;
	UPDATE migrate_db.hmaster SET m_id=0;
	UPDATE migrate_db.hmaster SET l_id=0;	
	UPDATE migrate_db.hmaster SET logmark = var_bigint + new_id;	
	UPDATE migrate_db.hmaster a,migrate_db.hmaster_newid b SET a.m_id=var_bigint + b.id WHERE a.master=b.accnt AND a.master<>'';
	UPDATE migrate_db.hmaster a,migrate_db.hmaster_newid b SET a.l_id=var_bigint + b.id WHERE a.pcrec=b.accnt AND a.pcrec<>'';
	UPDATE migrate_db.hmaster a SET a.l_id=logmark WHERE a.l_id=0;

	-- 插入 master_base_history 
	INSERT INTO master_base_history(hotel_group_id,hotel_id,id,rsv_id,is_resrv,rsv_man,rsv_company,group_code,group_manager,
		rsv_src_id,master_rsvsrc_id,rsv_class,master_id,grp_accnt,grp_flag,block_id,biz_date,sta,rmtype,rmno,rmno_son,rmnum,
		arr,dep,cutoff_days,cutoff_date,adult,children,res_sta,res_dep,up_rmtype,up_reason,up_user,rack_rate,nego_rate,real_rate,
		dsc_reason,dsc_amount,dsc_percent,exp_sta,tm_sta,rmpost_sta,is_rmposted,tag0,company_id,agent_id,source_id,member_type,
		member_no,inner_card_id,salesman,arno,building,src,market,rsv_type,channel,sales_channel,ratecode,ratecode_category,
		cmscode,packages,specials,amenities,is_fix_rate,is_fix_rmno,is_sure,is_permanent,is_walkin,is_secret,is_secret_rate,
		posting_flag,sc_flag,extra_flag,extra_bed_num,extra_bed_rate,crib_num,crib_rate,pay_code,limit_amt,credit_no,credit_man,
		credit_company,charge,pay,credit,last_num,last_num_link,rmocc_id,link_id,pkg_link_id,rsv_no,crs_no,where_from,where_to,
		purpose,remark,co_msg,is_send,promotion,create_user,create_datetime,modify_user,modify_datetime,sta_ebooking)	
	SELECT arg_hotel_group_id,arg_hotel_id,a.logmark,0,'F',a.applname,a.applicant,a.groupno,'',
		0,0,IF(a.class='M','G',IF(a.class='C','H',a.class)),a.m_id,0,'',0,a.bdate,a.sta,a.type,a.roomno,'',a.rmnum,
		a.arr,a.dep,0,NULL,a.gstno,a.children,a.ressta,a.resdep,a.up_type,'OTH',IF(a.up_type<>'','ADMIN',''),a.qtrate,a.rmrate,a.setrate,
		rtreason,a.qtrate-a.setrate,0,a.exp_sta,a.sta_tm,a.rmpoststa,a.rmposted,a.tag0,a.c_id,a.a_id,a.s_id,a.cardcode,
		a.cardno,NULL,a.saleid,a.araccnt,'',a.src,a.market,a.restype,a.channel,'',a.ratecode,'',
		a.cmscode,a.packages,a.srqs,a.amenities,a.fixrate,'','F','F','F','F','F',
		'0',a.accnt,'000000000000000000000000000000',a.addbed,a.addbed_rate,0,0,a.paycode,0,a.credcode,a.credman,
		a.credunit,a.charge,a.credit,a.accredit,a.lastnumb,a.lastinumb,'0',-1*l_id-2000,'0',a.resno,a.crsno,wherefrom,whereto,
		'SMDFD',a.ref,a.comsg,'','F',a.resby,a.restime,a.cby,a.changed,'F'
		FROM migrate_db.hmaster a,migrate_db.guest b WHERE a.haccnt=b.no;
		-- AND a.sta='O' AND a.class='F';		
 
	-- master_guest_history 档案信息	
	INSERT INTO master_guest_history(hotel_group_id,hotel_id,id,profile_type,profile_id,times_in,name,last_name,first_name,name2,name3,
		name_combine,sex,language,title,salutation,interest,birth,race,religion,career,occupation,nation,country,state,city,division,
		street,zipcode,vip,phone,mobile,fax,email,id_code,id_no,id_end,visa_type,visa_no,visa_begin,visa_end,visa_grant,enter_port,
		enter_date,enter_date_end,photo_pic,photo_sign,remark,room_prefer,feature,create_user,create_datetime,modify_user,modify_datetime) 
	SELECT arg_hotel_group_id,arg_hotel_id,a.logmark,'GUEST',a.h_id,b.i_times,b.name,b.fname,b.lname,b.name2,b.name3,
		b.name4,b.sex,b.lang,b.title,b.salutation,'',b.birth,b.race,b.religion,'',b.occupation,b.nation,b.country,b.state,b.city,'',
		b.street,b.zip,b.vip,b.phone,b.mobile,b.fax,b.email,b.idcls,b.ident,b.idend,b.visaid,b.visano,b.visaend,b.visaend,'',b.rjplace,
		b.rjdate,NULL,'','',b.refer1,b.amenities,b.feature,a.ciby,a.citime,a.cby,a.changed
	FROM migrate_db.hmaster a,migrate_db.guest b WHERE a.haccnt=b.no; 
	-- AND a.sta='O' AND a.class = 'F';

	-- master_stalog_history 状态信息
	INSERT INTO master_stalog_history (hotel_group_id,hotel_id,id,rsv_user,rsv_datetime,ci_user,ci_datetime,co_user,co_datetime,dep_user,dep_datetime,modify_user,modify_datetime)
	SELECT arg_hotel_group_id,arg_hotel_id,a.logmark,a.resby,a.restime,a.resby,a.restime,a.cby,a.changed,a.cby,a.changed,a.cby,a.changed 
		FROM migrate_db.hmaster a,migrate_db.guest b WHERE a.haccnt=b.no; 
	-- AND a.sta='O' AND a.class = 'F';		
		
	-- 产生up_map_accnt
	INSERT INTO up_map_accnt(hotel_group_id,hotel_id,accnt_type,accnt_class,accnt_old,accnt_new) 
		SELECT arg_hotel_group_id,arg_hotel_id,'HMASTER','',sc_flag,id
			FROM master_base_history WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND purpose='SMDFD';
	
	-- UPDATE master_base_history SET purpose='' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND purpose='SMDFD';
	/*
	UPDATE master_base_history SET grp_accnt = id WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rsv_class = 'G';
	UPDATE master_base_history a,up_map_accnt b,migrate_db.hmaster c,up_map_accnt d SET a.grp_accnt=d.accnt_new,a.rsv_id=d.accnt_new
	WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id
		AND d.hotel_group_id=arg_hotel_group_id AND d.hotel_id=arg_hotel_id AND a.id=b.accnt_new AND b.accnt_type ='HMASTER' AND d.accnt_type='HMASTER'		
		AND b.accnt_old=c.accnt AND c.groupno=d.accnt_old;
	*/
END$$

DELIMITER ;