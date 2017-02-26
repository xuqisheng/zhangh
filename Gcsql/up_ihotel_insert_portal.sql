DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_insert_portal`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_insert_portal`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN arg_bizdate			DATETIME
)
    SQL SECURITY INVOKER
label_0:
BEGIN
 	-- ==================================================================
	-- 用途：从培训库插入正式库
	-- 解释: 
	-- 范例: 
	-- 作者：
	-- ================================================================== 
 
	UPDATE portal.rep_jie_history SET hotel_id=-hotel_id WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_bizdate;
	INSERT INTO portal.rep_jie_history (hotel_group_id,hotel_id,id,biz_date,orderno,itemno,modeno,classno,descript,descript1,rectype,toop,toclass,sequence,day01,day02,day03,day04,day05,day06,day07,day08,day09,day99,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99)
	SELECT hotel_group_id,hotel_id,id,biz_date,orderno,itemno,modeno,classno,descript,descript1,rectype,toop,toclass,sequence,day01,day02,day03,day04,day05,day06,day07,day08,day09,day99,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99 FROM portal_tr.rep_jie_history WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_bizdate;


	UPDATE portal.rep_dai_history SET hotel_id=-hotel_id WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_bizdate;
	INSERT INTO portal.rep_dai_history (hotel_group_id, hotel_id,id, biz_date, orderno, itemno, modeno, classno, descript, descript1, sequence, credit01, credit02, credit03, credit04, credit05, credit06, credit07, sumcre, last_bl, debit, credit, till_bl, credit01m, credit02m, credit03m, credit04m, credit05m, credit06m, credit07m, sumcrem, last_blm, debitm, creditm, till_blm)
	SELECT hotel_group_id, hotel_id,id, biz_date, orderno, itemno, modeno, classno, descript, descript1, sequence, credit01, credit02, credit03, credit04, credit05, credit06, credit07, sumcre, last_bl, debit, credit, till_bl, credit01m, credit02m, credit03m, credit04m, credit05m, credit06m, credit07m, sumcrem, last_blm, debitm, creditm, till_blm FROM portal_tr.rep_dai_history WHERE
	hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_bizdate;


	UPDATE portal.rep_jiedai_history SET hotel_id=-hotel_id WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_bizdate;
	INSERT INTO portal.rep_jiedai_history(hotel_group_id, hotel_id,id, biz_date, orderno, itemno, modeno, classno, descript, descript1, sequence, last_charge, last_credit, charge, credit, apply, till_charge, till_credit, last_chargem, last_creditm, chargem, creditm, applym, till_chargem, till_creditm)
	SELECT hotel_group_id, hotel_id,id, biz_date, orderno, itemno, modeno, classno, descript, descript1, sequence, last_charge, last_credit, charge, credit, apply, till_charge, till_credit, last_chargem, last_creditm, chargem, creditm, applym, till_chargem, till_creditm FROM portal_tr.rep_jiedai_history WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_bizdate;


	UPDATE portal.rep_trial_balance_history SET hotel_id=-hotel_id WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_bizdate;
	INSERT INTO portal.rep_trial_balance_history (hotel_group_id, hotel_id,id, biz_date, item_type, item_code, descript, descript_en, amount, amount_m, amount_y)
	SELECT hotel_group_id, hotel_id,id, biz_date, item_type, item_code, descript, descript_en, amount, amount_m, amount_y FROM portal_tr.rep_trial_balance_history WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_bizdate;
 
 
	UPDATE portal.guest_sta_inland SET hotel_id=-hotel_id WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND date=arg_bizdate;
	INSERT INTO portal.guest_sta_inland (hotel_group_id,hotel_id,date,guest_class,where_from,descript,descript1,list_order,dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
	SELECT hotel_group_id,hotel_id,date,guest_class,where_from,descript,descript1,list_order,dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt FROM portal_tr.guest_sta_inland_history WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND date=arg_bizdate;
	
	UPDATE portal.guest_sta_overseas SET hotel_id=-hotel_id WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND date=arg_bizdate;	
	INSERT INTO portal.guest_sta_overseas (hotel_group_id,hotel_id,date,guest_class,nation,list_order,descript,descript1,sequence,dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
	SELECT hotel_group_id,hotel_id,date,guest_class,nation,list_order,descript,descript1,sequence,dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt FROM portal_tr.guest_sta_overseas_history WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND date=arg_bizdate;	

 
 

	
END$$

DELIMITER ;

CALL portal_tr.up_ihotel_insert_portal(2,9);

DROP PROCEDURE IF EXISTS `up_ihotel_insert_portal`;