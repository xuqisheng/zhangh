DELIMITER $$

DROP PROCEDURE IF EXISTS `up_pos_biz_hotel_analysis`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_pos_biz_hotel_analysis`(
	IN arg_hotel_group_id	INT,	
	IN arg_hotel_id			INT,
  	IN arg_biz_date			DATETIME
  	)
    SQL SECURITY INVOKER
label_0:
BEGIN

	-- posclient 登录界面统计数据
	-- modify by zhangh 2017.5.15
	
	DECLARE var_hotel_id INT;
    DECLARE done_cursor INT DEFAULT 0 ;
    DECLARE c_cursor CURSOR FOR SELECT id FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND IF(arg_hotel_id=0,1=1,id = arg_hotel_id);
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_cursor = 1;
	
	DROP TEMPORARY TABLE IF EXISTS tmp_pos_master;
	DROP TEMPORARY TABLE IF EXISTS tmp_pos_account;            
	CREATE TEMPORARY TABLE tmp_pos_master  LIKE pos_master ;
	CREATE TEMPORARY TABLE tmp_pos_account LIKE pos_account;
      
	DROP TEMPORARY TABLE IF EXISTS tmp_pos_analysis;
	CREATE TEMPORARY TABLE tmp_pos_analysis (
		`hotel_group_id` 	INT NOT NULL,
		`hotel_id` 			INT NOT NULL,
		`biz_date` 			DATETIME NOT NULL COMMENT '营业日期',
		`code`  			VARCHAR(10) DEFAULT '' COMMENT '营业点代码',
		`number` 			DECIMAL(12,2) DEFAULT '0' COMMENT '开单数',
		`gsts`   			DECIMAL(12,2) DEFAULT '0' COMMENT '就餐人数',
		`charge` 			DECIMAL(12,2) DEFAULT '0' COMMENT '营业收入',
		`gstsAvg` 			DECIMAL(12,2) DEFAULT '0' COMMENT '人均消费',
		`Atran` 			DECIMAL(12,2) DEFAULT '0' COMMENT '现金',
		`Btran` 			DECIMAL(12,2) DEFAULT '0' COMMENT '刷卡',
		`Ctran` 			DECIMAL(12,2) DEFAULT '0' COMMENT '储值卡',
		`Ipmstran`			DECIMAL(12,2) DEFAULT '0' COMMENT '转PMS', 
		`Enttran` 			DECIMAL(12,2) DEFAULT '0' COMMENT '折扣/款待',
		`Othertran` 		DECIMAL(12,2) DEFAULT '0' COMMENT '其他',
		KEY index1 (hotel_group_id,hotel_id,code),
		KEY index2 (hotel_group_id,code)
	  );
	  
	OPEN c_cursor ;
	SET done_cursor = 0 ;	
	FETCH c_cursor INTO var_hotel_id; 	  
	WHILE done_cursor = 0 DO
		BEGIN	  
			
			DELETE FROM tmp_pos_master  WHERE hotel_group_id = arg_hotel_group_id;
			DELETE FROM tmp_pos_account WHERE hotel_group_id = arg_hotel_group_id;
			
			INSERT INTO tmp_pos_master  SELECT * FROM pos_master WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = var_hotel_id AND biz_date = arg_biz_date ;
			INSERT INTO tmp_pos_master  SELECT * FROM pos_master_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = var_hotel_id AND biz_date = arg_biz_date ;

			INSERT INTO tmp_pos_account SELECT * FROM pos_account WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = var_hotel_id AND biz_date = arg_biz_date ;
			INSERT INTO tmp_pos_account SELECT * FROM pos_account_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = var_hotel_id AND biz_date = arg_biz_date ;

			 
			INSERT tmp_pos_analysis (hotel_group_id,hotel_id,biz_date,CODE,number,charge)
			SELECT arg_hotel_group_id,var_hotel_id,arg_biz_date,b.code,IFNULL(COUNT(e.accnt),0) ,IFNULL(SUM(e.charge),0)
			FROM pos_pccode b,tmp_pos_master e WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = var_hotel_id 
				AND e.hotel_group_id = arg_hotel_group_id AND e.hotel_id = var_hotel_id AND e.pccode = b.code GROUP BY b.code;
			
			INSERT tmp_pos_analysis (hotel_group_id,hotel_id,biz_date,CODE,gsts,gstsAvg)
			SELECT arg_hotel_group_id,var_hotel_id,arg_biz_date,b.code,IFNULL(SUM(e.gsts),0),IFNULL(ROUND(SUM(e.charge)/SUM(e.gsts),2),0)
			FROM pos_pccode b,tmp_pos_master e WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = var_hotel_id 
				AND e.hotel_group_id = arg_hotel_group_id AND e.hotel_id = var_hotel_id AND e.pccode = b.code AND e.sta NOT IN ('X','S') GROUP BY b.code;

			INSERT tmp_pos_analysis (hotel_group_id,hotel_id,biz_date,CODE,Atran)
				SELECT arg_hotel_group_id, var_hotel_id,arg_biz_date,d.pccode,IFNULL(SUM(c.credit) ,0)
				FROM tmp_pos_account c,tmp_pos_master d,pos_pccode e,code_transaction f
					WHERE c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = var_hotel_id AND d.hotel_group_id = arg_hotel_group_id AND d.hotel_id = var_hotel_id
						AND e.hotel_group_id = arg_hotel_group_id AND e.hotel_id = var_hotel_id AND f.hotel_group_id = arg_hotel_group_id AND f.hotel_id = var_hotel_id
						AND c.accnt = d.accnt AND c.paycode = f.code AND d.sta = 'O' AND c.sta = 'O' AND c.number = 2 
						AND c.pccode = e.code AND f.category_code = 'A' GROUP BY d.pccode;			 

			INSERT tmp_pos_analysis (hotel_group_id,hotel_id,biz_date,CODE,Btran)
				SELECT arg_hotel_group_id, var_hotel_id,arg_biz_date,d.pccode,IFNULL(SUM(c.credit) ,0)
				FROM tmp_pos_account c,tmp_pos_master d,pos_pccode e,code_transaction f
					WHERE c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = var_hotel_id AND d.hotel_group_id = arg_hotel_group_id AND d.hotel_id = var_hotel_id
						AND e.hotel_group_id = arg_hotel_group_id AND e.hotel_id = var_hotel_id AND f.hotel_group_id = arg_hotel_group_id AND f.hotel_id = var_hotel_id
						AND c.accnt = d.accnt AND c.paycode = f.code AND d.sta = 'O' AND c.sta = 'O' AND c.number = 2 
						AND c.pccode = e.code AND f.category_code IN ('C','D') GROUP BY d.pccode;

			INSERT tmp_pos_analysis (hotel_group_id,hotel_id,biz_date,CODE,Ctran)
				SELECT arg_hotel_group_id, var_hotel_id,arg_biz_date,d.pccode,IFNULL(SUM(c.credit) ,0)
				FROM tmp_pos_account c,tmp_pos_master d,pos_pccode e,code_transaction f
					WHERE c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = var_hotel_id AND d.hotel_group_id = arg_hotel_group_id AND d.hotel_id = var_hotel_id
						AND e.hotel_group_id = arg_hotel_group_id AND e.hotel_id = var_hotel_id AND f.hotel_group_id = arg_hotel_group_id AND f.hotel_id = var_hotel_id
						AND c.accnt = d.accnt AND c.paycode = f.code AND d.sta = 'O' AND c.sta = 'O' AND c.number = 2 
						AND c.pccode = e.code AND f.category_code = 'E' GROUP BY d.pccode;

			INSERT tmp_pos_analysis (hotel_group_id,hotel_id,biz_date,CODE,Ipmstran)
				SELECT arg_hotel_group_id, var_hotel_id,arg_biz_date,d.pccode,IFNULL(SUM(c.credit) ,0)
				FROM tmp_pos_account c,tmp_pos_master d,pos_pccode e,code_transaction f
					WHERE c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = var_hotel_id AND d.hotel_group_id = arg_hotel_group_id AND d.hotel_id = var_hotel_id
						AND e.hotel_group_id = arg_hotel_group_id AND e.hotel_id = var_hotel_id AND f.hotel_group_id = arg_hotel_group_id AND f.hotel_id = var_hotel_id
						AND c.accnt = d.accnt AND c.paycode = f.code AND d.sta = 'O' AND c.sta = 'O' AND c.number = 2 
						AND c.pccode = e.code AND f.category_code IN ('I','J') GROUP BY d.pccode;

			INSERT tmp_pos_analysis (hotel_group_id,hotel_id,biz_date,CODE,Enttran)
				SELECT arg_hotel_group_id, var_hotel_id,arg_biz_date,d.pccode,IFNULL(SUM(c.credit) ,0)
				FROM tmp_pos_account c,tmp_pos_master d,pos_pccode e,code_transaction f
					WHERE c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = var_hotel_id AND d.hotel_group_id = arg_hotel_group_id AND d.hotel_id = var_hotel_id
						AND e.hotel_group_id = arg_hotel_group_id AND e.hotel_id = var_hotel_id AND f.hotel_group_id = arg_hotel_group_id AND f.hotel_id = var_hotel_id
						AND c.accnt = d.accnt AND c.paycode = f.code AND d.sta = 'O' AND c.sta = 'O' AND c.number = 2 
						AND c.pccode = e.code AND f.category_code = 'H' GROUP BY d.pccode;

			INSERT tmp_pos_analysis (hotel_group_id,hotel_id,biz_date,CODE,Othertran)
				SELECT arg_hotel_group_id, var_hotel_id,arg_biz_date,d.pccode,IFNULL(SUM(c.credit) ,0)
				FROM tmp_pos_account c,tmp_pos_master d,pos_pccode e,code_transaction f
					WHERE c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = var_hotel_id AND d.hotel_group_id = arg_hotel_group_id AND d.hotel_id = var_hotel_id
						AND e.hotel_group_id = arg_hotel_group_id AND e.hotel_id = var_hotel_id AND f.hotel_group_id = arg_hotel_group_id AND f.hotel_id = var_hotel_id
						AND c.accnt = d.accnt AND c.paycode = f.code AND d.sta = 'O' AND c.sta = 'O' AND c.number = 2 
						AND c.pccode = e.code AND f.category_code NOT IN ('A','C','D','E','I','J','H') GROUP BY d.pccode;	  

		SET done_cursor = 0 ;
		FETCH c_cursor INTO var_hotel_id;  
		END ;
	END WHILE ;
	CLOSE c_cursor;

	SELECT b.descript,SUM(a.number),SUM(a.gsts),SUM(charge),IFNULL(ROUND(SUM(charge)/SUM(a.gsts),2),0),SUM(Atran),SUM(Btran),SUM(Ctran),SUM(Ipmstran),SUM(Enttran),SUM(Othertran) 
	FROM tmp_pos_analysis a,pos_pccode b WHERE a.hotel_group_id = arg_hotel_group_id AND IF(arg_hotel_id=0,1=1,a.hotel_id = arg_hotel_id) AND b.hotel_group_id = arg_hotel_group_id 
		AND IF(arg_hotel_id=0,1=1,b.hotel_id = arg_hotel_id) AND a.code = b.code GROUP BY b.code ORDER BY b.code;

	DROP TEMPORARY TABLE IF EXISTS tmp_pos_master;
	DROP TEMPORARY TABLE IF EXISTS tmp_pos_account;
	DROP TEMPORARY TABLE IF EXISTS tmp_pos_analysis;
	
END$$

DELIMITER ;