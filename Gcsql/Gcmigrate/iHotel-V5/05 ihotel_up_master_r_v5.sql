DELIMITER $$
 
DROP PROCEDURE IF EXISTS `ihotel_up_master_r_v5`$$

CREATE DEFINER=`root`@`%` PROCEDURE `ihotel_up_master_r_v5`(
	IN arg_hotel_group_id BIGINT(16),
	IN arg_hotel_id BIGINT(16) 
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- -------------------------------------------------
	-- 散客预订数据迁移  migrate_xc.master.sta = 'R'
	-- ------------------------------------------------- 	
	DECLARE var_biz_date DATETIME ;
	DECLARE done_cursor INT DEFAULT 0 ;
	DECLARE var_accnt 	VARCHAR(7);	
	DECLARE var_guestid VARCHAR(7);
	DECLARE var_rmtype 	VARCHAR(10);
	DECLARE var_rmno 	VARCHAR(10);
	DECLARE var_rmnum 	INT(8);
	DECLARE var_arr 	DATETIME;
	DECLARE var_dep 	DATETIME;
	DECLARE var_gstno 	INT(8);
	DECLARE var_children INT(8);
	DECLARE var_cusno 	VARCHAR(10);
	DECLARE var_tranlog VARCHAR(10);
	DECLARE var_src 	VARCHAR(10);
	DECLARE var_mkt 	VARCHAR(10);
	DECLARE var_qtrate 	DECIMAL(12,2);
	DECLARE var_setrate DECIMAL(12,2);
	DECLARE var_rtreason VARCHAR(10);
	DECLARE var_paycode VARCHAR(10);
	DECLARE var_phoneetc VARCHAR(30);
	DECLARE var_srqs 	VARCHAR(30);
	DECLARE var_content     VARCHAR(1024);
	DECLARE var_content2    VARCHAR(1024);
	DECLARE var_content3    VARCHAR(1024);
	DECLARE var_content4    VARCHAR(1024);
	DECLARE var_haccnt 	VARCHAR(10);
	DECLARE var_name 	VARCHAR(60); 
	DECLARE var_sex 	VARCHAR(2);
	DECLARE var_birth 	DATETIME; 
	DECLARE var_secret	CHAR(1);
	DECLARE var_vip 	VARCHAR(10); 
	DECLARE var_idcls 	VARCHAR(10); 
	DECLARE var_ident 	VARCHAR(20); 
	DECLARE var_nation 	VARCHAR(10); 
	DECLARE var_race 	VARCHAR(10); 
	DECLARE var_address VARCHAR(60); 
	DECLARE var_birthplace VARCHAR(10); 
	DECLARE var_balance DECIMAL(12,2); 
	DECLARE var_wherefrom VARCHAR(10); 
	DECLARE var_whereto VARCHAR(10); 
	DECLARE var_sta 	VARCHAR(2);	
	DECLARE var_rsv_type VARCHAR(10);
	DECLARE var_channel VARCHAR(10);
	DECLARE var_profile_type VARCHAR(10);
	DECLARE var_profile_id BIGINT(16);
	DECLARE var_id 		BIGINT(16);
	DECLARE var_resno 	VARCHAR(20);
	DECLARE var_credman	VARCHAR(10);
	DECLARE var_applname 	VARCHAR(50);
	DECLARE var_applicant 	VARCHAR(100);
	DECLARE	var_company_id 	BIGINT(16);
	DECLARE var_company_class VARCHAR(2);
	DECLARE	var_cid 	BIGINT(16);
	DECLARE	var_aid 	BIGINT(16);
	DECLARE	var_sid 	BIGINT(16);
	DECLARE var_resby	VARCHAR(7);
	DECLARE var_reserved	DATETIME;
	DECLARE var_cby		VARCHAR(7);
	DECLARE var_changed	DATETIME;
	DECLARE var_times_in	INT;
	DECLARE var_last_accnt VARCHAR(10) DEFAULT '';
	
	DECLARE c_master CURSOR FOR 
		SELECT a.accnt,b.guestid,a.type,a.roomno,a.rmnum,a.arr,a.dep,a.gstno,a.children,a.cusno,a.tranlog,a.src,a.mkt,
			a.qtrate,a.setrate*(1-a.discount1),a.rtreason,a.paycode,a.phoneetc,a.srqs,b.haccnt,TRIM(b.name),b.sex,b.birth,b.vip,b.secret,b.idcls,b.ident,b.nation,
			b.race,b.address,b.birthplace,a.rmb_db-a.depr_cr-a.addrmb,a.sta,c.content,d.content,e.content,f.content,a.credman,a.applname,a.applicant,a.resby,a.reserved,a.cby,a.resno,a.changed
		FROM migrate_xc.master a,migrate_xc.guest b 
		LEFT JOIN migrate_xc.message c ON b.accnt = c.accnt AND c.type = '61' 
		LEFT JOIN migrate_xc.message d ON b.accnt = d.accnt AND d.type = '64'
		LEFT JOIN migrate_xc.message e ON b.accnt = e.accnt AND e.type = '63'
		LEFT JOIN migrate_xc.message f ON b.accnt = f.accnt AND e.type = '73'
		WHERE a.accnt=b.accnt AND SUBSTRING(a.accnt,2,2)<>'95' AND a.sta = 'R' ORDER BY a.accnt;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;
	
	SELECT biz_date INTO var_biz_date FROM audit_flag WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id; 
	SELECT MIN(CODE) INTO var_rsv_type FROM code_rsv_type WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND is_halt = 'F'; 
	SELECT district_code INTO var_whereto FROM hotel WHERE hotel_group_id=arg_hotel_group_id AND id=arg_hotel_id; 	
	DELETE FROM up_status WHERE hotel_id=arg_hotel_id AND up_step='MASTER_R';
	INSERT INTO up_status(hotel_id,up_step,time_begin,time_end,time_long,remark) VALUES(arg_hotel_id,'MASTER_R',NOW(),NULL,0,''); 
	DELETE FROM up_map_accnt WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type='master_r' AND accnt_class='R';
	
	OPEN c_master ;
	SET done_cursor = 0 ;
	FETCH c_master INTO var_accnt,var_guestid,var_rmtype,var_rmno,var_rmnum,var_arr,var_dep,var_gstno,var_children,var_cusno,var_tranlog,var_src,var_mkt,
					var_qtrate,var_setrate,var_rtreason,var_paycode,var_phoneetc,var_srqs,var_haccnt,var_name,var_sex,var_birth,var_vip,var_secret,var_idcls,var_ident,var_nation,
					var_race,var_address,var_birthplace,var_balance,var_sta,var_content,var_content2,var_content3,var_content4,var_credman,var_applname,var_applicant,var_resby,var_reserved,var_cby,var_resno,var_changed; 
	WHILE done_cursor = 0 DO
		BEGIN

			IF var_idcls = '01' OR var_idcls = 'C01' THEN 
				SET var_wherefrom = MID(var_ident,1,6); 
			ELSE
				SET var_wherefrom = ''; 
			END IF; 		
			SET var_profile_id = 0; 
			SET var_channel = 'WAK';
			SET var_src = 'WAK';			
			IF var_haccnt<>'' THEN 
				SELECT accnt_new INTO var_profile_id FROM up_map_accnt WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type='GUEST_FIT' AND accnt_old=var_accnt; 
 			END IF; 
			IF var_profile_id=0 AND var_ident<>'' THEN 
				SET var_profile_type='F',var_profile_id=0; 
				CALL ihotel_up_get_guest_id_v5(arg_hotel_group_id,arg_hotel_id,var_haccnt,var_name,var_idcls,var_ident,var_sex,var_birth,var_race,var_address,var_birthplace,var_profile_id); 
			END IF; 
			
			SET var_company_id=0,var_cid=0,var_aid=0,var_sid=0; 
			IF var_cusno <> '' THEN 
				SELECT accnt_new INTO var_company_id FROM up_map_accnt WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND accnt_type='COMPANY' AND accnt_old=var_cusno; 
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
				INSERT INTO master_base(hotel_group_id,hotel_id,rsv_id,is_resrv,rsv_man,rsv_company,rsv_src_id,rsv_class,master_id,grp_accnt,block_id,biz_date,
					sta,rmtype,rmno,rmnum,arr,dep,adult,children,res_sta,res_dep,rack_rate,nego_rate,real_rate,dsc_reason,dsc_amount,dsc_percent,
					exp_sta,tm_sta,rmpost_sta,is_rmposted,tag0,company_id,agent_id,source_id,member_type,member_no,salesman,arno,building,
					src,market,rsv_type,channel,ratecode,cmscode,packages,specials,amenities,
					is_fix_rate,is_fix_rmno,is_sure,is_permanent,is_walkin,is_secret,is_secret_rate,posting_flag,
					sc_flag,extra_flag,extra_bed_num,extra_bed_rate,crib_num,crib_rate,pay_code,limit_amt,credit_no,credit_man,credit_company,
					charge,pay,credit,last_num,last_num_link,rmocc_id,link_id,pkg_link_id,rsv_no,crs_no,
					where_from,where_to,purpose,remark,co_msg,create_user,create_datetime,modify_user,modify_datetime)
				VALUES(arg_hotel_group_id,arg_hotel_id,0,IF(var_rmno<>'','F','T'),var_applname,var_applicant,0,'F',0,0,0,var_biz_date,
					var_sta,var_rmtype,var_rmno,var_rmnum,var_arr,var_dep,var_gstno,var_children,'R',NULL,0,0,0,var_rtreason,var_qtrate-var_setrate,0,
					'R',var_sta,'F','F','',var_cid,var_aid,var_sid,'','',var_credman,'','',
					var_mkt,var_src,var_rsv_type,var_channel,var_tranlog,'','',var_srqs,'',
					'F','F','T','T','F','0','F','0',
					CONCAT(var_accnt,'-',var_guestid),'000000000000000000000000000000',0,0,0,0,var_paycode,0,'','','',
					0,0,0,1,0,0,0,0,var_resno,'',
					var_wherefrom,var_whereto,'',CONCAT(IFNULL(var_content,''),IFNULL(var_content2,''),IFNULL(var_content3,''),IFNULL(var_content4,'')),var_resby,var_reserved,var_cby,var_changed);		
			ELSE
				INSERT INTO master_base(hotel_group_id,hotel_id,rsv_id,is_resrv,rsv_man,rsv_company,rsv_src_id,rsv_class,master_id,grp_accnt,block_id,biz_date,
					sta,rmtype,rmno,rmnum,arr,dep,adult,children,res_sta,res_dep,rack_rate,nego_rate,real_rate,dsc_reason,dsc_amount,dsc_percent,
					exp_sta,tm_sta,rmpost_sta,is_rmposted,tag0,company_id,agent_id,source_id,member_type,member_no,salesman,arno,building,
					src,market,rsv_type,channel,ratecode,cmscode,packages,specials,amenities,
					is_fix_rate,is_fix_rmno,is_sure,is_permanent,is_walkin,is_secret,is_secret_rate,posting_flag,
					sc_flag,extra_flag,extra_bed_num,extra_bed_rate,crib_num,crib_rate,pay_code,limit_amt,credit_no,credit_man,credit_company,
					charge,pay,credit,last_num,last_num_link,rmocc_id,link_id,pkg_link_id,rsv_no,crs_no,
					where_from,where_to,purpose,remark,co_msg,create_user,create_datetime,modify_user,modify_datetime)
				VALUES(arg_hotel_group_id,arg_hotel_id,0,IF(var_rmno<>'','F','T'),var_applname,var_applicant,0,'F',0,0,0,var_biz_date,
					var_sta,var_rmtype,var_rmno,var_rmnum,var_arr,var_dep,var_gstno,var_children,'R',NULL,var_qtrate,var_setrate,var_setrate,var_rtreason,var_qtrate-var_setrate,0,
					'I',var_sta,'F','F','',var_cid,var_aid,var_sid,'','',var_credman,'','',
					var_mkt,var_src,var_rsv_type,var_channel,var_tranlog,'','',var_srqs,'',
					'F','F','T','T','F','0','F','0',
					CONCAT(var_accnt,'-',var_guestid),'000000000000000000000000000000',0,0,0,0,var_paycode,0,'','','',
					var_balance,0,0,0,0,0,0,0,var_resno,'',
					var_wherefrom,var_whereto,'',CONCAT(IFNULL(var_content,''),IFNULL(var_content2,''),IFNULL(var_content3,''),IFNULL(var_content4,'')),'',var_resby,var_reserved,var_cby,var_changed);		
			END IF;
			
			SET var_last_accnt = var_accnt;
			SET var_id = LAST_INSERT_ID(); 
			
			IF var_profile_id > 0 THEN 
				INSERT INTO master_guest(hotel_group_id,hotel_id,id,profile_type,profile_id,NAME,last_name,first_name,name2,name3,name_combine,
					sex,LANGUAGE,title,salutation,interest,birth,race,religion,career,occupation,nation,country,state,city,division,street,zipcode,
					vip,phone,mobile,fax,email,id_code,id_no,id_end,visa_type,visa_no,visa_begin,visa_end,visa_grant,enter_port,enter_date,enter_date_end,
					photo_pic,photo_sign,remark,create_user,create_datetime,modify_user,modify_datetime)
				SELECT arg_hotel_group_id,arg_hotel_id,var_id,'F',a.id,a.name,a.last_name,a.first_name,a.name2,a.name3,a.name_combine,
					a.sex,a.language,a.title,a.salutation,'',a.birth,a.race,a.religion,a.career,a.occupation,a.nation,'CN','','','',var_address,'',
					d.vip,b.phone,b.mobile,b.fax,b.email,a.id_code,a.id_no,a.id_end,'','',NULL,NULL,NULL,'',NULL,NULL,
					0,0,'',var_resby,var_reserved,var_cby,var_changed
					FROM guest_base a,guest_link_base b,guest_type d  
					WHERE a.id=var_profile_id AND a.hotel_group_id=b.hotel_group_id AND a.hotel_id=b.hotel_id 
						AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=0 AND a.id=b.id 
						AND a.hotel_group_id=d.hotel_group_id AND d.hotel_id=arg_hotel_id AND a.id=d.guest_id;					        
			ELSE
				INSERT INTO master_guest(hotel_group_id,hotel_id,id,profile_type,profile_id,NAME,last_name,first_name,name2,name3,name_combine,
					sex,LANGUAGE,title,salutation,interest,birth,race,religion,career,occupation,nation,country,state,city,division,street,zipcode,
					vip,phone,mobile,fax,email,id_code,id_no,id_end,visa_type,visa_no,visa_begin,visa_end,visa_grant,enter_port,enter_date,enter_date_end,
					photo_pic,photo_sign,remark,create_user,create_datetime,modify_user,modify_datetime)
				VALUES(arg_hotel_group_id,arg_hotel_id,var_id,'GUEST',0,var_name,'','','','',var_name,
					var_sex,'C','','','',var_birth,'','','','',var_nation,var_nation,'','','',var_address,'',
					var_vip,'','','','',var_idcls,var_ident,NULL,'','',NULL,NULL,'','',NULL,NULL,
					0,0,'',var_resby,var_reserved,var_cby,var_changed);			        
			END IF;

			-- master_stalog 状态信息
			INSERT INTO master_stalog (hotel_group_id,hotel_id,id,rsv_user,rsv_datetime,ci_user,ci_datetime,co_user,co_datetime,dep_user,dep_datetime,modify_user,modify_datetime)
			VALUES(arg_hotel_group_id,arg_hotel_id,var_id,var_resby,var_reserved,var_cby,var_changed,'',NULL,var_cby,var_changed,'ADMIN',var_changed);	
							
			SET done_cursor = 0 ;
			FETCH c_master INTO var_accnt,var_guestid,var_rmtype,var_rmno,var_rmnum,var_arr,var_dep,var_gstno,var_children,var_cusno,var_tranlog,var_src,var_mkt,
					var_qtrate,var_setrate,var_rtreason,var_paycode,var_phoneetc,var_srqs,var_haccnt,var_name,var_sex,var_birth,var_vip,var_secret,var_idcls,var_ident,var_nation,
					var_race,var_address,var_birthplace,var_balance,var_sta,var_content,var_content2,var_content3,var_content4,var_credman,var_applname,var_applicant,var_resby,var_reserved,var_cby,var_resno,var_changed; 
		END ;
	END WHILE ;
	CLOSE c_master;	
	
	INSERT INTO up_map_accnt(hotel_group_id,hotel_id,accnt_type,accnt_class,accnt_old,accnt_new) 
		SELECT arg_hotel_group_id,arg_hotel_id,'master_r',CONCAT(rsv_class,sta),sc_flag,id FROM master_base
			WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND sc_flag<>'' AND sc_flag IS NOT NULL AND sta = 'R';	
	
 	UPDATE up_status SET time_end=NOW() WHERE hotel_id=arg_hotel_id AND up_step='MASTER_R';
	UPDATE up_status SET time_long=TIMESTAMPDIFF(SECOND,time_begin,time_end) WHERE hotel_id=arg_hotel_id AND up_step='MASTER_R';
	
END$$

DELIMITER ;