DELIMITER $$

USE `portal_pms`$$

DROP PROCEDURE IF EXISTS `up_ihotel_audit_bonus_detail`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_audit_bonus_detail`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	OUT arg_ret				INT,		
	OUT arg_msg				VARCHAR(10)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
    DECLARE var_bdate 		DATETIME;
	DECLARE var_ratecodes	VARCHAR(50);	
						
	SET arg_ret = 1,arg_msg = 'OK';
	-- 可提成的房价码集
	SET var_ratecodes = 'RSL';
	
	SELECT ADDDATE(biz_date1,-1) INTO var_bdate FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
    
	DELETE FROM rep_bonus_detail WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=var_bdate;
	
	IF EXISTS (SELECT 1 FROM code_ratecode WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND INSTR(CONCAT(',',var_ratecodes,','),CONCAT(',',CODE,','))>0) THEN
	
		INSERT INTO rep_bonus_detail(hotel_group_id,hotel_id,biz_date,accnt,master_id,NAME,id_no,sta,rmtype,rmno,arr,dep,real_rate,salesman,ratecode,market,packages,specials)
			SELECT a.hotel_group_id,a.hotel_id,var_bdate,a.id,a.master_id,b.name,b.id_no,a.sta,a.rmtype,a.rmno,a.arr,a.dep,SUM(a.real_rate),a.salesman,a.ratecode,a.market,a.packages,MAX(a.specials)
			FROM master_base_till a,master_guest_till b 
			WHERE a.id=b.id AND INSTR(CONCAT(',',var_ratecodes,','),CONCAT(',',a.ratecode,','))>0 AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id 
				AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.rsv_class='F' AND a.id<>a.rsv_id 
				AND (a.sta = 'I' OR (a.sta IN ('O','S') AND NOT EXISTS(SELECT 1 FROM master_base_last c WHERE a.id=c.id)))
				GROUP BY a.master_id ORDER BY rmno+0;	
		
		-- 房价码 QDJ 为基础价或底价
		UPDATE rep_bonus_detail a,code_ratecode_detail b SET a.base_rate = IFNULL(b.rate1,0) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date = var_bdate AND b.date = var_bdate
				AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.code = 'QDJ' AND a.rmtype = b.rmtype;
				
		-- 协议价
		UPDATE rep_bonus_detail a,code_ratecode_detail b SET a.nego_rate = IFNULL(b.rate1,0) 
			WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.biz_date = var_bdate AND b.date = var_bdate
				AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.code = a.ratecode AND a.rmtype = b.rmtype;
	ELSE
		SET arg_ret = -1,arg_msg = 'Error';
		LEAVE label_0;
	END IF;
	
	IF arg_hotel_id = 9 THEN
		UPDATE rep_bonus_detail SET bonus_amount = ROUND((real_rate - base_rate)*0.06,4) WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date = var_bdate AND real_rate >= base_rate;
	ELSE
		UPDATE rep_bonus_detail SET bonus_amount = 1.5 + ROUND((real_rate - base_rate)*0.03,4) WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date = var_bdate AND real_rate >= base_rate;
	END IF;
				
END$$

DELIMITER ;