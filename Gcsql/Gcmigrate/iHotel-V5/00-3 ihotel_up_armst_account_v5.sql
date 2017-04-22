DELIMITER $$
 
DROP PROCEDURE IF EXISTS `ihotel_up_armst_account_v5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_armst_account_v5`(
	IN arg_hotel_group_id BIGINT(16),
	IN arg_hotel_id 	BIGINT(16)
)
    SQL SECURITY INVOKER
BEGIN
	INSERT INTO ar_account (hotel_group_id,hotel_id,accnt,subaccnt,number,inumber,modu_code,biz_date,gen_date,ta_code,arrage_code,quantity,charge,pay,balance,charge0,pay0,
		charge1,pay1,charge9,pay9,balance9,disputed,invoice_code,invoice_amt,guest_name,guest_name2,cashier,reason,act_flag,trans_flag,trans_accnt,trans_subaccnt,
		ta_descript,ta_descript_en,ta_no,ta_remark,rmno,close_flag,close_id,act_tag,audit_tag,audit_user,audit_datetime,audit_cashier,mode1,pkg_number,
		pkg_code,create_user,create_datetime,modify_user,modify_datetime)
	SELECT arg_hotel_group_id,arg_hotel_id,b.id,c.id,a.number,0,'02',a.bdate,a.date,CONCAT(a.pccode,a.servcode),'',1,0,0,0,a.charge,
		a.credit,0,0,0,0,0,0,'',0,ref2,ref,shift,'',a.tofrom,a.accntof,0,
		0,ref,'','','','','',0,'A',1,NULL,NULL,NULL,NULL,NULL,NULL,a.empno,a.log_date,a.empno,a.log_date
	FROM migrate_xc.account a,ar_master b,ar_account_sub c WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id 
	AND c.type ='SUBACCNT' AND b.id = c.accnt AND a.accnt=b.arno AND a.billno ='';
		
	UPDATE ar_account a,up_map_code b SET a.ta_code = b.code_new,a.ta_descript = b.code_new_des WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code_old = a.ta_code AND b.cat IN ('paymth','pccode');
	UPDATE ar_account a,code_transaction b SET a.arrage_code = b.arrange_code WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code = a.ta_code;
	
	INSERT INTO ar_detail(hotel_group_id,hotel_id,accnt,subaccnt,number,inumber,modu_code,biz_date,gen_date,ta_code,arrange_code,article_code,quantity,charge,charge_base,
		charge_dsc,charge_srv,charge_tax,charge_oth,package_use,package_limit,package_rate,pay,balance,cashier,act_flag,accept_bank,market,src,rm_class,reason,trans_flag,
		trans_accnt,trans_subaccnt,ta_descript,ta_descript_en,ta_no,ta_remark,rmno,grp_accnt,rmpost_mode,close_flag,close_id,split_flag,split_user,split_datetime,
		split_cashier,mode1,pkg_number,create_user,create_datetime,modify_user,modify_datetime,ar_accnt,ar_subaccnt,ar_number,ar_inumber,ar_tag,ar_subtotal,ar_pnumber,
		charge9,credit9)
	SELECT arg_hotel_group_id,arg_hotel_id,b.id,c.id,a.number,a.number,'02',a.bdate,a.date,CONCAT(a.pccode,a.servcode),'','',1,a.charge,a.charge,0,0,0,0,0,0,0,a.credit,(a.charge-a.credit),a.shift,a.crradjt,'','',NULL,NULL,
	'',a.tofrom,CONVERT(a.accntof,UNSIGNED),0,a.ref,a.ref1,'','','',NULL,'','',0,'',NULL,NULL,NULL,'',NULL,a.empno,a.log_date,a.empno,a.log_date,b.id,c.id,a.number,a.number,'A','F',0,0,0
	FROM migrate_xc.account a,ar_master b,ar_account_sub c WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id 
	AND c.type = 'SUBACCNT' AND b.id = c.accnt AND a.accnt=b.arno AND a.billno = ''; 
 	
	-- 补齐房费相关代码市场码，保证AR款待分摊表数据完整(注意写入指定市场码)
	UPDATE ar_detail SET market='WAK' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND ar_tag='A' AND ta_code IN ('00001','00002','00003','00004','00005','00006','00007','00008') AND market='';
	
 	-- arrange_code好像有点问题 原先发现account_audit中ta_code为挂AR账时，ta_code和arrange_code都应该为空
	UPDATE ar_detail a,up_map_code b SET a.ta_code = b.code_new WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code_old = a.ta_code AND b.cat IN ('paymth','pccode');
	UPDATE ar_detail a,code_transaction b SET a.arrange_code = b.arrange_code WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code = a.ta_code;
	
	UPDATE ar_master a,(SELECT accnt,MAX(ar_number) ar_number FROM ar_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id GROUP BY accnt) b
		SET a.last_num_link = b.ar_number + 1 WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.accnt;
	
	UPDATE ar_master a,(SELECT accnt,MAX(ar_inumber) ar_inumber FROM ar_detail WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id GROUP BY accnt) b
		SET a.last_num = b.ar_inumber + 1 WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.accnt;
		
END$$

DELIMITER ;