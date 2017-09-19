
CREATE TABLE `up_status` (
  `id` BIGINT(16) NOT NULL AUTO_INCREMENT,
  `hotel_id` BIGINT(16) NOT NULL,
  `up_step` VARCHAR(32) NOT NULL,
  `time_begin` DATETIME DEFAULT NULL,
  `time_end` DATETIME DEFAULT NULL,
  `time_long` INT(11) NOT NULL DEFAULT '0',
  `remark` VARCHAR(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Index_1` (`hotel_id`,`up_step`)
) ENGINE=INNODB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COMMENT='执行时间记录表';

CREATE TABLE `up_map_code` (
  `hotel_group_id` BIGINT(20) NOT NULL,
  `hotel_id` BIGINT(16) NOT NULL,
  `id` BIGINT(16) NOT NULL AUTO_INCREMENT,
  `CODE` VARCHAR(12) NOT NULL COMMENT '比如:房类=rmtype 市场码=market ',
  `code_old` VARCHAR(12) NOT NULL,
  `code_old_des` VARCHAR(64) DEFAULT NULL,
  `code_new` VARCHAR(12) NOT NULL,
  `code_new_des` VARCHAR(64) DEFAULT NULL,
  `remark` VARCHAR(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `Index_1` (`hotel_group_id`,`hotel_id`,`CODE`,`code_old`)
) ENGINE=INNODB AUTO_INCREMENT=335 DEFAULT CHARSET=utf8 COMMENT='所有代码映射表';

CREATE TABLE `up_map_accnt` (
  `hotel_group_id` BIGINT(16) NOT NULL,
  `hotel_id` BIGINT(16) NOT NULL,
  `id` BIGINT(16) NOT NULL AUTO_INCREMENT,
  `accnt_type` VARCHAR(16) NOT NULL COMMENT '比如:登记单=master ',
  `accnt_class` VARCHAR(8) NOT NULL DEFAULT '' COMMENT '比如档案的 F G C A S ',
  `accnt_old` VARCHAR(16) NOT NULL,
  `accnt_new` BIGINT(16) NOT NULL DEFAULT '-1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `Index_1` (`hotel_group_id`,`hotel_id`,`accnt_type`,`accnt_old`),
  KEY `Index_2` (`hotel_group_id`,`hotel_id`,`accnt_type`,`accnt_new`)
) ENGINE=INNODB AUTO_INCREMENT=2858 DEFAULT CHARSET=utf8 COMMENT='所有帐号映射表';



