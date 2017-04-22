DELIMITER $$

USE `portal`$$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_accnt_checkout`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_accnt_checkout`(
	IN arg_hotel_group_id   INT,
	IN arg_hotel_id     INT,	        
	IN arg_date	DATETIME,
	IN arg_user     VARCHAR(20),
	IN arg_shift    VARCHAR(20),
	IN arg_option	VARCHAR(10)
	)
    SQL SECURITY INVOKER
label_0:
    BEGIN                                                   
	-- =============================================================================
	-- 用途:结账清单 收付实现制
	-- 解释:
	-- 作者:zhangh
	-- =============================================================================	
	DROP TABLE IF EXISTS tmp_checkout;
	CREATE TABLE tmp_checkout
	(
	 close_id		BIGINT(16) 	NOT NULL,
	 biz_date   	DATETIME 	NOT NULL,
	 NAME    		VARCHAR(60) NOT NULL DEFAULT '',	 
	 accnt      	BIGINT(16) 	NOT NULL,
	 rmno			VARCHAR(10) NOT NULL,
	 arrange_code	VARCHAR(6) 	NOT NULL,
	 ta_code   		VARCHAR(10) NOT NULL ,
	 ta_descript	VARCHAR(60) NOT NULL,
	 charge    		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	 pay        	DECIMAL(12,2) NOT NULL DEFAULT '0.00',
	 create_user 	VARCHAR(10) NOT NULL DEFAULT '',
	 cashier     	TINYINT(4) 	DEFAULT NULL,
	 biz_type		VARCHAR(10) NOT NULL DEFAULT '',
	 KEY Index_1(biz_date,accnt,rmno)
	);  
	IF  arg_shift = '' OR arg_shift IS NULL THEN
		SET arg_shift='%';
	END IF;
	IF  arg_user = '' OR arg_user IS NULL THEN 
		SET arg_user='%';
	END IF;
	
	INSERT INTO tmp_checkout
		SELECT b.close_id,b.biz_date,'',b.accnt,b.rmno,b.arrange_code,b.ta_code,b.ta_descript,b.charge,b.pay,b.create_user,b.cashier,'FO'
			FROM account_close a,account b
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id 
			AND a.gen_biz_date=arg_date AND a.close_flag='B' AND b.close_flag='B' 
			AND a.id = b.close_id AND a.gen_cashier LIKE arg_shift AND a.gen_user LIKE arg_user
		UNION ALL
			SELECT b.close_id,b.biz_date,'',b.accnt,b.rmno,b.arrange_code,b.ta_code,b.ta_descript,b.charge,b.pay,b.create_user,b.cashier,'FO'
			FROM account_close a,account_history b
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id 
			AND a.gen_biz_date=arg_date AND a.close_flag='B' AND b.close_flag='B' 
			AND a.id = b.close_id AND a.gen_cashier LIKE arg_shift AND a.gen_user LIKE arg_user
		UNION ALL
			SELECT a.close_id,a.biz_date,'',b.accnt,b.rmno,b.arrange_code,b.ta_code,b.ta_descript,a.charge,a.pay,a.create_user,b.cashier,'AR'
			FROM ar_apply a,ar_detail b
			WHERE a.hotel_group_id = b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.accnt = b.ar_accnt AND a.number = b.ar_number
			AND a.close_id IN (SELECT DISTINCT(id) FROM ar_apply WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND close_flag='B' AND biz_date = arg_date AND cashier LIKE arg_shift AND create_user LIKE arg_user)
		;	
			
	UPDATE tmp_checkout SET arrange_code = '98' WHERE arrange_code = '99' AND arg_user <> '%' AND create_user <> arg_user;
	
	UPDATE tmp_checkout a,master_guest b SET a.name = b.name WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id
		AND a.accnt = b.id AND a.biz_type='FO';
	UPDATE tmp_checkout a,master_guest_history b SET a.name = b.name WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id
		AND a.accnt = b.id AND a.biz_type='FO';
	UPDATE tmp_checkout a,ar_master_guest b SET a.name = b.name WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id
		AND a.accnt = b.id AND a.biz_type='AR';		
		
	DELETE FROM tmp_checkout WHERE accnt=0;
		
	SELECT close_id AS id,accnt,'10消费' AS arrange,ta_code AS taCode,ta_descript AS taDesc,SUM(charge) AS amount,
		rmno,NAME FROM tmp_checkout WHERE arrange_code < '9'
	GROUP BY id,accnt,taCode
	UNION ALL
	SELECT close_id AS id,accnt,'12定金' AS arrange,ta_code AS taCode,ta_descript AS taDesc,SUM(pay) AS amount,
		rmno,NAME FROM tmp_checkout WHERE arrange_code > '9' AND arrange_code='98'
	GROUP BY id,accnt,taCode
	UNION ALL
	SELECT close_id AS id,accnt,'15结账补差' AS arrange,ta_code AS taCode,ta_descript AS taDesc,SUM(pay) AS amount,
		rmno,NAME FROM tmp_checkout WHERE arrange_code > '9' AND arrange_code='99'
	GROUP BY id,accnt,taCode
	ORDER BY id,accnt,taCode;    		
		
	DROP TABLE IF EXISTS tmp_checkout;
             
    END$$

DELIMITER ;