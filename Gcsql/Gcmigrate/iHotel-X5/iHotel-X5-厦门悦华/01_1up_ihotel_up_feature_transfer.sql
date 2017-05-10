DELIMITER $$

 
DROP PROCEDURE IF EXISTS `up_ihotel_up_feature_transfer`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_up_feature_transfer`(
           IN arg_hotel_group_id     INT,
           IN arg_hotel_id           INT
)
    SQL SECURITY INVOKER
label_0:
BEGIN 
	DECLARE var_gcode 	CHAR(3) ;
	DECLARE var_type  	VARCHAR(255);
	DECLARE var_pos	  	INT;
	DECLARE var_accnt	BIGINT;
	DECLARE var_code	VARCHAR(4);
	DECLARE var_descript	VARCHAR(255);
	DECLARE var_bdate	DATETIME;
	DECLARE var_no		VARCHAR(12);
	DECLARE var_feature	VARCHAR(12);
	
	DECLARE done_cursor INT DEFAULT 0 ;	
 
 
	DECLARE c_feature CURSOR FOR
	SELECT 	NO,feature1 FROM guest_feature ORDER BY NO;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1 ;
	SET @procresult = 0 ;	
 
	 
	OPEN c_feature;
	SET done_cursor = 0;
	FETCH c_feature INTO var_no,var_feature;
	WHILE done_cursor = 0 DO
		BEGIN
			SET var_pos = INSTR(var_feature,',');
				WHILE var_pos > 0 DO
					BEGIN
						SET var_code = IFNULL(SUBSTRING(var_feature,1,var_pos-1),'');
						UPDATE guest_feature a,up_map_code b SET a.feature2 = CONCAT(a.feature2,b.code_new,',') WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code = 'room_feature' AND  b.code_old = var_code AND a.no = var_no;
						SET var_feature = IFNULL(LTRIM(INSERT(var_feature,   1,   var_pos,   '')),   '') ;
						SET var_pos = INSTR(var_feature,',');
					END;
				END WHILE;
			SET  done_cursor = 0;
			FETCH  c_feature INTO var_no,var_feature;	
		END;
	END WHILE;
	CLOSE c_feature;	
 		
		 
  
    
        BEGIN
		SET @procresult = 0 ;
		LEAVE label_0 ;
	END ;
     
END$$

DELIMITER ;