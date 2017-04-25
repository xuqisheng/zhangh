DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_proc_demo`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_proc_demo`(
	IN arg_hotel_group_id 	INT,
	IN arg_from_id 		    INT,
	IN arg_to_id            INT,
	IN arg_pos_pccode       VARCHAR(10)
    )
	
	SQL SECURITY INVOKER
label_0:
BEGIN
    /*
        营业点及营业数据从A酒店更换到B酒店
    */
    DECLARE var_return VARCHAR(50);

	SET @procresult = 1;

    IF EXISTS(SELECT 1 FROM pos_pccode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_to_id AND code = arg_pos_pccode) THEN
        SET var_return = '目标营业点代码相同，将造成索引冲突';
        SELECT var_return;
        BEGIN
            SET @procresult = 0 ;
            LEAVE label_0 ;
        END ;
    END IF;

    UPDATE pos_pccode  SET hotel_id = arg_to_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_from_id AND code = arg_pos_pccode;
    UPDATE pos_account SET hotel_id = arg_to_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_from_id AND pccode = arg_pos_pccode;
    UPDATE pos_account_history SET hotel_id = arg_to_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_from_id AND pccode = arg_pos_pccode;
    UPDATE pos_audit_master SET hotel_id = arg_to_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_from_id AND pccode = arg_pos_pccode;
    UPDATE pos_audit_report SET hotel_id = arg_to_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_from_id AND pccode = arg_pos_pccode;
    UPDATE pos_master SET hotel_id = arg_to_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_from_id AND pccode = arg_pos_pccode;
    UPDATE pos_master_history SET hotel_id = arg_to_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_from_id AND pccode = arg_pos_pccode;
    UPDATE pos_mode_def SET hotel_id = arg_to_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_from_id AND pccode = arg_pos_pccode;
    UPDATE pos_mode_def SET hotel_id = arg_to_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_from_id AND pccode = arg_pos_pccode;
    UPDATE pos_pccode_note SET hotel_id = arg_to_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_from_id AND pccode = arg_pos_pccode;
    UPDATE pos_pccode_shift SET hotel_id = arg_to_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_from_id AND pccode = arg_pos_pccode;
    UPDATE pos_pccode_table SET hotel_id = arg_to_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_from_id AND pccode = arg_pos_pccode;
    UPDATE pos_res SET hotel_id = arg_to_id WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_from_id AND pccode = arg_pos_pccode;

    UPDATE pos_detail a,pos_master b SET a.hotel_id = b.hotel_id WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_from_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_to_id
    AND a.accnt = b.accnt AND b.pccode = arg_pos_pccode;
    UPDATE pos_detail_history a,pos_master_history b SET a.hotel_id = b.hotel_id WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_from_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_to_id
    AND a.accnt = b.accnt AND b.pccode = arg_pos_pccode;




END$$

DELIMITER ;