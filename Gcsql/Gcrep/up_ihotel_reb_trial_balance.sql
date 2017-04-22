DELIMITER $$

 
DROP PROCEDURE IF EXISTS `up_ihotel_reb_trial_balance`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_reb_trial_balance`(
	arg_hotel_group_id		BIGINT,
	arg_hotel_id			BIGINT,
  	arg_begin_date			DATETIME
)
BEGIN
	DECLARE var_hotel_code		VARCHAR(20);
 	DECLARE var_bdate		DATETIME;

	SELECT DATE_ADD(set_value,INTERVAL -1 DAY) INTO var_bdate FROM sys_option WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog = 'system' AND item = 'biz_date';

  
	WHILE arg_begin_date <= var_bdate DO
		BEGIN 	
			UPDATE rep_trial_balance_history a,rep_trial_balance_history b SET a.amount_m = a.amount+b.amount_m,a.amount_y = a.amount+b.amount_y WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
				AND a.biz_date = arg_begin_date AND a.item_type = b.item_type AND a.item_code = b.item_code AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.biz_date= DATE_ADD(arg_begin_date,INTERVAL -1 DAY);

			UPDATE rep_trial_balance_history SET amount_m = amount, amount_y = amount WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date = arg_begin_date AND INSTR(item_code,'*') > 0 ;

			IF EXISTS(SELECT 1 FROM biz_month WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND begin_date=arg_begin_date AND biz_month=1) THEN 
				UPDATE rep_trial_balance_history SET amount_m = amount, amount_y=amount WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_begin_date; 
			ELSEIF EXISTS(SELECT 1 FROM biz_month WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND begin_date=arg_begin_date) THEN 
				UPDATE rep_trial_balance_history SET amount_m = amount WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_begin_date; 
			END IF; 	
					
			SET arg_begin_date = ADDDATE(arg_begin_date,INTERVAL 1 DAY);
		END;
	END WHILE;
	
	UPDATE rep_trial_balance a,rep_trial_balance_history b SET a.amount_m = b.amount_m,a.amount_y = b.amount_y
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = var_bdate AND a.item_type = b.item_type AND a.item_code = b.item_code AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.biz_date = var_bdate;
 
END$$

DELIMITER ;