DELIMITER $$

USE `portal`$$

DROP PROCEDURE IF EXISTS `up_ihotel_exec_cursor`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_exec_cursor`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN arg_biz_date			DATETIME
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	DECLARE done_cursor		INT DEFAULT 0;
	DECLARE var_accnt		INT;
	
	DECLARE c_cursor CURSOR FOR 
		SELECT accnt FROM tmp_accnt ORDER BY accnt DESC;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
			
	OPEN c_cursor;
	SET done_cursor = 0;
	FETCH c_cursor INTO var_accnt;
	WHILE done_cursor = 0 DO
		BEGIN	
			CALL up_ihotel_maint_snapshot_ageing(arg_hotel_group_id,arg_hotel_id,arg_biz_date,var_accnt);
			
			DELETE FROM tmp_accnt WHERE accnt=var_accnt;
		
			SET done_cursor = 0;
			FETCH c_cursor INTO var_accnt;
		END;
	END WHILE;	
	CLOSE c_cursor;	
	
	SELECT "Proc Exec Finish!!!";
	
  END$$

DELIMITER ;