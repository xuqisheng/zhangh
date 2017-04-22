DELIMITER $$

USE `portal_pms`$$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_bonus_detail`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `up_ihotel_rep_bonus_detail`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT,
	IN arg_date_begin		DATETIME,
	IN arg_date_end			DATETIME  
    )
    SQL SECURITY INVOKER
BEGIN
	DECLARE done_cursor 	INT DEFAULT 0;
	DECLARE var_id			INT;
	DECLARE var_specials	VARCHAR(50);
	DECLARE var_special		VARCHAR(20);
	DECLARE var_amount		DECIMAL(8,2);
	
	DECLARE var_pos			INT;	
	
	DECLARE c_cursor CURSOR FOR 	
	SELECT id,specials,bonus_amount FROM rep_bonus_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id
		AND biz_date>= arg_date_begin AND biz_date <= arg_date_end ORDER BY id;
		
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
		
	DROP TABLE IF EXISTS tmp_bonus_detail;
	CREATE TABLE tmp_bonus_detail(
		hotel_group_id 	INT NOT NULL,
		hotel_id 		INT NOT NULL,
		bonus_id		INT,
		bonus_code		VARCHAR(20),
		bonus_name		VARCHAR(30),
		bonus_num		DECIMAL(8,2),
		bonus_amount	DECIMAL(8,2),
		KEY index1(hotel_group_id,hotel_id,bonus_id),
		KEY index2(hotel_group_id,hotel_id,bonus_code)
	);
	
	OPEN c_cursor ;
	FETCH c_cursor INTO var_id,var_specials,var_amount; 
	
	WHILE done_cursor = 0 DO
		BEGIN				
			SET var_specials = CONCAT(var_specials,',');
			SET var_pos = INSTR(TRIM(var_specials),',');
	
			WHILE var_pos > 0 DO
				BEGIN
					SET var_special =  SUBSTR(var_specials,1,var_pos - 1);			
					INSERT INTO tmp_bonus_detail(hotel_group_id,hotel_id,bonus_id,bonus_code,bonus_num,bonus_amount)
						SELECT arg_hotel_group_id,arg_hotel_id,var_id,var_special,0,var_amount;
			
					SET var_specials = SUBSTR(var_specials,var_pos + 1);
					SET var_pos = INSTR(TRIM(var_specials),',');
				END;
			END WHILE;
	
		SET done_cursor = 0 ;
		FETCH c_cursor INTO var_id,var_specials,var_amount; 
  
		END ;
	END WHILE ;
	CLOSE c_cursor ;
	
	UPDATE tmp_bonus_detail a,(SELECT b.bonus_id,COUNT(1) AS idnum FROM (SELECT * FROM tmp_bonus_detail) AS b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id GROUP BY b.bonus_id) AS b 
		SET a.bonus_num = b.idnum
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.bonus_id = b.bonus_id;
	
	UPDATE tmp_bonus_detail SET bonus_num = ROUND(bonus_amount/bonus_num,2) WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	
	UPDATE tmp_bonus_detail a,USER b SET a.bonus_name = b.name 
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id 
			AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.bonus_code = b.code;
	SELECT a.id,a.biz_date,a.rmno,a.real_rate,a.base_rate,(a.real_rate - a.base_rate) AS diff_rate,b.bonus_code,b.bonus_name,b.bonus_num,c.descript AS market
	FROM rep_bonus_detail a
		LEFT JOIN code_base c ON c.hotel_group_id=arg_hotel_group_id AND c.hotel_id=arg_hotel_id AND c.parent_code = 'market_code' AND a.market = c.code,tmp_bonus_detail b 
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id 
			AND b.hotel_id=arg_hotel_id AND a.id = b.bonus_id ORDER BY a.biz_date,a.rmno+0,b.bonus_code;
	
	DROP TABLE IF EXISTS tmp_bonus_detail;
	
    END$$

DELIMITER ;