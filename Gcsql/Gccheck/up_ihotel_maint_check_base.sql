DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_maint_check_base`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_maint_check_base`(
	IN arg_hotel_group_id	INT,	-- 集团id
	IN arg_hotel_id			INT		-- 酒店id
)
    SQL SECURITY INVOKER
label_0:
BEGIN

	DECLARE var_client_version	VARCHAR(20);
	DECLARE var_hotel_version   VARCHAR(20);
	DECLARE var_group_name      VARCHAR(60);
	DECLARE var_hotel_name      VARCHAR(60);
	DECLARE var_group_code      VARCHAR(20);
	DECLARE var_hotel_code      VARCHAR(20);
	DECLARE var_online_date     DATE;
	-- ======================================================
	-- 系统参数、代码及基本配置检查
	-- 2017.3.28
	-- ======================================================
	SELECT descript,code INTO var_group_name,var_group_code FROM hotel_group WHERE id = arg_hotel_group_id;
	SELECT client_version,descript,code INTO var_client_version,var_hotel_name,var_hotel_code FROM hotel WHERE hotel_group_id = arg_hotel_group_id AND id = arg_hotel_id;
	SELECT MIN(biz_date) INTO var_online_date FROM rep_dai_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;

    IF var_client_version = 'IHOTEL' THEN
        SET var_hotel_version = '标准版';
    ELSEIF var_client_version = 'THEF' THEN
        SET var_hotel_version = '商务版';
    ELSEIF var_client_version = 'THEK' THEN
        SET var_hotel_version = '快捷版';
    ELSE
        SET var_hotel_version = '未知';
    END IF;


	-- 参数检查结果集
  	DROP TEMPORARY TABLE IF EXISTS tmp_check_base;
	CREATE TEMPORARY TABLE tmp_check_base(
		id				INT NOT NULL AUTO_INCREMENT,
		flag			VARCHAR(10), -- 0 ok -1 error 1 warning
		check_msg		VARCHAR(1000),
		PRIMARY KEY(id)
	);

	INSERT INTO tmp_check_base SELECT NULL,'0',CONCAT('检查日期：',DATE(NOW()),' 酒店 : ',var_hotel_code,' & ',var_hotel_name,' 集团 : ',var_group_code,' & ',var_group_name,' 上线时间：',var_online_date,' 版本：',var_hotel_version);
	INSERT INTO tmp_check_base SELECT NULL,'0',GROUP_CONCAT('\n---------------------------------------------------------------------');
	INSERT INTO tmp_check_base SELECT NULL,'B',CONCAT('hotel-省份代码 ',CONCAT(a.province_code,' [',b.descript,']'),'  城市代码 ',CONCAT(a.city_code,'[',c.descript,']'),'  区域代码  ',a.district_code,'  检查是否正确') FROM hotel a LEFT JOIN code_province b ON a.province_code=b.code AND b.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id
		LEFT JOIN code_city c ON a.city_code=c.code AND c.hotel_id = arg_hotel_id AND c.hotel_group_id = arg_hotel_group_id
		WHERE a.hotel_group_id = arg_hotel_group_id AND a.id=arg_hotel_id;

	-- INSERT INTO tmp_check_base SELECT NULL,'B',CONCAT('sys_option: ',' 请检查房费费用代码合集是否完整',a.set_value) FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='audit' AND a.item='ta_code_for_room_night_count';

	IF NOT EXISTS(SELECT 1 FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code='market_code' AND flag='HSE') THEN
		INSERT INTO tmp_check_base SELECT NULL,'B','没有定义自用房市场码';
	END IF;
	IF NOT EXISTS(SELECT 1 FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code='market_code' AND flag='COM') THEN
		INSERT INTO tmp_check_base SELECT NULL,'B','没有定义免费房市场码';
	END IF;
	IF NOT EXISTS(SELECT 1 FROM code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code='market_code' AND flag='LON') THEN
		INSERT INTO tmp_check_base SELECT NULL,'B','没有定义长包房市场码';
	END IF;

	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('code_transaction:','  无效的arrange_code =  ',CONCAT(arrange_code,descript)) FROM code_transaction a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.is_halt = 'F' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE  b.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.parent_code='arrangement_bill' AND a.arrange_code=b.code);
	-- INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('code_transaction:','  Rebate & reason 不匹配  ',CONCAT(CODE,' ',descript,'',is_rebate,' ',is_need_reason)) FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND is_rebate='T' AND is_need_reason<>'T' AND is_halt = 'F';
	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('检查 code_transaction : arrange_code 字段存在空值或空字符串,请注意修改') FROM code_transaction WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (arrange_code='' OR arrange_code IS NULL) AND is_halt = 'F';

	-- 费用&付款部分
	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('code_transaction:','  非法的营业部门 = ',CONCAT(a.code,'  ',a.descript,a.cat_dept)) FROM code_transaction a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arrange_code<'9' AND a.is_halt = 'F' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE  b.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.parent_code='accnt_dept' AND a.cat_dept=b.code);
	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('code_transaction:','  非法的记账类别 = ',CONCAT(a.code,'  ',a.descript,a.cat_posting)) FROM code_transaction a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arrange_code<'9' AND a.is_halt = 'F' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE  b.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.parent_code='posting_category' AND a.cat_posting=b.code);
	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('code_transaction:','  非法的发票分类 = ',CONCAT(a.code,'  ',a.descript,a.cat_inv)) FROM code_transaction a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arrange_code<'9' AND a.is_halt = 'F' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE  b.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.parent_code='invoice_category' AND a.cat_inv=b.code);
	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('code_transaction:','  非法的余额统计 = ',CONCAT(a.code,'  ',a.descript,a.cat_bal)) FROM code_transaction a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arrange_code<'9' AND a.is_halt = 'F' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE  b.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.parent_code='balance_category' AND a.cat_bal=b.code);
	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('code_transaction:','  非法的业绩统计 = ',CONCAT(a.code,'  ',a.descript,a.cat_sum)) FROM code_transaction a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arrange_code<'9' AND a.is_halt = 'F' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE  b.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.parent_code='production_category' AND a.cat_sum=b.code);
	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('code_transaction:','  非法的内部码 = ',CONCAT(a.code,'  ',a.descript,a.cat_sum)) FROM code_transaction a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arrange_code<'9' AND a.is_halt = 'F' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE  b.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.parent_code='production_category' AND a.cat_sum=b.code);
	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('code_transaction:','  非法的付款类别 = ',CONCAT(a.code,'  ',a.descript,' ',a.category_code)) FROM code_transaction a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arrange_code>'9' AND a.is_halt = 'F' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE  b.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.parent_code='payment_category' AND a.category_code=b.code);
	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('code_transaction:','  折扣类付款 reason error = ',CONCAT(a.code,'  ',a.descript,' ',a.category_code)) FROM code_transaction a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arrange_code>'9' AND a.cat_posting='ENT' AND a.is_need_reason<>'T' AND a.is_halt = 'F';
	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('code_transaction:','  非法的内部码 = ',CONCAT(a.code,'  ',a.descript,' ',a.cat_posting)) FROM code_transaction a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arrange_code>'9' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE  b.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.parent_code='payment_flag' AND a.cat_posting=b.code);
	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('code_transaction:','  不能做为定金 = ',CONCAT(a.code,'  ',a.descript,' ',a.cat_posting)) FROM code_transaction a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.arrange_code>'9' AND (a.cat_posting='TA' OR a.cat_posting='TF') AND a.cat_bal<>'T' AND a.is_halt = 'F';

	-- 预订接待部分
	IF EXISTS(SELECT 1 FROM room_no WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND INSTR(CODE,'-')>0) THEN
		INSERT INTO tmp_check_base SELECT NULL,'A','房号中间不能有【-】,请检查';
	END IF;
	IF EXISTS(SELECT 1 FROM room_no a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND NOT EXISTS(SELECT 1 FROM room_type b WHERE b.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.code=a.rmtype)) THEN
		INSERT INTO tmp_check_base SELECT NULL,'A','房号有不存在的房型';
	END IF;
	IF EXISTS(SELECT 1 FROM room_no a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND NOT EXISTS(SELECT 1 FROM room_floor b WHERE b.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.code=a.floor)) THEN
		INSERT INTO tmp_check_base SELECT NULL,'A','房号有不存在的楼层';
	END IF;
	IF EXISTS(SELECT 1 FROM room_no a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.parent_code='building' AND b.code=a.building)) THEN
		INSERT INTO tmp_check_base SELECT NULL,'A','房号有不存在的楼栋';
	END IF;

	-- 收银部分
	-- package
	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('code_package:','  不存在的费用码= ',CONCAT(a.code,' ',a.descript,' ',a.ta_code)) FROM code_package a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.ta_code<>''
		AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE  b.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.code=a.ta_code);
	INSERT INTO tmp_check_base SELECT NULL,'B',CONCAT('code_package:','  不存在的消费账户= ',CONCAT(a.code,' ',a.descript,' 账户 ',a.accnt)) FROM code_package a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND (a.accnt<>'' OR a.accnt IS NOT NULL)
		AND NOT EXISTS(SELECT 1 FROM master_base b WHERE  b.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.id=a.accnt);
	-- ar_category
	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('ar_master:','不存在的AR账户类别=',CONCAT(a.id,' ',c.name,' ',IFNULL(a.ar_category,''))) FROM ar_master a,ar_master_guest c WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id=c.id AND c.hotel_id = arg_hotel_id AND c.hotel_group_id = arg_hotel_group_id
		AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code='ar_category' AND b.code=a.ar_category);

	-- 销售部分
	-- INSERT INTO tmp_check_base SELECT NULL,'B',CONCAT('sales_man:','  不存在的销售组别= ',CONCAT(a.sales_man,' ',c.name)) FROM sales_man_business a,sales_man c WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.sales_man=c.code AND c.hotel_group_id = arg_hotel_group_id AND c.hotel_id=0
	-- 	AND (a.sales_group IS NULL OR NOT EXISTS(SELECT 1 FROM sales_group b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.sales_group=b.code));
 	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('code_ratecode:',' 房价码定义:包含无效的市场码 ',a.code,' 市场码 ',a.market) FROM code_ratecode a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
		AND ((a.market IS NOT NULL AND a.market <>'') AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code='market_code' AND a.market=b.code));
 	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('code_ratecode:',' 房价码定义:包含无效的来源码 ',a.code,' 来源码 ',a.market) FROM code_ratecode a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
		AND ((a.src IS NOT NULL AND a.src<>'') AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code='src_code' AND a.src=b.code));

	-- 底表部分
	IF NOT EXISTS (SELECT 1 FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno='999') THEN
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('检查 rep_jie : 借方合计classno不为 999 或者不存在借方合计,请注意修改');
	END IF;
	IF EXISTS (SELECT 1 FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND descript LIKE '%款待%') THEN
        IF NOT EXISTS (SELECT 1 FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND classno='998' AND descript LIKE '%款待%') THEN
		    INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('检查 rep_jie : 借方款待classno不为 998,请注意修改');
	    END IF;
	END IF;
	IF EXISTS (SELECT 1 FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (orderno='' OR orderno IS NULL)) THEN
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('检查 rep_jie : 存在orderno字段为空的情况');
	END IF;
	IF EXISTS (SELECT 1 FROM rep_jie WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND (modeno='' OR modeno IS NULL)) THEN
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('检查 rep_jie : 存在modeno字段为空的情况');
	END IF;

	-- 默认值
	IF var_client_version = 'IHOTEL' THEN
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('master:',' 主单默认市场码 ',a.value_default,' 不存在') FROM sys_constraint a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
			AND a.parent_code IN ('SubFitMaster.master_fit','EditResrv.resrvBase_fit','EditResrv.resrvBase_group')
			AND a.code='market' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code='market_code' AND a.value_default=b.code);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('master:',' 主单默认来源码 ',a.value_default,' 不存在') FROM sys_constraint a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
			AND a.parent_code IN ('SubFitMaster.master_fit','EditResrv.resrvBase_fit','EditResrv.resrvBase_group')
			AND a.code='src' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code='src_code' AND a.value_default=b.code);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('master:',' 主单默认房价码 ',a.value_default,' 不存在') FROM sys_constraint a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
			AND a.parent_code IN ('SubFitMaster.master_fit','EditResrv.resrvBase_fit','EditResrv.resrvBase_group')
			AND a.code='rateCode' AND NOT EXISTS(SELECT 1 FROM code_ratecode b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.value_default=b.code);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('master:',' 主单默认渠道码 ',a.value_default,' 不存在') FROM sys_constraint a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
			AND a.parent_code IN ('SubFitMaster.master_fit','EditResrv.resrvBase_fit','EditResrv.resrvBase_group')
			AND a.code='channel' AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code='channel' AND a.value_default=b.code);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('master:',' 主单默认预订类型 ',a.value_default,' 不存在') FROM sys_constraint a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
			AND a.parent_code IN ('SubFitMaster.master_fit','EditResrv.resrvBase_fit','EditResrv.resrvBase_group')
			AND a.code='rsvType' AND NOT EXISTS(SELECT 1 FROM code_rsv_type b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.value_default=b.code);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('master:',' 主单默认付款方式 ',a.value_default,' 不存在') FROM sys_constraint a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
			AND a.parent_code IN ('SubFitMaster.master_fit','EditResrv.resrvBase_fit','EditResrv.resrvBase_group')
			AND a.code='payCode' AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.value_default=b.code);

		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='report' AND a.item='real_room_sta_report_code'
			AND NOT EXISTS(SELECT 1 FROM report_center b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code=a.set_value);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='report' AND a.item='room_sta_report_code'
			AND NOT EXISTS(SELECT 1 FROM report_center b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code=a.set_value);

	ELSEIF (var_client_version='THEF' OR var_client_version='THEK') THEN
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='account' AND a.item='accredit_default_code'
			AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.arrange_code>'9' AND b.code=a.set_value);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: 现付帐 ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='account' AND a.item='business_accnt'
			AND NOT EXISTS(SELECT 1 FROM master_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.rsv_class='H' AND b.id=a.set_value);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='account' AND a.item='check_default_in_code'
			AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.arrange_code>'9' AND b.code=a.set_value);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='account' AND a.item='check_default_out_code'
			AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.arrange_code>'9' AND b.code=a.set_value);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='account' AND a.item='cash_default_code'
			AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.arrange_code>'9' AND b.code=a.set_value);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='walkin' AND a.item='default_rmtype'
			AND NOT EXISTS(SELECT 1 FROM room_type b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.is_halt='F' AND b.quantity<>0 AND b.code=a.set_value);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='walkin' AND a.item='default_market'
			AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code='market_code' AND b.code=a.set_value);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='walkin' AND a.item='default_src'
			AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code='src_code' AND b.code=a.set_value);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='walkin' AND a.item='default_channel'
			AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code='channel' AND b.code=a.set_value);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='walkin' AND a.item='default_hourmarket'
			AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code='market_code' AND b.code=a.set_value);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='walkin' AND a.item IN ('default_code_rate','default_dayuse_ratecode','default_free_rate')
			AND NOT EXISTS(SELECT 1 FROM code_ratecode b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code=a.set_value AND b.is_halt='F');
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='walkin' AND a.item = 'default_ratecode_c'
			AND NOT EXISTS(SELECT 1 FROM code_ratecode b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code=a.set_value AND b.is_halt='F');
		-- 预订业务 默认市场码
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='reserve' AND a.item = 'default_src'
			AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code='src_code' AND b.code=a.set_value);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='reserve' AND a.item = 'default_channel'
			AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code='channel' AND b.code=a.set_value);

		/*
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='reserve' AND a.item LIKE 'default_market%' AND a.item <> 'default_market_owner'
			AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code='market_code' AND b.code=a.set_value);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='reserve' AND a.item LIKE 'default_channel%' AND a.item <> 'default_channel_owner'
			AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code='channel' AND b.code=a.set_value);
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='reserve' AND a.item = 'default_src'
			AND NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code='src_code' AND b.code=a.set_value);
		*/
	END IF;
	-- 参数检查
 	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='audit' AND a.item='ta_code_for_room_night'
		AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.set_value=b.code);

	-- INSERT INTO tmp_check_base SELECT NULL,'B',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='account' AND a.item='business_accnt'
	-- 		AND NOT EXISTS(SELECT 1 FROM master_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.rsv_class='H' AND b.id=a.set_value);
	IF EXISTS (SELECT 1 FROM master_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND rsv_class='H' AND sta='I') THEN
		INSERT INTO tmp_check_base SELECT NULL,'B',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='account' AND a.item='roomAccnt_accnt'
				AND NOT EXISTS(SELECT 1 FROM master_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.rsv_class='H' AND b.id=a.set_value);
	END IF;

 	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='account' AND a.item='day_use_tacode'
		AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.set_value=b.code);
 	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='audit' AND (a.item='ta_code_for_day_half' OR a.item='ta_code_for_day_whole' OR a.item='ta_code_for_morning_half' OR a.item='ta_code_for_morning_whole')
		AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.set_value=b.code);
 	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='audit' AND a.item='ta_code_for_extra_bed'
		AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.set_value=b.code);
 	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='audit' AND a.item='rep_night_charge'
		AND NOT EXISTS(SELECT 1 FROM report_center b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.set_value=b.code);

 	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='account' AND a.item='round_ta_pccode'
		AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.set_value=b.code);
 	INSERT INTO tmp_check_base SELECT NULL,'B',CONCAT('sys_option: ',a.descript,' ',a.set_value,' 不存在') FROM sys_option a WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.catalog='account' AND a.item='balance_transfer_ta_code'
		AND NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.set_value=b.code);

    -- 自动夜审的时间
	IF EXISTS (SELECT 1 FROM sys_option WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog='system' AND item='auto_audit' AND set_value = 'T') THEN
		INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option : 自动夜审时间必须大于22点') FROM sys_option WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog='audit' AND item = 'audit_time_limit' AND set_value <= 22;
	END IF;

	INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT('sys_option : 夜审时间必须大于21点') FROM sys_option WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND catalog='audit' AND item = 'audit_time_limit' AND set_value < 21;


	-- 会计日期 检查
    INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT("month not between 1 and 12: ",a.biz_year,' ',a.biz_month)
		from biz_month a where a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id and not (a.biz_month >=1 and a.biz_month <= 12);

    INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT("end_date should be greater than or equal to begin_date: ",a.biz_year,' ',a.biz_month)
		from biz_month a where a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id and a.end_date < a.begin_date;

    INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT("date overlapped with: ",a.biz_year,' ',a.biz_month)
		from biz_month a where a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id and a.end_date < (select max(b.end_date) from biz_month b where b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id) and
           exists (select 1 from biz_month b where b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id and (b.begin_date >= a.begin_date and b.begin_date <= a.end_date) and b.id <> a.id );

    INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT("date gap occurred between end_date and next begin_date: ",a.biz_year,' ',a.biz_month)
		from biz_month a where a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id and a.end_date < (select max(b.end_date) from biz_month b where b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id) and
           (select date(min(b.begin_date)) from  biz_month b where b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id and b.begin_date > a.begin_date) > date_add(a.end_date,interval 1 day);

    -- 餐饮接口配置表检查
    INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT("code not in table code_transaction: ",a.code,' ',a.descript)
		FROM pos_deptdai a WHERE a.hotel_group_id = arg_hotel_group_id and a.hotel_id = arg_hotel_id AND
    		NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.code=b.code);
    INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT("code not in table code_transaction: ",a.code,' ',a.descript)
    	FROM pos_deptjie a WHERE a.hotel_group_id = arg_hotel_group_id and a.hotel_id = arg_hotel_id AND
    		NOT EXISTS(SELECT 1 FROM code_transaction b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.code=b.code);
    INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT("餐饮接口配置表营业点代码重复: ",pos_code,' ',descript)
	 	FROM pos_interface_map WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND link_type='ta_code' GROUP BY pos_code HAVING COUNT(1)>1;

    -- 云POS部分检查
    IF EXISTS (SELECT 1 FROM pos_pccode WHERE hotel_group_id = arg_hotel_group_id and hotel_id = arg_hotel_id) THEN     -- 判断是否启用云POS
        INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT("菜项 pos_plu_all: ",a.code,' ',a.descript,' 【报表数据项】缺失')
        FROM pos_plu_all a WHERE a.hotel_group_id = arg_hotel_group_id and a.hotel_id = arg_hotel_id AND (a.tocode = '' OR a.tocode IS NULL);
        INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT("菜项 pos_plu_all: ",a.code,' ',a.descript,' 【报表数据项】错误')
        FROM pos_plu_all a WHERE a.hotel_group_id = arg_hotel_group_id and a.hotel_id = arg_hotel_id AND
            NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code='pos_rep_item' AND a.tocode=b.code);

        INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT("菜类 pos_sort_all: ",a.code,' ',a.descript,' 【报表数据项】缺失')
        FROM pos_sort_all a WHERE a.hotel_group_id = arg_hotel_group_id and a.hotel_id = arg_hotel_id AND (a.tocode = '' OR a.tocode IS NULL);
        INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT("菜类 pos_sort_all: ",a.code,' ',a.descript,' 【报表数据项】错误')
        FROM pos_sort_all a WHERE a.hotel_group_id = arg_hotel_group_id and a.hotel_id = arg_hotel_id AND
            NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code='pos_rep_item' AND a.tocode=b.code);

        INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT("菜项 pos_detail: ",a.code,' ',a.descript,' 【报表数据项】缺失')
        FROM pos_detail a WHERE a.hotel_group_id = arg_hotel_group_id and a.hotel_id = arg_hotel_id AND (a.tocode = '' OR a.tocode IS NULL);
        INSERT INTO tmp_check_base SELECT NULL,'A',CONCAT("菜项 pos_detail: ",a.code,' ',a.descript,' 【报表数据项】错误')
        FROM pos_detail a WHERE a.hotel_group_id = arg_hotel_group_id and a.hotel_id = arg_hotel_id AND
            NOT EXISTS(SELECT 1 FROM code_base b WHERE b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.parent_code='pos_rep_item' AND a.tocode=b.code);
    END IF;

	INSERT INTO tmp_check_base SELECT NULL,'0',GROUP_CONCAT('\n---------------------------------------------------------------------');
	INSERT INTO tmp_check_base SELECT NULL,'0','检查结束...';

	SELECT flag,check_msg FROM tmp_check_base ORDER BY id;


 	DROP TEMPORARY TABLE IF EXISTS tmp_check_base;

END$$

DELIMITER ;

-- CALL up_ihotel_maint_check_base(2,9);

-- DROP PROCEDURE IF EXISTS `up_ihotel_maint_check_base`;