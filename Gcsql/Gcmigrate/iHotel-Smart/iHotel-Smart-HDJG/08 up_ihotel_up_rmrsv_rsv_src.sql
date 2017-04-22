DELIMITER $$
 
DROP PROCEDURE IF EXISTS `up_ihotel_up_rmrsv_rsv_src`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_up_rmrsv_rsv_src`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT
)
    SQL SECURITY INVOKER
label_0:
BEGIN

	DELETE FROM up_status WHERE hotel_id=arg_hotel_id AND up_step='RSVSRC';
	INSERT INTO up_status(hotel_id,up_step,time_begin,time_end,time_long,remark) VALUES(arg_hotel_id,'RSVSRC',NOW(),NULL,0,''); 
	
	DELETE FROM rsv_src WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	INSERT INTO rsv_src(hotel_group_id,hotel_id,occ_flag,accnt,list_order,rmtype,rmno,block_id,block_mark,arr_date,dep_date,rmnum,
		rsv_arr_date,rsv_dep_date,adult,children,rack_rate,nego_rate,real_rate,dsc_reason,remark,rsv_occ_id,master_id,
		ratecode,src,market,packages,specials,amenities,up_rmtype,up_reason,up_user,is_sure_rate,create_user,create_datetime,modify_user,modify_datetime)
	SELECT a.hotel_group_id,a.hotel_id,IF(b.roomno<>'','MF',(IF((LEFT(b.accnt,1)='G' OR LEFT(b.accnt,1)='M'),'RG','RF'))),a.accnt_new,0,b.type,b.roomno,0,IF(b.blkmark<>'T','F','T'),b.begin_,b.end_,b.quantity,
		b.begin_,b.end_,b.gstno,0,b.rmrate,b.rmrate,b.rate,b.rtreason,b.remark,NULL,0,
		b.ratecode,b.src,b.market,b.packages,b.srqs,b.amenities,'','','',b.rateok,b.cby,b.changed,b.cby,b.changed
		FROM up_map_accnt a,migrate_db.rsvsrc b WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id 
		AND a.accnt_type IN ('master_r','master_si') AND a.accnt_old=b.accnt
		AND b.accnt NOT IN (SELECT accnt FROM migrate_db.master WHERE sta = 'R' AND groupno <> '' AND roomno = '');
			
	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='RSVSRC';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='RSVSRC';
	
END$$

DELIMITER ;