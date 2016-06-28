DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_grp_analyse`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_zhangh_grp_analyse`()
    SQL SECURITY INVOKER
label_0:
BEGIN

	DELETE FROM audit_process WHERE hotel_group_id = -1;
	
	INSERT INTO `audit_process` (`hotel_group_id`,`hotel_id`,`exec_type`,`exec_order`,`descript`,`descript_en`,`exec_service_name`,`exec_method_name`,`exec_script`,`start_time`,`duration`,`duration_pre`,`modu_code`,`is_done`,`is_rebuild`,`is_halt`,`create_user`,`create_datetime`,`modify_user`,`modify_datetime`) 
	VALUES
	('-1','-1','D','300','中央数据上传','中央数据上传','auditReportSubFacadeService','updateSendDataToGrp','',NOW(),'0','1','','F','F','F','ADMIN',NOW(),'ADMIN',NOW());

	
	INSERT INTO `audit_process` (`hotel_group_id`,`hotel_id`,`exec_type`,`exec_order`,`descript`,`descript_en`,`exec_service_name`,`exec_method_name`,`exec_script`,`start_time`,`duration`,`duration_pre`,`modu_code`,`is_done`,`is_rebuild`,`is_halt`,`create_user`,`create_datetime`,`modify_user`,`modify_datetime`)
	SELECT
		b.hotel_group_id,b.id,a.exec_type,a.exec_order,a.descript,a.descript_en,a.exec_service_name,a.exec_method_name,a.exec_script,a.start_time,a.duration,a.duration_pre,a.modu_code,a.is_done,a.is_rebuild,a.is_halt,a.create_user,a.create_datetime,a.modify_user,a.modify_datetime
	FROM audit_process a,hotel b WHERE a.hotel_group_id = -1 AND a.hotel_id = -1 AND b.sta='I' 
		AND NOT EXISTS(SELECT 1 FROM audit_process c WHERE c.hotel_group_id = b.hotel_group_id AND c.hotel_id = b.id AND a.exec_type=c.exec_type AND a.exec_order=c.exec_order AND a.descript=c.descript);
	
	
	INSERT INTO `audit_process` (`hotel_group_id`,`hotel_id`,`exec_type`,`exec_order`,`descript`,`descript_en`,`exec_service_name`,`exec_method_name`,`exec_script`,`start_time`,`duration`,`duration_pre`,`modu_code`,`is_done`,`is_rebuild`,`is_halt`,`create_user`,`create_datetime`,`modify_user`,`modify_datetime`)
	SELECT
		b.id,a.hotel_id,a.exec_type,a.exec_order,a.descript,a.descript_en,a.exec_service_name,a.exec_method_name,a.exec_script,a.start_time,a.duration,a.duration_pre,a.modu_code,a.is_done,a.is_rebuild,a.is_halt,a.create_user,a.create_datetime,a.modify_user,a.modify_datetime
	FROM audit_process a,hotel_group b WHERE a.hotel_group_id = -1 AND a.hotel_id = 0 AND b.sta='I' 
		AND NOT EXISTS(SELECT 1 FROM audit_process c WHERE c.hotel_group_id = b.id AND c.hotel_id=0 AND a.exec_type=c.exec_type AND a.exec_order=c.exec_order AND a.descript=c.descript);
	
	DELETE FROM audit_process WHERE hotel_group_id = -1;

  ALTER TABLE grp_sales_detail CHANGE class classstr VARCHAR(20);
  ALTER TABLE grp_sales_special CHANGE class classstr VARCHAR(20);
	
END$$

DELIMITER ;

CALL up_ihotel_zhangh_grp_analyse();

DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_grp_analyse`;
