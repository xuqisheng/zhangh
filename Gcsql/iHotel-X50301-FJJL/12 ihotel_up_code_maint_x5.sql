DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_code_maint_x5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_code_maint_x5`(
	arg_hotel_group_id	INT,
	arg_hotel_id		INT
)
SQL SECURITY INVOKER
label_0:
BEGIN

	DELETE FROM up_status WHERE hotel_id=arg_hotel_id AND up_step='MAINT';
	INSERT INTO up_status(hotel_id,up_step,time_begin,time_end,time_long,remark) VALUES(arg_hotel_id,'MAINT',NOW(),NULL,0,''); 
		
	-- 预订号补全：否则入住页面有问题
	UPDATE master_base SET rsv_no=crs_no WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (rsv_no='' OR rsv_no IS NULL ) AND NOT (crs_no='' OR crs_no IS NULL); 
	UPDATE master_base SET rsv_no=TRIM(CONVERT(id,CHAR(20))) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (rsv_no='' OR rsv_no IS NULL );

	-- 更新 master_base.rsv_man 预订人
	UPDATE master_base a,master_guest b SET a.rsv_man=b.name WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.id=b.id AND a.rsv_man='';	
	
	UPDATE master_base a,up_map_code b SET a.rmtype = b.code_new WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code = 'rmtype' AND a.rmtype = b.code_old;
	UPDATE rsv_src a,up_map_code b SET a.rmtype = b.code_new WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code = 'rmtype' AND a.rmtype = b.code_old;

	UPDATE master_base a,up_map_code b SET a.up_rmtype = b.code_new WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.code = 'rmtype' AND a.up_rmtype = b.code_old AND a.up_rmtype<>'';
	UPDATE rsv_src a,up_map_code b SET a.up_rmtype = b.code_new WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code = 'rmtype' AND a.up_rmtype = b.code_old AND a.up_rmtype<>'';
	
	UPDATE master_base a,room_no b SET a.building = b.building WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.rmtype = b.rmtype;
	UPDATE master_guest SET birth = NULL WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND birth='0000-00-00 00:00:00';

	-- 信用部分	
	DELETE FROM accredit WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;	
	INSERT INTO accredit(hotel_group_id,hotel_id,accnt,accnt_type,number,ta_code,card_no,expiry_date,cur_exchg_no,
			auth_no,amount,amount_foreign,amount_use,tag,create_user,create_biz_date,create_cashier,create_datetime,
			use_user,use_biz_date,use_cashier,use_datetime,partout_flag,close_id,modify_user,modify_datetime,is_online)
	SELECT a.hotel_group_id,a.hotel_id,a.id,'F',c.number - 1,c.pccode,c.cardno,c.expiry_date,'',c.creditno,
			c.amount,0,0,'R',c.empno1,c.bdate1,CONVERT(c.shift1,SIGNED),c.log_date1,NULL,NULL,NULL,NULL,
			NULL,NULL,c.empno1,c.log_date1,'F'
			FROM master_base a,up_map_accnt b,migrate_db.accredit c
			WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id 
			AND a.sta IN('I','S','O') AND a.id=b.accnt_new AND b.accnt_type='master_si' AND b.accnt_old=c.accnt AND c.tag='0'
	UNION ALL
	SELECT a.hotel_group_id,a.hotel_id,a.id,'R',c.number - 1,c.pccode,c.cardno,c.expiry_date,'',c.creditno,
			c.amount,0,0,'R',c.empno1,c.bdate1,CONVERT(c.shift1,SIGNED),c.log_date1,NULL,NULL,NULL,NULL,
			NULL,NULL,c.empno1,c.log_date1,'F'
			FROM master_base a,up_map_accnt b,migrate_db.accredit c
			WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id 
			AND a.sta IN('R','X','N') AND a.id=b.accnt_new AND b.accnt_type='master_r' AND b.accnt_old=c.accnt AND c.tag='0'
	UNION ALL
	SELECT a.hotel_group_id,a.hotel_id,a.id,'A',c.number -1 ,c.pccode,c.cardno,c.expiry_date,'',c.creditno,
			c.amount,0,0,'R',c.empno1,c.bdate1,CONVERT(c.shift1,SIGNED),c.log_date1,NULL,NULL,NULL,NULL,
			NULL,NULL,c.empno1,c.log_date1,'F'
			FROM ar_master a,up_map_accnt b,migrate_db.accredit c
			WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id
			AND a.sta IN ('I','O') AND a.id = b.accnt_new AND b.accnt_type='armst' AND b.accnt_old=c.accnt AND c.tag='0';
	
	UPDATE accredit a,up_map_code b SET a.ta_code=b.code_new WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code='paymth' AND a.ta_code=b.code_old;
	
	-- 主单余额，定金修复		
	UPDATE master_base a SET a.charge=IFNULL((SELECT SUM(b.charge) FROM account b WHERE a.id=b.accnt AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id),0) WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id;
	UPDATE master_base a SET a.pay=IFNULL((SELECT SUM(b.pay) FROM account b WHERE a.id=b.accnt AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id),0) WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id;
	UPDATE master_base a SET a.credit=IFNULL((SELECT SUM(b.amount) FROM accredit b WHERE a.id=b.accnt AND b.accnt_type='F' AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id),0) WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id;

	-- 修复相关代码
	UPDATE master_base SET pay_code ='9000' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND pay_code = '';
	UPDATE master_base SET market = 'RAC' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id AND market = '';
	UPDATE master_base SET src = 'WKG' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id AND src = '';
	UPDATE master_base SET ratecode = 'RAC' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id AND ratecode = '';
	UPDATE master_base a,up_map_code b SET a.salesman = b.code_new WHERE b.code = 'salesman' AND a.salesman = b.code_old AND a.salesman<>'' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.hotel_group_id=b.hotel_group_id AND a.hotel_id = 0;
	UPDATE master_base a,up_map_code b SET a.pay_code = b.code_new WHERE a.pay_code = b.code_old AND b.code='paymth' AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id;
	UPDATE master_base SET pay_code = '9000' WHERE pay_code = '' AND hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
    UPDATE master_base SET dsc_reason = 'O02' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND rack_rate <> real_rate AND dsc_reason = '' ;	
	-- 修复打开团队主单账务时报错	
	UPDATE master_base SET master_id = id ,grp_accnt = id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND rsv_class = 'G';
	UPDATE master_base SET crs_no='' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND rsv_no=crs_no;
	
	-- 费用码和付款码中英对照翻译
	UPDATE account a,code_transaction b SET a.ta_descript_en = b.descript_en WHERE a.ta_code=b.code AND a.ta_code <> '' AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id;

	-- 产生允许记账
	INSERT INTO account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt_type,accnt,rmno,guest_id,to_accnt_type,to_accnt,to_rmno,NAME,
			ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
		SELECT arg_hotel_group_id,arg_hotel_id,'POSTING','','MASTER',id,'',0,NULL,NULL,'','',
			'*','',arr,dep,'','ADMIN',NOW(),'ADMIN',NOW()
		FROM master_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND sta IN ('I','S','O')
		AND id NOT IN (SELECT c.accnt FROM account_sub c WHERE c.hotel_group_id=arg_hotel_group_id AND c.hotel_id=arg_hotel_id AND c.type='POSTING');  

	UPDATE master_base SET extra_flag='001000000000000000000000000000',posting_flag ='1' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND sta IN ('I','S','O');

	INSERT INTO account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt_type,accnt,rmno,guest_id,to_accnt_type,to_accnt,to_rmno,NAME,
			ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
		SELECT arg_hotel_group_id,arg_hotel_id,'POSTING','USER','RESRV',id,'',0,NULL,NULL,'','',
			'*','',arr,dep,'','ADMIN',NOW(),'ADMIN',NOW()
		FROM master_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND sta IN ('R','X','N')
		AND id NOT IN (SELECT c.accnt FROM account_sub c WHERE c.hotel_group_id=arg_hotel_group_id AND c.hotel_id=arg_hotel_id AND c.type='POSTING');  
	UPDATE master_base SET extra_flag='001000000000000000000000000000'  WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND sta IN ('R','X','N');

	UPDATE account_sub SET accnt_type = 'MASTER' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type = 'consume';

	-- 产生基本分账户
	INSERT INTO account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt_type,accnt,rmno,guest_id,to_accnt_type,to_accnt,to_rmno,NAME,
			ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
		SELECT arg_hotel_group_id,arg_hotel_id,'POSTING','USER','RESRV',id,'',0,NULL,NULL,'','',
			'*','',arr,dep,'','ADMIN',NOW(),'ADMIN',NOW()
		FROM master_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND sc_flag<>'' AND sc_flag IS NOT NULL AND sta IN ('R','X','N'); 
	
	INSERT INTO account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt_type,accnt,rmno,guest_id,to_accnt_type,to_accnt,to_rmno,NAME,
			ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
		SELECT arg_hotel_group_id,arg_hotel_id,'POSTING','USER','MASTER',id,'',0,NULL,NULL,'','',
			'*','',arr,dep,'','ADMIN',NOW(),'ADMIN',NOW()
		FROM master_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND sc_flag<>'' AND sc_flag IS NOT NULL AND sta IN ('I','S','O'); 
	
	 INSERT INTO account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt_type,accnt,rmno,guest_id,to_accnt_type,to_accnt,to_rmno,NAME,
				  ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
		SELECT arg_hotel_group_id,arg_hotel_id,'SUBACCNT','SYS_FIX','MASTER',id,'',0,NULL,NULL,'','',
			'*','',arr,dep,'','ADMIN',NOW(),'ADMIN',NOW()
		FROM master_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id
		AND id NOT IN (SELECT c.accnt FROM account_sub c WHERE c.hotel_group_id=arg_hotel_group_id AND c.hotel_id=arg_hotel_id AND c.type='SUBACCNT' AND c.tag='SYS_FIX');  

	UPDATE account_sub a,master_guest b SET a.name=b.name 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id
		AND a.accnt=b.id AND a.type='SUBACCNT' AND a.tag='SYS_FIX' ;
		
	-- guest_type.code1和guest_type.saleman置为空
	UPDATE guest_type SET saleman='' WHERE saleman <>'' AND hotel_group_id = hotel_group_id AND hotel_id = arg_hotel_id;
	UPDATE guest_type SET code1='' WHERE code1 <>'' AND hotel_group_id = hotel_group_id AND hotel_id = arg_hotel_id;
		
	-- 防止消费账联房
	UPDATE master_base SET master_id=id WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rsv_class='H';
	-- 修复 master_base 中的 rsv_id,master_id	
	UPDATE master_base a,rsv_src b SET a.rsv_id=a.id WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id
		AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.sta='R' AND a.id=b.accnt AND b.occ_flag IN ('RF','RG');
		
	UPDATE master_base SET rsv_id = id WHERE hotel_group_id = hotel_group_id AND hotel_id = arg_hotel_id AND sta IN ('I','O','S') AND rsv_class='G';
	UPDATE master_base SET master_id=id WHERE hotel_group_id = hotel_group_id AND hotel_id = arg_hotel_id AND sta='R' AND rsv_class<>'H';

	-- 修复同住
	UPDATE master_base a,up_map_accnt b,migrate_db.master c,up_map_accnt d SET master_id=d.accnt_new
	WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id 
		AND b.hotel_id=arg_hotel_id AND d.hotel_group_id=arg_hotel_group_id AND d.hotel_id = arg_hotel_id
		AND a.id=b.accnt_new AND b.accnt_type ='master_si' AND d.accnt_type ='master_si' 
		AND b.accnt_old=c.accnt AND c.master<>'' AND c.master = d.accnt_old;
	
	-- 修复联房
		UPDATE master_base a,up_map_accnt b,migrate_db.master c,up_map_accnt d
		SET a.link_id=d.accnt_new 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id 
			AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id 
			AND d.hotel_group_id=arg_hotel_group_id AND d.hotel_id=arg_hotel_id 
			AND a.id=b.accnt_new AND b.accnt_type IN ('master_si','master_r','consume') 
			AND c.pcrec=d.accnt_old AND d.accnt_type IN ('master_si','master_r','consume') 
			AND b.accnt_old=c.accnt AND c.pcrec<>''; 
		
	-- 团队主单与成员的信息关联
	UPDATE master_base SET grp_accnt = id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND rsv_class = 'G';

	UPDATE master_base a,up_map_accnt b,migrate_db.master c,up_map_accnt d SET a.grp_accnt=d.accnt_new,a.rsv_id=d.accnt_new
	WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id
		AND d.hotel_group_id=arg_hotel_group_id AND d.hotel_id=arg_hotel_id AND a.id=b.accnt_new AND b.accnt_type IN ('master_si','master_r') AND d.accnt_type IN ('master_si','master_r') 
		AND b.accnt_old=c.accnt AND c.groupno=d.accnt_old;	

	-- 处理合并结账的 arrange_code,防止夜审报错
	UPDATE account SET arrange_code = '99' WHERE ta_code='9' AND arrange_code='' AND hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	UPDATE master_base SET dsc_reason = '' 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND dsc_reason IS NULL;
	UPDATE rsv_src 	SET dsc_reason = '' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND dsc_reason IS NULL;
	UPDATE rsv_rate SET dsc_reason = '' WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND dsc_reason IS NULL;
	UPDATE rsv_rate SET remark = '' 	WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND remark IS NULL;
	
	UPDATE ar_master SET arno = co_msg WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	-- 处理客人持卡
	/*
	INSERT INTO profile_card (hotel_group_id,hotel_id,master_type,master_id,card_type,card_no,date_begin,date_end,remark,is_master,is_halt,create_user,create_datetime,modify_user,modify_datetime) 
		SELECT a.hotel_group_id,a.hotel_id,'F',a.accnt_new,b.cardcode,b.cardno,ADDDATE(b.expiry_date,INTERVAL -15 DAY),b.expiry_date,'','F','F',b.cby,b.changed,b.cby,b.changed FROM up_map_accnt a,migrate_db.guest_card b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.accnt_type='GUEST' AND a.accnt_old=b.no GROUP BY a.accnt_new;
	UPDATE profile_card SET card_type='bankCard' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;	
	*/	
	UPDATE rsv_src SET rsv_dep_date=DATE_ADD(rsv_dep_date,INTERVAL 12 HOUR) WHERE hotel_group_id =arg_hotel_group_id AND hotel_id = arg_hotel_id AND HOUR(rsv_dep_date)=0;
	UPDATE ar_master SET dep=DATE_ADD(dep,INTERVAL 12 HOUR) WHERE hotel_group_id =arg_hotel_group_id AND hotel_id = arg_hotel_id AND HOUR(dep)=0;
	UPDATE master_base SET dep=DATE_ADD(dep,INTERVAL 12 HOUR) WHERE hotel_group_id =arg_hotel_group_id AND hotel_id = arg_hotel_id AND HOUR(dep)=0;
		
	-- 为重建房价准备
	DELETE FROM rsv_rate WHERE hotel_group_id =arg_hotel_group_id AND hotel_id = arg_hotel_id;
	UPDATE rsv_src SET rack_rate=0 WHERE hotel_group_id =arg_hotel_group_id AND hotel_id = arg_hotel_id AND rack_rate IS NULL;
	UPDATE rsv_src SET nego_rate=0 WHERE hotel_group_id =arg_hotel_group_id AND hotel_id = arg_hotel_id AND nego_rate IS NULL;
	UPDATE rsv_src SET real_rate=0 WHERE hotel_group_id =arg_hotel_group_id AND hotel_id = arg_hotel_id AND real_rate IS NULL;
	
	UPDATE company_base SET name_combine=REPLACE(name_combine,' ','');
	UPDATE guest_base SET name_combine=REPLACE(name_combine,' ','');
	
	UPDATE account SET trans_accnt = NULL WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND (trans_accnt='' OR trans_accnt=0);

	UPDATE guest_base a,up_map_accnt b SET a.company_id=b.accnt_new
	WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=0 AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id
	AND a.company_id=b.accnt_old AND b.accnt_type='COMPANY' AND a.company_id<>'';

	-- 团体付费
	INSERT INTO account_sub (hotel_group_id,hotel_id,TYPE,tag,accnt_type,accnt,rmno,guest_id,to_accnt_type,to_accnt,to_rmno,NAME,
			  ta_codes,pay_code,begin_datetime,end_datetime,remark,create_user,create_datetime,modify_user,modify_datetime)
	SELECT arg_hotel_group_id,arg_hotel_id,'SUBACCNT','SYS_MOD','MASTER',id,rmno,NULL,'FO',grp_accnt,'','团体付费',
		'10*','','2000-01-01','2050-01-01','团体付费','ADMIN',NOW(),'ADMIN',NOW()
	FROM master_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND id <> rsv_id AND grp_accnt <> 0
	AND id NOT IN (SELECT c.accnt FROM account_sub c WHERE c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND c.type='SUBACCNT' AND c.tag='SYS_MOD');  

	-- UPDATE guest_type SET hotel_group_id=-2 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND sys_cat='G' AND belong_app_code='';
	UPDATE master_base SET rmtype = '' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rsv_class = 'G';
	
	-- 横店丰景嘉丽特有
	UPDATE code_package a,up_map_accnt b SET a.accnt = b.accnt_new WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.group_code = b.accnt_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.accnt_type = 'consume' AND b.accnt_class = 'HI';	
	
	-- 修复联房id
	CALL up_ihotel_maint_linkid('fix');
	
	UPDATE code_cache SET modify_datetime = NOW() WHERE hotel_group_id =arg_hotel_group_id AND hotel_id=arg_hotel_id;
	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='MAINT';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='MAINT';
		
END$$

DELIMITER ;