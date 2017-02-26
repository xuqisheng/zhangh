DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_ar_list`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_ar_list`(
	IN arg_hotel_group_id   INT,
	IN arg_hotel_id         INT,
	IN arg_date_begin		DATETIME,
	IN arg_date_end			DATETIME,
	IN arg_user         	VARCHAR(20),
	IN arg_shift        	VARCHAR(20),
	IN arg_mode				VARCHAR(10)
	)
    SQL SECURITY INVOKER
label_0:
    BEGIN
	-- =============================================================================
	-- 用途:前台和餐饮挂AR账明细表
	-- 解释:
	-- 作者:张惠
	-- =============================================================================	
		DROP TEMPORARY TABLE IF EXISTS tmp_ar_list;
		CREATE TEMPORARY TABLE tmp_ar_list
		(
			hotel_group_id		INT,
			hotel_id			INT,
			accnt      			BIGINT(16) NOT NULL,
			number				INT(11) NOT NULL,
			modu_code			VARCHAR(10) NOT NULL,
			biz_date  			DATETIME,
			gen_date  			DATETIME,
			create_datetime		DATETIME,
			arrange_code		VARCHAR(10) NOT NULL,
			ta_code   			VARCHAR(10) NOT NULL,
			ta_descript 		VARCHAR(60) NOT NULL,
			charge     			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			pay        			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			create_user 		VARCHAR(10) NOT NULL DEFAULT '',
			cashier     		TINYINT(4)  DEFAULT NULL,
			act_flag    		VARCHAR(10) NOT NULL DEFAULT '',
			ta_remark  			VARCHAR(20) NOT NULL DEFAULT '',
			rmno        		VARCHAR(10) NOT NULL DEFAULT '',
			trans_accnt			BIGINT(16),
			NAME	       		VARCHAR(50) NOT NULL DEFAULT '',
			arname	       		VARCHAR(50) NOT NULL DEFAULT '',
			accnt_type			VARCHAR(10) NOT NULL DEFAULT '',
			KEY index1 (hotel_group_id,hotel_id,trans_accnt),
			KEY index2 (hotel_group_id,hotel_id,accnt_type),
			KEY index3 (hotel_group_id,hotel_id,accnt)
		);      
		IF  arg_shift = '' OR arg_shift IS NULL THEN
			SET arg_shift='%';
		END IF;
		IF  arg_user = '' OR arg_user IS NULL THEN 
			SET arg_user='%';
		END IF;
		
		IF arg_mode = 'FRONT' THEN
			BEGIN
				INSERT INTO tmp_ar_list(hotel_group_id,hotel_id,accnt,number,modu_code,biz_date,gen_date,create_datetime,arrange_code,
					ta_code,ta_descript,charge,pay,create_user,cashier,act_flag,ta_remark,rmno,trans_accnt,NAME,arname,accnt_type)
				SELECT hotel_group_id,hotel_id,accnt,number,modu_code,biz_date,gen_date,create_datetime,arrange_code,
					ta_code,ta_descript,charge,pay,create_user,cashier,act_flag,ta_remark,rmno,trans_accnt,'','','FO'
				FROM account WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date >= arg_date_begin AND biz_date <= arg_date_end AND cashier LIKE arg_shift AND create_user LIKE arg_user AND ta_code IN (SELECT CODE FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND cat_posting='TA')
				UNION ALL
				SELECT hotel_group_id,hotel_id,accnt,number,modu_code,biz_date,gen_date,create_datetime,arrange_code,
					ta_code,ta_descript,charge,pay,create_user,cashier,act_flag,ta_remark,rmno,trans_accnt,'','','H_FO'
				FROM account_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date >= arg_date_begin AND biz_date <= arg_date_end AND cashier LIKE arg_shift AND create_user LIKE arg_user AND ta_code IN (SELECT CODE FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND cat_posting='TA');
			
				UPDATE tmp_ar_list a,master_guest b SET a.name = b.name 
					WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.accnt_type = 'FO' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.accnt = b.id ;
				UPDATE tmp_ar_list a,master_guest_history b SET a.name=b.name 
					WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.accnt_type = 'H_FO' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id  AND a.accnt = b.id;
				UPDATE tmp_ar_list a,ar_master_guest b SET a.arname = b.name
					WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.trans_accnt=b.id;		
			END;
		END IF;
		
		IF arg_mode = 'POS' THEN
			BEGIN
				INSERT INTO tmp_ar_list(hotel_group_id,hotel_id,accnt,number,modu_code,biz_date,gen_date,create_datetime,arrange_code,
					ta_code,ta_descript,charge,pay,create_user,cashier,act_flag,ta_remark,rmno,trans_accnt,NAME,arname,accnt_type)
				SELECT a.hotel_group_id,a.hotel_id,a.menu_id,a.inumber,'04',a.biz_date,a.biz_date,a.create_datetime,'',
					a.code,a.descript,0,SUM(a.fee),a.puser,a.cashier,'',b.menu_no,a.pos_station,a.accnt,'','',''
					FROM pos_dish a,pos_menu b WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.menu_id=b.id AND a.biz_date=b.biz_date AND a.biz_date >= arg_date_begin AND a.biz_date <= arg_date_end AND a.cashier LIKE arg_shift AND a.puser LIKE arg_user AND a.code IN (SELECT CODE FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND cat_posting='TA')
					GROUP BY a.biz_date,a.menu_id;
		
				UPDATE tmp_ar_list a,ar_master_guest b SET a.arname = b.name
					WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.trans_accnt=b.id;
				
				UPDATE tmp_ar_list a,pos_interface_map b SET a.name = b.descript
					WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.link_type='ta_code' AND a.rmno=b.code;		
			END;
		END IF;
		
		IF arg_mode = 'ALL' THEN
			BEGIN
		
				INSERT INTO tmp_ar_list(hotel_group_id,hotel_id,accnt,number,modu_code,biz_date,gen_date,create_datetime,arrange_code,
					ta_code,ta_descript,charge,pay,create_user,cashier,act_flag,ta_remark,rmno,trans_accnt,NAME,arname,accnt_type)
				SELECT hotel_group_id,hotel_id,accnt,number,modu_code,biz_date,gen_date,create_datetime,arrange_code,
					ta_code,ta_descript,charge,pay,create_user,cashier,act_flag,ta_remark,rmno,trans_accnt,'','','FO'
				FROM account WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date >= arg_date_begin AND biz_date <= arg_date_end AND cashier LIKE arg_shift AND create_user LIKE arg_user AND ta_code IN (SELECT CODE FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND cat_posting='TA')
				UNION ALL
				SELECT hotel_group_id,hotel_id,accnt,number,modu_code,biz_date,gen_date,create_datetime,arrange_code,
					ta_code,ta_descript,charge,pay,create_user,cashier,act_flag,ta_remark,rmno,trans_accnt,'','','H_FO'
				FROM account_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date >= arg_date_begin AND biz_date <= arg_date_end AND cashier LIKE arg_shift AND create_user LIKE arg_user AND ta_code IN (SELECT CODE FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND cat_posting='TA');
			
				UPDATE tmp_ar_list a,master_guest b SET a.name = b.name 
					WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.accnt_type = 'FO' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.accnt = b.id ;
				UPDATE tmp_ar_list a,master_guest_history b SET a.name=b.name 
					WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.accnt_type = 'H_FO' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id  AND a.accnt = b.id;
				UPDATE tmp_ar_list a,ar_master_guest b SET a.arname = b.name
					WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.trans_accnt=b.id;		
		
		
				INSERT INTO tmp_ar_list(hotel_group_id,hotel_id,accnt,number,modu_code,biz_date,gen_date,create_datetime,arrange_code,
					ta_code,ta_descript,charge,pay,create_user,cashier,act_flag,ta_remark,rmno,trans_accnt,NAME,arname,accnt_type)
				SELECT a.hotel_group_id,a.hotel_id,a.menu_id,a.inumber,'04',a.biz_date,a.biz_date,a.create_datetime,'',
					a.code,a.descript,0,SUM(a.fee),a.puser,a.cashier,'',b.menu_no,a.pos_station,a.accnt,'','','POS'
					FROM pos_dish a,pos_menu b WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.menu_id=b.id AND a.biz_date=b.biz_date AND a.biz_date >= arg_date_begin AND a.biz_date <= arg_date_end AND a.cashier LIKE arg_shift AND a.puser LIKE arg_user AND a.code IN (SELECT CODE FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND cat_posting='TA')
					GROUP BY a.biz_date,a.menu_id;
		
				UPDATE tmp_ar_list a,ar_master_guest b SET a.arname = b.name
					WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.accnt_type = 'POS' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.trans_accnt=b.id;
				
				UPDATE tmp_ar_list a,pos_interface_map b SET a.name = b.descript
					WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.accnt_type = 'POS' AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.link_type='ta_code' AND a.rmno=b.code;		
			END;
		END IF;		
		
		SELECT trans_accnt,arname,IF(rmno<>'',rmno,'团队主单') AS rmno,accnt,NAME,pay,ta_remark,create_datetime,biz_date,create_user,cashier FROM tmp_ar_list WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id ORDER BY trans_accnt,biz_date;	
   		
		DROP TEMPORARY TABLE IF EXISTS tmp_ar_list;
    END$$

DELIMITER ;