DELIMITER $$
 
DROP PROCEDURE IF EXISTS `up_ihotel_up_rmrsv_rsv_src_yh`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_up_rmrsv_rsv_src_yh`(
	IN arg_hotel_group_id	BIGINT(16),
	IN arg_hotel_id			BIGINT(16)
)
    SQL SECURITY INVOKER
label_0:
BEGIN

	DELETE FROM up_status WHERE hotel_id=arg_hotel_id AND up_step='RSVSRC';
	INSERT INTO up_status(hotel_id,up_step,time_begin,time_end,time_long,remark) VALUES(arg_hotel_id,'RSVSRC',NOW(),NULL,0,''); 
	
	DELETE FROM rsv_src WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	INSERT INTO rsv_src (hotel_group_id,hotel_id,occ_flag,accnt,list_order,rmtype,rmno,block_id,block_mark,arr_date,dep_date,rmnum,
		rsv_arr_date,rsv_dep_date,adult,children,rack_rate,nego_rate,real_rate,dsc_reason,remark,rsv_occ_id,master_id,
		ratecode,src,market,packages,specials,amenities,up_rmtype,up_reason,up_user,is_sure_rate,create_user,create_datetime,modify_user,modify_datetime)
	SELECT a.hotel_group_id,a.hotel_id,IF(b.roomno<>'','MF',(IF((LEFT(b.accnt,1)='G' OR LEFT(b.accnt,1)='M'),'RG','RF'))),a.accnt_new,0,b.type,b.roomno,0,IF(b.blkmark<>'T','F','T'),b.begin_,b.end_,b.quantity,
		b.begin_,b.end_,b.gstno,0,b.rmrate,b.rmrate,b.rate,b.rtreason,b.remark,NULL,0,
		b.ratecode,b.src,b.market,b.packages,b.srqs,b.amenities,'','','',b.rateok,b.cby,b.changed,b.cby,b.changed
		FROM up_map_accnt a,migrate_xmyh.rsvsrc b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id 
		AND a.accnt_type IN ('master_r','master_si') AND a.accnt_old=b.accnt;
	
	UPDATE rsv_src a,master_base b SET a.master_id=b.master_id WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.accnt=b.id;

	-- 市场来源
 	UPDATE rsv_src a,up_map_code b SET a.market = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.code = 'mktcode' AND b.code_old = a.market; 
 	UPDATE rsv_src a,up_map_code b SET a.src = b.code_new WHERE a.hotel_group_id=b.hotel_group_id AND a.hotel_id = b.hotel_id AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.code = 'srccode' AND b.code_old = a.src; 
 	-- 房价码
--   	UPDATE rsv_src a,up_map_code b SET a.ratecode = b.code_new WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.hotel_group_id=b.hotel_group_id AND a.hotel_id = b.hotel_id  AND b.code = 'ratecode' AND b.code_old = a.ratecode; 
 	-- 优惠理由
 	UPDATE rsv_src a,up_map_code b SET a.dsc_reason = b.code_new WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND b.code = 'code_reason' AND b.code_old = a.dsc_reason ;
	
-- 	UPDATE rsv_src SET amenities = REPLACE(amenities,'PT','PAT') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND amenities <> '';
-- 	UPDATE rsv_src SET specials = REPLACE(specials,'F2','FL2') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND amenities <> '';
    	

		
	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='RSVSRC';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='RSVSRC';
	
END$$

DELIMITER ;