DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_dokeep_snapshot`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_dokeep_snapshot`(
	IN 	arg_hotel_group_id	INT,
	IN 	arg_hotel_id		INT
)
	SQL SECURITY INVOKER 
label_0:
BEGIN
	
	DECLARE done_cursor 	INT DEFAULT 0;
	DECLARE var_master_type VARCHAR(20);
	DECLARE var_master_id	INT;
	
	DECLARE c_cursor CURSOR FOR 	
	SELECT master_type,master_id
		FROM master_snapshot_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id ORDER BY master_type,master_id;
		
		
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	
	OPEN c_cursor ;
	SET done_cursor = 0 ;	
	FETCH c_cursor INTO var_master_type,var_master_id; 
	
	WHILE done_cursor = 0 DO
		BEGIN	

			CALL up_ihotel_master_snapshot_maint(arg_hotel_group_id,arg_hotel_id,var_master_type,var_master_id,@a,@t);

		SET done_cursor = 0 ;
		FETCH c_cursor INTO var_master_type,var_master_id;  
		END ;
	END WHILE ;
	CLOSE c_cursor ;

	SELECT 'EXEC END -- OK';

END$$

DELIMITER ;

CALL up_ihotel_dokeep_snapshot(1,16);
DROP PROCEDURE IF EXISTS `up_ihotel_dokeep_snapshot`;