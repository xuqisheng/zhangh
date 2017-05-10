DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_dai_snapshot_guest`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_dai_snapshot_guest`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	DECLARE var_date_begin	DATETIME;
	DECLARE var_date_end	DATETIME;

	
	DROP TABLE IF EXISTS temp_dai_snapshot;
	CREATE TABLE temp_dai_snapshot(
		master_type 	VARCHAR(10) DEFAULT NULL,
		biz_date 		DATETIME DEFAULT NULL,
		snap_bal_last	DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		dai_bal_last	DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		diff_bal_last	DECIMAL(12,2) NOT NULL DEFAULT '0.00',		
		snap_bal_till	DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		dai_bal_till	DECIMAL(12,2) NOT NULL DEFAULT '0.00',		
		diff_bal_till	DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		KEY index1(biz_date,master_type)
	)ENGINE=INNODB DEFAULT CHARSET=utf8;
	
	SELECT MIN(biz_date) INTO var_date_begin FROM rep_dai_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	SELECT MAX(biz_date) INTO var_date_end FROM rep_dai_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	SET var_date_begin = '2015-1-1';	
	
	WHILE var_date_begin <= var_date_end DO
		BEGIN
			INSERT INTO temp_dai_snapshot
				SELECT 'master',var_date_begin,SUM(last_balance),0,0,SUM(till_balance),0,0
					FROM master_snapshot WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND master_type <> 'armaster'
					AND biz_date_begin < var_date_begin AND biz_date_end >= var_date_begin;	
		
			SET var_date_begin = ADDDATE(var_date_begin,1);				
		END;
	END WHILE;
		
	UPDATE temp_dai_snapshot a,rep_dai_history b SET a.dai_bal_last = b.last_bl,a.dai_bal_till = b.till_bl WHERE a.biz_date = b.biz_date AND b.classno='02000' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id;
		
	UPDATE temp_dai_snapshot SET diff_bal_last = snap_bal_last - dai_bal_last;
	UPDATE temp_dai_snapshot SET diff_bal_till = snap_bal_till - dai_bal_till;
		
	SELECT * FROM temp_dai_snapshot WHERE diff_bal_last <> 0 OR diff_bal_till <> 0 ORDER BY biz_date;
		
END$$

DELIMITER ;

CALL up_ihotel_dai_snapshot_guest(1,10);

DROP PROCEDURE IF EXISTS `up_ihotel_dai_snapshot_guest`;

