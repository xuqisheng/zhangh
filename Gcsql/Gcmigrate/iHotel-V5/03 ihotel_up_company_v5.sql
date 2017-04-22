DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_company_v5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_company_v5`(
	IN arg_hotel_group_id BIGINT(16),
	IN arg_hotel_id 	  BIGINT(16)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- =============================
	-- 公司档案导入
	-- =============================
	DECLARE var_no 		CHAR(7);
	DECLARE var_sno 	CHAR(15);
	DECLARE var_sta 	CHAR(1);
	DECLARE var_name 	VARCHAR(60);
	DECLARE var_nation 	VARCHAR(3);
	DECLARE var_class 	CHAR(1);
	DECLARE var_class1 	CHAR(3);
	DECLARE var_class2 	CHAR(3);
	DECLARE var_class3 	CHAR(3);
	DECLARE var_lawman 	CHAR(16);
	DECLARE var_address VARCHAR(60);
	DECLARE var_zip 	CHAR(12);
	DECLARE var_phone 	VARCHAR(20);
	DECLARE var_fax 	VARCHAR(20);
	DECLARE var_wwwinfo VARCHAR(40);
	DECLARE var_regno 	VARCHAR(20);
	DECLARE var_liason 	VARCHAR(15);
	DECLARE var_liason1 VARCHAR(30);
	DECLARE var_arr DATETIME;
	DECLARE var_dep DATETIME;
	DECLARE var_tranlog CHAR(10);
	DECLARE var_extrainf VARCHAR(30);
	DECLARE var_postctrl CHAR(1);
	DECLARE var_request VARCHAR(60);
	DECLARE var_descript VARCHAR(512);
	DECLARE var_saleid 	VARCHAR(12);
	DECLARE var_araccnt1 CHAR(7);
	DECLARE var_araccnt2 CHAR(7);
	DECLARE var_i_times INT(8);
	DECLARE var_x_times INT(8);
	DECLARE var_n_times INT(8);
	DECLARE var_l_times INT(8);
	DECLARE var_i_days  INT(8);
	DECLARE var_tl 		DECIMAL(12,2);
	DECLARE var_rm 		DECIMAL(12,2);
	DECLARE var_rm_b 	DECIMAL(12,2);
	DECLARE var_rm_e 	DECIMAL(12,2);
	DECLARE var_fb 		DECIMAL(12,2);
	DECLARE var_en 		DECIMAL(12,2);
	DECLARE var_ot 		DECIMAL(12,2);
	DECLARE var_cby 	VARCHAR(10);
	DECLARE var_cbyname VARCHAR(20);
	DECLARE var_changed DATETIME;
	DECLARE var_exp_m 	BIGINT(20);
	DECLARE var_exp_dt 	DATETIME;
	DECLARE var_exp_s 	CHAR(10);
	DECLARE var_more TEXT;
	DECLARE var_logmark INT(8);
	DECLARE var_company_id INT;
	DECLARE var_companyid 	INT;
	DECLARE var_code1 		VARCHAR(20);
	DECLARE var_valid_begin DATETIME;
	DECLARE var_valid_end 	DATETIME;
    DECLARE done_cursor INT DEFAULT 0;

	DECLARE c_cursor CURSOR FOR SELECT NO,sno,sta,NAME,nation,class,class1,class2,class3,lawman,address,zip,
		phone,fax,wwwinfo,regno,liason,liason1,arr,dep,tranlog,extrainf,postctrl,request,descript,saleid,araccnt1,araccnt2,
		i_times,x_times,n_times,l_times,i_days,tl,rm,rm_b,rm_e,fb,en,ot,cby,cbyname,CHANGED,exp_m,exp_dt,exp_s,more,logmark 
		FROM migrate_xc.cusinf;
		
	DECLARE c_profile CURSOR FOR SELECT company_id,code1,valid_begin,valid_end FROM company_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND code1 <> '';
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	DELETE FROM up_status WHERE hotel_id=arg_hotel_id AND up_step='COMPANY';
	INSERT INTO up_status(hotel_id,up_step,time_begin,time_end,time_long,remark) VALUES(arg_hotel_id,'COMPANY',NOW(),NULL,0,''); 

	OPEN c_cursor;
	SET done_cursor = 0;
	FETCH c_cursor INTO var_no,var_sno,var_sta,var_name,var_nation,var_class,var_class1,var_class2,var_class3,var_lawman,var_address,var_zip,
		var_phone,var_fax,var_wwwinfo,var_regno,var_liason,var_liason1,var_arr,var_dep,var_tranlog,var_extrainf,var_postctrl,var_request,var_descript,var_saleid,var_araccnt1,var_araccnt2,
		var_i_times,var_x_times,var_n_times,var_l_times,var_i_days,var_tl,var_rm,var_rm_b,var_rm_e,var_fb,var_en,var_ot,var_cby,var_cbyname,var_changed,var_exp_m,var_exp_dt,var_exp_s,var_more,var_logmark;
	WHILE done_cursor = 0 DO
		
		INSERT INTO company_base(hotel_group_id,hotel_id,NAME,name2,name3,name_combine,is_save,LANGUAGE,nation,
			phone,mobile,fax,email,website,blog,linkman1,linkman2,country,state,city,division,street,zipcode,representative,register_no,
			bank_name,bank_account,tax_no,remark,create_hotel,create_user,create_datetime,modify_hotel,modify_user,modify_datetime) 
		VALUES(arg_hotel_group_id,0,var_name,var_name,var_name,var_name,'F','C',var_nation,
			var_phone,var_liason1,var_fax,'',var_wwwinfo,'',var_liason,'',var_nation,'','','',var_address,var_zip,var_lawman,'',
			'','','','',arg_hotel_id,var_cby,var_changed,arg_hotel_id,var_cby,var_changed);
			
		SET var_company_id=LAST_INSERT_ID();
		
		-- 酒店档案
		IF NOT EXISTS(SELECT 1 FROM company_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND company_id = var_company_id) THEN
		    INSERT INTO company_type (hotel_group_id,hotel_id,company_id,sta,manual_no,sys_cat,flag_cat,grade,latency,class1,class2,class3,class4,
				src,market,vip,belong_app_code,membership_type,membership_no,membership_level,over_rsvsrc,valid_begin,valid_end,code1,code2,code3,code4,code5,
				flag,saleman,ar_no1,ar_no2,extra_flag,extra_info,comments,create_user,create_datetime,modify_user,modify_datetime) 
			VALUES(arg_hotel_group_id,arg_hotel_id,var_company_id,var_sta,var_no,var_class,'','','',var_class,var_class1,var_class2,var_class3,
				'','','','','','','','F',var_arr,var_dep,var_tranlog,'','','','',
				'',var_saleid,var_araccnt1,var_araccnt2,'000000000000000000000000000000','',var_descript,var_cby,var_changed,var_cby,var_changed);
		END IF;
		
		-- 集团档案
		IF NOT EXISTS(SELECT 1 FROM company_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND company_id = var_company_id) THEN
		    INSERT INTO company_type (hotel_group_id,hotel_id,company_id,sta,manual_no,sys_cat,flag_cat,grade,latency,class1,class2,class3,class4,
				src,market,vip,belong_app_code,membership_type,membership_no,membership_level,over_rsvsrc,valid_begin,valid_end,code1,code2,code3,code4,code5,
				flag,saleman,ar_no1,ar_no2,extra_flag,extra_info,comments,create_user,create_datetime,modify_user,modify_datetime) 
			VALUES(arg_hotel_group_id,0,var_company_id,var_sta,var_no,var_class,'','','',var_class,var_class1,var_class2,var_class3,
				'','','','','','','','F',var_arr,var_dep,'','','','','',
				'','',var_araccnt1,var_araccnt2,'000000000000000000000000000000','',var_descript,var_cby,var_changed,var_cby,var_changed);
		END IF;
		     
		IF var_request <> '' AND NOT EXISTS(SELECT 1 FROM company_prefer WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND company_id = var_company_id) THEN
			INSERT INTO company_prefer (hotel_group_id,hotel_id,company_id,specials,amenity,feature,room_prefer,interest,
				prefer_front,prefer_fb,prefer_other,create_user,create_datetime,modify_user,modify_datetime) 
			VALUES(arg_hotel_group_id,arg_hotel_id,var_company_id,'','','','','',var_request,'','',var_cby,var_changed,var_cby,var_changed);
		END IF;
		IF var_request <> '' AND NOT EXISTS(SELECT 1 FROM company_prefer WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND company_id = var_company_id) THEN
			INSERT INTO company_prefer (hotel_group_id,hotel_id,company_id,specials,amenity,feature,room_prefer,interest,
				prefer_front,prefer_fb,prefer_other,create_user,create_datetime,modify_user,modify_datetime) 
			VALUES(arg_hotel_group_id,0,var_company_id,'','','','','',var_request,'','',var_cby,var_changed,var_cby,var_changed);
		END IF;
		     
		IF NOT EXISTS(SELECT 1 FROM company_production WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND company_id = var_company_id) THEN
		    INSERT INTO company_production(hotel_group_id,hotel_id,company_id,first_visit_date,first_visit_room,first_visit_rate,last_visit_date,last_visit_room,last_visit_rate,
				days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
				production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime) 
			VALUES(arg_hotel_group_id,arg_hotel_id,var_company_id,NULL,'','0',NULL,'','0',var_i_days,var_i_times,var_x_times,var_n_times,'0','0','0',
				var_rm,var_rm_b,var_rm_e,'0.00',var_ot,var_tl,var_cby,var_changed,var_cby,var_changed);
		    INSERT INTO company_production_old(hotel_group_id,hotel_id,company_id,first_visit_date,first_visit_room,first_visit_rate,last_visit_date,last_visit_room,last_visit_rate,
				days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
				production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime) 
			VALUES(arg_hotel_group_id,arg_hotel_id,var_company_id,NULL,'','0',NULL,'','0',var_i_days,var_i_times,var_x_times,var_n_times,'0','0','0',
				var_rm,var_rm_b,var_rm_e,'0.00',var_ot,var_tl,var_cby,var_changed,var_cby,var_changed);				
		END IF;
		IF NOT EXISTS(SELECT 1 FROM company_production WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND company_id = var_company_id) THEN
		    INSERT INTO company_production(hotel_group_id,hotel_id,company_id,first_visit_date,first_visit_room,first_visit_rate,last_visit_date,last_visit_room,last_visit_rate,
				days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
				production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
			VALUES(arg_hotel_group_id,0,var_company_id,NULL,'','0',NULL,'','0',var_i_days,var_i_times,var_x_times,var_n_times,'0','0','0',
				var_rm,var_rm_b,var_rm_e,'0.00',var_ot,var_tl,var_cby,var_changed,var_cby,var_changed);
		END IF;
		
		IF var_company_id IS NOT NULL THEN
			INSERT INTO up_map_accnt(hotel_group_id,hotel_id,accnt_type,accnt_class,accnt_old,accnt_new) VALUES(arg_hotel_group_id,arg_hotel_id,'COMPANY','',var_no,var_company_id);
		END IF;
		
		SET done_cursor = 0;
		FETCH c_cursor INTO var_no,var_sno,var_sta,var_name,var_nation,var_class,var_class1,var_class2,var_class3,var_lawman,var_address,var_zip,
			var_phone,var_fax,var_wwwinfo,var_regno,var_liason,var_liason1,var_arr,var_dep,var_tranlog,var_extrainf,var_postctrl,var_request,var_descript,var_saleid,var_araccnt1,var_araccnt2,
			var_i_times,var_x_times,var_n_times,var_l_times,var_i_days,var_tl,var_rm,var_rm_b,var_rm_e,var_fb,var_en,var_ot,var_cby,var_cbyname,var_changed,var_exp_m,var_exp_dt,var_exp_s,var_more,var_logmark;
		END WHILE;
	CLOSE c_cursor;
  		
	-- UPDATE company_type a,up_map_code b SET a.class1 = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code_old = a.class1 AND b.cat = 'cuscls';
	UPDATE company_type a,up_map_code b SET a.code1 = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code_old = a.code1 AND b.cat = 'ratecode';
	UPDATE company_type a,up_map_code b SET a.saleman = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code_old = a.saleman AND b.cat = 'salesman';
	
	-- ==================================================
	-- 根据协议公司主单上的房价码生成profileExtra中的值
	-- ==================================================	
	DELETE FROM profile_extra WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id AND extra_item = 'RATECODE' AND master_type = 'COMPANY';
	
	OPEN c_profile;
	SET done_cursor = 0;
	FETCH c_profile INTO var_companyid,var_code1,var_valid_begin,var_valid_end;
		WHILE done_cursor = 0 DO		
			IF NOT EXISTS(SELECT 1 FROM profile_extra WHERE extra_item = 'RATECODE' AND master_type = 'COMPANY' AND master_id = var_company_id AND hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id) THEN	    
				INSERT INTO profile_extra(hotel_group_id,hotel_id,extra_item,master_type,master_id,extra_value,date_begin,date_end,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime)
					VALUES(arg_hotel_group_id,arg_hotel_id,'RATECODE','COMPANY',var_companyid,var_code1,var_valid_begin,var_valid_end,'F','0','ADMIN',NOW(),'ADMIN',NOW());
			END IF;			
			SET done_cursor = 0;
			FETCH c_profile INTO var_companyid,var_code1,var_valid_begin,var_valid_end;
		END WHILE;
	CLOSE c_profile;
	
	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='COMPANY';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='COMPANY';
	
END$$

DELIMITER ;