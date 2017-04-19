DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_proc_demo`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_proc_demo`(
	IN arg_hotel_group_id 	BIGINT(16),
	IN arg_hotel_id 		BIGINT(16),
	IN arg_biz_date			DATETIME,
	OUT arg_ret				BIGINT(16),		
	OUT arg_msg				VARCHAR(128)
    )
	
	SQL SECURITY INVOKER
label_0:
BEGIN
    /*
        存储过程示例
    */


	DECLARE done_cursor 	INT DEFAULT 0;
	DECLARE var_bdate		DATETIME;
	DECLARE var_bfdate		DATETIME;
	DECLARE var_name		VARCHAR(60);
	DECLARE var_empno		VARCHAR(10);
	DECLARE var_index		INT;
	DECLARE var_oid			INT;
	DECLARE var_master_id	INT;
	DECLARE var_biz_date	DATETIME;
	DECLARE var_sta			CHAR(1);
	DECLARE var_rmno		VARCHAR(10);
	DECLARE var_specials	VARCHAR(50);
	DECLARE var_index_last	INT;
	

	DECLARE c_cursor CURSOR FOR 	
	SELECT oid,master_id,biz_date,sta,rmno,specials
		FROM tmp_template 
		WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
		
	SET arg_ret = 1, arg_msg = 'OK';	
	SELECT biz_date1 INTO var_bdate FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id ;
	SET var_bfdate = ADDDATE(var_bdate, -1); 
	

	DROP TABLE IF EXISTS report_center_copy;
	CREATE TABLE report_center_copy SELECT * FROM report_center WHERE 1=2;	
	

	IF arg_hotel_group_id IS NULL THEN 
		BEGIN
		SET arg_ret = 0, arg_msg = 'Error'; 
		LEAVE label_0;
		END; 
	END IF;
	

	DELETE FROM rep_template WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=var_bfdate;
	

	DROP TEMPORARY TABLE IF EXISTS tmp_template;
	CREATE TEMPORARY TABLE tmp_template (
		hotel_group_id 	BIGINT(16) 	NOT NULL,
		hotel_id 		BIGINT(16) 	NOT NULL,
		oid				BIGINT(16) 	NOT NULL,
		biz_date		DATETIME 	NOT NULL,
		NAME			VARCHAR(60) NOT NULL,
		sta				CHAR(2) NOT NULL,
		rmno			VARCHAR(10) NOT NULL,
		rmtype			VARCHAR(10) NOT NULL,
		arr				DATETIME 	NOT NULL,
		dep				DATETIME 	NOT NULL,
		real_rate		DECIMAL(8,2) NOT NULL,
		market			VARCHAR(10) NOT NULL,
		ratecode		VARCHAR(10) NOT NULL,
		PRIMARY KEY (oid),
		KEY index1 (hotel_group_id,hotel_id,oid)
	);
	
	INSERT INTO tmp_template(hotel_group_id,hotel_id,oid,master_id,biz_date,rmtype,sta,rmno,arr,dep,real_rate,market,ratecode,specials,NAME)
		SELECT a.hotel_group_id,a.hotel_id,a.id,a.master_id,a.biz_date,a.rmtype,a.sta,a.rmno,a.arr,a.dep,a.real_rate,a.market,a.ratecode,a.specials,b.name 
			FROM master_base a,master_guest b
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.rsv_class='F' AND a.market='WAK' AND a.sta <> 'C' AND a.sta <> 'D'
			AND a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.id=b.id AND a.id=a.master_id
			AND DATE(a.arr)=DATE(var_bfdate);			
	

	OPEN c_cursor ;
	SET done_cursor = 0 ;	
	FETCH c_cursor INTO var_oid,var_master_id,var_biz_date,var_sta,var_rmno,var_specials ; 
	
	WHILE done_cursor = 0 DO
		BEGIN		
		
				WHILE var_index_last > 0 DO
					BEGIN
						SET var_empno = SUBSTR(var_specials,1,var_index-1);
						
						IF var_index = 0 THEN
							SET var_empno = SUBSTR(var_specials,1,var_sp_len);

						ELSE
							SET var_index_last = var_sp_len - var_index;
						
						END IF;
						
					END;
				END WHILE;			
								
		SET done_cursor = 0 ;
		FETCH c_cursor INTO var_oid,var_master_id,var_biz_date,var_sta,var_rmno,var_specials;  
		END ;
	END WHILE ;
	CLOSE c_cursor ;

	DROP TEMPORARY TABLE IF EXISTS tmp_template;
	DROP TABLE IF EXISTS report_center_copy;
	
END$$

DELIMITER ;