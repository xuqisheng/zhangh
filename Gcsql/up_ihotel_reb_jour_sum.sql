DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_reb_jour_sum`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_reb_jour_sum`(
	IN arg_hotel_group_id 	BIGINT(16),
	IN arg_hotel_id 		BIGINT(16),
	IN arg_begin_date		DATETIME,
	IN arg_end_date			DATETIME,
	IN arg_code				VARCHAR(10)
    )	
	SQL SECURITY INVOKER
label_0:
BEGIN
	-- =============================================================================
	-- 用途:重复营业日报指定某项的月和年累计
	-- 解释:
	-- 作者:zhangh 2015-04-25
	-- =============================================================================
	DECLARE var_bdate		DATETIME;

	SELECT ADDDATE(biz_date1, -1) INTO var_bdate FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	
	IF arg_end_date > var_bdate THEN
		SET arg_end_date = var_bdate;
	END IF;

	WHILE arg_begin_date <= arg_end_date DO
		BEGIN

			IF EXISTS(SELECT 1 FROM biz_month WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND begin_date = arg_begin_date) THEN
				BEGIN
					UPDATE rep_jour_history a SET a.month=a.day,a.rebate_month=a.rebate_day
						WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_begin_date AND code=arg_code;						
				END;
			ELSE
				BEGIN			
					UPDATE rep_jour_history a,rep_jour_history b SET a.month=a.day+b.month,a.rebate_month=a.rebate_day+b.rebate_month
						WHERE a.code=b.code AND a.code=arg_code 
						AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_begin_date
						AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=ADDDATE(arg_begin_date,-1);							
				END;
			END IF;				
	
			IF EXISTS(SELECT 1 FROM biz_month WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_month = 1 AND begin_date = arg_begin_date) THEN
				BEGIN
					UPDATE rep_jour_history a SET a.year=a.day,a.rebate_year=a.rebate_day
						WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_begin_date AND code=arg_code;
				END;
			ELSE
				BEGIN				
					UPDATE rep_jour_history a,rep_jour_history b SET a.year=a.day+b.year,a.rebate_year=a.rebate_day+b.rebate_year
						WHERE a.code=b.code AND a.code=arg_code 
						AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_begin_date
						AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=ADDDATE(arg_begin_date,-1);				
				END;				
			END IF;	
		
		SET arg_begin_date = ADDDATE(arg_begin_date,1);
				
		END;
	END WHILE;			

	UPDATE rep_jour a,rep_jour_history b SET
		a.month=b.month,a.rebate_month=b.rebate_month,
		a.year=b.year,a.rebate_year=b.rebate_year
	WHERE a.code=b.code AND a.code=arg_code
	AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_end_date
	AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_end_date;	
	
    END$$

DELIMITER ; 

-- CALL up_ihotel_reb_jour_sum(1,108,'2015-1-1','2015-4-24','000025');
-- DROP PROCEDURE IF EXISTS `up_ihotel_reb_jour_sum`;