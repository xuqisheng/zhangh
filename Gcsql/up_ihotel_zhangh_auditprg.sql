DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_auditprg`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_zhangh_auditprg`()
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- =============================================================================
	-- 用途:往夜审流程表audit_process中添加步骤
	-- 解释:
	-- 作者:张惠
	-- =============================================================================	
	DELETE FROM audit_process WHERE hotel_group_id = -1;
	
	INSERT INTO `audit_process` (`hotel_group_id`,`hotel_id`,`exec_type`,`exec_order`,`descript`,`descript_en`,`exec_service_name`,`exec_method_name`,`exec_script`,`start_time`,`duration`,`duration_pre`,`modu_code`,`is_done`,`is_rebuild`,`is_halt`,`create_user`,`create_datetime`,`modify_user`,`modify_datetime`) 
	VALUES
	('-1','0','D','231','集团统计分析','集团统计分析','proc:up_ihotel_audit_grp_analyse arg_hotel_group_id,arg_hotel_id,\'G\'','1','',NOW(),'0','1','','F','F','F','ADMIN',NOW(),'ADMIN',NOW()),
	('-1','-1','D','231','集团统计分析','集团统计分析','proc:up_ihotel_audit_grp_analyse arg_hotel_group_id,arg_hotel_id,\'H\'','1','',NOW(),'0','1','','F','F','F','ADMIN',NOW(),'ADMIN',NOW()),
	('-1','0','D','235','特殊日期集团统计','特殊日期集团统计','proc:up_ihotel_audit_grp_analyse_spe arg_hotel_group_id,arg_hotel_id,\'G\'','1','',NOW(),'0','1','','F','F','F','ADMIN',NOW(),'ADMIN',NOW()),
	('-1','-1','D','235','特殊日期集团统计','特殊日期集团统计','proc:up_ihotel_audit_grp_analyse_spe arg_hotel_group_id,arg_hotel_id,\'H\'','1','',NOW(),'0','1','','F','F','F','ADMIN',NOW(),'ADMIN',NOW());
		
	
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
	
END$$

DELIMITER ;

CALL up_ihotel_zhangh_auditprg();

DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_auditprg`;