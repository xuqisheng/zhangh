DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_add_sysoption`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_zhangh_add_sysoption`()
    SQL SECURITY INVOKER
label_0:
BEGIN
 
	DELETE FROM sys_option WHERE hotel_group_id = -1 AND hotel_id = -1;
	
	INSERT INTO sys_option (hotel_group_id,hotel_id,catalog,item,set_value,def_value,is_mod,lic_code,descript,descript_en,remark,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime,ctrl_str) VALUES
		('-1','-1','system','allow_ips','121.40.217.226;202.107.192.25;121.52.232.216;202.107.192.24;121.52.232.197;120.27.163.4,','192.168.0.250','T','','白名单列表(表示这些ip可以访问"受保护的地址")','','','F','0','ADMIN',NOW(),'ADMIN',NOW(),'10'),
		('-1','-1','system','protected_urls','/ipms/CRS/.*,','/ipms/CRS/.*','T','','受保护的地址','受保护的地址','','F','0','ADMIN',NOW(),'ADMIN',NOW(),'10');


	INSERT INTO sys_option (hotel_group_id,hotel_id,catalog,item,set_value,def_value,is_mod,lic_code,descript,descript_en,remark,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime,ctrl_str)
		SELECT b.hotel_group_id,b.id,a.catalog,a.item,a.set_value,a.def_value,a.is_mod,a.lic_code,a.descript,a.descript_en,a.remark,a.is_halt,a.list_order,a.create_user,a.create_datetime,a.modify_user,a.modify_datetime,a.ctrl_str
			FROM sys_option a,hotel b WHERE a.hotel_group_id = -1 AND a.hotel_id = -1 AND NOT EXISTS (SELECT 1 FROM sys_option c WHERE c.hotel_group_id = b.hotel_group_id AND c.hotel_id = b.id AND a.catalog=c.catalog AND a.item=c.item);

	INSERT INTO sys_option (hotel_group_id,hotel_id,catalog,item,set_value,def_value,is_mod,lic_code,descript,descript_en,remark,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime,ctrl_str)
		SELECT b.id,0,a.catalog,a.item,a.set_value,a.def_value,a.is_mod,a.lic_code,a.descript,a.descript_en,a.remark,a.is_halt,a.list_order,a.create_user,a.create_datetime,a.modify_user,a.modify_datetime,a.ctrl_str
			FROM sys_option a,hotel_group b WHERE a.hotel_group_id = -1 AND a.hotel_id = -1 
			AND NOT EXISTS (SELECT 1 FROM sys_option c WHERE c.hotel_group_id = b.id AND c.hotel_id = b.id AND a.catalog=c.catalog AND a.item=c.item);
			
	DELETE FROM sys_option WHERE hotel_group_id = -1 AND hotel_id = -1;
	
	UPDATE code_cache SET modify_datetime = NOW() WHERE entity_name = 'com.greencloud.entity.SysOption';

END$$
DELIMITER ;


CALL up_ihotel_zhangh_add_sysoption();

DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_add_sysoption`;