	DROP TABLE hmaster_new;
	CREATE TABLE hmaster_new (
	   id 		BIGINT(16) NOT NULL AUTO_INCREMENT,
	   accnt	CHAR(12),
	  PRIMARY KEY (id),
	  KEY index1(accnt)
	 ) ENGINE=INNODB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8 COMMENT='历史主单newid';
	INSERT INTO hmaster_new(accnt)
	SELECT accnt FROM migrate_xmyh.hmaster1;
	SELECT * FROM hmaster_new ORDER BY id;
	
	SELECT COUNT(1) FROM hmaster1;
	-- 增加相关字段
	ALTER TABLE migrate_xmyh.hmaster1 ADD c_id BIGINT(16) NOT NULL DEFAULT 0;
	ALTER TABLE migrate_xmyh.hmaster1 ADD a_id BIGINT(16) NOT NULL DEFAULT 0;
	ALTER TABLE migrate_xmyh.hmaster1 ADD s_id BIGINT(16) NOT NULL DEFAULT 0;
	ALTER TABLE migrate_xmyh.hmaster1 ADD h_id BIGINT(16);
	ALTER TABLE migrate_xmyh.hmaster1 ADD m_id BIGINT(16);
	ALTER TABLE migrate_xmyh.hmaster1 ADD l_id BIGINT(16);
	ALTER TABLE migrate_xmyh.hmaster1 ADD new_id BIGINT(16);
	-- 增加索引
	CREATE INDEX cusno 	ON migrate_xmyh.hmaster1(cusno);
	CREATE INDEX agent 	ON migrate_xmyh.hmaster1(agent);
	CREATE INDEX source 	ON migrate_xmyh.hmaster1(source);
-- 	CREATE INDEX accnt 	ON migrate_xmyh.hmaster1(accnt);
	CREATE INDEX haccnt 	ON migrate_xmyh.hmaster1(haccnt);
	CREATE INDEX MASTER 	ON migrate_xmyh.hmaster1(MASTER);
	CREATE INDEX pcrec 	ON migrate_xmyh.hmaster1(pcrec);
	CREATE INDEX logmark ON migrate_xmyh.hmaster1(logmark);
	-- 协议单位 订房中心 旅行社 新的账号
	UPDATE migrate_xmyh.hmaster1 a,portal_tr.up_map_accnt b SET a.c_id=b.accnt_new WHERE a.cusno=b.accnt_old AND b.accnt_type='COMPANY' AND b.hotel_group_id = 1 AND b.hotel_id=1 AND b.accnt_class='C';   -- 协议公司 
	UPDATE migrate_xmyh.hmaster1 a,portal_tr.up_map_accnt b SET a.a_id=b.accnt_new WHERE a.agent=b.accnt_old AND b.accnt_type='COMPANY' AND b.hotel_group_id = 1 AND b.hotel_id=1 AND b.accnt_class='A';   -- 旅行社 
	UPDATE migrate_xmyh.hmaster1 a,portal_tr.up_map_accnt b SET a.s_id=b.accnt_new WHERE a.source=b.accnt_old AND b.accnt_type='COMPANY'AND b.hotel_group_id = 1  AND b.hotel_id=1 AND b.accnt_class='S';  -- 订房中心  
	UPDATE migrate_xmyh.hmaster1 a,portal_tr.up_map_accnt b SET a.h_id=b.accnt_new WHERE a.haccnt=b.accnt_old AND b.accnt_type='GUEST_FIT' AND b.hotel_group_id = 1 AND b.hotel_id=1 ;
	UPDATE migrate_xmyh.hmaster1 a,portal_tr.up_map_accnt b SET a.h_id=b.accnt_new WHERE a.haccnt=b.accnt_old AND b.accnt_type='GUEST_GRP' AND b.hotel_group_id = 1 AND b.hotel_id=1 ;

	-- 代码对照
	UPDATE migrate_xmyh.hmaster1 a,up_map_code b SET a.paycode = b.code_new WHERE b.hotel_group_id=1 AND b.hotel_id = 1 AND b.code = 'paymth' AND b.code_old = a.paycode ; 
	UPDATE migrate_xmyh.hmaster1 a,up_map_code b SET a.market = b.code_new WHERE b.hotel_group_id=1 AND b.hotel_id = 1 AND b.code = 'mktcode' AND b.code_old = a.market ; 
	UPDATE migrate_xmyh.hmaster1 a,up_map_code b SET a.src = b.code_new WHERE b.hotel_group_id=1 AND b.hotel_id = 1 AND b.code = 'srccode' AND b.code_old = a.src ; 
	UPDATE migrate_xmyh.hmaster1 a,up_map_code b SET a.channel = b.code_new WHERE b.hotel_group_id=1 AND b.hotel_id = 1 AND b.code = 'channel' AND b.code_old = a.channel ; 
	UPDATE migrate_xmyh.hmaster1 a,up_map_code b SET a.restype = b.code_new WHERE b.hotel_group_id=1 AND b.hotel_id = 1 AND b.code = 'rsv_type' AND b.code_old = a.restype ; 
	UPDATE migrate_xmyh.hmaster1 a,up_map_code b SET a.rtreason = b.code_new WHERE b.hotel_group_id=1 AND b.hotel_id = 1 AND b.code = 'code_reason' AND b.code_old = a.rtreason  ;
	UPDATE migrate_xmyh.hmaster1 a,up_map_code b SET a.up_reason = b.code_new WHERE b.hotel_group_id=1 AND b.hotel_id = 1 AND b.code = 'upgrade' AND b.code_old = a.up_reason;
	
	SELECT MAX(id) FROM master_base;
	-- 12818+10000
	SELECT * FROM migrate_xmyh.hmaster1 WHERE h_id IS NOT NULL AND logmark = 0;
	
	SELECT * FROM hmaster_new WHERE accnt = 'F307020122';
	UPDATE migrate_xmyh.hmaster1 a,hmaster_new b SET a.new_id = b.id WHERE a.accnt = b.accnt;
	SELECT * FROM migrate_xmyh.hmaster1 WHERE accnt = 'F307020122';
	SELECT * FROM migrate_xmyh.hmaster1 WHERE accnt = 'F307020122';

	SELECT 81201+22818;
	SELECT * FROM master_base_history;
	SELECT * FROM master_guest_history;
	SELECT * FROM migrate_xmyh.hmaster1 WHERE sta = 'O' AND pcrec <> '';

