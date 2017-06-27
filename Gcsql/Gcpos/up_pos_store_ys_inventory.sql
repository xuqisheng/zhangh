-- 过夜审合计当日的销售单和生成库存
DELIMITER $$

DROP PROCEDURE IF EXISTS `up_pos_store_ys_inventory`$$

CREATE PROCEDURE `up_pos_store_ys_inventory`(
	    IN arg_hotel_group_id 	BIGINT(16),
	    IN arg_hotel_id 		BIGINT(16),
	    IN arg_biz_date 		DATETIME
    )
    SQL SECURITY INVOKER
BEGIN

	-- 明细表 pos_store_detail
	DELETE FROM pos_store_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND create_datetime=arg_biz_date AND INSTR(accnt,'Z-D')=1;
	INSERT INTO pos_store_detail(hotel_group_id,hotel_id,accnt,article_code,article_name,packing_size,unit,number,create_user,create_datetime,modify_user,modify_datetime)
	SELECT arg_hotel_group_id,arg_hotel_id,CONCAT("Z-D",UNIX_TIMESTAMP(),'#',a.pccode),c.art_code,c.art_name,b.unit,b.unit,SUM(b.number),'ADMIN',arg_biz_date,'ADMIN',arg_biz_date
		FROM pos_master a,pos_detail b,pos_store_plu_article c
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id
				AND c.hotel_group_id=arg_hotel_group_id AND c.hotel_id=arg_hotel_id AND a.sta NOT IN ('X','C') AND b.biz_date=arg_biz_date AND b.sta='I' AND a.accnt=b.accnt 
				AND LEFT(RIGHT(a.accnt, 10), 6) = DATE_FORMAT(arg_biz_date, '%y%m%d') AND b.code=c.plu_code AND SUBSTRING(b.flag,3,1) = 0 
				GROUP BY a.pccode,b.code HAVING SUM(b.number) <> 0;
				
	-- 单据表 pos_store_master  type = 01 入库	02	销售	03	调拔
	-- source_code 01:入库时为空 	02:销售时为管理营业点的吧台  03:调拔时为来源吧台
	-- target_code 01:入库时为吧台   02:销售时为营业点		    03:调拔时为目标吧台
	DELETE FROM pos_store_master WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND date =arg_biz_date AND INSTR(accnt,'Z-D')=1;
	INSERT INTO pos_store_master (sta,hotel_group_id,hotel_id,accnt,type,source_code,target_code,date,invoice,user_code,remark,create_user,create_datetime,modify_user,modify_datetime) 
	SELECT 'I',arg_hotel_group_id,arg_hotel_id,accnt,'02',
	(SELECT c.code FROM pos_store_bar c WHERE FIND_IN_SET(SUBSTR(accnt,INSTR(accnt,'#')+1),c.pccodes)>0 AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id),
	SUBSTR(accnt,INSTR(accnt,'#')+1),arg_biz_date,NULL,'ADMIN','','ADMIN',NOW(),'ADMIN',NOW()
		FROM pos_store_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND INSTR(accnt,'Z-D')=1 AND create_datetime=arg_biz_date GROUP BY accnt;

	-- 吧台库存表 pos_store_inventory 
	-- 本日库存 = 上日库存 + 本日入库 - 本日销售 +  本日调拨[调出\调入]
	DELETE FROM pos_store_inventory WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date;
	DROP TEMPORARY TABLE IF EXISTS tmp_pos_store_inventory;
	CREATE TEMPORARY TABLE tmp_pos_store_inventory(
		hotel_group_id 	INT,
		hotel_id		INT,
		bar_code		VARCHAR(20),
  		article_code 	VARCHAR(12) NOT NULL,
  		article_name 	VARCHAR(20) NOT NULL,
  		unit CHAR(4) 	DEFAULT '',
  		number DECIMAL(12,2) DEFAULT '0.00',
  		amount DECIMAL(12,2) DEFAULT '0.00',
  		KEY Index_1 (hotel_group_id,hotel_id,bar_code,article_code)
	);

	-- 上日库存
	INSERT INTO tmp_pos_store_inventory
		SELECT arg_hotel_group_id,arg_hotel_id,bar_code,article_code,article_name,unit,number,amount
			FROM pos_store_inventory WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = ADDDATE(arg_biz_date,-1);

	-- 本日入库
	INSERT INTO tmp_pos_store_inventory
		SELECT arg_hotel_group_id,arg_hotel_id,a.target_code,b.article_code,b.article_name,b.unit,SUM(b.number),0
			FROM pos_store_master a,pos_store_detail b WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id 
				AND b.hotel_id = arg_hotel_id AND a.accnt = b.accnt AND a.type = '01' AND a.date = arg_biz_date AND a.sta = 'I' GROUP BY a.target_code,b.article_code;

	-- 本日销售
	INSERT INTO tmp_pos_store_inventory
		SELECT arg_hotel_group_id,arg_hotel_id,a.source_code,b.article_code,b.article_name,b.unit,SUM(0 - b.number),0
			FROM pos_store_master a,pos_store_detail b WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id 
				AND b.hotel_id = arg_hotel_id AND a.accnt = b.accnt AND a.type = '02' AND a.date = arg_biz_date AND a.sta = 'I' GROUP BY a.source_code,b.article_code;
	
	-- 本日调拨 调出
	INSERT INTO tmp_pos_store_inventory
		SELECT arg_hotel_group_id,arg_hotel_id,a.source_code,b.article_code,b.article_name,b.unit,SUM(0 - b.number),0
			FROM pos_store_master a,pos_store_detail b WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id 
				AND b.hotel_id = arg_hotel_id AND a.accnt = b.accnt AND a.type = '03' AND a.date = arg_biz_date AND a.sta = 'I' GROUP BY a.source_code,b.article_code;			

	-- 本日调拨 调入
	INSERT INTO tmp_pos_store_inventory
		SELECT arg_hotel_group_id,arg_hotel_id,a.target_code,b.article_code,b.article_name,b.unit,SUM(b.number),0
			FROM pos_store_master a,pos_store_detail b WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id 
				AND b.hotel_id = arg_hotel_id AND a.accnt = b.accnt AND a.type = '03' AND a.date = arg_biz_date AND a.sta = 'I' GROUP BY a.target_code,b.article_code;

	-- 本日库存	
	INSERT INTO pos_store_inventory(hotel_group_id,hotel_id,bar_code,article_code,article_name,unit,number,amount,biz_date)
		SELECT hotel_group_id,hotel_id,bar_code,article_code,article_name,unit,SUM(number),amount,arg_biz_date FROM tmp_pos_store_inventory
			WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY bar_code,article_code HVAING SUM(number) <>0;
	
END$$

DELIMITER ;