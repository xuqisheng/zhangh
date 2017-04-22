DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_rep_reserve_status`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_rep_reserve_status`(
	IN arg_hotel_group_id	INT,
	IN arg_hotel_id			INT,
	IN arg_begin_date		DATETIME,
	IN arg_end_date			DATETIME,
	IN arg_type				CHAR(1)
)
    SQL SECURITY INVOKER
label_0:
BEGIN
	-- =====================================================================================
	-- 各个状态统计: X 取消;I 在住;O 退房;H 自用;C 免费;D 删除;N 未抵;Z 钟点房;T 当日抵离 
	-- 
	-- 作者：zhangh
	-- =====================================================================================
	DROP TEMPORARY TABLE IF EXISTS tmp_reserve_status;
	CREATE TEMPORARY TABLE tmp_reserve_status(
		accnt 				BIGINT(16) NOT NULL COMMENT 'master_base.id ',
		master_id 			BIGINT(16) NOT NULL COMMENT '用来标记同住，没有同住则填充自己id',
		name 				VARCHAR(80) NOT NULL DEFAULT '',
		grp_accnt 			BIGINT(16) NOT NULL DEFAULT '0',
		grpname 			VARCHAR(100) NOT NULL DEFAULT '',
		company_id 			BIGINT(16) NOT NULL,
		agent_id 			BIGINT(16) NOT NULL,
		source_id 			BIGINT(16) NOT NULL,
		arr 				DATETIME NOT NULL,
		dep 				DATETIME NOT NULL,
		rmtype 				VARCHAR(10) NOT NULL,
		rmno 				VARCHAR(10) NOT NULL,
		real_rate 			DECIMAL(8,2) NOT NULL DEFAULT '0.00',
		ratecode 			VARCHAR(20) NOT NULL DEFAULT '',
		market 				VARCHAR(10) NOT NULL DEFAULT '',
		src 				VARCHAR(10) NOT NULL DEFAULT '',
		rsv_type 			VARCHAR(10) NOT NULL DEFAULT '',
		channel 			VARCHAR(10) NOT NULL DEFAULT '',
		rmnum				INT,
		gstno				INT,
		vip 				VARCHAR(6) NOT NULL DEFAULT '',
		dsc_reason 			VARCHAR(10) NOT NULL DEFAULT '',
		card_id 			BIGINT(16) DEFAULT NULL,
		salesman 			VARCHAR(10) NOT NULL DEFAULT '',
		remark 				VARCHAR(512) NOT NULL DEFAULT '',
		KEY index1 (accnt),
		KEY index2 (company_id),
		KEY index3 (agent_id),
		KEY index4 (source_id)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;

		IF arg_type = 'N' THEN	-- 未抵
			INSERT INTO tmp_reserve_status(accnt,master_id,name,grp_accnt,grpname,company_id,agent_id,source_id,arr,dep,
				rmtype,rmno,real_rate,ratecode,market,src,rsv_type,channel,rmnum,gstno,vip,dsc_reason,card_id,salesman,remark)
			SELECT a.id,a.master_id,b.name,a.grp_accnt,IFNULL(c.name,''),a.company_id,a.agent_id,a.source_id,a.arr,a.dep,
				a.rmtype,a.rmno,a.real_rate,a.ratecode,a.market,a.src,a.rsv_type,a.channel,a.rmnum,a.adult+a.children,b.vip,a.dsc_reason,a.inner_card_id,a.salesman,a.remark
				FROM master_base a LEFT JOIN master_guest c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.grp_accnt=c.id
				,master_guest b
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.id AND a.sta = 'N'
				AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.biz_date >= arg_begin_date AND a.biz_date <= arg_end_date
			UNION ALL
			SELECT a.id,a.master_id,b.name,a.grp_accnt,IFNULL(c.name,''),a.company_id,a.agent_id,a.source_id,a.arr,a.dep,
				a.rmtype,a.rmno,a.real_rate,a.ratecode,a.market,a.src,a.rsv_type,a.channel,a.rmnum,a.adult+a.children,b.vip,a.dsc_reason,a.inner_card_id,a.salesman,a.remark
				FROM master_base_history a LEFT JOIN master_guest_history c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.grp_accnt=c.id
				,master_guest_history b
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.id AND a.sta = 'N'
				AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.biz_date >= arg_begin_date AND a.biz_date <= arg_end_date;
		ELSEIF arg_type = 'X' THEN	-- 取消
			INSERT INTO tmp_reserve_status(accnt,master_id,name,grp_accnt,grpname,company_id,agent_id,source_id,arr,dep,
				rmtype,rmno,real_rate,ratecode,market,src,rsv_type,channel,rmnum,gstno,vip,dsc_reason,card_id,salesman,remark)
			SELECT a.id,a.master_id,b.name,a.grp_accnt,IFNULL(c.name,''),a.company_id,a.agent_id,a.source_id,a.arr,a.dep,
				a.rmtype,a.rmno,a.real_rate,a.ratecode,a.market,a.src,a.rsv_type,a.channel,a.rmnum,a.adult+a.children,b.vip,a.dsc_reason,a.inner_card_id,a.salesman,a.remark
				FROM master_base a LEFT JOIN master_guest c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.grp_accnt=c.id
				,master_guest b
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.id AND a.sta = 'X'
				AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.biz_date >= arg_begin_date AND a.biz_date <= arg_end_date
			UNION ALL
			SELECT a.id,a.master_id,b.name,a.grp_accnt,IFNULL(c.name,''),a.company_id,a.agent_id,a.source_id,a.arr,a.dep,
				a.rmtype,a.rmno,a.real_rate,a.ratecode,a.market,a.src,a.rsv_type,a.channel,a.rmnum,a.adult+a.children,b.vip,a.dsc_reason,a.inner_card_id,a.salesman,a.remark
				FROM master_base_history a LEFT JOIN master_guest_history c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.grp_accnt=c.id
				,master_guest_history b
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.id AND a.sta = 'X'
				AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.biz_date >= arg_begin_date AND a.biz_date <= arg_end_date;
		ELSEIF arg_type = 'D' THEN	-- 删除
			INSERT INTO tmp_reserve_status(accnt,master_id,name,grp_accnt,grpname,company_id,agent_id,source_id,arr,dep,
				rmtype,rmno,real_rate,ratecode,market,src,rsv_type,channel,rmnum,gstno,vip,dsc_reason,card_id,salesman,remark)
			SELECT a.id,a.master_id,b.name,a.grp_accnt,IFNULL(c.name,''),a.company_id,a.agent_id,a.source_id,a.arr,a.dep,
				a.rmtype,a.rmno,a.real_rate,a.ratecode,a.market,a.src,a.rsv_type,a.channel,a.rmnum,a.adult+a.children,b.vip,a.dsc_reason,a.inner_card_id,a.salesman,a.remark
				FROM master_base a LEFT JOIN master_guest c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.grp_accnt=c.id
				,master_guest b
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.id AND a.sta = 'D'
				AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.biz_date >= arg_begin_date AND a.biz_date <= arg_end_date
			UNION ALL
			SELECT a.id,a.master_id,b.name,a.grp_accnt,IFNULL(c.name,''),a.company_id,a.agent_id,a.source_id,a.arr,a.dep,
				a.rmtype,a.rmno,a.real_rate,a.ratecode,a.market,a.src,a.rsv_type,a.channel,a.rmnum,a.adult+a.children,b.vip,a.dsc_reason,a.inner_card_id,a.salesman,a.remark
				FROM master_base_history a LEFT JOIN master_guest_history c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.grp_accnt=c.id
				,master_guest_history b
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.id AND a.sta = 'D'
				AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND a.biz_date >= arg_begin_date AND a.biz_date <= arg_end_date;
		ELSEIF arg_type = 'I' THEN	-- 在住
			INSERT INTO tmp_reserve_status(accnt,master_id,name,grp_accnt,grpname,company_id,agent_id,source_id,arr,dep,
				rmtype,rmno,real_rate,ratecode,market,src,rsv_type,channel,rmnum,gstno,vip,dsc_reason,card_id,salesman,remark)
			SELECT a.id,a.master_id,b.name,a.grp_accnt,IFNULL(c.name,''),a.company_id,a.agent_id,a.source_id,a.arr,a.dep,
				a.rmtype,a.rmno,a.real_rate,a.ratecode,a.market,a.src,a.rsv_type,a.channel,a.rmnum,a.adult+a.children,b.vip,a.dsc_reason,a.inner_card_id,a.salesman,a.remark
				FROM master_base a LEFT JOIN master_guest c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.grp_accnt=c.id
				,master_guest b
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.id AND a.sta IN ('I','S','O') AND a.id<>a.rsv_id
				AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND DATEDIFF(arg_begin_date,a.dep) <0 AND DATEDIFF(arg_end_date,a.arr) >= 0
			UNION ALL
			SELECT a.id,a.master_id,b.name,a.grp_accnt,IFNULL(c.name,''),a.company_id,a.agent_id,a.source_id,a.arr,a.dep,
				a.rmtype,a.rmno,a.real_rate,a.ratecode,a.market,a.src,a.rsv_type,a.channel,a.rmnum,a.adult+a.children,b.vip,a.dsc_reason,a.inner_card_id,a.salesman,a.remark
				FROM master_base_history a LEFT JOIN master_guest_history c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.grp_accnt=c.id
				,master_guest_history b
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.id AND a.sta = 'O' AND a.id<>a.rsv_id
				AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND DATEDIFF(arg_begin_date,a.dep) <0 AND DATEDIFF(arg_end_date,a.arr) >= 0;
		ELSEIF arg_type = 'O' THEN	-- 退房
			INSERT INTO tmp_reserve_status(accnt,master_id,name,grp_accnt,grpname,company_id,agent_id,source_id,arr,dep,
				rmtype,rmno,real_rate,ratecode,market,src,rsv_type,channel,rmnum,gstno,vip,dsc_reason,card_id,salesman,remark)
			SELECT a.id,a.master_id,b.name,a.grp_accnt,IFNULL(c.name,''),a.company_id,a.agent_id,a.source_id,a.arr,a.dep,
				a.rmtype,a.rmno,a.real_rate,a.ratecode,a.market,a.src,a.rsv_type,a.channel,a.rmnum,a.adult+a.children,b.vip,a.dsc_reason,a.inner_card_id,a.salesman,a.remark
				FROM master_base a LEFT JOIN master_guest c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.grp_accnt=c.id
				,master_guest b
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.id AND a.sta IN ('I','O','S') AND a.id<>a.rsv_id
				AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND DATEDIFF(a.dep,arg_begin_date) >=0 AND DATEDIFF(arg_end_date,a.dep) >= 0
			UNION ALL
			SELECT a.id,a.master_id,b.name,a.grp_accnt,IFNULL(c.name,''),a.company_id,a.agent_id,a.source_id,a.arr,a.dep,
				a.rmtype,a.rmno,a.real_rate,a.ratecode,a.market,a.src,a.rsv_type,a.channel,a.rmnum,a.adult+a.children,b.vip,a.dsc_reason,a.inner_card_id,a.salesman,a.remark
				FROM master_base_history a LEFT JOIN master_guest_history c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.grp_accnt=c.id
				,master_guest_history b
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.id AND a.sta = 'O' AND a.id<>a.rsv_id
				AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND DATEDIFF(a.dep,arg_begin_date) >=0 AND DATEDIFF(arg_end_date,a.dep) >= 0;
		ELSEIF arg_type = 'T' THEN	-- 当日抵离
			INSERT INTO tmp_reserve_status(accnt,master_id,name,grp_accnt,grpname,company_id,agent_id,source_id,arr,dep,
				rmtype,rmno,real_rate,ratecode,market,src,rsv_type,channel,rmnum,gstno,vip,dsc_reason,card_id,salesman,remark)
			SELECT a.id,a.master_id,b.name,a.grp_accnt,IFNULL(c.name,''),a.company_id,a.agent_id,a.source_id,a.arr,a.dep,
				a.rmtype,a.rmno,a.real_rate,a.ratecode,a.market,a.src,a.rsv_type,a.channel,a.rmnum,a.adult+a.children,b.vip,a.dsc_reason,a.inner_card_id,a.salesman,a.remark
				FROM master_base a LEFT JOIN master_guest c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.grp_accnt=c.id
				,master_guest b
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.id AND a.sta IN ('I','O','S') AND a.id<>a.rsv_id
				AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND DATEDIFF(a.dep,arg_begin_date) >=0 AND DATEDIFF(arg_end_date,a.dep) >= 0 AND DATE(a.arr) =  DATE(a.dep)
			UNION ALL
			SELECT a.id,a.master_id,b.name,a.grp_accnt,IFNULL(c.name,''),a.company_id,a.agent_id,a.source_id,a.arr,a.dep,
				a.rmtype,a.rmno,a.real_rate,a.ratecode,a.market,a.src,a.rsv_type,a.channel,a.rmnum,a.adult+a.children,b.vip,a.dsc_reason,a.inner_card_id,a.salesman,a.remark
				FROM master_base_history a LEFT JOIN master_guest_history c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.grp_accnt=c.id
				,master_guest_history b
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.id AND a.sta = 'O' AND a.id<>a.rsv_id
				AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND DATEDIFF(a.dep,arg_begin_date) >=0 AND DATEDIFF(arg_end_date,a.dep) >= 0 AND DATE(a.arr) =  DATE(a.dep);				
		ELSEIF arg_type = 'H' THEN	-- 自用房
			INSERT INTO tmp_reserve_status(accnt,master_id,name,grp_accnt,grpname,company_id,agent_id,source_id,arr,dep,
				rmtype,rmno,real_rate,ratecode,market,src,rsv_type,channel,rmnum,gstno,vip,dsc_reason,card_id,salesman,remark)
			SELECT a.id,a.master_id,b.name,a.grp_accnt,IFNULL(c.name,''),a.company_id,a.agent_id,a.source_id,a.arr,a.dep,
				a.rmtype,a.rmno,a.real_rate,a.ratecode,a.market,a.src,a.rsv_type,a.channel,a.rmnum,a.adult+a.children,b.vip,a.dsc_reason,a.inner_card_id,a.salesman,a.remark
				FROM master_base a LEFT JOIN master_guest c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.grp_accnt=c.id
				,master_guest b
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.id AND a.sta IN ('I','S','O') AND a.id<>a.rsv_id
				AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND DATEDIFF(arg_begin_date,a.dep) <0 AND DATEDIFF(arg_end_date,a.arr) >= 0
				AND a.market IN (SELECT code FROM code_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND parent_code = 'market_code' AND flag = 'HSE')
			UNION ALL
			SELECT a.id,a.master_id,b.name,a.grp_accnt,IFNULL(c.name,''),a.company_id,a.agent_id,a.source_id,a.arr,a.dep,
				a.rmtype,a.rmno,a.real_rate,a.ratecode,a.market,a.src,a.rsv_type,a.channel,a.rmnum,a.adult+a.children,b.vip,a.dsc_reason,a.inner_card_id,a.salesman,a.remark
				FROM master_base_history a LEFT JOIN master_guest_history c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.grp_accnt=c.id
				,master_guest_history b
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.id AND a.sta = 'O' AND a.id<>a.rsv_id
				AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND DATEDIFF(arg_begin_date,a.dep) <0 AND DATEDIFF(arg_end_date,a.arr) >= 0
				AND a.market IN (SELECT code FROM code_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND parent_code = 'market_code' AND flag = 'HSE');
		ELSEIF arg_type = 'Z' THEN	-- 钟点房
			INSERT INTO tmp_reserve_status(accnt,master_id,name,grp_accnt,grpname,company_id,agent_id,source_id,arr,dep,
				rmtype,rmno,real_rate,ratecode,market,src,rsv_type,channel,rmnum,gstno,vip,dsc_reason,card_id,salesman,remark)
			SELECT a.id,a.master_id,b.name,a.grp_accnt,IFNULL(c.name,''),a.company_id,a.agent_id,a.source_id,a.arr,a.dep,
				a.rmtype,a.rmno,a.real_rate,a.ratecode,a.market,a.src,a.rsv_type,a.channel,a.rmnum,a.adult+a.children,b.vip,a.dsc_reason,a.inner_card_id,a.salesman,a.remark
				FROM master_base a LEFT JOIN master_guest c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.grp_accnt=c.id
				,master_guest b
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.id AND a.sta IN ('I','S','O') AND a.id<>a.rsv_id
				AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND DATEDIFF(arg_begin_date,a.dep) <0 AND DATEDIFF(arg_end_date,a.arr) >= 0
				AND a.market IN (SELECT code FROM code_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND parent_code = 'market_code' AND flag = 'HRS')
			UNION ALL
			SELECT a.id,a.master_id,b.name,a.grp_accnt,IFNULL(c.name,''),a.company_id,a.agent_id,a.source_id,a.arr,a.dep,
				a.rmtype,a.rmno,a.real_rate,a.ratecode,a.market,a.src,a.rsv_type,a.channel,a.rmnum,a.adult+a.children,b.vip,a.dsc_reason,a.inner_card_id,a.salesman,a.remark
				FROM master_base_history a LEFT JOIN master_guest_history c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.grp_accnt=c.id
				,master_guest_history b
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.id AND a.sta = 'O' AND a.id<>a.rsv_id
				AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND DATEDIFF(arg_begin_date,a.dep) <0 AND DATEDIFF(arg_end_date,a.arr) >= 0
				AND a.market IN (SELECT code FROM code_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND parent_code = 'market_code' AND flag = 'HRS');
		ELSEIF arg_type = 'C' THEN	-- 免费房
			INSERT INTO tmp_reserve_status(accnt,master_id,name,grp_accnt,grpname,company_id,agent_id,source_id,arr,dep,
				rmtype,rmno,real_rate,ratecode,market,src,rsv_type,channel,rmnum,gstno,vip,dsc_reason,card_id,salesman,remark)
			SELECT a.id,a.master_id,b.name,a.grp_accnt,IFNULL(c.name,''),a.company_id,a.agent_id,a.source_id,a.arr,a.dep,
				a.rmtype,a.rmno,a.real_rate,a.ratecode,a.market,a.src,a.rsv_type,a.channel,a.rmnum,a.adult+a.children,b.vip,a.dsc_reason,a.inner_card_id,a.salesman,a.remark
				FROM master_base a LEFT JOIN master_guest c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.grp_accnt=c.id
				,master_guest b
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.id AND a.sta IN ('I','S','O') AND a.id<>a.rsv_id
				AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND DATEDIFF(arg_begin_date,a.dep) <0 AND DATEDIFF(arg_end_date,a.arr) >= 0
				AND a.market IN (SELECT code FROM code_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND parent_code = 'market_code' AND flag = 'COM')
			UNION ALL
			SELECT a.id,a.master_id,b.name,a.grp_accnt,IFNULL(c.name,''),a.company_id,a.agent_id,a.source_id,a.arr,a.dep,
				a.rmtype,a.rmno,a.real_rate,a.ratecode,a.market,a.src,a.rsv_type,a.channel,a.rmnum,a.adult+a.children,b.vip,a.dsc_reason,a.inner_card_id,a.salesman,a.remark
				FROM master_base_history a LEFT JOIN master_guest_history c ON c.hotel_group_id = arg_hotel_group_id AND c.hotel_id = arg_hotel_id AND a.grp_accnt=c.id
				,master_guest_history b
				WHERE a.hotel_group_id = arg_hotel_group_id AND a.hotel_id = arg_hotel_id AND a.id = b.id AND a.sta = 'O' AND a.id<>a.rsv_id
				AND b.hotel_group_id = arg_hotel_group_id AND b.hotel_id = arg_hotel_id AND DATEDIFF(arg_begin_date,a.dep) <0 AND DATEDIFF(arg_end_date,a.arr) >= 0
				AND a.market IN (SELECT code FROM code_base WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND parent_code = 'market_code' AND flag = 'COM');		
		END IF;


		SELECT a.accnt,a.rmno,a.rmtype,a.name,a.arr,a.dep,a.real_rate,a.ratecode,a.rmnum,a.gstno,a.master_id,
		CONCAT(a.grpname,'/',IFNULL(c.name,''),IFNULL(d.name,''),IFNULL(e.name,'')) AS grpname,a.remark,IFNULL(f.descript,'') AS reasondes 
			FROM tmp_reserve_status a 
			LEFT JOIN company_base c ON c.hotel_group_id = arg_hotel_group_id AND c.id = a.company_id
			LEFT JOIN company_base d ON d.hotel_group_id = arg_hotel_group_id AND d.id = a.agent_id
			LEFT JOIN company_base e ON e.hotel_group_id = arg_hotel_group_id AND e.id = a.source_id
			LEFT JOIN code_reason f ON f.hotel_group_id = arg_hotel_group_id AND f.hotel_id = arg_hotel_id AND f.code = a.dsc_reason
			;
		
		DROP TEMPORARY TABLE IF EXISTS tmp_reserve_status;
END$$

DELIMITER ;