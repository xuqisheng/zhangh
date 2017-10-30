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

    -- 直接更新的表
    UPDATE pos_account          SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_account_history  SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_audit_master     SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode   WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_audit_report     SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode   WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_pccode           SET hotel_id = arg_new_hotelid,code = arg_new_poscode   WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND code = arg_old_poscode;
    UPDATE pos_pccode_addition  SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_master           SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_master_history   SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    -- UPDATE pos_mode_def         SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    -- 菜谱有些是菜用的，不这样简单的处理
    -- UPDATE pos_pccode_note      SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    -- UPDATE pos_pccode_note_type SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_pccode_shift     SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_pccode_table     SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_res              SET hotel_id = arg_new_hotelid,pccode = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pccode = arg_old_poscode;
    UPDATE pos_interface_map    SET hotel_id = arg_new_hotelid,pos_code = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND pos_code = arg_old_poscode AND link_type='ta_code';
    UPDATE pos_interface_map    SET hotel_id = arg_new_hotelid,sys_code = arg_new_poscode WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_old_hotelid AND sys_code = arg_old_poscode AND link_type='item_code';

    -- 关联更新的表
    UPDATE pos_detail a,pos_master b                    SET a.hotel_id = arg_new_hotelid WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_old_hotelid AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_new_hotelid AND a.accnt = b.accnt AND b.pccode = arg_new_poscode;
    UPDATE pos_detail_history a,pos_master_history b    SET a.hotel_id = arg_new_hotelid WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_old_hotelid AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_new_hotelid AND a.accnt = b.accnt AND b.pccode = arg_new_poscode;

    UPDATE pos_close a,pos_master b                     SET a.hotel_id = arg_new_hotelid WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_old_hotelid AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_new_hotelid AND a.accnt = b.accnt;
    UPDATE pos_close a,pos_master_history b             SET a.hotel_id = arg_new_hotelid WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_old_hotelid AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_new_hotelid AND a.accnt = b.accnt;

    UPDATE pos_pay a,pos_res b                          SET a.hotel_id = arg_new_hotelid WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_old_hotelid AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_new_hotelid AND a.accnt = b.accnt;
    UPDATE pos_res_order a,pos_res b                    SET a.hotel_id = arg_new_hotelid WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_old_hotelid AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_new_hotelid AND a.accnt = b.accnt;

    -- 菜本【菜本、菜类、菜项都存在冲突的可能，感觉不能这么简单处理?】
    -- 菜本
    UPDATE code_base a,pos_pccode_note b    SET a.hotel_id = b.hotel_id WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_old_hotelid AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_new_hotelid AND a.code = b.note_code AND a.parent_code = 'pos_note' AND b.pccode = arg_new_poscode;
    -- 菜类
    UPDATE pos_sort_all a,pos_pccode_note b SET a.hotel_id = b.hotel_id WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_old_hotelid AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_new_hotelid AND a.plu_code = b.note_code AND b.pccode = arg_new_poscode ;
    -- 菜项
    UPDATE pos_plu_all a,pos_sort_all b,pos_pccode_note c SET a.hotel_id = b.hotel_id WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_old_hotelid
        AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_new_hotelid
        AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_new_hotelid
        AND b.plu_code = c.note_code AND c.pccode = arg_new_poscode AND a.sort_code = b.code;





END$$

DELIMITER ;

/*
SELECT * FROM code_base WHERE hotel_group_id = 2 AND hotel_id = 18 AND parent_code = 'pos_note'
INSERT INTO code_base(hotel_group_id,hotel_id,CODE,parent_code,descript,descript_en,max_len,flag,code_category,is_sys,is_group,group_code,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime,code_type)
SELECT hotel_group_id,21,CODE,parent_code,descript,descript_en,max_len,flag,code_category,is_sys,is_group,group_code,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime,code_type
FROM code_base WHERE hotel_group_id = 2 AND hotel_id = 18 AND parent_code = 'pos_note'


SELECT * FROM pos_sort_all WHERE hotel_group_id = 2 AND hotel_id = 18 AND plu_code='70'
INSERT INTO pos_sort_all(hotel_group_id,hotel_id,CODE,plu_code,descript,descript_en,condst,tocode,is_halt,list_order,is_group,group_code,code_type,create_user,create_datetime,modify_user,modify_datetime)
SELECT hotel_group_id,21,CODE,plu_code,descript,descript_en,condst,tocode,is_halt,list_order,is_group,group_code,code_type,create_user,create_datetime,modify_user,modify_datetime
FROM pos_sort_all WHERE hotel_group_id = 2 AND hotel_id = 18 AND plu_code='70'

SELECT * FROM pos_plu_all WHERE hotel_group_id = 2 AND hotel_id = 18 AND sort_code IN (SELECT CODE FROM pos_sort_all WHERE hotel_group_id = 2 AND hotel_id = 18 )
INSERT INTO pos_plu_all(hotel_group_id,hotel_id,CODE,sort_code,descript,descript_en,helpcode,price,unit,cost_price,MODE,menu,flag,condgp1,tocode,timecode,pt_num,has_pic,
pic_path1,is_central,introduction,plu_material,remark,list_order,is_halt,is_group,group_code,code_type,create_user,create_datetime,modify_user,modify_datetime)
SELECT hotel_group_id,21,CODE,sort_code,descript,descript_en,helpcode,price,unit,cost_price,MODE,menu,flag,condgp1,tocode,timecode,pt_num,has_pic,
pic_path1,is_central,introduction,plu_material,remark,list_order,is_halt,is_group,group_code,code_type,create_user,create_datetime,modify_user,modify_datetime
FROM pos_plu_all WHERE hotel_group_id = 2 AND hotel_id = 18 AND sort_code IN (SELECT CODE FROM pos_sort_all WHERE hotel_group_id = 2 AND hotel_id = 18 )

SELECT * FROM pos_pccode WHERE hotel_group_id = 2 AND hotel_id = 18 AND CODE='700'
INSERT INTO pos_pccode(hotel_group_id,hotel_id,ta_code,CODE,descript,descript_en,menu_type,dsc_rate,serve_rate,tax_rate,dec_length,dec_mode,ground_bmp,
quantity,overquan,deptno,LANGUAGE,remark,exp1,exp2,exp3,exp4,is_group,group_code,code_type,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime)
SELECT hotel_group_id,21,ta_code,CODE,descript,descript_en,menu_type,dsc_rate,serve_rate,tax_rate,dec_length,dec_mode,ground_bmp,
quantity,overquan,deptno,LANGUAGE,remark,exp1,exp2,exp3,exp4,is_group,group_code,code_type,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime
FROM pos_pccode WHERE hotel_group_id = 2 AND hotel_id = 18 AND CODE='700'

SELECT * FROM pos_pccode_note WHERE hotel_group_id = 2 AND hotel_id = 18 AND note_code='70'
INSERT INTO pos_pccode_note(hotel_group_id,hotel_id,pccode,note_code,is_halt,list_order,is_group,group_code,code_type,create_user,create_datetime,modify_user,modify_datetime)
SELECT hotel_group_id,21,pccode,note_code,is_halt,list_order,is_group,group_code,code_type,create_user,create_datetime,modify_user,modify_datetime
FROM pos_pccode_note WHERE hotel_group_id = 2 AND hotel_id = 18 AND note_code='70'

SELECT * FROM pos_pccode_table WHERE hotel_group_id = 2 AND hotel_id = 18 AND pccode='700'
INSERT INTO pos_pccode_table(hotel_group_id,hotel_id,CODE,TYPE,pccode,descript,descript_en,sta,MODE,amount,min_id,AREA,regcode,X,Y,width,height,tag,mapcode,modi,reason,
placecode,is_group,group_code,code_type,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime)
SELECT hotel_group_id,21,CODE,TYPE,pccode,descript,descript_en,sta,MODE,amount,min_id,AREA,regcode,X,Y,width,height,tag,mapcode,modi,reason,
placecode,is_group,group_code,code_type,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime
FROM pos_pccode_table WHERE hotel_group_id = 2 AND hotel_id = 18 AND pccode='700'

SELECT * FROM pos_interface_map WHERE hotel_group_id = 2 AND hotel_id = 18 AND link_type = 'ta_code' AND pos_code='700'
SELECT * FROM pos_interface_map WHERE hotel_group_id = 2 AND hotel_id = 18 AND link_type = 'item_code' AND sys_code='700'
SELECT * FROM pos_interface_map WHERE hotel_group_id = 2 AND hotel_id = 18 AND link_type IN ('casher','pay_code')
INSERT INTO pos_interface_map(hotel_group_id,hotel_id,link_type,CODE,descript,descript_en,pos_code,sys_code,link_cashier,point_rate,create_user,create_datetime,modify_user,modify_datetime,other)
SELECT hotel_group_id,21,link_type,CODE,descript,descript_en,pos_code,sys_code,link_cashier,point_rate,create_user,create_datetime,modify_user,modify_datetime,other
FROM pos_interface_map WHERE hotel_group_id = 2 AND hotel_id = 18 AND link_type = 'ta_code' AND pos_code='700'
UNION ALL
SELECT hotel_group_id,21,link_type,CODE,descript,descript_en,pos_code,sys_code,link_cashier,point_rate,create_user,create_datetime,modify_user,modify_datetime,other
FROM pos_interface_map WHERE hotel_group_id = 2 AND hotel_id = 18 AND link_type = 'item_code' AND sys_code='700'
UNION ALL
SELECT hotel_group_id,21,link_type,CODE,descript,descript_en,pos_code,sys_code,link_cashier,point_rate,create_user,create_datetime,modify_user,modify_datetime,other
FROM pos_interface_map WHERE hotel_group_id = 2 AND hotel_id = 18 AND link_type IN ('casher','pay_code')
*/

