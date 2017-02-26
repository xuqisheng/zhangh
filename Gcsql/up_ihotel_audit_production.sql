DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_audit_production`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_audit_production`(
	IN 	arg_hotel_group_id	BIGINT(16),
	IN 	arg_hotel_id		BIGINT(16),
	OUT	arg_ret				BIGINT(16),
	OUT arg_msg				VARCHAR(128)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- =========================================================
	--  夜审报表 -- 业绩相关表统计
	-- 
	-- 作者：zhangh
	-- =========================================================
	DECLARE done_cursor 	INT DEFAULT 0;
	DECLARE var_duringaudit	CHAR(1);
	DECLARE var_bfdate		DATETIME;
	DECLARE var_bdate		DATETIME;
	DECLARE	var_sta			CHAR(1);
	DECLARE var_rmno		VARCHAR(10);
	DECLARE var_accnt   	BIGINT(16);
	DECLARE var_master_id   BIGINT(16);
	DECLARE	var_guest_id	BIGINT(16);
	DECLARE	var_group_id	BIGINT(16);
	DECLARE	var_company_id	BIGINT(16);
	DECLARE	var_agent_id	BIGINT(16);
	DECLARE	var_source_id	BIGINT(16);
	DECLARE	var_member_no	VARCHAR(20);
	DECLARE	var_salesman	VARCHAR(10);
	DECLARE var_biz_date	DATETIME;
	DECLARE var_real_rate	DECIMAL(8,2);
	DECLARE	var_nights		DECIMAL(8,2);
	DECLARE	var_nights2		DECIMAL(8,2);
	DECLARE	var_cxl			DECIMAL(8,2);
	DECLARE	var_noshow		DECIMAL(8,2);
	DECLARE	var_rm			DECIMAL(8,2);
	DECLARE	var_fb			DECIMAL(8,2);
	DECLARE	var_mt			DECIMAL(8,2);
	DECLARE	var_en			DECIMAL(8,2);
	DECLARE	var_ot			DECIMAL(8,2);
	DECLARE	var_ttl			DECIMAL(8,2);	
	DECLARE var_member_id   BIGINT(16);
	DECLARE	var_card_id		BIGINT(16);
	
	DECLARE c_cursor CURSOR FOR
		SELECT sta,rmno,accnt,master_id,guest_id,group_id,company_id,agent_id,source_id,member_no,card_id,salesman,nights,nights2,times_cxl,times_noshow,biz_date,real_rate,production_rm,
			production_fb,production_mt,production_en,production_ot,production_ttl
			FROM production_detail 
			WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND master_type IN ('master','pos') AND biz_date=var_bdate;
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	
	SELECT ADDDATE(biz_date1, -1) INTO var_bdate FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	SET var_bfdate = ADDDATE(var_bdate, -1);	
	SET arg_ret = 1, arg_msg = 'OK';		
					
	OPEN c_cursor;
	SET done_cursor = 0;
	FETCH c_cursor INTO var_sta,var_rmno,var_accnt,var_master_id,var_guest_id,var_group_id,var_company_id,var_agent_id,var_source_id,var_member_no,var_card_id,var_salesman,var_nights,var_nights2,var_cxl,var_noshow,var_biz_date,var_real_rate,var_rm,var_fb,var_mt,var_en,var_ot,var_ttl;		
	WHILE done_cursor = 0 DO
		BEGIN			
			IF var_guest_id <> 0 THEN	-- 宾客
				BEGIN
					IF NOT EXISTS(SELECT 1 FROM guest_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND guest_id=var_guest_id) THEN
						INSERT INTO guest_production(hotel_group_id,hotel_id,guest_id,first_visit_date,first_visit_room,first_visit_rate,
							last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
							production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
						VALUES(arg_hotel_group_id,arg_hotel_id,var_guest_id,var_biz_date,var_rmno,var_real_rate,NULL,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'ADMIN',NOW(),'ADMIN',NOW());
					END IF;
					IF NOT EXISTS(SELECT 1 FROM guest_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND guest_id=var_guest_id) THEN
						INSERT INTO guest_production(hotel_group_id,hotel_id,guest_id,first_visit_date,first_visit_room,first_visit_rate,
							last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
							production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
						VALUES(arg_hotel_group_id,0,var_guest_id,var_biz_date,var_rmno,var_real_rate,NULL,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'ADMIN',NOW(),'ADMIN',NOW());
					END IF;			
					
					UPDATE guest_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
					production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights,
					last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
					production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
						WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND guest_id=var_guest_id;
							
					UPDATE guest_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
					production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights,
					last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
					production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
						WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND guest_id=var_guest_id;			
					
					IF var_sta = 'O' AND var_rmno <>'' AND NOT EXISTS(SELECT 1 FROM production_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date<=var_bfdate AND accnt=var_accnt AND sta='O') THEN	
						BEGIN
						UPDATE guest_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND guest_id=var_guest_id;
						UPDATE guest_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND guest_id=var_guest_id;
						END;
					END IF;	
					IF var_fb <> 0 THEN	
						BEGIN
						UPDATE guest_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND guest_id=var_guest_id;
						UPDATE guest_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND guest_id=var_guest_id;
						END;
					END IF;			
					IF var_en <> 0 THEN	
						BEGIN
						UPDATE guest_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND guest_id=var_guest_id;
						UPDATE guest_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND guest_id=var_guest_id;
						END;
					END IF;						
				END;
			END IF;
			/*
			IF var_group_id <> 0 THEN	-- 团体
				BEGIN
					IF NOT EXISTS(SELECT 1 FROM guest_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND guest_id=var_group_id) THEN
						INSERT INTO guest_production(hotel_group_id,hotel_id,guest_id,first_visit_date,first_visit_room,first_visit_rate,
							last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
							production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
						VALUES(arg_hotel_group_id,arg_hotel_id,var_group_id,var_biz_date,var_rmno,var_real_rate,NULL,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'ADMIN',NOW(),'ADMIN',NOW());
					END IF;
					IF NOT EXISTS(SELECT 1 FROM guest_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND guest_id=var_group_id) THEN
						INSERT INTO guest_production(hotel_group_id,hotel_id,guest_id,first_visit_date,first_visit_room,first_visit_rate,
							last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
							production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
						VALUES(arg_hotel_group_id,0,var_group_id,var_biz_date,var_rmno,var_real_rate,NULL,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'ADMIN',NOW(),'ADMIN',NOW());
					END IF;	
					
					UPDATE guest_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
					production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights2,
					last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
					production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
						WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND guest_id=var_group_id;
					UPDATE guest_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
					production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights2,
					last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
					production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
						WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND guest_id=var_group_id;					
					
					IF var_sta = 'O' AND var_rmno <>'' AND NOT EXISTS(SELECT 1 FROM production_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date<=var_bfdate AND accnt=var_accnt AND sta='O') THEN
						BEGIN
						UPDATE guest_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND guest_id=var_group_id;
						UPDATE guest_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND guest_id=var_group_id;
						END;
					END IF;				
					IF var_fb <> 0 THEN	
						BEGIN
						UPDATE guest_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND guest_id=var_group_id;
						UPDATE guest_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND guest_id=var_group_id;
						END;
					END IF;			
					IF var_en <> 0 THEN	
						BEGIN
						UPDATE guest_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND guest_id=var_group_id;
						UPDATE guest_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND guest_id=var_group_id;
						END;
					END IF;					
				END;
			END IF;
			*/
		
			IF var_company_id <> 0 THEN		-- 公司
				BEGIN
					IF NOT EXISTS(SELECT 1 FROM company_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND company_id=var_company_id) THEN
						INSERT INTO company_production(hotel_group_id,hotel_id,company_id,first_visit_date,first_visit_room,first_visit_rate,
							last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
							production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
						VALUES(arg_hotel_group_id,arg_hotel_id,var_company_id,var_biz_date,var_rmno,var_real_rate,NULL,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'ADMIN',NOW(),'ADMIN',NOW());
					END IF;
					IF NOT EXISTS(SELECT 1 FROM company_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND company_id=var_company_id) THEN
						INSERT INTO company_production(hotel_group_id,hotel_id,company_id,first_visit_date,first_visit_room,first_visit_rate,
							last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
							production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
						VALUES(arg_hotel_group_id,0,var_company_id,var_biz_date,var_rmno,var_real_rate,NULL,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'ADMIN',NOW(),'ADMIN',NOW());
					END IF;					
				
					UPDATE company_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
					production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights2,
					last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
					production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
						WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND company_id=var_company_id;
					UPDATE company_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
					production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights2,
					last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
					production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
						WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND company_id=var_company_id;				
					
					IF var_sta = 'O' AND var_rmno <>'' AND NOT EXISTS(SELECT 1 FROM production_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date<=var_bfdate AND accnt=var_accnt AND sta='O') THEN
						BEGIN
						UPDATE company_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND company_id=var_company_id;
						UPDATE company_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND company_id=var_company_id;
						END;
					END IF;						
					IF var_fb <> 0 THEN	
						BEGIN
						UPDATE company_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND company_id=var_company_id;
						UPDATE company_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND company_id=var_company_id;
						END;
					END IF;			
					IF var_en <> 0 THEN
						BEGIN
						UPDATE company_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND company_id=var_company_id;
						UPDATE company_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND company_id=var_company_id;
						END;
					END IF;
				END;
			END IF;
		
			IF var_agent_id <> 0 THEN	-- 旅行社
				BEGIN
					IF NOT EXISTS(SELECT 1 FROM company_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND company_id=var_agent_id) THEN
						INSERT INTO company_production(hotel_group_id,hotel_id,company_id,first_visit_date,first_visit_room,first_visit_rate,
							last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
							production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
						VALUES(arg_hotel_group_id,arg_hotel_id,var_agent_id,var_biz_date,var_rmno,var_real_rate,NULL,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'ADMIN',NOW(),'ADMIN',NOW());
					END IF;
					IF NOT EXISTS(SELECT 1 FROM company_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND company_id=var_agent_id) THEN
						INSERT INTO company_production(hotel_group_id,hotel_id,company_id,first_visit_date,first_visit_room,first_visit_rate,
							last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
							production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
						VALUES(arg_hotel_group_id,0,var_agent_id,var_biz_date,var_rmno,var_real_rate,NULL,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'ADMIN',NOW(),'ADMIN',NOW());
					END IF;
				
					UPDATE company_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
					production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights2,
					last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
					production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
						WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND company_id=var_agent_id;
					UPDATE company_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
					production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights2,
					last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
					production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
						WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND company_id=var_agent_id;
						
					IF var_sta = 'O' AND var_rmno <>'' AND NOT EXISTS(SELECT 1 FROM production_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date<=var_bfdate AND accnt=var_accnt AND sta='O') THEN
						BEGIN
						UPDATE company_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND company_id=var_agent_id;
						UPDATE company_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND company_id=var_agent_id;
						END;
					END IF;						
					IF var_fb <> 0 THEN
						BEGIN
						UPDATE company_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND company_id=var_agent_id;
						UPDATE company_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND company_id=var_agent_id;
						END;
					END IF;			
					IF var_en <> 0 THEN	
						BEGIN
						UPDATE company_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND company_id=var_agent_id;
						UPDATE company_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND company_id=var_agent_id;
						END;
					END IF;
				END;
			END IF;
						
			IF var_source_id <> 0 THEN	-- 订房中心
				BEGIN
					IF NOT EXISTS(SELECT 1 FROM company_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND company_id=var_source_id) THEN
						INSERT INTO company_production(hotel_group_id,hotel_id,company_id,first_visit_date,first_visit_room,first_visit_rate,
							last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
							production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
						VALUES(arg_hotel_group_id,arg_hotel_id,var_source_id,var_biz_date,var_rmno,var_real_rate,NULL,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'ADMIN',NOW(),'ADMIN',NOW());
					END IF;
					IF NOT EXISTS(SELECT 1 FROM company_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND company_id=var_source_id) THEN
						INSERT INTO company_production(hotel_group_id,hotel_id,company_id,first_visit_date,first_visit_room,first_visit_rate,
							last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
							production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
						VALUES(arg_hotel_group_id,0,var_source_id,var_biz_date,var_rmno,var_real_rate,NULL,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'ADMIN',NOW(),'ADMIN',NOW());
					END IF;	
					
					UPDATE company_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
					production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights2,
					last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
					production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
						WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND company_id=var_source_id;
					UPDATE company_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
					production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights2,
					last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
					production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
						WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND company_id=var_source_id;
						
					IF var_sta = 'O' AND var_rmno <>'' AND NOT EXISTS(SELECT 1 FROM production_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date<=var_bfdate AND accnt=var_accnt AND sta='O') THEN
						BEGIN
						UPDATE company_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND company_id=var_source_id;
						UPDATE company_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND company_id=var_source_id;
						END;
					END IF;						
					IF var_fb <> 0 THEN	
						BEGIN
						UPDATE company_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND company_id=var_source_id;
						UPDATE company_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND company_id=var_source_id;
						END;
					END IF;			
					IF var_en <> 0 THEN
						BEGIN
						UPDATE company_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND company_id=var_source_id;
						UPDATE company_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND company_id=var_source_id;
						END;
					END IF;
				END;
			END IF;		
		
			IF var_card_id IS NOT NULL AND var_card_id<>0 AND var_member_no<>'' THEN	-- 会员
				BEGIN	
					SELECT member_id INTO var_member_id FROM card_base WHERE hotel_group_id=arg_hotel_group_id AND card_no=var_member_no;
					
					IF NOT EXISTS(SELECT 1 FROM member_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_id=var_card_id) THEN
						INSERT INTO member_production(hotel_group_id,hotel_id,member_id,card_id,first_visit_date,first_visit_room,first_visit_rate,
							last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
							production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
						VALUES(arg_hotel_group_id,arg_hotel_id,var_member_id,var_card_id,var_biz_date,var_rmno,var_real_rate,NULL,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'ADMIN',NOW(),'ADMIN',NOW());
					END IF;
					IF NOT EXISTS(SELECT 1 FROM member_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND card_id=var_card_id) THEN
						INSERT INTO member_production(hotel_group_id,hotel_id,member_id,card_id,first_visit_date,first_visit_room,first_visit_rate,
							last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
							production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
						VALUES(arg_hotel_group_id,0,var_member_id,var_card_id,var_biz_date,var_rmno,var_real_rate,NULL,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'ADMIN',NOW(),'ADMIN',NOW());
					END IF;					
					
					UPDATE member_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
					production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights2,
					last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
					production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
						WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_id=var_card_id;							
					UPDATE member_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
					production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights2,
					last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
					production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
						WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND card_id=var_card_id;	
						
					IF var_sta = 'O' AND var_rmno <>'' AND NOT EXISTS(SELECT 1 FROM production_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date<=var_bfdate AND accnt=var_accnt AND sta='O') THEN
						BEGIN
						UPDATE member_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_id=var_card_id;
						UPDATE member_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND card_id=var_card_id;
						END;
					END IF;					
					IF var_fb <> 0 THEN	
						BEGIN
						UPDATE member_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_id=var_card_id;
						UPDATE member_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND card_id=var_card_id;
						END;
					END IF;			
					IF var_en <> 0 THEN
						BEGIN
						UPDATE member_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_id=var_card_id;
						UPDATE member_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND card_id=var_card_id;
						END;
					END IF;
				END;
			END IF;
		
			IF var_salesman <> '' THEN	-- 销售员
				BEGIN
					IF NOT EXISTS(SELECT 1 FROM sales_man_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND salesman_code=var_salesman) THEN
						INSERT INTO sales_man_production(hotel_group_id,hotel_id,salesman_code,first_visit_date,first_visit_room,first_visit_rate,
							last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
							production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
						VALUES(arg_hotel_group_id,arg_hotel_id,var_salesman,var_biz_date,var_rmno,var_real_rate,NULL,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'ADMIN',NOW(),'ADMIN',NOW());
					END IF;
					IF NOT EXISTS(SELECT 1 FROM sales_man_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND salesman_code=var_salesman) THEN
						INSERT INTO sales_man_production(hotel_group_id,hotel_id,salesman_code,first_visit_date,first_visit_room,first_visit_rate,
							last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
							production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
						VALUES(arg_hotel_group_id,0,var_salesman,var_biz_date,var_rmno,var_real_rate,NULL,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'ADMIN',NOW(),'ADMIN',NOW());
					END IF;					
				
					UPDATE sales_man_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
					production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights2,
					last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
					production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
						WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND salesman_code=var_salesman;				
					UPDATE sales_man_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
					production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights2,
					last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
					production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
						WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND salesman_code=var_salesman;		
			
					IF var_sta = 'O' AND var_rmno <>'' AND NOT EXISTS(SELECT 1 FROM production_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date<=var_bfdate AND accnt=var_accnt AND sta='O') THEN
						BEGIN
						UPDATE sales_man_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND salesman_code=var_salesman;
						UPDATE sales_man_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND salesman_code=var_salesman;
						END;
					END IF;							
					IF var_fb <> 0 THEN
						BEGIN
						UPDATE sales_man_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND salesman_code=var_salesman;
						UPDATE sales_man_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND salesman_code=var_salesman;
						END;
					END IF;			
					IF var_en <> 0 THEN	
						BEGIN
						UPDATE sales_man_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND salesman_code=var_salesman;
						UPDATE sales_man_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND salesman_code=var_salesman;
						END;
					END IF;
				END;
			END IF;
		
		SET done_cursor = 0;
		FETCH c_cursor INTO var_sta,var_rmno,var_accnt,var_master_id,var_guest_id,var_group_id,var_company_id,var_agent_id,var_source_id,var_member_no,var_card_id,var_salesman,var_nights,var_nights2,var_cxl,var_noshow,var_biz_date,var_real_rate,var_rm,var_fb,var_mt,var_en,var_ot,var_ttl;			
		END;
	END WHILE;
	CLOSE c_cursor;

END$$

DELIMITER ;