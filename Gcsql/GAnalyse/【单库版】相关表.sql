/*
SELECT * FROM portal.grp_manage_detail WHERE hotel_group_id=1 AND hotel_id=137;
SELECT * FROM portal.grp_sales_detail WHERE hotel_group_id=1 AND hotel_id=137;
SELECT * FROM portal.grp_company_detail WHERE hotel_group_id=1 AND hotel_id=137;
SELECT * FROM portal.grp_company_perfor_detail WHERE hotel_group_id=1 AND hotel_id=137;
SELECT * FROM portal.grp_company_perfor_year WHERE hotel_group_id=1 AND hotel_id=137;
*/

CREATE TABLE `grp_manage_detail` (
  `hotel_group_id` 	int NOT NULL,
  `hotel_id` 		int NOT NULL,
  `id` 				bigint(16) NOT NULL AUTO_INCREMENT,
  `biz_date` 		datetime DEFAULT NULL,
  `income_rm` 		decimal(12,2) DEFAULT '0.00',
  `income_pos` 		decimal(12,2) DEFAULT '0.00',
  `income_ot` 		decimal(12,2) DEFAULT '0.00',
  `income_ttl` 		decimal(12,2) DEFAULT '0.00',
  `rental_rates` 	decimal(12,2) DEFAULT '0.00',
  `room_avg` 		decimal(12,2) DEFAULT '0.00',
  `rev_par` 		decimal(12,2) DEFAULT '0.00',
  `room_avl` 		decimal(12,2) DEFAULT '0.00',
  `room_sold` 		decimal(12,2) DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `Index_1` (`hotel_group_id`,`hotel_id`,`biz_date`),
  KEY `Index_2` (`hotel_group_id`,`biz_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `grp_sales_detail` (
  `hotel_group_id` 	int NOT NULL,
  `hotel_id` 		int NOT NULL,
  `id` 				bigint(16) NOT NULL AUTO_INCREMENT,
  `biz_date` 		datetime DEFAULT NULL,
  `type` 			varchar(20) DEFAULT '' COMMENT '市场、来源、渠道',
  `class`			varchar(20) DEFAULT '',
  `classdesc` 		varchar(50) DEFAULT '',
  `section` 		varchar(20) DEFAULT '',
  `sectiondesc` 	varchar(50) DEFAULT '',
  `income` 			decimal(12,2) DEFAULT '0.00',
  `nights` 			decimal(12,2) DEFAULT '0.00',
  `persons` 		decimal(12,2) DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `Index_1` (`hotel_group_id`,`hotel_id`,`biz_date`,`type`),
  KEY `Index_2` (`hotel_group_id`,`hotel_id`,`biz_date`,`type`,`class`),
  KEY `Index_3` (`hotel_group_id`,`biz_date`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='分析维度： 市场码、来源码、渠道码、预定类型';


CREATE TABLE `grp_suspend_detail` (
  `hotel_group_id` 	int NOT NULL,
  `hotel_id` 		int NOT NULL,
  `id` 				bigint(16) NOT NULL AUTO_INCREMENT,
  `biz_date` 		datetime DEFAULT NULL,
  `ar_amount` 		decimal(12,2) DEFAULT '0.00',
  `s_amount` 		decimal(12,2) DEFAULT '0.00',
  `t_amount` 		decimal(12,2) DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `Index_1` (`hotel_group_id`,`hotel_id`,`biz_date`),
  KEY `Index_2` (`hotel_group_id`,`biz_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `grp_company_detail` (
  `hotel_group_id` 	int NOT NULL,
  `hotel_id` 		int NOT NULL,
  `id` 				bigint(16) NOT NULL AUTO_INCREMENT,
  `biz_date` 		datetime DEFAULT NULL,
  `sales_man` 		varchar(20) DEFAULT '',
  `sys_class` 		varchar(20) DEFAULT '',
  `class_descr` 	varchar(60) DEFAULT '',
  `number_add` 		bigint(16) DEFAULT '0',
  `number_all` 		bigint(16) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `Index_1` (`hotel_group_id`,`hotel_id`,`biz_date`,`sys_class`),
  KEY `Index_2` (`hotel_group_id`,`hotel_id`,`biz_date`,`sales_man`),
  KEY `Index_3` (`hotel_group_id`,`hotel_id`,`biz_date`,`sales_man`,`sys_class`),
  KEY `Index_4` (`hotel_group_id`,`biz_date`,`sales_man`,`sys_class`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `grp_company_perfor_detail` (
  `hotel_group_id` 	int NOT NULL,
  `hotel_id` 		int NOT NULL,
  `id` 				bigint(16) NOT NULL AUTO_INCREMENT,
  `biz_date` 		datetime DEFAULT NULL,
  `company_id` 		bigint(16) DEFAULT NULL,
  `company_class` 	varchar(20) DEFAULT '',
  `company_name` 	varchar(200) DEFAULT '',
  `nights` 			decimal(12,2) DEFAULT NULL,
  `persons` 		int(11) DEFAULT NULL,
  `room_avg` 		decimal(12,2) DEFAULT '0.00',
  `room_charge` 	decimal(12,2) DEFAULT '0.00',
  `pos_charge` 		decimal(12,2) DEFAULT '0.00',
  `ot_charge` 		decimal(12,2) DEFAULT '0.00',
  `ttl_charge` 		decimal(12,2) DEFAULT '0.00',
  `avg_charge` 		decimal(12,2) DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `Index_1` (`hotel_group_id`,`hotel_id`,`company_id`,`biz_date`),
  KEY `Index_2` (`hotel_group_id`,`biz_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `grp_company_perfor_year` (
  `hotel_group_id` 	int NOT NULL,
  `hotel_id` 		int NOT NULL,
  `id` 				bigint(16) NOT NULL AUTO_INCREMENT,
  `company_id` 		bigint(16) DEFAULT NULL,
  `company_class` 	varchar(20) DEFAULT '',
  `company_name` 	varchar(200) DEFAULT '',
  `year` 			varchar(4) DEFAULT '' COMMENT '年份',
  `index_code` 		decimal(12,2) DEFAULT '0.00',
  `month01` 		decimal(12,2) DEFAULT '0.00',
  `month02` 		decimal(12,2) DEFAULT '0.00',
  `month03` 		decimal(12,2) DEFAULT '0.00',
  `month04` 		decimal(12,2) DEFAULT '0.00',
  `month05` 		decimal(12,2) DEFAULT '0.00',
  `month06` 		decimal(12,2) DEFAULT '0.00',
  `month07` 		decimal(12,2) DEFAULT '0.00',
  `month08` 		decimal(12,2) DEFAULT '0.00',
  `month09` 		decimal(12,2) DEFAULT '0.00',
  `month10` 		decimal(12,2) DEFAULT '0.00',
  `month11` 		decimal(12,2) DEFAULT '0.00',
  `month12` 		decimal(12,2) DEFAULT '0.00',
  `month99` 		decimal(12,2) DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `Index_1` (`hotel_group_id`,`hotel_id`,`year`,`index_code`),
  KEY `Index_2` (`hotel_group_id`,`hotel_id`,`company_id`,`year`,`index_code`),
  KEY `Index_3` (`hotel_group_id`,`year`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `grp_company_perfor_special` (
  `hotel_group_id` 	int NOT NULL,
  `hotel_id` 		int NOT NULL,
  `id` 				bigint(16) NOT NULL AUTO_INCREMENT,
  `year` 			INT DEFAULT NULL COMMENT '年份',
  `date_type` 		varchar(20) DEFAULT '' COMMENT '节假日、月、周、季、自定义',
  `date_code` 		varchar(40) DEFAULT '',
  `date_desc` 		varchar(100) DEFAULT '',
  `date_short` 		varchar(40) DEFAULT '',
  `company_id` 		bigint(16) DEFAULT NULL,
  `company_class` 	varchar(20) DEFAULT '',
  `company_name` 	varchar(200) DEFAULT '',
  `nights` 			decimal(12,2) DEFAULT '0.00',
  `persons` 		decimal(12,2) DEFAULT '0.00',
  `room_avg` 		decimal(12,2) DEFAULT '0.00',
  `room_charge` 	decimal(12,2) DEFAULT '0.00',
  `pos_charge` 		decimal(12,2) DEFAULT '0.00',
  `ot_charge` 		decimal(12,2) DEFAULT '0.00',
  `ttl_charge` 		decimal(12,2) DEFAULT '0.00',
  `avg_charge` 		decimal(12,2) DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `Index_1` (`hotel_group_id`,`hotel_id`,`company_id`,`year`,`date_type`,`date_code`),
  KEY `Index_2` (`hotel_group_id`,`year`,`date_type`,`date_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `grp_company_special` (
  `hotel_group_id` 	int NOT NULL,
  `hotel_id` 		int NOT NULL,
  `id` 				bigint(16) NOT NULL AUTO_INCREMENT,
  `year` 			INT DEFAULT NULL COMMENT '年份',
  `date_type` 		varchar(20) DEFAULT '' COMMENT '节假日、月、周、季、自定义',
  `date_code` 		varchar(40) DEFAULT '',
  `date_desc` 		varchar(100) DEFAULT '',
  `sales_man` 		varchar(20) DEFAULT '',
  `sys_class` 		varchar(20) DEFAULT '',
  `class_descr` 	varchar(60) DEFAULT '',
  `number_add` 		decimal(12,2) DEFAULT '0.00',
  `number_all` 		decimal(12,2) DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `Index_1` (`hotel_group_id`,`hotel_id`,`year`,`date_type`,`date_code`,`sys_class`),
  KEY `Index_2` (`hotel_group_id`,`hotel_id`,`year`,`date_type`,`date_code`,`sales_man`),
  KEY `Index_3` (`hotel_group_id`,`hotel_id`,`year`,`date_type`,`date_code`,`sales_man`,`sys_class`),
  KEY `Index_4` (`hotel_group_id`,`year`,`date_type`,`date_code`,`sales_man`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `grp_manage_special` (
  `hotel_group_id` 	int NOT NULL,
  `hotel_id` 		int NOT NULL,
  `id` 				bigint(16) NOT NULL AUTO_INCREMENT,
  `year` 			INT DEFAULT NULL COMMENT '年份',
  `date_type` 		varchar(20) DEFAULT '' COMMENT '节假日、月、周、季、自定义',
  `date_code` 		varchar(40) DEFAULT '',
  `date_desc` 		varchar(100) DEFAULT '',
  `date_short` 		varchar(40) DEFAULT '',
  `income_rm` 		decimal(12,2) DEFAULT '0.00',
  `income_rm_plan` 	decimal(12,2) DEFAULT '0.00',
  `income_rm_per` 	decimal(12,2) DEFAULT '0.00',
  `income_fb` 		decimal(12,2) DEFAULT '0.00',
  `income_fb_plan` 	decimal(12,2) DEFAULT '0.00',
  `income_fb_per` 	decimal(12,2) DEFAULT '0.00',
  `income_ot` 		decimal(12,2) DEFAULT '0.00',
  `income_ot_plan` 	decimal(12,2) DEFAULT '0.00',
  `income_ot_per` 	decimal(12,2) DEFAULT '0.00',
  `income_ttl` 		decimal(12,2) DEFAULT '0.00',
  `income_ttl_plan` decimal(12,2) DEFAULT '0.00',
  `income_ttl_per` 	decimal(12,2) DEFAULT '0.00',
  `rental_rates` 	decimal(12,2) DEFAULT '0.00',
  `rental_rates_plan` decimal(12,2) DEFAULT '0.00',
  `rental_rates_per` decimal(12,2) DEFAULT '0.00',
  `room_avg` 		decimal(12,2) DEFAULT '0.00',
  `room_avg_plan` 	decimal(12,2) DEFAULT '0.00',
  `room_avg_per` 	decimal(12,2) DEFAULT '0.00',
  `rev_par` 		decimal(12,2) DEFAULT '0.00',
  `rev_par_plan` 	decimal(12,2) DEFAULT '0.00',
  `rev_par_per` 	decimal(12,2) DEFAULT '0.00',
  `room_sold` 		decimal(12,2) DEFAULT '0.00',
  `room_avl` 		decimal(12,2) DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `Index_1` (`hotel_group_id`,`hotel_id`,`year`,`date_type`,`date_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `grp_sales_special` (
  `hotel_group_id` 	int NOT NULL,
  `hotel_id` 		int NOT NULL,
  `id` 				bigint(16) NOT NULL AUTO_INCREMENT,
  `year` 			INT DEFAULT NULL COMMENT '年份',
  `date_type` 		varchar(20) DEFAULT '' COMMENT '节假日、月、周、季、自定义',
  `date_code` 		varchar(40) DEFAULT '',
  `date_desc` 		varchar(100) DEFAULT '',
  `date_short` 		varchar(40) DEFAULT '',
  `type` 			varchar(20) DEFAULT '' COMMENT '市场、来源、渠道',
  `class`			varchar(20) DEFAULT '',
  `classdesc` 		varchar(50) DEFAULT '',
  `section` 		varchar(50) DEFAULT '',
  `sectiondesc` 	varchar(50) DEFAULT '',
  `income` 			decimal(12,2) DEFAULT '0.00',
  `nights` 			decimal(12,2) DEFAULT '0.00',
  `persons` 		decimal(12,2) DEFAULT '0.00',
  PRIMARY KEY (`id`),
  KEY `Index_1` (`hotel_group_id`,`hotel_id`,`year`,`date_type`,`date_code`),
  KEY `Index_2` (`hotel_group_id`,`hotel_id`,`year`,`date_type`,`date_code`,`type`,`class`),
  KEY `Index_3` (`hotel_group_id`,`year`,`date_type`,`date_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `special_date` (
  `hotel_group_id` 	int NOT NULL,
  `hotel_id` 		int NOT NULL,
  `id` 				bigint(16) NOT NULL AUTO_INCREMENT,
  `year` 			INT DEFAULT NULL COMMENT '年份',
  `date_type` 		varchar(20) DEFAULT '' COMMENT '节假日、月、周、季、自定义',
  `date_code` 		varchar(40) DEFAULT '',
  `date_desc` 		varchar(100) DEFAULT '',
  `date_begin` 		datetime DEFAULT NULL,
  `date_end` 		datetime DEFAULT NULL,
  `remark` 			varchar(400) DEFAULT '',
  `extra1` 			varchar(200) DEFAULT '',
  `extra2` 			varchar(200) DEFAULT '',
  `extra3` 			varchar(200) DEFAULT '',
  `extra4` 			varchar(200) DEFAULT '',
  `create_user` 	varchar(20) DEFAULT '',
  `create_datetime` datetime NOT NULL,
  `modify_user` 	varchar(20) DEFAULT '',
  `modify_datetime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `Index_1` (`hotel_group_id`,`hotel_id`,`year`,`date_type`,`date_code`),
  KEY `Index_2` (`hotel_group_id`,`year`,`date_type`,`date_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
