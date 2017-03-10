DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_up_exec_all`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_up_exec_all`(
	IN arg_biz_date			DATETIME,
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT
	)
SQL SECURITY INVOKER
label_0:
BEGIN
	
	CALL up_ihotel_up_code_init(arg_hotel_group_id,arg_hotel_id,arg_biz_date);	
	CALL up_ihotel_up_guest_fit(arg_hotel_group_id,arg_hotel_id);
	CALL up_ihotel_up_guest_grp(arg_hotel_group_id,arg_hotel_id);	   
	
	CALL portal_group.up_ihotel_up_company(arg_hotel_group_id,arg_hotel_id);
	
	CALL up_ihotel_up_master_si(arg_hotel_group_id,arg_hotel_id);
	CALL up_ihotel_up_rmrsv_rsv_src(arg_hotel_group_id,arg_hotel_id);
	CALL up_ihotel_up_fo_account(arg_hotel_group_id,arg_hotel_id);
	CALL up_ihotel_up_armst(arg_hotel_group_id,arg_hotel_id);
	CALL ihotel_up_code_maint(arg_hotel_group_id,arg_hotel_id);		
	CALL up_ihotel_rsvrate_reb(arg_hotel_group_id,arg_hotel_id,@a);

	
END$$

DELIMITER ;