DELIMITER $$

USE `portal_ipms`$$

DROP PROCEDURE IF EXISTS `up_ihotel_reb_hotel_proc`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_reb_hotel_proc`(
          
)
    SQL SECURITY INVOKER
label_0:
BEGIN 
	DECLARE var_hotel_group_id	BIGINT;
	DECLARE var_hotel_id 	BIGINT;
 	DECLARE var_begin_date 	DATETIME;
	DECLARE done_cursor INT DEFAULT 0 ;	
    	DECLARE c_hotel CURSOR FOR 
  	SELECT hotel_group_id,id FROM hotel ORDER BY id;
 	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1 ;
	SET @procresult = 0 ;	
 
	OPEN c_hotel ;
	SET done_cursor = 0 ;
	FETCH c_hotel INTO var_hotel_group_id,var_hotel_id ;
	WHILE done_cursor = 0 DO
		BEGIN
			call up_ihotel_reb_repjie_month(var_hotel_group_id,var_hotel_id,'2016.10.1','2016.10.31');
			
 	 		SET done_cursor = 0 ;
			FETCH c_hotel INTO var_hotel_group_id,var_hotel_id ;
		END ;
	END WHILE ;
	CLOSE c_hotel ;    
	
         BEGIN
 		SET @procresult = 0 ;
		LEAVE label_0 ;
	END ;
     
END$$

DELIMITER ;