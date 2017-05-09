DELIMITER $$

DROP PROCEDURE IF EXISTS `up_pos_rep_card_shift_aranya`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_pos_rep_card_shift_aranya`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT,
	IN arg_biz_date			DATETIME,
	IN arg_shift			VARCHAR(20),
	IN arg_user				VARCHAR(20),
	IN arg_pccode			VARCHAR(50)		

    )
	
	SQL SECURITY INVOKER
label_0:
BEGIN
    /*
        阿那亚餐饮会员等级交班表
        根据会员等级来
    */

	DECLARE done_cursor 	INT DEFAULT 0;
	DECLARE var_tacodes		VARCHAR(50);	

	DROP TEMPORARY TABLE IF EXISTS tmp_pos_card_rep;
	CREATE TEMPORARY TABLE tmp_pos_card_rep (
		hotel_group_id 	INT 	NOT NULL,
		hotel_id 		INT 	NOT NULL,
		pos_accnt		VARCHAR(20) NOT NULL,
		pos_pccode		VARCHAR(20) NOT NULL,	
		credit 			DECIMAL(8,2) NOT NULL,
		info1			VARCHAR(50) NOT NULL,
		info2			VARCHAR(50) NOT NULL,
		card_no			VARCHAR(20) NOT NULL DEFAULT '',
		card_type		VARCHAR(30) NOT NULL DEFAULT '',
		card_level		VARCHAR(30) NOT NULL DEFAULT '',
		create_user		VARCHAR(20) NOT NULL,
		KEY index1 (hotel_group_id,hotel_id,pos_accnt)
	);

	IF  arg_shift = '' OR arg_shift IS NULL OR arg_shift='9' THEN
		SET arg_shift='%';
	END IF;
	IF  arg_user = '' OR arg_user IS NULL THEN 
		SET arg_user='%';
	END IF;

	SELECT GROUP_CONCAT(code) INTO var_tacodes FROM code_transaction WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND cat_posting = 'RCV'; 

	INSERT INTO tmp_pos_card_rep(hotel_group_id,hotel_id,pos_accnt,pos_pccode,credit,info1,info2,create_user)
		SELECT arg_hotel_group_id,arg_hotel_id,accnt,pccode,credit,info1,info2,create_user
			FROM pos_account WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND INSTR(var_tacodes,paycode) >= 1 AND paycode<>''
			AND sta <> 'X' AND shift LIKE arg_shift AND create_user LIKE arg_user AND IF(arg_pccode = '' OR arg_pccode IS NULL,1=1,INSTR(arg_pccode,pccode) >= 1)
		UNION ALL
		SELECT arg_hotel_group_id,arg_hotel_id,accnt,pccode,credit,info1,info2,create_user
			FROM pos_account_history WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_biz_date AND INSTR(var_tacodes,paycode) >= 1 AND paycode<>''
			AND sta <> 'X' AND shift LIKE arg_shift AND create_user LIKE arg_user AND IF(arg_pccode = '' OR arg_pccode IS NULL,1=1,INSTR(arg_pccode,pccode) >= 1);

	UPDATE tmp_pos_card_rep SET card_no = SUBSTR(info2,INSTR(info2,'[')+1,INSTR(info2,']')-2) WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;

	UPDATE tmp_pos_card_rep SET card_level = SUBSTR(info1,1,INSTR(info1,'/')-1) WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	UPDATE tmp_pos_card_rep SET card_type = SUBSTR(SUBSTR(info1,INSTR(info1,'#')+1),1,INSTR(SUBSTR(info1,INSTR(info1,'#')+1),'/')-1) WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;

	SELECT c.name,IFNULL(b.descript,'未知等级') AS descript,SUM(a.credit) AS credit 
	FROM tmp_pos_card_rep a
	LEFT JOIN card_level b ON b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=0 AND b.code = a.card_level
	LEFT JOIN user c ON c.hotel_group_id=arg_hotel_group_id AND c.hotel_id=0 AND c.code = a.create_user
	 WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id
	 GROUP BY a.create_user,a.card_level
	 ORDER BY a.create_user,a.card_level;
	
END$$

DELIMITER ;