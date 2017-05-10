/*

*/
DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_reb_snapshot_armaster`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_reb_snapshot_armaster`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT,
	IN arg_biz_date			DATETIME,
	IN arg_master_id		INT,
	IN arg_charge_bal		DECIMAL(12,2),
	IN arg_pay_bal			DECIMAL(12,2)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ==================================================================
	-- 用途：重建快照表AR相关的余额	
	-- 解释: 
	-- 范例: 
	-- 作者：
	-- ==================================================================
	DECLARE var_id		BIGINT(16);
	
	-- 费用
	IF arg_charge_bal <> 0 THEN
		BEGIN
			UPDATE master_snapshot a SET 
				a.charge_ot   = a.charge_ot   - arg_charge_bal,a.charge_ttl   = a.charge_ttl   - arg_charge_bal,
				a.charge_ot2  = a.charge_ot2  - arg_charge_bal,a.charge_ttl2  = a.charge_ttl2  - arg_charge_bal,
				a.till_charge = a.till_charge - arg_charge_bal,a.till_balance = a.till_balance - arg_charge_bal
			WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.master_type = 'armaster'
				AND a.master_id = arg_master_id AND a.biz_date_begin < arg_biz_date AND a.biz_date_end >= arg_biz_date;				

			SET var_id = 0;
			SELECT id INTO var_id FROM master_snapshot WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND master_type = 'armaster' AND master_id = arg_master_id AND biz_date_begin < arg_biz_date AND biz_date_end >= arg_biz_date;
			
			UPDATE master_snapshot a SET 
				a.last_charge = a.last_charge - arg_charge_bal,a.last_balance = a.last_balance - arg_charge_bal,
				a.charge_ot2  = a.charge_ot2  - arg_charge_bal,a.charge_ttl2  = a.charge_ttl2  - arg_charge_bal,
				a.till_charge = a.till_charge - arg_charge_bal,a.till_balance = a.till_balance - arg_charge_bal
			WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.master_type = 'armaster'
				AND a.master_id = arg_master_id AND a.id > var_id;		
		END;			
	END IF;				
	-- 付款
	IF arg_pay_bal <>0 THEN
		BEGIN
			UPDATE master_snapshot a SET 
				a.pay_chk  = a.pay_chk  - arg_pay_bal,a.pay_ttl      = a.pay_ttl 	  - arg_pay_bal,
				a.pay_chk2 = a.pay_chk2 - arg_pay_bal,a.pay_ttl2     = a.pay_ttl2 	  - arg_pay_bal,
				a.till_pay = a.till_pay - arg_pay_bal,a.till_balance = a.till_balance + arg_pay_bal
			WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.master_type = 'armaster' 
			AND a.master_id = arg_master_id  AND a.biz_date_begin < arg_biz_date AND a.biz_date_end >= arg_biz_date;

			SET var_id = 0;
			SELECT id INTO var_id FROM master_snapshot WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND master_type = 'armaster' AND master_id = arg_master_id AND biz_date_begin < arg_biz_date AND biz_date_end >= arg_biz_date; 

			UPDATE master_snapshot a SET 
				a.last_pay = a.last_pay - arg_pay_bal,a.last_balance = a.last_balance - arg_pay_bal,
				a.pay_chk2 = a.pay_chk2 - arg_pay_bal,a.pay_ttl2 = a.pay_ttl2 - arg_pay_bal,
				a.till_pay = a.till_pay - arg_pay_bal,a.till_balance = a.till_balance + arg_pay_bal
			WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.master_type = 'armaster'
			AND a.master_id = arg_master_id  AND a.id > var_id;			
		END;
	END IF;	
		
END$$

DELIMITER ;

CALL up_ihotel_reb_snapshot_armaster(1,103,'2014-10-30',11283,0,0);

DROP PROCEDURE IF EXISTS `up_ihotel_reb_snapshot_armaster`;