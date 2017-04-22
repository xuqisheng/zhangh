DELIMITER $$

USE `portal`$$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_account_payout`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_account_payout`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN arg_biz_date			DATETIME,
	IN arg_user     		VARCHAR(20),
	IN arg_shift    		VARCHAR(20)	
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ==========================================
	-- 用途:前台缴款单
	-- 解释:
	-- modify 张晓斌 2015.5.17
	-- ==========================================		
	DECLARE var_tacode1		VARCHAR(10);	
	DECLARE var_tacode2		VARCHAR(10);
	DECLARE var_tacodedes1		VARCHAR(50);	
	DECLARE var_tacodedes2		VARCHAR(50);	
	
	DROP TEMPORARY TABLE IF EXISTS temp_apportion_detail;
	CREATE TEMPORARY TABLE temp_apportion_detail (
		hotel_group_id 		INT,
		hotel_id 		INT(16),
		biz_date 		DATETIME,
 		close_flag 		CHAR(2) NOT NULL,
		close_id 		BIGINT(16) NOT NULL,
		apportion_amount 	DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		ta_code1 		VARCHAR(10) NOT NULL,
		ta_descript1 		VARCHAR(60) NOT NULL,
		accnt1 			BIGINT(16) NOT NULL,
 		ta_code2 		VARCHAR(10) NOT NULL,
		ta_descript2 		VARCHAR(60) NOT NULL,
		billno		    	VARCHAR(16) NOT NULL DEFAULT '',
		deptno			VARCHAR(5),
		deptno_des		VARCHAR(10),
  		tag			INT DEFAULT 1,
		KEY Index_1 (hotel_group_id,hotel_id,biz_date,ta_code1,ta_code2),
		KEY Index_2 (hotel_group_id,hotel_id,biz_date,ta_code2,ta_code1),
		KEY Index_3 (hotel_group_id,hotel_id,biz_date,ta_code1)
	);
	
	DROP TEMPORARY TABLE IF EXISTS temp_apportion_detail2;
	CREATE TEMPORARY TABLE temp_apportion_detail2 (
		hotel_group_id 	INT,
		hotel_id 		INT(16),
		biz_date 		DATETIME,
 		close_flag 		CHAR(2) NOT NULL,
		close_id 		BIGINT(16) NOT NULL,
		apportion_amount 	DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		ta_code1 		VARCHAR(10) NOT NULL,
		ta_descript1 		VARCHAR(60) NOT NULL,
		accnt1 			BIGINT(16) NOT NULL,
 		ta_code2 		VARCHAR(10) NOT NULL,
		ta_descript2 		VARCHAR(60) NOT NULL,
		billno		    	VARCHAR(16) NOT NULL DEFAULT '', 
		deptno			VARCHAR(5),
		deptno_des		VARCHAR(10),
  		tag			INT DEFAULT 1,
		KEY Index_1 (hotel_group_id,hotel_id,biz_date,ta_code1,ta_code2),
		KEY Index_2 (hotel_group_id,hotel_id,biz_date,ta_code2,ta_code1),
		KEY Index_3 (hotel_group_id,hotel_id,biz_date,ta_code1)
	);
			
	DROP TEMPORARY TABLE IF EXISTS tmp_account_pay;
	CREATE TEMPORARY TABLE tmp_account_pay(
		biz_type	CHAR(1),
		biz_date	DATETIME,
		pay_code	VARCHAR(10),
		pay_des		VARCHAR(15),
 		deptno		VARCHAR(10),
		deptno_des	VARCHAR(15),
		charge 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		billno	        VARCHAR(16)   NOT NULL DEFAULT '', 
		amount		DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		amount1		DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		remark		VARCHAR(50)   NOT NULL DEFAULT '',
		KEY index1(biz_date,pay_code,deptno)		  		
	);
	
	DROP TEMPORARY TABLE IF EXISTS tmp_account_pay1;
	CREATE TEMPORARY TABLE tmp_account_pay1(
		biz_type	CHAR(1),
		biz_date	DATETIME,
		pay_code	VARCHAR(10),
		pay_des		VARCHAR(15),
 		deptno		VARCHAR(10),
		deptno_des	VARCHAR(15),
		charge 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		billno	        VARCHAR(16) NOT NULL DEFAULT '', 
		amount		DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		amount1		DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		remark		VARCHAR(50)   NOT NULL DEFAULT '',
		KEY index1(biz_date,pay_code,deptno)		  		
	);
	DROP TEMPORARY TABLE IF EXISTS tmp_account_pay2;
	CREATE TEMPORARY TABLE tmp_account_pay2(
		biz_type	CHAR(1),
		biz_date	DATETIME,
		pay_code	VARCHAR(10),
		pay_des		VARCHAR(15),
 		deptno		VARCHAR(10),
		deptno_des	VARCHAR(15),
		charge 		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		billno	        VARCHAR(16) NOT NULL DEFAULT '', 
		amount		DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		amount1		DECIMAL(12,2) NOT NULL DEFAULT 0.00,
		remark		VARCHAR(50)   NOT NULL DEFAULT '',
		KEY index1(biz_date,pay_code,deptno)		  		
	);
 	DROP TEMPORARY TABLE IF EXISTS tmp_account1;
	CREATE TEMPORARY TABLE tmp_account1 (
		id              	BIGINT(16) NOT NULL AUTO_INCREMENT,
		biz_type 		VARCHAR(8) NOT NULL, 
		accnt 			BIGINT(16) NOT NULL,
		number 			INT NOT NULL DEFAULT 0,
		ta_code 		VARCHAR(10) NOT NULL,
		ta_order 		INT(10) NOT NULL,
		arrange_code 		VARCHAR(10) NOT NULL,
		charge 			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		pay 			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		act_flag    		VARCHAR(10) NOT NULL DEFAULT '',
		trans_flag		CHAR(2),
		market 			VARCHAR(10) NOT NULL DEFAULT '',
		ta_descript 		VARCHAR(60) NOT NULL,
		rmno 			VARCHAR(10) NOT NULL DEFAULT '',
		grp_accnt 		BIGINT(16) DEFAULT '0',
		close_flag 		CHAR(2) NOT NULL DEFAULT '',
		close_id 		BIGINT(16) NOT NULL,
		billno 			VARCHAR(16) NOT NULL DEFAULT '',  
		billno_dc 		VARCHAR(2) NOT NULL ,  
		billno_rec 		INT(10) DEFAULT 0,
		billno_amount 		DECIMAL(12,2) DEFAULT 0,
		tag			INT DEFAULT 1,
		PRIMARY KEY (id),
		KEY Index_1 (billno, billno_dc,id),
		KEY Index_2 (billno_rec)
	);
	
	DROP TEMPORARY TABLE IF EXISTS tmp_account2;
	CREATE TEMPORARY TABLE tmp_account2 (
		id              	BIGINT(16) NOT NULL AUTO_INCREMENT,
		biz_type 		VARCHAR(8) NOT NULL, 
		accnt 			BIGINT(16) NOT NULL,
		number 			INT NOT NULL DEFAULT 0,
		ta_code 		VARCHAR(10) NOT NULL,
		ta_order 		INT(10) NOT NULL,
		arrange_code 		VARCHAR(10) NOT NULL,
		charge 			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		pay 			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		act_flag    		VARCHAR(10) NOT NULL DEFAULT '',
		trans_flag		CHAR(2),
		market 			VARCHAR(10) NOT NULL DEFAULT '',
		ta_descript 		VARCHAR(60) NOT NULL,
		rmno 			VARCHAR(10) NOT NULL DEFAULT '',
		grp_accnt 		BIGINT(16) DEFAULT '0',
		close_flag 		CHAR(2) NOT NULL DEFAULT '',
		close_id 		BIGINT(16) NOT NULL,
		billno 			VARCHAR(16) NOT NULL DEFAULT '',  
		billno_dc 		VARCHAR(2) NOT NULL ,  
		billno_rec 		INT(10) DEFAULT 0,
		billno_amount 		DECIMAL(12,2) DEFAULT 0,
		tag			INT DEFAULT 1,
		PRIMARY KEY (id),
		KEY Index_1 (billno, billno_dc,id),
		KEY Index_2 (billno_rec)
	);
	DROP TEMPORARY TABLE IF EXISTS tmp_billno;
	CREATE TEMPORARY TABLE tmp_billno (
		billno 		VARCHAR(16) NOT NULL DEFAULT '',  
		billno_rec 		INT(10) DEFAULT 0,
		billno_amount 	DECIMAL(12,2) DEFAULT 0,
		KEY Index_1 (billno)
	);
	DROP TEMPORARY TABLE IF EXISTS tmp_apportion;
	CREATE TEMPORARY TABLE tmp_apportion(
		biz_date            DATETIME NOT NULL,
		biz_type            VARCHAR(10) NOT NULL,
		modu_code           VARCHAR(10) NOT NULL,
		close_flag          CHAR(2) NOT NULL DEFAULT '',
		close_id            BIGINT(16) NOT NULL,
		apportion_amount    DECIMAL(12,2) NOT NULL DEFAULT 0,
		ta_code1            VARCHAR(10) NOT NULL,
		ta_descript1        VARCHAR(60) NOT NULL,
		accnt1              BIGINT(16) NOT NULL,
		number1             INT NOT NULL DEFAULT 0,
		ta_code2            VARCHAR(10) NOT NULL,
		ta_descript2        VARCHAR(60) NOT NULL,
		accnt2              BIGINT(16) NOT NULL,
		number2             INT NOT NULL DEFAULT 0,
		market              VARCHAR(10) NOT NULL DEFAULT '',
		billno		    VARCHAR(16) NOT NULL,
		ta_order1 	    INT(10) NOT NULL,
		ta_order2 	    INT(10) NOT NULL,
		charge 		    DECIMAL(12,2) NOT NULL,
		pay 		    DECIMAL(12,2) NOT NULL,
		billno_rec 	    INT(10) NOT NULL,
		billno_amount 	    DECIMAL(12,2) NOT NULL,
		tag		    INT DEFAULT 1,
		KEY index1 (biz_date,biz_type,close_id)
	);
	IF  arg_shift = '' OR arg_shift IS NULL THEN
		SET arg_shift='%';
	END IF;
	IF  arg_user = '' OR arg_user IS NULL THEN 
		SET arg_user='%';
	END IF;
	
	-- 前台
	INSERT tmp_account1(biz_type,accnt,number,ta_code,ta_order,arrange_code,charge,pay,market,
			ta_descript,rmno,grp_accnt,billno,billno_dc,billno_rec,close_flag,close_id)
		SELECT 'FO',a.accnt,a.number,a.ta_code,0,a.arrange_code,a.charge,a.pay,a.market,
			a.ta_descript,a.rmno,a.grp_accnt,CONCAT('FO', CONVERT(a.close_id, UNSIGNED)),'d',0,a.close_flag,a.close_id
		FROM account a, account_close b 
		WHERE a.close_flag='B' AND b.close_flag='B' AND a.close_id=b.id AND b.gen_biz_date = arg_biz_date 
			AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.gen_cashier LIKE arg_shift
			AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.gen_user LIKE arg_user 
		UNION ALL
		SELECT 'FO', a.accnt,a.number,a.ta_code,0,a.arrange_code,a.charge,a.pay,a.market,
			a.ta_descript,a.rmno,a.grp_accnt,CONCAT('FO', CONVERT(a.close_id, UNSIGNED)),'d',0,a.close_flag,a.close_id
		FROM account_history a, account_close b 
		WHERE a.close_flag='B' AND b.close_flag='B' AND a.close_id=b.id AND b.gen_biz_date=arg_biz_date 
			AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.gen_cashier LIKE arg_shift
			AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.gen_user LIKE arg_user; 
	
-- 	-- 餐饮
-- 	INSERT tmp_account1(biz_type,accnt,number,ta_code,ta_order,arrange_code,charge,pay,market,
-- 			ta_descript,rmno,grp_accnt,billno,billno_dc,billno_rec,close_flag,close_id)
-- 		SELECT 'PO', a.menu_id, 1, a.code, 0, b.arrange_code, IF(b.arrange_code<'9', a.fee, 0), IF(b.arrange_code<'9', 0, a.fee), '',
-- 			a.descript, '', 0, CONVERT(a.menu_id, CHAR(20)), 'd', 0, 'b', a.menu_id
-- 		FROM pos_dish a 
-- 			LEFT JOIN code_transaction b ON b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.code=b.code 
-- 		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_biz_date AND a.cashier LIKE arg_shift AND a.puser LIKE arg_user;
-- 
	-- AR
	INSERT tmp_account1(biz_type,accnt,number,ta_code,ta_order,arrange_code,charge,pay,market,
			ta_descript,rmno,grp_accnt,billno,billno_dc,billno_rec,close_flag,close_id)	 
	SELECT 'AR',b.accnt,b.number,b.ta_code,0,b.arrange_code,a.charge,a.pay,b.market,b.ta_descript,
			b.rmno,b.grp_accnt,CONCAT('AR', CONVERT(a.close_id, UNSIGNED)),'d',0,'b',a.close_id
	FROM ar_apply a,ar_detail b
	WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id=arg_hotel_id 
	AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id 
	AND a.accnt = b.ar_accnt AND a.number = b.ar_number 
	AND a.close_id IN (SELECT DISTINCT(id) FROM ar_apply WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND close_flag='B' AND biz_date = arg_biz_date AND cashier LIKE arg_shift AND create_user LIKE arg_user);
	 	 
	UPDATE tmp_account1 a,code_transaction b SET a.arrange_code = b.arrange_code WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.biz_type = 'AR' AND b.code = a.ta_code AND b.arrange_code < '9';
	
	DELETE FROM tmp_account1 WHERE ta_code='9'; 
	DELETE FROM tmp_account1 WHERE charge=0 AND pay=0;
	UPDATE tmp_account1 SET billno_dc='c' WHERE arrange_code>='9';
	
	INSERT tmp_billno (billno, billno_rec, billno_amount)
		SELECT CONCAT(billno,billno_dc), COUNT(1), SUM(charge+pay) FROM tmp_account1 GROUP BY CONCAT(billno,billno_dc); 
	UPDATE tmp_account1 a, tmp_billno b SET a.billno_rec = b.billno_rec, a.billno_amount = b.billno_amount
		WHERE CONCAT(a.billno,a.billno_dc)=b.billno;
 
 	UPDATE tmp_account1 SET ta_order=1 WHERE billno_rec=1 ; 
	INSERT tmp_account2 SELECT * FROM tmp_account1; 
	UPDATE tmp_account1 a
		SET a.ta_order=(SELECT COUNT(b.id) FROM (SELECT * FROM tmp_account2 c WHERE c.billno_dc='d') b 
							WHERE a.billno=b.billno AND b.id<=a.id)
	WHERE a.billno_dc='d'; 
	UPDATE tmp_account1 a
		SET a.ta_order=(SELECT COUNT(b.id) FROM (SELECT * FROM tmp_account2 c WHERE c.billno_dc='c') b 
							WHERE a.billno=b.billno AND b.id<=a.id)
	WHERE a.billno_dc='c';	
	
	DELETE FROM tmp_account2; 
	INSERT tmp_account2 SELECT * FROM tmp_account1 WHERE billno_dc='c'; 
	DELETE FROM tmp_account1 WHERE billno_dc='c';
	INSERT tmp_apportion (biz_date,biz_type,modu_code,close_flag,close_id,apportion_amount,ta_code1,ta_descript1,accnt1,number1,
				ta_code2,ta_descript2,accnt2,number2,market,billno,ta_order1,ta_order2,charge,pay,billno_rec,billno_amount)
		SELECT arg_biz_date,a.biz_type,'02',a.close_flag,a.close_id,0,a.ta_code,a.ta_descript,a.accnt,a.number,
				b.ta_code,b.ta_descript,b.accnt,b.number,a.market,a.billno,a.ta_order,b.ta_order,a.charge,b.pay,a.billno_rec,a.billno_amount
			FROM tmp_account1 a, tmp_account2 b WHERE a.billno=b.billno;	
	
	
	UPDATE tmp_apportion SET apportion_amount=ROUND(pay*charge/billno_amount,2);  
 
	DELETE FROM tmp_billno; 
	INSERT tmp_billno(billno, billno_rec, billno_amount) 
		SELECT billno, ta_order2, SUM(apportion_amount) FROM tmp_apportion GROUP BY billno, ta_order2; 
	UPDATE tmp_apportion a, tmp_billno b SET a.apportion_amount=a.apportion_amount + (a.pay - b.billno_amount)   
		WHERE a.billno=b.billno AND a.ta_order1=a.billno_rec AND a.ta_order2=b.billno_rec;
	
	SELECT MIN(CODE) INTO var_tacode1 FROM code_transaction WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arrange_code<'9';
	SELECT MIN(CODE) INTO var_tacode2 FROM code_transaction WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arrange_code>='9';
	SELECT descript INTO var_tacodedes1 FROM code_transaction WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND CODE=var_tacode1;
	SELECT descript INTO var_tacodedes2 FROM code_transaction WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND CODE=var_tacode2;	
	
	INSERT tmp_apportion (biz_date,biz_type,modu_code,close_flag,close_id,apportion_amount,ta_code1,ta_descript1,accnt1,number1,
				ta_code2,ta_descript2,accnt2,number2,market,billno,ta_order1,ta_order2,charge,pay,billno_rec,billno_amount)
		SELECT arg_biz_date,a.biz_type,'02',a.close_flag,a.close_id,a.charge,a.ta_code,a.ta_descript,a.accnt,a.number,
				var_tacode2,var_tacodedes2,a.accnt,0,a.market,a.billno,a.ta_order,0,a.charge,a.charge,a.billno_rec,a.billno_amount
			FROM tmp_account1 a WHERE NOT EXISTS(SELECT 1 FROM tmp_account2 b WHERE a.billno=b.billno); 
	INSERT tmp_apportion (biz_date,biz_type,modu_code,close_flag,close_id,apportion_amount,ta_code1,ta_descript1,accnt1,number1,
				ta_code2,ta_descript2,accnt2,number2,market,billno,ta_order1,ta_order2,charge,pay,billno_rec,billno_amount)
		SELECT arg_biz_date,b.biz_type,'02',b.close_flag,b.close_id,b.pay,var_tacode1,var_tacodedes1,b.accnt,0,
				b.ta_code,b.ta_descript,b.accnt,b.number,b.market,b.billno,b.ta_order,b.ta_order,b.pay,b.pay,b.billno_rec,b.billno_amount
			FROM tmp_account2 b WHERE NOT EXISTS(SELECT 1 FROM tmp_account1 a WHERE a.billno=b.billno); 
  	
  	
 	UPDATE 	tmp_apportion a,code_transaction b SET a.ta_code2 = '9000',ta_descript2 = '人民币现金' WHERE a.ta_code2 = b.code
		AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.category_code = 'A';
 --  	SELECT * FROM tmp_apportion;
		
	INSERT temp_apportion_detail (hotel_group_id,hotel_id,biz_date,close_flag,close_id,apportion_amount,
		ta_code1,ta_descript1,accnt1,ta_code2,ta_descript2,billno)
		SELECT arg_hotel_group_id,arg_hotel_id,biz_date,close_flag,close_id,SUM(apportion_amount),
				ta_code1,ta_descript1,accnt1,ta_code2,ta_descript2,billno
			FROM tmp_apportion GROUP BY billno,ta_code1,ta_code2;
	INSERT INTO temp_apportion_detail2 SELECT * FROM temp_apportion_detail;			
 	UPDATE temp_apportion_detail a,(SELECT billno,COUNT(DISTINCT ta_code2) AS num FROM temp_apportion_detail2 GROUP BY billno ) b SET a.tag = b.num
		WHERE a.billno = b.billno;
 		
	
	DELETE FROM tmp_account1;		
	
	-- 本日发生部分
	INSERT tmp_account1(biz_type,accnt,number,ta_code,ta_order,arrange_code,charge,pay,act_flag,trans_flag,market,
			ta_descript,rmno,grp_accnt,billno,close_flag,close_id)
		SELECT 'fo',a.accnt,a.number,a.ta_code,0,a.arrange_code,a.charge,a.pay,a.act_flag,a.trans_flag,a.market,
			a.ta_descript,a.rmno,a.grp_accnt,CONCAT('FO', CONVERT(a.close_id, UNSIGNED)),a.close_flag,a.close_id
		FROM account a 
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date = arg_biz_date AND a.arrange_code > '9' AND a.cashier LIKE arg_shift AND a.create_user LIKE arg_user 
		UNION
		SELECT 'fo',a.accnt,a.number,a.ta_code,0,a.arrange_code,a.charge,a.pay,a.act_flag,a.trans_flag,a.market,
			a.ta_descript,a.rmno,a.grp_accnt,CONCAT('FO', CONVERT(a.close_id, UNSIGNED)),a.close_flag,a.close_id
		FROM account_history a 
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date = arg_biz_date AND a.arrange_code > '9' AND a.cashier LIKE arg_shift AND a.create_user LIKE arg_user 
		; 
		
	DELETE FROM tmp_account1 WHERE NOT (act_flag IN ('AD', '') OR (act_flag IN ('LT', 'LA') AND (trans_flag= '' OR trans_flag IS NULL)));
	
 	UPDATE 	tmp_account1 a,code_transaction b SET a.ta_code = '9000',ta_descript = '人民币现金' WHERE a.ta_code = b.code
		AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.category_code = 'A';
 
	INSERT temp_apportion_detail (hotel_group_id,hotel_id,biz_date,apportion_amount,
		accnt1,ta_code2,ta_descript2,deptno,deptno_des)
		SELECT arg_hotel_group_id,arg_hotel_id,arg_biz_date,SUM(pay),accnt,ta_code,ta_descript,'999','预付订金'
			FROM tmp_account1 WHERE arrange_code = '98' GROUP BY ta_code,ta_descript;
			
	UPDATE temp_apportion_detail a,code_transaction b,code_base c SET a.deptno = b.cat_posting,a.deptno_des = c.descript
		WHERE a.ta_code1 = b.code AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.cat_posting = c.code AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND c.parent_code = 'posting_category';
 
		
	INSERT INTO tmp_account_pay(biz_type,biz_date,pay_code,pay_des,deptno,deptno_des,charge)
		SELECT 'A',biz_date,ta_code2,ta_descript2,deptno,deptno_des,SUM(apportion_amount) FROM temp_apportion_detail WHERE tag = 1 GROUP BY ta_code2,ta_descript2,deptno,deptno_des;
	
	INSERT INTO tmp_account_pay(biz_type,biz_date,pay_code,pay_des,deptno,deptno_des,charge,billno)
		SELECT 'B',biz_date,ta_code2,ta_descript2,deptno,deptno_des,SUM(apportion_amount),billno FROM temp_apportion_detail WHERE tag > 1 GROUP BY ta_code2,ta_descript2,deptno,deptno_des,billno;
	INSERT INTO tmp_account_pay1 SELECT * FROM tmp_account_pay;
	
	UPDATE tmp_account_pay a,(SELECT ta_code,ta_descript,SUM(pay) pay FROM tmp_account1 WHERE billno NOT IN(SELECT billno FROM tmp_account_pay1 WHERE billno <> '') GROUP BY ta_code ) b 
		SET a.amount = b.pay,amount1 = b.pay WHERE a.pay_code = b.ta_code AND a.billno = '';
		 
	UPDATE tmp_account_pay a,(SELECT ta_code,ta_descript,billno,SUM(pay) pay FROM tmp_account1 WHERE billno <> '' GROUP BY ta_code,billno ) b 
		SET a.amount = b.pay,amount1 = b.pay WHERE a.pay_code = b.ta_code AND a.billno = b.billno;
	INSERT INTO tmp_account_pay2 SELECT * FROM tmp_account_pay;
	INSERT INTO tmp_account_pay(biz_type,biz_date,pay_code,pay_des,deptno,deptno_des,charge,billno,amount)
		SELECT biz_type,biz_date,pay_code,pay_des,'ZZZ','合计',SUM(charge),billno,MAX(amount) FROM tmp_account_pay2 GROUP BY biz_type,pay_code,billno;
 
	UPDATE tmp_account_pay SET remark = IF(charge <> amount,CONCAT('押    ',charge-amount ,'  实   ',amount),'') WHERE deptno = 'ZZZ' AND deptno_des = '合计';
 
 	SELECT biz_type,biz_date,pay_code,pay_des,CONCAT(pay_des,billno) pay_des1,deptno,deptno_des,charge,billno,amount,amount1,remark FROM tmp_account_pay ORDER BY biz_type,pay_code,billno,deptno;

	
-- 	INSERT INTO tmp_account_scjj(pay_code,pay_des,ta_descript,deptno,deptno_des,charge)
-- 		SELECT ta_code,ta_descript,'预付定金','99','预付定金',SUM(pay) FROM tmp_account1 WHERE arrange_code = '98' GROUP BY ta_code,ta_descript;
 		
	
 
 	
	
	DROP TEMPORARY TABLE IF EXISTS tmp_account1; 
	DROP TEMPORARY TABLE IF EXISTS tmp_account2;
	DROP TEMPORARY TABLE IF EXISTS tmp_billno;
	DROP TEMPORARY TABLE IF EXISTS tmp_apportion;
	
END$$

DELIMITER ;