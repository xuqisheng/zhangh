DELIMITER $$

USE `portal_ipms`$$

DROP PROCEDURE IF EXISTS `up_ihotel_audit_rep_jiedai_dai_tax`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_audit_rep_jiedai_dai_tax`(
	IN arg_hotel_group_id		INT,
	IN arg_hotel_id			INT,
	IN arg_accnt_type		VARCHAR(3),
	IN arg_modu			CHAR(2),
	IN arg_ta_code			VARCHAR(10),
	IN arg_pay			DECIMAL(12,2)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ---------------------------------------------------------------
	-- 夜审过程- 定制稽核底表
	-- 作者：张晓斌 2016.9.3
	-- 2016.09.03日 
	-- ---------------------------------------------------------------
	-- 修改日志 
	-- ---------------------------------------------------------------
	DECLARE var_cashgst		VARCHAR(10);
	DECLARE var_cashpos		VARCHAR(10);
	DECLARE var_cashar		VARCHAR(10);
	DECLARE var_cashttl		VARCHAR(10);
	DECLARE var_cashvip		VARCHAR(10);
	DECLARE var_ent_sum		VARCHAR(10);
	DECLARE var_deptno		CHAR(1);
	DECLARE var_tacodes_ar		VARCHAR(100);
	DECLARE var_tacodes_vip		VARCHAR(100);
	DECLARE var_group_paycode1	VARCHAR(255);
	DECLARE var_group_paycode2	VARCHAR(255);
	DECLARE var_group_paycode3	VARCHAR(255);
	DECLARE var_group_paycode4	VARCHAR(255);
	DECLARE var_group_paycode5	VARCHAR(255);
	DECLARE var_group_paycode6	VARCHAR(255);
	DECLARE var_group_paycode7	VARCHAR(255);
	DECLARE var_group_paycode8	VARCHAR(255);
	DECLARE var_group_paycode9	VARCHAR(255);
	DECLARE var_group_paycode10	VARCHAR(255);
	DECLARE var_group_paycode11	VARCHAR(255);
	DECLARE var_group_paycode12	VARCHAR(255);
	SET  var_cashttl = '01010', var_cashgst = '01020',var_cashpos='01998',var_cashar='01999',var_cashvip='01060',var_ent_sum = '08000';
	
 	-- 付款码
	DROP TEMPORARY TABLE IF EXISTS tmp_paycode;
	CREATE TEMPORARY TABLE tmp_paycode
	(
 		CODE 		VARCHAR(10) NOT NULL,
		descript	VARCHAR(30),
		category_code	VARCHAR(10),
		cat_posting	VARCHAR(5),
		KEY index1(CODE),
		KEY index2(cat_posting)
	);
	
	INSERT INTO tmp_paycode(CODE,descript,category_code,cat_posting)
		SELECT CODE,descript,IF(category_code = 'A',category_code,CODE),cat_posting FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND arrange_code = '98' AND CODE <> '9'
			AND cat_posting NOT IN('TA','TF','RCV','LCV');
	UPDATE tmp_paycode SET category_code = cat_posting WHERE cat_posting = 'ENT';		
	-- 现金类
	SET var_group_paycode1 = IFNULL((SELECT CONCAT(',',GROUP_CONCAT(DISTINCT CODE),',') FROM tmp_paycode WHERE category_code = 'A'),'9000');
	-- 中行刷卡
	SET var_group_paycode2 = IFNULL((SELECT CONCAT(',',GROUP_CONCAT(DISTINCT CODE),',') FROM tmp_paycode WHERE category_code IN ('9110','9210')),'9110');
	-- 邮政刷卡
	SET var_group_paycode3 = IFNULL((SELECT CONCAT(',',GROUP_CONCAT(DISTINCT CODE),',') FROM tmp_paycode WHERE category_code IN ('9112','9212')),'9112');
	-- 农行刷卡
	SET var_group_paycode4 = IFNULL((SELECT CONCAT(',',GROUP_CONCAT(DISTINCT CODE),',') FROM tmp_paycode WHERE category_code IN ('9111','9211')),'9111');
	-- 建行刷卡
	SET var_group_paycode5 = IFNULL((SELECT CONCAT(',',GROUP_CONCAT(DISTINCT CODE),',') FROM tmp_paycode WHERE category_code IN ('9113','9213')),'9113');
	-- 支付宝
	SET var_group_paycode6 = IFNULL((SELECT CONCAT(',',GROUP_CONCAT(DISTINCT CODE),',') FROM tmp_paycode WHERE category_code IN ('9050','9051','9052','9053','9054')),'9050');
	-- 微信
	SET var_group_paycode7 = IFNULL((SELECT CONCAT(',',GROUP_CONCAT(DISTINCT CODE),',') FROM tmp_paycode WHERE category_code = '9060'),'9060');
	-- 内部转账
	SET var_group_paycode8 = IFNULL((SELECT CONCAT(',',GROUP_CONCAT(DISTINCT CODE),',') FROM tmp_paycode WHERE category_code = '9300'),'9300');
	-- 婚房
	SET var_group_paycode9 = IFNULL((SELECT CONCAT(',',GROUP_CONCAT(DISTINCT CODE),',') FROM tmp_paycode WHERE category_code = '9802'),'9802');	
	-- 款待	
	SET var_group_paycode10 = IFNULL((SELECT CONCAT(',',GROUP_CONCAT(DISTINCT CODE),',') FROM tmp_paycode WHERE category_code = 'ENT'),'9080');
	-- 其他	
	SET var_group_paycode11 = IFNULL((SELECT CONCAT(',',GROUP_CONCAT(DISTINCT CODE),',') FROM tmp_paycode WHERE category_code NOT IN('A','9110','9112','9111','9113','9050','9051','9052','9053','9054','9060','9300','9802','ENT')),'');
	
 	
	SELECT IFNULL(category_code,'A') INTO var_deptno FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND CODE = arg_ta_code;
	SELECT GROUP_CONCAT(CODE) INTO var_tacodes_ar FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND cat_posting = 'TA';
	SELECT GROUP_CONCAT(CODE) INTO var_tacodes_vip FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND cat_posting IN('RCV','LCV');
	-- 转AR和储值卡结账的赋值为0
	IF INSTR(CONCAT(',',var_tacodes_ar,','),CONCAT(',',arg_ta_code,',')) > 0 OR INSTR(CONCAT(',',var_tacodes_vip,','),CONCAT(',',arg_ta_code,',')) > 0 THEN
		SET arg_pay = 0;
	END IF;
	
 	IF arg_accnt_type = 'AR' AND arg_modu = '02' AND INSTR(var_group_paycode1,CONCAT(',',arg_ta_code,','))>0 THEN
 		UPDATE rep_dai_hd_tax SET credit01=credit01+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashar);
  	ELSEIF arg_accnt_type = 'FO' AND arg_modu = '02' AND INSTR(var_group_paycode1,CONCAT(',',arg_ta_code,','))>0 THEN
 		UPDATE rep_dai_hd_tax SET credit01=credit01+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashgst);		
  	ELSEIF arg_accnt_type = 'VIP' AND arg_modu = '02' AND INSTR(var_group_paycode1,CONCAT(',',arg_ta_code,','))>0 THEN
 		UPDATE rep_dai_hd_tax SET credit01=credit01+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashvip);		
  	ELSEIF arg_accnt_type = 'POS' AND arg_modu = '04' AND INSTR(var_group_paycode1,CONCAT(',',arg_ta_code,','))>0 THEN
 		UPDATE rep_dai_hd_tax SET credit01=credit01+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashpos);		
	ELSEIF arg_accnt_type = 'FO' AND arg_modu = '02' AND INSTR(var_group_paycode2,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit02=credit02+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashgst);		
	ELSEIF arg_accnt_type = 'AR' AND arg_modu = '02' AND INSTR(var_group_paycode2,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit02=credit02+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashar);		
	ELSEIF arg_accnt_type = 'VIP' AND arg_modu = '02' AND INSTR(var_group_paycode2,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit02=credit02+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashvip);		
	ELSEIF arg_accnt_type = 'POS' AND arg_modu = '04' AND INSTR(var_group_paycode2,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit02=credit02+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashpos);		
	ELSEIF arg_accnt_type = 'FO' AND arg_modu = '02' AND INSTR(var_group_paycode3,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit03=credit03+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashgst);		
	ELSEIF arg_accnt_type = 'AR' AND arg_modu = '02' AND INSTR(var_group_paycode3,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit03=credit03+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashar);		
	ELSEIF arg_accnt_type = 'VIP' AND arg_modu = '02' AND INSTR(var_group_paycode3,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit03=credit03+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashvip);		
	ELSEIF arg_accnt_type = 'POS' AND arg_modu = '04' AND INSTR(var_group_paycode3,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit03=credit03+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashpos);		
	ELSEIF arg_accnt_type = 'FO' AND arg_modu = '02' AND INSTR(var_group_paycode4,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit04=credit04+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashgst);		
	ELSEIF arg_accnt_type = 'AR' AND arg_modu = '02' AND INSTR(var_group_paycode4,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit04=credit04+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashar);		
	ELSEIF arg_accnt_type = 'VIP' AND arg_modu = '02' AND INSTR(var_group_paycode4,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit04=credit04+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashvip);		
	ELSEIF arg_accnt_type = 'POS' AND arg_modu = '04' AND INSTR(var_group_paycode4,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit04=credit04+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashpos);		
	ELSEIF arg_accnt_type = 'FO' AND arg_modu = '02' AND INSTR(var_group_paycode5,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit05=credit05+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashgst);		
	ELSEIF arg_accnt_type = 'AR' AND arg_modu = '02' AND INSTR(var_group_paycode5,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit05=credit05+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashar);		
	ELSEIF arg_accnt_type = 'VIP' AND arg_modu = '02' AND INSTR(var_group_paycode5,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit05=credit05+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashvip);		
	ELSEIF arg_accnt_type = 'POS' AND arg_modu = '04' AND INSTR(var_group_paycode5,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit05=credit05+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashpos);		
  	ELSEIF arg_accnt_type = 'FO' AND arg_modu = '02' AND INSTR(var_group_paycode6,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit06=credit06+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashgst);		
	ELSEIF arg_accnt_type = 'AR' AND arg_modu = '02' AND INSTR(var_group_paycode6,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit06=credit06+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashar);		
	ELSEIF arg_accnt_type = 'VIP' AND arg_modu = '02' AND INSTR(var_group_paycode6,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit06=credit06+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashvip);		
	ELSEIF arg_accnt_type = 'POS' AND arg_modu = '04' AND INSTR(var_group_paycode6,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit06=credit06+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashpos);		
	ELSEIF arg_accnt_type = 'FO' AND arg_modu = '02' AND INSTR(var_group_paycode7,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit07=credit07+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashgst);		
	ELSEIF arg_accnt_type = 'AR' AND arg_modu = '02' AND INSTR(var_group_paycode7,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit07=credit07+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashar);		
	ELSEIF arg_accnt_type = 'VIP' AND arg_modu = '02' AND INSTR(var_group_paycode7,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit07=credit07+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashvip);		
	ELSEIF arg_accnt_type = 'POS' AND arg_modu = '04' AND INSTR(var_group_paycode7,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit07=credit07+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashpos);		
	ELSEIF arg_accnt_type = 'FO' AND arg_modu = '02' AND INSTR(var_group_paycode8,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit08=credit08+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashgst);		
	ELSEIF arg_accnt_type = 'AR' AND arg_modu = '02' AND INSTR(var_group_paycode8,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit08=credit08+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashar);		
	ELSEIF arg_accnt_type = 'VIP' AND arg_modu = '02' AND INSTR(var_group_paycode8,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit08=credit08+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashvip);		
	ELSEIF arg_accnt_type = 'POS' AND arg_modu = '04' AND INSTR(var_group_paycode8,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit08=credit08+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashpos);		
	ELSEIF arg_accnt_type = 'FO' AND arg_modu = '02' AND INSTR(var_group_paycode9,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit09=credit09+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashgst);		
	ELSEIF arg_accnt_type = 'AR' AND arg_modu = '02' AND INSTR(var_group_paycode9,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit09=credit09+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashar);		
	ELSEIF arg_accnt_type = 'VIP' AND arg_modu = '02' AND INSTR(var_group_paycode9,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit09=credit09+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashvip);		
	ELSEIF arg_accnt_type = 'POS' AND arg_modu = '04' AND INSTR(var_group_paycode9,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit09=credit09+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashpos);		
	ELSEIF arg_accnt_type = 'FO' AND arg_modu = '02' AND INSTR(var_group_paycode10,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit10=credit10+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashgst);		
	ELSEIF arg_accnt_type = 'AR' AND arg_modu = '02' AND INSTR(var_group_paycode10,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit10=credit10+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashar);		
	ELSEIF arg_accnt_type = 'VIP' AND arg_modu = '02' AND INSTR(var_group_paycode10,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit10=credit10+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashvip);		
	ELSEIF arg_accnt_type = 'POS' AND arg_modu = '04' AND INSTR(var_group_paycode10,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit10=credit10+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashpos);		
	ELSEIF arg_accnt_type = 'FO' AND arg_modu = '02' AND INSTR(var_group_paycode11,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit11=credit11+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashgst);		
	ELSEIF arg_accnt_type = 'AR' AND arg_modu = '02' AND INSTR(var_group_paycode11,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit11=credit11+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashar);		
	ELSEIF arg_accnt_type = 'VIP' AND arg_modu = '02' AND INSTR(var_group_paycode11,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit11=credit11+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashvip);		
	ELSEIF arg_accnt_type = 'POS' AND arg_modu = '04' AND INSTR(var_group_paycode11,CONCAT(',',arg_ta_code,','))>0 THEN
		UPDATE rep_dai_hd_tax SET credit11=credit11+arg_pay,sumcre = sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashpos);		
 	END IF;
 	-- 款待部分
 	IF arg_accnt_type = 'fo' AND arg_modu='08' THEN
		UPDATE rep_dai_hd_tax SET credit10=credit10-arg_pay,sumcre=sumcre-arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashgst);
		UPDATE rep_dai_hd_tax SET sumcre=sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = '08000');
	ELSEIF 	arg_accnt_type = 'pos' AND arg_modu='08' THEN
		UPDATE rep_dai_hd_tax SET credit10=credit10-arg_pay,sumcre=sumcre-arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashpos);
		UPDATE rep_dai_hd_tax SET sumcre=sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = '08000');
	ELSEIF 	arg_accnt_type = 'AR' AND arg_modu='08' THEN
		UPDATE rep_dai_hd_tax SET credit10=credit10-arg_pay,sumcre=sumcre-arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = var_cashttl OR classno = var_cashar);
		UPDATE rep_dai_hd_tax SET sumcre=sumcre+arg_pay WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (classno = '08000');
	
 	END IF;	
 
    	BEGIN
 
		SET @procresult = 0 ;
		LEAVE label_0 ;
	END ;
	
  END$$

DELIMITER ;