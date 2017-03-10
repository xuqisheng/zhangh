DELIMITER $$

USE `portal_group`$$

DROP PROCEDURE IF EXISTS `up_ihotel_up_company`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_up_company`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ==========================================================
	-- 协议单位档案导入
	-- 适用于在同一服务器中的分库，注意此过程中涉及多个库名
	-- ==========================================================
	DECLARE done_cursor 	INT DEFAULT 0;
	DECLARE var_no 			VARCHAR(10);
	DECLARE var_sno 		VARCHAR(15);
	DECLARE var_cno 		VARCHAR(15);
	DECLARE var_name 		VARCHAR(50);
	DECLARE var_lname 		VARCHAR(30);
	DECLARE var_fname 		VARCHAR(30);
	DECLARE var_name2 		VARCHAR(50);
	DECLARE var_name3 		VARCHAR(50);
	DECLARE var_name4 		VARCHAR(50);
	DECLARE var_lang 		VARCHAR(10);
	DECLARE var_title 		VARCHAR(10);
	DECLARE var_salutation 	VARCHAR(60);
	DECLARE var_liason 		VARCHAR(30);
	DECLARE var_liason1 	VARCHAR(30);
	DECLARE var_sex 		VARCHAR(10);
	DECLARE var_city 		VARCHAR(6);
	DECLARE var_birth 		DATETIME;
	DECLARE var_occupation  VARCHAR(10);
	DECLARE var_vip  		VARCHAR(10);
	DECLARE var_src  		VARCHAR(10);
	DECLARE var_market  	VARCHAR(10);
	DECLARE var_nation 	 	VARCHAR(10);
	DECLARE var_race  		VARCHAR(10);
	DECLARE var_religion  	VARCHAR(10);
	DECLARE var_street  	VARCHAR(60);
	DECLARE var_mobile 		VARCHAR(20);
	DECLARE var_phone  		VARCHAR(20);
	DECLARE var_fax	   		VARCHAR(25);
	DECLARE var_wetsite 	VARCHAR(60);
	DECLARE var_email   	VARCHAR(20);
	DECLARE var_unit  		VARCHAR(60);
	DECLARE var_zip  		VARCHAR(6);
	DECLARE var_idcls  		VARCHAR(10);
	DECLARE var_ident  		VARCHAR(20);
	DECLARE var_srqs  		VARCHAR(18);
	DECLARE var_rmpref 		VARCHAR(60);
	DECLARE var_extrainf 	VARCHAR(30);
	DECLARE var_cusno 		VARCHAR(7);
	DECLARE var_saleid 		VARCHAR(12);
	DECLARE var_araccnt1  	VARCHAR(7);
	DECLARE var_araccnt2  	VARCHAR(7);
	DECLARE var_i_times 	INT(11);
	DECLARE var_x_times 	INT(11);
	DECLARE var_n_times 	INT(11);
	DECLARE var_l_times 	INT(11);
	DECLARE var_i_days 		INT(11);
	DECLARE var_tl 			DECIMAL(12,2);
	DECLARE var_rm 			DECIMAL(12,2);
	DECLARE var_fb 			DECIMAL(12,2);
	DECLARE var_en 			DECIMAL(12,2);
	DECLARE var_ot 			DECIMAL(12,2);
	DECLARE var_mt 			DECIMAL(12,2);
	DECLARE var_refer1		VARCHAR(250);
	DECLARE var_refer2		VARCHAR(250);
	DECLARE var_refer3		VARCHAR(250);
	DECLARE var_class		VARCHAR(10);
	DECLARE var_class1		VARCHAR(10);
	DECLARE var_class2		VARCHAR(10);
	DECLARE var_class3		VARCHAR(10);
	DECLARE var_class4		VARCHAR(10);
	DECLARE var_code1		VARCHAR(10);
	DECLARE var_code2		VARCHAR(10);
	DECLARE var_code3		VARCHAR(10);
	DECLARE var_code4		VARCHAR(10);
	DECLARE var_code5		VARCHAR(10);	
	DECLARE var_cby 		VARCHAR(10);
	DECLARE var_changed 	DATETIME; 
	DECLARE var_comment 	VARCHAR(1000);
	DECLARE var_remark 		TEXT;
	DECLARE var_exp_m 		BIGINT(20);
	DECLARE var_exp_dt 		DATETIME;
	DECLARE var_exp_s 		VARCHAR(10);
	DECLARE var_logmark 	INT(11);
	DECLARE var_company_id 	BIGINT(12);
	DECLARE var_amenity 	VARCHAR(50);
	DECLARE var_feature 	VARCHAR(50);
	DECLARE var_latency		VARCHAR(10);
	DECLARE var_cardno		VARCHAR(10);
	DECLARE var_country		VARCHAR(10);
	DECLARE var_state		VARCHAR(10);
	DECLARE var_town		VARCHAR(50);
	DECLARE var_country1	VARCHAR(10);
	DECLARE var_state1		VARCHAR(10);
	DECLARE var_town1		VARCHAR(50);
	DECLARE var_city1		VARCHAR(20);
	DECLARE var_street1		VARCHAR(100);
	DECLARE var_zip1		VARCHAR(10);
	DECLARE var_mobile1		VARCHAR(20);
	DECLARE var_phone1		VARCHAR(20);
	DECLARE var_fax1		VARCHAR(20);
	DECLARE var_email1		VARCHAR(50);
	DECLARE var_visaid		VARCHAR(10);
	DECLARE var_visaend		DATETIME;
	DECLARE var_visano		VARCHAR(20);
	DECLARE var_visaunit	VARCHAR(10);
	DECLARE var_rjplace		VARCHAR(10);
	DECLARE var_lawman		VARCHAR(20);
	DECLARE var_regno		VARCHAR(20);
	DECLARE var_bank		VARCHAR(50);
	DECLARE var_bankno		VARCHAR(30);
	DECLARE var_taxno		VARCHAR(20);
	DECLARE var_arr			DATETIME;
	DECLARE var_dep			DATETIME;
	DECLARE var_fvdate		DATETIME;
	DECLARE var_fvroom		VARCHAR(10);
	DECLARE var_fvrate		DECIMAL(12,2);
	DECLARE var_lvdate		DATETIME;
	DECLARE var_lvroom		VARCHAR(10);
	DECLARE var_lvrate		DECIMAL(12,2);
	DECLARE var_crtby		VARCHAR(10);
	DECLARE var_crttime		DATETIME;
	DECLARE var_sta			CHAR(1);
	DECLARE var_interest	VARCHAR(50);
	DECLARE var_companyid 	INT;
	DECLARE var_valid_begin DATETIME;
	DECLARE var_valid_end 	DATETIME;
	DECLARE var_belong		VARCHAR(10);	
	
	DECLARE c_cursor CURSOR FOR SELECT NO,sta,class,sno,cno,TRIM(NAME),TRIM(lname),TRIM(fname),TRIM(name2),TRIM(name3),lang,title,salutation,liason,liason1,sex,
		city,IF(YEAR(birth) >= YEAR(NOW()),NULL,birth),occupation,vip,src,market,nation,race,religion,TRIM(street),mobile,phone,fax,wetsite,email,unit,zip,belong,
		idcls,TRIM(ident),srqs,amenities,feature,rmpref,extrainf,cusno,saleid,araccnt1,araccnt2,TRIM(refer1),TRIM(refer2),refer3,interest,
		IF(class1 = '0','',class1),IF(class2 = '0','',class2),IF(class3 = '0','',class3),IF(class4 = '0','',class4),code1,code2,code3,code4,code5,latency,cardno,country,state,town,country1,state1,town1,city1,street1,
		zip1,mobile1,phone1,fax1,email1,visaid,visaend,visano,visaunit,rjplace,lawman,regno,bank,bankno,taxno,IF(arr >DATE_ADD(NOW(),INTERVAL -1 DAY),NULL,arr),IF(dep >DATE_ADD(NOW(),INTERVAL -1 DAY),NULL,dep),IF(fv_date > DATE(NOW()),NULL,fv_date),fv_room,fv_rate,IF(lv_date>DATE(NOW()),NULL,lv_date),lv_room,lv_rate,crtby,crttime,
		i_times,x_times,n_times,l_times,i_days,tl,rm,fb,en,mt,ot,cby,CHANGED,TRIM(COMMENT),TRIM(remark),exp_m1,exp_dt1,exp_s1,logmark
		FROM migrate_db.guest WHERE class IN ( 'A','S','C') ;

	DECLARE c_profile CURSOR FOR SELECT company_id,code1,valid_begin,valid_end FROM company_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND code1 <> '';
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	DELETE FROM portal_ipms.up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND accnt_type = 'COMPANY';
	DELETE FROM portal_ipms.up_status WHERE hotel_id=arg_hotel_id AND up_step='COMPANY';
	INSERT INTO portal_ipms.up_status(hotel_id,up_step,time_begin,time_end,time_long,remark) VALUES (arg_hotel_id,'COMPANY',NOW(),NULL,0,''); 
		
   OPEN c_cursor;
   SET done_cursor = 0;
	FETCH c_cursor INTO var_no,var_sta,var_class,var_sno,var_cno,var_name,var_lname,var_fname,var_name2,var_name3,var_lang,var_title,var_salutation,var_liason,var_liason1,var_sex,
		var_city,var_birth,var_occupation,var_vip,var_src,var_market,var_nation,var_race,var_religion,var_street,var_mobile,var_phone,var_fax,var_wetsite,var_email,var_unit,var_zip,var_belong,
		var_idcls,var_ident,var_srqs,var_amenity,var_feature,var_rmpref,var_extrainf,var_cusno,var_saleid,var_araccnt1,var_araccnt2,var_refer1,var_refer2,var_refer3,var_interest,
		var_class1,var_class2,var_class3,var_class4,var_code1,var_code2,var_code3,var_code4,var_code5,var_latency,var_cardno,var_country,var_state,var_town,var_country1,var_state1,var_town1,var_city1,var_street1,
		var_zip1,var_mobile1,var_phone1,var_fax1,var_email1,var_visaid,var_visaend,var_visano,var_visaunit,var_rjplace,var_lawman,var_regno,var_bank,var_bankno,var_taxno,var_arr,var_dep,var_fvdate,var_fvroom,var_fvrate,var_lvdate,var_lvroom,var_lvrate,var_crtby,var_crttime,
		var_i_times,var_x_times,var_n_times,var_l_times,var_i_days,var_tl,var_rm,var_fb,var_en,var_mt,var_ot,var_cby,var_changed,var_comment,var_remark,var_exp_m,var_exp_dt,var_exp_s,var_logmark;
	WHILE done_cursor = 0 DO		
		
		INSERT INTO company_base (hotel_group_id,hotel_id,NAME,name2,name3,name_combine,is_save,LANGUAGE,nation,
				phone,mobile,mobile2,fax,email,website,blog,linkman1,linkman2,country,state,city,division,street,zipcode,
				representative,register_no,bank_name,bank_account,tax_no,remark,create_hotel,create_user,create_datetime,modify_hotel,modify_user,modify_datetime) 
			VALUES(arg_hotel_group_id,'0',var_name,var_name2,var_name3,CONCAT(var_name,var_name2),'F',var_lang,var_nation,
				var_phone,var_liason1,var_bank,var_fax,var_email,var_wetsite,'',var_liason,var_regno,var_country,var_state,var_town,'',var_street,var_zip,
				var_lawman,'','','','',var_comment,arg_hotel_id,var_crtby,var_crttime,arg_hotel_id,var_cby,var_changed);			
		
		SET var_company_id=LAST_INSERT_ID();
		
		IF NOT EXISTS(SELECT 1 FROM company_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND company_id = var_company_id) THEN
		    INSERT INTO company_type (hotel_group_id,hotel_id,company_id,sta,manual_no,sys_cat,flag_cat,grade,latency,
					class1,class2,class3,class4,src,market,vip,belong_app_code,membership_type,membership_no,membership_level,over_rsvsrc,valid_begin,valid_end,
					code1,code2,code3,code4,code5,flag,saleman,ar_no1,ar_no2,extra_flag,extra_info,comments,create_user,create_datetime,modify_user,modify_datetime) 
				VALUES(arg_hotel_group_id,arg_hotel_id,var_company_id,var_sta,IF(var_cno = '',var_no,var_cno),var_class,'','',var_latency,
					var_class1,var_class2,var_class3,var_class4,var_src,var_market,var_vip,var_belong,'',var_cardno,'','F',NOW(),DATE_ADD(NOW(),INTERVAL +1 YEAR),
					var_code1,var_code2,var_code3,var_code4,var_code5,'',var_saleid,var_araccnt1,var_araccnt2,'000000000000000000000000000000',var_extrainf,CONCAT(var_comment,'--',var_remark),var_crtby,var_crttime,var_cby,var_changed);
		END IF;
		IF NOT EXISTS(SELECT 1 FROM company_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = '0' AND company_id = var_company_id) THEN
		    INSERT INTO company_type (hotel_group_id,hotel_id,company_id,sta,manual_no,sys_cat,flag_cat,grade,latency,
					class1,class2,class3,class4,src,market,vip,belong_app_code,membership_type,membership_no,membership_level,over_rsvsrc,valid_begin,valid_end,
					code1,code2,code3,code4,code5,flag,saleman,ar_no1,ar_no2,extra_flag,extra_info,comments,create_user,create_datetime,modify_user,modify_datetime) 
				VALUES(arg_hotel_group_id,'0',var_company_id,var_sta,IF(var_cno = '',var_no,var_cno),var_class,'','',var_latency,
					var_class1,var_class2,var_class3,var_class4,var_src,var_market,var_vip,var_belong,'',var_cardno,'','F',NOW(),DATE_ADD(NOW(),INTERVAL +1 YEAR),
					var_code1,var_code2,var_code3,var_code4,var_code5,'',var_saleid,var_araccnt1,var_araccnt2,'000000000000000000000000000000',var_extrainf,CONCAT(var_comment,'--',var_remark),var_crtby,var_crttime,var_cby,var_changed);
		END IF;
		   		
		IF NOT EXISTS(SELECT 1 FROM company_production WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND company_id = var_company_id) THEN
		
		    INSERT INTO company_production (hotel_group_id,hotel_id,company_id,first_visit_date,first_visit_room,first_visit_rate,last_visit_date,last_visit_room,last_visit_rate,
					days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
				VALUES(arg_hotel_group_id,arg_hotel_id,var_company_id,var_fvdate,var_fvroom,var_fvrate,var_lvdate,var_lvroom,var_lvrate,
					var_i_days,var_i_times,var_x_times,var_n_times,'0','0','0',var_rm,var_fb,var_en,var_mt,var_ot,var_tl,var_crtby,var_crttime,var_cby,var_changed);
			
			IF NOT EXISTS(SELECT 1 FROM company_production WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = '0' AND company_id = var_company_id) THEN
				INSERT INTO company_production (hotel_group_id,hotel_id,company_id,first_visit_date,first_visit_room,first_visit_rate,last_visit_date,last_visit_room,last_visit_rate,
					days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime) 
				VALUES(arg_hotel_group_id,'0',var_company_id,var_fvdate,var_fvroom,var_fvrate,var_lvdate,var_lvroom,var_lvrate,
					var_i_days,var_i_times,var_x_times,var_n_times,'0','0','0',var_rm,var_fb,var_en,var_mt,var_ot,var_tl,var_crtby,var_crttime,var_cby,var_changed);
			END IF;
		END IF;	
	
		IF var_company_id IS NOT NULL THEN
			INSERT INTO portal_ipms.up_map_accnt(hotel_group_id,hotel_id,accnt_type,accnt_class,accnt_old,accnt_new) 
				VALUES(arg_hotel_group_id,arg_hotel_id,'COMPANY',var_class,var_no,var_company_id);
		END IF;
		
		SET done_cursor = 0;
		FETCH c_cursor INTO var_no,var_sta,var_class,var_sno,var_cno,var_name,var_lname,var_fname,var_name2,var_name3,var_lang,var_title,var_salutation,var_liason,var_liason1,var_sex,
			var_city,var_birth,var_occupation,var_vip,var_src,var_market,var_nation,var_race,var_religion,var_street,var_mobile,var_phone,var_fax,var_wetsite,var_email,var_unit,var_zip,var_belong,
			var_idcls,var_ident,var_srqs,var_amenity,var_feature,var_rmpref,var_extrainf,var_cusno,var_saleid,var_araccnt1,var_araccnt2,var_refer1,var_refer2,var_refer3,var_interest,
			var_class1,var_class2,var_class3,var_class4,var_code1,var_code2,var_code3,var_code4,var_code5,var_latency,var_cardno,var_country,var_state,var_town,var_country1,var_state1,var_town1,var_city1,var_street1,
			var_zip1,var_mobile1,var_phone1,var_fax1,var_email1,var_visaid,var_visaend,var_visano,var_visaunit,var_rjplace,var_lawman,var_regno,var_bank,var_bankno,var_taxno,var_arr,var_dep,var_fvdate,var_fvroom,var_fvrate,var_lvdate,var_lvroom,var_lvrate,var_crtby,var_crttime,
			var_i_times,var_x_times,var_n_times,var_l_times,var_i_days,var_tl,var_rm,var_fb,var_en,var_mt,var_ot,var_cby,var_changed,var_comment,var_remark,var_exp_m,var_exp_dt,var_exp_s,var_logmark;
	END WHILE;
	CLOSE c_cursor;

  	UPDATE company_type a,portal_ipms.up_map_code b SET a.code1 	= b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code_old = a.code1 AND b.code = 'ratecode';
  	UPDATE company_type a,portal_ipms.up_map_code b SET a.saleman = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code_old = a.saleman AND b.code = 'salesman';
	UPDATE company_type a,portal_ipms.up_map_code b SET a.src 	= b.code_new WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.code = 'srccode'  AND b.code_old = a.src  ;
 	UPDATE company_type a,portal_ipms.up_map_code b SET a.market = b.code_new WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.code = 'mktcode'  AND b.code_old = a.market  ;
  	UPDATE company_type a,portal_ipms.up_map_code b SET a.vip 	= b.code_new WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.code = 'vip'  AND b.code_old = a.vip  ;
	UPDATE company_base SET name_combine=REPLACE(name_combine,' ','');
	UPDATE company_type SET belong_app_code=1 WHERE hotel_group_id=2;
	
	-- ====================================================================
	-- 根据协议公司主单上的房价码生成profileExtra中的值，协议单位关联房价码(感觉有问题，待测试)
	-- ====================================================================
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
	
	-- 从集团库中插回PMS库
	-- 协议公司主单表
	INSERT INTO portal_ipms.company_base
		SELECT a.* FROM portal_group.company_base a,portal_ipms.up_map_accnt b 
			WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = 0 AND a.id = b.accnt_new AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.accnt_type = 'COMPANY';

	-- 协议公司关联表
	INSERT INTO portal_ipms.company_type
		SELECT a.* FROM portal_group.company_type a,portal_ipms.up_map_accnt b 
			WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = 0 AND a.company_id = b.accnt_new AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.accnt_type = 'COMPANY';
	INSERT INTO portal_ipms.company_type
		SELECT a.* FROM portal_group.company_type a,portal_ipms.up_map_accnt b 
			WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.company_id = b.accnt_new AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.accnt_type = 'COMPANY';
		
	INSERT INTO portal_ipms.company_production(hotel_group_id,hotel_id,company_id,first_visit_date,first_visit_room,first_visit_rate,
		last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,production_rm,
		production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
	SELECT a.hotel_group_id,a.hotel_id,a.company_id,a.first_visit_date,a.first_visit_room,a.first_visit_rate,a.last_visit_date,a.last_visit_room,
		a.last_visit_rate,a.days_in,a.times_in,a.times_cxl,a.times_noshow,a.times_trans,a.times_fb,a.times_en,a.production_rm,
		a.production_fb,a.production_en,a.production_mt,a.production_ot,a.production_ttl,a.create_user,a.create_datetime,a.modify_user,a.modify_datetime
	FROM portal_group.company_production a,portal_ipms.up_map_accnt b 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = 0 AND a.company_id = b.accnt_new AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.accnt_type = 'COMPANY';

	INSERT INTO portal_ipms.company_production(hotel_group_id,hotel_id,company_id,first_visit_date,first_visit_room,first_visit_rate,
		last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,production_rm,
		production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
	SELECT a.hotel_group_id,a.hotel_id,a.company_id,a.first_visit_date,a.first_visit_room,a.first_visit_rate,a.last_visit_date,a.last_visit_room,
		a.last_visit_rate,a.days_in,a.times_in,a.times_cxl,a.times_noshow,a.times_trans,a.times_fb,a.times_en,a.production_rm,
		a.production_fb,a.production_en,a.production_mt,a.production_ot,a.production_ttl,a.create_user,a.create_datetime,a.modify_user,a.modify_datetime
	FROM portal_group.company_production a,portal_ipms.up_map_accnt b 
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.company_id = b.accnt_new AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.accnt_type = 'COMPANY';
		    
	INSERT INTO portal_ipms.profile_extra
		SELECT a.* FROM portal_group.profile_extra a,portal_ipms.up_map_accnt b WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.master_id = b.accnt_new
			AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.accnt_type = 'COMPANY';	
	
	UPDATE portal_ipms.up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='COMPANY';
	UPDATE portal_ipms.up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='COMPANY';

END$$

DELIMITER ;