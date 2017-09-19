DROP TABLE membercard;
CREATE TABLE `membercard` (
  `hotel_group_id` BIGINT(16) DEFAULT NULL COMMENT '请对照：hotel_group.id。集团编号，',
  `hotel_id` BIGINT(16) DEFAULT NULL COMMENT '请对照：hotel.id。酒店编号',
  `iss_hotel` VARCHAR(20) DEFAULT NULL COMMENT '请对照：hotel.code。发卡酒店代码',
  `biz_date` DATETIME DEFAULT NULL COMMENT '导入的积分、储值数据的营业日期',
  `card_id_temp` BIGINT(16) NOT NULL AUTO_INCREMENT COMMENT '中间数据，不填',
  `member_id_temp` BIGINT(20) DEFAULT NULL COMMENT '中间数据，不填',
  `account_master_id` BIGINT(16) DEFAULT NULL COMMENT '中间数据，不填',
  `card_id` BIGINT(16) DEFAULT NULL COMMENT '中间数据，不填',
  `member_id` BIGINT(16) DEFAULT NULL COMMENT '中间数据，不填',
  `guest_id` BIGINT(20) DEFAULT NULL COMMENT '若有导好的客史档案，根据hno填写该值',
  `company_id` BIGINT(20) DEFAULT NULL COMMENT '若有导好的公司档案，新账号填入', 
  `cno` BIGINT(20) DEFAULT NULL COMMENT '公司档案', 
  `card_no` VARCHAR(20) NOT NULL COMMENT '填西软系统中的card_no',
  `card_no2` VARCHAR(20) NOT NULL DEFAULT '' COMMENT '填西软系统中的no,即西软内部卡号',
  `sta` CHAR(2) NOT NULL DEFAULT 'R' COMMENT '状态=R=初始 I-有效,X-销卡,L-挂失,M-损坏,O-停用 S=休眠',
  `card_type` VARCHAR(30) NOT NULL COMMENT '请对照，card_type.code',
  `card_level` VARCHAR(30) NOT NULL COMMENT '请对照，card_level.code',
  `card_src` VARCHAR(30) NOT NULL COMMENT '请对照，code_base.parent_code = ''card_src''',
  `card_name` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '卡上姓名，可以用guest姓名',
  `src` VARCHAR(50) NOT NULL DEFAULT '' COMMENT 'src',
  `src_des` VARCHAR(50) NOT NULL DEFAULT '' COMMENT 'src',
  `mkt` VARCHAR(50) NOT NULL DEFAULT '' COMMENT 'market',
  `ratecode` VARCHAR(20) NOT NULL DEFAULT '' COMMENT '请对照：code_ratecode房价码',
  `posmode` VARCHAR(20) DEFAULT '' COMMENT '请对照：code_base.parent_code = ''pos_mode''餐娱码',
  `date_begin` DATETIME NOT NULL COMMENT '卡片有效期起',
  `date_end` DATETIME NOT NULL COMMENT '卡片有效期止',
  `password` VARCHAR(20) NOT NULL DEFAULT '' COMMENT '卡消费密码',
  `salesman` VARCHAR(10) DEFAULT NULL COMMENT '请对照：sales_man.code',
  `crc` VARCHAR(20) DEFAULT NULL COMMENT '写卡效验码',
  `remark` VARCHAR(512) DEFAULT NULL COMMENT '卡上备注',
  `point_pay` DECIMAL(10,2) NOT NULL DEFAULT '0.00' COMMENT '积分产生余额',
  `point_charge` DECIMAL(10,2) NOT NULL DEFAULT '0.00' COMMENT '积分消耗余额',
  `point_last_num` INT(11) NOT NULL DEFAULT '0' COMMENT '积分记录数，只导余额时填0',
  `card_master` VARCHAR(30) DEFAULT NULL COMMENT '原西软账务系统中，存在多卡公用一账号时，主卡填null，附卡填主卡的card_id_temp',
  `araccnt` VARCHAR(20) DEFAULT NULL COMMENT '原系统账务账号，如AR账号',
  `pay` DECIMAL(10,2) NOT NULL DEFAULT '0.00' COMMENT '充值金额',
  `charge` DECIMAL(10,2) NOT NULL DEFAULT '0.00' COMMENT '消费金额',
  `accredit` DECIMAL(10,2) NOT NULL DEFAULT '0.00' COMMENT '信用金额', 
  `last_num` INT(11) NOT NULL DEFAULT '0' COMMENT '储值账务记录数，只导余额时填0',
  `freeze` DECIMAL(10,2) DEFAULT '0.00' COMMENT '储值账务冻结金额',
  `pay_code` VARCHAR(10) DEFAULT '' COMMENT '产生期初数据时的付款码',
  `create_user` VARCHAR(20) NOT NULL COMMENT '建卡工号',
  `create_datetime` DATETIME NOT NULL COMMENT '建卡时间',
  `modify_user` VARCHAR(20) NOT NULL COMMENT '最后修改工号',
  `modify_datetime` DATETIME NOT NULL COMMENT '最后修改日期',
  `hno` VARCHAR(20) DEFAULT NULL COMMENT '原系统档案号',
  `hname` VARCHAR(60) DEFAULT '' COMMENT '姓名',
  `hlname` VARCHAR(40) DEFAULT '' COMMENT '姓',
  `hfname` VARCHAR(40) DEFAULT '' COMMENT '名',
  `hname2` VARCHAR(100) DEFAULT '' COMMENT '姓名拼音',
  `hname3` VARCHAR(100) DEFAULT '' COMMENT '英文名',
  `hname_combine` VARCHAR(200) DEFAULT '' COMMENT '姓名组合，',
  `sex` VARCHAR(10) DEFAULT '?' COMMENT '请对照：code_base.parent_code = ''card_src'',性别',
  `language` VARCHAR(10) NOT NULL DEFAULT '' COMMENT '请对照：code_base.parent_code = ''language'',语言',
  `birth` DATETIME DEFAULT NULL COMMENT '生日',
  `nation` VARCHAR(10) NOT NULL DEFAULT '' COMMENT '请对照：code_country.code。国籍',
  `id_code` VARCHAR(10) NOT NULL DEFAULT '?' COMMENT '请对照code_base.parent_code = ''idcode''.证件类型',
  `id_no` VARCHAR(50) NOT NULL DEFAULT '?' COMMENT '证件号码',
  `hremark` TEXT COMMENT '档案备注',
  `hcreate_user` VARCHAR(20) DEFAULT NULL COMMENT '档案创建人',
  `hcreate_datetime` DATETIME DEFAULT NULL COMMENT '档案创建日期',
  `hmodify_user` VARCHAR(20) DEFAULT NULL COMMENT '档案最后修改人',
  `hmodify_datetime` DATETIME DEFAULT NULL COMMENT '档案最后修改日期',
  `mobile` VARCHAR(160) DEFAULT NULL COMMENT '手机',
  `phone` VARCHAR(160) DEFAULT NULL COMMENT '电话',
  `email` VARCHAR(160) DEFAULT NULL COMMENT '电邮',
  `country` VARCHAR(10) DEFAULT NULL COMMENT '请对照：code_country.code。住址：国家',
  `state` VARCHAR(40) DEFAULT NULL COMMENT '请对照：code_province.code。住址：省',
  `city` VARCHAR(40) DEFAULT NULL COMMENT '请对照：code_city.code。住址：市',
  `division` VARCHAR(6) DEFAULT NULL COMMENT '请对照：code_city.division。住址：地区',
  `street` VARCHAR(512) DEFAULT NULL COMMENT '住址：地址',
  `zipcode` VARCHAR(12) DEFAULT NULL COMMENT '住址：邮编',
  `loginPW` VARCHAR(20) DEFAULT NULL COMMENT '网站登录密码',
  PRIMARY KEY (`card_id_temp`),
  UNIQUE KEY `Index_1` (`card_no`),
  KEY `Index_3` (`card_no2`),
  KEY `card_id_temp` (`card_id_temp`),
  KEY `member_id_temp` (`member_id_temp`),
  KEY `guest_id` (`guest_id`),
  KEY ratecode(ratecode),
  KEY posmode(posmode),
  KEY hno(hno),
  KEY cno(cno),
  KEY `card_id` (`card_id`)
) ENGINE=INNODB AUTO_INCREMENT=383 DEFAULT CHARSET=utf8;

SELECT * FROM membercard;
