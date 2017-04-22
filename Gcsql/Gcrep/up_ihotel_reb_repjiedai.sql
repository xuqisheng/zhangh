DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_reb_repjiedai`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_reb_repjiedai`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT,
	IN arg_begin_date		DATETIME
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	DECLARE var_bfdate	DATETIME;
	
	SELECT ADDDATE(biz_date,-1) INTO var_bfdate FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;

	WHILE arg_begin_date <= var_bfdate DO
		BEGIN			
			
			UPDATE rep_jiedai_history a,rep_jiedai_history b 
				SET a.last_charge = b.till_charge,a.last_credit = b.till_credit
				WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id				
					AND b.biz_date=ADDDATE(arg_begin_date,-1) AND a.biz_date=arg_begin_date AND a.classno IN ('03A','03B') AND a.classno=b.classno;
			
			UPDATE rep_jiedai_history SET till_charge = last_charge + charge,till_credit = last_credit + credit
				WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_begin_date AND classno IN ('03A','03B');					
				
			SET arg_begin_date = DATE_ADD(arg_begin_date,INTERVAL 1 DAY);
		END;
	END WHILE;
	
	UPDATE rep_jiedai a,rep_jiedai_history b SET
		a.last_charge=b.last_charge,a.last_credit=b.last_credit,a.till_charge=b.till_charge,a.till_credit=b.till_credit
	WHERE a.classno=b.classno 
	AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=var_bfdate AND a.classno IN ('03A','03B')
	AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=var_bfdate AND b.classno IN ('03A','03B');	
	
END$$

DELIMITER ;

CALL up_ihotel_reb_repjiedai(1,108,'2015-4-15');

DROP PROCEDURE IF EXISTS `up_ihotel_reb_repjiedai`;