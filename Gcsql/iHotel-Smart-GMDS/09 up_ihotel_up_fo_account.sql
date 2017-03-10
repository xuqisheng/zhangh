DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_up_fo_account`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_up_fo_account`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT
)
label_0:
BEGIN
	-- =============================================================
	-- 明细账务迁移(前台) 
	-- =============================================================
	DELETE FROM up_status WHERE hotel_id=arg_hotel_id AND up_step='ACCOUNT';
	INSERT INTO up_status(hotel_id,up_step,time_begin,time_end,time_long,remark) VALUES(arg_hotel_id,'ACCOUNT',NOW(),NULL,0,''); 
	DELETE FROM account WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	
	ALTER TABLE account MODIFY COLUMN trans_accnt VARCHAR(30);
	
	INSERT INTO account(hotel_group_id,hotel_id,accnt,subaccnt,number,inumber,modu_code,biz_date,gen_date,ta_code,
		   arrange_code,article_code,quantity,charge,charge_base,charge_dsc,charge_srv,charge_tax,charge_oth,package_use,
		   package_limit,package_rate,pay,balance,cashier,act_flag,accept_bank,market,reason,trans_flag,trans_accnt,trans_subaccnt,
		   ta_descript,ta_descript_en,ta_no,ta_remark,rmno,grp_accnt,rmpost_mode,close_flag,close_id,split_flag,split_user,split_datetime,
		   split_cashier,mode1,pkg_number,create_user,create_datetime,modify_user,modify_datetime,card_id,card_no) 
	SELECT b.hotel_group_id,b.hotel_id,b.accnt_new,0,a.number,a.inumber,'02',a.bdate,a.date,a.pccode,
			'','',1,a.charge,0,0,0,0,0,0,
			0,0,a.credit,0,a.shift,a.crradjt,'','','',a.tofrom,a.accntof,NULL,
			a.ref,a.ref,a.ref1,a.ref2,a.roomno,a.groupno,a.mode,IF(a.billno='','',SUBSTR(a.billno,1,1)),IF(a.billno='',NULL,'-1'),'','',NULL,
			NULL,'',NULL,a.empno,a.log_date,a.empno,a.log_date,NULL,NULL
			FROM migrate_db.account a,up_map_accnt b 
			WHERE a.accnt=b.accnt_old AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.accnt_type IN ('master_si','master_r','consume');
		
	UPDATE account a,up_map_accnt b SET a.trans_accnt = b.accnt_new WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.accnt_type IN('master_si','master_r','consume') AND b.accnt_old=a.trans_accnt;
	UPDATE account a SET a.trans_accnt = NULL WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.trans_accnt<>'' AND LEFT(a.trans_accnt,1)>'9';
		
	ALTER TABLE account MODIFY COLUMN trans_accnt BIGINT(16);
	
	-- up_map_code 根据代码对照表更新最新的代码
	UPDATE account a,up_map_code b SET a.ta_code = b.code_new WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.code IN ('paymth','pccode') AND b.code_old = a.ta_code;

	-- 更新arrange_code,ta_descript
	UPDATE account a,code_transaction b SET a.arrange_code=b.arrange_code,a.ta_descript=b.descript WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.ta_code=b.code;
	
	-- 修复一下number
	UPDATE master_base a,(SELECT accnt,MAX(number) number FROM account WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id GROUP BY accnt) b
		SET a.last_num_link = b.number + 1 WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.accnt;

	UPDATE master_base a,(SELECT accnt,MAX(number) number FROM account WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id GROUP BY accnt) b
		SET a.last_num = b.number + 1 WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.accnt;		
	
	-- up act_flag账务其他标记的更新操作
	UPDATE account SET act_flag = '' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND act_flag NOT IN('C','CO','AD','LT');
	UPDATE account SET rmpost_mode = '' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND rmpost_mode NOT IN('J','K','S','N','P');
	UPDATE account SET close_flag = 'B' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND close_flag IN('P','O');

	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='ACCOUNT';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='ACCOUNT';
 	
END$$

DELIMITER ;