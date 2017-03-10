/*==============================================================*/
/* Table: up_status    更新时间状态表                           */
/*==============================================================*/
-- DROP TABLE IF EXISTS up_status;
CREATE TABLE up_status
(
   id                   BIGINT(16) 	NOT NULL AUTO_INCREMENT,
   hotel_id             BIGINT(16) 	NOT NULL,
   up_step              VARCHAR(32) NOT NULL,
   time_begin           DATETIME,
   time_end             DATETIME,
   time_long            INT 		NOT NULL DEFAULT 0,
   remark               VARCHAR(64),
   PRIMARY KEY (id),
   UNIQUE  KEY Index_1(hotel_id,up_step)
)ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COMMENT='执行时间记录表';

/*==============================================================*/
/* Table: up_map_accnt    账号对照表                            */
/*==============================================================*/
-- DROP TABLE IF EXISTS up_map_accnt;
CREATE TABLE up_map_accnt (
  hotel_group_id	BIGINT(16)	NOT NULL,
  hotel_id 			BIGINT(16) 	NOT NULL,
  id 				BIGINT(16) 	NOT NULL AUTO_INCREMENT,
  accnt_type 		VARCHAR(16) NOT NULL COMMENT '比如:登记单=master ',
  accnt_class 		VARCHAR(8) 	NOT NULL DEFAULT '' COMMENT '比如档案的 F G C A S ',
  accnt_old 		VARCHAR(16) NOT NULL,
  accnt_new 		BIGINT(16) 	NOT NULL DEFAULT '-1',
  PRIMARY KEY (id),
  UNIQUE KEY Index_1 (hotel_group_id,hotel_id,accnt_type,accnt_old),
  KEY Index_2 (hotel_group_id,hotel_id,accnt_type,accnt_new)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COMMENT='所有帐号映射表';

/*==============================================================*/
/* Table: up_map_code  代码对照表                               */
/* 插入需要新旧代码                                             */
/*==============================================================*/
-- DROP TABLE IF EXISTS up_map_code;
CREATE TABLE up_map_code (
  hotel_group_id	BIGINT(16)	NOT NULL,
  hotel_id 			BIGINT(16) 	NOT NULL,
  code 				VARCHAR(12) NOT NULL COMMENT '比如:房类=rmtype 市场码=market ',
  code_old 			VARCHAR(12) NOT NULL,
  code_old_des 		VARCHAR(64) DEFAULT NULL,
  code_new 			VARCHAR(12) NOT NULL,
  code_new_des 		VARCHAR(64) DEFAULT NULL,
  UNIQUE KEY Index_1(hotel_group_id,hotel_id,code,code_old)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='所有代码映射表';