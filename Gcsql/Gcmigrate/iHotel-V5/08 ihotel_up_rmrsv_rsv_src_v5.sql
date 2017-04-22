DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_rmrsv_rsv_src_v5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_rmrsv_rsv_src_v5`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- -------------------------------------	
	-- V5预订部分资源
	-- -------------------------------------
 
	DECLARE var_accnt_rsv BIGINT(16); 
	DECLARE var_rsv_src BIGINT(16); 
	DECLARE var_rsv_rmno BIGINT(16); 
	DECLARE var_rsv_gst BIGINT(16); 
	
	DECLARE var_accnt_old CHAR(7); 
	DECLARE var_rmno CHAR(10); 
	DECLARE var_arr DATETIME; 
	DECLARE var_dep DATETIME; 
	DECLARE var_int INTEGER ;
	DECLARE var_current DATETIME; 
	
	DECLARE done_cursor INT DEFAULT 0 ;
	DECLARE c_rsvsrc CURSOR FOR 
		SELECT id, arr, dep FROM master_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id  AND ((sta='R' AND rsv_class = 'F') OR (rsv_class = 'G' AND sta IN('R','I','S'))); 
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1 ;
	SET var_current = NOW(); 
	DELETE FROM up_status WHERE hotel_id=arg_hotel_id AND up_step='RSVSRC';
	INSERT INTO up_status(hotel_id, up_step, time_begin, time_end, time_long, remark) VALUES(arg_hotel_id, 'RSVSRC', NOW(), NULL, 0, ''); 
	
	DELETE FROM rsv_src WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id ; 
 	
	OPEN c_rsvsrc ;
	SET done_cursor = 0 ;
	FETCH c_rsvsrc INTO var_accnt_rsv, var_arr, var_dep; 
	label_1:WHILE done_cursor = 0 DO
		BEGIN
			SET var_accnt_old=''; 
			SELECT LEFT(accnt_old, 7) INTO var_accnt_old FROM up_map_accnt WHERE hotel_id=arg_hotel_id AND accnt_type IN ('grpmst', 'master_r') AND accnt_new=var_accnt_rsv; 
			IF var_accnt_old <> '' THEN 
				IF MID(var_accnt_old, 2, 1)>='8' THEN  
					INSERT INTO rsv_src (hotel_group_id, hotel_id, occ_flag, accnt, list_order, rmtype, rmno, block_id, arr_date, dep_date, rmnum, 
						rsv_arr_date, rsv_dep_date, adult, children, rack_rate, nego_rate, real_rate, dsc_reason, remark, rsv_occ_id, master_id, 
						ratecode, src, market, packages, specials, amenities,up_rmtype, is_sure_rate, create_user, create_datetime, modify_user, modify_datetime)
					SELECT a.hotel_group_id, a.hotel_id, CONCAT('R', a.rsv_class), a.id, 0, b.type, '', 0, c.begin_, c.end_, c.quantity, 
						c.begin_, c.end_, c.guest, 0, c.rate, c.rate, c.rate, '', c.remark, NULL, 0, 
						d.tranlog, d.mkt, d.src, '', d.srqs, '', '','T', d.resby, d.reserved, d.cby, d.changed
					FROM master_base a, migrate_xc.rsvdtl b, migrate_xc.rsvgrp c, migrate_xc.grpmst d
					WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=var_accnt_rsv 
						AND b.accnt=var_accnt_old AND b.accnt=c.accnt AND b.accnt=d.accnt 
						AND b.type=c.type AND b.begin_=c.begin_ AND b.end_=c.end_; 
				ELSE  
					INSERT INTO rsv_src (hotel_group_id, hotel_id, occ_flag, accnt, list_order, rmtype, rmno, block_id, arr_date, dep_date, rmnum, 
						rsv_arr_date, rsv_dep_date, adult, children, rack_rate, nego_rate, real_rate, dsc_reason, remark, rsv_occ_id, master_id, 
						ratecode, src, market, packages, specials, amenities,up_rmtype, is_sure_rate, create_user, create_datetime, modify_user, modify_datetime)
					SELECT a.hotel_group_id, a.hotel_id, IF(b.roomno <> '','MF','RF'), a.id, 0, b.type, b.roomno, 0, b.begin_, b.end_, b.quantity, 
						b.begin_, b.end_, d.gstno, d.children, d.qtrate, d.qtrate, d.setrate*(1-d.discount1), d.rtreason, a.remark, NULL, 0, 
						d.tranlog, d.mkt, d.src, '', d.srqs, '','', 'T', d.resby, d.reserved, d.cby, d.changed
					FROM master_base a, migrate_xc.rsvdtl b, migrate_xc.master d
					WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.id=var_accnt_rsv 
						AND b.accnt=var_accnt_old AND b.accnt=d.accnt; 
 				END IF; 
			END IF; 
			SET done_cursor = 0 ;
			FETCH c_rsvsrc INTO var_accnt_rsv, var_arr, var_dep; 
		END ;
	END WHILE ;
	CLOSE c_rsvsrc ;	

	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='RSVSRC';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='RSVSRC';
		
	BEGIN
		LEAVE label_0 ;
	END ;
	
END$$

DELIMITER ;