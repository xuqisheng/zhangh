DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_jiedai_patch`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_jiedai_patch`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT,
	IN arg_model_date		DATETIME,
	IN arg_date_begin		DATETIME,
	IN arg_date_end			DATETIME
    )	
	SQL SECURITY INVOKER
label_0:
BEGIN 
	-- ============================================================================================
	-- 用途:底表三张表补数据,以某一天为模板补底表某段时间数据,用于直接修改营业日期造成数据丢失		
	-- 解释:CALL up_ihotel_rep_jiedai_patch(1,15,'2015-2-25','2015-2-26','2015-3-25');
	-- 作者:张惠
	-- ============================================================================================
	
	WHILE arg_date_begin <= arg_date_end DO
		BEGIN
		-- 	rep_jie 和 rep_jie_history
		DELETE FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_date_begin;
			
		INSERT INTO rep_jie(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,rectype,toop,
			toclass,sequence,day01,day02,day03,day04,day05,day06,day07,day08,day09,day99,
			month01,month02,month03,month04,month05,month06,month07,month08,month09,month99)
		SELECT hotel_group_id,hotel_id,arg_date_begin,orderno,itemno,modeno,classno,descript,descript1,rectype,toop,
			toclass,sequence,day01,day02,day03,day04,day05,day06,day07,day08,day09,day99,
			month01,month02,month03,month04,month05,month06,month07,month08,month09,month99
		FROM rep_jie_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_model_date;
		
		INSERT INTO rep_jie_history SELECT * FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_date_begin;		
		DELETE FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_date_begin;		
			
		-- rep_dai 和 rep_dai_history
		DELETE FROM rep_dai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_date_begin;
			
		INSERT INTO rep_dai(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence,
			credit01,credit02,credit03,credit04,credit05,credit06,credit07,sumcre,last_bl,debit,credit,till_bl,
			credit01m,credit02m,credit03m,credit04m,credit05m,credit06m,credit07m,sumcrem,last_blm,debitm,creditm,till_blm)
		SELECT hotel_group_id,hotel_id,arg_date_begin,orderno,itemno,modeno,classno,descript,descript1,sequence,
			credit01,credit02,credit03,credit04,credit05,credit06,credit07,sumcre,last_bl,debit,credit,till_bl,
			credit01m,credit02m,credit03m,credit04m,credit05m,credit06m,credit07m,sumcrem,last_blm,debitm,creditm,till_blm
		FROM rep_dai_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_model_date;
		
		INSERT INTO rep_dai_history SELECT * FROM rep_dai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_date_begin;		
		DELETE FROM rep_dai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_date_begin;		
				
		-- rep_jiedai 和 rep_jiedai_history
		DELETE FROM rep_jiedai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_date_begin;
			
		INSERT INTO rep_jiedai(hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,sequence,
			last_charge,last_credit,charge,credit,apply,till_charge,till_credit,last_chargem,last_creditm,chargem,
			creditm,applym,till_chargem,till_creditm)
		SELECT hotel_group_id,hotel_id,arg_date_begin,orderno,itemno,modeno,classno,descript,descript1,sequence,
		last_charge,last_credit,charge,credit,apply,till_charge,till_credit,last_chargem,last_creditm,chargem,
			creditm,applym,till_chargem,till_creditm
		FROM rep_jiedai_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_model_date;
		
		INSERT INTO rep_jiedai_history SELECT * FROM rep_jiedai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_date_begin;		
		DELETE FROM rep_jiedai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_date_begin;				
		
		SET arg_date_begin = ADDDATE(arg_date_begin,1);				
		END;
		
	END WHILE;			
		
END$$

DELIMITER ; 

CALL up_ihotel_rep_jiedai_patch(1,15,'2015-2-25','2015-2-26','2015-3-25');

DROP PROCEDURE IF EXISTS `up_ihotel_rep_jiedai_patch`;