DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_pcashrep_summary`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_pcashrep_summary`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN arg_biz_date			DATETIME
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ========================================================================================
	-- 现金收入表:含前台,会员及餐饮部分分营业点统计
	-- 作者：zhangh
	-- 适用: 标准版	实时查询 采用交叉表形式
	-- A:现金 B:支票 C:国内卡 D: 国外卡 E:贵宾卡 F:代价券 G:内部转账 H:款待 I:宾客账 J:AR账
	-- ========================================================================================
	DECLARE done_cursor INT DEFAULT 0;
	DECLARE var_cat		VARCHAR(4);
	DECLARE var_tacode	VARCHAR(10);
	DECLARE var_paytype	VARCHAR(10);
	DECLARE var_cashier TINYINT(4);
	DECLARE var_cashier_user VARCHAR(20);
	DECLARE var_fee	DECIMAL(12,2);
	
	DROP TEMPORARY TABLE IF EXISTS tmp_rep_pcashrep;	
	CREATE TEMPORARY TABLE tmp_rep_pcashrep (
	  hotel_group_id 	INT  NOT NULL,
	  hotel_id 			INT  NOT NULL,
	  modu_code			VARCHAR(8) NOT NULL,	-- PO FO AR CARD
	  modu_desc			VARCHAR(20) NOT NULL,
	  cashier 			TINYINT(2)  NOT NULL,
	  cashier_desc		VARCHAR(6) NOT NULL,
	  user_code 		VARCHAR(20) NOT NULL,
	  user_desc			VARCHAR(30) NOT NULL,
	  ta_class			VARCHAR(20) NOT NULL,
	  class_desc		VARCHAR(10) NOT NULL,
	  ta_code			VARCHAR(20) NOT NULL,
	  code_desc			VARCHAR(20) NOT NULL,
	  amount			DECIMAL(12,2) NOT NULL DEFAULT '0.00',  
	  KEY Index_1 (hotel_group_id,hotel_id,modu_code,cashier,user_code),
	  KEY Index_2 (hotel_group_id,hotel_id,ta_class,ta_code)
	);	
	
	DELETE FROM tmp_rep_pcashrep WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	-- INSERT INTO tmp_account_fo SELECT * FROM account WHERE 1=2;
	-- INSERT INTO tmp_account_fo SELECT * FROM account WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND arrange_code > '9';
	-- INSERT INTO tmp_account_fo SELECT * FROM account_history WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND arrange_code > '9';
	
	-- 前台 FO
	INSERT INTO tmp_rep_pcashrep(hotel_group_id,hotel_id,modu_code,modu_desc,cashier,cashier_desc,user_code,user_desc,ta_class,class_desc,ta_code,code_desc,amount)
		SELECT a.hotel_group_id,a.hotel_id,'PO','A前台',a.cashier,'',a.create_user,'','','',a.ta_code,a.ta_descript,SUM(a.pay)
			FROM 
			(SELECT * FROM account b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND b.arrange_code > '9'
			 UNION ALL
			 SELECT * FROM account_history c WHERE c.hotel_group_id=arg_hotel_group_id AND c.hotel_id=arg_hotel_id AND c.biz_date=arg_biz_date AND c.arrange_code > '9'			
			) AS a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_biz_date
			GROUP BY a.cashier,a.create_user,a.ta_code HAVING SUM(a.pay)<>0;
						
	-- 应收 AR
	INSERT INTO tmp_rep_pcashrep(hotel_group_id,hotel_id,modu_code,modu_desc,cashier,cashier_desc,user_code,user_desc,ta_class,class_desc,ta_code,code_desc,amount)
		SELECT a.hotel_group_id,a.hotel_id,'AR','B应收',a.cashier,'',a.create_user,'','','',a.ta_code,a.ta_descript,SUM(a.pay+a.pay0)
			FROM
			(SELECT b.hotel_group_id,b.hotel_id,b.biz_date,b.cashier,b.create_user,b.ta_code,b.ta_descript,b.pay,b.pay0 FROM ar_account b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND b.act_tag='A' AND b.arrage_code > 9
			UNION ALL
			SELECT c.hotel_group_id,c.hotel_id,c.biz_date,c.cashier,c.create_user,c.ta_code,c.ta_descript,c.pay,c.pay0 FROM ar_account_history c WHERE c.hotel_group_id=arg_hotel_group_id AND c.hotel_id=arg_hotel_id AND c.biz_date=arg_biz_date AND c.act_tag='A' AND c.arrage_code > 9		
			) AS a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_biz_date
			GROUP BY a.cashier,a.create_user,a.ta_code HAVING SUM(a.pay+a.pay0)<>0;
	
	-- 餐饮 PO
	INSERT INTO tmp_rep_pcashrep(hotel_group_id,hotel_id,modu_code,modu_desc,cashier,cashier_desc,user_code,user_desc,ta_class,class_desc,ta_code,code_desc,amount)
		SELECT a.hotel_group_id,a.hotel_id,CONCAT('PO',b.pos_code),CONCAT('C',b.descript),a.cashier,'',a.puser,'','','',a.code,'',SUM(a.fee)
			FROM pos_dish a,pos_interface_map b
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_biz_date 
				AND a.list_order>=100 AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id 
				AND a.pos_station=b.code AND b.link_type='ta_code' 
			GROUP BY pos_code,cashier,puser,CODE HAVING SUM(a.fee)<>0
			ORDER BY pos_code,cashier,puser,CODE;			
		
	-- 会员 CARD
	INSERT INTO tmp_rep_pcashrep(hotel_group_id,hotel_id,modu_code,modu_desc,cashier,cashier_desc,user_code,user_desc,ta_class,class_desc,ta_code,code_desc,amount)
		SELECT a.hotel_group_id,a.hotel_id,'CARD','D会员卡',a.cashier,'',a.create_user,'','','',a.ta_code,'',SUM(a.pay)
			FROM card_account a
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_biz_date
			GROUP BY a.cashier,a.create_user,a.ta_code HAVING SUM(a.pay)<>0
			ORDER BY a.cashier,a.create_user,a.ta_code;	
	
	-- 更新相关值	
	UPDATE tmp_rep_pcashrep a,code_transaction b SET a.ta_class = b.category_code,a.code_desc = b.descript
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.ta_code=b.code;
	UPDATE tmp_rep_pcashrep a,code_base b SET a.cashier_desc = b.descript
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.cashier = b.code AND b.parent_code='shift';
	UPDATE tmp_rep_pcashrep a,USER b SET a.user_desc = b.name
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.user_code = b.code;
	UPDATE tmp_rep_pcashrep a,code_base b SET a.class_desc = b.descript
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.ta_class = b.code AND b.parent_code='payment_category';

	-- 删除部分付款类别
	DELETE FROM tmp_rep_pcashrep WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND ta_class IN ('H','I','J');		

	SELECT modu_desc,CONCAT(IF(cashier=1,'A',IF(cashier=2,'B',IF(cashier=3,'C','D'))),cashier_desc) cashier_desc,user_desc,CONCAT(ta_class,class_desc) class_desc,SUM(amount) amount FROM tmp_rep_pcashrep
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id
		GROUP BY modu_code,cashier,user_code,ta_class
		ORDER BY modu_desc,cashier_desc,user_code,ta_class;

	DROP TEMPORARY TABLE IF EXISTS tmp_rep_pcashrep;
	

	
END$$

DELIMITER ;