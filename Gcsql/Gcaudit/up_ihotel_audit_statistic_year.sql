DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_audit_statistic_year`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_audit_statistic_year`(
	IN 	arg_hotel_group_id	BIGINT(16),
	IN 	arg_hotel_id		BIGINT(16),
	OUT	arg_ret				BIGINT(16),
	OUT arg_msg				VARCHAR(128)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- =========================================================
	--  夜审报表 -- statistic_y 年统计
	-- 
	-- 作者：zhangh
	-- =========================================================	
	DECLARE done_cursor 	INT DEFAULT 0;
	DECLARE var_bdate		DATETIME;
	DECLARE var_byear		INT;
	DECLARE var_bmonth		INT;
	DECLARE var_bday		INT;	
	DECLARE var_accnt		BIGINT(16);
	DECLARE var_master_id	BIGINT(16);
	DECLARE var_rmno		VARCHAR(20);
	DECLARE var_sta			CHAR(2);
	DECLARE var_guest_id	BIGINT(16);
	DECLARE var_group_id	BIGINT(16);
	DECLARE var_company_id	BIGINT(16);
	DECLARE var_agent_id	BIGINT(16);
	DECLARE var_source_id	BIGINT(16);
	DECLARE var_card_id		BIGINT(16);
	DECLARE var_salesman	VARCHAR(20);
	DECLARE var_nights		DECIMAL(8,2);
	DECLARE var_nights2		DECIMAL(8,2);
	DECLARE var_rm			DECIMAL(8,2);
	DECLARE var_fb			DECIMAL(8,2);
	DECLARE var_mt			DECIMAL(8,2);
	DECLARE var_en			DECIMAL(8,2);
	DECLARE var_sp			DECIMAL(8,2);
	DECLARE var_ot			DECIMAL(8,2);
	DECLARE var_persons		INT;	
	
	DECLARE c_cursor CURSOR FOR SELECT accnt,master_id,rmno,sta,guest_id,group_id,company_id,agent_id,source_id,IFNULL(card_id,0),salesman,
		nights,nights2,production_rm,
		production_fb,production_mt,production_en,production_sp,production_ot,adult+children 
		FROM production_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND master_type IN ('master','pos') AND biz_date = var_bdate;
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	
	SELECT ADDDATE(biz_date1, -1) INTO var_bdate FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id ;
	SET var_byear = YEAR(var_bdate);
	SET var_bmonth = MONTH(var_bdate);		
	SET arg_ret = 1, arg_msg = 'OK';
	
	OPEN c_cursor;
	SET done_cursor=0;
	FETCH c_cursor INTO var_accnt,var_master_id,var_rmno,var_sta,var_guest_id,var_group_id,var_company_id,var_agent_id,var_source_id,var_card_id,var_salesman,var_nights,var_nights2,var_rm,var_fb,var_mt,var_en,var_sp,var_ot,var_persons;
	WHILE done_cursor = 0 DO
		IF var_guest_id <> 0 THEN	-- 宾客
			IF var_nights > 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_rooms_nights','F',var_guest_id,var_nights);
			END IF;
			IF var_persons > 0 AND var_sta='I' THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_persons_adult','F',var_guest_id,var_persons);			
			END IF;				
			IF var_rm <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_room','F',var_guest_id,var_rm);			
			END IF;
			IF var_fb <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_fb','F',var_guest_id,var_fb);			
			END IF;	
			IF var_mt <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_mt','F',var_guest_id,var_mt);			
			END IF;	
			IF var_en <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_en','F',var_guest_id,var_en);			
			END IF;	
			IF var_sp <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_sp','F',var_guest_id,var_sp);			
			END IF;	
			IF var_ot <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_extras','F',var_guest_id,var_ot);			
			END IF;			
		END IF;
		
		IF var_group_id <> 0 THEN	-- 团体
			IF var_nights > 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_rooms_nights','G',var_group_id,var_nights2);
			END IF;
			IF var_persons > 0 AND var_sta='I' THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_persons_adult','G',var_group_id,var_persons);			
			END IF;				
			IF var_rm <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_room','G',var_group_id,var_rm);			
			END IF;
			IF var_fb <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_fb','G',var_group_id,var_fb);			
			END IF;	
			IF var_mt <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_mt','G',var_group_id,var_mt);			
			END IF;	
			IF var_en <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_en','G',var_group_id,var_en);			
			END IF;	
			IF var_sp <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_sp','G',var_group_id,var_sp);			
			END IF;	
			IF var_ot <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_extras','G',var_group_id,var_ot);			
			END IF;			
		END IF;		
	
		IF var_company_id <> 0 THEN	-- 公司
			IF var_nights > 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_rooms_nights','C',var_company_id,var_nights2);
			END IF;
			IF var_persons > 0 AND var_sta='I' THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_persons_adult','C',var_company_id,var_persons);			
			END IF;				
			IF var_rm <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_room','C',var_company_id,var_rm);			
			END IF;
			IF var_fb <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_fb','C',var_company_id,var_fb);			
			END IF;	
			IF var_mt <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_mt','C',var_company_id,var_mt);			
			END IF;	
			IF var_en <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_en','C',var_company_id,var_en);			
			END IF;	
			IF var_sp <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_sp','C',var_company_id,var_sp);			
			END IF;	
			IF var_ot <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_extras','C',var_company_id,var_ot);			
			END IF;			
		END IF;	
		
		IF var_agent_id <> 0 THEN	-- 旅行社
			IF var_nights > 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_rooms_nights','A',var_agent_id,var_nights2);
			END IF;
			IF var_persons > 0 AND var_sta='I' THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_persons_adult','A',var_agent_id,var_persons);			
			END IF;				
			IF var_rm <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_room','A',var_agent_id,var_rm);			
			END IF;
			IF var_fb <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_fb','A',var_agent_id,var_fb);			
			END IF;	
			IF var_mt <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_mt','A',var_agent_id,var_mt);			
			END IF;	
			IF var_en <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_en','A',var_agent_id,var_en);			
			END IF;	
			IF var_sp <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_sp','A',var_agent_id,var_sp);			
			END IF;	
			IF var_ot <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_extras','A',var_agent_id,var_ot);			
			END IF;			
		END IF;			
	
		IF var_source_id <> 0 THEN	-- 订房中心
			IF var_nights > 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_rooms_nights','S',var_source_id,var_nights2);
			END IF;
			IF var_persons > 0 AND var_sta='I' THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_persons_adult','S',var_source_id,var_persons);			
			END IF;				
			IF var_rm <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_room','S',var_source_id,var_rm);			
			END IF;
			IF var_fb <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_fb','S',var_source_id,var_fb);			
			END IF;	
			IF var_mt <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_mt','S',var_source_id,var_mt);			
			END IF;	
			IF var_en <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_en','S',var_source_id,var_en);			
			END IF;	
			IF var_sp <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_sp','S',var_source_id,var_sp);			
			END IF;	
			IF var_ot <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_extras','S',var_source_id,var_ot);			
			END IF;			
		END IF;		
	
		IF var_card_id <> 0 THEN	-- 会员
			IF var_nights > 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_rooms_nights','CAR',var_card_id,var_nights2);
			END IF;
			IF var_persons > 0 AND var_sta='I' THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_persons_adult','CAR',var_card_id,var_persons);			
			END IF;				
			IF var_rm <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_room','CAR',var_card_id,var_rm);			
			END IF;
			IF var_fb <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_fb','CAR',var_card_id,var_fb);			
			END IF;	
			IF var_mt <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_mt','CAR',var_card_id,var_mt);			
			END IF;	
			IF var_en <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_en','CAR',var_card_id,var_en);			
			END IF;	
			IF var_sp <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_sp','CAR',var_card_id,var_sp);			
			END IF;	
			IF var_ot <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_extras','CAR',var_card_id,var_ot);			
			END IF;			
		END IF;	

		IF var_salesman <> '' THEN	-- 销售员
			IF var_nights > 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_rooms_nights','SAL',var_salesman,var_nights2);
			END IF;
			IF var_persons > 0 AND var_sta='I' THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_persons_adult','SAL',var_salesman,var_persons);			
			END IF;				
			IF var_rm <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_room','SAL',var_salesman,var_rm);			
			END IF;
			IF var_fb <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_fb','SAL',var_salesman,var_fb);			
			END IF;	
			IF var_mt <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_mt','SAL',var_salesman,var_mt);			
			END IF;	
			IF var_en <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_en','SAL',var_salesman,var_en);			
			END IF;	
			IF var_sp <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_sp','SAL',var_salesman,var_sp);			
			END IF;	
			IF var_ot <> 0 THEN
				CALL up_ihotel_statistic_save_year(arg_hotel_group_id,arg_hotel_id,var_bdate,'yielddb_revenus_extras','SAL',var_salesman,var_ot);			
			END IF;			
		END IF;

		SET done_cursor = 0;
		FETCH c_cursor INTO var_accnt,var_master_id,var_rmno,var_sta,var_guest_id,var_group_id,var_company_id,var_agent_id,var_source_id,var_card_id,var_salesman,var_nights,var_nights2,var_rm,var_fb,var_mt,var_en,var_sp,var_ot,var_persons;
		END WHILE;
	CLOSE c_cursor;	

	UPDATE statistic_y SET month99 = month01 + month02 + month03 + month04 + month05 + month06 + month07 + month08 + month09 + month10 + month11 + month12 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND year=var_byear;

END$$

DELIMITER ;