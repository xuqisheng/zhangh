/*

CREATE TABLE `pos_input_table` (
  `hotel_group_id`  int(11) DEFAULT NULL,
  `hotel_id`        int(11) DEFAULT NULL,
  `id`              int(11) NOT NULL AUTO_INCREMENT,
  `pos_note_name`   varchar(50) DEFAULT NULL COMMENT '菜本',
  `pos_sort_name`   varchar(50) DEFAULT NULL COMMENT '菜类',
  `pos_plu_old`     varchar(10) DEFAULT NULL COMMENT '菜项原代码',
  `pos_plu_name`    varchar(50) DEFAULT NULL COMMENT '菜项名称',
  `pos_help`        varchar(30) DEFAULT NULL COMMENT '助记码',
  `pos_unit`        varchar(5) DEFAULT NULL  COMMENT '单位',
  `pos_price`       decimal(12,2) DEFAULT NULL COMMENT '价格',
  `pos_price1`      decimal(12,2) DEFAULT NULL COMMENT '价格1,导入指定折扣模式中固定金额',
  `pos_price2`      decimal(12,2) DEFAULT NULL COMMENT '价格2,导入指定折扣模式中固定金额',
  `pos_price3`      decimal(12,2) DEFAULT NULL COMMENT '价格3,导入指定折扣模式中固定金额',
  `pos_note`        varchar(10) DEFAULT NULL   COMMENT '新菜本代码',
  `pos_sort`        varchar(10) DEFAULT NULL   COMMENT '新菜类代码',
  `pos_plu`         varchar(10) DEFAULT NULL   COMMENT '新菜项代码',
  PRIMARY KEY (`id`),
  KEY `Index_1` (`hotel_group_id`,`hotel_id`,`pos_plu_old`),
  KEY `Index_2` (`hotel_group_id`,`hotel_id`,`pos_sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

 */

DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_pos_input_plu_aranya`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_pos_input_plu_aranya`(
	IN arg_hotel_group_id 	INT,
	IN arg_hotel_id 		INT
    )

	SQL SECURITY INVOKER
label_0:
BEGIN
	/*
		阿那亚 Aranya  菜谱导入
	*/
	DECLARE done_cursor 	INT DEFAULT 0;
	DECLARE var_pos_note 	VARCHAR(10);
	DECLARE var_pos_sort 	VARCHAR(10);

	DECLARE c_sort CURSOR FOR
	SELECT pos_note FROM pos_input_table
		WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY pos_note ORDER BY pos_note;

	DECLARE c_plu CURSOR FOR
	SELECT pos_note,pos_sort FROM pos_input_table
		WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY pos_note,pos_sort ORDER BY pos_note,pos_sort;

	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done_cursor = 1;

    -- 将对方数据导入中间表
    DELETE FROM pos_input_table WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
	INSERT INTO pos_input_table(hotel_group_id,hotel_id,pos_note_name,pos_sort_name,pos_plu_old,pos_plu_name,pos_help,pos_unit,
	    pos_price,pos_price1,pos_price2,pos_price3)
	SELECT arg_hotel_group_id,arg_hotel_id,vch_xfbm,vch_cdfl,vch_cdbh,vch_cdmc,vch_zjm,vch_cddw,
	    mon_cddj,mon_cddj1,mon_cddj2,mon_cddj3
        from ty_cd where bit_sfsy='1' and vch_xfbm<>'' order by vch_xfbm,vch_cdfl;


    UPDATE pos_input_table SET pos_note_name = REPLACE(pos_note_name,'（','(') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
    UPDATE pos_input_table SET pos_note_name = REPLACE(pos_note_name,'）',')') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
    UPDATE pos_input_table SET pos_note_name = REPLACE(pos_note_name,'/','')   WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;

    UPDATE pos_input_table SET pos_sort_name = REPLACE(pos_sort_name,'（','(') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
    UPDATE pos_input_table SET pos_sort_name = REPLACE(pos_sort_name,'）',')') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
    UPDATE pos_input_table SET pos_sort_name = REPLACE(pos_sort_name,'/','')   WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;

    UPDATE pos_input_table SET pos_plu_name = REPLACE(pos_plu_name,'（','(') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
    UPDATE pos_input_table SET pos_plu_name = REPLACE(pos_plu_name,'）',')') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
    UPDATE pos_input_table SET pos_plu_name = REPLACE(pos_plu_name,'/','')   WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;

    UPDATE pos_input_table SET pos_help = REPLACE(pos_help,'(','') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
    UPDATE pos_input_table SET pos_help = REPLACE(pos_help,')','') WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
    UPDATE pos_input_table SET pos_help = UPPER(pos_help) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;

	-- 数据预处理
	DELETE FROM pos_input_table WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND pos_plu_name='';

	-- 先对菜类进行排序更新
	SET @num_sort_note=90;
	UPDATE pos_input_table a,(SELECT c.pos_note_name,(@num_sort_note := @num_sort_note  + 10) AS linum_sort_note FROM
	(SELECT pos_note_name FROM pos_input_table WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id GROUP BY pos_note_name) AS c
	ORDER BY c.pos_note_name) AS b
	SET a.pos_note = b.linum_sort_note
	WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.pos_note_name=b.pos_note_name;

	-- 菜类编码更新
	OPEN c_sort ;
	SET done_cursor = 0 ;
	FETCH c_sort INTO var_pos_note;
	WHILE done_cursor = 0 DO
		BEGIN

			SET @num_sort=9;
			UPDATE pos_input_table a,(SELECT c.pos_sort_name,(@num_sort := @num_sort + 1) AS linum_sort FROM
			(SELECT pos_sort_name FROM pos_input_table WHERE pos_note = var_pos_note GROUP BY pos_sort_name) AS c ORDER BY c.pos_sort_name) AS b
			SET a.pos_sort = b.linum_sort WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.pos_note = var_pos_note
				AND a.pos_sort_name = b.pos_sort_name;

		SET done_cursor = 0 ;
		FETCH c_sort INTO var_pos_note;
		END ;
	END WHILE ;
	CLOSE c_sort;

	-- 菜项编码更新
	OPEN c_plu ;
	SET done_cursor = 0 ;
	FETCH c_plu INTO var_pos_note,var_pos_sort;
	WHILE done_cursor = 0 DO
		BEGIN

			SET @num_plu=0;
			UPDATE pos_input_table a,(SELECT pos_plu_old,(@num_plu := @num_plu + 1) AS linum_plu FROM pos_input_table WHERE pos_note = var_pos_note AND pos_sort = var_pos_sort ORDER BY pos_plu) AS b
			SET a.pos_plu = b.linum_plu WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.pos_note = var_pos_note AND a.pos_sort = var_pos_sort AND a.pos_plu_old = b.pos_plu_old;

		SET done_cursor = 0 ;
		FETCH c_plu INTO var_pos_note,var_pos_sort;
		END ;
	END WHILE ;
	CLOSE c_plu;

	UPDATE pos_input_table SET pos_sort = CONCAT('0',pos_sort) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND pos_sort < 10;

	UPDATE pos_input_table SET pos_plu = CONCAT('00',pos_plu) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND pos_plu < 10;
	UPDATE pos_input_table SET pos_plu = CONCAT('0',pos_plu) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND pos_plu < 100 AND pos_plu >= 10;

	UPDATE pos_input_table SET pos_sort = CONCAT(pos_note,pos_sort) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;
	UPDATE pos_input_table SET pos_plu = CONCAT(pos_sort,pos_plu) WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;


	DELETE FROM portal_group.code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code = 'pos_note';
	DELETE FROM portal_pms.code_base WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND parent_code = 'pos_note';
	DELETE FROM pos_sort_all WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id ;
	DELETE FROM pos_plu_all  WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id ;

	-- 菜本  code_base.parent_code='pos_note' 注意分库多个库 建议直接导在portal_group库，然后使用同步下发  或 手工拷贝
	INSERT INTO portal_group.code_base(hotel_group_id,hotel_id,code,parent_code,descript,descript_en,max_len,flag,code_category,is_sys,is_group,group_code,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime,code_type)
		SELECT arg_hotel_group_id,arg_hotel_id,pos_note,'pos_note',pos_note_name,pos_note_name,'30','','','F','T','001','F','0','ADMIN',NOW(),'ADMIN',NOW(),'1'
			FROM pos_input_table WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id GROUP BY pos_note;

	-- 菜类 pos_sort_all	导入之后，需检查【报表数据项】
	INSERT INTO pos_sort_all(hotel_group_id,hotel_id,code,plu_code,descript,descript_en,condst,tocode,is_halt,list_order,is_group,group_code,code_type,create_user,create_datetime,modify_user,modify_datetime)
		SELECT arg_hotel_group_id,arg_hotel_id,pos_sort,pos_note,pos_sort_name,pos_sort_name,'','010','F','0','T','0.00','1','ADMIN',NOW(),'ADMIN',NOW()
			FROM pos_input_table WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id GROUP BY pos_sort;

	-- 菜项 pos_plu_all		导入之后，需要检查【报表数据项】、【菜项属性】
	INSERT INTO pos_plu_all (hotel_group_id,hotel_id,code,sort_code,descript,descript_en,helpcode,price,unit,cost_price,mode,menu,flag,condgp1,tocode,timecode,pt_num,has_pic,pic_path1,is_central,introduction,plu_material,remark,list_order,is_halt,is_group,group_code,code_type,create_user,create_datetime,modify_user,modify_datetime)
		SELECT arg_hotel_group_id,arg_hotel_id,pos_plu,pos_sort,pos_plu_name,pos_plu_name,pos_help,pos_price,pos_unit,'0.00','T','11111','00000000000000000000','','010',NULL,NULL,NULL,'','F','','','','1000','F','T','0.00','1','ADMIN',NOW(),'ADMIN',NOW()
			FROM pos_input_table WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id GROUP BY pos_plu ORDER BY pos_note,pos_sort;


    -- pos_mode_def 菜项模式定义
    -- 001 业主模式 pos_price1     002 嘉宾模式 pos_price2    003 高尔夫模式 pos_price3
    insert into pos_mode_def (hotel_group_id,hotel_id,code,descript,pccode,pccode_descript,sort_code,sort_descript,plu_code,
        plu_descript,type,class1,class2,rate,is_group,group_code,code_type,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime)
    SELECT arg_hotel_group_id,arg_hotel_id,'001','业主模式','XXX','XXX',pos_sort,pos_sort_name,pos_plu,pos_plu_name,'4','T',
        pos_price,pos_price1,'F','','plu','F','0','ADMIN',NOW(),'ADMIN',NOW()
        FROM pos_input_table WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;

    insert into pos_mode_def (hotel_group_id,hotel_id,code,descript,pccode,pccode_descript,sort_code,sort_descript,plu_code,
        plu_descript,type,class1,class2,rate,is_group,group_code,code_type,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime)
    SELECT arg_hotel_group_id,arg_hotel_id,'002','嘉宾模式','XXX','XXX',pos_sort,pos_sort_name,pos_plu,pos_plu_name,'4','T',
        pos_price,pos_price2,'F','','plu','F','0','ADMIN',NOW(),'ADMIN',NOW()
        FROM pos_input_table WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;

    insert into pos_mode_def (hotel_group_id,hotel_id,code,descript,pccode,pccode_descript,sort_code,sort_descript,plu_code,
        plu_descript,type,class1,class2,rate,is_group,group_code,code_type,is_halt,list_order,create_user,create_datetime,modify_user,modify_datetime)
    SELECT arg_hotel_group_id,arg_hotel_id,'003','高尔夫模式','XXX','XXX',pos_sort,pos_sort_name,pos_plu,pos_plu_name,'4','T',
        pos_price,pos_price3,'F','','plu','F','0','ADMIN',NOW(),'ADMIN',NOW()
        FROM pos_input_table WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id;

    -- pos_pccode_note 营业点 关联 菜本



    -- 统计导入 hotel_id = 9 中 再作hotel_id的更换
    -- code_base    pos_sort_all   pos_plu_all   pos_mode_def  pos_pccode_note




END$$

DELIMITER ;


SELECT MAX(id) INTO @a FROM portal_group.code_base;
-- 注意hotel_group_id和hotel_id
CALL up_ihotel_pos_input_plu_aranya(2,9);

SELECT MAX(id) INTO @b FROM portal_group.code_base;

INSERT INTO portal_group.sync_data(hotel_group_id,hotel_id,flag,entity_name,entity_id,sync_type)
SELECT hotel_group_id,hotel_id,DATE_FORMAT( NOW(),'%Y%m%d%H%i%s000'),'CodeBase',id,'ADD'
FROM portal_group.code_base WHERE id > @a AND id<= @b;