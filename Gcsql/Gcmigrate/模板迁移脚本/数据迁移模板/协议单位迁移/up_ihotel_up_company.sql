DELIMITER $$

 
DROP PROCEDURE IF EXISTS `up_ihotel_up_company`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_up_company`(
	IN   arg_hotel_group_id INT, 
	IN   arg_hotel_id INT, 
	INOUT var_return VARCHAR(128)  -- 返回空串表示成功，否则表示失败  
)
label_0:
BEGIN
	-- ---------------------------------------------------------------------------------------------------------
	-- 强烈建议，协议单位导入前，做一定的整理删减，重点删减对象是：非活跃、消费业绩少的
	-- ---------------------------------------------------------------------------------------------------------
	
 	
	-- step 1:
	-- 定义变量，存放从中间表里面取过来的数据
	DECLARE done_cursor 		INT DEFAULT 0;
	DECLARE var_accnt		VARCHAR(20);
	DECLARE var_name 		CHAR(255);
	DECLARE var_linkman1 		CHAR(15);
	DECLARE	var_ratecode		CHAR(14);
	DECLARE	var_mobile	 	CHAR(14);
 	DECLARE	var_phone		CHAR(32);	
 	DECLARE	var_fax			CHAR(32);	
	DECLARE	var_address		CHAR(100);
 	DECLARE var_begin_date		DATETIME;
	DECLARE var_end_date		DATETIME;
	DECLARE var_company_id 		INT;
	DECLARE var_companyid 		INT;
 	DECLARE var_valid_begin 	DATETIME;
	DECLARE var_valid_end 		DATETIME;
	DECLARE var_sys_cat		CHAR(1);
	DECLARE var_belong		VARCHAR(10);		
	DECLARE var_code1		VARCHAR(10);
	DECLARE var_saleman		VARCHAR(10);
	DECLARE var_manual_no		VARCHAR(20);

	DECLARE var_stop INT DEFAULT 0;
	DECLARE var_cursor CURSOR FOR SELECT a.accnt,a.no,a.name,a.valid_begin,a.valid_end,a.sys_cat,a.linkman1,a.ratecode,a.mobile,a.phone,a.fax,a.saleman,a.street
	FROM migrate_db.company a  ;


	DECLARE c_profile CURSOR FOR SELECT company_id,code1,valid_begin,valid_end FROM company_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND code1 <> '';
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET var_stop = 1;
		 																											 													
	DELETE FROM up_status WHERE hotel_id=arg_hotel_id AND up_step='COMPANY';
	INSERT INTO up_status(hotel_id,up_step,time_begin,time_end,time_long,remark) VALUES(arg_hotel_id,'COMPANY',NOW(),NULL,0,''); 
	-- step 2:
	-- 清理不必要的数据(1.没有证件号码的)
	-- delete from migrate_xx.hgstinf where ident = '' or ident is null;
	-- DELETE FROM company_production_old WHERE hotel_group_id = var_hotel_group_id AND hotel_id = var_hotel_id;
	-- DELETE FROM up_map_accnt WHERE hotel_id = var_hotel_id AND accnt_type = 'COMPANY';
-- 	SET var_hotel_code = IFNULL((SELECT CODE FROM hotel WHERE hotel_group_id = var_hotel_group_id AND id = var_hotel_id),var_hotel_id);
 	OPEN var_cursor;
	FETCH var_cursor INTO var_accnt,var_manual_no,var_name,var_valid_begin,var_valid_end,var_sys_cat,var_linkman1,var_ratecode,var_mobile,var_phone,var_fax,var_saleman,var_address ;
 	WHILE var_stop <> 1 DO
		
		SET var_company_id = 0;
		INSERT INTO company_base(hotel_group_id,hotel_id,NAME,name2,name3,name_combine,is_save,LANGUAGE,nation,
			phone,mobile,fax,email,website,blog,linkman1,occupation,linkman2,country,state,city,division,street,zipcode,representative,register_no,
			bank_name,bank_account,tax_no,remark,create_hotel,create_user,create_datetime,modify_hotel,modify_user,modify_datetime) 
		VALUES(arg_hotel_group_id,0,var_name,var_name,var_name,var_name,'F','C','CN',
			var_phone,var_mobile,var_fax,'','','',var_linkman1,'',NULL,'CN','','','',var_address,'','','',
			'','','','',arg_hotel_id,'ADMIN',NOW(),arg_hotel_id,'ADMIN',NOW());
		SET var_company_id=LAST_INSERT_ID();	
		
 		-- 酒店档案
		IF NOT EXISTS(SELECT 1 FROM company_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND company_id = var_company_id) THEN
		    INSERT INTO company_type (hotel_group_id,hotel_id,company_id,sta,manual_no,sys_cat,flag_cat,grade,latency,class1,class2,class3,class4,
				src,market,vip,belong_app_code,membership_type,membership_no,membership_level,over_rsvsrc,valid_begin,valid_end,code1,code2,code3,code4,code5,
				flag,saleman,ar_no1,ar_no2,extra_flag,extra_info,comments,create_user,create_datetime,modify_user,modify_datetime) 
			VALUES(arg_hotel_group_id,arg_hotel_id,var_company_id,'I',IFNULL(var_manual_no,''),var_sys_cat,'','','','','','','',
				'','','','1','','','','F',var_valid_begin,var_valid_end,var_ratecode,'','','','',
				'',IFNULL(var_saleman,''),NULL,NULL,'000000000000000000000000000000',var_accnt,var_accnt,'ADMIN',NOW(),'ADMIN',NOW());
		END IF;
-- 		-- 集团档案
		IF NOT EXISTS(SELECT 1 FROM company_type WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = 0 AND company_id = var_company_id) THEN
		    INSERT INTO company_type (hotel_group_id,hotel_id,company_id,sta,manual_no,sys_cat,flag_cat,grade,latency,class1,class2,class3,class4,
				src,market,vip,belong_app_code,membership_type,membership_no,membership_level,over_rsvsrc,valid_begin,valid_end,code1,code2,code3,code4,code5,
				flag,saleman,ar_no1,ar_no2,extra_flag,extra_info,comments,create_user,create_datetime,modify_user,modify_datetime) 
			VALUES(arg_hotel_group_id,0,var_company_id,'I',IFNULL(var_manual_no,''),var_sys_cat,'','','','','','','',
				'','','','1','','','','F',var_valid_begin,var_valid_end,var_ratecode,'','','','',
				'',IFNULL(var_saleman,''),NULL,NULL,'000000000000000000000000000000',var_accnt,'','ADMIN',NOW(),'ADMIN',NOW());
		END IF;
 
		IF var_company_id IS NOT NULL THEN
			INSERT INTO up_map_accnt(hotel_group_id,hotel_id,accnt_type,accnt_class,accnt_old,accnt_new) VALUES(arg_hotel_group_id,arg_hotel_id,'COMPANY','',var_accnt,var_company_id);
		END IF;

			FETCH var_cursor INTO var_accnt,var_manual_no,var_name,var_valid_begin,var_valid_end,var_sys_cat,var_linkman1,var_ratecode,var_mobile,var_phone,var_fax,var_saleman,var_address ;
		END WHILE;
	CLOSE var_cursor;
 
--  	UPDATE company_type a,migrate_xx.company b SET a.code1 = 'NET' WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.extra_info = b.account AND b.type = 'BC' AND b.end_date >= '2013.12.31';
-- 	UPDATE company_type a,migrate_xx.company b SET a.code1 = 'CORC' WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.extra_info = b.account AND b.type = 'TS' AND b.end_date >= '2013.12.31';
-- 	UPDATE company_type a,migrate_xx.company b SET a.code1 = 'CORB' WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.extra_info = b.account AND b.type = 'BL' AND b.end_date >= '2013.12.31';
-- 
 	-- ====================================================================
	-- 根据协议公司主单上的房价码生成profileExtra中的值，协议单位关联房价码(感觉有问题，待测试)
	-- ====================================================================
/*	DELETE FROM profile_extra WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id AND extra_item = 'RATECODE' AND master_type = 'COMPANY';
	
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
    	
*/
	SET var_return = '';
END$$

DELIMITER ;