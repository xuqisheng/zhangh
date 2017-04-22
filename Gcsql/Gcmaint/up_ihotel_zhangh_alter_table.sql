DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_alter_table`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_zhangh_alter_table`()

	SQL SECURITY INVOKER

label_0:
BEGIN
	-- =========================================================
	-- 实体表添加或修改
	-- 作者：zhangh
	-- =========================================================
	DECLARE done_cursor INT DEFAULT 0;
	
	DROP TABLE IF EXISTS rep_diff_price;
	DROP TABLE IF EXISTS rep_diff_price_history;
	DROP TABLE IF EXISTS rep_diffchange_price;
	DROP TABLE IF EXISTS rep_diffchange_price_history;	
	
	DELETE FROM audit_process WHERE exec_service_name LIKE '%up_ihotel_rep_diff_price%';
	DELETE FROM audit_process WHERE exec_service_name LIKE '%up_ihotel_rep_diff_change_price%';

	IF NOT EXISTS(SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='rep_rmrate_diff') THEN	
		CREATE TABLE rep_rmrate_diff(
		  hotel_group_id 	BIGINT(16) NOT NULL,
		  hotel_id 			BIGINT(16) NOT NULL,
		  id 				BIGINT(16) NOT NULL AUTO_INCREMENT,
		  diff_type 		VARCHAR(10) NOT NULL COMMENT 'HSE=自用房 COM=免费房 DIFF=房价差异房',
		  biz_date 			DATETIME NOT NULL,		  
		  accnt 			BIGINT(16) NOT NULL,
		  master_id 		BIGINT(16) NOT NULL,
		  grp_accnt		 	BIGINT(16) NOT NULL DEFAULT '0',
		  name				VARCHAR(60) NOT NULL DEFAULT '',
		  id_no				VARCHAR(20) NOT NULL DEFAULT '',
		  sta 				CHAR(1) NOT NULL DEFAULT '',
		  sex				CHAR(2) NOT NULL DEFAULT '',
		  vip				VARCHAR(10) NOT NULL DEFAULT '',
		  phone				VARCHAR(20) NOT NULL DEFAULT '',
		  mobile			VARCHAR(20) NOT NULL DEFAULT '',
		  rmtype 			VARCHAR(10) NOT NULL,
		  rmno 				VARCHAR(10) NOT NULL,
		  arr 				DATETIME NOT NULL,
		  dep 				DATETIME NOT NULL,
		  rack_rate			DECIMAL(8,2) NOT NULL DEFAULT '0.00',
		  nego_rate 		DECIMAL(8,2) NOT NULL DEFAULT '0.00',
		  real_rate 		DECIMAL(8,2) NOT NULL DEFAULT '0.00',
		  dsc_reason 		VARCHAR(10) NOT NULL DEFAULT '',
		  guest_id 			BIGINT(16) NOT NULL,
		  company_id 		BIGINT(16) NOT NULL,
		  agent_id 			BIGINT(16) NOT NULL,
		  source_id 		BIGINT(16) NOT NULL,
		  member_type 		VARCHAR(10) NOT NULL DEFAULT '',
		  member_no 		VARCHAR(20) NOT NULL DEFAULT '',
		  card_id	 		BIGINT(16) NULL,
		  salesman 			VARCHAR(10) NOT NULL DEFAULT '',
		  link_id			BIGINT(16) NULL,
		  ratecode 			VARCHAR(20) NOT NULL DEFAULT '',
		  market 			VARCHAR(10) NOT NULL DEFAULT '',
		  src 				VARCHAR(10) NOT NULL DEFAULT '',		  
		  packages 			VARCHAR(20) NOT NULL DEFAULT '',
		  rsv_no 			VARCHAR(20) NOT NULL DEFAULT '',
		  remark 			VARCHAR(512) NOT NULL DEFAULT '',
		  PRIMARY KEY (id),
		  KEY index1 (hotel_group_id,hotel_id,biz_date,diff_type),
		  KEY index2 (hotel_group_id,hotel_id,biz_date,accnt),
		  KEY index3 (hotel_group_id,hotel_id,guest_id),
		  KEY index4 (hotel_group_id,hotel_id,company_id),
		  KEY index5 (hotel_group_id,hotel_id,agent_id),
		  KEY index6 (hotel_group_id,hotel_id,source_id),
		  KEY index7 (hotel_group_id,hotel_id,card_id),
		  KEY index8 (hotel_group_id,hotel_id,salesman)
		)ENGINE=INNODB DEFAULT CHARSET=utf8;	
	END IF;
	
	
	
	
END$$

DELIMITER ;

CALL up_ihotel_zhangh_alter_table();
DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_alter_table`;