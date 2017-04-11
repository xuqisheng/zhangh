DELIMITER $$

DROP PROCEDURE IF EXISTS `up_pos_modify_table_id`$$

CREATE PROCEDURE `up_pos_modify_table_id`(
	OUT arg_ret				INT)
    SQL SECURITY INVOKER
label_0:
BEGIN
	DECLARE var_mastermaxid 	BIGINT ;
	DECLARE var_accountmaxid 	BIGINT;
	DECLARE var_detailmaxid 	BIGINT;
	
	
	
	ALTER TABLE `pos_master_history` DROP COLUMN id;
	ALTER TABLE pos_master_history ADD COLUMN id BIGINT AUTO_INCREMENT AFTER hotel_id,ADD PRIMARY KEY ( `id` );
	ALTER TABLE pos_master_history MODIFY COLUMN id BIGINT;

	ALTER TABLE `pos_account_history` DROP COLUMN id;
	ALTER TABLE pos_account_history ADD COLUMN id BIGINT AUTO_INCREMENT AFTER hotel_id,ADD PRIMARY KEY ( `id` );
	ALTER TABLE pos_account_history MODIFY COLUMN id BIGINT;

	ALTER TABLE `pos_detail_history` DROP COLUMN id;
	ALTER TABLE pos_detail_history ADD COLUMN id BIGINT AUTO_INCREMENT AFTER hotel_id,ADD PRIMARY KEY ( `id` );
	ALTER TABLE pos_detail_history MODIFY COLUMN id BIGINT;

	
	SELECT IFNULL(MAX(id),0) INTO var_mastermaxid FROM pos_master_history;
	SELECT IFNULL(MAX(id),0) INTO var_accountmaxid FROM pos_account_history;
	SELECT IFNULL(MAX(id),0) INTO var_detailmaxid FROM pos_detail_history;
	
	ALTER TABLE `pos_master` DROP COLUMN id;
	ALTER TABLE pos_master ADD COLUMN id BIGINT AUTO_INCREMENT AFTER hotel_id,ADD PRIMARY KEY ( `id` );
	
	ALTER TABLE `pos_account` DROP COLUMN id;
	ALTER TABLE pos_account ADD COLUMN id BIGINT AUTO_INCREMENT AFTER hotel_id,ADD PRIMARY KEY ( `id` );
	
	ALTER TABLE `pos_detail` DROP COLUMN id;
	ALTER TABLE pos_detail ADD COLUMN id BIGINT AUTO_INCREMENT AFTER hotel_id,ADD PRIMARY KEY ( `id` );
	
	UPDATE pos_master SET id = var_mastermaxid + id ORDER BY id DESC;
	UPDATE pos_account SET id = var_accountmaxid + id ORDER BY id DESC;
	UPDATE pos_detail SET id = var_detailmaxid + id ORDER BY id DESC;
	
	SELECT IFNULL(MAX(id),0)+1 INTO var_mastermaxid FROM pos_master;
	SELECT IFNULL(MAX(id),0)+1 INTO var_accountmaxid FROM pos_account;
	SELECT IFNULL(MAX(id),0)+1 INTO var_detailmaxid FROM pos_detail;
	
	INSERT INTO `pos_master` (`hotel_group_id`, `hotel_id`, `id`, `accnt`, `type1`, `type2`, `type3`, `type4`, `type5`, `pccode`, `mode`, `shift`, `empid`, `sta`, `osta`, `biz_date`, `tableno`, `exttableno`, `gsts`, `children`, `phone`, `market`, `source`, `haccnt`, `name`, `cusno`, `cusinfo`, `cardno`, `cardinfo`, `saleid`, `saleinfo`, `dsc`, `reason`, `srv`, `tax`, `dscamount`, `srvamount`, `taxamount`, `amount`, `amount1`, `amount2`, `amount3`, `amount4`, `amount5`, `maxamount`, `charge`, `credit`, `bal`, `billno`, `paycode`, `extra`, `lastnum`, `lastrnum`, `lastpnum`, `pcrec`, `cmscode`, `receipt_no`, `receipt_amount`, `info`, `toaccnt`, `accntinfo`, `resno`, `qr_code`, `create_user`, `create_datetime`, `modify_user`, `modify_datetime`) 
		VALUES('1','-1',var_mastermaxid,'P7001703070007','001',NULL,NULL,NULL,NULL,'700','000','2','','O','I','2017-03-07 00:00:00','KF1','','1','0',NULL,'001','001','','','','','','','','','0.00','','0.15',NULL,'0.00','40.80','0.00','272.20','0.00','0.00','0.00','0.00','0.00','0.00','313.00','313.00','0.00','B7001703070006','','','1','5','2108',NULL,'',NULL,NULL,'',NULL,'',NULL,'','FO22','2017-03-07 21:40:05','FO22','2017-03-07 22:10:51');
		
	INSERT INTO `pos_account` (`hotel_group_id`, `hotel_id`, `id`, `accnt`, `number`, `inumber`, `subid`, `shift`, `pccode`, `tableno`, `empid`, `biz_date`, `logdate`, `paycode`, `descript`, `descript_en`, `amount`, `credit`, `bal`, `billno`, `foliono`, `orderno`, `sign`, `flag`, `sta`, `reason`, `info1`, `info2`, `bank`, `cardno`, `dtl_accnt`, `create_user`, `create_datetime`, `modify_user`, `modify_datetime`) 
		VALUES('1','-1',var_accountmaxid,'P4001612190001','1','1','0','2','400','GLT',NULL,'2016-12-19 00:00:00','2016-12-19 21:18:17','','',NULL,'15522.00','0.00','0.00','B4001612190001',NULL,NULL,'00000000000000000000','','O','','','',NULL,'','','FB2','2016-12-19 21:18:17','FB2','2016-12-19 21:26:17');	
		
	INSERT INTO `pos_detail` (`hotel_group_id`, `hotel_id`, `id`, `accnt`, `inumber`, `tnumber`, `anumber`, `mnumber`, `type`, `billno`, `orderno`, `sta`, `shift`, `empid`, `biz_date`, `note_code`, `sort_code`, `code`, `tocode`, `cond_code`, `cook`, `printid`, `descript`, `descript_en`, `unit`, `number`, `pinumber`, `price`, `amount`, `amount1`, `amount2`, `amount3`, `amount4`, `amount5`, `cost`, `flag`, `flag1`, `reason`, `dsc`, `srv`, `srv0`, `srv_dsc`, `tax`, `tax0`, `tax_dsc`, `tableno`, `siteno`, `info`, `cardno`, `cardinfo`, `kitchen`, `pcid`, `empid1`, `empid2`, `empid3`, `draw_date`, `create_user`, `create_datetime`, `modify_user`, `modify_datetime`) 
		VALUES('1','-1',var_detailmaxid,'P3001612190002','0','1','0','0','1','B3001612190002','1','I','2','FB2','2016-12-19 00:00:00','','001','001003','010','','','0','工作餐','工作餐','桌','3.00','0','200.00','600.00','600.00','0.00','0.00','0.00','0.00','0.00','00100000000000000000','0000000000','','0.00','0.00','0.00','0.00','0.00','0.00','0.00','W3','','','','','','25','','','',NULL,'FB2','2016-12-19 21:38:36','FB2','2016-12-19 21:38:46');

	DELETE FROM pos_master WHERE id = var_mastermaxid;
	DELETE FROM pos_account WHERE id = var_accountmaxid;		
	DELETE FROM pos_detail WHERE id = var_detailmaxid;
END$$

DELIMITER ;

CALL up_pos_modify_table_id(@ret);

DROP PROCEDURE IF EXISTS `up_pos_modify_table_id`;