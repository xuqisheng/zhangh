DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_reb_gueststa_month`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_reb_gueststa_month`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT,
	IN arg_begin_date		DATETIME,
	IN arg_end_date			DATETIME
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- =============================================================================
	-- 用途:根据境内每日正确数据重新计算月数据和年数据
	-- 解释:CALL up_ihotel_reb_internal_month(集团id,酒店id,开始日期,结束日期)
	-- 作者:张惠 2014-11-05
	-- =============================================================================
	DECLARE var_bizdate	DATETIME;
		
	
	SELECT biz_date INTO var_bizdate FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	IF arg_end_date > DATE_ADD(var_bizdate,INTERVAL -1 DAY) THEN
		SET arg_end_date=DATE_ADD(var_bizdate,INTERVAL -1 DAY);
	END IF;	

	WHILE arg_begin_date <= arg_end_date DO
		BEGIN
			IF EXISTS(SELECT 1 FROM biz_month WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND begin_date = arg_begin_date AND biz_month = 1) THEN
				BEGIN
					UPDATE guest_sta_inland_history a SET
						a.ytc=a.dtc,a.ygc=a.dgc,a.ymc=a.dmc,a.ytt=a.dtt,a.ygt=a.dgt,a.ymt=a.dmt
					WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.date=arg_begin_date;
					
					UPDATE guest_sta_overseas_history a SET
						a.ytc=a.dtc,a.ygc=a.dgc,a.ymc=a.dmc,a.ytt=a.dtt,a.ygt=a.dgt,a.ymt=a.dmt
					WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.date=arg_begin_date;
				END;
			ELSE
				BEGIN
					UPDATE guest_sta_inland_history a,guest_sta_inland_history b SET
						a.ytc=a.dtc+b.ytc,a.ygc=a.dgc+b.ygc,a.ymc=a.dmc+b.ymc,
						a.ytt=a.dtt+b.ytt,a.ygt=a.dgt+b.ygt,a.ymt=a.dmt+b.ymt
					WHERE a.guest_class=b.guest_class AND a.where_from=b.where_from AND a.descript=b.descript
					AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.date=arg_begin_date
					AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.date=ADDDATE(arg_begin_date,-1);					

					UPDATE guest_sta_overseas_history a,guest_sta_overseas_history b SET
						a.ytc=a.dtc+b.ytc,a.ygc=a.dgc+b.ygc,a.ymc=a.dmc+b.ymc,
						a.ytt=a.dtt+b.ytt,a.ygt=a.dgt+b.ygt,a.ymt=a.dmt+b.ymt
					WHERE a.guest_class=b.guest_class AND a.nation=b.nation AND a.descript=b.descript AND a.list_order=b.list_order
					AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.date=arg_begin_date
					AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.date=ADDDATE(arg_begin_date,-1);				
				END;
			END IF;		
			
			IF EXISTS(SELECT 1 FROM biz_month WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND begin_date = arg_begin_date) THEN
				BEGIN
					UPDATE guest_sta_inland_history a SET
						a.mtc=a.dtc,a.mgc=a.dgc,a.mmc=a.dmc,
						a.mtt=a.dtt,a.mgt=a.dgt,a.mmt=a.dmt
					WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.date=arg_begin_date;
					
					UPDATE guest_sta_overseas_history a SET
						a.mtc=a.dtc,a.mgc=a.dgc,a.mmc=a.dmc,
						a.mtt=a.dtt,a.mgt=a.dgt,a.mmt=a.dmt
					WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.date=arg_begin_date;
				END;
			ELSE
				BEGIN
					UPDATE guest_sta_inland_history a,guest_sta_inland_history b SET
						a.mtc=a.dtc+b.mtc,a.mgc=a.dgc+b.mgc,a.mmc=a.dmc+b.mmc,
						a.mtt=a.dtt+b.mtt,a.mgt=a.dgt+b.mgt,a.mmt=a.dmt+b.mmt
					WHERE a.guest_class=b.guest_class AND a.where_from=b.where_from AND a.descript=b.descript
					AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.date=arg_begin_date
					AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.date=ADDDATE(arg_begin_date,-1);					

					UPDATE guest_sta_overseas_history a,guest_sta_overseas_history b SET
						a.mtc=a.dtc+b.mtc,a.mgc=a.dgc+b.mgc,a.mmc=a.dmc+b.mmc,
						a.mtt=a.dtt+b.mtt,a.mgt=a.dgt+b.mgt,a.mmt=a.dmt+b.mmt
					WHERE a.guest_class=b.guest_class AND a.nation=b.nation AND a.descript=b.descript AND a.list_order=b.list_order
					AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.date=arg_begin_date
					AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.date=ADDDATE(arg_begin_date,-1);					
				END;
			END IF;
			
			SET arg_begin_date = DATE_ADD(arg_begin_date,INTERVAL 1 DAY);
		END;
	END WHILE;			
	
	UPDATE guest_sta_inland a,guest_sta_inland_history b SET
		a.mtc=a.mtc,a.mgc=a.mgc,a.mmc=a.mmc,
		a.mtt=a.mtt,a.mgt=a.mgt,a.mmt=a.mmt
	WHERE a.guest_class=b.guest_class AND a.where_from=b.where_from AND a.descript=b.descript
	AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.date=arg_end_date
	AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.date=arg_end_date;					
	
	UPDATE guest_sta_overseas a,guest_sta_overseas_history b SET
		a.mtc=a.mtc,a.mgc=a.mgc,a.mmc=a.mmc,
		a.mtt=a.mtt,a.mgt=a.mgt,a.mmt=a.mmt
	WHERE a.guest_class=b.guest_class AND a.nation=b.nation AND a.descript=b.descript AND a.list_order=b.list_order
	AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.date=arg_end_date
	AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.date=arg_end_date;	

END$$

DELIMITER ;

-- CALL up_ihotel_reb_gueststa_month(1,1,'2014-10-30','2014-11-03');

-- DROP PROCEDURE IF EXISTS `up_ihotel_reb_gueststa_month`;