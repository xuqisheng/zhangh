DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_reb_guest_internal`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_reb_guest_internal`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT,
	IN arg_begin_date		DATETIME
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ==================================================================
	-- 用途：重建境内人数统计	
	-- 解释: 
	-- 范例: 
	-- 作者：
	-- ==================================================================
	DECLARE done_cursor INT DEFAULT 0;	
	DECLARE var_heji 	 CHAR(2);
	DECLARE var_jingwai  CHAR(2);
	DECLARE var_jingnei  CHAR(2);
	DECLARE var_shengnei CHAR(2);
	DECLARE var_shengwai CHAR(2);
	DECLARE var_buxiang  CHAR(2);
	DECLARE var_sta		 CHAR(1);
	DECLARE var_lclpro   VARCHAR(6);
	DECLARE var_province VARCHAR(6);
	DECLARE var_accnt	 BIGINT(12);
	DECLARE var_nation	 VARCHAR(10);
	DECLARE var_arr		 DATETIME;
	DECLARE var_division VARCHAR(6);
	DECLARE var_idno	 VARCHAR(20);
	DECLARE var_grpaccnt BIGINT(12);	
	DECLARE var_bfdate DATETIME;
	DECLARE var_bfldate DATETIME;
	DECLARE var_bdate DATETIME;	
	DECLARE c_cursor CURSOR FOR SELECT id,nation,arr,sta,division,id_no,grp_accnt FROM temp_internal;	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	
	DELETE FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE >= arg_begin_date;
	DELETE FROM guest_sta_inland_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE >= arg_begin_date;
	
	SELECT biz_date INTO var_bdate FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	SET var_bdate= DATE_ADD(var_bdate,INTERVAL -1 DAY);
	INSERT INTO guest_sta_inland SELECT * FROM guest_sta_inland_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE = DATE_ADD(arg_begin_date,INTERVAL -1 DAY);
	
	DROP TEMPORARY TABLE IF EXISTS temp_internal;
	CREATE TEMPORARY TABLE temp_internal(
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
			
			INSERT INTO temp_internal(id,nation,biz_date,arr,sta,division,id_no,grp_accnt)
			SELECT a.accnt,'',a.biz_date,a.arr,a.sta,'','',a.grpaccnt FROM production_detail a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.biz_date=arg_begin_date
				AND a.master_type = 'MASTER' AND (a.sta ='I' OR (a.sta IN ('S','O') AND NOT EXISTS(SELECT 1 FROM production_detail b WHERE a.accnt=b.accnt AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.biz_date=var_bfdate)));
				
			UPDATE temp_internal a,master_base b,master_guest c SET a.arr = DATE_FORMAT(b.arr,'%Y-%m-%d'),a.nation = c.nation,a.division = c.division,a.id_no=c.id_no
				WHERE a.id = b.id AND a.id = c.id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.hotel_group_id = c.hotel_group_id AND b.hotel_id = c.hotel_id;
			UPDATE temp_internal a,master_base_history b,master_guest_history c SET a.arr = DATE_FORMAT(b.arr,'%Y-%m-%d'),a.nation = c.nation,a.division = c.division,a.id_no=c.id_no
				WHERE a.id = b.id AND a.id = c.id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.hotel_group_id = c.hotel_group_id AND b.hotel_id = c.hotel_id;
			
			SELECT TRIM(province_code) INTO var_lclpro FROM hotel WHERE id = arg_hotel_id;
			SET var_heji = '10', var_jingwai = '20', var_jingnei = '30', var_shengnei = '40', var_shengwai = '50', var_buxiang = '60';
			
			IF NOT EXISTS (SELECT 1 FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_heji) THEN
				INSERT guest_sta_inland (hotel_group_id,hotel_id,DATE, guest_class, list_order, descript, descript1) VALUES (arg_hotel_group_id,arg_hotel_id,arg_begin_date, var_heji, 0, '合  计', 'Total');
			END IF;
			IF NOT EXISTS (SELECT 1 FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_jingnei) THEN
				INSERT guest_sta_inland (hotel_group_id,hotel_id,DATE, guest_class, list_order, descript, descript1) VALUES (arg_hotel_group_id,arg_hotel_id,arg_begin_date, var_jingnei, 0, '境  内','Nationals');
			END IF;
			IF NOT EXISTS (SELECT 1 FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_jingwai) THEN
				INSERT guest_sta_inland(hotel_group_id,hotel_id,DATE, guest_class, list_order, descript, descript1) VALUES (arg_hotel_group_id,arg_hotel_id,arg_begin_date, var_jingwai, 0, '境  外', 'Overseas');
			END IF;
			IF NOT EXISTS (SELECT 1 FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_shengnei) THEN
				INSERT guest_sta_inland(hotel_group_id,hotel_id,DATE, guest_class, list_order, descript, descript1) VALUES (arg_hotel_group_id,arg_hotel_id,arg_begin_date, var_shengnei, 0, '省  内', 'In province');
			END IF;
			IF NOT EXISTS (SELECT 1 FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_shengwai) THEN
				INSERT guest_sta_inland(hotel_group_id,hotel_id,DATE, guest_class, list_order, descript, descript1) VALUES (arg_hotel_group_id,arg_hotel_id,arg_begin_date, var_shengwai, 0, '省  外', 'Out province');
			END IF;
			IF NOT EXISTS (SELECT 1 FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_buxiang) THEN
				INSERT guest_sta_inland(hotel_group_id,hotel_id,DATE, guest_class, list_order, descript, descript1) VALUES (arg_hotel_group_id,arg_hotel_id,arg_begin_date, var_buxiang, 0, '不  详', 'Unknow');
			END IF;
			
			IF EXISTS(SELECT 1 FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE = arg_begin_date) THEN
				UPDATE guest_sta_inland SET
										   mtc = mtc-dtc, mtt = mtt-dtt, mgc = mgc-dgc, mgt = mgt-dgt, mmc = mmc-dmc, mmt = mmt-dmt, 
										   ytc = ytc-dtc, ytt = ytt-dtt, ygc = ygc-dgc, ygt = ygt-dgt, ymc = ymc-dmc, ymt = ymt-dmt 
				WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
			END IF;
			UPDATE guest_sta_inland SET dtc = 0, dtt = 0, dgc = 0, dgt = 0, dmc = 0, dmt = 0, DATE = arg_begin_date WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
			
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
						SET var_province='';
						SELECT IFNULL(province,'') INTO var_province FROM code_division WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND CODE=var_division;
					
						IF var_grpaccnt <> 0 THEN		-- 团队
							IF var_arr <= arg_begin_date AND var_sta = 'I' THEN	-- 人天
								UPDATE guest_sta_inland SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_heji;			
								IF var_nation <> 'CN' THEN
									UPDATE guest_sta_inland SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai; 
								ELSE
									UPDATE guest_sta_inland SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei;
									IF var_province IS NULL OR var_province = '' THEN
										UPDATE guest_sta_inland SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_buxiang AND where_from ='';								
									ELSEIF var_province <> var_lclpro THEN
										BEGIN
											UPDATE guest_sta_inland SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from ='';
											IF NOT EXISTS(SELECT 1 FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = SUBSTRING(var_division,1,2)) THEN
												INSERT guest_sta_inland (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
												SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,var_shengwai,SUBSTRING(var_division,1,2),'','' 
													FROM code_division WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND CODE = CONCAT(SUBSTRING(var_division,1,2),'0000') ;
												
												UPDATE guest_sta_inland a,code_division b SET a.descript = b.descript,a.descript1 = b.descript_en 
													WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id  AND a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id
														AND a.guest_class = var_shengwai AND CONCAT(a.where_from,'0000') = b.code AND a.where_from <> '';
											END IF;
											UPDATE guest_sta_inland SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = SUBSTRING(var_division,1,2) AND where_from <>'';
										END;
									ELSE						
										BEGIN
											UPDATE guest_sta_inland SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from =''; 
											IF NOT EXISTS(SELECT 1 FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from = var_division) THEN
												INSERT guest_sta_inland (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
												SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,var_shengnei,var_division,descript,descript_en 
													FROM code_division WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND CODE = var_division AND province=var_lclpro;
											END IF;									
											UPDATE guest_sta_inland SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from = var_division;
										END;									
									END IF;							
								END IF;
							END IF;
							IF var_arr = arg_begin_date THEN	-- 人次
								UPDATE guest_sta_inland SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_heji;			
								IF var_nation <> 'CN' THEN	-- 境外(人次)
									UPDATE guest_sta_inland SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai ; 
								ELSE -- 境内(人次)
									UPDATE guest_sta_inland SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei ;
									IF var_province IS NULL OR var_province = '' THEN
										UPDATE guest_sta_inland SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_buxiang AND where_from ='';
									ELSEIF var_province <> var_lclpro THEN
										BEGIN
											UPDATE guest_sta_inland SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from =''; 
											IF NOT EXISTS(SELECT 1 FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = SUBSTRING(var_division,1,2)) THEN
												INSERT guest_sta_inland (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
												SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,var_shengwai,SUBSTRING(var_division,1,2),'','' 
													FROM code_division a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = CONCAT(SUBSTRING(var_division,1,2),'0000') ;
												
												UPDATE guest_sta_inland a,code_division b SET a.descript = b.descript,a.descript1 = b.descript_en 
													WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id  AND a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id
														AND a.guest_class = var_shengwai AND CONCAT(a.where_from,'0000') = b.code AND a.where_from <> '';
											END IF;
											UPDATE guest_sta_inland SET dgc= dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = SUBSTRING(var_division,1,2) AND where_from <>'';								
										END;
									ELSE						
										BEGIN
											UPDATE guest_sta_inland SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from =''; 
											IF NOT EXISTS(SELECT 1 FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from = var_division) THEN
												INSERT guest_sta_inland (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
												SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,var_shengnei,var_division,a.descript,a.descript_en 
													FROM code_division a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = var_division AND a.province=var_lclpro;
											END IF;									
											UPDATE guest_sta_inland SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from = var_division;
										END;
									END IF;					
								END IF;							
							END IF;	
						ELSE		-- 散客
							IF var_arr <= arg_begin_date AND var_sta = 'I' THEN	-- 人天
								UPDATE guest_sta_inland SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_heji;			
								IF var_nation <> 'CN' THEN
									UPDATE guest_sta_inland SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai; 
								ELSE
									UPDATE guest_sta_inland SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei;
									IF var_province IS NULL OR var_province = '' THEN
										UPDATE guest_sta_inland SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_buxiang AND where_from ='';								
									ELSEIF var_province <> var_lclpro THEN
										BEGIN
											UPDATE guest_sta_inland SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from ='';
											IF NOT EXISTS(SELECT 1 FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = SUBSTRING(var_division,1,2)) THEN
												INSERT guest_sta_inland (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
												SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,var_shengwai,SUBSTRING(var_division,1,2),'','' 
													FROM code_division WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND CODE = CONCAT(SUBSTRING(var_division,1,2),'0000') ;
												
												UPDATE guest_sta_inland a,code_division b SET a.descript = b.descript,a.descript1 = b.descript_en 
													WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id  AND a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id
														AND a.guest_class = var_shengwai AND CONCAT(a.where_from,'0000') = b.code AND a.where_from <> '';
											END IF;
											UPDATE guest_sta_inland SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = SUBSTRING(var_division,1,2) AND where_from <>'';								
										END;
									ELSE						
										BEGIN
											UPDATE guest_sta_inland SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from =''; 
											IF NOT EXISTS(SELECT 1 FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from = var_division) THEN
												INSERT guest_sta_inland (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
												SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,var_shengnei,var_division,descript,descript_en 
													FROM code_division WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND CODE = var_division AND province=var_lclpro;
											END IF;									
											UPDATE guest_sta_inland SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from = var_division;
										END;									
									END IF;							
								END IF;
							END IF;
							IF var_arr = arg_begin_date THEN	-- 人次
								UPDATE guest_sta_inland SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_heji;			
								IF var_nation <> 'CN' THEN	
									UPDATE guest_sta_inland SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai ; 
								ELSE 
									UPDATE guest_sta_inland SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei ;
									IF var_province IS NULL OR var_province = '' THEN
										UPDATE guest_sta_inland SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_buxiang AND where_from ='';
									ELSEIF var_province <> var_lclpro THEN
										BEGIN
											UPDATE guest_sta_inland SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from =''; 
											IF NOT EXISTS(SELECT 1 FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = SUBSTRING(var_division,1,2)) THEN
												INSERT guest_sta_inland (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
												SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,var_shengwai,SUBSTRING(var_division,1,2),'','' 
													FROM code_division a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = CONCAT(SUBSTRING(var_division,1,2),'0000') ;
												
												UPDATE guest_sta_inland a,code_division b SET a.descript = b.descript,a.descript1 = b.descript_en 
													WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id  AND a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id
														AND a.guest_class = var_shengwai AND CONCAT(a.where_from,'0000') = b.code AND a.where_from <> '';
											END IF;
											UPDATE guest_sta_inland SET dtc= dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = SUBSTRING(var_division,1,2)AND where_from <>'';								
										END;
									ELSE						
										BEGIN
											UPDATE guest_sta_inland SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from =''; 
											IF NOT EXISTS(SELECT 1 FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from = var_division) THEN
												INSERT guest_sta_inland (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
												SELECT arg_hotel_group_id,arg_hotel_id,arg_begin_date,var_shengnei,var_division,a.descript,a.descript_en 
													FROM code_division a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = var_division AND a.province=var_lclpro;
											END IF;									
											UPDATE guest_sta_inland SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from = var_division;
										END;
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
				UPDATE guest_sta_inland SET mtc = dtc, mtt = dtt, mgc = dgc, mgt = dgt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
			ELSE
				UPDATE guest_sta_inland SET mtc = mtc + dtc, mtt = mtt + dtt, mgc = mgc + dgc, mgt = mgt + dgt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
			END IF;
			
			IF EXISTS(SELECT 1 FROM biz_month WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_month = 1 AND begin_date = arg_begin_date) THEN
				UPDATE guest_sta_inland SET ytc = dtc, ytt = dtt, ygc = dgc, ygt = dgt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
			ELSE
				UPDATE guest_sta_inland SET ytc = ytc + dtc, ytt = ytt + dtt, ygc = ygc + dgc, ygt = ygt + dgt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
			END IF;
			
			UPDATE guest_sta_inland SET DATE = arg_begin_date WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
			
			DELETE FROM guest_sta_inland_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE = arg_begin_date ;
			INSERT INTO guest_sta_inland_history SELECT * FROM guest_sta_inland WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
			DELETE FROM temp_internal WHERE biz_date=arg_begin_date;
			SET arg_begin_date = DATE_ADD(arg_begin_date,INTERVAL 1 DAY);
		END;
	END WHILE;
	
	DROP TEMPORARY TABLE IF EXISTS temp_internal;		
		
END$$

DELIMITER ;

CALL up_ihotel_reb_guest_internal(1,103,'2014-10-30');

DROP PROCEDURE IF EXISTS `up_ihotel_reb_guest_internal`;