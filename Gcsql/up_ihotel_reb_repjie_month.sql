DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_reb_repjie_month`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_reb_repjie_month`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT,
	IN arg_begin_date		DATETIME,
	IN arg_end_date			DATETIME
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- =============================================================================
	-- 用途:根据底表每日正确数据重新计算月数据
	-- 解释:CALL up_ihotel_reb_repjie_month(集团id,酒店id,开始日期,结束日期)
	-- 作者:张惠 2014-11-04
	-- =============================================================================
	DECLARE var_bizdate		DATETIME;
	DECLARE var_mdate		DATETIME;
	DECLARE var_lastbl02	DECIMAL(12,2);
	DECLARE var_lastbl03	DECIMAL(12,2);
	DECLARE var_lastbl06	DECIMAL(12,2);

	
	UPDATE rep_jie SET month08=0,month09=0 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	UPDATE rep_jie_history SET month08=0,month09=0 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date>=arg_begin_date;	
	
	SELECT biz_date INTO var_bizdate FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	IF arg_end_date > DATE_ADD(var_bizdate,INTERVAL -1 DAY) THEN
		SET arg_end_date=DATE_ADD(var_bizdate,INTERVAL -1 DAY);
	END IF;	

	WHILE arg_begin_date <= arg_end_date DO
		BEGIN
			SET var_mdate = DATE_ADD(arg_begin_date,INTERVAL -(DAYOFMONTH(arg_begin_date)-1) DAY);
			SELECT last_bl INTO var_lastbl02 FROM rep_dai_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_mdate AND classno = '02000';
			SELECT last_bl INTO var_lastbl03 FROM rep_dai_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_mdate AND classno = '03000';
			SELECT last_bl INTO var_lastbl06 FROM rep_dai_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = var_mdate AND classno = '06000';			
			
			IF EXISTS(SELECT 1 FROM biz_month WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND begin_date = arg_begin_date) THEN
				BEGIN
					UPDATE rep_jie_history a SET
						a.month01=a.day01,a.month02=a.day02,a.month03=a.day03,a.month04=a.day04,a.month05=a.day05,
						a.month06=a.day06,a.month07=a.day07,a.month08=a.day08,a.month09=a.day09,a.month99=a.day99
					WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_begin_date;							
					UPDATE rep_dai_history a SET
						a.credit01m=a.credit01,a.credit02m=a.credit02,a.credit03m=a.credit03,a.credit04m=a.credit04,a.credit05m=a.credit05,
						a.credit06m=a.credit06,a.credit07m=a.credit07,a.sumcrem=a.sumcre,a.last_blm=0,a.debitm=a.debit,a.creditm=a.credit
					WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_begin_date;
					
					UPDATE rep_dai_history a SET 
						a.till_blm=a.last_blm+a.debitm-a.creditm 
					WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_begin_date; 

					UPDATE rep_jiedai_history a SET
						a.last_chargem=0,a.last_creditm=0,a.chargem=a.charge,a.creditm=a.credit,a.applym=a.apply
					WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_begin_date;
					UPDATE rep_jiedai_history a SET 
						a.till_chargem=a.last_chargem+a.chargem,a.till_creditm=a.last_creditm+a.creditm
					WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_begin_date;								
				END;
			ELSE
				BEGIN
					UPDATE rep_jie_history a,rep_jie_history b SET
						a.month01=a.day01+b.month01,a.month02=a.day02+b.month02,a.month03=a.day03+b.month03,
						a.month04=a.day04+b.month04,a.month05=a.day05+b.month05,a.month06=a.day06+b.month06,
						a.month07=a.day07+b.month07,a.month08=a.day08+b.month08,a.month09=a.day09+b.month09,a.month99=a.day99+b.month99
					WHERE a.classno=b.classno 
					AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_begin_date
					AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=ADDDATE(arg_begin_date,-1);

					UPDATE rep_dai_history a,rep_dai_history b SET
						a.credit01m=a.credit01+b.credit01m,a.credit02m=a.credit02+b.credit02m,a.credit03m=a.credit03+b.credit03m,
						a.credit04m=a.credit04+b.credit04m,a.credit05m=a.credit05+b.credit05m,a.credit06m=a.credit06+b.credit06m,
						a.credit07m=a.credit07+b.credit07m,a.sumcrem=a.sumcre+b.sumcrem,a.last_blm=b.till_blm,a.debitm=a.debit+b.debitm,a.creditm=a.credit+b.creditm
					WHERE a.classno=b.classno 
					AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_begin_date
					AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=ADDDATE(arg_begin_date,-1);
					
					UPDATE rep_dai_history a SET 
						a.till_blm=a.last_blm+a.debitm-a.creditm 
					WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_begin_date AND a.classno NOT IN ('02000','03000','06000');
					
					UPDATE rep_dai_history a SET 
						a.till_blm = var_lastbl02 + a.debitm-a.creditm 
					WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = arg_begin_date AND a.classno = '02000';
					UPDATE rep_dai_history a SET 
						a.till_blm = var_lastbl03 + a.debitm-a.creditm 
					WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = arg_begin_date AND a.classno = '03000';
					UPDATE rep_dai_history a SET 
						a.till_blm = var_lastbl06 + a.debitm-a.creditm 
					WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date = arg_begin_date AND a.classno = '06000';					

					UPDATE rep_jiedai_history a,rep_jiedai_history b SET						
						a.last_chargem=b.till_chargem,a.last_creditm=b.till_creditm,						
						a.chargem=a.charge+b.chargem,a.creditm=a.credit+b.creditm,a.applym=a.apply+a.applym
					WHERE a.classno=b.classno 
					AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_begin_date
					AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=ADDDATE(arg_begin_date,-1);
					
					UPDATE rep_jiedai_history a SET 
						a.till_chargem=a.last_chargem+a.chargem,
						a.till_creditm=a.last_creditm+a.creditm
					WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_begin_date;									
				END;
			END IF;		
		
			SET arg_begin_date = DATE_ADD(arg_begin_date,INTERVAL 1 DAY);
		END;
	END WHILE;			
	
	UPDATE rep_jie a,rep_jie_history b SET
		a.month01=b.month01,a.month02=b.month02,a.month03=b.month03,
		a.month04=b.month04,a.month05=b.month05,a.month06=b.month06,
		a.month07=b.month07,a.month08=b.month08,a.month09=b.month09,a.month99=b.month99
	WHERE a.classno=b.classno 
	AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_end_date
	AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_end_date;
	
	UPDATE rep_dai a,rep_dai_history b SET
		a.credit01m=b.credit01m,a.credit02m=b.credit02m,a.credit03m=b.credit03m,
		a.credit04m=b.credit04m,a.credit05m=b.credit05m,a.credit06m=b.credit06m,
		a.credit07m=b.credit07m,a.sumcrem=b.sumcrem,a.last_blm=b.last_blm,
		a.debitm=b.debitm,a.creditm=b.creditm,a.till_blm=b.till_blm
	WHERE a.classno=b.classno 
	AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_end_date
	AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_end_date;
	
	UPDATE rep_jiedai a,rep_jiedai_history b SET
		a.last_chargem=b.last_chargem,a.last_creditm=b.last_creditm,a.chargem=b.chargem,
		a.creditm=b.creditm,a.applym=b.applym,a.till_chargem=b.till_chargem,a.till_creditm=b.till_creditm
	WHERE a.classno=b.classno 
	AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_end_date
	AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_end_date;	
	
END$$

DELIMITER ;

-- CALL up_ihotel_reb_repjie_month(1,1,'2014-10-30','2014-11-03');

-- DROP PROCEDURE IF EXISTS `up_ihotel_reb_repjie_month`;