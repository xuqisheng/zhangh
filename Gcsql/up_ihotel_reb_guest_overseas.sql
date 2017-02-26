DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_reb_guest_overseas`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_reb_guest_overseas`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT,
	IN arg_begin_date		DATETIME
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ==================================================================
	-- 用途：重建境外人数统计	
	-- 解释: 
	-- 范例: 
	-- 作者：
	-- ==================================================================
	DECLARE done_cursor INT DEFAULT 0;
	DECLARE var_duringaudit		CHAR(1);	
	DECLARE var_heji 	CHAR(2);
	DECLARE var_jingnei CHAR(2);
	DECLARE var_shengnei CHAR(2);
	DECLARE var_shengwai CHAR(2);
	DECLARE var_jingwai CHAR(2);
	DECLARE var_huaqiao CHAR(2);
	DECLARE var_hongkong CHAR(2);
	DECLARE var_taiwan 	CHAR(2);
	DECLARE var_macao 	CHAR(2);
	DECLARE var_waibin 	CHAR(2);
	DECLARE var_noaddress CHAR(2);
	DECLARE var_nonation CHAR(2);
	DECLARE var_sta		 CHAR(1);
	DECLARE var_lclpro   VARCHAR(6);
	DECLARE var_province VARCHAR(6);
	DECLARE var_accnt	 BIGINT(12);
	DECLARE var_nation	 VARCHAR(10);
	DECLARE var_arr		 DATETIME;
	DECLARE var_division VARCHAR(6);
	DECLARE var_idno	 VARCHAR(20);
	DECLARE var_grpaccnt BIGINT(12);
	DECLARE var_bfdate 	 DATETIME;
	DECLARE var_bfldate  DATETIME;
	DECLARE var_bdate  DATETIME;
	DECLARE c_cursor CURSOR FOR SELECT id,nation,arr,sta,division,id_no,grp_accnt FROM temp_overseas;	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	
	DELETE FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE >= arg_begin_date;
	DELETE FROM guest_sta_overseas_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE >= arg_begin_date;

	SELECT biz_date INTO var_bdate FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	SET var_bdate= DATE_ADD(var_bdate,INTERVAL -1 DAY);
	INSERT INTO guest_sta_overseas SELECT * FROM guest_sta_overseas_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE = DATE_ADD(arg_begin_date,INTERVAL -1 DAY);

	DROP TEMPORARY TABLE IF EXISTS temp_overseas;
	CREATE TEMPORARY TABLE temp_overseas(
		id			BIGINT(16),
		nation		VARCHAR(10) NOT NULL,
		biz_date	DATETIME,
		arr			DATETIME,
		sta			CHAR(1),
		division	VARCHAR(6)  NOT NULL,
		id_no		VARCHAR(20) NOT NULL,
		grp_accnt	BIGINT(16),
		KEY index1(id)
	);	
	
	WHILE arg_begin_date <= var_bdate DO
		BEGIN
			SET var_bfdate = DATE_ADD(arg_begin_date,INTERVAL -1 DAY);
			SET var_bfldate = DATE_ADD(arg_begin_date,INTERVAL -2 DAY);
			
			INSERT INTO temp_overseas(id,nation,biz_date,arr,sta,division,id_no,grp_accnt)
			SELECT a.accnt,'',a.biz_date,a.arr,a.sta,'','',a.grpaccnt FROM production_detail a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date=arg_begin_date
				AND a.master_type = 'MASTER' AND (a.sta ='I' OR (a.sta IN ('S','O') AND NOT EXISTS(SELECT 1 FROM production_detail b WHERE a.accnt=b.accnt AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.biz_date=var_bfdate)));
				
			UPDATE temp_overseas a,master_base b,master_guest c SET a.arr = DATE_FORMAT(b.arr,'%Y-%m-%d'),a.nation = c.nation,a.division = c.division,a.id_no=c.id_no
				WHERE a.id = b.id AND a.id = c.id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.hotel_group_id = c.hotel_group_id AND b.hotel_id = c.hotel_id;
			UPDATE temp_overseas a,master_base_history b,master_guest_history c SET a.arr = DATE_FORMAT(b.arr,'%Y-%m-%d'),a.nation = c.nation,a.division = c.division,a.id_no=c.id_no
				WHERE a.id = b.id AND a.id = c.id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.hotel_group_id = c.hotel_group_id AND b.hotel_id = c.hotel_id;
		
			SELECT TRIM(province_code) INTO var_lclpro FROM hotel WHERE id = arg_hotel_id;	
			SET var_heji ='1', var_jingnei = '2',var_shengnei='01', var_shengwai='02', var_noaddress='03';
			SET var_jingwai ='3',var_hongkong='01', var_taiwan='02', var_macao='03', var_waibin='04';	
			IF NOT EXISTS (SELECT 1 FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_heji) THEN
				INSERT guest_sta_overseas(hotel_group_id,hotel_id,DATE, guest_class, list_order, descript, descript1,nation,sequence) VALUES (arg_hotel_group_id,arg_hotel_id,NOW(), var_heji, '', '合  计', 'Total','',0);
			END IF;
			IF NOT EXISTS (SELECT 1 FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_jingnei) THEN
				INSERT guest_sta_overseas(hotel_group_id,hotel_id,DATE, guest_class, list_order, descript, descript1 ,nation,sequence) VALUES (arg_hotel_group_id,arg_hotel_id,NOW(), var_jingnei, '', '境  内','Nationals','',0);
			END IF;
			IF NOT EXISTS (SELECT 1 FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_jingnei AND RTRIM(list_order) = var_shengnei) THEN
				INSERT guest_sta_overseas (hotel_group_id,hotel_id,DATE, guest_class, list_order, descript, descript1 ,nation,sequence) VALUES (arg_hotel_group_id,arg_hotel_id,NOW(), var_jingnei, var_shengnei, '省  内','Province Inside','',0);
			END IF;
			IF NOT EXISTS (SELECT 1 FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_jingnei AND RTRIM(list_order) = var_shengwai) THEN
				INSERT guest_sta_overseas(hotel_group_id,hotel_id,DATE, guest_class, list_order, descript, descript1,nation,sequence) VALUES (arg_hotel_group_id,arg_hotel_id,NOW(), var_jingnei, var_shengwai, '省  外', 'Province Outside','',0);
			END IF;
			IF NOT EXISTS (SELECT 1 FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_jingnei AND list_order=var_noaddress) THEN
				INSERT guest_sta_overseas(hotel_group_id,hotel_id,DATE, guest_class, list_order, descript, descript1,nation,sequence) VALUES (arg_hotel_group_id,arg_hotel_id,NOW(), var_jingnei, var_noaddress, '地址不详', 'No Address','',0);
			END IF;
			IF NOT EXISTS (SELECT 1 FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_jingwai) THEN
				INSERT guest_sta_overseas(hotel_group_id,hotel_id,DATE, guest_class, list_order, descript, descript1,nation,sequence) VALUES (arg_hotel_group_id,arg_hotel_id,NOW(), var_jingwai, '', '境  外', 'Overseas','',0);
			END IF;
			
			IF NOT EXISTS (SELECT 1 FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_jingwai AND list_order = var_hongkong) THEN
				INSERT guest_sta_overseas(hotel_group_id,hotel_id,DATE, guest_class, list_order, nation, descript, descript1,sequence) VALUES (arg_hotel_group_id,arg_hotel_id,NOW(), var_jingwai, var_hongkong, 'HK', '香  港', 'Hong Kong',0);
			END IF;
			IF NOT EXISTS (SELECT 1 FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_jingwai AND list_order = var_macao) THEN
				INSERT guest_sta_overseas(hotel_group_id,hotel_id,DATE, guest_class, list_order, nation, descript, descript1,sequence) VALUES (arg_hotel_group_id,arg_hotel_id,NOW(), var_jingwai, var_macao, 'MO', '澳  门', 'Macao',0);
			END IF;
			IF NOT EXISTS (SELECT 1 FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_jingwai AND list_order = var_taiwan) THEN
				INSERT guest_sta_overseas(hotel_group_id,hotel_id,DATE, guest_class, list_order, nation, descript, descript1,sequence) VALUES (arg_hotel_group_id,arg_hotel_id,NOW(), var_jingwai, var_taiwan, 'TW', '台  湾', 'TaiWan',0);
			END IF;
			IF NOT EXISTS (SELECT 1 FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_jingwai AND nation='' AND list_order = var_nonation) THEN
				INSERT guest_sta_overseas(hotel_group_id,hotel_id,DATE, guest_class, list_order, nation, descript, descript1,sequence) VALUES (arg_hotel_group_id,arg_hotel_id,NOW(), var_jingwai,var_nonation,'','境外不祥', 'NoNation',0);
			END IF;			
			
			IF EXISTS(SELECT 1 FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE = arg_begin_date) THEN
				UPDATE guest_sta_overseas SET
										   mtc = mtc-dtc, mtt = mtt-dtt, mgc = mgc-dgc, mgt = mgt-dgt, mmc = mmc-dmc, mmt = mmt-dmt, 
										   ytc = ytc-dtc, ytt = ytt-dtt, ygc = ygc-dgc, ygt = ygt-dgt, ymc = ymc-dmc, ymt = ymt-dmt 
				WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
			END IF;	
			
			UPDATE guest_sta_overseas SET dtc = 0, dtt = 0, dgc = 0, dgt = 0, dmc = 0, dmt = 0, DATE = var_bfdate WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
			
			OPEN c_cursor ;
			SET done_cursor = 0 ;
			FETCH c_cursor INTO var_accnt,var_nation,var_arr,var_sta,var_division,var_idno,var_grpaccnt;
				WHILE done_cursor = 0 DO
					BEGIN
						IF TRIM(var_division)='' AND TRIM(var_nation)='CN' AND TRIM(var_idno)<>'' AND CHAR_LENGTH(var_idno)>=15 THEN
							SET var_division = SUBSTRING(var_idno,1,6);
						END IF;
						
						IF NOT EXISTS(SELECT 1 FROM code_division WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND CODE=var_division) THEN
							SET var_division = '';
						END IF;
						SET var_province = '';
						SELECT IFNULL(province,'') INTO var_province FROM code_division WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND CODE=var_division;
						
						IF var_grpaccnt <> 0 THEN	-- 团队
							IF var_arr <= arg_begin_date AND var_sta = 'I' THEN	-- 人天
								UPDATE guest_sta_overseas SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_heji; 
								IF var_nation = 'CN' THEN
									UPDATE guest_sta_overseas SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei AND list_order = ''; 
									IF var_province IS NULL OR var_province = '' THEN
										UPDATE guest_sta_overseas SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei AND list_order = var_noaddress;
									ELSEIF var_lclpro = var_province THEN
										UPDATE guest_sta_overseas SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei AND list_order = var_shengnei; 
									ELSE
										UPDATE guest_sta_overseas SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei AND list_order = var_shengwai;
									END IF;				
								ELSE
									UPDATE guest_sta_overseas SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = ''; 
									IF var_nation = 'HK' THEN 
										UPDATE guest_sta_overseas SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_hongkong AND nation = 'HK';
									ELSEIF var_nation = 'MO' THEN 
										UPDATE guest_sta_overseas SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_macao AND nation = 'MO';
									ELSEIF var_nation = 'TW' THEN 
										UPDATE guest_sta_overseas SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_taiwan AND nation = 'TW';
									ELSE									
										UPDATE guest_sta_overseas SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_waibin AND nation = '';
										IF NOT EXISTS(SELECT 1 FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_waibin AND nation = var_nation) THEN
											INSERT guest_sta_overseas (hotel_group_id,hotel_id,DATE, guest_class, nation,list_order, descript, descript1) 
												SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,var_jingwai,var_nation,'04',a.descript,a.descript_en FROM code_country a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = var_nation;
										END IF;									
										UPDATE guest_sta_overseas SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_waibin AND nation = var_nation;
									END IF;					
								END IF;
							END IF;						
							IF var_arr=arg_begin_date THEN	-- 人次
								UPDATE guest_sta_overseas SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_heji; 
								IF var_nation = 'CN' THEN
									UPDATE guest_sta_overseas SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei AND list_order = ''; 
									IF var_province IS NULL OR var_province = '' THEN
										UPDATE guest_sta_overseas SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei AND list_order = var_noaddress;
									ELSEIF var_lclpro = var_province THEN
										UPDATE guest_sta_overseas SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei AND list_order = var_shengnei; 
									ELSE
										UPDATE guest_sta_overseas SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei AND list_order = var_shengwai;
									END IF;				
								ELSE
									UPDATE guest_sta_overseas SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = ''; 
									IF var_nation = 'HK' THEN 
										UPDATE guest_sta_overseas SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_hongkong AND nation = 'HK';
									ELSEIF var_nation = 'MO' THEN 
										UPDATE guest_sta_overseas SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_macao AND nation = 'MO';
									ELSEIF var_nation = 'TW' THEN 
										UPDATE guest_sta_overseas SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_taiwan AND nation = 'TW';
									ELSE									
										UPDATE guest_sta_overseas SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_waibin AND nation = '';
										IF NOT EXISTS(SELECT 1 FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_waibin AND nation = var_nation) THEN
											INSERT guest_sta_overseas (hotel_group_id,hotel_id,DATE, guest_class, nation,list_order, descript, descript1) 
												SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,var_jingwai,var_nation,'04',a.descript,a.descript_en FROM code_country a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = var_nation;
										END IF;									
										UPDATE guest_sta_overseas SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_waibin AND nation = var_nation;
									END IF;					
								END IF;						
							END IF;
						ELSE	-- 散客
							IF var_arr <= arg_begin_date AND var_sta = 'I' THEN	-- 人天
								UPDATE guest_sta_overseas SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_heji; 
								IF var_nation = 'CN' THEN
									UPDATE guest_sta_overseas SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei AND list_order = ''; 
									IF var_province IS NULL OR var_province = '' THEN
										UPDATE guest_sta_overseas SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei AND list_order = var_noaddress;
									ELSEIF var_lclpro = var_province THEN
										UPDATE guest_sta_overseas SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei AND list_order = var_shengnei; 
									ELSE
										UPDATE guest_sta_overseas SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei AND list_order = var_shengwai;
									END IF;				
								ELSE
									UPDATE guest_sta_overseas SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = ''; 
									IF var_nation = 'HK' THEN 
										UPDATE guest_sta_overseas SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_hongkong AND nation = 'HK';
									ELSEIF var_nation = 'MO' THEN 
										UPDATE guest_sta_overseas SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_macao AND nation = 'MO';
									ELSEIF var_nation = 'TW' THEN 
										UPDATE guest_sta_overseas SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_taiwan AND nation = 'TW';
									ELSE									
										UPDATE guest_sta_overseas SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_waibin AND nation = '';
										IF NOT EXISTS(SELECT 1 FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_waibin AND nation = var_nation) THEN
											INSERT guest_sta_overseas (hotel_group_id,hotel_id,DATE, guest_class, nation,list_order, descript, descript1) 
												SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,var_jingwai,var_nation,'04',a.descript,a.descript_en FROM code_country a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = var_nation;
										END IF;									
										UPDATE guest_sta_overseas SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_waibin AND nation = var_nation;
									END IF;					
								END IF;
							END IF;						
							IF var_arr=arg_begin_date THEN	-- 人次
								UPDATE guest_sta_overseas SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_heji; 
								IF var_nation = 'CN' THEN
									UPDATE guest_sta_overseas SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei AND list_order = ''; 
									IF var_province IS NULL OR var_province = '' THEN
										UPDATE guest_sta_overseas SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei AND list_order = var_noaddress;
									ELSEIF var_lclpro = var_province THEN
										UPDATE guest_sta_overseas SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei AND list_order = var_shengnei; 
									ELSE
										UPDATE guest_sta_overseas SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei AND list_order = var_shengwai;
									END IF;				
								ELSE
									UPDATE guest_sta_overseas SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = ''; 
									IF var_nation = 'HK' THEN 
										UPDATE guest_sta_overseas SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_hongkong AND nation = 'HK';
									ELSEIF var_nation = 'MO' THEN 
										UPDATE guest_sta_overseas SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_macao AND nation = 'MO';
									ELSEIF var_nation = 'TW' THEN 
										UPDATE guest_sta_overseas SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_taiwan AND nation = 'TW';
									ELSE									
										UPDATE guest_sta_overseas SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_waibin AND nation = '';
										IF NOT EXISTS(SELECT 1 FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_waibin AND nation = var_nation) THEN
											INSERT guest_sta_overseas (hotel_group_id,hotel_id,DATE, guest_class, nation,list_order, descript, descript1) 
												SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,var_jingwai,var_nation,'04',a.descript,a.descript_en FROM code_country a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = var_nation;
										END IF;									
										UPDATE guest_sta_overseas SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai AND list_order = var_waibin AND nation = var_nation;
									END IF;					
								END IF;						
							END IF;					
						END IF;
					SET done_cursor = 0 ;
					FETCH c_cursor INTO var_accnt,var_nation,var_arr,var_sta,var_division,var_idno,var_grpaccnt;
					END;
				END WHILE ;
			CLOSE c_cursor;
			IF EXISTS(SELECT 1 FROM biz_month WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND begin_date = arg_begin_date) THEN
				UPDATE guest_sta_overseas SET mtc = dtc, mtt = dtt, mgc = dgc, mgt = dgt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
			ELSE
				UPDATE guest_sta_overseas SET mtc = mtc + dtc, mtt = mtt + dtt, mgc = mgc + dgc, mgt = mgt + dgt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
			END IF;
			
			IF EXISTS(SELECT 1 FROM biz_month WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_month = 1 AND begin_date = arg_begin_date) THEN
				UPDATE guest_sta_overseas SET ytc = dtc, ytt = dtt, ygc = dgc, ygt = dgt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
			ELSE
				UPDATE guest_sta_overseas SET ytc = ytc + dtc, ytt = ytt + dtt, ygc = ygc + dgc, ygt = ygt + dgt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
			END IF;
			
			UPDATE guest_sta_overseas SET DATE = arg_begin_date WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
			
			DELETE FROM guest_sta_overseas_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE = arg_begin_date ;
			INSERT INTO guest_sta_overseas_history SELECT * FROM guest_sta_overseas WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
			DELETE FROM temp_overseas WHERE biz_date=arg_begin_date;
			SET arg_begin_date = DATE_ADD(arg_begin_date,INTERVAL 1 DAY);
		END;
	END WHILE;	
	
	DROP TEMPORARY TABLE IF EXISTS temp_overseas;
		
END$$

DELIMITER ;


CALL up_ihotel_reb_guest_overseas(1,103,'2014-10-30');

DROP PROCEDURE IF EXISTS `up_ihotel_reb_guest_overseas`;