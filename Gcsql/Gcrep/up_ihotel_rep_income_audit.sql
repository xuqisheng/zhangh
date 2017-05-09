DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_income_audit`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_income_audit`(
	IN arg_hotel_group_id 	BIGINT(16),
	IN arg_hotel_id 		BIGINT(16),
	IN arg_biz_date			DATETIME,
	IN arg_tag				CHAR(1)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- 夜审收入报告
	DECLARE var_bfdate		DATETIME;
	DECLARE var_mdate		DATETIME;
	DECLARE var_ydate		DATETIME;
	DECLARE var_ldate		DATETIME;
	DECLARE var_lydate		DATETIME;
	DECLARE var_index		INT;
	DECLARE	var_classes		VARCHAR(250);
	DECLARE var_class		VARCHAR(10);
	DECLARE var_pos			INT;
	
	SET var_bfdate = ADDDATE(arg_biz_date, -1);
	SET var_mdate  = DATE_ADD(arg_biz_date,INTERVAL -(DAYOFMONTH(arg_biz_date)-1) DAY);
	SET var_ydate  = DATE_ADD(arg_biz_date,INTERVAL -(DAYOFYEAR(arg_biz_date)-1) DAY);
	SET var_ldate  = DATE_ADD(arg_biz_date,INTERVAL -1 YEAR);
	SET var_lydate = DATE_ADD(var_ydate,INTERVAL -1 YEAR);
	
	DROP TABLE IF EXISTS rep_income_night;
	CREATE TABLE rep_income_night (
	    hotel_group_id 	INT NOT NULL,
		hotel_id 		INT NOT NULL,
		biz_date		DATETIME NOT NULL,
		tag				CHAR(1) NOT NULL,
		CODE			VARCHAR(20) NOT NULL DEFAULT '',
		descript		VARCHAR(60) NOT NULL DEFAULT '',
		descript1		VARCHAR(60) NOT NULL DEFAULT '',
		dayrm			INT	NOT NULL DEFAULT '0',
		DAY				DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		dayave			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		dayreb			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		monthrm			INT	NOT NULL DEFAULT '0',
		MONTH			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		monthave		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		yearrm			INT	NOT NULL DEFAULT '0',
		YEAR			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		yearave			DECIMAL(12,2) NOT NULL DEFAULT '0.00',	
		lyearrm			INT	NOT NULL DEFAULT '0',
		lyear			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		lyearave		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		pm01			INT NOT NULL DEFAULT '0.00',
		pm02			INT NOT NULL DEFAULT '0.00',
		pm03			INT NOT NULL DEFAULT '0.00',
		pm11			INT NOT NULL DEFAULT '0.00',
		pm12			INT NOT NULL DEFAULT '0.00',
		pm13			INT NOT NULL DEFAULT '0.00',
		pos				INT NOT NULL DEFAULT '0.00',			
		KEY index1 (hotel_group_id,hotel_id,tag,CODE,biz_date)
	);
	
	DROP TEMPORARY TABLE IF EXISTS tmp_jierebate;
	CREATE TEMPORARY TABLE tmp_jierebate(
	    hotel_group_id 	BIGINT(16) NOT NULL,
		hotel_id 		BIGINT(16) NOT NULL,
		biz_date		DATETIME NOT NULL,
		classno			VARCHAR(20) NOT NULL DEFAULT '',
		amount			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
		KEY index1 (hotel_group_id,hotel_id,biz_date,classno)
	);
		
	IF arg_tag = 'A' THEN
		BEGIN
		DELETE FROM rep_income_night WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND tag='A';
		
		INSERT INTO rep_income_night(hotel_group_id,hotel_id,biz_date,tag,CODE,descript,DAY,MONTH,YEAR,lyear)
			SELECT a.hotel_group_id,a.hotel_id,a.biz_date,'A',a.code,a.descript,a.day,a.month,a.year,IFNULL(b.year,0)
				FROM rep_jour_history a
				LEFT JOIN rep_jour_history b ON b.hotel_group_id =a.hotel_group_id AND b.hotel_id =a.hotel_id AND b.biz_date = DATE_ADD(arg_biz_date, INTERVAL -1 YEAR) AND b.code = a.code
				WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_biz_date
					AND a.code >='010300' AND a.code<='010380' ORDER BY a.list_order;
					
		INSERT INTO tmp_jierebate(hotel_group_id,hotel_id,biz_date,classno,amount)
			SELECT hotel_group_id,hotel_id,biz_date,'00001',SUM(day07) FROM rep_jie_history WHERE hotel_group_id=arg_hotel_group_id 
				AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND classno IN ('010005','010006')
			UNION ALL
			SELECT hotel_group_id,hotel_id,biz_date,'00003',SUM(day07) FROM rep_jie_history WHERE hotel_group_id=arg_hotel_group_id 
				AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND classno >= '010010' AND classno <='010080'			
				;
		INSERT INTO rep_income_night(hotel_group_id,hotel_id,biz_date,CODE,dayreb,dayrm,monthrm,yearrm,lyearrm,tag)
			SELECT arg_hotel_group_id,arg_hotel_id,arg_biz_date,'010333',0,0,0,0,0,'A';
		
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='010300' AND b.classno='010' AND a.tag='A';
		
		UPDATE rep_income_night a,tmp_jierebate b SET a.dayreb=b.amount
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='010302' AND b.classno='00001' AND a.tag='A';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='010305' AND b.classno='010005' AND a.tag='A';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='010306' AND b.classno='010006' AND a.tag='A';
		
		UPDATE rep_income_night a,tmp_jierebate b SET a.dayreb=b.amount 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='010308' AND b.classno='00003' AND a.tag='A';				
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='010310' AND b.classno='010010' AND a.tag='A';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='010312' AND b.classno='010012' AND a.tag='A';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='010315' AND b.classno='010015' AND a.tag='A';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='010320' AND b.classno='010020' AND a.tag='A';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='010325' AND b.classno='010025' AND a.tag='A';				
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='010330' AND b.classno='010030' AND a.tag='A';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='010335' AND b.classno='010035' AND a.tag='A';	
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='010350' AND b.classno='010050' AND a.tag='A';	
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='010380' AND b.classno='010080' AND a.tag='A';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='010360' AND b.classno='010090' AND a.tag='A';				
	
		
		UPDATE rep_income_night a SET a.dayrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND b.code_type = 'MARKET' AND b.code NOT IN ('COM','HSE') )
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010300' AND a.tag='A';
		UPDATE rep_income_night a SET a.dayrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND b.code_type = 'MARKET' AND b.code IN ('CON','TGP')) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010302' AND a.tag='A';
		UPDATE rep_income_night a SET a.dayrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND b.code_type = 'MARKET' AND b.code='CON') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010305' AND a.tag='A';
		UPDATE rep_income_night a SET a.dayrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND b.code_type = 'MARKET' AND b.code='TGP') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010306' AND a.tag='A';
		UPDATE rep_income_night a SET a.dayrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND b.code_type = 'MARKET' AND b.code NOT IN ('CON','TGP','COM','HSE','VIP')) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010308' AND a.tag='A';
		UPDATE rep_income_night a SET a.dayrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND b.code_type = 'MARKET' AND b.code='RAC') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010310' AND a.tag='A';
		UPDATE rep_income_night a SET a.dayrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND b.code_type = 'MARKET' AND b.code IN ('WLK','WI')) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010312' AND a.tag='A';
		UPDATE rep_income_night a SET a.dayrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND b.code_type = 'MARKET' AND b.code IN ('LON','NR','DIS')) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010315' AND a.tag='A';
		UPDATE rep_income_night a SET a.dayrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND b.code_type = 'MARKET' AND b.code='WSL') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010320' AND a.tag='A';
		UPDATE rep_income_night a SET a.dayrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND b.code_type = 'MARKET' AND b.code='CO') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010325' AND a.tag='A';
		UPDATE rep_income_night a SET a.dayrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND b.code_type = 'MARKET' AND b.code='WBC') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010330' AND a.tag='A';
		UPDATE rep_income_night a SET a.dayrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND b.code_type = 'MARKET' AND b.code='SPE') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010335' AND a.tag='A';
		UPDATE rep_income_night a SET a.dayrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND b.code_type = 'MARKET' AND b.code='PAK') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010350' AND a.tag='A';				
		UPDATE rep_income_night a SET a.dayrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND b.code_type = 'MARKET' AND b.code='VIP') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010380' AND a.tag='A';
		UPDATE rep_income_night a SET a.dayrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND b.code_type = 'MARKET' AND b.code='AU') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010360' AND a.tag='A';
			
		UPDATE rep_income_night a SET a.monthrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_mdate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code NOT IN ('COM','HSE') ) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010300' AND a.tag='A';
		UPDATE rep_income_night a SET a.monthrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_mdate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code IN ('CON','TGP')) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010302' AND a.tag='A';
		UPDATE rep_income_night a SET a.monthrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_mdate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='CON') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010305' AND a.tag='A';
		UPDATE rep_income_night a SET a.monthrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_mdate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='TGP') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010306' AND a.tag='A';
		UPDATE rep_income_night a SET a.monthrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_mdate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code NOT IN ('CON','TGP','COM','HSE','VIP')) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010308' AND a.tag='A';
		UPDATE rep_income_night a SET a.monthrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_mdate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='RAC') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010310' AND a.tag='A';
		UPDATE rep_income_night a SET a.monthrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_mdate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code IN ('WLK','WI')) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010312' AND a.tag='A';
		UPDATE rep_income_night a SET a.monthrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_mdate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code IN ('LON','NR','DIS')) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010315' AND a.tag='A';
		UPDATE rep_income_night a SET a.monthrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_mdate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='WSL') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010320' AND a.tag='A';
		UPDATE rep_income_night a SET a.monthrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_mdate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='CO') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010325' AND a.tag='A';
		UPDATE rep_income_night a SET a.monthrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_mdate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='WBC') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010330' AND a.tag='A';
		UPDATE rep_income_night a SET a.monthrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_mdate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='SPE') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010335' AND a.tag='A';				
		UPDATE rep_income_night a SET a.monthrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_mdate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='PAK') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010350' AND a.tag='A';
		UPDATE rep_income_night a SET a.monthrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_mdate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='VIP') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010380' AND a.tag='A';				
		UPDATE rep_income_night a SET a.monthrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_mdate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='AU') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010360' AND a.tag='A';				
			
		UPDATE rep_income_night a SET a.yearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_ydate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code NOT IN ('COM','HSE')) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010300' AND a.tag='A';
		UPDATE rep_income_night a SET a.yearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_ydate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code IN ('CON','TGP')) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010302' AND a.tag='A';
		UPDATE rep_income_night a SET a.yearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_ydate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='CON') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010305' AND a.tag='A';
		UPDATE rep_income_night a SET a.yearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_ydate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='TGP') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010306' AND a.tag='A';
		UPDATE rep_income_night a SET a.yearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_ydate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code NOT IN ('CON','TGP','COM','HSE','VIP')) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010308' AND a.tag='A';
		UPDATE rep_income_night a SET a.yearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_ydate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='RAC') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010310' AND a.tag='A';
		UPDATE rep_income_night a SET a.yearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_ydate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code IN ('WLK','WI')) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010312' AND a.tag='A';
		UPDATE rep_income_night a SET a.yearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_ydate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code IN ('LON','NR','DIS')) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010315' AND a.tag='A';
		UPDATE rep_income_night a SET a.yearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_ydate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='WSL') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010320' AND a.tag='A';
		UPDATE rep_income_night a SET a.yearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_ydate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='CO') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010325' AND a.tag='A';
		UPDATE rep_income_night a SET a.yearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_ydate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='WBC') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010330' AND a.tag='A';
		UPDATE rep_income_night a SET a.yearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_ydate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='SPE') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010335' AND a.tag='A';				
		UPDATE rep_income_night a SET a.yearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_ydate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='PAK') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010350' AND a.tag='A';
		UPDATE rep_income_night a SET a.yearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_ydate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='VIP') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010380' AND a.tag='A';				
		UPDATE rep_income_night a SET a.yearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_ydate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code='AU') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010360' AND a.tag='A';				
			
		UPDATE rep_income_night a SET a.lyearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_lydate AND b.biz_date<=var_ldate AND b.code_type = 'MARKET' AND b.code NOT IN ('COM','HSE') ) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010300' AND a.tag='A';
		UPDATE rep_income_night a SET a.lyearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_lydate AND b.biz_date<=var_ldate AND b.code_type = 'MARKET' AND b.code IN ('CON','TGP')) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010302' AND a.tag='A';
		UPDATE rep_income_night a SET a.lyearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_lydate AND b.biz_date<=var_ldate AND b.code_type = 'MARKET' AND b.code='CON') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010305' AND a.tag='A';
		UPDATE rep_income_night a SET a.lyearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_lydate AND b.biz_date<=var_ldate AND b.code_type = 'MARKET' AND b.code='TGP') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010306' AND a.tag='A';
		UPDATE rep_income_night a SET a.lyearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_lydate AND b.biz_date<=var_ldate AND b.code_type = 'MARKET' AND b.code NOT IN ('CON','TGP','COM','HSE','VIP')) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010308' AND a.tag='A';
		UPDATE rep_income_night a SET a.lyearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_lydate AND b.biz_date<=var_ldate AND b.code_type = 'MARKET' AND b.code='RAC') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010310' AND a.tag='A';
		UPDATE rep_income_night a SET a.lyearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_lydate AND b.biz_date<=var_ldate AND b.code_type = 'MARKET' AND b.code IN ('WLK','WI')) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010312' AND a.tag='A';
		UPDATE rep_income_night a SET a.lyearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_lydate AND b.biz_date<=var_ldate AND b.code_type = 'MARKET' AND b.code IN ('LON','NR','DIS')) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010315' AND a.tag='A';
		UPDATE rep_income_night a SET a.lyearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_lydate AND b.biz_date<=var_ldate AND b.code_type = 'MARKET' AND b.code='WSL') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010320' AND a.tag='A';
		UPDATE rep_income_night a SET a.lyearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_lydate AND b.biz_date<=var_ldate AND b.code_type = 'MARKET' AND b.code='CO') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010325' AND a.tag='A';
		UPDATE rep_income_night a SET a.lyearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_lydate AND b.biz_date<=var_ldate AND b.code_type = 'MARKET' AND b.code='WBC') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010330' AND a.tag='A';
		UPDATE rep_income_night a SET a.lyearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_lydate AND b.biz_date<=var_ldate AND b.code_type = 'MARKET' AND b.code='SPE') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010335' AND a.tag='A';				
		UPDATE rep_income_night a SET a.lyearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_lydate AND b.biz_date<=var_ldate AND b.code_type = 'MARKET' AND b.code='PAK') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010350' AND a.tag='A';
		UPDATE rep_income_night a SET a.lyearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_lydate AND b.biz_date<=var_ldate AND b.code_type = 'MARKET' AND b.code='VIP') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010380' AND a.tag='A';				
		UPDATE rep_income_night a SET a.lyearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_lydate AND b.biz_date<=var_ldate AND b.code_type = 'MARKET' AND b.code='AU') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010360' AND a.tag='A';				
		UPDATE rep_income_night a SET a.dayrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND b.code_type = 'MARKET' AND b.code <> 'HSE' )
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010333' AND a.tag='A';
		UPDATE rep_income_night a SET a.lyearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_lydate AND b.biz_date<=var_ldate AND b.code_type = 'MARKET' AND b.code <> 'HSE' ) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010333' AND a.tag='A';
		UPDATE rep_income_night a SET a.yearrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_ydate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code <> 'HSE') 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010333' AND a.tag='A';
		UPDATE rep_income_night a SET a.monthrm=(SELECT SUM(b.rooms_total) FROM rep_revenue_mkt_history b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date>=var_mdate AND b.biz_date<=arg_biz_date AND b.code_type = 'MARKET' AND b.code <> 'HSE' ) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.hotel_id=arg_hotel_id AND a.code='010333' AND a.tag='A';
		
		INSERT INTO rep_income_night(hotel_group_id,hotel_id,biz_date,tag,CODE,descript,dayave,monthave,yearave,lyearave)
			SELECT a.hotel_group_id,a.hotel_id,a.biz_date,'A','000001','※平均房价(含免)',a.day,a.month,a.year,IFNULL(b.year,0)
				FROM rep_jour_history a
				LEFT JOIN rep_jour_history b ON b.hotel_group_id =a.hotel_group_id AND b.hotel_id =a.hotel_id AND b.biz_date = DATE_ADD(arg_biz_date, INTERVAL -1 YEAR) AND b.code = a.code
				WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_biz_date
					AND a.code ='010180' ORDER BY a.list_order;
		
		UPDATE rep_income_night SET DAY = (SELECT SUM(a.day) FROM (SELECT * FROM rep_income_night WHERE CODE='010300' AND hotel_group_id =arg_hotel_group_id AND hotel_id =arg_hotel_id) AS a) WHERE CODE='000001';
		UPDATE rep_income_night SET dayreb = (SELECT SUM(a.dayreb) FROM (SELECT * FROM rep_income_night WHERE CODE='010300' AND hotel_group_id =arg_hotel_group_id AND hotel_id =arg_hotel_id) AS a) WHERE CODE='000001';		
		UPDATE rep_income_night SET MONTH = (SELECT SUM(a.MONTH) FROM (SELECT * FROM rep_income_night WHERE CODE='010300' AND hotel_group_id =arg_hotel_group_id AND hotel_id =arg_hotel_id) AS a) WHERE CODE='000001';	
		UPDATE rep_income_night SET YEAR = (SELECT SUM(a.YEAR) FROM (SELECT * FROM rep_income_night WHERE CODE='010300' AND hotel_group_id =arg_hotel_group_id AND hotel_id =arg_hotel_id) AS a) WHERE CODE='000001';
		UPDATE rep_income_night SET lyear = (SELECT SUM(a.lyear) FROM (SELECT * FROM rep_income_night WHERE CODE='010300' AND hotel_group_id =arg_hotel_group_id AND hotel_id =arg_hotel_id) AS a) WHERE CODE='000001';
		
		UPDATE rep_income_night SET dayrm = (SELECT a.dayrm FROM (SELECT * FROM rep_income_night WHERE CODE='010333' AND hotel_group_id =arg_hotel_group_id AND hotel_id =arg_hotel_id) AS a) WHERE CODE='000001' AND dayave <> 0;
		UPDATE rep_income_night SET monthrm = (SELECT a.monthrm FROM (SELECT * FROM rep_income_night WHERE CODE='010333' AND hotel_group_id =arg_hotel_group_id AND hotel_id =arg_hotel_id) AS a) WHERE CODE='000001' AND monthave <> 0;	
		UPDATE rep_income_night SET yearrm = (SELECT a.yearrm FROM (SELECT * FROM rep_income_night WHERE CODE='010333' AND hotel_group_id =arg_hotel_group_id AND hotel_id =arg_hotel_id) AS a) WHERE CODE='000001' AND yearave <> 0;
		UPDATE rep_income_night SET lyearrm = (SELECT a.lyearrm FROM (SELECT * FROM rep_income_night WHERE CODE='010333' AND hotel_group_id =arg_hotel_group_id AND hotel_id =arg_hotel_id) AS a) WHERE CODE='000001' AND lyearave <> 0;
		UPDATE rep_income_night SET dayave=ROUND(DAY/dayrm,2) WHERE dayrm <> 0;
		UPDATE rep_income_night SET monthave=ROUND(MONTH/monthrm,2) WHERE monthrm <> 0;
		UPDATE rep_income_night SET yearave=ROUND(YEAR/yearrm,2) WHERE yearrm <> 0;
		UPDATE rep_income_night SET lyearave=ROUND(lyear/lyearrm,2) WHERE lyearrm <> 0;	
				
		DELETE FROM rep_income_night WHERE CODE='010333';
		SELECT descript,dayrm,DAY,dayave,dayreb,monthrm,MONTH,monthave,yearrm,YEAR,yearave,lyearrm,lyear,lyearave FROM rep_income_night WHERE tag='A' ORDER BY CODE;
		
		END;
	END IF;
	
	IF arg_tag='B' THEN
		BEGIN
		DELETE FROM rep_income_night WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND tag='B';
		INSERT INTO rep_income_night(hotel_group_id,hotel_id,biz_date,tag,CODE,descript,DAY,MONTH,YEAR,lyear)
			SELECT a.hotel_group_id,a.hotel_id,a.biz_date,'B',a.code,a.descript,a.day,a.month,a.year,IFNULL(b.year,0)
				FROM rep_jour_history a
				LEFT JOIN rep_jour_history b ON b.hotel_group_id =a.hotel_group_id AND b.hotel_id =a.hotel_id AND b.biz_date = DATE_ADD(arg_biz_date, INTERVAL -1 YEAR) AND b.code = a.code
				WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_biz_date
					AND a.code >='020000' AND a.code<='020060' 
			UNION ALL
			SELECT a.hotel_group_id,a.hotel_id,a.biz_date,'B',a.code,a.descript,a.day,a.month,a.year,IFNULL(b.year,0)
				FROM rep_jour_history a
				LEFT JOIN rep_jour_history b ON b.hotel_group_id =a.hotel_group_id AND b.hotel_id =a.hotel_id AND b.biz_date = DATE_ADD(arg_biz_date, INTERVAL -1 YEAR) AND b.code = a.code
				WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_biz_date
					AND a.code >='040000' AND a.code<='040010' 
			UNION ALL
			SELECT a.hotel_group_id,a.hotel_id,a.biz_date,'B',a.code,a.descript,a.day,a.month,a.year,IFNULL(b.year,0)
				FROM rep_jour_history a
				LEFT JOIN rep_jour_history b ON b.hotel_group_id =a.hotel_group_id AND b.hotel_id =a.hotel_id AND b.biz_date = DATE_ADD(arg_biz_date, INTERVAL -1 YEAR) AND b.code = a.code
				WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_biz_date
					AND a.code IN ('040020','040030','999')					
			UNION ALL
			SELECT a.hotel_group_id,a.hotel_id,a.biz_date,'B',a.code,a.descript,a.day,a.month,a.year,IFNULL(b.year,0)
				FROM rep_jour_history a
				LEFT JOIN rep_jour_history b ON b.hotel_group_id =a.hotel_group_id AND b.hotel_id =a.hotel_id AND b.biz_date = DATE_ADD(arg_biz_date, INTERVAL -1 YEAR) AND b.code = a.code
				WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_biz_date
					AND a.code >='040040' AND a.code<='070080' ORDER BY CODE;			
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='020000' AND b.classno='020' AND a.tag='B';				
			
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code=b.classno AND a.tag='B';				
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='040000' AND b.classno='060' AND a.tag='B';				
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='040010' AND b.classno='060010' AND a.tag='B';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='040020' AND b.classno='060020' AND a.tag='B';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='040030' AND b.classno='060030' AND a.tag='B';				
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='040040' AND b.classno='060040' AND a.tag='B';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='040050' AND b.classno='060050' AND a.tag='B';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='040060' AND b.classno='060060' AND a.tag='B';				
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='040070' AND b.classno='060070' AND a.tag='B';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='040080' AND b.classno='060080' AND a.tag='B';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='040090' AND b.classno='060080' AND a.tag='B';
				
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='050000' AND b.classno='065' AND a.tag='B';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='060000' AND b.classno='079' AND a.tag='B';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='070000' AND b.classno='080' AND a.tag='B';				
UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='070010' AND b.classno='080010' AND a.tag='B';				
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='070020' AND b.classno='080020' AND a.tag='B';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='070030' AND b.classno='080030' AND a.tag='B';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='070040' AND b.classno='081035' AND a.tag='B';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='070050' AND b.classno='081040' AND a.tag='B';				
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='070060' AND b.classno='081050' AND a.tag='B';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='070070' AND b.classno='080160' AND a.tag='B';
		UPDATE rep_income_night a,rep_jie_history b SET a.dayreb=b.day07 
			WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id 
				AND a.hotel_id=arg_hotel_id AND b.biz_date=arg_biz_date AND a.code='070080' AND b.classno='080170' AND a.tag='B';				
				
		SELECT descript,DAY,dayreb,MONTH,YEAR,lyear FROM rep_income_night WHERE tag='B' ORDER BY CODE;
		END;
	END IF;
	
	IF arg_tag='C' THEN
		BEGIN
		DELETE FROM rep_income_night WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND tag='C';
		
		INSERT INTO rep_income_night(hotel_group_id,hotel_id,biz_date,tag,CODE,descript,DAY)
			SELECT hotel_group_id,hotel_id,biz_date,'C','01010','现金',sumcre FROM rep_dai_history
				WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND classno='01010'
			UNION ALL
			SELECT hotel_group_id,hotel_id,biz_date,'C','01010A','  人民币',credit01 FROM rep_dai_history
				WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND classno='01010'
			UNION ALL
			SELECT hotel_group_id,hotel_id,biz_date,'C','01010B','  支票',credit02 FROM rep_dai_history
				WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND classno='01010'
			UNION ALL
			SELECT hotel_group_id,hotel_id,biz_date,'C','01010C','  信用卡',credit03+credit04 FROM rep_dai_history
				WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND classno='01010'
			UNION ALL
			SELECT hotel_group_id,hotel_id,biz_date,'C','01010Z','  其他',credit06+credit07 FROM rep_dai_history
				WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND classno='01010' HAVING SUM(credit06+credit07) <> 0
			UNION ALL
			SELECT a.hotel_group_id,a.hotel_id,a.biz_date,'C','02000A','  挂帐数',SUM(a.sumcre) FROM rep_dai_history a
				WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_biz_date AND a.classno IN ('01010','02000','03000')
			UNION ALL
			SELECT hotel_group_id,hotel_id,biz_date,'C','02000B','  减:收回客帐',sumcre FROM rep_dai_history
				WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND classno='01010'
			UNION ALL
			SELECT hotel_group_id,hotel_id,biz_date,'C','03000','内部转帐',credit05 FROM rep_dai_history
				WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND classno='01010'
			;
			INSERT INTO rep_income_night(hotel_group_id,hotel_id,biz_date,tag,CODE,descript,DAY)
			SELECT a.hotel_group_id,a.hotel_id,a.biz_date,'C','02000','宾客帐',a.DAY-b.DAY FROM rep_income_night a,rep_income_night b
				WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id 
					AND a.code='02000A' AND b.code='02000B' AND a.tag='C' AND a.tag=b.tag;	
				
			INSERT INTO rep_income_night(hotel_group_id,hotel_id,biz_date,tag,CODE,descript,DAY)
				SELECT a.hotel_group_id,a.hotel_id,a.biz_date,'C','05000','合 计',a.day FROM rep_income_night a
				WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.tag='C' AND a.code='02000A';
		UPDATE rep_income_night a SET a.pos = (SELECT COUNT(1) FROM (SELECT * FROM rep_income_night) AS b WHERE b.code <= a.code);
		SET var_classes = '010012 #010014 #010015 #010020 #010030 #010045 #010080 #010121 #010122 #';
		SET var_pos = 0;
		WHILE var_pos*8+1 <= CHAR_LENGTH(var_classes) DO
			BEGIN
			SET var_class = RTRIM(SUBSTRING(var_classes,var_pos*8 + 1,7));
			SET var_pos = var_pos + 1;
			
			UPDATE rep_income_night a,rep_jour_history b SET a.descript1=LTRIM(b.descript),a.pm01=b.day,a.pm02=b.month,a.pm03=b.year WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.biz_date=b.biz_date
				AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_biz_date AND a.pos=var_pos AND b.code=var_class;
			
			UPDATE rep_income_night a,rep_jour_history b SET a.pm11=b.day,a.pm12=b.month,a.pm13=b.year WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.biz_date=b.biz_date
				AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date=arg_biz_date AND a.pos=var_pos AND b.code=CONCAT(var_class,'0');
		
			END;
		END WHILE;
		
		UPDATE rep_income_night SET descript1 = SUBSTRING(descript1,INSTR(descript1,'.') + 1,30) WHERE INSTR(descript1,'.') > 0;
		
	
		SELECT descript,DAY,descript1,pm01,pm02,pm03,pm11,pm12,pm13 FROM rep_income_night WHERE tag='C' ORDER BY CODE;
		END;
	END IF;
		
	DROP TABLE IF EXISTS rep_income_night;
	DROP TEMPORARY TABLE IF EXISTS tmp_jierebate;
	
END$$

DELIMITER ;