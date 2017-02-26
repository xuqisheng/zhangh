DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_audit_guest_internal_ms`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_audit_guest_internal_ms`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT,
	IN arg_lclpro 			VARCHAR(10), -- 用于需指定产生明细的省份
	OUT arg_ret				INT,
	OUT arg_msg				VARCHAR(255)
)
    SQL SECURITY INVOKER
label_0:
BEGIN	
	-- =============================================================================
	-- 用途:可指定省份产生明细
	-- 解释:
	-- 作者:张惠
	-- =============================================================================	
	DECLARE done_cursor INT DEFAULT 0;	
	DECLARE var_heji 	 CHAR(2);
	DECLARE var_jingwai  CHAR(2);
	DECLARE var_jingnei  CHAR(2);
	DECLARE var_shengnei CHAR(2);
	DECLARE var_shengwai CHAR(2);
	DECLARE var_buxiang  CHAR(2);
	DECLARE var_sta		 CHAR(1);
	DECLARE var_lclpro   VARCHAR(10);
	DECLARE var_province VARCHAR(10);
	DECLARE var_accnt	 BIGINT(12);
	DECLARE var_nation	 VARCHAR(10);
	DECLARE var_arr		 DATETIME;
	DECLARE var_division VARCHAR(6);
	DECLARE var_idno	 VARCHAR(20);
	DECLARE var_grpaccnt BIGINT(12);
	DECLARE var_bdate DATETIME;
	
	DECLARE c_cursor CURSOR FOR SELECT id,nation,biz_date,division,id_no,grp_accnt FROM temp_internal_ms;	
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	
	DROP TEMPORARY TABLE IF EXISTS temp_internal_ms;
	CREATE TEMPORARY TABLE temp_internal_ms(
		id			BIGINT(16),
		nation		VARCHAR(10) DEFAULT '' NOT NULL,
		biz_date	DATETIME,
		division	VARCHAR(6)  DEFAULT '' NOT NULL,
		id_no		VARCHAR(20) DEFAULT '' NOT NULL,
		grp_accnt	BIGINT(16),
		KEY index1(id)
	);
	
	IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'master_base' AND COLUMN_NAME = 'group_code') THEN	
		INSERT INTO temp_internal_ms(id,nation,biz_date,division,id_no,grp_accnt)
			SELECT a.id,b.nation,a.biz_date,b.division,b.id_no,a.grp_accnt FROM master_base_till a,master_guest_till b
				WHERE a.id = b.id AND a.rsv_class = 'F'
				AND (a.sta = 'I' OR (a.sta IN ('S','O') AND NOT EXISTS(SELECT 1 FROM master_base_last d WHERE a.id = d.id AND a.hotel_group_id = d.hotel_group_id AND a.hotel_id = d.hotel_id ))) 
				AND a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id ORDER BY b.nation,b.division;
	ELSE
		INSERT INTO temp_internal_ms(id,nation,biz_date,division,id_no,grp_accnt)
			SELECT a.id,b.nation,a.biz_date,b.division,b.id_no,a.grp_accnt FROM master_base_till a,master_guest_till b
				WHERE a.id = b.id AND a.rsv_class = 'F' AND a.id <> a.rsv_id
				AND (a.sta = 'I' OR (a.sta IN ('S','O') AND NOT EXISTS(SELECT 1 FROM master_base_last d WHERE a.id = d.id AND a.hotel_group_id = d.hotel_group_id AND a.hotel_id = d.hotel_id ))) 
				AND a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id ORDER BY b.nation,b.division;
	END IF;		
	
	SET arg_ret = 1, arg_msg = 'OK';	
	SELECT DATE_ADD(set_value,INTERVAL  -1 DAY) INTO var_bdate FROM sys_option WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog = 'system' AND item = 'biz_date';
	
	SELECT TRIM(province_code) INTO var_lclpro FROM hotel WHERE id = arg_hotel_id;
	
	SET var_heji = '10', var_jingwai = '20', var_jingnei = '30', var_shengnei = '40', var_shengwai = '50', var_buxiang = '60';
	
	IF NOT EXISTS (SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_heji) THEN
		INSERT guest_sta_inland_ms (hotel_group_id,hotel_id,DATE, guest_class, list_order, descript, descript1) VALUES (arg_hotel_group_id,arg_hotel_id,var_bdate, var_heji, 0, '合  计', 'Total');
	END IF;
	IF NOT EXISTS (SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_jingnei) THEN
		INSERT guest_sta_inland_ms (hotel_group_id,hotel_id,DATE, guest_class, list_order, descript, descript1) VALUES (arg_hotel_group_id,arg_hotel_id,var_bdate, var_jingnei, 0, '境  内','Nationals');
	END IF;
	IF NOT EXISTS (SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_jingwai) THEN
		INSERT guest_sta_inland_ms(hotel_group_id,hotel_id,DATE, guest_class, list_order, descript, descript1) VALUES (arg_hotel_group_id,arg_hotel_id,var_bdate, var_jingwai, 0, '境  外', 'Overseas');
	END IF;
	IF NOT EXISTS (SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_shengnei) THEN
		INSERT guest_sta_inland_ms(hotel_group_id,hotel_id,DATE, guest_class, list_order, descript, descript1) VALUES (arg_hotel_group_id,arg_hotel_id,var_bdate, var_shengnei, 0, '省  内', 'In province');
	END IF;
	IF NOT EXISTS (SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_shengwai) THEN
		INSERT guest_sta_inland_ms(hotel_group_id,hotel_id,DATE, guest_class, list_order, descript, descript1) VALUES (arg_hotel_group_id,arg_hotel_id,var_bdate, var_shengwai, 0, '省  外', 'Out province');
	END IF;
	IF NOT EXISTS (SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND RTRIM(guest_class) = var_buxiang) THEN
		INSERT guest_sta_inland_ms(hotel_group_id,hotel_id,DATE, guest_class, list_order, descript, descript1) VALUES (arg_hotel_group_id,arg_hotel_id,var_bdate, var_buxiang, 0, '不  详', 'Unknow');
	END IF;	
	
	IF EXISTS(SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE = var_bdate) THEN
		UPDATE guest_sta_inland_ms SET
		                           mtc = mtc-dtc, mtt = mtt-dtt, mgc = mgc-dgc, mgt = mgt-dgt, mmc = mmc-dmc, mmt = mmt-dmt, 
		                           ytc = ytc-dtc, ytt = ytt-dtt, ygc = ygc-dgc, ygt = ygt-dgt, ymc = ymc-dmc, ymt = ymt-dmt 
		WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	END IF;	
	UPDATE guest_sta_inland_ms SET dtc = 0, dtt = 0, dgc = 0, dgt = 0, dmc = 0, dmt = 0, DATE = var_bdate WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	
	OPEN c_cursor;
	SET done_cursor = 0;
	FETCH c_cursor INTO var_accnt,var_nation,var_arr,var_division,var_idno,var_grpaccnt;
		WHILE done_cursor = 0 DO
			BEGIN
				SELECT sta INTO var_sta FROM master_base_till WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND id=var_accnt;
				IF EXISTS(SELECT 1 FROM master_base_last WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND id=var_accnt AND sta='I') THEN
					SELECT biz_date INTO var_arr FROM master_base_last WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND id=var_accnt;
				END IF;
				
				IF TRIM(var_division)='' AND TRIM(var_nation)='CN' AND TRIM(var_idno)<>'' AND CHAR_LENGTH(var_idno)>=15 THEN
					SET var_division = SUBSTRING(var_idno,1,6);
				END IF;
				
				IF NOT EXISTS(SELECT 1 FROM code_division WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND CODE=var_division) THEN
					SET var_division = '';
				END IF;

				SET var_province = '';
				SELECT IFNULL(province,'') INTO var_province FROM code_division WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND CODE=var_division;
				
			
				IF var_grpaccnt <> 0 THEN		
					IF var_arr <= var_bdate AND var_sta = 'I' THEN	
						UPDATE guest_sta_inland_ms SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_heji;			
						IF var_nation <> 'CN' THEN
							UPDATE guest_sta_inland_ms SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai; 
						ELSE
							UPDATE guest_sta_inland_ms SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei;
							IF var_province IS NULL OR var_province='' THEN
								UPDATE guest_sta_inland_ms SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_buxiang AND where_from ='';							
							ELSEIF INSTR(var_lclpro,var_province)=0 THEN
								BEGIN								
									UPDATE guest_sta_inland_ms SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from ='';
									IF NOT EXISTS(SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = SUBSTRING(var_division,1,2)) THEN
										INSERT guest_sta_inland_ms (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
										SELECT arg_hotel_group_id,arg_hotel_id,var_bdate,var_shengwai,SUBSTRING(var_division,1,2),'','' 
											FROM code_division WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND CODE = CONCAT(SUBSTRING(var_division,1,2),'0000') ;
										
										UPDATE guest_sta_inland_ms a,code_division b SET a.descript = b.descript,a.descript1 = b.descript_en 
											WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id  AND a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id
												AND a.guest_class = var_shengwai AND CONCAT(a.where_from,'0000') = b.code AND a.where_from <> '';
									END IF;
									UPDATE guest_sta_inland_ms SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = SUBSTRING(var_division,1,2) AND where_from <>'';
									
									IF INSTR(arg_lclpro,var_province)<>0 THEN
										BEGIN
											UPDATE guest_sta_inland_ms SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from =''; 
											IF NOT EXISTS(SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = var_division) THEN
												INSERT guest_sta_inland_ms (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
												SELECT arg_hotel_group_id,arg_hotel_id,var_bdate,var_shengwai,var_division,descript,descript_en 
													FROM code_division WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND CODE = var_division AND INSTR(arg_lclpro,province)<>0;
											END IF;									
											UPDATE guest_sta_inland_ms SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = var_division;	
										END;
									END IF;
								END;
							ELSE						
								BEGIN
									UPDATE guest_sta_inland_ms SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from =''; 
									IF NOT EXISTS(SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from = var_division) THEN
										INSERT guest_sta_inland_ms (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
										SELECT arg_hotel_group_id,arg_hotel_id,var_bdate,var_shengnei,var_division,descript,descript_en 
											FROM code_division WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND CODE = var_division AND INSTR(var_lclpro,province)<>0;
									END IF;									
									UPDATE guest_sta_inland_ms SET dgt = dgt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from = var_division;
								END;									
							END IF;							
						END IF;
					END IF;
					IF var_arr = var_bdate THEN	
						UPDATE guest_sta_inland_ms SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_heji;			
						IF var_nation <> 'CN' THEN	
							UPDATE guest_sta_inland_ms SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai ; 
						ELSE 
							UPDATE guest_sta_inland_ms SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei ;
							IF var_province IS NULL OR var_province='' THEN
								UPDATE guest_sta_inland_ms SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_buxiang AND where_from ='';
							ELSEIF INSTR(var_lclpro,var_province)=0 THEN
								BEGIN
									UPDATE guest_sta_inland_ms SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from =''; 
									IF NOT EXISTS(SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = SUBSTRING(var_division,1,2)) THEN
										INSERT guest_sta_inland_ms (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
										SELECT arg_hotel_group_id,arg_hotel_id,var_bdate,var_shengwai,SUBSTRING(var_division,1,2),'','' 
											FROM code_division a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = CONCAT(SUBSTRING(var_division,1,2),'0000') ;
										
										UPDATE guest_sta_inland_ms a,code_division b SET a.descript = b.descript,a.descript1 = b.descript_en 
											WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id  AND a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id
												AND a.guest_class = var_shengwai AND CONCAT(a.where_from,'0000') = b.code AND a.where_from <> '';
									END IF;
									UPDATE guest_sta_inland_ms SET dgc= dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = SUBSTRING(var_division,1,2) AND where_from <>'';								
									
									IF INSTR(arg_lclpro,var_province)<>0 THEN
										BEGIN
											UPDATE guest_sta_inland_ms SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from =''; 
											IF NOT EXISTS(SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = var_division) THEN
												INSERT guest_sta_inland_ms (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
												SELECT arg_hotel_group_id,arg_hotel_id,var_bdate,var_shengwai,var_division,a.descript,a.descript_en 
													FROM code_division a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = var_division AND INSTR(arg_lclpro,a.province)<>0;
											END IF;									
											UPDATE guest_sta_inland_ms SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = var_division;
										END;
									END IF;
								END;
							ELSE						
								BEGIN
									UPDATE guest_sta_inland_ms SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from =''; 
									IF NOT EXISTS(SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from = var_division) THEN
										INSERT guest_sta_inland_ms (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
										SELECT arg_hotel_group_id,arg_hotel_id,var_bdate,var_shengnei,var_division,a.descript,a.descript_en 
											FROM code_division a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = var_division AND INSTR(var_lclpro,a.province)<>0;
									END IF;									
									UPDATE guest_sta_inland_ms SET dgc = dgc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from = var_division;
								END;
							END IF;					
						END IF;							
					END IF;	
				ELSE		
					IF var_arr <= var_bdate AND var_sta = 'I' THEN	
						UPDATE guest_sta_inland_ms SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_heji;			
						IF var_nation <> 'CN' THEN
							UPDATE guest_sta_inland_ms SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai; 
						ELSE
							UPDATE guest_sta_inland_ms SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei;
							IF var_province IS NULL OR var_province='' THEN
								UPDATE guest_sta_inland_ms SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_buxiang AND where_from ='';								
							ELSEIF INSTR(var_lclpro,var_province)=0 THEN
								BEGIN
									UPDATE guest_sta_inland_ms SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from ='';
									IF NOT EXISTS(SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = SUBSTRING(var_division,1,2)) THEN
										INSERT guest_sta_inland_ms (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
										SELECT arg_hotel_group_id,arg_hotel_id,var_bdate,var_shengwai,SUBSTRING(var_division,1,2),'','' 
											FROM code_division WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND CODE = CONCAT(SUBSTRING(var_division,1,2),'0000') ;
										
										UPDATE guest_sta_inland_ms a,code_division b SET a.descript = b.descript,a.descript1 = b.descript_en 
											WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id  AND a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id
												AND a.guest_class = var_shengwai AND CONCAT(a.where_from,'0000') = b.code AND a.where_from <> '';
									END IF;
									UPDATE guest_sta_inland_ms SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = SUBSTRING(var_division,1,2) AND where_from <>'';								
								
									IF INSTR(arg_lclpro,var_province)<>0 THEN
										BEGIN
											UPDATE guest_sta_inland_ms SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from =''; 
											IF NOT EXISTS(SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = var_division) THEN
												INSERT guest_sta_inland_ms (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
												SELECT arg_hotel_group_id,arg_hotel_id,var_bdate,var_shengwai,var_division,descript,descript_en 
													FROM code_division WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND CODE = var_division AND INSTR(arg_lclpro,province)<>0;
											END IF;									
											UPDATE guest_sta_inland_ms SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = var_division;
										END;
									END IF;
								END;
							ELSE						
								BEGIN
									UPDATE guest_sta_inland_ms SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from =''; 
									IF NOT EXISTS(SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from = var_division) THEN
										INSERT guest_sta_inland_ms (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
										SELECT arg_hotel_group_id,arg_hotel_id,var_bdate,var_shengnei,var_division,descript,descript_en 
											FROM code_division WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND CODE = var_division AND INSTR(var_lclpro,province)<>0;
									END IF;									
									UPDATE guest_sta_inland_ms SET dtt = dtt + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from = var_division;
								END;									
							END IF;							
						END IF;
					END IF;
					IF var_arr = var_bdate THEN	
						UPDATE guest_sta_inland_ms SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_heji;			
						IF var_nation <> 'CN' THEN	
							UPDATE guest_sta_inland_ms SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingwai ; 
						ELSE 
							UPDATE guest_sta_inland_ms SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_jingnei ;
							IF var_province IS NULL OR var_province='' THEN									
								UPDATE guest_sta_inland_ms SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_buxiang AND where_from ='';
							ELSEIF INSTR(var_lclpro,var_province)=0 THEN
								BEGIN
									UPDATE guest_sta_inland_ms SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from =''; 
									IF NOT EXISTS(SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = SUBSTRING(var_division,1,2)) THEN
										INSERT guest_sta_inland_ms (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
										SELECT arg_hotel_group_id,arg_hotel_id,var_bdate,var_shengwai,SUBSTRING(var_division,1,2),'','' 
											FROM code_division a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = CONCAT(SUBSTRING(var_division,1,2),'0000') ;
										
										UPDATE guest_sta_inland_ms a,code_division b SET a.descript = b.descript,a.descript1 = b.descript_en 
											WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id  AND a.hotel_group_id = b.hotel_group_id AND a.hotel_id = b.hotel_id
												AND a.guest_class = var_shengwai AND CONCAT(a.where_from,'0000') = b.code AND a.where_from <> '';
									END IF;
									UPDATE guest_sta_inland_ms SET dtc= dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = SUBSTRING(var_division,1,2)AND where_from <>'';

									IF INSTR(arg_lclpro,var_province)<>0 THEN
										BEGIN
											UPDATE guest_sta_inland_ms SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from =''; 
											IF NOT EXISTS(SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = var_division) THEN
												INSERT guest_sta_inland_ms (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
												SELECT arg_hotel_group_id,arg_hotel_id,var_bdate,var_shengwai,var_division,a.descript,a.descript_en 
													FROM code_division a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = var_division AND INSTR(arg_lclpro,a.province)<>0;
											END IF;									
											UPDATE guest_sta_inland_ms SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengwai AND where_from = var_division;
										END;
									END IF;
								END;
							ELSE
								BEGIN
									UPDATE guest_sta_inland_ms SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from =''; 
									IF NOT EXISTS(SELECT 1 FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from = var_division) THEN
										INSERT guest_sta_inland_ms (hotel_group_id,hotel_id,DATE, guest_class, where_from, descript, descript1) 
										SELECT arg_hotel_group_id,arg_hotel_id,var_bdate,var_shengnei,var_division,a.descript,a.descript_en 
											FROM code_division a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.code = var_division AND INSTR(var_lclpro,a.province)<>0;
									END IF;									
									UPDATE guest_sta_inland_ms SET dtc = dtc + 1 WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND guest_class = var_shengnei AND where_from = var_division;
								END;
							END IF;					
						END IF;							
					END IF;
				END IF;
			SET done_cursor = 0 ;
			FETCH c_cursor INTO var_accnt,var_nation,var_arr,var_division,var_idno,var_grpaccnt;
			END;
		END WHILE ;
	CLOSE c_cursor;

	IF EXISTS(SELECT 1 FROM biz_month WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND begin_date = var_bdate) THEN
		UPDATE guest_sta_inland_ms SET mtc = dtc, mtt = dtt, mgc = dgc, mgt = dgt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	ELSE
		UPDATE guest_sta_inland_ms SET mtc = mtc + dtc, mtt = mtt + dtt, mgc = mgc + dgc, mgt = mgt + dgt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	END IF;
	
	IF EXISTS(SELECT 1 FROM biz_month WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_month = 1 AND begin_date = var_bdate) THEN
		UPDATE guest_sta_inland_ms SET ytc = dtc, ytt = dtt, ygc = dgc, ygt = dgt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	ELSE
		UPDATE guest_sta_inland_ms SET ytc = ytc + dtc, ytt = ytt + dtt, ygc = ygc + dgc, ygt = ygt + dgt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	END IF;

	DELETE FROM guest_sta_inland_ms_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE = var_bdate ;
	INSERT INTO guest_sta_inland_ms_history SELECT * FROM guest_sta_inland_ms WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND DATE = var_bdate;

	DROP TEMPORARY TABLE IF EXISTS temp_internal_ms;
	
END$$

DELIMITER ;