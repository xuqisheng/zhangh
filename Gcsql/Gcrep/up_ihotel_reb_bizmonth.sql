DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_reb_bizmonth`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_reb_bizmonth`(
	IN arg_hotel_group_id	INT,
	IN arg_year_begin		INT,
	IN arg_year_num			INT
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ==================================================================
	-- 用途：biz_month 会计周期数据生成(针对会计日期为自然月客户) 
	-- 解释: CALL up_ihotel_reb_bizmonth(集团id,开始年份,生成几年数据)
	-- 范例: CALL up_ihotel_reb_bizmonth(1,2015,10)
	-- 作者：zhangh 2014.10.31
	-- ==================================================================
	DECLARE done_cursor 	INT DEFAULT 0;
	DECLARE var_hotel_id 	INT;
	DECLARE var_min_id 		INT;
	DECLARE var_year 		INT;
	DECLARE var_month 		INT;
	DECLARE var_num 		INT;	
	DECLARE var_datestr	 	CHAR(8);
	DECLARE var_begin_date	DATETIME;
	DECLARE var_end_date	DATETIME;	
	
 	DECLARE c_cursor CURSOR FOR SELECT id FROM hotel WHERE hotel_group_id=arg_hotel_group_id ORDER BY id;	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1; 
 
	SET var_year = arg_year_begin;
	SET var_num = 0;
	SET var_month = 1;
 
	OPEN c_cursor ;
	SET done_cursor = 0;
	FETCH c_cursor INTO var_hotel_id;
		WHILE done_cursor = 0 DO
			BEGIN
				-- 这一句当时添加时担心存在自定义会计日期的客户
				IF EXISTS (SELECT 1 FROM biz_month WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=var_hotel_id AND biz_year=arg_year_begin AND biz_month=8 AND DAY(begin_date)=1) THEN			
					BEGIN
						DELETE FROM biz_month WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=var_hotel_id AND biz_year>=arg_year_begin;			
						
						WHILE var_num <= arg_year_num DO
							BEGIN						
								
								WHILE var_month <= 12 DO
									BEGIN
										IF var_month < 10 THEN 					
											SET var_datestr = CONCAT(var_year,'0',var_month,'01');
										ELSE
											SET var_datestr = CONCAT(var_year,var_month,'01');
										END IF;
										SET var_begin_date = DATE_FORMAT(var_datestr,'%Y-%m-%d');
										SET var_end_date   = ADDDATE(DATE_ADD(DATE_FORMAT(var_datestr,'%Y-%m-%d'),INTERVAL 1 MONTH),-1);
										
										INSERT INTO biz_month(hotel_group_id,hotel_id,biz_year,biz_month,begin_date,end_date,day_num,remark,create_user,create_datetime,modify_user,modify_datetime)
											SELECT arg_hotel_group_id,var_hotel_id,var_year,var_month,var_begin_date,var_end_date,DATEDIFF(var_end_date,var_begin_date)+1,CONCAT(var_year,'年',var_month,'月'),'ADMIN',NOW(),'ADMIN',NOW();
											
										SET var_month = var_month + 1;
									END;
								END WHILE;			
						
								SET var_num = var_num + 1;
								SET var_year = var_year + 1;
								SET var_month = 1;
							END;
						END WHILE;
						
						SET var_year = arg_year_begin;
						SET var_num = 0;
					END;
				END IF;			
				
			SET done_cursor = 0;
			FETCH c_cursor INTO var_hotel_id;
			END;
		END WHILE ;
	CLOSE c_cursor;
	
	SELECT MIN(id) INTO var_min_id FROM hotel WHERE hotel_group_id=arg_hotel_group_id;
	
	DELETE FROM biz_month WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=0 AND biz_year>=arg_year_begin;
	INSERT INTO biz_month(hotel_group_id,hotel_id,biz_year,biz_month,begin_date,end_date,day_num,remark,create_user,create_datetime,modify_user,modify_datetime)
		SELECT hotel_group_id,0,biz_year,biz_month,begin_date,end_date,day_num,remark,create_user,create_datetime,modify_user,modify_datetime
			FROM biz_month WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=var_min_id AND biz_year>=arg_year_begin;	
	
END$$

DELIMITER ;


-- CALL up_ihotel_reb_bizmonth(1,2014,10);

-- DROP PROCEDURE IF EXISTS `up_ihotel_reb_bizmonth`;