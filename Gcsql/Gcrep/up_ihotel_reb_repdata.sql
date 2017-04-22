DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_reb_repdata`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_reb_repdata`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN arg_bizdate			DATETIME
)
    SQL SECURITY INVOKER
label_0:
BEGIN
 	-- ==================================================================
	-- 用途：biz_month 会计周期出错后数据处理
	-- 解释: 
	-- 范例: 
	-- 作者：
	-- ================================================================== 
 
	DELETE FROM biz_month WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_year=2014;
	INSERT INTO `biz_month` (`hotel_group_id`, `hotel_id`, `biz_year`, `biz_month`, `begin_date`, `end_date`, `day_num`, `remark`, `create_user`, `create_datetime`, `modify_user`, `modify_datetime`) 
	VALUES
	(arg_hotel_group_id,arg_hotel_id,'2014','1','2014-01-01 00:00:00','2014-01-31 00:00:00','31','','ADMIN','2011-12-28 20:36:06','ADMIN','2011-12-28 20:36:06'),
	(arg_hotel_group_id,arg_hotel_id,'2014','2','2014-02-01 00:00:00','2014-02-28 00:00:00','28','','ADMIN','2011-12-28 20:36:06','ADMIN','2011-12-28 20:36:06'),
	(arg_hotel_group_id,arg_hotel_id,'2014','3','2014-03-01 00:00:00','2014-03-31 00:00:00','31','','ADMIN','2011-12-28 20:36:06','ADMIN','2011-12-28 20:36:06'),
	(arg_hotel_group_id,arg_hotel_id,'2014','4','2014-04-01 00:00:00','2014-04-30 00:00:00','30','','ADMIN','2011-12-28 20:36:06','ADMIN','2011-12-28 20:36:06'),
	(arg_hotel_group_id,arg_hotel_id,'2014','5','2014-05-01 00:00:00','2014-05-31 00:00:00','31','','ADMIN','2011-12-28 20:36:06','ADMIN','2011-12-28 20:36:06'),
	(arg_hotel_group_id,arg_hotel_id,'2014','6','2014-06-01 00:00:00','2014-06-30 00:00:00','30','','ADMIN','2011-12-28 20:36:06','ADMIN','2011-12-28 20:36:06'),
	(arg_hotel_group_id,arg_hotel_id,'2014','7','2014-07-01 00:00:00','2014-07-31 00:00:00','31','','ADMIN','2011-12-28 20:36:06','ADMIN','2011-12-28 20:36:06'),
	(arg_hotel_group_id,arg_hotel_id,'2014','8','2014-08-01 00:00:00','2014-08-31 00:00:00','31','','ADMIN','2011-12-28 20:36:06','ADMIN','2011-12-28 20:36:06'),
	(arg_hotel_group_id,arg_hotel_id,'2014','9','2014-09-01 00:00:00','2014-09-30 00:00:00','30','','ADMIN','2011-12-28 20:36:06','ADMIN','2011-12-28 20:36:06'),
	(arg_hotel_group_id,arg_hotel_id,'2014','10','2014-10-01 00:00:00','2014-10-31 00:00:00','31','','ADMIN','2011-12-28 20:36:06','ADMIN','2011-12-28 20:36:06'),
	(arg_hotel_group_id,arg_hotel_id,'2014','11','2014-11-01 00:00:00','2014-11-30 00:00:00','30','','ADMIN','2011-12-28 20:36:06','ADMIN','2011-12-28 20:36:06'),
	(arg_hotel_group_id,arg_hotel_id,'2014','12','2014-12-01 00:00:00','2014-12-31 00:00:00','31','','ADMIN','2011-12-28 20:36:06','ADMIN','2011-12-28 20:36:06');

	SET arg_bizdate = ADDDATE(arg_bizdate,-1);
 
	DELETE FROM rep_jie WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	INSERT INTO rep_jie (hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,rectype,toop,toclass,sequence,day01,day02,day03,day04,day05,day06,day07,day08,day09,day99,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99)
	SELECT hotel_group_id,hotel_id,biz_date,orderno,itemno,modeno,classno,descript,descript1,rectype,toop,toclass,sequence,day01,day02,day03,day04,day05,day06,day07,day08,day09,day99,month01,month02,month03,month04,month05,month06,month07,month08,month09,month99 FROM rep_jie_history WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_bizdate;


	DELETE FROM rep_dai WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	INSERT INTO rep_dai (hotel_group_id, hotel_id, biz_date, orderno, itemno, modeno, classno, descript, descript1, sequence, credit01, credit02, credit03, credit04, credit05, credit06, credit07, sumcre, last_bl, debit, credit, till_bl, credit01m, credit02m, credit03m, credit04m, credit05m, credit06m, credit07m, sumcrem, last_blm, debitm, creditm, till_blm)
	SELECT hotel_group_id, hotel_id, biz_date, orderno, itemno, modeno, classno, descript, descript1, sequence, credit01, credit02, credit03, credit04, credit05, credit06, credit07, sumcre, last_bl, debit, credit, till_bl, credit01m, credit02m, credit03m, credit04m, credit05m, credit06m, credit07m, sumcrem, last_blm, debitm, creditm, till_blm FROM rep_dai_history WHERE
	hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_bizdate;

	DELETE FROM rep_jiedai WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	INSERT INTO rep_jiedai(hotel_group_id, hotel_id, biz_date, orderno, itemno, modeno, classno, descript, descript1, sequence, last_charge, last_credit, charge, credit, apply, till_charge, till_credit, last_chargem, last_creditm, chargem, creditm, applym, till_chargem, till_creditm)
	SELECT hotel_group_id, hotel_id, biz_date, orderno, itemno, modeno, classno, descript, descript1, sequence, last_charge, last_credit, charge, credit, apply, till_charge, till_credit, last_chargem, last_creditm, chargem, creditm, applym, till_chargem, till_creditm FROM rep_jiedai_history WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_bizdate;


	DELETE FROM guest_sta_inland WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	INSERT INTO guest_sta_inland (hotel_group_id,hotel_id,date,guest_class,where_from,descript,descript1,list_order,dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
	SELECT hotel_group_id,hotel_id,date,guest_class,where_from,descript,descript1,list_order,dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt FROM guest_sta_inland_history WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND date=arg_bizdate;	
	
	DELETE FROM guest_sta_overseas WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	INSERT INTO guest_sta_overseas (hotel_group_id,hotel_id,date,guest_class,nation,list_order,descript,descript1,sequence,dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt)
	SELECT hotel_group_id,hotel_id,date,guest_class,nation,list_order,descript,descript1,sequence,dtc,dgc,dmc,dtt,dgt,dmt,mtc,mgc,mmc,mtt,mgt,mmt,ytc,ygc,ymc,ytt,ygt,ymt FROM guest_sta_overseas_history WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND date=arg_bizdate;	
	
	
	DELETE FROM rep_trial_balance WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	INSERT INTO rep_trial_balance (hotel_group_id, hotel_id, biz_date, item_type, item_code, descript, descript_en, amount, amount_m, amount_y)
	SELECT hotel_group_id, hotel_id, biz_date, item_type, item_code, descript, descript_en, amount, amount_m, amount_y FROM rep_trial_balance_history WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND biz_date=arg_bizdate;
 
	
END$$

DELIMITER ;

CALL portal_tr.up_ihotel_reb_repdata(2,9);

DROP PROCEDURE IF EXISTS `up_ihotel_reb_repdata`;