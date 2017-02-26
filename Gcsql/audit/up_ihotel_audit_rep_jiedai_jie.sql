DELIMITER $$

USE `portal_ipms`$$

DROP PROCEDURE IF EXISTS `up_ihotel_audit_rep_jiedai_jie`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_audit_rep_jiedai_jie`(
	IN arg_hotel_group_id		INT,
	IN arg_hotel_id			INT,
	IN arg_accnt_type		VARCHAR(3),
	IN arg_modu_code		CHAR(2),
	IN arg_accnt			BIGINT,
	IN arg_tacode			VARCHAR(10),
	IN arg_market			VARCHAR(10),
	IN arg_source			VARCHAR(10),
	IN arg_charge			DECIMAL(12,2),	
	IN arg_charge_tax		DECIMAL(12,2),
	IN arg_trans_accnt		BIGINT
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ---------------------------------------------------------------
	-- 夜审过程- 定制稽核底表
	-- 作者：张晓斌 2016.9.13
	-- 2016.09.13日 
	-- ---------------------------------------------------------------
	-- 修改日志 
	-- ---------------------------------------------------------------
	
	DECLARE var_gstbl		VARCHAR(10);
	DECLARE var_arbl		VARCHAR(10);
	DECLARE var_deptno		CHAR(1);
	DECLARE var_src			VARCHAR(10);
	DECLARE	var_market2		VARCHAR(10);
	DECLARE var_src2		VARCHAR(10);
	DECLARE var_channel		VARCHAR(10);
	DECLARE arg_tacodes_ar		VARCHAR(100);
	DECLARE arg_tacodes_vip		VARCHAR(100);
	DECLARE var_group_mkt1		VARCHAR(1024);
	DECLARE var_group_mkt2		VARCHAR(1024);
	DECLARE var_group_mkt3		VARCHAR(1024);
	DECLARE var_group_mkt4		VARCHAR(1024);
	DECLARE var_group_mkt5		VARCHAR(1024);
	DECLARE var_group_mkt6		VARCHAR(1024);
	DECLARE var_group_mkt7		VARCHAR(1024);
	DECLARE var_group_src1		VARCHAR(1024);
	DECLARE var_group_src2		VARCHAR(1024);
	DECLARE var_pos_mkt1		VARCHAR(1024); -- 餐饮市场
	DECLARE var_pos_mkt2		VARCHAR(1024);
	DECLARE var_pos_mkt3		VARCHAR(1024);
	DECLARE var_pos_mkt4		VARCHAR(1024);
	DECLARE var_pos_mkt5		VARCHAR(1024);
	DECLARE var_pos_mkt6		VARCHAR(1024);
	DECLARE var_pos_mkt7		VARCHAR(1024);
	DECLARE var_pos_src1		VARCHAR(1024);
	DECLARE var_pos_src2		VARCHAR(1024);
	-- 市场码
	DROP TEMPORARY TABLE IF EXISTS tmp_mkt_group;
	CREATE TEMPORARY TABLE tmp_mkt_group
	(
		accnt_type	VARCHAR(3),
 		CODE 		VARCHAR(10) NOT NULL,
		descript	VARCHAR(30),
		code_category	VARCHAR(10),
		KEY index1(accnt_type,code_category)
	);
	INSERT INTO tmp_mkt_group(accnt_type,CODE,descript,code_category)
		SELECT 'FO',CODE,descript,code_category FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code = 'market_code';
	SET var_group_mkt1 = IFNULL((SELECT GROUP_CONCAT(DISTINCT CODE) FROM tmp_mkt_group WHERE accnt_type = 'FO' AND code_category = 'JZ'),'JZ');
	SET var_group_mkt2 = IFNULL((SELECT GROUP_CONCAT(DISTINCT CODE) FROM tmp_mkt_group WHERE accnt_type = 'FO' AND code_category = 'HW'),'HW');
	SET var_group_mkt3 = IFNULL((SELECT GROUP_CONCAT(DISTINCT CODE) FROM tmp_mkt_group WHERE accnt_type = 'FO' AND code_category = 'YX'),'YX');
	SET var_group_mkt4 = IFNULL((SELECT GROUP_CONCAT(DISTINCT CODE) FROM tmp_mkt_group WHERE accnt_type = 'FO' AND code_category = 'SWSK'),'SWSK');
	SET var_group_mkt5 = IFNULL((SELECT GROUP_CONCAT(DISTINCT CODE) FROM tmp_mkt_group WHERE accnt_type = 'FO' AND code_category = 'LYSK'),'LYSK');
	SET var_group_mkt6 = IFNULL((SELECT GROUP_CONCAT(DISTINCT CODE) FROM tmp_mkt_group WHERE accnt_type = 'FO' AND code_category = 'TD'),'TD');
	SET var_group_mkt7 = IFNULL((SELECT GROUP_CONCAT(DISTINCT CODE) FROM tmp_mkt_group WHERE accnt_type = 'FO' AND code_category = 'LYZXT'),'LYZXT');
	
	INSERT INTO tmp_mkt_group(accnt_type,CODE,descript,code_category)
		SELECT 'POS',CODE,descript,code_category FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code = 'pos_market';
		
	UPDATE 	tmp_mkt_group SET code_category = 'SWSK' WHERE accnt_type = 'POS' AND code_category NOT IN ('JZ','HW','YX','TD','LYZXT','LYSK');
	
	SET var_pos_mkt1 = IFNULL((SELECT GROUP_CONCAT(DISTINCT CODE) FROM tmp_mkt_group WHERE accnt_type = 'POS' AND code_category = 'JZ'),'JZ');
	SET var_pos_mkt2 = IFNULL((SELECT GROUP_CONCAT(DISTINCT CODE) FROM tmp_mkt_group WHERE accnt_type = 'POS' AND code_category = 'HW'),'HW');
	SET var_pos_mkt3 = IFNULL((SELECT GROUP_CONCAT(DISTINCT CODE) FROM tmp_mkt_group WHERE accnt_type = 'POS' AND code_category = 'YX'),'YX');
	SET var_pos_mkt4 = IFNULL((SELECT GROUP_CONCAT(DISTINCT CODE) FROM tmp_mkt_group WHERE accnt_type = 'POS' AND code_category = 'SWSK'),'SWSK');
	SET var_pos_mkt5 = IFNULL((SELECT GROUP_CONCAT(DISTINCT CODE) FROM tmp_mkt_group WHERE accnt_type = 'POS' AND code_category = 'LYSK'),'LYSK');
	SET var_pos_mkt6 = IFNULL((SELECT GROUP_CONCAT(DISTINCT CODE) FROM tmp_mkt_group WHERE accnt_type = 'POS' AND code_category = 'TD'),'TD');
	SET var_pos_mkt7 = IFNULL((SELECT GROUP_CONCAT(DISTINCT CODE) FROM tmp_mkt_group WHERE accnt_type = 'POS' AND code_category = 'LYZXT'),'LYZXT');
	
 	-- 来源码
	DROP TEMPORARY TABLE IF EXISTS tmp_src_group;
	CREATE TEMPORARY TABLE tmp_src_group
	(
		accnt_type	VARCHAR(3),
 		CODE 		VARCHAR(10) NOT NULL,
		descript	VARCHAR(30),
		code_category	VARCHAR(10),
		KEY index1(accnt_type,code_category)
	);
	
	INSERT INTO tmp_src_group(accnt_type,CODE,descript,code_category)
		SELECT 'FO',CODE,descript,code_category FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code = 'src_code';
	SET var_group_src1 = IFNULL((SELECT CONCAT(',',GROUP_CONCAT(DISTINCT CODE),',') FROM tmp_src_group WHERE accnt_type = 'FO' AND CODE = 'XS'),'XS');
	SET var_group_src2 = IFNULL((SELECT CONCAT(',',GROUP_CONCAT(DISTINCT CODE),',') FROM tmp_src_group WHERE accnt_type = 'FO' AND CODE = 'XX'),'XX');
	INSERT INTO tmp_src_group(accnt_type,CODE,descript,code_category)
		SELECT 'POS',CODE,descript,code_category FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code = 'pos_source';
	SET var_pos_src1 = IFNULL((SELECT CONCAT(',',GROUP_CONCAT(DISTINCT CODE),',') FROM tmp_src_group WHERE accnt_type = 'POS' AND code_category = 'XS'),'XS');
	SET var_pos_src2 = IFNULL((SELECT CONCAT(',',GROUP_CONCAT(DISTINCT CODE),',') FROM tmp_src_group WHERE accnt_type = 'POS' AND code_category = 'XX'),'XX');
 	
	IF arg_accnt_type = 'FO' AND arg_trans_accnt IS NULL THEN
		SELECT src,channel INTO var_src,var_channel FROM master_base_till WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND id = arg_accnt;	
	ELSE
		SELECT src,channel INTO var_src,var_channel FROM master_base_till WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND id = arg_trans_accnt;			
	END IF;
	
	SET var_market2 = 'LYSK01',var_src2 = 'XS';
 	-- 市场码默认值	
 	IF (arg_accnt_type = 'FO' OR arg_accnt_type = 'AR' OR arg_accnt_type = 'VIP') AND (arg_market = '' OR arg_market IS NULL) THEN
		SET arg_market = var_market2;		
	END IF;
	IF (arg_accnt_type = 'FO' OR arg_accnt_type = 'AR' OR arg_accnt_type = 'VIP') AND (var_src = '' OR var_src IS NULL) THEN
		SET var_src = var_src2;
	END IF;
	
	
	IF (arg_accnt_type = 'FO' OR arg_accnt_type = 'AR' OR arg_accnt_type = 'VIP') AND arg_modu_code = '02' THEN
		BEGIN
			
			IF INSTR(var_group_mkt1,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day01 = day01+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_group_mkt2,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day02 = day02+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_group_mkt3,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day03 = day03+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_group_mkt4,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day04 = day04+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_group_mkt5,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day05 = day05+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_group_mkt6,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day06 = day06+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_group_mkt7,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day07 = day07+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSE
				UPDATE rep_jie_hd SET day04 = day04+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;	
			END IF;	
			IF INSTR(var_group_src1,CONCAT(',',var_src,',')) > 0 THEN
				UPDATE rep_jie_hd SET day11 = day11+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF INSTR(var_group_src2,CONCAT(',',var_src,',')) > 0 THEN
				UPDATE rep_jie_hd SET day12 = day12+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;					
			END IF;
			
 			UPDATE rep_jie_hd SET day99 = day99+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;					
		END;
 	ELSEIF arg_accnt_type = 'POS' AND arg_modu_code = '04' THEN
		BEGIN
			IF INSTR(var_pos_mkt1,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day01 = day01+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_pos_mkt2,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day02 = day02+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_pos_mkt3,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day03 = day03+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_pos_mkt4,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day04 = day04+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_pos_mkt5,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day05 = day05+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_pos_mkt6,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day06 = day06+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_pos_mkt7,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day07 = day07+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSE
				UPDATE rep_jie_hd SET day04 = day04+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
				
			END IF;	
			IF INSTR(var_pos_src1,CONCAT(',',arg_source,',')) > 0 THEN
				UPDATE rep_jie_hd SET day11 = day11+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF INSTR(var_pos_src2,CONCAT(',',arg_source,',')) > 0 THEN
				UPDATE rep_jie_hd SET day12 = day12+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;					
			END IF;
							
			UPDATE rep_jie_hd SET day99 = day99+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;					
		
		END;
	ELSEIF 	arg_accnt_type = 'pos' AND arg_modu_code = '08' THEN
		BEGIN
			IF INSTR(var_pos_mkt1,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day01 = day01-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_pos_mkt2,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day02 = day02-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_pos_mkt3,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day03 = day03-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_pos_mkt4,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day04 = day04-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_pos_mkt5,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day05 = day05-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_pos_mkt6,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day06 = day06-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_pos_mkt7,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day07 = day07-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSE
				UPDATE rep_jie_hd SET day04 = day04-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
				
			END IF;	
			IF INSTR(var_pos_src1,CONCAT(',',arg_source,',')) > 0 THEN
				UPDATE rep_jie_hd SET day11 = day11-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF INSTR(var_pos_src2,CONCAT(',',arg_source,',')) > 0 THEN
				UPDATE rep_jie_hd SET day12 = day12-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;					
			END IF;
			
			INSERT INTO temp_revenue(accnt,market,src,channel,ta_code,charge,charge_tax)
				VALUES(arg_accnt,arg_market,arg_source,var_channel,arg_tacode,arg_charge,arg_charge_tax);
				
			UPDATE rep_jie_hd SET day99 = day99-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;					
			UPDATE rep_jie_hd SET day01 = day01+arg_charge,day99=day99+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno = '998';
		END;	
	ELSEIF 	(arg_accnt_type = 'fo' OR arg_accnt_type = 'AR') AND arg_modu_code = '08' THEN
		BEGIN
			IF INSTR(var_group_mkt1,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day01 = day01-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_group_mkt2,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day02 = day02-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_group_mkt3,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day03 = day03-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_group_mkt4,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day04 = day04-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_group_mkt5,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day05 = day05-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF 	INSTR(var_group_mkt6,arg_market) > 0 THEN
				UPDATE rep_jie_hd SET day06 = day06-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSE
				UPDATE rep_jie_hd SET day04 = day04-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
				
			END IF;	
			IF INSTR(var_group_src1,CONCAT(',',var_src,',')) > 0 THEN
				UPDATE rep_jie_hd SET day11 = day11-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;
			ELSEIF INSTR(var_group_src2,CONCAT(',',var_src,',')) > 0 THEN
				UPDATE rep_jie_hd SET day12 = day12-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;					
			END IF;
			
 				
			UPDATE rep_jie_hd SET day99 = day99-arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(modeno,CONCAT(',',arg_tacode,','))>0;					
			UPDATE rep_jie_hd SET day01 = day01+arg_charge,day99=day99+arg_charge WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno = '998';
		
		END;
	END IF; 	
  
    	BEGIN
 
		SET @procresult = 0 ;
		LEAVE label_0 ;
	END ;
	
  END$$

DELIMITER ;