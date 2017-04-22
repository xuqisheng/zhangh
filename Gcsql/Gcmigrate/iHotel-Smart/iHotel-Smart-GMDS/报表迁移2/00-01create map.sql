-- 在中间库执行
DROP TABLE jour_map;
CREATE TABLE jour_map (
  code_old 	VARCHAR(50)  DEFAULT NULL COMMENT '西软代码，',
  des_old 	VARCHAR(255) DEFAULT NULL COMMENT '西软描述',
  code_new 	VARCHAR(50)  DEFAULT NULL COMMENT '绿云代码，',
  des_new 	VARCHAR(255) DEFAULT NULL COMMENT '绿云描述'
  );
  
DROP TABLE jie_map;
CREATE TABLE jie_map (
  code_old 	VARCHAR(50)  DEFAULT NULL COMMENT '西软代码，',
  des_old 	VARCHAR(255) DEFAULT NULL COMMENT '西软描述',
  code_new 	VARCHAR(50)  DEFAULT NULL COMMENT '绿云代码，',
  des_new 	VARCHAR(255) DEFAULT NULL COMMENT '绿云描述'
  );
  
DROP TABLE jour_map2;
CREATE TABLE jour_map2 (
  code_old 	VARCHAR(50)  DEFAULT NULL COMMENT '西软代码，',
  des_old 	VARCHAR(255) DEFAULT NULL COMMENT '西软描述',
  code_new 	VARCHAR(50)  DEFAULT NULL COMMENT '绿云代码，',
  des_new 	VARCHAR(255) DEFAULT NULL COMMENT '绿云描述'
  );
  
  
  CREATE TABLE `zzz` (
  `hotel_id` BIGINT(20) DEFAULT NULL,
  `accnt_type` CHAR(10) DEFAULT NULL,
  `accnt` BIGINT(20) DEFAULT NULL,
  `balance` DECIMAL(12,2) DEFAULT NULL,
  `accnt_old` VARCHAR(10) DEFAULT NULL
) ENGINE=INNODB DEFAULT CHARSET=utf8

