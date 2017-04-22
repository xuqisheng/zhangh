DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_reb_pos_dept`$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `up_ihotel_reb_pos_dept`(
	IN arg_hotel_group_id	INT,	
	IN arg_hotel_id			INT,
	IN arg_biz_date			DATETIME
	)
    SQL SECURITY INVOKER
BEGIN
	-- 餐饮夜审过程
	 DECLARE var_bizdate 		DATETIME;
	 DECLARE var_is_union		VARCHAR(1);	 
	 DECLARE t_error 			INTEGER DEFAULT 0; 
	 DECLARE var_ret			INT;
	 DECLARE var_msg			VARCHAR(60) ;
	 DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET t_error=1; 
label:BEGIN
	SET var_ret = 1, var_msg = '数据重建完成,请进入PMS系统重建报表';
	SELECT set_value INTO var_bizdate FROM sys_option WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog = 'system' AND item = 'biz_date'; 
	-- 查看参数：是否启用餐饮联单分开统计
	SELECT set_value INTO var_is_union FROM sys_option WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog = 'interface' AND item = 'pos_menu_link_bill'; 
	SET var_bizdate = DATE_ADD(var_bizdate,INTERVAL -1 DAY);

	START TRANSACTION; 
	IF arg_biz_date > var_bizdate THEN
		SET  var_ret = -1;
		SET  var_msg = "-1,只能重建本日之前的数据!" ; 
	LEAVE label; 		
	END IF;
	-- 下面为生成pos_deptjie和pos_deptdai数据
	-- 删除当前表
	IF EXISTS(SELECT 1 FROM pos_deptjie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_biz_date) THEN
	DELETE FROM pos_deptjie WHERE hotel_id=arg_hotel_id AND hotel_group_id=arg_hotel_group_id AND biz_date = arg_biz_date;
	END IF;
	
	IF EXISTS(SELECT 1 FROM pos_deptdai WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_biz_date) THEN
		DELETE FROM pos_deptdai WHERE hotel_id=arg_hotel_id AND hotel_group_id=arg_hotel_group_id AND biz_date = arg_biz_date;
	END IF;
	
	-- 插入当前表pos_deptjie，根据参数的设置来判断数据源是pos_dish还是pos_audit_dish	
	IF var_is_union = 'T' THEN
		INSERT INTO `pos_deptjie` (`hotel_group_id`, `hotel_id`, `biz_date`, `ta_code`, `cashier`, `user_code`, `CODE`, `descript`, `descript_en`, `day_mark`, `amount_day`, `amount_month`, `amount_year`, `create_user`, `create_datetime`, `modify_user`, `modify_datetime`) 
		SELECT a.hotel_group_id,a.hotel_id,a.biz_date,a.ta_code,'1',a.create_user,a.ta_code,a.ta_descript,a.ta_descript,'',a.charge,0,0,a.create_user, a.create_datetime, a.modify_user, a.modify_datetime
		FROM pos_audit_dish a,code_transaction b WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.ta_code=b.code AND a.biz_date = arg_biz_date AND  a.hotel_id=arg_hotel_id AND a.hotel_group_id=arg_hotel_group_id AND b.arrange_code<'9';
		    IF t_error = 1 THEN
			SET  var_ret = -1;
			SET  var_msg = "-1,pos_deptjie插入失败，数据重建不成功!" ; 
			LEAVE label; 
		    END IF;
	ELSE
		INSERT INTO `pos_deptjie` (`hotel_group_id`, `hotel_id`, `biz_date`, `ta_code`, `cashier`, `user_code`, `CODE`, `descript`, `descript_en`, `day_mark`, `amount_day`, `amount_month`, `amount_year`, `create_user`, `create_datetime`, `modify_user`, `modify_datetime`) 
		SELECT a.hotel_group_id,a.hotel_id,a.biz_date,a.code,a.cashier,a.puser,a.code,a.descript,a.descript,'',a.fee,0,0,a.create_user, a.create_datetime, a.modify_user, a.modify_datetime
		FROM pos_dish a,code_transaction b WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.code=b.code AND a.biz_date = arg_biz_date AND  a.hotel_id=arg_hotel_id AND a.hotel_group_id=arg_hotel_group_id AND b.arrange_code<'9';
		    IF t_error = 1 THEN
			SET  var_ret = -1;
			SET  var_msg = "-1,pos_deptjie插入失败，数据重建不成功!" ; 
			LEAVE label; 
		    END IF;
	END IF;
	
	-- 插入当前表pos_deptdai
	INSERT INTO `pos_deptdai` (`hotel_group_id`, `hotel_id`, `biz_date`, `ta_code`, `cashier`, `user_code`, `CODE`, `descript`, `descript_en`, `day_mark`, `amount_day`, `amount_month`, `amount_year`, `create_user`, `create_datetime`, `modify_user`, `modify_datetime`) 
	SELECT a.hotel_group_id,a.hotel_id,a.biz_date,a.code,a.cashier,a.puser,a.code,a.descript,a.descript,'',a.fee,0,0,a.create_user, a.create_datetime, a.modify_user, a.modify_datetime
	FROM pos_dish a,code_transaction b WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id AND a.code=b.code AND a.biz_date = arg_biz_date AND  a.hotel_id=arg_hotel_id AND a.hotel_group_id=arg_hotel_group_id AND b.arrange_code>'9';
	    IF t_error = 1 THEN
		SET  var_ret = -1;
		SET  var_msg = "-1,pos_deptdai插入失败，数据重建不成功!" ; 
		LEAVE label; 
	    END IF;	
	
	-- 清空历史表
	IF EXISTS(SELECT 1 FROM pos_deptjie_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_biz_date) THEN
		DELETE FROM pos_deptjie_history WHERE hotel_id=arg_hotel_id AND hotel_group_id=arg_hotel_group_id AND biz_date = arg_biz_date;
	END IF;

	IF EXISTS(SELECT 1 FROM pos_deptdai_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND biz_date = arg_biz_date) THEN
		DELETE FROM pos_deptdai_history WHERE hotel_id=arg_hotel_id AND hotel_group_id=arg_hotel_group_id AND biz_date = arg_biz_date;
	END IF;
	-- 将当前表插入历史表
	INSERT INTO `pos_deptjie_history` (`hotel_group_id`, `hotel_id`, `biz_date`, `id`, `ta_code`, `cashier`, `user_code`, `code`, `descript`, `descript_en`, `day_mark`, `amount_day`, `amount_month`, `amount_year`, `create_user`, `create_datetime`, `modify_user`, `modify_datetime`) 
		SELECT `hotel_group_id`, `hotel_id`, `biz_date`, `id`, `ta_code`, `cashier`, `user_code`, `code`, `descript`, `descript_en`, `day_mark`, `amount_day`, `amount_month`, `amount_year`, `create_user`, `create_datetime`, `modify_user`, `modify_datetime` FROM pos_deptjie  WHERE  hotel_id=arg_hotel_id AND hotel_group_id=arg_hotel_group_id AND biz_date = arg_biz_date;
	INSERT INTO `pos_deptdai_history` (`hotel_group_id`, `hotel_id`, `biz_date`, `id`, `ta_code`, `cashier`, `user_code`, `code`, `descript`, `descript_en`,`dai_tail`, `day_mark`, `amount_day`, `amount_month`, `amount_year`, `create_user`, `create_datetime`, `modify_user`, `modify_datetime`) 
		SELECT `hotel_group_id`, `hotel_id`, `biz_date`, `id`, `ta_code`, `cashier`, `user_code`, `code`, `descript`, `descript_en`, `dai_tail`, `day_mark`, `amount_day`, `amount_month`, `amount_year`, `create_user`, `create_datetime`, `modify_user`, `modify_datetime` FROM pos_deptdai WHERE  hotel_id=arg_hotel_id AND hotel_group_id=arg_hotel_group_id AND biz_date = arg_biz_date;

	-- 如果重建日期不是上一个营业日期，则删除当前表
	IF arg_biz_date < var_bizdate THEN
		DELETE FROM pos_deptjie WHERE hotel_id=arg_hotel_id AND hotel_group_id=arg_hotel_group_id AND biz_date = arg_biz_date;
		DELETE FROM pos_deptdai WHERE hotel_id=arg_hotel_id AND hotel_group_id=arg_hotel_group_id AND biz_date = arg_biz_date;
	END IF;
 
	END label; 
	   IF t_error = 1 OR t_error = 2 THEN  
		ROLLBACK;   

	   ELSE  
		COMMIT;       
	   END IF;
	   
	   SELECT var_ret, var_msg ;
END$$

DELIMITER ;

-- CALL up_ihotel_reb_pos_dept(1,4,'2016-3-13');

DROP PROCEDURE IF EXISTS `up_ihotel_reb_pos_dept`;