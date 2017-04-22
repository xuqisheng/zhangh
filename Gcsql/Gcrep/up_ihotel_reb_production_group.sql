DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_reb_production_group`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_reb_production_group`(
	IN arg_hotel_group_id	BIGINT(16),
	IN arg_type			VARCHAR(2)	-- G:宾客业绩,C:公司业绩,M:会员业绩,S:销售业绩
)
	SQL SECURITY INVOKER 

label_0:
BEGIN
	-- =============================================================================
	-- 用途:重建集团业绩
	-- 解释:
	-- 作者:zhangh
	-- =============================================================================
	DECLARE done_cursor		INT DEFAULT 0;
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
	DECLARE	var_rm			DECIMAL(12,2);
	DECLARE	var_fb			DECIMAL(12,2);
	DECLARE	var_mt			DECIMAL(12,2);
	DECLARE	var_en			DECIMAL(12,2);
	DECLARE	var_ot			DECIMAL(12,2);
	DECLARE	var_ttl			DECIMAL(12,2);	
	DECLARE var_member_id   BIGINT(16);
	DECLARE var_begin_date	DATETIME;
	DECLARE var_end_date	DATETIME;
	
	DECLARE c_cursor CURSOR FOR
		SELECT sta,rmno,accnt,master_id,guest_id,group_id,company_id,agent_id,source_id,member_no,salesman,nights,nights2,times_cxl,times_noshow,biz_date,real_rate,
			production_rm+production_rm_svc+production_rm_bf+production_rm_cms+production_rm_lau+production_rm_pkg,
			production_fb,production_mt,production_en,production_ot,production_ttl
			FROM production_detail 
			WHERE hotel_group_id=arg_hotel_group_id AND master_type IN ('master','pos') AND biz_date=var_begin_date			
			ORDER BY guest_id,group_id,company_id,agent_id,source_id,member_no,salesman;
	SELECT MIN(biz_date) INTO var_begin_date FROM production_detail  WHERE hotel_group_id=arg_hotel_group_id ;			
	SELECT MAX(biz_date) INTO var_end_date 	 FROM production_detail WHERE hotel_group_id=arg_hotel_group_id ;

	IF arg_type='G' THEN
		BEGIN
			DELETE FROM guest_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND arg_type='G';
			INSERT INTO guest_production(hotel_group_id,hotel_id,guest_id,first_visit_date,first_visit_room,first_visit_rate,
				last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
				production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
				SELECT hotel_group_id,0,guest_id,first_visit_date,'',0,NULL,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'ADMIN',NOW(),'ADMIN',NOW()
				FROM guest_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id<>0 GROUP BY guest_id;
		END;
	END IF;
	IF arg_type='C' THEN
		BEGIN
			DELETE FROM company_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND arg_type='C';
			INSERT INTO company_production(hotel_group_id,hotel_id,company_id,first_visit_date,first_visit_room,first_visit_rate,
				last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
				production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
				SELECT hotel_group_id,0,company_id,first_visit_date,'',0,NULL,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'ADMIN',NOW(),'ADMIN',NOW()
				FROM company_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id<>0 GROUP BY company_id;
		END;
	END IF;		
	IF arg_type='M' THEN
		BEGIN
			DELETE FROM member_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND arg_type='M';
			INSERT INTO member_production(hotel_group_id,hotel_id,member_id,card_id,first_visit_date,first_visit_room,first_visit_rate,
				last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
				production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)			
				SELECT hotel_group_id,0,member_id,card_id,first_visit_date,'',0,NULL,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'ADMIN',NOW(),'ADMIN',NOW()
				FROM member_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id<>0 GROUP BY card_id;				
		END;
	END IF;			
	IF arg_type='S' THEN
		BEGIN
			DELETE FROM sales_man_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND arg_type='S';
			INSERT INTO sales_man_production(hotel_group_id,hotel_id,salesman_code,first_visit_date,first_visit_room,first_visit_rate,
				last_visit_date,last_visit_room,last_visit_rate,days_in,times_in,times_cxl,times_noshow,times_trans,times_fb,times_en,
				production_rm,production_fb,production_en,production_mt,production_ot,production_ttl,create_user,create_datetime,modify_user,modify_datetime)
				SELECT hotel_group_id,0,salesman,first_visit_date,'',0,NULL,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,'ADMIN',NOW(),'ADMIN',NOW()
				FROM sales_man_production WHERE hotel_group_id=arg_hotel_group_id AND hotel_id<>0 GROUP BY salesman_code;
		END;
	END IF;

	WHILE var_begin_date <= var_begin_date DO
		BEGIN 
			OPEN c_cursor;
			SET done_cursor = 0;
			FETCH c_cursor INTO var_sta,var_accnt,var_master_id,var_rmno,var_guest_id,var_group_id,var_company_id,var_agent_id,var_source_id,var_member_no,var_salesman,var_nights,var_cxl,var_noshow,
				var_biz_date,var_real_rate,var_rm,var_fb,var_mt,var_en,var_ot,var_ttl;
			WHILE done_cursor = 0 DO
				BEGIN		
					IF arg_type='G' THEN							
						IF var_guest_id <> 0 THEN
							BEGIN
								UPDATE guest_production SET days_in = days_in + var_nights ,times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
								production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,
								last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
								production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
									WHERE hotel_group_id=arg_hotel_group_id  AND guest_id=var_guest_id;
												
								IF var_sta = 'O' AND NOT EXISTS(SELECT 1 FROM production_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date < var_begin_date AND accnt=var_accnt AND sta='O') THEN	
									UPDATE guest_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND guest_id=var_guest_id;
								END IF;	
								IF var_fb > 0 THEN	
									UPDATE guest_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND guest_id=var_guest_id;
								END IF;			
								IF var_en > 0 THEN
									UPDATE guest_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND guest_id=var_guest_id;
								END IF;
							END;
						END IF;
						IF var_group_id <> 0 THEN
							BEGIN
								UPDATE guest_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
								production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights2,
								last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
								production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
									WHERE hotel_group_id=arg_hotel_group_id  AND guest_id=var_group_id;
						
								IF var_sta = 'O' AND var_rmno<>'' AND NOT EXISTS(SELECT 1 FROM production_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date < var_begin_date AND accnt=var_accnt AND sta='O') THEN
									UPDATE guest_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND guest_id=var_group_id;
								END IF;							
								IF var_fb > 0 THEN	
									UPDATE guest_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND guest_id=var_group_id;
								END IF;			
								IF var_en > 0 THEN	
									UPDATE guest_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND guest_id=var_group_id;
								END IF;
							END;
						END IF;				
					END IF;
					
					IF arg_type='C' THEN
						IF var_company_id <> 0 THEN
							BEGIN
								UPDATE company_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
								production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights2,
								last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
								production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
									WHERE hotel_group_id=arg_hotel_group_id  AND company_id=var_company_id;
								IF var_sta = 'O' AND var_rmno<>'' AND NOT EXISTS(SELECT 1 FROM production_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date < var_begin_date AND accnt=var_accnt AND sta='O') THEN
									UPDATE company_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND company_id=var_company_id;
								END IF;						
								IF var_fb > 0 THEN	
									UPDATE company_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND company_id=var_company_id;
								END IF;			
								IF var_en > 0 THEN
									UPDATE company_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND company_id=var_company_id;
								END IF;								
							END;
						END IF;
						IF var_agent_id <> 0 THEN
							BEGIN				
								UPDATE company_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
								production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights2,
								last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
								production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
									WHERE hotel_group_id=arg_hotel_group_id  AND company_id=var_agent_id;
								IF var_sta = 'O' AND var_rmno<>'' AND NOT EXISTS(SELECT 1 FROM production_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date < var_begin_date AND accnt=var_accnt AND sta='O') THEN	
									UPDATE company_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND company_id=var_agent_id;
								END IF;						
								IF var_fb > 0 THEN
									UPDATE company_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND company_id=var_agent_id;
								END IF;			
								IF var_en > 0 THEN	
									UPDATE company_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND company_id=var_agent_id;
								END IF;								
							END;
						END IF;						
						IF var_source_id <> 0 THEN
							BEGIN
								UPDATE company_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
								production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights2,
								last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
								production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
									WHERE hotel_group_id=arg_hotel_group_id  AND company_id=var_source_id;
								IF var_sta = 'O' AND var_rmno<>'' AND NOT EXISTS(SELECT 1 FROM production_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date < var_begin_date AND accnt=var_accnt AND sta='O') THEN
									UPDATE company_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND company_id=var_source_id;
								END IF;						
								IF var_fb > 0 THEN	
									UPDATE company_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND company_id=var_source_id;
								END IF;			
								IF var_en > 0 THEN
									UPDATE company_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND company_id=var_source_id;
								END IF;							
							END;
						END IF;						
					END IF;

					IF arg_type='M' THEN
						IF var_member_no <> 0 THEN
							BEGIN
								UPDATE member_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
								production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights2,
								last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
								production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
									WHERE hotel_group_id=arg_hotel_group_id  AND card_id=var_card_id;							
								IF var_sta = 'O' AND var_rmno<>'' AND NOT EXISTS(SELECT 1 FROM production_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date < var_begin_date AND accnt=var_accnt AND sta='O') THEN
									UPDATE member_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND card_id=var_card_id;
								END IF;					
								IF var_fb > 0 THEN	
									UPDATE member_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND card_id=var_card_id;
								END IF;			
								IF var_en > 0 THEN
									UPDATE member_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND card_id=var_card_id;
								END IF;										
							END;
						END IF;
					END IF;

					IF arg_type='S' THEN
						IF var_salesman <> 0 THEN
							BEGIN
								UPDATE sales_man_production SET times_cxl = times_cxl + var_cxl,times_noshow = times_noshow + var_noshow,
								production_rm = production_rm + var_rm,production_fb = production_fb + var_fb,days_in = days_in + var_nights2,
								last_visit_date = var_biz_date,last_visit_room = var_rmno,last_visit_rate = var_real_rate,
								production_en = production_en + var_en,production_mt = production_mt + var_mt,production_ot = production_ot + var_ot,production_ttl = production_ttl + var_ttl
									WHERE hotel_group_id=arg_hotel_group_id  AND salesman_code=var_salesman;				
								IF var_sta = 'O' AND var_rmno<>'' AND NOT EXISTS(SELECT 1 FROM production_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date < var_begin_date AND accnt=var_accnt AND sta='O') THEN	
									UPDATE sales_man_production SET times_in = times_in + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND salesman_code=var_salesman;
								END IF;							
								IF var_fb > 0 THEN
									UPDATE sales_man_production SET times_fb = times_fb + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND salesman_code=var_salesman;
								END IF;			
								IF var_en > 0 THEN	
									UPDATE sales_man_production SET times_en = times_en + 1 WHERE hotel_group_id=arg_hotel_group_id  AND hotel_id=0 AND salesman_code=var_salesman;
								END IF;								
							END;
						END IF;						
					END IF;			
			SET done_cursor = 0;
			FETCH c_cursor INTO var_sta,var_accnt,var_master_id,var_rmno,var_guest_id,var_group_id,var_company_id,var_agent_id,var_source_id,var_member_no,var_salesman,var_nights,var_cxl,var_noshow,
				var_biz_date,var_real_rate,var_rm,var_fb,var_mt,var_en,var_ot,var_ttl;		
			END;
		END WHILE;
		CLOSE c_cursor;		
		SET var_begin_date = DATE_ADD(var_begin_date,INTERVAL 1 DAY);		
		END;
	END WHILE;
END$$

DELIMITER ;