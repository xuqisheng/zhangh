DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_reb_bizmonth_custom`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_reb_bizmonth_custom`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id	        INT,
	IN arg_year_begin		INT,
	IN arg_begin_day        INT,
	IN arg_year_num			INT
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ==================================================================
	-- 用途：biz_month 会计周期数据生成(针对会计日期为自定义的客户)
	-- 解释: CALL up_ihotel_reb_bizmonth_custom(集团id,酒店id,开始年份,生成几年数据)
	-- 范例: CALL up_ihotel_reb_bizmonth_custom(1,1,2015,25,10)
	-- 作者：zhangh 2017.3.24
	-- ==================================================================
	DECLARE done_cursor 	INT DEFAULT 0;
	DECLARE var_min_id 		INT;
	DECLARE var_year 		INT;
	DECLARE var_month 		INT;
	DECLARE var_num 		INT;	
	DECLARE var_datestr	 	CHAR(8);
	DECLARE var_begin_date	DATETIME;
	DECLARE var_end_date	DATETIME;	

	SET var_year = arg_year_begin;
	SET var_num = 0;
	SET var_month = 1;

    DELETE FROM biz_month WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_year>=arg_year_begin;

    WHILE var_num <= arg_year_num DO
        BEGIN

            WHILE var_month <= 12 DO
                BEGIN
                    IF var_month < 10 THEN
                        SET var_datestr = CONCAT(var_year,'0',var_month,arg_begin_day);
                    ELSE
                        SET var_datestr = CONCAT(var_year,var_month,arg_begin_day);
                    END IF;
                    SET var_begin_date = DATE_FORMAT(var_datestr,'%Y-%m-%d');
                    SET var_end_date   = ADDDATE(DATE_ADD(DATE_FORMAT(var_datestr,'%Y-%m-%d'),INTERVAL 1 MONTH),-1);

                    INSERT INTO biz_month(hotel_group_id,hotel_id,biz_year,biz_month,begin_date,end_date,day_num,remark,create_user,create_datetime,modify_user,modify_datetime)
                        SELECT arg_hotel_group_id,arg_hotel_id,var_year,var_month,var_begin_date,var_end_date,DATEDIFF(var_end_date,var_begin_date)+1,CONCAT(var_year,'年',var_month,'月'),'ADMIN',NOW(),'ADMIN',NOW();

                    SET var_month = var_month + 1;
                END;
            END WHILE;

            SET var_num = var_num + 1;
            SET var_year = var_year + 1;
            SET var_month = 1;
        END;
    END WHILE;

    UPDATE biz_month SET biz_month = biz_month + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_year>=arg_year_begin ORDER BY biz_month DESC;
    UPDATE biz_month SET biz_month = 1,biz_year = biz_year + 1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_year>=arg_year_begin AND biz_month=13;

	
END$$

DELIMITER ;


-- CALL up_ihotel_reb_bizmonth_custom(1,1,2017,26,10);

DROP PROCEDURE IF EXISTS `up_ihotel_reb_bizmonth_custom`;