DELIMITER $$

USE `portal`$$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_forecast_sywh_new`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_forecast_sywh_new`(
	IN 	arg_hotel_group_id	BIGINT(16),
	IN 	arg_hotel_id		BIGINT(16),
	IN  arg_begin_date		DATETIME,
	IN  arg_end_date		DATETIME
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- 三亚五号 预测报表
	DECLARE done_cursor 	INT DEFAULT 0 ;
	DECLARE var_bdate		DATETIME ;
	DECLARE var_bfdate		DATETIME ;
	DECLARE var_index		INT;
	DECLARE var_amount		DECIMAL(12,2);
	DECLARE var_ttl			DECIMAL(12,2);
	DECLARE var_occ			DECIMAL(12,2);
	DECLARE var_value		DECIMAL(12,2);
	DECLARE var_rmtype		VARCHAR(10);
	DECLARE var_int			INT;
	DECLARE var_catid		INT;
	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
		
	SELECT biz_date1 INTO var_bdate FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	SET var_bfdate = ADDDATE(var_bdate, -1); 
	
	IF arg_begin_date < var_bdate THEN
		SET arg_begin_date = var_bdate;
	END IF;
	
	SET var_index = DATEDIFF(arg_end_date,arg_begin_date);
	IF  var_index > 31 THEN
		SET arg_end_date = ADDDATE(arg_begin_date,INTERVAL 31 DAY);
	
	END IF;
	
	TRUNCATE TABLE rep_forecast_sywh;
	
	DROP TEMPORARY TABLE IF EXISTS tmp_rmtype_son;
	CREATE TEMPORARY TABLE tmp_rmtype_son (
		rmtype		VARCHAR(5),
		descript	VARCHAR(60),
		quan		INT,
		KEY index1(rmtype)
	);
	INSERT INTO tmp_rmtype_son (rmtype,quan)
		SELECT DISTINCT rmtype,rmnum FROM (
			SELECT a.rmtype AS rmtype,a.code AS aa,b.code AS bb,COUNT(1) AS rmnum FROM room_no a
			LEFT JOIN room_no b ON b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.parent_code=a.code
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.parent_code='' GROUP BY a.code
			UNION
			SELECT a.rmtype AS rmtype,a.code AS aa,b.code AS bb,COUNT(1) AS rmnum FROM room_no a
			LEFT JOIN room_no b ON b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.parent_code=a.code
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.parent_code<>'' GROUP BY a.code ORDER BY rmtype) AS aa;
	
	SET var_catid = 1;	
	WHILE arg_begin_date <= arg_end_date DO
		BEGIN
			
		SELECT COUNT(1) INTO var_amount FROM room_no WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND (is_villa='S' OR is_villa='');
			SET var_ttl = var_amount;
			INSERT INTO rep_forecast_sywh VALUES (arg_hotel_group_id,arg_hotel_id,var_catid,arg_begin_date,'','#000','#00',' 总房数',var_amount);
	
		
		CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','Out of Order',var_amount);
			INSERT INTO rep_forecast_sywh VALUES (arg_hotel_group_id,arg_hotel_id,var_catid,arg_begin_date,'','#444','#Z4',' 总维修',var_amount);
		
		CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','Out of Service',var_amount);
			INSERT INTO rep_forecast_sywh VALUES (arg_hotel_group_id,arg_hotel_id,var_catid,arg_begin_date,'','#445','#Z4',' 总锁房',var_amount);
		
		CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','HSE',var_amount);
			INSERT INTO rep_forecast_sywh VALUES (arg_hotel_group_id,arg_hotel_id,var_catid,arg_begin_date,'','#500','',' 自用房',var_amount);
		
		CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','Departure Rooms',var_amount);
			INSERT INTO rep_forecast_sywh VALUES (arg_hotel_group_id,arg_hotel_id,var_catid,arg_begin_date,'','ZZ30','ZZ3',' 本日退',var_amount);
		
		CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','People In Hotel',var_amount);
			INSERT INTO rep_forecast_sywh VALUES (arg_hotel_group_id,arg_hotel_id,var_catid,arg_begin_date,'','#892','#ZZ6',' 在店客人',var_amount);	
	
		CALL up_ihotel_forecast_index_detail(arg_hotel_group_id,arg_hotel_id,arg_begin_date,'%','Arrival Rooms',var_amount);
		INSERT INTO rep_forecast_sywh VALUES (arg_hotel_group_id,arg_hotel_id,var_catid,arg_begin_date,'','ZZ20','ZZ2',' 当日到',var_amount);
	
			
		-- 小房
		IF var_bdate = arg_begin_date THEN
			INSERT INTO rep_forecast_sywh
				SELECT arg_hotel_group_id,arg_hotel_id,var_catid,arg_begin_date,'',0,rmtype,'',SUM(rmnum)
				FROM (SELECT a.rmtype AS rmtype,IFNULL(COUNT(DISTINCT a.master_id,a.rmno_son),0) AS rmnum FROM master_base a,rsv_src b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.id=b.accnt AND a.id <> a.rsv_id AND a.rsv_class = 'F' AND b.occ_flag = 'MF' AND b.arr_date <= arg_begin_date AND b.dep_date > arg_begin_date GROUP BY a.rmtype
				UNION ALL
				SELECT b.rmtype AS rmtype,IFNULL(SUM(b.rmnum),0) AS rmnum FROM master_base a,rsv_src b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id
				AND a.id=b.accnt AND a.id = a.rsv_id AND a.rsv_class IN('F','G') AND b.occ_flag IN('RF','RG') AND b.arr_date <= arg_begin_date AND b.dep_date > arg_begin_date GROUP BY a.rmtype) temp GROUP BY rmtype;
				
			INSERT INTO rep_forecast_sywh
				SELECT arg_hotel_group_id,arg_hotel_id,var_catid,arg_begin_date,'',0,a.code,'',0
					FROM room_type a WHERE NOT EXISTS(SELECT 1 FROM rep_forecast_sywh b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.type=a.code AND b.sort=0 AND b.biz_date=arg_begin_date ) AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.is_halt='F';
		ELSE
			INSERT INTO rep_forecast_sywh
				SELECT arg_hotel_group_id,arg_hotel_id,var_catid,arg_begin_date,'',0,a.rmtype,CONCAT(a.rmtype,':',a.descript),a.quan*(IFNULL(sure_book_num,0) + IFNULL(unsure_book_num,0)) 
				FROM tmp_rmtype_son a,rsv_rmtype_total b WHERE a.rmtype=b.rmtype AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.occ_date=arg_begin_date;
		END IF;
		
		-- 大房
		INSERT INTO rep_forecast_sywh
			SELECT arg_hotel_group_id,arg_hotel_id,var_catid,arg_begin_date,'','#8900', 'ZZ50',' 总占房[大房]',SUM(sure_book_num + unsure_book_num)
				FROM rsv_rmtype_total WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND occ_date=arg_begin_date;
		SELECT IFNULL(SUM(amount),0) INTO var_occ FROM rep_forecast_sywh WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_begin_date AND sort='0' AND catid=var_catid;
		
		
		SELECT IFNULL(SUM(IFNULL(b.real_share_rate,a.real_rate) * a.rmnum),0) INTO var_amount FROM rsv_src AS a              
		LEFT JOIN rsv_rate AS b ON b.rsv_src_id = a.id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.rsv_date = arg_begin_date
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arr_date <= arg_begin_date AND a.dep_date > arg_begin_date
		AND (a.occ_flag = 'MF' OR a.occ_flag = 'RF' OR a.occ_flag = 'RG');		
		
		INSERT INTO rep_forecast_sywh VALUES (arg_hotel_group_id,arg_hotel_id,var_catid,arg_begin_date,'','ZZ91','ZZ6','客房收入',var_amount);
		IF var_occ <> 0 THEN
			SET var_amount = ROUND(var_amount/var_occ,2);
		ELSE
			SET var_amount = 0;
		END IF;
		INSERT INTO rep_forecast_sywh VALUES (arg_hotel_group_id,arg_hotel_id,var_catid,arg_begin_date,'','ZZ96','ZZ6','平均房价-1',var_amount);
		
		
		SELECT IFNULL(SUM(IFNULL(b.rm_fee_net+b.rm_fee_srv,a.real_rate) * a.rmnum),0) INTO var_amount FROM rsv_src AS a              
		LEFT JOIN rsv_rate AS b ON b.rsv_src_id = a.id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.rsv_date = arg_begin_date
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arr_date <= arg_begin_date AND a.dep_date > arg_begin_date
		AND (a.occ_flag = 'MF' OR a.occ_flag = 'RF' OR a.occ_flag = 'RG');		
		
		
		INSERT INTO rep_forecast_sywh VALUES (arg_hotel_group_id,arg_hotel_id,var_catid,arg_begin_date,'','ZZ92','ZZ6','客房收入[服务费]',var_amount);
		IF var_occ <> 0 THEN
			SET var_amount = ROUND(var_amount/var_occ,2);
		ELSE
			SET var_amount = 0;
		END IF;
		INSERT INTO rep_forecast_sywh VALUES (arg_hotel_group_id,arg_hotel_id,var_catid,arg_begin_date,'','ZZ97','ZZ6','平均房价-2',var_amount);
		
		
		SELECT IFNULL(SUM(IFNULL(b.rm_fee_net+b.rm_fee_srv+b.rm_fee_bf,a.real_rate) * a.rmnum),0) INTO var_amount FROM rsv_src AS a              
		LEFT JOIN rsv_rate AS b ON b.rsv_src_id = a.id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.rsv_date = arg_begin_date
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arr_date <= arg_begin_date AND a.dep_date > arg_begin_date
		AND (a.occ_flag = 'MF' OR a.occ_flag = 'RF' OR a.occ_flag = 'RG');	
		INSERT INTO rep_forecast_sywh VALUES (arg_hotel_group_id,arg_hotel_id,var_catid,arg_begin_date,'','ZZ93','ZZ6','客房收入[包价服务费]',var_amount);
		IF var_occ <> 0 THEN
			SET var_amount = ROUND(var_amount/var_occ,2);
		ELSE
			SET var_amount = 0;
		END IF;
		INSERT INTO rep_forecast_sywh VALUES (arg_hotel_group_id,arg_hotel_id,var_catid,arg_begin_date,'','ZZ98','ZZ6','平均房价-3',var_amount);
		
		
		SET arg_begin_date = ADDDATE(arg_begin_date,INTERVAL 1 DAY);
		SET var_catid = var_catid + 1;
		SET done_cursor = 1;
		END;
	END WHILE;
	
	
	INSERT INTO rep_forecast_sywh
		SELECT arg_hotel_group_id,arg_hotel_id,catid,biz_date,'','#888', '#88',' 可用房',var_ttl-SUM(amount)
			FROM rep_forecast_sywh WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND sort IN ('#444','#445','#500') GROUP BY catid,arg_begin_date;
	
	INSERT INTO rep_forecast_sywh
		SELECT arg_hotel_group_id,arg_hotel_id,catid,biz_date,'','#890', 'ZZ5',' 总占房[小房]',SUM(amount)
			FROM rep_forecast_sywh WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND sort NOT LIKE 'ZZ%' AND sort NOT LIKE '#%' GROUP BY catid,biz_date;
				
	
	INSERT INTO rep_forecast_sywh
		SELECT arg_hotel_group_id,arg_hotel_id,catid,biz_date,'','#895', 'ZZ1',' 总存量',SUM(amount)
			FROM rep_forecast_sywh WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND sort IN ('#890','#444','#445') GROUP BY catid,biz_date;
	
	
	
	INSERT INTO rep_forecast_sywh
		SELECT arg_hotel_group_id,arg_hotel_id,a.catid,a.biz_date,'','ZZ80', 'ZZZ',' 占房率1(%)',
		ROUND(a.amount*100/(SELECT b.amount FROM rep_forecast_sywh b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.biz_date=b.biz_date AND b.sort='#000'),2)
			FROM rep_forecast_sywh a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.sort='#890';
			
	
	INSERT INTO rep_forecast_sywh
		SELECT arg_hotel_group_id,arg_hotel_id,a.catid,a.biz_date,'','ZZ81', 'ZZZ',' 占房率3(%)',
		ROUND(a.amount*100/(SELECT b.amount FROM rep_forecast_sywh b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.biz_date=b.biz_date AND b.sort='#888'),2)
			FROM rep_forecast_sywh a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.sort='#890';
	
	
	UPDATE rep_forecast_sywh a,room_type b SET a.descript = CONCAT(b.code,':',RTRIM(b.descript)) WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.type=b.code;
			
	
	UPDATE rep_forecast_sywh SET datedes = IF(MONTH(biz_date)=MONTH(arg_begin_date),CONCAT('2',SUBSTRING(DATE_FORMAT(biz_date,'%Y-%m-%d'),9,2),'(S)'),CONCAT('1',SUBSTRING(DATE_FORMAT(biz_date,'%Y-%m-%d'),9,2),'(S)')) WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND DATE_FORMAT(biz_date,'%w')='0';
	UPDATE rep_forecast_sywh SET datedes = IF(MONTH(biz_date)=MONTH(arg_begin_date),CONCAT('2',SUBSTRING(DATE_FORMAT(biz_date,'%Y-%m-%d'),9,2),'(M)'),CONCAT('1',SUBSTRING(DATE_FORMAT(biz_date,'%Y-%m-%d'),9,2),'(M)')) WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND DATE_FORMAT(biz_date,'%w')='1';
	UPDATE rep_forecast_sywh SET datedes = IF(MONTH(biz_date)=MONTH(arg_begin_date),CONCAT('2',SUBSTRING(DATE_FORMAT(biz_date,'%Y-%m-%d'),9,2),'(T)'),CONCAT('1',SUBSTRING(DATE_FORMAT(biz_date,'%Y-%m-%d'),9,2),'(T)')) WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND DATE_FORMAT(biz_date,'%w')='2';
	UPDATE rep_forecast_sywh SET datedes = IF(MONTH(biz_date)=MONTH(arg_begin_date),CONCAT('2',SUBSTRING(DATE_FORMAT(biz_date,'%Y-%m-%d'),9,2),'(W)'),CONCAT('1',SUBSTRING(DATE_FORMAT(biz_date,'%Y-%m-%d'),9,2),'(W)')) WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND DATE_FORMAT(biz_date,'%w')='3';
	UPDATE rep_forecast_sywh SET datedes = IF(MONTH(biz_date)=MONTH(arg_begin_date),CONCAT('2',SUBSTRING(DATE_FORMAT(biz_date,'%Y-%m-%d'),9,2),'(T)'),CONCAT('1',SUBSTRING(DATE_FORMAT(biz_date,'%Y-%m-%d'),9,2),'(T)')) WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND DATE_FORMAT(biz_date,'%w')='4';
	UPDATE rep_forecast_sywh SET datedes = IF(MONTH(biz_date)=MONTH(arg_begin_date),CONCAT('2',SUBSTRING(DATE_FORMAT(biz_date,'%Y-%m-%d'),9,2),'(F)'),CONCAT('1',SUBSTRING(DATE_FORMAT(biz_date,'%Y-%m-%d'),9,2),'(F)')) WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND DATE_FORMAT(biz_date,'%w')='5';
	UPDATE rep_forecast_sywh SET datedes = IF(MONTH(biz_date)=MONTH(arg_begin_date),CONCAT('2',SUBSTRING(DATE_FORMAT(biz_date,'%Y-%m-%d'),9,2),'(S)'),CONCAT('1',SUBSTRING(DATE_FORMAT(biz_date,'%Y-%m-%d'),9,2),'(S)')) WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND DATE_FORMAT(biz_date,'%w')='6';	
	
	INSERT INTO rep_forecast_sywh
		SELECT arg_hotel_group_id,arg_hotel_id,99,'2030-01-01','TOTAL',sort,TYPE,descript,0 FROM rep_forecast_sywh WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND catid=1;
		
	UPDATE rep_forecast_sywh a SET a.amount = (SELECT SUM(b.amount) FROM (SELECT * FROM rep_forecast_sywh WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id) AS b WHERE a.sort=b.sort AND a.type=b.type) 
		WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date='2030-01-01' AND a.catid=99;
	
	
	SELECT amount INTO var_amount FROM rep_forecast_sywh WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date='2030-01-01' AND catid=99 AND sort='#888';
	IF var_amount <> 0 THEN
		UPDATE rep_forecast_sywh SET amount = ROUND((SELECT b.amount FROM (SELECT * FROM rep_forecast_sywh) AS b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date='2030-01-01' AND b.catid=99 AND b.sort='#890')*100/var_amount,2)
			WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date='2030-01-01' AND catid=99 AND sort='ZZ80';
	END IF;
	
	
	SELECT amount INTO var_amount FROM rep_forecast_sywh WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date='2030-01-01' AND catid=99 AND sort='#890';
	IF var_amount <> 0 THEN
		BEGIN
		UPDATE rep_forecast_sywh SET amount = ROUND((SELECT b.amount FROM (SELECT * FROM rep_forecast_sywh) AS b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date='2030-01-01' AND b.catid=99 AND b.sort='ZZ91')/var_amount,2)
			WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date='2030-01-01' AND catid=99 AND sort='ZZ96';
		UPDATE rep_forecast_sywh SET amount = ROUND((SELECT b.amount FROM (SELECT * FROM rep_forecast_sywh) AS b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date='2030-01-01' AND b.catid=99 AND b.sort='ZZ92')/var_amount,2)
			WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date='2030-01-01' AND catid=99 AND sort='ZZ97';
		UPDATE rep_forecast_sywh SET amount = ROUND((SELECT b.amount FROM (SELECT * FROM rep_forecast_sywh) AS b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.biz_date='2030-01-01' AND b.catid=99 AND b.sort='ZZ93')/var_amount,2)
			WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date='2030-01-01' AND catid=99 AND sort='ZZ98';
		END;
	END IF;
	
	SELECT sort,datedes,descript,amount FROM rep_forecast_sywh WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id ORDER BY catid,sort;
	
	DROP TEMPORARY TABLE tmp_rmtype_son;
END$$

DELIMITER ;