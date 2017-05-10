-- 出错账号表
CREATE TABLE master_snapshot_accnt (
	hotel_group_id 		INT,
	hotel_id 			INT,
	master_type 		VARCHAR(20) DEFAULT NULL,
	master_id 			INT(11) DEFAULT NULL,
	KEY index1 (master_id)
) ENGINE=INNODB DEFAULT CHARSET=utf8;

-- 对照截取表
CREATE TABLE master_snapshot_tmp (
	hotel_group_id 		BIGINT(16) NOT NULL,
	hotel_id 			BIGINT(16) NOT NULL,
	id 					BIGINT(16) NOT NULL AUTO_INCREMENT,
	biz_date 			DATETIME DEFAULT NULL,
	master_type 		VARCHAR(20) NOT NULL,
	master_id 			BIGINT(16) NOT NULL,
	NAME 				VARCHAR(60) NOT NULL,
	last_balance 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	charge_ttl 			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	pay_ttl 			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	till_balance 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	PRIMARY KEY (id),
	KEY index1 (hotel_group_id,hotel_id,biz_date,master_id,master_type)
) ENGINE=INNODB DEFAULT CHARSET=utf8;


-- 前台账务表
CREATE TABLE master_snapshot_account (
	hotel_group_id 		INT(11) DEFAULT NULL,
	hotel_id 			INT(11) DEFAULT NULL,
	biz_date 			DATETIME DEFAULT NULL,
	accnt 				INT(11) DEFAULT NULL,
	charge 				DECIMAL(12,2) DEFAULT NULL,
	pay 				DECIMAL(12,2) DEFAULT NULL,
	balance 			DECIMAL(12,2) DEFAULT NULL,
	KEY index1 (hotel_group_id,hotel_id,accnt)
) ENGINE=INNODB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS master_snapshot_accnt;
DROP TABLE IF EXISTS master_snapshot_tmp;
DROP TABLE IF EXISTS master_snapshot_account;