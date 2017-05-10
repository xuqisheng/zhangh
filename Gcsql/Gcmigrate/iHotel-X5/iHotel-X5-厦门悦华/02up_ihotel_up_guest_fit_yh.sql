DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_up_guest_fit_yh`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_up_guest_fit_yh`(
	IN arg_hotel_group_id BIGINT(16),
	IN arg_hotel_id 	BIGINT(16)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ==================================
	-- 客史档案导入 散客
	-- ==================================
	DECLARE done_cursor INT DEFAULT 0;
	DECLARE var_no 		VARCHAR(10);
	DECLARE var_sno 	VARCHAR(15);
	DECLARE var_cno 	VARCHAR(15);
	DECLARE var_name 	VARCHAR(50);
	DECLARE var_lname 	VARCHAR(30);
	DECLARE var_fname 	VARCHAR(30);
	DECLARE var_name2 	VARCHAR(50);
	DECLARE var_name3 	VARCHAR(50);
	DECLARE var_name4 	VARCHAR(50);
	DECLARE var_lang 	VARCHAR(10);
	DECLARE var_title 	VARCHAR(10);
	DECLARE var_salutation 	VARCHAR(60);
	DECLARE var_liason 	VARCHAR(30);
	DECLARE var_liason1 	VARCHAR(30);
	DECLARE var_sex 	VARCHAR(10);
	DECLARE var_city 	VARCHAR(6);
	DECLARE var_birth 	DATETIME;
	DECLARE var_occupation  VARCHAR(10);
	DECLARE var_vip  	VARCHAR(10);
	DECLARE var_src  	VARCHAR(10);
	DECLARE var_market  	VARCHAR(10);
	DECLARE var_nation  	VARCHAR(10);
	DECLARE var_race  	VARCHAR(10);
	DECLARE var_religion  	VARCHAR(10);
	DECLARE var_street  	VARCHAR(60);
	DECLARE var_mobile 	VARCHAR(20);
	DECLARE var_phone  	VARCHAR(20);
	DECLARE var_fax	   	VARCHAR(25);
	DECLARE var_wetsite 	VARCHAR(60);
	DECLARE var_email   	VARCHAR(30);
	DECLARE var_unit  	VARCHAR(60);
	DECLARE var_zip  	VARCHAR(6);
	DECLARE var_idcls  	VARCHAR(10);
	DECLARE var_ident  	VARCHAR(20);
	DECLARE var_idend  	DATETIME;
	DECLARE var_srqs  	VARCHAR(18);
	DECLARE var_rmpref  	VARCHAR(60);
	DECLARE var_extrainf 	VARCHAR(30);
	DECLARE var_cusno 	VARCHAR(7);
	DECLARE var_saleid 	VARCHAR(12);
	DECLARE var_araccnt1  	VARCHAR(7);
	DECLARE var_araccnt2  	VARCHAR(7);
	DECLARE var_i_times 	INT(11);
	DECLARE var_x_times 	INT(11);
	DECLARE var_n_times 	INT(11);
	DECLARE var_l_times 	INT(11);
	DECLARE var_i_days 	INT(11);
	DECLARE var_tl 		DECIMAL(12,2);
	DECLARE var_rm 		DECIMAL(12,2);
	DECLARE var_fb 		DECIMAL(12,2);
	DECLARE var_en 		DECIMAL(12,2);
	DECLARE var_ot 		DECIMAL(12,2);
	DECLARE var_mt 		DECIMAL(12,2);
	DECLARE var_refer1	VARCHAR(250);
	DECLARE var_refer2	VARCHAR(250);
	DECLARE var_refer3	VARCHAR(250);
	DECLARE var_class1	VARCHAR(10);
	DECLARE var_class2	VARCHAR(10);
	DECLARE var_class3	VARCHAR(10);
	DECLARE var_class4	VARCHAR(10);
	DECLARE var_code1	VARCHAR(10);
	DECLARE var_code2	VARCHAR(10);
	DECLARE var_code3	VARCHAR(10);
	DECLARE var_code4	VARCHAR(10);
	DECLARE var_code5	VARCHAR(10);	
	DECLARE var_cby 	VARCHAR(10);
	DECLARE var_changed 	DATETIME; 
	DECLARE var_comment 	VARCHAR(1000);
	DECLARE var_remark 	TEXT;
	DECLARE var_exp_m 	BIGINT(20);
	DECLARE var_exp_dt 	DATETIME;
	DECLARE var_exp_s 	VARCHAR(10);
	DECLARE var_logmark 	INT(11);
	DECLARE var_guest_id 	INT;
	DECLARE var_amenity 	VARCHAR(50);
	DECLARE var_feature 	VARCHAR(50);
	DECLARE var_latency	VARCHAR(10);
	DECLARE var_cardno	VARCHAR(20);
	DECLARE var_country	VARCHAR(10);
	DECLARE var_state	VARCHAR(10);
	DECLARE var_town	VARCHAR(50);
	DECLARE var_country1	VARCHAR(10);
	DECLARE var_state1	VARCHAR(10);
	DECLARE var_town1	VARCHAR(50);
	DECLARE var_city1	VARCHAR(20);
	DECLARE var_street1	VARCHAR(100);
	DECLARE var_zip1	VARCHAR(10);
	DECLARE var_mobile1	VARCHAR(20);
	DECLARE var_phone1	VARCHAR(20);
	DECLARE var_fax1	VARCHAR(20);
	DECLARE var_email1	VARCHAR(50);
	DECLARE var_visaid	VARCHAR(10);
	DECLARE var_visaend	DATETIME;
	DECLARE var_visano	VARCHAR(20);
	DECLARE var_visaunit	VARCHAR(10);
	DECLARE var_rjplace	VARCHAR(10);
	DECLARE var_lawman	VARCHAR(20);
	DECLARE var_regno	VARCHAR(20);
	DECLARE var_bank	VARCHAR(50);
	DECLARE var_bankno	VARCHAR(30);
	DECLARE var_taxno	VARCHAR(20);
	DECLARE var_arr		DATETIME;
	DECLARE var_dep		DATETIME;
	DECLARE var_fvdate	DATETIME;
	DECLARE var_fvroom	VARCHAR(10);
	DECLARE var_fvrate	DECIMAL(12,2);
	DECLARE var_lvdate	DATETIME;
	DECLARE var_lvroom	VARCHAR(10);
	DECLARE var_lvrate	DECIMAL(12,2);
	DECLARE var_crtby	VARCHAR(10);
	DECLARE var_crttime	DATETIME;
	DECLARE var_sta		CHAR(1);
	DECLARE var_interest 	VARCHAR(50);
	DECLARE var_belong	VARCHAR(10);
	DECLARE var_hotel_code	VARCHAR(12);
	DECLARE c_cursor CURSOR FOR SELECT NO,sta,sno,cno,TRIM(NAME),IF(nation IN('CN','TW'),TRIM(fname),TRIM(fname)),IF(nation IN('CN','TW'),TRIM(lname),TRIM(lname)),TRIM(name2),TRIM(name3),lang,title,salutation,liason,liason1,sex,
		city,IF(birth >= DATE_ADD(NOW(),INTERVAL -1 DAY),NULL,birth),occupation,vip,src,market,nation,race,religion,TRIM(street),mobile,phone,fax,wetsite,email,unit,zip,belong,
		idcls,TRIM(ident),idend,srqs,amenities,feature,rmpref,extrainf,cusno,saleid,araccnt1,araccnt2,TRIM(refer1),TRIM(refer2),refer3,interest,
		class1,class2,class3,class4,code1,code2,code3,code4,code5,latency,cardno,country,state,town,country1,state1,town1,city1,street1,
		zip1,mobile1,phone1,fax1,email1,visaid,visaend,visano,visaunit,rjplace,lawman,regno,bank,bankno,taxno,arr,dep,IF(fv_date > DATE(NOW()),NULL,fv_date),fv_room,fv_rate,IF(lv_date>DATE(NOW()),NULL,lv_date),lv_room,lv_rate,crtby,crttime,
		i_times,x_times,n_times,l_times,i_days,tl,rm,fb,en,mt,ot,cby,CHANGED,TRIM(COMMENT),TRIM(remark),exp_m1,exp_dt1,exp_s1,logmark
		FROM migrate_xmyh.guest WHERE  class = 'F' AND tag = 'A';
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	DELETE FROM up_status WHERE hotel_id=arg_hotel_id AND up_step='GUEST_FIT';
	INSERT INTO up_status(hotel_id,up_step,time_begin,time_end,time_long,remark) VALUES(arg_hotel_id,'GUEST_FIT',NOW(),NULL,0,''); 
	
	SELECT MAX(CODE) INTO var_hotel_code FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id = arg_hotel_id;	
   OPEN c_cursor;
   SET done_cursor = 0;
	FETCH c_cursor INTO var_no,var_sta,var_sno,var_cno,var_name,var_lname,var_fname,var_name2,var_name3,var_lang,var_title,var_salutation,var_liason,var_liason1,var_sex,
		var_city,var_birth,var_occupation,var_vip,var_src,var_market,var_nation,var_race,var_religion,var_street,var_mobile,var_phone,var_fax,var_wetsite,var_email,var_unit,var_zip,var_belong,
		var_idcls,var_ident,var_idend,var_srqs,var_amenity,var_feature,var_rmpref,var_extrainf,var_cusno,var_saleid,var_araccnt1,var_araccnt2,var_refer1,var_refer2,var_refer3,var_interest,
		var_class1,var_class2,var_class3,var_class4,var_code1,var_code2,var_code3,var_code4,var_code5,var_latency,var_cardno,var_country,var_state,var_town,var_country1,var_state1,var_town1,var_city1,var_street1,
		var_zip1,var_mobile1,var_phone1,var_fax1,var_email1,var_visaid,var_visaend,var_visano,var_visaunit,var_rjplace,var_lawman,var_regno,var_bank,var_bankno,var_taxno,var_arr,var_dep,var_fvdate,var_fvroom,var_fvrate,var_lvdate,var_lvroom,var_lvrate,var_crtby,var_crttime,
		var_i_times,var_x_times,var_n_times,var_l_times,var_i_days,var_tl,var_rm,var_fb,var_en,var_mt,var_ot,var_cby,var_changed,var_comment,var_remark,var_exp_m,var_exp_dt,var_exp_s,var_logmark;
	WHILE done_cursor = 0 DO
				
		INSERT INTO guest_base(hotel_group_id,hotel_id,NAME,last_name,first_name,name2,name3,name_combine,is_save,sex,
				LANGUAGE,title,salutation,birth,race,religion,career,occupation,nation,id_code,id_no,id_end,company_id,company_name,
				pic_photo,pic_sign,remark,create_hotel,create_user,create_datetime,modify_hotel,modify_user,modify_datetime) 
			VALUES(arg_hotel_group_id,0,var_name,var_lname,var_fname,var_name2,var_name3,CONCAT(var_name,var_name2),'F',var_sex,
				var_lang,var_title,var_salutation,var_birth,var_race,var_religion,'',var_occupation,var_nation,var_idcls,var_ident,var_idend,var_cusno,var_unit,
				NULL,NULL,var_comment,var_hotel_code,var_cby,var_changed,var_hotel_code,var_cby,var_changed);
		
		SET var_guest_id=LAST_INSERT_ID();
		
		IF NOT EXISTS(SELECT 1 FROM guest_link_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND id = var_guest_id) THEN
			INSERT INTO guest_link_base(hotel_group_id,hotel_id,id,mobile,phone,fax,email,website,msn,qq,sns,blog,
					linkman1,linkman2,create_hotel,create_user,create_datetime,modify_hotel,modify_user,modify_datetime) 
				VALUES(arg_hotel_group_id,'0',var_guest_id,var_mobile,var_phone,var_fax,var_email,var_wetsite,'','','','',
					var_liason,'',var_hotel_code,var_crtby,var_crttime,var_hotel_code,var_cby,var_changed);
		END IF;
		
		IF NOT EXISTS(SELECT 1 FROM guest_link_addr WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND guest_id = var_guest_id) THEN
			INSERT INTO guest_link_addr(hotel_group_id,hotel_id,guest_id,addr_name,addr_type,is_default,country,state,city,division,street,
					zipcode,list_order,remark,create_hotel,create_user,create_datetime,modify_hotel,modify_user,modify_datetime) 
				VALUES(arg_hotel_group_id,0,var_guest_id,'默认地址','HOME','T',var_country,var_state,var_town,'',var_street,
					var_zip,'0','',var_hotel_code,var_crtby,var_crttime,var_hotel_code,var_cby,var_changed);
		END IF;
		IF (var_country1 <> '' OR var_state1 <> '' OR var_town1 <> '' OR var_city1 <> '' OR var_street1 <> '' OR var_zip1 <> '' OR var_mobile1 <> '' OR var_phone1 <> '' OR var_fax1 <> '' OR var_email1 <> '') THEN
			INSERT INTO guest_link_addr(hotel_group_id,hotel_id,guest_id,addr_name,addr_type,is_default,country,state,city,division,street,
					zipcode,list_order,remark,create_hotel,create_user,create_datetime,modify_hotel,modify_user,modify_datetime) 
				VALUES(arg_hotel_group_id,0,var_guest_id,'公司地址','CORP','F',var_country1,var_state1,var_town1,'',var_street1,
					var_zip1,'10','',var_hotel_code,var_crtby,var_crttime,var_hotel_code,var_cby,var_changed);
		
		END IF;
		-- 酒店档案 
		IF NOT EXISTS(SELECT 1 FROM guest_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_id = var_guest_id) THEN
			INSERT INTO guest_type (hotel_group_id,hotel_id,guest_id,sta,manual_no,sys_cat,flag_cat,grade,latency,
					src,market,vip,belong_app_code,membership_type,membership_no,membership_level,over_rsvsrc,valid_begin,valid_end,
					class1,class2,class3,class4,code1,code2,code3,code4,code5,
					flag,saleman,ar_no1,ar_no2,extra_flag,extra_info,comments,create_user,create_datetime,modify_user,modify_datetime) 
				VALUES(arg_hotel_group_id,arg_hotel_id,var_guest_id,var_sta,var_no,'F','','',var_latency,
					var_src,var_market,var_vip,var_belong,'',var_cardno,'','F',var_arr,var_dep,
					var_class1,var_class2,var_class3,var_class4,var_code1,var_code2,var_code3,var_code4,var_code5,
					'',var_saleid,var_araccnt1,var_araccnt2,'000000000000000000000000000000','',CONCAT(var_comment),var_crtby,var_changed,var_cby,var_changed);
		END IF;
		-- 集团档案 
		IF NOT EXISTS(SELECT 1 FROM guest_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND guest_id = var_guest_id) THEN
			INSERT INTO guest_type (hotel_group_id,hotel_id,guest_id,sta,manual_no,sys_cat,flag_cat,grade,latency,
					src,market,vip,belong_app_code,membership_type,membership_no,membership_level,over_rsvsrc,valid_begin,valid_end,
					class1,class2,class3,class4,code1,code2,code3,code4,code5,
					flag,saleman,ar_no1,ar_no2,extra_flag,extra_info,comments,create_user,create_datetime,modify_user,modify_datetime) 
				VALUES(arg_hotel_group_id,'0',var_guest_id,var_sta,var_no,'F','','',var_latency,
					var_src,var_market,var_vip,var_belong,'',var_cardno,'','F',var_arr,var_dep,
					var_class1,var_class2,var_class3,var_class4,var_code1,var_code2,var_code3,var_code4,var_code5,
					'',var_saleid,var_araccnt1,var_araccnt2,'000000000000000000000000000000',var_extrainf,var_comment,var_crtby,var_crttime,var_cby,var_changed);
		END IF;		
		
		-- 客人喜好
		IF (var_refer1 <> '' OR var_refer2 <> '' OR var_refer3 <> '' OR var_srqs <> '' OR var_amenity <> '' OR var_feature <> '' OR var_remark <> '') AND NOT EXISTS(SELECT 1 FROM guest_prefer WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_id = var_guest_id) THEN
			  INSERT INTO guest_prefer (hotel_group_id,hotel_id,guest_id,specials,amenity,feature,room_prefer,interest,
					prefer_front,prefer_fb,prefer_other,create_user,create_datetime,modify_user,modify_datetime) 
				VALUES(arg_hotel_group_id,arg_hotel_id,var_guest_id,var_srqs,var_amenity,var_feature,var_rmpref,var_interest,
					var_refer1,var_refer2,CONCAT(var_remark,'#',var_refer3),var_crtby,var_crttime,var_cby,var_changed);
		END IF;	
		
		IF NOT EXISTS(SELECT 1 FROM guest_production WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_id = var_guest_id) THEN
		    INSERT INTO guest_production(hotel_group_id,hotel_id,guest_id,first_visit_date,first_visit_room,first_visit_rate,last_visit_date,last_visit_room,last_visit_rate,
				days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime) 
				VALUES(arg_hotel_group_id,arg_hotel_id,var_guest_id,var_fvdate,var_fvroom,var_fvrate,var_lvdate,var_lvroom,var_lvrate,
				var_i_days,var_i_times,var_x_times,var_n_times,'0','0','0',var_rm,var_fb,var_en,var_mt,var_ot,var_tl,var_crtby,var_crttime,var_cby,var_changed);    
		    
			INSERT INTO guest_production_old(hotel_group_id,hotel_id,guest_id,first_visit_date,first_visit_room,first_visit_rate,last_visit_date,last_visit_room,last_visit_rate,
				days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime) 
				VALUES(arg_hotel_group_id,arg_hotel_id,var_guest_id,var_fvdate,var_fvroom,var_fvrate,var_lvdate,var_lvroom,var_lvrate,
				var_i_days,var_i_times,var_x_times,var_n_times,'0','0','0',var_rm,var_fb,var_en,var_mt,var_ot,var_tl,var_crtby,var_crttime,var_cby,var_changed);    
		    IF NOT EXISTS(SELECT 1 FROM guest_production WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND guest_id = var_guest_id) THEN
				INSERT INTO guest_production(hotel_group_id,hotel_id,guest_id,first_visit_date,first_visit_room,first_visit_rate,last_visit_date,last_visit_room,last_visit_rate,
					days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime) 
				VALUES(arg_hotel_group_id,'0',var_guest_id,var_fvdate,var_fvroom,var_fvrate,var_lvdate,var_lvroom,var_lvrate,
					var_i_days,var_i_times,var_x_times,var_n_times,'0','0','0',var_rm,var_fb,var_en,var_mt,var_ot,var_tl,var_crtby,var_crttime,var_cby,var_changed);    
		    END IF;
		END IF;
		
		IF var_guest_id IS NOT NULL THEN
			INSERT INTO up_map_accnt(hotel_group_id,hotel_id,accnt_type,accnt_class,accnt_old,accnt_new) VALUES(arg_hotel_group_id,arg_hotel_id,'GUEST_FIT','F',var_no,var_guest_id);
		END IF;
		
		SET done_cursor = 0;
		FETCH c_cursor INTO var_no,var_sta,var_sno,var_cno,var_name,var_lname,var_fname,var_name2,var_name3,var_lang,var_title,var_salutation,var_liason,var_liason1,var_sex,
			var_city,var_birth,var_occupation,var_vip,var_src,var_market,var_nation,var_race,var_religion,var_street,var_mobile,var_phone,var_fax,var_wetsite,var_email,var_unit,var_zip,var_belong,
			var_idcls,var_ident,var_idend,var_srqs,var_amenity,var_feature,var_rmpref,var_extrainf,var_cusno,var_saleid,var_araccnt1,var_araccnt2,var_refer1,var_refer2,var_refer3,var_interest,
			var_class1,var_class2,var_class3,var_class4,var_code1,var_code2,var_code3,var_code4,var_code5,var_latency,var_cardno,var_country,var_state,var_town,var_country1,var_state1,var_town1,var_city1,var_street1,
			var_zip1,var_mobile1,var_phone1,var_fax1,var_email1,var_visaid,var_visaend,var_visano,var_visaunit,var_rjplace,var_lawman,var_regno,var_bank,var_bankno,var_taxno,var_arr,var_dep,var_fvdate,var_fvroom,var_fvrate,var_lvdate,var_lvroom,var_lvrate,var_crtby,var_crttime,
			var_i_times,var_x_times,var_n_times,var_l_times,var_i_days,var_tl,var_rm,var_fb,var_en,var_mt,var_ot,var_cby,var_changed,var_comment,var_remark,var_exp_m,var_exp_dt,var_exp_s,var_logmark;
	END WHILE;
	CLOSE c_cursor;
	UPDATE guest_type a,up_map_code b SET a.src = b.code_new WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.code = 'srccode'  AND b.code_old = a.src  ;
 	UPDATE guest_type a,up_map_code b SET a.market = b.code_new WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.code = 'mktcode'  AND b.code_old = a.market  ;
  	UPDATE guest_type a,up_map_code b SET a.vip = b.code_new WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.code = 'vip'  AND b.code_old = a.vip  ;
  	UPDATE guest_link_addr a,up_map_code b SET a.state = b.code_new WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.code = 'province'  AND b.code_old = a.state  ;

  	UPDATE guest_base a,up_map_code b SET a.title = b.code_new WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.code = 'title'  AND b.code_old = a.title  ;

-- 	UPDATE guest_prefer SET amenity = REPLACE(amenity,'PT','PAT') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND amenity <> '';
-- 	UPDATE guest_prefer SET amenity = REPLACE(amenity,'F2','FL2') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND amenity <> '';
    	
	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='GUEST_FIT';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='GUEST_FIT';
END$$

DELIMITER ;