DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_alter_index`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_zhangh_alter_index`()

	SQL SECURITY INVOKER

label_0:
BEGIN
	-- =========================================================
	--  实体表索引的添加或修改
	-- 
	-- 作者：张惠
	-- =========================================================
	DECLARE done_cursor INT DEFAULT 0;
	DECLARE var_indexs VARCHAR(30);
	DECLARE var_sql VARCHAR(200) ;	

	DECLARE c_cursor CURSOR FOR SELECT index_name FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() 
		AND TABLE_NAME = 'production_detail' AND index_name <> 'PRIMARY' GROUP BY index_name;
		
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
		
	OPEN c_cursor;
	SET done_cursor = 0;	
	FETCH c_cursor INTO var_indexs;
	WHILE done_cursor = 0 DO
			IF (var_indexs <> 'index_p1' AND var_indexs <> 'index_p2' AND var_indexs <> 'index_p3' AND var_indexs <> 'index_p4' AND var_indexs <> 'index_p5' AND var_indexs <> 'index_p6' AND var_indexs <> 'index_p7' AND var_indexs <> 'index_p8' AND var_indexs <> 'index_p9') THEN

				SET var_sql = CONCAT('DROP INDEX ', var_indexs, ' ON production_detail;');
				
				SET @exec_sql = var_sql;  
				PREPARE stmt FROM @exec_sql;
				EXECUTE stmt;			
			END IF;
		SET done_cursor = 0;
		FETCH c_cursor INTO var_indexs;
	END WHILE;
	CLOSE c_cursor;		

	IF NOT EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME = 'production_detail' AND index_name='index_p1') THEN
		 ALTER TABLE production_detail ADD INDEX index_p1 (hotel_group_id,hotel_id,biz_date,accnt);
	END IF;	
	IF NOT EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME = 'production_detail' AND index_name='index_p2') THEN
		 ALTER TABLE production_detail ADD INDEX index_p2 (hotel_group_id,hotel_id,master_type);
	END IF;
	IF NOT EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME = 'production_detail' AND index_name='index_p3') THEN
		 ALTER TABLE production_detail ADD INDEX index_p3 (hotel_group_id,hotel_id,guest_id);
	END IF;
	IF NOT EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME = 'production_detail' AND index_name='index_p4') THEN
		 ALTER TABLE production_detail ADD INDEX index_p4 (hotel_group_id,hotel_id,group_id);
	END IF;
	IF NOT EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME = 'production_detail' AND index_name='index_p5') THEN
		 ALTER TABLE production_detail ADD INDEX index_p5 (hotel_group_id,hotel_id,company_id);
	END IF;
	IF NOT EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME = 'production_detail' AND index_name='index_p6') THEN
		 ALTER TABLE production_detail ADD INDEX index_p6 (hotel_group_id,hotel_id,agent_id);
	END IF;
	IF NOT EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME = 'production_detail' AND index_name='index_p7') THEN
		 ALTER TABLE production_detail ADD INDEX index_p7 (hotel_group_id,hotel_id,source_id);
	END IF;
	IF NOT EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME = 'production_detail' AND index_name='index_p8') THEN
		 ALTER TABLE production_detail ADD INDEX index_p8 (hotel_group_id,hotel_id,salesman);
	END IF;
	IF NOT EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME = 'production_detail' AND index_name='index_p9') THEN
		 ALTER TABLE production_detail ADD INDEX index_p9 (hotel_group_id,hotel_id,card_id);
	END IF;	
	IF NOT EXISTS(SELECT 1 FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME = 'production_detail' AND index_name='index_p10') THEN
		 ALTER TABLE production_detail ADD INDEX index_p10 (hotel_group_id,hotel_id,accnt);
	END IF;

END$$

DELIMITER ;

CALL up_ihotel_zhangh_alter_index();
DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_alter_index`;