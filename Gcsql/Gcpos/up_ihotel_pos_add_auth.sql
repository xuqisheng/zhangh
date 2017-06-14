DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_pos_add_auth`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_pos_add_auth`()
SQL SECURITY INVOKER

label_0:
BEGIN

	-- user_pos_auth
	DELETE FROM user_pos_auth WHERE hotel_group_id = 1 AND hotel_id = -1;
	INSERT INTO user_pos_auth (hotel_group_id, hotel_id, app_code, CODE, parent_code, descript, descript_en, auth_flag, is_halt, list_order, create_user, create_datetime, modify_user, modify_datetime) VALUES
		 ('1','-1','pos','pos!posMode!SystemLocal','posMode','7003-本地维护','7003-本地维护',NULL,'F','7003','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posMode!System','posMode','7002-系统维护','7002-系统维护',NULL,'F','7002','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posMode!Cashier','posMode','7001-综合收银','7001-综合收银',NULL,'F','7001','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posSystemGroup!master','posSystemGroup','6006-餐单查询','6006-餐单查询',NULL,'F','6006','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posSystemGroup!report','posSystemGroup','6005-集团报表','6005-集团报表',NULL,'F','6005','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posSystemGroup!sysopt','posSystemGroup','6004-参数设置','6004-参数设置',NULL,'F','6004','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posSystemGroup!condst','posSystemGroup','6003-做法设置','6003-做法设置',NULL,'F','6003','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posSystemGroup!pluE','posSystemGroup','6002-菜谱编辑','6002-菜谱编辑',NULL,'F','6002','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posSystemGroup!code','posSystemGroup','6001-基本代码设置','6001-基本代码设置',NULL,'F','6001','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posSystem!editAuth','posSystem','5007-权限设置','5007-权限设置',NULL,'F','5007','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posSystem!master','posSystem','5006-餐单查询','5006-餐单查询',NULL,'F','5006','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posSystem!report','posSystem','5005-酒店报表','5005-酒店报表',NULL,'F','5005','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posSystem!mode','posSystem','5004-模式设置','5004-模式设置',NULL,'F','5004','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posSystem!pccode','posSystem','5003-营业点设置','5003-营业点设置',NULL,'F','5003','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posSystem!pluE','posSystem','5002-菜谱设置','5002-菜谱设置',NULL,'F','5002','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posSystem!code','posSystem','5001-代码设置','5001-代码设置',NULL,'F','5001','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posSystemLocal!interf','posSystemLocal','4002-接口设置','4002-接口设置',NULL,'F','4002','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posSystemLocal!print','posSystemLocal','4001-厨打设置','4001-厨打设置',NULL,'F','4001','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!getData','posCashier','3024-数据更新','3024-数据更新',NULL,'F','3024','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!station','posCashier','3023-站点管理','3023-站点管理',NULL,'F','3023','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!checkReOth','posCashier','3022-撤销他人结账','3022-撤销他人结账',NULL,'F','3022','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!SstaChange','posCashier','3021-S状态下修改','3021-S状态下修改',NULL,'F','3021','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!accessDel','posCashier','3020-沽清取消','3020-沽清取消',NULL,'F','3020','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!access','posCashier','3019-沽清设置','3019-沽清设置',NULL,'F','3019','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!audit','posCashier','3018-夜间稽核','3018-夜间稽核',NULL,'F','3018','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!syncUp','posCashier','3017-云同步','3017-云同步',NULL,'F','3017','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!checkReC','posCashier','3016-重登','3016-重登',NULL,'F','3016','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!checkS','posCashier','3015-挂S账','3015-挂S账',NULL,'F','3015','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!checkRe','posCashier','3014-撤销结账','3014-撤销结账',NULL,'F','3014','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!report','posCashier','3013-交班报表','3013-交班报表',NULL,'F','3013','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!resOpen','posCashier','3012-预订转登记','3012-预订转登记',NULL,'F','3012','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!res','posCashier','3011-预订详情','3011-预订详情',NULL,'F','3011','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!checkOut','posCashier','3010-结账','3010-结账',NULL,'F','3010','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!bill','posCashier','3009-账单打印','3009-账单打印',NULL,'F','3009','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!YJbill','posCashier','3008-预结单打印','3008-预结单打印',NULL,'F','3008','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!pluEnt','posCashier','3007-单菜赠送','3007-单菜赠送',NULL,'F','3007','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!pluDsc','posCashier','3006-单菜折扣','3006-单菜折扣',NULL,'F','3006','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!revoke','posCashier','3005-消单','3005-消单',NULL,'F','3005','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!merger','posCashier','3004-并桌','3004-并桌',NULL,'F','3004','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!change','posCashier','3003-换桌','3003-换桌',NULL,'F','3003','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!link','posCashier','3002-联单','3002-联单',NULL,'F','3002','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posCashier!masterEdit','posCashier','3001-主单信息修改','3001-主单信息修改',NULL,'F','3001','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posOrder!writeOff','posOrder','2005-冲销菜品','2005-冲销菜品',NULL,'F','2005','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posOrder!orderOffline','posOrder','2004-离线点菜','2004-离线点菜',NULL,'F','2004','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posOrder!delete','posOrder','2003-退菜','2003-退菜',NULL,'F','2003','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posOrder!order','posOrder','2002-点菜下单','2002-点菜下单',NULL,'F','2002','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posOrder!create','posOrder','2001-新开单','2001-新开单',NULL,'F','2001','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posRes!resPayList','posRes','1008-定金列表','1008-定金列表',NULL,'F','1008','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posRes!resRe','posRes','1007-预订恢复','1007-预订恢复',NULL,'F','1007','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posRes!resDel','posRes','1006-预订取消','1006-预订取消',NULL,'F','1006','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posRes!resPay','posRes','1005-预定金','1005-预定金',NULL,'F','1005','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posRes!resPlu','posRes','1004-预订菜式','1004-预订菜式',NULL,'F','1004','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posRes!resEdit','posRes','1003-预订主单修改','1003-预订主单修改',NULL,'F','1003','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posRes!res','posRes','1002-新建预订','1002-新建预订',NULL,'F','1002','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','pos!posRes!resList','posRes','1001-预订列表查询','1001-预订列表查询',NULL,'F','1001','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','posMode','0','70-模块设置','70-模块设置',NULL,'F','0','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','posSystemGroup','0','60-集团系统设置','60-集团系统设置',NULL,'F','0','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','posSystem','0','50-系统设置','50-系统设置',NULL,'F','0','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','posSystemLocal','0','40-本地设置','40-本地设置',NULL,'F','0','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','posCashier','0','30-收银设置','30-收银设置',NULL,'F','0','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','posOrder','0','20-点菜设置','20-点菜设置',NULL,'F','0','ADMIN',NOW(),'ADMIN',NOW()),
		 ('1','-1','pos','posRes','0','10-预订设置','10-预订设置',NULL,'F','0','ADMIN',NOW(),'ADMIN',NOW());

	INSERT INTO user_pos_auth (hotel_group_id, hotel_id, app_code, CODE, parent_code, descript, descript_en, auth_flag, is_halt, list_order, create_user, create_datetime, modify_user, modify_datetime)
			SELECT b.hotel_group_id, b.id, a.app_code, a.code, a.parent_code, a.descript, a.descript_en, a.auth_flag, a.is_halt, a.list_order, a.create_user, a.create_datetime, a.modify_user, a.modify_datetime
			FROM user_pos_auth a, hotel b WHERE a.hotel_group_id = 1 AND a.hotel_id = -1
			AND NOT EXISTS (SELECT 1 FROM user_pos_auth c WHERE c.hotel_group_id = b.hotel_group_id AND c.hotel_id = b.id AND c.CODE = a.CODE AND c.parent_code = a.parent_code);

	DELETE FROM user_pos_auth WHERE hotel_group_id = 1 AND hotel_id = -1;


	DELETE FROM user_pos_auth_user_auth WHERE hotel_group_id = 1 AND hotel_id = -1;
	INSERT INTO user_pos_auth_user_auth (hotel_group_id, hotel_id, user_code, role_code, auth_hotel_group_id, auth_hotel_id, auth_code, create_user, create_datetime, modify_user, modify_datetime) VALUES
		('1','-1','ADMIN',NULL,'182','10214','*','ADMIN','2016-06-29 16:01:49','ADMIN','2016-06-29 16:01:49');

	INSERT INTO user_pos_auth_user_auth (hotel_group_id, hotel_id, user_code, role_code, auth_hotel_group_id, auth_hotel_id, auth_code, create_user, create_datetime, modify_user, modify_datetime)
		SELECT b.hotel_group_id, b.id, a.user_code, a.role_code, b.hotel_group_id, b.id, a.auth_code, a.create_user, a.create_datetime, a.modify_user, a.modify_datetime
		FROM user_pos_auth_user_auth a, hotel b WHERE a.hotel_group_id = 1 AND a.hotel_id = -1 AND a.user_code = 'ADMIN'
		AND NOT EXISTS (SELECT 1 FROM user_pos_auth_user_auth c WHERE c.hotel_group_id = b.hotel_group_id AND c.hotel_id = b.id AND c.user_code = a.user_code AND c.user_code = 'ADMIN');
	DELETE FROM user_pos_auth_user_auth WHERE hotel_group_id = 1 AND hotel_id = -1;

END$$
DELIMITER ;

CALL up_ihotel_user_auth_temp();

DROP PROCEDURE IF EXISTS `up_ihotel_user_auth_temp`;