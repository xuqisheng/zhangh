DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_check_repjie`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_check_repjie`(
			IN arg_hotel_group_id 	INT,  	
			IN arg_hotel_id 		INT   		
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- =============================================================================
	-- �ױ����ü��
	-- =============================================================================
	
	-- �������
	DECLARE var_msg  		VARCHAR(100); 	--  ������Ϣ
	DECLARE var_tmp 		VARCHAR(800); 	--  ����������ϸ	
	DECLARE var_tmp_1 		VARCHAR(800); 	--  ����������ϸ	
	DECLARE var_tmp_4 		VARCHAR(800); 	--  ����������ϸ
	
	DECLARE var_modeno 		VARCHAR(800); 	--  ����������ϸ
	DECLARE var_classno		VARCHAR(60); 	--  �ױ���
	DECLARE var_descript	VARCHAR(60); 	--  ������Ŀ
	DECLARE var_toop		VARCHAR(60); 	--  �ۼƷ�ʽ
	DECLARE var_toclass		VARCHAR(60);	--  �ۼӶ���
	
	DECLARE var_qx_code  VARCHAR(60);
	DECLARE var_code_descript  VARCHAR(60);
	DECLARE var_mktcode  VARCHAR(200);
	
	-- ������
	DECLARE var_code_tr   VARCHAR(60);
	DECLARE var_code_buff VARCHAR(600);
	
	DECLARE done_cursor     INT DEFAULT 0;
	-- �����α�
	DECLARE done_cursor  CURSOR FOR SELECT modeno,classno,descript,toop,toclass FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id ;
			
	-- �����α������־
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	-- ����
	
    DROP TEMPORARY TABLE IF EXISTS role_table_2016;
	CREATE TEMPORARY TABLE role_table_2016
	(
		modeno			VARCHAR(800), 	-- ����������ϸ
		mktcode			VARCHAR(200)	DEFAULT NULL,
		classno 		VARCHAR(60), 	-- �ױ���
		descript 		VARCHAR(60), 	-- ������Ŀ
		toop			VARCHAR(60), 	-- �ۼƷ�ʽ
		toclass 		VARCHAR(60)  	-- �ۼӶ���
	); 
	DROP TEMPORARY TABLE IF EXISTS role_table_2017;
	CREATE TEMPORARY TABLE role_table_2017
	(
		CODE 	VARCHAR(60) 
	);
	
	-- �����α�����״�ȡֵ
	OPEN done_cursor;
	FETCH  done_cursor  INTO  var_modeno,var_classno,var_descript,var_toop,var_toclass;
	-- ����whileѭ��������׼
	SET done_cursor = 0 ;
	SET var_tmp_4 = '';
	WHILE done_cursor = 0 DO
	     BEGIN
		  -- 1 �滻 ��Ϊ ; 
		  SET var_modeno = REPLACE(var_modeno,':',';');
		  -- 3 �滻, Ϊ '' 
		  SET var_modeno = REPLACE(var_modeno,',',';');
		  -- ĩβ �� ;
		  SET var_modeno = CONCAT(var_modeno,';');
		  -- �滻GCNULL Ϊ '' 
		  
		  SET var_modeno = REPLACE(var_modeno,'GCNULL;','');
		  
		  -- ���� modeno
		  SET var_tmp = var_modeno ;
		  SET var_tmp_1 = '';
		  SET var_mktcode = '';
		  
		 
		  IF var_tmp <>'' OR LENGTH(var_tmp)>0 OR var_tmp =';'  THEN  		  
			SET var_qx_code = 'To_be_Number_One';
			WHILE var_tmp <> var_qx_code DO
				BEGIN
					 -- �ֶν�ȡ
					 IF   var_qx_code = 'To_be_Number_One' THEN 
						SET var_qx_code = SUBSTRING_INDEX(var_tmp,';',1);
					 ELSE
						SET var_tmp = REPLACE(var_tmp,CONCAT (var_qx_code,';'),'');
						SET var_qx_code = SUBSTRING_INDEX(var_tmp,';',1);
					END IF;
					
					-- �޳��ظ�
					INSERT role_table_2017(CODE) SELECT TRIM(var_qx_code);
					-- �������

					-- �������
					-- ���������
					
					-- IF  EXISTS(SELECT 1 FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND CODE = var_qx_code) then
					   SELECT descript INTO var_code_descript 
							FROM code_transaction
							WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND CODE = var_qx_code;					
					-- �г�					
					IF EXISTS(SELECT 1 FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND  parent_code = 'market_code' AND CODE = var_qx_code) THEN
					  SELECT CONCAT(var_mktcode,'[',var_qx_code,']',descript,';') INTO var_mktcode 
							FROM code_base
							WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code = 'market_code' AND CODE = var_qx_code;
					 END IF;	
					IF LENGTH(var_qx_code) > 0 AND var_qx_code <> ';'THEN
						SET var_tmp_1 = CONCAT(var_tmp_1,'[',var_qx_code,']',var_code_descript,';');
					END IF ;
					SET var_code_descript = '';
					
				END;
			END WHILE;
		
		  END IF;
			
		  INSERT INTO role_table_2016(modeno,mktcode,classno,descript,toop,toclass)
		  VALUES(var_tmp_1,var_mktcode,var_classno,var_descript,var_toop,var_toclass);
		  
		  
		  SET done_cursor = 0 ;
		  FETCH  done_cursor   INTO  var_modeno,var_classno,var_descript,var_toop,var_toclass;
	     END;	
	END WHILE ;
	CLOSE done_cursor;
     
      -- ���������Ƿ�ȱʧ
	IF NOT EXISTS ( SELECT 1 FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id 
								AND arrange_code <> '98'  AND CODE NOT IN (SELECT CODE FROM role_table_2017 GROUP BY CODE)) THEN
		SELECT '��������ȱʧ'  ;
	ELSE
		SELECT * FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND arrange_code <> '98'  
			AND is_halt = 'F' AND CODE NOT IN (SELECT CODE FROM role_table_2017 GROUP BY CODE);
	END IF ;
	
      -- ����г����Ƿ�ȱʧ      
	IF NOT EXISTS (SELECT 1 FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id 
							AND  parent_code = 'market_code' AND CODE NOT IN (SELECT CODE FROM role_table_2017 GROUP BY CODE)) THEN 
		SELECT '�г�����ȱʧ'  ;    
	ELSE
		SELECT * FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code = 'market_code' 
			AND CODE NOT IN (SELECT CODE FROM role_table_2017 GROUP BY CODE);
	END IF ;
	
	SELECT * FROM role_table_2016;
      
END$$

DELIMITER ;