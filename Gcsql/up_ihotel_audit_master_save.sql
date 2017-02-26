/*
DROP TABLE IF EXISTS rep_master_save;
CREATE TABLE rep_master_save (
  hotel_group_id 	BIGINT(16) NOT NULL,
  hotel_id 			BIGINT(16) NOT NULL,
  id 				BIGINT(16) NOT NULL AUTO_INCREMENT,
  biz_date 			DATETIME NOT NULL,
  accnt 			BIGINT(16) NOT NULL COMMENT 'master_base.id ',
  master_id 		BIGINT(16) NOT NULL COMMENT '用来标记同住，没有同住则填充自己id',
  name 				VARCHAR(80) NOT NULL DEFAULT '',
  grp_accnt 		BIGINT(16) NOT NULL DEFAULT '0',
  grpname 			VARCHAR(100) NOT NULL DEFAULT '',
  id_no 			VARCHAR(20) NOT NULL DEFAULT '',
  sta 				CHAR(1) NOT NULL DEFAULT '',
  sex 				CHAR(2) NOT NULL DEFAULT '',
  vip 				VARCHAR(6) NOT NULL DEFAULT '',
  phone 			VARCHAR(20) NOT NULL DEFAULT '',
  mobile 			VARCHAR(20) NOT NULL DEFAULT '',
  rmtype 			VARCHAR(10) NOT NULL,
  rmno 				VARCHAR(10) NOT NULL,
  arr 				DATETIME NOT NULL,
  dep 				DATETIME NOT NULL,
  rack_rate 		DECIMAL(8,2) NOT NULL DEFAULT '0.00',
  nego_rate 		DECIMAL(8,2) NOT NULL DEFAULT '0.00',
  real_rate 		DECIMAL(8,2) NOT NULL DEFAULT '0.00',
  dsc_reason 		VARCHAR(10) NOT NULL DEFAULT '',
  guest_id 			BIGINT(16) NOT NULL,
  company_id 		BIGINT(16) NOT NULL,
  agent_id 			BIGINT(16) NOT NULL,
  source_id 		BIGINT(16) NOT NULL,
  member_type 		VARCHAR(10) NOT NULL DEFAULT '',
  member_no 		VARCHAR(20) NOT NULL DEFAULT '',
  card_id 			BIGINT(16) DEFAULT NULL,
  salesman 			VARCHAR(10) NOT NULL DEFAULT '',
  ratecode 			VARCHAR(20) NOT NULL DEFAULT '',
  market 			VARCHAR(10) NOT NULL DEFAULT '',
  src 				VARCHAR(10) NOT NULL DEFAULT '',
  packages 			VARCHAR(20) NOT NULL DEFAULT '',
  rsv_no 			VARCHAR(20) NOT NULL DEFAULT '',
  adult	 			INT,
  children	 		INT,
  remark 			VARCHAR(512) NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  KEY index1 (hotel_group_id,hotel_id,biz_date),
  KEY index2 (hotel_group_id,hotel_id,accnt),
  KEY index3 (hotel_group_id,hotel_id,company_id),
  KEY index4 (hotel_group_id,hotel_id,agent_id),
  KEY index5 (hotel_group_id,hotel_id,source_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
*/

DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_audit_master_save`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_audit_master_save`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	OUT arg_ret				INT,		
	OUT arg_msg				VARCHAR(10) 
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ==================================================================
	-- 用途：保存每日主单信息，针对本日在住、日租房统计，适用于标准合并版
	--		 需要放至于夜审流程中	
	-- 解释: 
	-- 范例: 
	-- 作者：
	-- ==================================================================
    DECLARE var_bdate DATETIME;		
						
	SET arg_ret = 1,arg_msg = 'OK';
	SELECT ADDDATE(biz_date1,-1) INTO var_bdate FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id ;
       
	DELETE FROM rep_master_save WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=var_bdate;
	
	INSERT INTO rep_master_save(hotel_group_id,hotel_id,biz_date,accnt,master_id,name,grp_accnt,grpname,id_no,sta,sex,vip,
		phone,mobile,rmtype,rmno,arr,dep,rack_rate,nego_rate,real_rate,dsc_reason,guest_id,company_id,agent_id,source_id,
		member_type,member_no,card_id,salesman,ratecode,market,src,packages,rsv_no,adult,children,remark)
	SELECT a.hotel_group_id,a.hotel_id,var_bdate,a.id,a.master_id,b.name,a.grp_accnt,IFNULL(e.name,''),b.id_no,a.sta,b.sex,b.vip,
		b.phone,b.mobile,a.rmtype,a.rmno,a.arr,a.dep,a.rack_rate,a.nego_rate,a.real_rate,a.dsc_reason,b.profile_id,a.company_id,a.agent_id,a.source_id,
		a.member_type,a.member_no,a.inner_card_id,a.salesman,a.ratecode,a.market,a.src,packages,a.rsv_no,a.adult,a.children,a.remark
	FROM master_base_till a LEFT JOIN master_guest_till e ON e.hotel_group_id=arg_hotel_group_id AND e.hotel_id=arg_hotel_id AND a.grp_accnt=e.id
		,master_guest_till b WHERE a.id=b.id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id
		AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.rsv_class='F' AND a.id<>a.rsv_id 
		AND (a.sta = 'I' OR (a.sta IN ('O','S') AND NOT EXISTS(SELECT 1 FROM master_base_last c WHERE a.id=c.id)));
	
END$$

DELIMITER ;