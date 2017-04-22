DELIMITER $$

USE `portal_ipms`$$

DROP PROCEDURE IF EXISTS `up_ihotel_audit_rep_jiedai_jiedai`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_audit_rep_jiedai_jiedai`(
	IN arg_hotel_group_id		INT,
	IN arg_hotel_id			INT,
	IN arg_accnt_type		CHAR(2),
	IN arg_accnt			BIGINT,
	IN arg_charge			DECIMAL(12,2),
	IN arg_pay			DECIMAL(12,2)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ---------------------------------------------------------------
	-- 夜审过程- 定制稽核底表
	-- 作者：张晓斌 2016.9.13
	-- 2016.09.13日 
	-- ---------------------------------------------------------------
	-- 修改日志 
	-- ---------------------------------------------------------------
	DECLARE var_gstbl		VARCHAR(10);
	DECLARE var_arbl		VARCHAR(10);
	DECLARE var_deptno		CHAR(1);
	DECLARE var_tacodes_ar		VARCHAR(100);
	DECLARE var_tacodes_vip		VARCHAR(100);
	SET  var_gstbl = '02000', var_arbl = '03000';
	
 
	IF arg_accnt_type = 'AR' AND arg_charge = 0 THEN
		UPDATE rep_dai_hd SET credit=credit+arg_pay,sumcre = sumcre-arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno = var_arbl;
	ELSEIF arg_accnt_type = 'AR' AND arg_charge <> 0 THEN
		UPDATE rep_dai_hd SET debit=debit+arg_charge,sumcre = sumcre+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno = var_arbl;		
	ELSEIF arg_accnt_type = 'FO' AND arg_charge = 0 THEN
		UPDATE rep_dai_hd SET credit=credit+arg_pay,sumcre = sumcre-arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno = var_gstbl;
	ELSEIF arg_accnt_type = 'FO' AND arg_charge <> 0 THEN
		UPDATE rep_dai_hd SET debit=debit+arg_charge,sumcre = sumcre+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno = var_gstbl;		
 
	END IF;
 		
 
    	BEGIN
 
		SET @procresult = 0 ;
		LEAVE label_0 ;
	END ;
	
  END$$

DELIMITER ;