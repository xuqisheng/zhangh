DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_syslistmeta`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_zhangh_syslistmeta`()
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- ==================================================================
	-- 用途：往sys_list_meta添加	
	-- 解释: 
	-- 范例: 
	-- 作者：
	-- ==================================================================	
	INSERT INTO sys_list_meta(hotel_group_id, hotel_id, save_id, code, descript, descript_en, count_sql, sql_define, column_sta, column_key, page_size, format_define, is_halt, list_order, create_user, create_datetime, modify_user, modify_datetime)
	VALUES
	('-1','-1',NULL,'invoice_list_f','发票列表','','','SELECT h.descript_short hotelid,t1.org_amount, t1.sta receipt_type,t2.receipt_no, t2.amount,t2.remark, t1.pc_id,t1.close_id, t1.flag, t1.create_user,t1.create_datetime, t1.accnt,t1.id recepitId,t2.id recepitDetailId,t1.company_name,t1.biz_date FROM receipt t1, receipt_detail t2,v_hotel h WHERE (1=1) and t1.hotel_id = h.hotel_id AND t1.hotel_group_id = t2.hotel_group_id AND t1.hotel_id = t2.hotel_id AND t1.id = t2.receipt_id AND t1.hotel_group_id = #HOTEL_GROUP_ID#',NULL,NULL,'0','<columns>\n  <column width=\"50\" minWidth=\"\" dataField=\"closeTag\" headerText=\"账单号\" type=\"\" editable=\"FALSE\" draggable=\"true\" sortable=\"true\">\n    <headRender name=\"\"/>\n    <itemRender name=\"\"/>\n    <itemEditor name=\"\"/>\n    <headerStyleName/>\n    <backgroundColor/>\n    <color/>\n    <fontSize/>\n    <textAlign/>\n    <fontFamily/>\n    <fontStyle/>\n    <fontThickness/>\n    <fontWeight/>\n    <paddingLeft/>\n    <paddingRight/>\n    <textDecoration/>\n    <format/>\n  </column>\n  <column width=\"80\" minWidth=\"\" dataField=\"charge\" headerText=\"消费\" type=\"\" editable=\"FALSE\" draggable=\"true\" sortable=\"true\">\n    <headRender name=\"\"/>\n    <itemRender name=\"\"/>\n    <itemEditor name=\"\"/>\n    <headerStyleName/>\n    <backgroundColor/>\n    <color/>\n    <fontSize/>\n    <textAlign/>\n    <fontFamily/>\n    <fontStyle/>\n    <fontThickness/>\n    <fontWeight/>\n    <paddingLeft/>\n    <paddingRight/>\n    <textDecoration/>\n    <format/>\n  </column>\n  <column width=\"100\" minWidth=\"\" dataField=\"pay\" headerText=\"付款\" type=\"\" editable=\"FALSE\" draggable=\"true\" sortable=\"true\">\n    <headRender name=\"\"/>\n    <itemRender name=\"\"/>\n    <itemEditor name=\"\"/>\n    <headerStyleName/>\n    <backgroundColor/>\n    <color/>\n    <fontSize/>\n    <textAlign/>\n    <fontFamily/>\n    <fontStyle/>\n    <fontThickness/>\n    <fontWeight/>\n    <paddingLeft/>\n    <paddingRight/>\n    <textDecoration/>\n    <format/>\n  </column>\n  <column width=\"100\" minWidth=\"\" dataField=\"ar\" headerText=\"记账未收\" type=\"\" editable=\"FALSE\" draggable=\"true\" sortable=\"true\">\n    <headRender name=\"\"/>\n    <itemRender name=\"\"/>\n    <itemEditor name=\"\"/>\n    <headerStyleName/>\n    <backgroundColor/>\n    <color/>\n    <fontSize/>\n    <textAlign/>\n    <fontFamily/>\n    <fontStyle/>\n    <fontThickness/>\n    <fontWeight/>\n    <paddingLeft/>\n    <paddingRight/>\n    <textDecoration/>\n    <format/>\n  </column>\n  <column width=\"100\" minWidth=\"\" dataField=\"trans_accnt\" headerText=\"转账账号\" type=\"\" editable=\"FALSE\" draggable=\"true\" sortable=\"true\">\n    <headRender name=\"\"/>\n    <itemRender name=\"\"/>\n    <itemEditor name=\"\"/>\n    <headerStyleName/>\n    <backgroundColor/>\n    <color/>\n    <fontSize/>\n    <textAlign/>\n    <fontFamily/>\n    <fontStyle/>\n    <fontThickness/>\n    <fontWeight/>\n    <paddingLeft/>\n    <paddingRight/>\n    <textDecoration/>\n    <format/>\n  </column>\n  <column width=\"100\" minWidth=\"\" dataField=\"gen_user\" headerText=\"用户名\" type=\"\" editable=\"FALSE\" draggable=\"true\" sortable=\"true\">\n    <headRender name=\"\"/>\n    <itemRender name=\"\"/>\n    <itemEditor name=\"\"/>\n    <headerStyleName/>\n    <backgroundColor/>\n    <color/>\n    <fontSize/>\n    <textAlign/>\n    <fontFamily/>\n    <fontStyle/>\n    <fontThickness/>\n    <fontWeight/>\n    <paddingLeft/>\n    <paddingRight/>\n    <textDecoration/>\n    <format/>\n  </column>\n  <column width=\"100\" minWidth=\"\" dataField=\"gen_datetime\" headerText=\"时间\" type=\"\" editable=\"FALSE\" draggable=\"true\" sortable=\"true\">\n    <headRender name=\"\"/>\n    <itemRender name=\"\"/>\n    <itemEditor name=\"\"/>\n    <headerStyleName/>\n    <backgroundColor/>\n    <color/>\n    <fontSize/>\n    <textAlign/>\n    <fontFamily/>\n    <fontStyle/>\n    <fontThickness/>\n    <fontWeight/>\n    <paddingLeft/>\n    <paddingRight/>\n    <textDecoration/>\n    <format/>\n  </column>\n</columns>',NULL,NULL,'ADMIN','2014-08-27 12:48:06','ADMIN','2014-08-27 12:48:06');
	
	INSERT INTO sys_list_meta(hotel_group_id,hotel_id,save_id,code,descript,descript_en,sql_define,column_sta,column_key,page_size,format_define,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime)
	SELECT 
		b.hotel_group_id,b.id,a.save_id,a.code,a.descript,a.descript_en,a.sql_define,a.column_sta,a.column_key,a.page_size,a.format_define,a.is_halt,a.list_order,a.create_user,a.create_datetime,a.modify_user,a.modify_datetime
	FROM sys_list_meta a,hotel b WHERE a.hotel_group_id = -1 AND a.hotel_id = -1 AND b.sta IN ('H','I') AND (b.client_type <> 'THEF' OR b.client_type IS NULL)
		AND NOT EXISTS (SELECT 1 FROM sys_list_meta c WHERE c.hotel_group_id = b.hotel_group_id AND c.hotel_id = b.id AND a.code=c.code);
	
	DELETE FROM sys_list_meta WHERE hotel_group_id = -1 AND hotel_id = -1;
	
END$$

DELIMITER ;

CALL up_ihotel_zhangh_syslistmeta();

DROP PROCEDURE IF EXISTS `up_ihotel_zhangh_syslistmeta`