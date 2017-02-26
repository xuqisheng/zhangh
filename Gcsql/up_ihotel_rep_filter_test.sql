DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_filter_test`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_filter_test`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN arg_filter_codes		VARCHAR(1024)
)
    SQL SECURITY INVOKER
label_0:
BEGIN

	-- 解析实现范例
	SELECT a.id,b.name,a.rmtype,a.rmno,a.ratecode,a.market,a.real_rate
		FROM master_base a,master_guest b WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id
			AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.id = b.id
			AND IF(uf_filter_analyse(arg_filter_codes,'sta')='ALL',1=1,INSTR(CONCAT(',',uf_filter_analyse(arg_filter_codes,'sta'),','),CONCAT(',',a.sta,','))>0)
			AND IF(uf_filter_analyse(arg_filter_codes,'rmtype')='ALL',1=1,INSTR(CONCAT(',',uf_filter_analyse(arg_filter_codes,'rmtype'),','),CONCAT(',',a.rmtype,','))>0);

END$$

DELIMITER ;