DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_guest_fit_v5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_guest_fit_v5`(
	IN arg_hotel_group_id BIGINT(16), 
	IN arg_hotel_id 	BIGINT(16)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ======================================================
	-- 客史档案导入(散客) 公司和前台喜好拼起来
	-- ======================================================
	DECLARE var_no 		CHAR(7);
	DECLARE var_sno 	CHAR(15);
	DECLARE var_name 	VARCHAR(50);
	DECLARE var_lname 	VARCHAR(30);
	DECLARE var_ename 	VARCHAR(50);
	DECLARE var_call2  	CHAR(12);
	DECLARE var_nameetc VARCHAR(255);
	DECLARE var_inman 	VARCHAR(10);
	DECLARE var_linkman VARCHAR(10);
	DECLARE var_postman VARCHAR(10);
	DECLARE var_sex 	CHAR(1);
	DECLARE var_birthplace CHAR(6);
	DECLARE var_birth 	DATETIME;
	DECLARE var_occupation  CHAR(2);
	DECLARE var_vip  	CHAR(1);
	DECLARE var_secret  CHAR(1);
	DECLARE var_mkt  	VARCHAR(10);
	DECLARE var_nation  CHAR(3);
	DECLARE var_race  	CHAR(2);
	DECLARE var_reg  	CHAR(5);
	DECLARE var_address  VARCHAR(60);
	DECLARE var_fir  	VARCHAR(60);
	DECLARE var_zip  	CHAR(6);
	DECLARE var_idcls  	CHAR(3);
	DECLARE var_ident  	VARCHAR(18);
	DECLARE var_srqs  	VARCHAR(18);
	DECLARE var_request  VARCHAR(60);
	DECLARE var_extrainf VARCHAR(30);
	DECLARE var_cusno 	CHAR(7);
	DECLARE var_tranlog VARCHAR(10);
	DECLARE var_saleid 	VARCHAR(12);
	DECLARE var_araccnt1  CHAR(7);
	DECLARE var_araccnt2  CHAR(7);
	DECLARE var_photopath VARCHAR(60);
	DECLARE var_signpath  VARCHAR(60);
	DECLARE var_i_times INT(8);
	DECLARE var_x_times INT(8);
	DECLARE var_n_times INT(8);
	DECLARE var_l_times INT(8);
	DECLARE var_i_days 	INT(8);
	DECLARE var_tl 		DECIMAL(12,2);
	DECLARE var_rm 		DECIMAL(12,2);
	DECLARE var_rm_b 	DECIMAL(12,2);
	DECLARE var_rm_e 	DECIMAL(12,2);
	DECLARE var_fb 		DECIMAL(12,2);
	DECLARE var_en 		DECIMAL(12,2);
	DECLARE var_ot 		DECIMAL(12,2);
	DECLARE var_cby 	CHAR(3);
	DECLARE var_changed DATETIME; 
	DECLARE var_ref 	VARCHAR(250);
	DECLARE var_remark 	TEXT;
	DECLARE var_exp_m 	BIGINT(20);
	DECLARE var_exp_dt 	DATETIME;
	DECLARE var_exp_s 	VARCHAR(10);
	DECLARE var_logmark INT(8);
	DECLARE var_s1		VARCHAR(512);
	DECLARE var_s2		VARCHAR(512);
	DECLARE var_s5		VARCHAR(512);
	DECLARE var_guest_id INT;
	DECLARE done_cursor INT DEFAULT 0;
	
	DECLARE c_cursor CURSOR FOR SELECT a.no,a.sno,a.name,a.lname,a.ename,a.call2,a.nameetc,a.inman,a.linkman,a.postman,a.sex, 
		a.birthplace,a.birth,a.occupation,a.vip,a.secret,a.mkt,a.nation,a.race,a.reg,a.address,a.fir,a.zip,a.idcls,a.ident,a.srqs, 
		a.request,a.extrainf,a.cusno,a.tranlog,a.saleid,a.araccnt1,a.araccnt2,a.photopath,a.signpath,a.i_times,a.x_times,a.n_times, 
		a.l_times,a.i_days,a.tl,a.rm,a.rm_b,a.rm_e,a.fb,a.en,a.ot,a.cby,a.changed,a.ref,a.remark,a.exp_m,a.exp_dt,a.exp_s,a.logmark,b.s1,b.s2,b.s5 
		FROM migrate_xc.hgstinf a LEFT JOIN migrate_xc.hgstinf_xh b ON a.no = b.no;
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	DELETE FROM up_status WHERE hotel_id=arg_hotel_id AND up_step='GUEST_FIT';
	INSERT INTO up_status(hotel_id,up_step,time_begin,time_end,time_long,remark) VALUES(arg_hotel_id,'GUEST_FIT', NOW(),NULL,0,''); 
		
    OPEN c_cursor;
	SET done_cursor = 0;
	FETCH c_cursor INTO var_no,var_sno,var_name,var_lname,var_ename,var_call2,var_nameetc,var_inman,var_linkman,var_postman,var_sex,
		var_birthplace,var_birth,var_occupation,var_vip,var_secret,var_mkt,var_nation,var_race,var_reg,var_address,var_fir,var_zip,var_idcls,var_ident,var_srqs,
		var_request,var_extrainf,var_cusno,var_tranlog,var_saleid,var_araccnt1,var_araccnt2,var_photopath,var_signpath,var_i_times,var_x_times,var_n_times,var_l_times,
		var_i_days,var_tl,var_rm,var_rm_b,var_rm_e,var_fb,var_en,var_ot,var_cby,var_changed,var_ref,var_remark,var_exp_m,var_exp_dt,var_exp_s,var_logmark,var_s1,var_s2,var_s5;
	WHILE done_cursor = 0 DO
		
		INSERT INTO guest_base(hotel_group_id,hotel_id,NAME,last_name,first_name,name2,name3,name_combine,is_save,
			sex,LANGUAGE,title,salutation,birth,race,religion,career,occupation,nation,id_code,id_no,id_end,company_id,
			company_name,pic_photo,pic_sign,remark,create_hotel,create_user,create_datetime,modify_hotel,modify_user,modify_datetime) 
		VALUES(arg_hotel_group_id,0,var_name,'',var_lname,var_name,var_name,var_name,'F',
			var_sex,'C','','',var_birth,var_race,'','',var_occupation,var_nation,var_idcls,var_ident,NULL,NULL,
			'',NULL,NULL,var_remark,arg_hotel_id,var_cby,var_changed,arg_hotel_id,var_cby,var_changed);
			
		SET var_guest_id=LAST_INSERT_ID();
		
		IF NOT EXISTS(SELECT 1 FROM guest_link_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND id = var_guest_id) THEN
			INSERT INTO guest_link_base(hotel_group_id, hotel_id, id, mobile, phone, fax, email, website, msn, qq, sns, blog, 
				linkman1, linkman2, create_hotel, create_user, create_datetime, modify_hotel, modify_user, modify_datetime) 
			VALUES(arg_hotel_group_id,0,var_guest_id,'',var_ename,'',var_extrainf,'','','','','',
				var_linkman,var_postman,arg_hotel_id,var_cby,var_changed,arg_hotel_id,var_cby,var_changed);
		END IF;
		
		IF NOT EXISTS(SELECT 1 FROM guest_link_addr WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND guest_id = var_guest_id) THEN
			INSERT INTO guest_link_addr (hotel_group_id, hotel_id, guest_id, addr_name, addr_type, is_default, country,state, 
				city, division, street, zipcode, list_order, remark, create_hotel, create_user, create_datetime, modify_hotel, modify_user, modify_datetime) 
			VALUES(arg_hotel_group_id,0,var_guest_id,'默认地址','HOME','T','CN','',
				'',var_birthplace,var_address,var_zip,'0','',arg_hotel_id,var_cby,var_changed,arg_hotel_id,var_cby,var_changed);
		END IF;
		-- 酒店客史档案 
		IF NOT EXISTS(SELECT 1 FROM guest_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_id = var_guest_id) THEN
			INSERT INTO guest_type (hotel_group_id, hotel_id, guest_id, sta, manual_no, sys_cat, flag_cat, grade, latency, 
				class1, class2, class3, class4, src, market, vip, belong_app_code, membership_type, membership_no, membership_level, 
				over_rsvsrc, valid_begin, valid_end, code1, code2, code3, code4, code5, flag, saleman, ar_no1, ar_no2, 
				extra_flag, extra_info, comments, create_user, create_datetime, modify_user, modify_datetime) 
			VALUES(arg_hotel_group_id,arg_hotel_id,var_guest_id,'I',var_no,'F','','','',
				'','','','','',var_mkt,var_vip,'','','','','F',NULL,NULL,'','','','','','',var_saleid,NULL,NULL,
				'000000000000000000000000000000','',var_remark,var_cby,var_changed,var_cby,var_changed);
		END IF;
		-- 集团客史档案
		IF NOT EXISTS(SELECT 1 FROM guest_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND guest_id = var_guest_id) THEN
			INSERT INTO guest_type (hotel_group_id, hotel_id, guest_id, sta, manual_no, sys_cat, flag_cat, grade, latency, 
				class1, class2, class3, class4, src, market, vip, belong_app_code, membership_type, membership_no, membership_level, 
				over_rsvsrc, valid_begin, valid_end, code1, code2, code3, code4, code5, flag, saleman, ar_no1, ar_no2, extra_flag, 
				extra_info, comments, create_user, create_datetime, modify_user, modify_datetime) 
			VALUES(arg_hotel_group_id,0,var_guest_id,'I',var_no,'F','','','',
				'','','','','',var_mkt,var_vip,'','','','','F',NULL,NULL,'','','','','','',var_saleid,NULL,NULL,
				'000000000000000000000000000000','',var_remark,var_cby,var_changed,var_cby,var_changed);
		END IF;
		IF (var_s1 <> '' OR var_s2 <> '' OR var_s5 <> '') AND NOT EXISTS(SELECT 1 FROM guest_prefer WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_id = var_guest_id) THEN
			  INSERT INTO guest_prefer (hotel_group_id,hotel_id,guest_id,specials,amenity,feature,room_prefer,interest,
					prefer_front,prefer_fb,prefer_other,create_user,create_datetime,modify_user,modify_datetime) 
				VALUES(arg_hotel_group_id,arg_hotel_id,var_guest_id,var_srqs,var_request,NULL,NULL,NULL,
					CONCAT(var_fir,'===',var_s1),var_s2,var_s5,var_cby,var_changed,var_cby,var_changed);
		END IF;	
		
		IF NOT EXISTS(SELECT 1 FROM guest_production WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_id = var_guest_id) THEN
		    INSERT INTO guest_production (hotel_group_id, hotel_id, guest_id, first_visit_date, first_visit_room,
				first_visit_rate, last_visit_date, last_visit_room, last_visit_rate, days_in, times_in, times_cxl, times_noshow, 
				times_trans, times_fb, times_en, production_rm, production_fb, production_en, production_mt, production_ot, 
				production_ttl, create_user, create_datetime,modify_user, modify_datetime) 
			VALUES(arg_hotel_group_id,arg_hotel_id,var_guest_id,NULL,'','0',NULL,'','0',var_i_days,var_i_times,var_x_times,var_n_times,'0','0','0',var_rm,var_rm_b,
				var_rm_e,'0',var_ot,var_tl,var_cby,var_changed,var_cby,var_changed);
			
		    INSERT INTO guest_production_old(hotel_group_id, hotel_id, guest_id, first_visit_date, first_visit_room,first_visit_rate, last_visit_date, last_visit_room, last_visit_rate, 
				days_in, times_in, times_cxl, times_noshow,times_trans, times_fb, times_en, 
				production_rm, production_fb, production_en, production_mt, production_ot,production_ttl, create_user, create_datetime,modify_user, modify_datetime) 
			VALUES(arg_hotel_group_id,arg_hotel_id,var_guest_id,NULL,'','0',NULL,'','0',
				var_i_days,var_i_times,var_x_times,var_n_times,'0','0','0',
				var_rm,var_rm_b,var_rm_e,'0',var_ot,var_tl,var_cby,var_changed,var_cby,var_changed);
		END IF;
		IF NOT EXISTS(SELECT 1 FROM guest_production WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND guest_id = var_guest_id) THEN
			INSERT INTO guest_production(hotel_group_id, hotel_id, guest_id, first_visit_date, first_visit_room,first_visit_rate, last_visit_date, last_visit_room, last_visit_rate,
				days_in, times_in, times_cxl, times_noshow,times_trans, times_fb, times_en,
				production_rm, production_fb, production_en, production_mt, production_ot,production_ttl, create_user, create_datetime,modify_user, modify_datetime) 
			VALUES(arg_hotel_group_id,0,var_guest_id,NULL,'','0',NULL,'','0',
				var_i_days,var_i_times,var_x_times,var_n_times,'0','0','0',
				var_rm,var_rm_b,var_rm_e,'0',var_ot,var_tl,var_cby,var_changed,var_cby,var_changed);    
		END IF;		
		
		IF var_guest_id IS NOT NULL THEN
			INSERT INTO up_map_accnt(hotel_group_id,hotel_id,accnt_type,accnt_class,accnt_old,accnt_new) VALUES(arg_hotel_group_id,arg_hotel_id,'GUEST_FIT','F',var_no,var_guest_id);
		END IF;
		SET done_cursor = 0;
		FETCH c_cursor INTO var_no,var_sno,var_name,var_lname,var_ename,var_call2,var_nameetc,var_inman,var_linkman,var_postman,var_sex,
			var_birthplace,var_birth,var_occupation,var_vip,var_secret,var_mkt,var_nation,var_race,var_reg,var_address,var_fir,var_zip,var_idcls,var_ident,var_srqs,
			var_request,var_extrainf,var_cusno,var_tranlog,var_saleid,var_araccnt1,var_araccnt2,var_photopath,var_signpath,var_i_times,var_x_times,var_n_times,var_l_times,
			var_i_days,var_tl,var_rm,var_rm_b,var_rm_e,var_fb,var_en,var_ot,var_cby,var_changed,var_ref,var_remark,var_exp_m,var_exp_dt,var_exp_s,var_logmark,var_s1,var_s2,var_s5;
	END WHILE;
	CLOSE c_cursor;
    
	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='GUEST_FIT';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='GUEST_FIT';

END$$

DELIMITER ;