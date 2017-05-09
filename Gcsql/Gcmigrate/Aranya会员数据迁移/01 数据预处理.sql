DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_migrate_member_pre`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_migrate_member_pre`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT
)
label_0:
BEGIN
	DECLARE var_group_code	 	VARCHAR(60);
	DECLARE var_bdate 			DATETIME;

	-- 预处理
	SELECT code INTO var_group_code FROM hotel_group WHERE id = arg_hotel_group_id;

	SELECT DATE(set_value) INTO var_bdate FROM sys_option WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND item='biz_date' ;
	
	/*
		将原数据准备到aranya_member_data表中
		1、核查hotel_group_id,hotel_id、card_type字段内容
	*/
	START TRANSACTION;
        TRUNCATE TABLE aranya_member_data;
        INSERT INTO aranya_member_data
            (hotel_group_id,hotel_id,iss_hotel,biz_date,card_no,card_no2,sta,
            card_type,card_level,card_src,card_name,ratecode,posmode,date_begin,date_end,password,salesman,crc,remark,
            araccnt,create_user,create_datetime,modify_user,modify_datetime,
            point_pay,point_charge,point_last_num,pay,charge,
            hno,hname,hlname,hfname,hname2,hname3,hname_combine,sex,LANGUAGE,birth,nation,id_code,id_no,hremark,
            hcreate_user,hcreate_datetime,hmodify_user,hmodify_datetime,mobile,phone,email,
            country,state,city,division,street,zipcode,loginpw,company_name)
        SELECT arg_hotel_group_id,arg_hotel_id,var_group_code,var_bdate,vch_vipkh,VCH_VIPBH,'I',
            vch_viplx,'','1',vch_khxm,'','',dat_fkrq,dat_yxrq,'888888','',IFNULL(vch_no,''),IFNULL(vch_bz,''),
            guid,'Aranya',dat_fkrq,'Aranya',dat_fkrq,
            0,0,0,MON_YE,0,
            vch_zzh,vch_khxm,vch_khxm,vch_khxm,vch_khxm,vch_khxm,concat(vch_khxm,vch_khxm,vch_khxm),IF(vch_xb='男',1,IF(vch_xb='女',2,'')),'C',dat_sr,'CN','02',IFNULL(vch_zjbh,''),'',
            'Aranya',dat_fkrq,'Aranya',dat_fkrq,IFNULL(VCH_SJHM,''),'','',
            '','','','','','','',vch_dwmc
        FROM TV_VIPXX GROUP BY vch_vipkh;

        -- 去除经酒店确定的会员卡种
        UPDATE aranya_member_data SET hotel_group_id = - arg_hotel_group_id WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type IN ('高尔夫50次卡','婚庆卡','九州会会员卡','客房卡','微信会员','消费卡');

        -- 原西软账务系统中，存在多卡共用一账号时，西软系统中一账户多卡没有从属关系，ihotel要求有从属关系
        -- 主卡的card_master字段填null，附卡填主卡的 card_id_temp,
        -- 手工或程序方式填写card_master字段，并将附卡的帐户余额（set pay=0、charge=0）清零
        -- 主附卡
        UPDATE aranya_member_data a,aranya_member_data b SET b.card_master = a.card_id_temp
        WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.card_no2=a.hno
        AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND b.card_no2<>b.hno AND a.hno=b.hno;

        UPDATE aranya_member_data SET pay=0,charge=0 WHERE card_master IS NOT NULL;

        -- 指定hotel_id,iss_hotel //请对照：hotel.id。酒店编号;请对照：hotel.code。发卡酒店代码
        -- 对照表up_map_code中的code字段用于区别各种类型代码
        UPDATE aranya_member_data SET iss_hotel=var_group_code WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
        -- select distinct hotel_id ,iss_hotel  from aranya_member_data order by hotel_id

        -- 翻译代码卡状态 //状态=R=初始 I-有效,X-销卡,L-挂失,M-损坏,O-停用 S=休眠
        -- 若为西软系统，此句跳过；若其它PMS系统，核查卡状态建立对照表

        -- 翻译卡计划和等级 card_type,card_level 请对照,card_type.code 请对照，card_level.code
        UPDATE aranya_member_data SET card_type='XZK',card_level='ZSKYZZK',ratecode = 'OWN',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '赠送卡业主折扣';
        UPDATE aranya_member_data SET card_type='CZK',card_level='GEFHYK',ratecode = 'OWN',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '高尔夫会员卡';
        -- UPDATE aranya_member_data SET card_type='ZHANGH',card_level='140' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '消费卡';
        UPDATE aranya_member_data SET card_type='XZK',card_level='DCYGCK',ratecode = '',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '地产员工餐卡';
        UPDATE aranya_member_data SET card_type='XZK',card_level='3FFZK',ratecode = 'OWN',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '3F反租卡';
        UPDATE aranya_member_data SET card_type='XYK',card_level='DCZDK',ratecode = 'OWN',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '地产招待卡';
        UPDATE aranya_member_data SET card_type='XZK',card_level='DOK',ratecode = '',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = 'DO卡';
        UPDATE aranya_member_data SET card_type='XZK',card_level='JTCK',ratecode = '',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '集团餐卡';
        UPDATE aranya_member_data SET card_type='XZK',card_level='JZHYGCK',ratecode = '',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '九州会员工餐卡';
        UPDATE aranya_member_data SET card_type='XZK',card_level='LSYGK',ratecode = '',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '员工卡';
        UPDATE aranya_member_data SET card_type='XYK',card_level='JZHZDK',ratecode = 'OWN',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '九州会招待卡';
        UPDATE aranya_member_data SET card_type='CZK',card_level='YZK',ratecode = 'OWN',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '业主卡';
        UPDATE aranya_member_data SET card_type='CZK',card_level='HZHBCZK',ratecode = 'OWN',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '合作伙伴消费卡';
        UPDATE aranya_member_data SET card_type='CZK',card_level='DCYGCZK',ratecode = 'OWN',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '地产员工消费卡';
        UPDATE aranya_member_data SET card_type='XZK',card_level='ALFZK',ratecode = 'OWN',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '安澜反租卡';
        UPDATE aranya_member_data SET card_type='QCK',card_level='XMK',ratecode = 'OWN',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '享梦卡';
        UPDATE aranya_member_data SET card_type='XYK',card_level='XYDWXNK',ratecode = '',posmode = '' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '协议单位';
        UPDATE aranya_member_data SET card_type='XYK',card_level='ZDK',ratecode = 'OWN',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '招待卡';
        UPDATE aranya_member_data SET card_type='CZK',card_level='JZHYGCZK',ratecode = 'OWN',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '九州会员工消费卡';
        UPDATE aranya_member_data SET card_type='XZK',card_level='HZHBCK',ratecode = '',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '合作伙伴餐卡';
        UPDATE aranya_member_data SET card_type='XZK',card_level='ZSKFKZK',ratecode = 'IGCOR',posmode = '000' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '赠送卡访客折扣';
        UPDATE aranya_member_data SET card_type='CZK',card_level='YXYGCZK',ratecode = 'OWN',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '营销员工消费卡';
        UPDATE aranya_member_data SET card_type='CZK',card_level='TYK',ratecode = 'IGCOR',posmode = '000' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = '体验卡';
        UPDATE aranya_member_data SET card_type='XZK',card_level='VVIP',ratecode = 'OWN',posmode = '001' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND card_type = 'VVIP卡';


        -- 翻译发卡来源 card_src//请对照，code_base.parent_code = 'card_src'

        -- 指定期初付款码 aranya_member_data.pay_code //请对照,code_transaction.code

        UPDATE aranya_member_data SET pay_code='9810' WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id;



        -- 翻译或填写房价码 ,餐娱码ratecode,posmode //请对照：code_ratecode房价码；请对照：code_base.parent_code = 'pos_mode'餐娱码


        -- 在aranya_member_data中验证卡数量、积分余额、储值余额
        -- 卡总数
        /*
        SELECT card_type,card_level,COUNT(1) tl FROM aranya_member_data WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id
        GROUP BY card_type,card_level
        UNION ALL
        SELECT '','',COUNT(1) FROM aranya_member_data WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id;
        -- 积分总数
        SELECT SUM(point_pay) ,SUM(point_charge),SUM(point_pay - point_charge) balance FROM aranya_member_data WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id;
        -- 储值卡余额、冻结数
        SELECT SUM(pay) ,SUM(charge) ,SUM(pay - charge) balance ,SUM(freeze) FROM aranya_member_data WHERE hotel_group_id=arg_hotel_group_id AND hotel_id = arg_hotel_id;
        */
    COMMIT;
	
END$$

DELIMITER ;

-- CALL up_ihotel_migrate_member_pre(2,14);