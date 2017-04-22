DELIMITER $$		-- 定界符

DROP PROCEDURE IF EXISTS `up_ihotel_rep_jour_insert`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_jour_insert`(
	IN arg_hotel_group_id 	BIGINT(16),
	IN arg_hotel_id 		BIGINT(16),
	IN arg_date_begin		DATETIME,
	IN arg_date_end			DATETIME,
	IN arg_code				VARCHAR(10),
	IN arg_codename			VARCHAR(50)
    )	
	SQL SECURITY INVOKER
label_0:
BEGIN
	-- 
	-- =============================================================================
	-- 用途:往营业日报表里添加指定行
	-- 解释:CALL up_ihotel_rep_jour_insert(1,108,'2015-1-1','2015-4-12','000025','会议室租金');
	-- 作者:张惠
	-- =============================================================================
	
	WHILE arg_date_begin <= arg_date_end DO
		BEGIN
			INSERT INTO rep_jour (hotel_group_id,hotel_id,biz_date,code,descript,descript_en,day,month,year,rebate_day,rebate_month,rebate_year,is_show,list_order) 
				SELECT arg_hotel_group_id,arg_hotel_id,arg_date_begin,arg_code,arg_codename,'','0','0','0','0.00','0.00','0.00','T','3';	
		
		SET arg_date_begin = ADDDATE(arg_date_begin,1);
				
		END;
	END WHILE;			
			
	INSERT INTO rep_jour_history SELECT * FROM rep_jour WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date<=arg_date_end AND code=arg_code;
	
	DELETE FROM rep_jour WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date<=arg_date_end AND code=arg_code;	
	
    END$$

DELIMITER ; 