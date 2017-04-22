DELIMITER $$

DROP PROCEDURE IF EXISTS `ihotel_up_grpmst_si_v5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_grpmst_si_v5`(
	IN arg_hotel_group_id BIGINT(16),
	IN arg_hotel_id BIGINT(16)
)
label_0:
BEGIN		
	DECLARE var_accnt 	VARCHAR(7);
	DECLARE var_sta 	VARCHAR(2);
	DECLARE var_ressta 	VARCHAR(2);
	DECLARE var_exp_sta VARCHAR(2);
	DECLARE var_sta_tm 	VARCHAR(2);
	DECLARE var_src 	VARCHAR(2);
	DECLARE var_class 	VARCHAR(2);
	DECLARE var_name 	VARCHAR(50);
	DECLARE var_nation 	VARCHAR(3);
	DECLARE var_cusno 	VARCHAR(7);
	DECLARE var_tranlog VARCHAR(10);
	DECLARE var_leader 	VARCHAR(16);
	DECLARE var_mate 	VARCHAR(16);
	DECLARE var_rescode VARCHAR(16);
	DECLARE var_children VARCHAR(16);
	DECLARE var_gstno 	INT(8);
	DECLARE var_rooms 	INT(8);
	DECLARE var_rate 	DECIMAL(12,2); 
	DECLARE var_orate 	DECIMAL(12,2);
	DECLARE var_ratemode VARCHAR(16);
	DECLARE var_mkt 	VARCHAR(16);
	DECLARE var_guide 	INT(8);
	DECLARE var_arr 	DATETIME;
	DECLARE var_dep 	DATETIME;
	DECLARE var_oarr 	DATETIME;
	DECLARE var_odep 	DATETIME;
	DECLARE var_resdep 	DATETIME;
	DECLARE var_applname VARCHAR(30);
	DECLARE var_applicant VARCHAR(30);
	DECLARE var_araccnt VARCHAR(16);
	DECLARE var_phoneetc VARCHAR(16);
	DECLARE var_paycode VARCHAR(16);
	DECLARE var_limit1 	DECIMAL(12,2);
	DECLARE var_credcode VARCHAR(30);
	DECLARE var_credman VARCHAR(30);
	DECLARE var_credunit VARCHAR(40);
	DECLARE var_empno  	VARCHAR(3);
	DECLARE var_tag0 	VARCHAR(3);
	DECLARE var_wherefrom VARCHAR(16);
	DECLARE var_whereto VARCHAR(16);
	DECLARE var_arrinfo VARCHAR(16);
	DECLARE var_depinfo VARCHAR(16);
	DECLARE var_approved VARCHAR(16);
	DECLARE var_approvedd DATETIME;
	DECLARE var_locksta  VARCHAR(3);
	DECLARE var_rmb_od 	DECIMAL(12,2);
	DECLARE var_rmb_td 	DECIMAL(12,2);
	DECLARE var_rmb_db 	DECIMAL(12,2);
	DECLARE var_escr_od DECIMAL(12,2);
	DECLARE var_escr_td DECIMAL(12,2);
	DECLARE var_escr_db DECIMAL(12,2);
	DECLARE var_depr_oc DECIMAL(12,2);
	DECLARE var_depr_tc DECIMAL(12,2);
	DECLARE var_depr_cr DECIMAL(12,2);
	DECLARE var_addrmb 	DECIMAL(12,2);
	DECLARE var_addtr 	DECIMAL(12,2);
	DECLARE var_addor 	DECIMAL(12,2);
	DECLARE var_lastnumb INT(8);
	DECLARE var_lastinumb INT(8);
	DECLARE var_srqs 	VARCHAR(30);
	DECLARE var_ref 	VARCHAR(1024);
	DECLARE var_content2 	VARCHAR(1024);
	DECLARE var_content3 	VARCHAR(1024);
	DECLARE var_content4 	VARCHAR(1024);	
	DECLARE var_resby 	VARCHAR(10);
	DECLARE var_resbyname 	VARCHAR(30);
	DECLARE var_reserved 	DATETIME;
	DECLARE var_resmode VARCHAR(30);
	DECLARE var_resno 	VARCHAR(30);
	DECLARE var_cby 	VARCHAR(30);
	DECLARE var_changed DATETIME;
	DECLARE var_exp_m 	DECIMAL(12,2);
	DECLARE var_exp_dt 	DATETIME;
	DECLARE var_exp_s  	VARCHAR(30);
	DECLARE var_logmark INT(8);
	DECLARE var_vip  	VARCHAR(3);	
	DECLARE var_id 		BIGINT(16);
	DECLARE var_balance DECIMAL(12,2); 
	DECLARE var_channel VARCHAR(10);
	DECLARE var_rsv_type VARCHAR(10);
	DECLARE var_biz_date DATETIME;
	DECLARE	var_company_id BIGINT(16);
	DECLARE var_company_class VARCHAR(2);
	DECLARE	var_cid 	BIGINT(16);
	DECLARE	var_aid 	BIGINT(16);
	DECLARE	var_sid 	BIGINT(16);
	DECLARE var_last_accnt VARCHAR(7) DEFAULT '';
	
	DECLARE done_cursor INT DEFAULT 0 ;
	DECLARE c_grpmst CURSOR FOR  
		SELECT a.accnt,a.sta,a.ressta,a.exp_sta,a.sta_tm,a.src,a.class,a.name,a.nation,a.cusno,a.tranlog,a.leader,a.mate,
		       a.rescode,a.children,a.gstno,a.rooms,a.rate,a.orate,a.ratemode,a.mkt,a.guide,a.arr,a.dep,a.oarr,a.odep,
		       a.resdep,a.applname,a.applicant,a.araccnt,a.phoneetc,a.paycode,a.limit1,a.credcode,a.credman,a.credunit,
		       a.empno,a.tag0,a.wherefrom,a.whereto,a.arrinfo,a.depinfo,a.approved,a.approvedd,a.locksta ,
		       a.rmb_od,a.rmb_td,a.rmb_db,a.escr_od,a.escr_td,a.escr_db,a.depr_oc,a.depr_tc,a.depr_cr,a.addrmb,
		       a.addtr,a.addor,a.lastnumb,a.lastinumb,a.srqs,IFNULL(c.content,''),IFNULL(d.content,''),IFNULL(e.content,''),IFNULL(f.content,''),a.resby,a.resbyname,a.reserved,a.resmode,a.resno,
		       a.resby,a.reserved,a.cby,a.changed,a.exp_m,a.exp_dt,a.exp_s,a.logmark,a.vip,a.rmb_db-a.depr_cr-a.addrmb
		FROM migrate_xc.grpmst a LEFT JOIN migrate_xc.message c ON a.accnt = c.accnt AND c.type = '61' 
		LEFT JOIN migrate_xc.message d ON a.accnt = c.accnt AND c.type = '64'
		LEFT JOIN migrate_xc.message e ON a.accnt = c.accnt AND c.type = '63'
		LEFT JOIN migrate_xc.message f ON a.accnt = c.accnt AND c.type = '73'		
		WHERE a.sta IN ('I','S','O','R') ORDER BY a.accnt;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	
	SELECT biz_date INTO var_biz_date FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id; 
	SELECT MIN(CODE) INTO var_rsv_type FROM code_rsv_type WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id  AND is_halt = 'F'; 
-- 	SELECT MIN(CODE) INTO var_channel FROM code_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND parent_code='channel' AND is_halt = 'F';  
	SELECT district_code INTO var_whereto FROM hotel WHERE hotel_group_id=arg_hotel_group_id AND id=arg_hotel_id; 
	DELETE FROM up_status WHERE hotel_id=arg_hotel_id AND up_step='grpmst';
	INSERT INTO up_status(hotel_id,up_step,time_begin,time_end,time_long,remark) VALUES(arg_hotel_id,'grpmst',NOW(),NULL,0,''); 
	DELETE FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type='grpmst';
	
	OPEN c_grpmst;
	SET done_cursor = 0;
	FETCH c_grpmst INTO 
	       var_accnt,var_sta,var_ressta,var_exp_sta,var_sta_tm,var_src,var_class,var_name,var_nation,var_cusno,var_tranlog,var_leader,var_mate,
	       var_rescode,var_children,var_gstno,var_rooms,var_rate,var_orate,var_ratemode,var_mkt,var_guide,var_arr,var_dep,var_oarr,var_odep,
	       var_resdep,var_applname,var_applicant,var_araccnt,var_phoneetc,var_paycode,var_limit1,var_credcode,var_credman,var_credunit,
	       var_empno ,var_tag0,var_wherefrom,var_whereto,var_arrinfo,var_depinfo,var_approved,var_approvedd,var_locksta ,
	       var_rmb_od,var_rmb_td,var_rmb_db,var_escr_od,var_escr_td,var_escr_db,var_depr_oc,var_depr_tc,var_depr_cr,var_addrmb,
	       var_addtr,var_addor,var_lastnumb,var_lastinumb,var_srqs,var_ref,var_content2,var_content3,var_content4,var_resby,var_resbyname,var_reserved,var_resmode,var_resno,
	       var_resby,var_reserved,var_cby,var_changed,var_exp_m,var_exp_dt,var_exp_s ,var_logmark,var_vip,var_balance;
	       
	WHILE done_cursor = 0 DO
	
	       SET var_company_id=0,var_cid=0,var_aid=0,var_sid=0;
			IF var_class='M' THEN 
				SET var_class='G'; 
			END IF; 
			SET var_channel = 'WAK';
			SET var_src = 'WAK';			
	       IF var_cusno <> '' THEN 
			SELECT accnt_new INTO var_company_id FROM up_map_accnt WHERE hotel_group_id = arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type='COMPANY' AND accnt_old=var_cusno; 
			IF var_company_id>0 THEN 
				SET var_company_class = ''; 
				SELECT b.sys_cat INTO var_company_class FROM company_base a,company_type b 
					WHERE a.id=b.company_id AND a.id=var_company_id  AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id; 
				IF 	var_company_class = 'C' THEN 
					SET var_cid=var_company_id; 
				ELSEIF var_company_class = 'A' THEN 
					SET var_aid=var_company_id; 
				ELSEIF var_company_class = 'S' THEN 
					SET var_sid=var_company_id; 
				END IF; 
			END IF;
	       END IF ; 
		
	    IF var_accnt = var_last_accnt THEN 		
			INSERT INTO master_base (hotel_group_id,hotel_id,rsv_id,is_resrv,rsv_man,rsv_company,rsv_src_id,rsv_class,master_id,grp_accnt,block_id,biz_date,
				sta,rmtype,rmno,rmnum,arr,dep,adult,children,res_sta,res_dep,rack_rate,nego_rate,real_rate,dsc_reason,dsc_amount,dsc_percent,
				exp_sta,tm_sta,rmpost_sta,is_rmposted,tag0,company_id,agent_id,source_id,member_type,member_no,salesman,arno,building,
				src,market,rsv_type,channel,ratecode,cmscode,packages,specials,amenities,
				is_fix_rate,is_fix_rmno,is_sure,is_permanent,is_walkin,is_secret,is_secret_rate,posting_flag,
				sc_flag,extra_flag,extra_bed_num,extra_bed_rate,crib_num,crib_rate,pay_code,limit_amt,credit_no,credit_man,credit_company,
				charge,pay,credit,last_num,last_num_link,rmocc_id,link_id,pkg_link_id,rsv_no,crs_no,
				where_from,where_to,purpose,remark,co_msg,create_user,create_datetime,modify_user,modify_datetime)
			VALUES(arg_hotel_group_id,arg_hotel_id,0,'F',var_applname,var_applicant,0,'G',0,0,0,var_biz_date,
				var_sta,'','',var_rooms,var_arr,var_dep,var_gstno,var_children,var_ressta,var_resdep,0,0,0,'',0,0,
				var_exp_sta,var_sta_tm,'F','F','',var_cid,var_aid,var_sid,'','',var_credman,var_araccnt,'',
				var_mkt,var_src,var_rsv_type,var_channel,var_tranlog,'','',var_srqs,'',
				'F','F','T','F','F','0','F','0',
				var_accnt,'000000000000000000000000000000',0,0,0,0,var_paycode,var_limit1,var_credcode,'',var_credunit,
				0,0,0,1,0,0,0,0,var_resno,'',
				var_wherefrom,var_whereto,'',CONCAT(IFNULL(var_ref,''),IFNULL(var_content2,'')),CONCAT(IFNULL(var_content3,''),IFNULL(var_content4,'')),var_resby,var_reserved,var_cby,var_changed);
		ELSE
			INSERT INTO master_base(hotel_group_id,hotel_id,rsv_id,is_resrv,rsv_man,rsv_company,rsv_src_id,rsv_class,master_id,grp_accnt,block_id,biz_date,
				sta,rmtype,rmno,rmnum,arr,dep,adult,children,res_sta,res_dep,rack_rate,nego_rate,real_rate,dsc_reason,dsc_amount,dsc_percent,
				exp_sta,tm_sta,rmpost_sta,is_rmposted,tag0,company_id,agent_id,source_id,member_type,member_no,salesman,arno,building,
				src,market,rsv_type,channel,ratecode,cmscode,packages,specials,amenities,
				is_fix_rate,is_fix_rmno,is_sure,is_permanent,is_walkin,is_secret,is_secret_rate,posting_flag,
				sc_flag,extra_flag,extra_bed_num,extra_bed_rate,crib_num,crib_rate,pay_code,limit_amt,credit_no,credit_man,credit_company,
				charge,pay,credit,last_num,last_num_link,rmocc_id,link_id,pkg_link_id,rsv_no,crs_no,
				where_from,where_to,purpose,remark,co_msg,create_user,create_datetime,modify_user,modify_datetime)
			VALUES(arg_hotel_group_id,arg_hotel_id,0,'F',var_applname,var_applicant,0,'G',0,0,0,var_biz_date,
				var_sta,'','',var_rooms,var_arr,var_dep,var_gstno,var_children,var_ressta,var_resdep,'0','0','0','','0','0',
				var_exp_sta,var_sta_tm,'F','F','',var_cid,var_aid,var_sid,'','',var_credman,var_araccnt,'',
				var_mkt,var_src,var_rsv_type,var_channel,var_tranlog,'','',var_srqs,'',
				'F','F','T','F','F','0','F','0',
				var_accnt,'000000000000000000000000000000',0,0,0,0,var_paycode,var_limit1,var_credcode,'',var_credunit,
				var_balance,0,0,1,0,0,0,0,var_resno,'',
				var_wherefrom,var_whereto,'',CONCAT(IFNULL(var_ref,''),IFNULL(var_content2,'')),CONCAT(IFNULL(var_content3,''),IFNULL(var_content4,'')),var_resby,var_reserved,var_cby,var_changed);
		END IF;

		SET var_last_accnt = var_accnt;
		SET var_id = LAST_INSERT_ID();
		
		INSERT INTO master_guest (hotel_group_id,hotel_id,id,profile_type,profile_id,NAME,last_name,first_name,name2,name3,name_combine,
					sex,LANGUAGE,title,salutation,interest,birth,race,religion,career,occupation,nation,country,state,city,division,street,zipcode,
					vip,phone,mobile,fax,email,id_code,id_no,id_end,visa_type,visa_no,visa_begin,visa_end,visa_grant,enter_port,enter_date,enter_date_end,
					photo_pic,photo_sign,remark,create_user,create_datetime,modify_user,modify_datetime)
				VALUES(arg_hotel_group_id,arg_hotel_id,var_id,'GUEST',0,var_name,'','',var_name,var_name,var_name,
					'1','C','','','',NULL,'','','','',var_nation,var_nation,'','','','','',
					var_vip,var_phoneetc,var_phoneetc,'','','','',NULL,'','',NULL,NULL,'','',NULL,NULL,
					0,0,'',var_resby,var_reserved,var_cby,var_changed);
		
		INSERT INTO master_stalog (hotel_group_id,hotel_id,id,rsv_user,rsv_datetime,ci_user,ci_datetime,
				co_user,co_datetime,dep_user,dep_datetime,modify_user,modify_datetime)
			VALUES(arg_hotel_group_id,arg_hotel_id,var_id,var_resby,var_reserved,var_cby,var_changed,
			IF(var_sta IN ('R','I'),'',var_cby),IF(var_sta IN('R','I'),NULL,var_changed),IF(var_sta IN ('R','I'),'',var_cby),IF(var_sta IN('R','I'),NULL,var_changed),var_cby,var_changed);
			
	       SET done_cursor = 0 ;
	       FETCH c_grpmst INTO 
	       var_accnt,var_sta,var_ressta,var_exp_sta,var_sta_tm,var_src,var_class,var_name,var_nation,var_cusno,var_tranlog,var_leader,var_mate,
	       var_rescode,var_children,var_gstno,var_rooms,var_rate,var_orate,var_ratemode,var_mkt,var_guide,var_arr,var_dep,var_oarr,var_odep,
	       var_resdep,var_applname,var_applicant,var_araccnt,var_phoneetc,var_paycode,var_limit1,var_credcode,var_credman,var_credunit,
	       var_empno ,var_tag0,var_wherefrom,var_whereto,var_arrinfo,var_depinfo,var_approved,var_approvedd,var_locksta ,
	       var_rmb_od,var_rmb_td,var_rmb_db,var_escr_od,var_escr_td,var_escr_db,var_depr_oc,var_depr_tc,var_depr_cr,var_addrmb,
	       var_addtr,var_addor,var_lastnumb,var_lastinumb,var_srqs,var_ref,var_content2,var_content3,var_content4,var_resby,var_resbyname,var_reserved,var_resmode,var_resno,
	       var_resby,var_reserved,var_cby,var_changed,var_exp_m,var_exp_dt,var_exp_s,var_logmark,var_vip,var_balance;
	END WHILE;
	CLOSE c_grpmst;
	
	INSERT INTO up_map_accnt(hotel_group_id,hotel_id,accnt_type,accnt_class,accnt_old,accnt_new) 
		SELECT arg_hotel_group_id,arg_hotel_id,'grpmst',CONCAT(rsv_class,sta),sc_flag,id FROM master_base
			WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND sc_flag<>'' AND sc_flag IS NOT NULL AND sta IN ('S','I','O','R') AND  rsv_class = 'G'; 
	
	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='grpmst';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='grpmst';
	
END$$

DELIMITER ;