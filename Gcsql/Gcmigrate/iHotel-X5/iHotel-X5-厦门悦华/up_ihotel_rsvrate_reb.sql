DELIMITER $$
DROP PROCEDURE IF EXISTS `up_ihotel_rsvrate_reb`$$
CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rsvrate_reb`(
	IN arg_hotel_group_id		INT,
	IN arg_hotel_id			INT,
	OUT arg_msg			VARCHAR(255) -- 返回信息
)
SQL SECURITY INVOKER # added by mode utility
label_0:
BEGIN
	-- ---------------------
	-- 客房资源每日房价重建 
	-- 可以单独使用
	-- 注意：此过程暂不支持每日房价变价功能
	-- 陈武  2014.11.09
	-- ---------------------
	DECLARE var_count INTEGER;

	DECLARE var_occFlag VARCHAR(10);
	DECLARE var_rsvSrcId BIGINT(16);
	DECLARE var_accnt BIGINT(16);
	DECLARE var_occId BIGINT(16);

	DECLARE var_rmtype VARCHAR(10);
	DECLARE var_rmno VARCHAR(10);
	DECLARE var_rmnum INTEGER;

	DECLARE var_arrDate DATETIME;
	DECLARE var_depDate DATETIME;
	DECLARE var_ratecode VARCHAR(10);
	DECLARE var_negoRate DECIMAL(8,2);
	DECLARE var_realRate DECIMAL(8,2);

	DECLARE var_adult MEDIUMINT(9);
	DECLARE var_dscReason VARCHAR(10);
	DECLARE var_remark VARCHAR(512);

	DECLARE var_market VARCHAR(10);
	DECLARE var_src VARCHAR(10);
	DECLARE var_packages VARCHAR(60);

	DECLARE var_createUser VARCHAR(10);
	DECLARE var_createDatetime DATETIME;
	DECLARE var_modifyUser VARCHAR(10);
	DECLARE var_modifyDatetime DATETIME;

	DECLARE done_cursor INT DEFAULT 0 ;

	-- 资源占用记录游标
	DECLARE c_rsvsrc CURSOR FOR 
		SELECT occ_flag, id, accnt,rsv_occ_id, rmtype, rmno, rmnum, arr_date, dep_date,
			ratecode,nego_rate,real_rate,adult,dsc_reason,remark,market,src,packages,
			create_user,create_datetime,modify_user,modify_datetime
		FROM rsv_src WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id 
			AND occ_flag IN ('MF','RF','RG'); 

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1 ;
	
	-- ---------------------
	-- 校验 hotel_id  
	-- ---------------------
	SELECT COUNT(1) INTO var_count FROM hotel WHERE hotel_group_id=arg_hotel_group_id AND id = arg_hotel_id; 
	IF var_count = 0 THEN 
		BEGIN
		SET arg_msg =  'Group Hotel id or Hotel id Error !';
		LEAVE label_0;
		END; 
	END IF; 
	
	OPEN c_rsvsrc ;
	SET done_cursor = 0 ;
	FETCH c_rsvsrc INTO var_occFlag,var_rsvSrcId, var_accnt, var_occId, var_rmtype, 
		var_rmno, var_rmnum, var_arrDate, var_depDate, var_ratecode,var_negoRate,
		var_realRate,var_adult,var_dscReason,var_remark,var_market,var_src,var_packages,
		var_createUser,var_createDatetime,var_modifyUser,var_modifyDatetime; 

	WHILE done_cursor = 0 DO
		-- 执行缺失每日房价插入过程
		INSERT INTO `rsv_rate` (`hotel_group_id`, `hotel_id`, `rsv_src_id`, `rmtype`, 
			`rmno`, `rsv_date`, `rmnum`, `adult`, `nego_rate`, `nego_share_rate`, 
			`real_rate`, `real_share_rate`, `dsc_reason`, `rm_fee_ttl`, 
			`rm_fee_net`, `rm_fee_srv`, `rm_fee_tax`, `rm_fee_bf`, `rm_fee_pack`, 
			`rm_fee_other`, `remark`, `master_id`, `occ_id`, `ratecode`, 
			`market`, `src`, `rsv_type`, `channel`, `packages`, 
			`create_user`, `create_datetime`, `modify_user`, `modify_datetime`)
		(SELECT arg_hotel_group_id,arg_hotel_id,var_rsvSrcId,var_rmtype,
			var_rmno,a.date,var_rmnum,var_adult,var_negoRate,var_negoRate,
			var_realRate,var_realRate,var_dscReason,var_realRate,
			0,0,0,0,0,0,var_remark,var_accnt,var_occId,var_ratecode,
			var_market,var_src,b.rsv_type,b.channel,var_packages,
			var_createUser,var_createDatetime,var_modifyUser,var_modifyDatetime
		FROM calendar AS a,master_base AS b
		WHERE b.id = var_accnt AND a.date >= var_arrDate AND a.date <= var_depDate
			AND NOT EXISTS (SELECT 1 FROM rsv_rate WHERE hotel_group_id = arg_hotel_group_id
				AND hotel_id = arg_hotel_id AND rsv_src_id = var_rsvSrcId
				AND rsv_date = a.date AND master_id = var_accnt));
		
		SET done_cursor = 0 ;
		FETCH c_rsvsrc INTO var_occFlag,var_rsvSrcId, var_accnt, var_occId, var_rmtype, 
			var_rmno, var_rmnum, var_arrDate, var_depDate, var_ratecode,var_negoRate,
			var_realRate,var_adult,var_dscReason,var_remark,var_market,var_src,var_packages,
			var_createUser,var_createDatetime,var_modifyUser,var_modifyDatetime; 
	END WHILE ;
	CLOSE c_rsvsrc ;
	
	SET arg_msg = 'RsvRate Rebuild Success !';
	
	SELECT arg_msg;

	BEGIN		
		LEAVE label_0;
	END; 	
END$$
DELIMITER ;