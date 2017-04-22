
-- 第一步：增加表  在portal_member库执行
CREATE TABLE `card_idcard_map` (
  `id` bigint(16) NOT NULL AUTO_INCREMENT,
  `card_id` bigint(16) NOT NULL,
  `card_no` varchar(20) DEFAULT NULL COMMENT 'id卡卡内记录的卡号',
  `card_no2` varchar(20) DEFAULT NULL COMMENT 'id卡外部卡号',
  `create_user` varchar(20) DEFAULT NULL COMMENT '创建人',
  `create_datetime` datetime DEFAULT NULL COMMENT '创建时间',
  `modify_user` varchar(20) DEFAULT NULL COMMENT '修改人',
  `modify_datetime` datetime DEFAULT NULL COMMENT '修改时间',
  PRIMARY KEY (`id`,`card_id`),
  UNIQUE KEY `index_card_id` (`card_id`),
  UNIQUE KEY `index_card_no` (`card_no`),
  UNIQUE KEY `index_card_no2` (`card_no2`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- 第二步：增加参数  在portal_group库执行；

DELIMITER $$
SET sql_notes = 0$$
DROP PROCEDURE IF EXISTS portal_group.`up_ihotel_sysoption_temp`$$
CREATE DEFINER=`root`@`%` PROCEDURE portal_group.`up_ihotel_sysoption_temp`()
SQL SECURITY INVOKER # added by mode utility
label_0:
BEGIN


	INSERT INTO sys_option (hotel_group_id, hotel_id, catalog, item, set_value, def_value, is_mod, lic_code, descript, descript_en, remark, is_halt, list_order, create_user, create_datetime, modify_user, modify_datetime, ctrl_str) VALUES
	('1','-1','member','idcard_model','T','','T','','会员ID卡模式','会员ID卡模式','会员ID卡模式','F','219','ADMIN',NOW(),'ADMIN',NOW(),'10');
	
	
	-- 插入不存在的	sys_option
	INSERT INTO sys_option (hotel_group_id, hotel_id, catalog, item, set_value, def_value, is_mod, lic_code, descript, descript_en, remark, is_halt, 
			list_order, create_user, create_datetime, modify_user, modify_datetime, ctrl_str)
			SELECT b.hotel_group_id, b.id, a.catalog, a.item, a.set_value, a.def_value, a.is_mod, a.lic_code, a.descript, a.descript_en, a.remark, a.is_halt,
			a.list_order, a.create_user, a.create_datetime, a.modify_user, a.modify_datetime, a.ctrl_str
			FROM sys_option a, hotel b WHERE a.hotel_group_id = 1 AND a.hotel_id = -1 AND b.sta IN ('H','I')
			AND NOT EXISTS (SELECT 1 FROM sys_option c WHERE c.hotel_group_id = b.hotel_group_id AND c.hotel_id = b.id AND c.catalog = a.catalog AND c.item = a.item);
		
	INSERT INTO sys_option (hotel_group_id, hotel_id, catalog, item, set_value, def_value, is_mod, lic_code, descript, descript_en, remark, is_halt, 
			list_order, create_user, create_datetime, modify_user, modify_datetime, ctrl_str)
			SELECT b.id, 0, a.catalog, a.item, a.set_value, a.def_value, a.is_mod, a.lic_code, a.descript, a.descript_en, a.remark, a.is_halt,
			a.list_order, a.create_user, a.create_datetime, a.modify_user, a.modify_datetime, a.ctrl_str
			FROM sys_option a, hotel_group b WHERE a.hotel_group_id = 1 AND a.hotel_id = -1 AND b.sta IN ('H','I')
			AND NOT EXISTS (SELECT 1 FROM sys_option c WHERE c.hotel_group_id = b.id AND c.hotel_id = 0 AND c.catalog = a.catalog AND c.item = a.item);

	-- 更新同步机制的修改时间	sys_option
	UPDATE code_cache SET modify_datetime = NOW() WHERE entity_name = 'com.greencloud.entity.SysOption';

	-- ---------------------
	-- 删除处理数据 
	-- ---------------------
	DELETE FROM sys_option WHERE hotel_group_id=1 AND hotel_id<0; 

END$$
DELIMITER ;

SELECT IFNULL(MAX(id),0) INTO @a FROM sys_option;
CALL up_ihotel_sysoption_temp();
SELECT IFNULL(MAX(id),0) INTO @b FROM sys_option;

INSERT INTO sync_data(hotel_group_id,hotel_id,flag,entity_name,entity_id,sync_type)
SELECT hotel_group_id,hotel_id,DATE_FORMAT( NOW(),'%Y%m%d%H%i%s000'),'SysOption',id,'ADD'
FROM sys_option WHERE id > @a AND id<= @b;
DROP PROCEDURE IF EXISTS `up_ihotel_sysoption_temp`;









-- 第三步： 修改卡查询列表

SELECT * FROM sys_list_meta WHERE hotel_group_id = ? AND hotel_id = ? AND CODE = 'listMemberCardQuery';

-- 将该sys_list_meta记录的sql_define字段用以下sql替换，若是标准版程序就用 【标准版卡查询个性化sql】替换；若是商务版就用 【商务版卡查询个性化sql】 替换；



-- 标准版卡查询个性化sql

SELECT a.id,c.id memberId, a.sta,a.card_type,a.card_master,a.card_level,a.card_no,c.name,c.sex,c.id_no,b.email,b.mobile,a.date_end,IF(t.is_point='F',NULL, a.point_pay - a.point_charge) point_balance,
IF(t.is_account='F',NULL,a.pay - a.charge + a.credit - a.freeze) balance,IF(t.is_account='F',NULL,a.freeze) freeze,a.iss_hotel,LEFT(c.remark,512) AS remark 
FROM #TARGET_TABLE# a,member_link_base b,member_base c ,card_type t 
WHERE c.hotel_group_id = #HOTEL_GROUP_ID# and (1=1) and a.hotel_group_id = b.hotel_group_id and a.hotel_group_id = c.hotel_group_id 
AND a.member_id = b.id AND a.member_id = c.id AND a.hotel_group_id = t.hotel_group_id AND a.card_type = t.code AND a.hotel_group_id = #HOTEL_GROUP_ID# AND UF_CARD_TYPE_ROLE(#HOTEL_GROUP_ID#,#HOTEL_ID#,#USER_CODE#,t.code,t.is_group_card,t.scope) 
UNION
SELECT cb.id,c.id memberId, cb.sta,cb.card_type,cb.card_master,cb.card_level,cb.card_no,c.name,c.sex,c.id_no,b.email,b.mobile,cb.date_end,IF(t.is_point='F',NULL, cb.point_pay - cb.point_charge) point_balance,
IF(t.is_account='F',NULL,cb.pay - cb.charge + cb.credit - cb.freeze) balance,IF(t.is_account='F',NULL,cb.freeze) freeze,cb.iss_hotel,LEFT(c.remark,512) AS remark 
FROM card_base cb,member_link_base b,member_base c ,card_type t, card_idcard_map a
WHERE c.hotel_group_id = #HOTEL_GROUP_ID# and (2=2) and cb.hotel_group_id = b.hotel_group_id and cb.hotel_group_id = c.hotel_group_id 
AND cb.member_id = b.id AND cb.member_id = c.id AND cb.hotel_group_id = t.hotel_group_id AND cb.card_type = t.code AND cb.hotel_group_id = #HOTEL_GROUP_ID# AND UF_CARD_TYPE_ROLE(#HOTEL_GROUP_ID#,#HOTEL_ID#,#USER_CODE#,t.code,t.is_group_card,t.scope) 
AND a.card_id = cb.id
ORDER BY id




-- 商务版卡查询个性化sql
SELECT IF((a.sta='O' OR a.sta='L' OR a.sta='X'),'T','F') c_0xFFCCCC,a.id,c.id memberId,c.is_anonymous isAnonymous,t.is_physical isPhysical,t.is_mustread ismustread,
t.is_account isAccount,t.is_point isPoint, a.sta,a.card_type,a.card_master,a.card_level,a.card_no,a.inner_card_no,c.name,c.sex,c.id_no,b.email,b.mobile,
a.date_begin,a.date_end,IF(t.is_point='F',NULL, a.point_pay) point_pay,IF(t.is_point='F',NULL, a.point_charge) point_charge,IF(t.is_point='F',NULL, a.point_pay - a.point_charge) point_balance,
IF(t.is_account='F',NULL,a.charge) charge,IF(t.is_account='F',NULL,a.pay) pay,IF(t.is_account='F',NULL,a.pay - a.charge + a.credit - a.freeze) balance,
IF(t.is_account='F',NULL,a.freeze) freeze,a.iss_hotel,LEFT(c.remark,512) AS remark ,t.descript card_type_descript,l.descript card_level_descript
 FROM #TARGET_TABLE# a,member_link_base b,member_base c ,card_type t ,card_level l WHERE a.hotel_group_id = #HOTEL_GROUP_ID#  
 AND (1=1) AND UF_CARD_TYPE_ROLE_F(#HOTEL_GROUP_ID#,#HOTEL_ID#,t.code,t.is_group_card,t.scope) 
 AND a.hotel_group_id = b.hotel_group_id AND a.hotel_group_id = c.hotel_group_id 
 AND a.member_id = b.id AND a.member_id = c.id AND a.card_type = t.code AND t.hotel_group_id = a.hotel_group_id 
 AND a.hotel_group_id = l.hotel_group_id AND a.card_level = l.code 
UNION
SELECT IF((cb.sta='O' OR cb.sta='L' OR cb.sta='X'),'T','F') c_0xFFCCCC,cb.id,c.id memberId,c.is_anonymous isAnonymous,t.is_physical isPhysical,t.is_mustread ismustread,
t.is_account isAccount,t.is_point isPoint, cb.sta,cb.card_type,cb.card_master,cb.card_level,cb.card_no,cb.inner_card_no,c.name,c.sex,c.id_no,b.email,b.mobile,
cb.date_begin,cb.date_end,IF(t.is_point='F',NULL, cb.point_pay) point_pay,IF(t.is_point='F',NULL, cb.point_charge) point_charge,IF(t.is_point='F',NULL, cb.point_pay - cb.point_charge) point_balance,
IF(t.is_account='F',NULL,cb.charge) charge,IF(t.is_account='F',NULL,cb.pay) pay,IF(t.is_account='F',NULL,cb.pay - cb.charge + cb.credit - cb.freeze) balance,
IF(t.is_account='F',NULL,cb.freeze) freeze,cb.iss_hotel,LEFT(c.remark,512) AS remark ,t.descript card_type_descript,l.descript card_level_descript
FROM card_base cb,member_link_base b,member_base c ,card_type t,card_level l, card_idcard_map a
WHERE c.hotel_group_id = #HOTEL_GROUP_ID# and (2=2) and cb.hotel_group_id = b.hotel_group_id and cb.hotel_group_id = c.hotel_group_id 
AND cb.member_id = b.id AND cb.member_id = c.id AND cb.hotel_group_id = t.hotel_group_id AND cb.card_type = t.code
AND  cb.hotel_group_id = l.hotel_group_id AND cb.card_level = l.code AND cb.hotel_group_id = #HOTEL_GROUP_ID# AND UF_CARD_TYPE_ROLE(#HOTEL_GROUP_ID#,#HOTEL_ID#,#USER_CODE#,t.code,t.is_group_card,t.scope) 
AND a.card_id = cb.id 
 
 ORDER BY FIELD(sta,'I','Y','R','L','O','X'),id 
 
 
 
 -- 第四步： 餐饮查卡所需配置

 设置好以下两个参数 餐饮即可支持查询id内部卡号
 
参数：【idcard_model】 是否开启id卡内部卡号查询
参数：【pos_vip_search_area】 第7位表示 id内部卡号的查询配置
 
 
 
 
 
 
 
 
 
 
 
 
 
 