DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_optimize_table`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_optimize_table`(
	IN arg_schema 	VARCHAR(20)
    )	
	SQL SECURITY INVOKER
label_0:
BEGIN
	DECLARE done_cursor 	INT DEFAULT 0;
	DECLARE var_table_name	VARCHAR(50);
	DECLARE var_sql 		VARCHAR(1024);
	
	DECLARE c_cursor CURSOR FOR 	
		SELECT table_name FROM information_schema.TABLES WHERE TABLE_SCHEMA=arg_schema AND table_type='BASE TABLE' ORDER BY TABLE_NAME;
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;	

	OPEN c_cursor ;
	SET done_cursor = 0 ;
	FETCH c_cursor INTO var_table_name; 
	
	WHILE done_cursor = 0 DO
		BEGIN		
			SET var_sql = '';
			SET var_sql = CONCAT("OPTIMIZE TABLE ",var_table_name);
			
			SET @exec_sql = var_sql;
			
			PREPARE stmt FROM @exec_sql;
			EXECUTE stmt;		
								
		SET done_cursor = 0 ;
		FETCH c_cursor INTO var_table_name;  
		END ;
	END WHILE ;
	CLOSE c_cursor ;
	
END$$

DELIMITER ;  

CALL up_ihotel_optimize_table('portal_group');

DROP PROCEDURE IF EXISTS `up_ihotel_optimize_table`;