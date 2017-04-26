DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_proc_demo`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_proc_demo`(
	IN arg_hotel_group_id 	INT,
	IN arg_old_hotelid 		INT,
	IN arg_new_hotelid      INT,
	IN arg_old_poscode      VARCHAR(10),
	IN arg_new_poscode      VARCHAR(10)
    )
	
	SQL SECURITY INVOKER
label_0:
BEGIN
    /*
        营业点及营业数据从A酒店更换到B酒店,仅支持同库
    */
    DECLARE var_return VARCHAR(50);

	SET @procresult = 1;


    IF EXISTS(SELECT 1 FROM pos_pccode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_new_hotelid AND code = arg_new_poscode) THEN
        SET var_return = '目标营业点代码相同，将造成索引冲突,请更换新代码';
        SELECT var_return;
        BEGIN
            SET @procresult = 0 ;
            LEAVE label_0 ;
        END ;
    END IF;

    UPDATE pos_pccode           SET hotel_id = arg_new_hotelid,code = arg_new_poscode   WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND code = arg_old_poscode;
    UPDATE pos_pccode_addition  SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_account          SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_account_history  SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_audit_master     SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_audit_report     SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_master           SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_master_history   SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_mode_def         SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_pccode_note      SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_pccode_note_type SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_pccode_shift     SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_pccode_table     SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_res              SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;

    UPDATE pos_detail a,pos_master b                    SET a.hotel_id = b.hotel_id,a.pccode = arg_new_poscode WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_old_hotelid AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_new_hotelid AND a.accnt = b.accnt AND b.pccode = arg_new_poscode;
    UPDATE pos_detail_history a,pos_master_history b    SET a.hotel_id = b.hotel_id,a.pccode = arg_new_poscode WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_old_hotelid AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_new_hotelid AND a.accnt = b.accnt AND b.pccode = arg_new_poscode;
    -- 菜本【菜本、菜类、菜项都存在冲突的可能，感觉不能这么简单处理?】
    UPDATE code_base a,pos_pccode_note b    SET a.hotel_id = b.hotel_id WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_old_hotelid AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_new_hotelid AND a.code = b.note_code AND a.parent_code = 'pos_note' AND b.pccode = arg_new_poscode;
    UPDATE pos_sort_all a,pos_pccode_note b SET a.hotel_id = b.hotel_id WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_old_hotelid AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_new_hotelid AND a.plu_code = b.note_code AND b.pccode = arg_new_poscode ;
    UPDATE pos_plu_all a,pos_sort_all b,pos_pccode_note c SET a.hotel_id = b.hotel_id WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_old_hotelid
        AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_new_hotelid
        AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_new_hotelid
        AND b.plu_code = c.note_code AND c.pccode = arg_new_poscode AND a.sort_code = b.code;

    -- 餐饮预定
    UPDATE pos_res_order a,pos_res b SET a.hotel_id = b.hotel_id WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_old_hotelid AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_new_hotelid AND a.accnt = b.accnt AND b.pccode = arg_new_poscode;


END$$

DELIMITER ;