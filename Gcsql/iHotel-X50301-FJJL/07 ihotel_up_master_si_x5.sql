DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_master_si_x5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_master_si_x5`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT
)
SQL SECURITY INVOKER
label_0:
BEGIN
	-- -----------------------------------------------------------------------
	-- 散客在住、挂账、本日结账数据迁移  migrate_db.master.sta = 'I'/'S'/'O'
	-- 原系统中N和X状态下若有余额，必须事先处理
	-- -----------------------------------------------------------------------
	DECLARE done_cursor INT DEFAULT 0;
	DECLARE var_biz_date DATETIME ;
	DECLARE var_accnt 	VARCHAR(10);
	DECLARE var_guestid VARCHAR(10);
	DECLARE var_rmtype 	VARCHAR(10);
	DECLARE var_rmno 	VARCHAR(10);
	DECLARE var_arr 	DATETIME;
	DECLARE var_dep 	DATETIME;
	DECLARE var_cusno 	VARCHAR(10);
	DECLARE var_agent 	VARCHAR(10);
	DECLARE var_source 	VARCHAR(10);
	DECLARE var_resno 	VARCHAR(10);
	DECLARE var_crsno 	VARCHAR(10);
	DECLARE var_ratecode VARCHAR(10);
	DECLARE var_src 	VARCHAR(10);
	DECLARE var_mkt 	VARCHAR(10);
	DECLARE var_building VARCHAR(6);
	DECLARE var_qtrate 	DECIMAL(12,2);
	DECLARE var_rmrate 	DECIMAL(12,2);
	DECLARE var_setrate DECIMAL(12,2);
	DECLARE var_rtreason VARCHAR(10);
	DECLARE var_paycode VARCHAR(10);
	DECLARE var_srqs 	VARCHAR(30);
	DECLARE var_ref 	VARCHAR(255);
	DECLARE var_comsg 	VARCHAR(255);
	DECLARE var_haccnt 	VARCHAR(10);
	DECLARE var_name 	VARCHAR(60);
	DECLARE var_lname 	VARCHAR(30);
	DECLARE var_fname 	VARCHAR(30);
	DECLARE var_name2 	VARCHAR(50);
	DECLARE var_name3 	VARCHAR(50);
	DECLARE var_name4 	VARCHAR(50);
	DECLARE var_sex 	VARCHAR(2);
	DECLARE var_birth 	DATETIME; 
	DECLARE var_vip 	VARCHAR(10); 
	DECLARE var_idcls	VARCHAR(10); 
	DECLARE var_ident 	VARCHAR(20); 
	DECLARE var_nation 	VARCHAR(10); 
	DECLARE var_race 	VARCHAR(10); 
	DECLARE var_address VARCHAR(60); 
	DECLARE var_birthplace VARCHAR(10); 
	DECLARE var_balance DECIMAL(12,2); 
	DECLARE var_wherefrom VARCHAR(10); 
	DECLARE var_whereto VARCHAR(10); 
	DECLARE var_sta 	VARCHAR(2); 
	DECLARE var_class 	VARCHAR(2); 
	DECLARE var_rsv_type VARCHAR(10);
	DECLARE var_channel VARCHAR(10);
	DECLARE var_profile_type VARCHAR(10);
	DECLARE var_profile_id BIGINT(16);
	DECLARE var_id BIGINT(16);
	DECLARE	var_company_id BIGINT(16);
	DECLARE var_company_class VARCHAR(2);
	DECLARE	var_cid 	BIGINT(16);
	DECLARE	var_aid 	BIGINT(16);
	DECLARE	var_sid 	BIGINT(16);
	DECLARE var_pcrec 	VARCHAR(10);
	DECLARE var_cby		VARCHAR(10);
	DECLARE var_last_accnt VARCHAR(10) DEFAULT '';
	DECLARE var_packages	VARCHAR(30);
	DECLARE var_adult	MEDIUMINT(4);
	DECLARE var_children	MEDIUMINT(4);
	DECLARE var_rmnum	MEDIUMINT(4);
	DECLARE var_applname	VARCHAR(50);
	DECLARE var_applicant	VARCHAR(50);
	DECLARE var_cardcode	VARCHAR(10);
	DECLARE var_cardno		VARCHAR(20);
	DECLARE var_saleid		VARCHAR(20);
	DECLARE var_itimes		INT(6);
	DECLARE var_changed		DATETIME;
	DECLARE var_amenities	VARCHAR(20);
	DECLARE var_uptype		VARCHAR(10);
	DECLARE var_upreason	VARCHAR(10);
	DECLARE var_phone		VARCHAR(20);
	DECLARE var_fax		VARCHAR(20);
	DECLARE var_email		VARCHAR(100);
	DECLARE var_feature		VARCHAR(10);	
	DECLARE var_visaid		VARCHAR(10);
	DECLARE var_visaend		DATETIME;
	DECLARE var_rjplace		VARCHAR(10);
	DECLARE var_rjdate		DATETIME;
	
	DECLARE c_master CURSOR FOR 
		SELECT a.accnt,b.no,a.type,a.roomno,a.arr,a.dep,a.cusno,a.agent,a.source,a.cardcode,a.cardno,a.saleid,TRIM(b.name),IF(b.nation IN('CN','TW'),TRIM(b.fname),TRIM(b.lname)),IF(b.nation IN('CN','TW'),TRIM(b.lname),TRIM(b.fname)),TRIM(b.name2),TRIM(b.name3),TRIM(b.name4),
			a.ratecode,a.src,a.market,a.qtrate,a.rmrate,a.setrate,a.rtreason,a.paycode,a.srqs,TRIM(a.ref),b.no,b.sex,a.amenities,a.up_type,a.up_reason,b.visaid,b.visaend,b.rjplace,b.rjdate,
			IFNULL(b.birth,''),b.vip,b.idcls,b.ident,b.nation,b.race,TRIM(b.street),b.city,a.charge-a.credit,b.i_times,a.changed,a.phone,a.fax,a.email,b.feature,
			a.sta,a.class,a.pcrec,TRIM(a.comsg),IFNULL(a.cby,'ADMIN'),a.restype,a.channel,IFNULL(a.resno,''),IFNULL(a.crsno,''),a.packages,a.gstno,a.children,a.rmnum,a.applname,a.applicant
		FROM migrate_db.master a,migrate_db.guest b WHERE a.haccnt=b.no AND a.class IN ('F','G','M') AND a.sta IN ('I','O','S') ORDER BY a.accnt;
		
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	
	SELECT biz_date INTO var_biz_date FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id; 
	SELECT MIN(CODE) INTO var_rsv_type FROM code_rsv_type WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND is_halt = 'F'; 
	SELECT MIN(CODE) INTO var_channel FROM code_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND parent_code='channel' AND is_halt = 'F'; 
	SELECT district_code INTO var_whereto FROM hotel WHERE hotel_group_id=arg_hotel_group_id AND id=arg_hotel_id; 
	
	DELETE FROM up_status WHERE hotel_id=arg_hotel_id AND up_step='MASTER_SI';
	INSERT INTO up_status(hotel_id,up_step,time_begin,time_end,time_long,remark) VALUES(arg_hotel_id,'MASTER_SI',NOW(),NULL,0,''); 
	DELETE FROM up_map_accnt WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type='master_si' AND accnt_class IN('I','S','O');
	
	OPEN c_master ;
	SET done_cursor = 0;
	
	FETCH c_master INTO var_accnt,var_guestid,var_rmtype,var_rmno,var_arr,var_dep,var_cusno,var_agent,var_source,var_cardcode,var_cardno,var_saleid,var_name,var_lname,var_fname,var_name2,var_name3,var_name4,
					var_ratecode,var_src,var_mkt,var_qtrate,var_rmrate,var_setrate,var_rtreason,var_paycode,var_srqs,var_ref,var_haccnt,var_sex,var_amenities,var_uptype,var_upreason,var_visaid,var_visaend,var_rjplace,var_rjdate,
					var_birth,var_vip,var_idcls,var_ident,var_nation,var_race,var_address,var_birthplace,var_balance,var_itimes,var_changed,var_phone,var_fax,var_email,var_feature,
					var_sta,var_class,var_pcrec,var_comsg,var_cby,var_rsv_type,var_channel,var_resno,var_crsno,var_packages,var_adult,var_children,var_rmnum,var_applname,var_applicant; 
	WHILE done_cursor = 0 DO
		BEGIN
			IF var_idcls = '01' THEN 
				SET var_wherefrom = MID(var_ident,1,6); 
			ELSE
				SET var_wherefrom = ''; 
			END IF; 
			
			IF var_class='M' THEN 
				SET var_class='G';
			END IF; 
			
			SET var_profile_id = 0;  
			IF var_haccnt<>'' THEN 
				SELECT accnt_new INTO var_profile_id FROM up_map_accnt WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type='GUEST' AND accnt_old=var_accnt; 
			END IF; 
			IF var_profile_id=0 AND var_ident<>'' THEN 
				SET var_profile_type='F',var_profile_id=0; 
				CALL ihotel_up_get_guest_id_x5(arg_hotel_group_id,arg_hotel_id,var_haccnt,var_name,var_idcls,var_ident,var_sex,var_birth,var_race,var_address,var_birthplace,var_profile_id); 
			END IF; 
			
			SET var_company_id=0,var_cid=0,var_aid=0,var_sid=0; 
			IF var_cusno <> '' THEN 
				SELECT accnt_new INTO var_company_id FROM up_map_accnt WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type='COMPANY' AND accnt_old=var_cusno; 
				IF var_company_id>0 THEN 
					SET var_cid=var_company_id; 
				END IF; 
			END IF ; 
			IF var_agent <> '' THEN 
				SELECT accnt_new INTO var_company_id FROM up_map_accnt WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type='COMPANY' AND accnt_old=var_agent; 
				IF var_company_id>0 THEN 
					SET var_aid=var_company_id; 
				END IF; 
			END IF ; 
			IF var_source <> '' THEN 
				SELECT accnt_new INTO var_company_id FROM up_map_accnt WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type='COMPANY' AND accnt_old=var_source; 
				IF var_company_id>0 THEN 
					SET var_sid=var_company_id; 
				END IF; 
			END IF ; 
			
			IF var_accnt = var_last_accnt THEN 				
				INSERT INTO master_base (hotel_group_id,hotel_id,rsv_id,is_resrv,rsv_man,rsv_company,rsv_src_id,rsv_class,master_id,grp_accnt,block_id,biz_date,
					sta,rmtype,rmno,rmnum,arr,dep,adult,children,res_sta,res_dep,up_rmtype,up_reason,up_user,rack_rate,nego_rate,real_rate,dsc_reason,dsc_amount,dsc_percent,
					exp_sta,tm_sta,rmpost_sta,is_rmposted,tag0,company_id,agent_id,source_id,member_type,member_no,salesman,arno,building,
					src,market,rsv_type,channel,ratecode,cmscode,packages,specials,amenities,
					is_fix_rate,is_fix_rmno,is_sure,is_permanent,is_walkin,is_secret,is_secret_rate,posting_flag,
					sc_flag,extra_flag,extra_bed_num,extra_bed_rate,crib_num,crib_rate,pay_code,limit_amt,credit_no,credit_man,credit_company,
					charge,pay,credit,last_num,last_num_link,rmocc_id,link_id,pkg_link_id,rsv_no,crs_no,
					where_from,where_to,purpose,remark,co_msg,create_user,create_datetime,modify_user,modify_datetime)
				VALUES(arg_hotel_group_id,arg_hotel_id,0,'F',var_applname,var_applicant,0,var_class,0,0,0,var_biz_date,
					var_sta,var_rmtype,var_rmno,var_rmnum,var_arr,var_dep,var_adult,var_children,'I',NULL,var_uptype,var_upreason,IF(var_uptype<>'','ADMIN',''),0,0,0,'',0,0,
					'I',var_sta,'F','F','',var_cid,var_aid,var_sid,var_cardcode,var_cardno,var_saleid,'','',
					var_src,var_mkt,var_rsv_type,var_channel,var_ratecode,'',var_packages,var_srqs,var_amenities,
					'F','F','T','F','F','0','F','0',
					var_accnt,'000000000000000000000000000000',0,0,0,0,IFNULL(var_paycode,'9000'),0,'','','',
					0,0,0,1,0,0,0,0,var_resno, var_crsno,
					var_wherefrom,var_whereto,'I',var_ref,var_comsg,var_cby,var_changed,var_cby,var_changed);
			ELSE
				INSERT INTO master_base (hotel_group_id,hotel_id,rsv_id,is_resrv,rsv_man,rsv_company,rsv_src_id,rsv_class,master_id,grp_accnt,block_id,biz_date,
					sta,rmtype,rmno,rmnum,arr,dep,adult,children,res_sta,res_dep,up_rmtype,up_reason,up_user,rack_rate,nego_rate,real_rate,dsc_reason,dsc_amount,dsc_percent,
					exp_sta,tm_sta,rmpost_sta,is_rmposted,tag0,company_id,agent_id,source_id,member_type,member_no,salesman,arno,building,
					src,market,rsv_type,channel,ratecode,cmscode,packages,specials,amenities,
					is_fix_rate,is_fix_rmno,is_sure,is_permanent,is_walkin,is_secret,is_secret_rate,posting_flag,
					sc_flag,extra_flag,extra_bed_num,extra_bed_rate,crib_num,crib_rate,pay_code,limit_amt,credit_no,credit_man,credit_company,
					charge,pay,credit,last_num,last_num_link,rmocc_id,link_id,pkg_link_id,rsv_no,crs_no,
					where_from,where_to,purpose,remark,co_msg,create_user,create_datetime,modify_user,modify_datetime)
				VALUES(arg_hotel_group_id,arg_hotel_id,0,'F',var_applname,var_applicant,0,var_class,0,0,0,var_biz_date,
					var_sta,var_rmtype,var_rmno,var_rmnum,var_arr,var_dep,var_adult,var_children,'I',NULL,var_uptype,var_upreason,IF(var_uptype<>'','ADMIN',''),var_qtrate,var_rmrate,var_setrate,'',var_qtrate-var_setrate,0,
					'I',var_sta,'F','F','',var_cid,var_aid,var_sid,var_cardcode,var_cardno,var_saleid,'','',
					var_src,var_mkt,var_rsv_type,var_channel,var_ratecode,'',var_packages,var_srqs,var_amenities,
					'F','F','T','F','F','0','F','0',
					var_accnt,'000000000000000000000000000000',0,0,0,0,IFNULL(var_paycode,'9000'),0,'','','',
					var_balance,0,0,1,0,0,0,0,var_resno, var_crsno,
					var_wherefrom,var_whereto,'I',var_ref,var_comsg,var_cby,var_changed,var_cby,var_changed);
			END IF;
				
			SET var_last_accnt = var_accnt;			
			SET var_id = LAST_INSERT_ID(); 
			
			IF var_profile_id > 0 THEN 
				INSERT INTO master_guest (hotel_group_id,hotel_id,id,profile_type,profile_id,times_in,name,last_name,first_name,name2,name3,name_combine,
					sex,language,title,salutation,interest,birth,race,religion,career,occupation,nation,country,state,city,division,street,zipcode,
					vip,phone,mobile,fax,email,id_code,id_no,id_end,visa_type,visa_no,visa_begin,visa_end,visa_grant,enter_port,enter_date,enter_date_end,
					photo_pic,photo_sign,remark,room_prefer,feature,create_user,create_datetime,modify_user,modify_datetime)
				SELECT arg_hotel_group_id,arg_hotel_id,var_id,'GUEST',a.id,var_itimes,a.name,a.last_name,a.first_name,a.name2,a.name3,a.name_combine,
					a.sex,a.language,a.title,a.salutation,'',var_birth,a.race,a.religion,a.career,a.occupation,var_nation,var_nation,'','','','','',
					d.vip,var_phone,LEFT(b.mobile,20),var_fax,var_email,a.id_code,a.id_no,a.id_end,var_visaid,'',NULL,var_visaend,'',var_rjplace,NULL,var_rjdate,
					0,0,'','',var_feature,var_cby,var_changed,var_cby,var_changed
					FROM guest_base a,guest_link_base b,guest_type d
					WHERE a.id=var_profile_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=0 AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=0 AND a.id=b.id 
						AND d.hotel_group_id=arg_hotel_group_id AND d.hotel_id=arg_hotel_id AND a.id=d.guest_id ;
			ELSE
				INSERT INTO master_guest (hotel_group_id,hotel_id,id,profile_type,profile_id,times_in,name,last_name,first_name,name2,name3,name_combine,
					sex,language,title,salutation,interest,birth,race,religion,career,occupation,nation,country,state,city,division,street,zipcode,
					vip,phone,mobile,fax,email,id_code,id_no,id_end,visa_type,visa_no,visa_begin,visa_end,visa_grant,enter_port,enter_date,enter_date_end,
					photo_pic,photo_sign,remark,room_prefer,feature,create_user,create_datetime,modify_user,modify_datetime)
				VALUES(arg_hotel_group_id,arg_hotel_id,var_id,'GUEST',0,var_itimes,var_name,var_lname,var_fname,var_name2,var_name3,var_name4,
					var_sex,'C','','','',var_birth,'','','','',var_nation,var_nation,'','','',var_address,'',
					var_vip,var_phone,'',var_fax,var_email,var_idcls,var_ident,NULL,var_visaid,'',NULL,var_visaend,'',var_rjplace,NULL,var_rjdate,
					0,0,'','',var_feature,var_cby,var_changed,var_cby,var_changed);
			END IF; 			
			
			INSERT INTO master_stalog (hotel_group_id,hotel_id,id,rsv_user,rsv_datetime,ci_user,ci_datetime,co_user,co_datetime,dep_user,dep_datetime,modify_user,modify_datetime)
			VALUES(arg_hotel_group_id,arg_hotel_id,var_id,var_cby,var_arr,var_cby,var_changed,'',NULL,var_cby,var_changed,var_cby,var_changed);
					
			SET done_cursor = 0 ;
			FETCH c_master INTO var_accnt,var_guestid,var_rmtype,var_rmno,var_arr,var_dep,var_cusno,var_agent,var_source,var_cardcode,var_cardno,var_saleid,var_name,var_lname,var_fname,var_name2,var_name3,var_name4,
					var_ratecode,var_src,var_mkt,var_qtrate,var_rmrate,var_setrate,var_rtreason,var_paycode,var_srqs,var_ref,var_haccnt,var_sex,var_amenities,var_uptype,var_upreason,var_visaid,var_visaend,var_rjplace,var_rjdate,
					var_birth,var_vip,var_idcls,var_ident,var_nation,var_race,var_address,var_birthplace,var_balance,var_itimes,var_changed,var_phone,var_fax,var_email,var_feature,
					var_sta,var_class,var_pcrec,var_comsg,var_cby,var_rsv_type,var_channel,var_resno,var_crsno,var_packages,var_adult,var_children,var_rmnum,var_applname,var_applicant;
		END ;
	END WHILE ;
	CLOSE c_master ;
	
	-- 产生帐户对照表
	INSERT INTO up_map_accnt(hotel_group_id,hotel_id,accnt_type,accnt_class,accnt_old,accnt_new) 
		SELECT arg_hotel_group_id,arg_hotel_id,'master_si',CONCAT(rsv_class,sta),sc_flag,id FROM master_base
			WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND sc_flag<>'' AND sc_flag IS NOT NULL AND sta IN ('I','S','O') AND rsv_class IN ('F','G');
	
	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='MASTER_SI';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='MASTER_SI';

END$$

DELIMITER ;