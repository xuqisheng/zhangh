DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_armst_account_x5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_armst_account_x5`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT
)
    SQL SECURITY INVOKER
BEGIN

	INSERT INTO ar_account(hotel_group_id,hotel_id,accnt,subaccnt,number,inumber,modu_code,biz_date,gen_date,ta_code,
		arrage_code,quantity,charge,pay,balance,charge0,pay0,charge1,pay1,charge9,pay9,balance9,disputed,invoice_code,
		invoice_amt,guest_name,guest_name2,cashier,reason,act_flag,trans_flag,trans_accnt,trans_subaccnt,
		ta_descript,ta_descript_en,ta_no,ta_remark,rmno,close_flag,close_id,act_tag,audit_tag,audit_user,
		audit_datetime,audit_cashier,mode1,pkg_number,pkg_code,create_user,create_datetime,modify_user,modify_datetime)
	SELECT arg_hotel_group_id,arg_hotel_id,b.id,a.subaccnt,a.number,a.inumber,a.modu_id,a.bdate,a.date,a.pccode,
		a.argcode,a.quantity,a.charge,a.credit,a.balance,a.charge0,a.credit0,a.charge1,a.credit1,a.charge9,a.credit9,a.balance9,a.disputed,a.invoice_id,
		a.invoice,a.guestname,a.guestname2,a.shift,a.reason,a.tofrom,'',
		IF(a.accntof = '',0,IF(a.accntof LIKE 'AR%',CONVERT(SUBSTRING(a.accntof,3),UNSIGNED),CONVERT(CONCAT(SUBSTRING(a.accntof,2,2),SUBSTRING(a.accntof,5)),UNSIGNED))),0,
		a.ref,a.ref1,a.ref1,a.ref2,a.roomno,'',0,a.tag,a.audit,NULL,
		NULL,NULL,a.mode1,NULL,NULL,a.empno,a.log_date,a.empno,a.log_date
	FROM migrate_db.ar_detail a,ar_master b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.accnt = b.arno; 
		
	UPDATE ar_account a,up_map_code b SET a.ta_code = b.code_new WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code_old = a.ta_code AND b.code IN ('paymth','pccode');
	UPDATE ar_account a,code_transaction b SET a.arrage_code = b.arrange_code WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code = a.ta_code;
	
	INSERT INTO ar_detail(hotel_group_id,hotel_id,accnt,subaccnt,number,inumber,modu_code,biz_date,gen_date,ta_code,
		arrange_code,article_code,quantity,charge,charge_base,charge_dsc,charge_srv,charge_tax,charge_oth,package_use,
		package_limit,package_rate,pay,balance,cashier,act_flag,accept_bank,market,src,rm_class,reason,trans_flag,
		trans_accnt,trans_subaccnt,ta_descript,ta_descript_en,ta_no,ta_remark,rmno,grp_accnt,rmpost_mode,close_flag,
		close_id,split_flag,split_user,split_datetime,split_cashier,mode1,pkg_number,create_user,create_datetime,
		modify_user,modify_datetime,ar_accnt,ar_subaccnt,ar_number,ar_inumber,ar_tag,ar_subtotal,ar_pnumber,charge9,credit9)
	SELECT arg_hotel_group_id,arg_hotel_id,IF(a.accnt LIKE 'AR%',b.id,CONVERT(CONCAT('3',SUBSTRING(a.accntof,2)),UNSIGNED)),a.subaccnt,a.number,a.inumber,a.modu_id,a.bdate,a.date,a.pccode,
		a.argcode,'',a.quantity,a.charge,a.charge1,a.charge2,a.charge3,a.charge4,a.charge5,a.package_d,
		0,0,a.credit,a.balance,a.shift,'','',a.tag,'','',a.reason,a.tofrom,
		IF(a.accntof = '',0,IF(a.accntof LIKE 'AR%',CONVERT(SUBSTRING(a.accntof,3),UNSIGNED),CONVERT(CONCAT(SUBSTRING(a.accntof,2,2),SUBSTRING(a.accntof,5)),UNSIGNED))),0,a.ref,a.ref1,IF(a.accntof = '',0,IF(a.accntof LIKE 'AR%',CONVERT(SUBSTRING(a.accntof,3),UNSIGNED),CONVERT(CONCAT(SUBSTRING(a.accntof,2,2),SUBSTRING(a.accntof,5)),UNSIGNED))),a.ref2,a.roomno,'','',IF(a.billno = '','','B'),
		IF(a.accntof = '',0,CONVERT(CONCAT(SUBSTRING(a.accntof,2,2),SUBSTRING(a.accntof,5)),UNSIGNED)),'',NULL,NULL,NULL,a.mode1,NULL,a.empno,a.log_date,
		a.empno,a.log_date,b.id,a.ar_subaccnt,a.ar_number,a.ar_inumber,a.ar_tag,a.ar_subtotal,a.ar_pnumber,a.charge9,a.credit9
	FROM migrate_db.ar_account a,ar_master b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.ar_accnt = b.arno;
	
	-- 补齐房费相关代码市场码，保证AR款待分摊表数据完整(注意写入指定市场码)
	UPDATE ar_detail SET market='LYSK01' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND ar_tag='A' AND ta_code IN ('0001','0002','0003','0004','0005','0006','0007') AND market='';
	
 	-- arrange_code好像有点问题 原先发现account_audit中ta_code为挂AR账时，ta_code和arrange_code都应该为空
	UPDATE ar_detail a,up_map_code b SET a.ta_code = b.code_new WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code_old = a.ta_code AND b.code IN ('paymth','pccode');
	UPDATE ar_detail a,code_transaction b SET a.arrange_code = b.arrange_code WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code = a.ta_code;
	
	UPDATE ar_master a,(SELECT ar_accnt,MAX(ar_number) ar_number FROM ar_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id GROUP BY ar_accnt) b
		SET a.last_num_link = b.ar_number + 1 WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.ar_accnt;
	
	UPDATE ar_master a,(SELECT ar_accnt,MAX(ar_inumber) ar_inumber FROM ar_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id GROUP BY ar_accnt) b
		SET a.last_num = b.ar_inumber + 1 WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.ar_accnt;

END$$

DELIMITER ;