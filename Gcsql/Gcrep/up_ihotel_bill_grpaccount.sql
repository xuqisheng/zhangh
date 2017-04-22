DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_bill_grpaccount`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_bill_grpaccount`(
		IN arg_hotel_group_id	INT,
        IN arg_hotel_id			INT,
        IN arg_begindate		DATETIME,
        IN arg_enddate			DATETIME,
        IN arg_grp_accnt		INT,     -- 团队账号
        IN arg_billflag			CHAR(1), -- 账单类型 1 按项目 2 按房号 3 按日期
        IN arg_accountflag		CHAR(1), -- 账务类型 1 所有   2 主单   3 成员
        IN arg_outstanding		CHAR(1), -- 账目类型 末结账目
        IN arg_hasBeen			CHAR(1), -- 账目类型 已结账目
        IN arg_expect			CHAR(1)	 -- 账目类型 预计 
		)
    SQL SECURITY INVOKER
label_0:
    BEGIN
    -- *******************************************
	-- 团体结算单计算过程
	-- CALL up_ihotel_bill_grpaccount(1,104,'2014-01-01','2014-10-15','1397390','3','1','1','1','')
	-- 作者:zhangh
	-- *******************************************	
		DECLARE var_grp_name		VARCHAR(52) ;
		
		IF NOT EXISTS(SELECT 1 FROM master_guest WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND id = arg_grp_accnt) THEN
			SET var_grp_name = IFNULL((SELECT name FROM master_guest_history WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND id = arg_grp_accnt),'');
		ELSE
			SET var_grp_name = IFNULL((SELECT name FROM master_guest WHERE hotel_group_id = arg_hotel_group_id AND hotel_id = arg_hotel_id AND id = arg_grp_accnt),'');		
		END IF;

		DROP TEMPORARY TABLE IF EXISTS tmp_grpmaster;
		CREATE TEMPORARY TABLE tmp_grpmaster
		(
			hotel_group_id  INT,
			hotel_id   		INT,
			grp_accnt  		BIGINT(16) NOT NULL,
			accnt      		BIGINT(16) NOT NULL,
			master_id      	BIGINT(16) NOT NULL,
			class     		VARCHAR(2) NULL,
			rmno        	VARCHAR(10) NOT NULL DEFAULT '',
			rmtype        	VARCHAR(20) NULL ,
			real_rate  		DECIMAL(12,2) NOT NULL DEFAULT '0.00',  
			arr       		DATETIME,
			dep       		DATETIME,
			sta          	VARCHAR(1) NOT NULL DEFAULT '',
			KEY index1 (hotel_group_id,hotel_id,accnt),
			KEY index2 (hotel_group_id,hotel_id,grp_accnt)
			 );   
		 
		IF arg_accountflag = '1' THEN		-- 所有账务
			INSERT INTO tmp_grpmaster (hotel_group_id,hotel_id,grp_accnt,accnt,master_id,class,rmno,rmtype,real_rate,arr,dep,sta) 
				SELECT hotel_group_id,hotel_id,grp_accnt,id,master_id,rsv_class,rmno,rmtype,real_rate,arr,dep,sta FROM master_base WHERE grp_accnt = arg_grp_accnt AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
			
			INSERT INTO tmp_grpmaster (hotel_group_id,hotel_id,grp_accnt,accnt,master_id,class,rmno,rmtype,real_rate,arr,dep,sta) 
				SELECT hotel_group_id,hotel_id,grp_accnt,id,master_id,rsv_class,rmno,rmtype,real_rate,arr,dep,sta FROM master_base_history WHERE grp_accnt = arg_grp_accnt AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;

		ELSEIF arg_accountflag ='2' THEN	-- 团队主单
			INSERT INTO tmp_grpmaster  (hotel_group_id,hotel_id,grp_accnt,master_id,accnt,class,rmno,rmtype,real_rate,arr,dep,sta) 
				SELECT hotel_group_id,hotel_id,grp_accnt,id,master_id,rsv_class,rmno,rmtype,real_rate,arr,dep,sta FROM master_base WHERE id = arg_grp_accnt AND rsv_class='G' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;

			INSERT INTO tmp_grpmaster  (hotel_group_id,hotel_id,grp_accnt,accnt,master_id,class,rmno,rmtype,real_rate,arr,dep,sta) 
				SELECT hotel_group_id,hotel_id,grp_accnt,id,master_id,rsv_class,rmno,rmtype,real_rate,arr,dep,'',sta FROM master_base_history WHERE id = arg_grp_accnt AND rsv_class='G' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;

		ELSEIF arg_accountflag ='3' THEN	-- 团队成员
			INSERT INTO tmp_grpmaster (hotel_group_id,hotel_id,grp_accnt,accnt,master_id,class,rmno,rmtype,real_rate,arr,dep,sta)  
				SELECT hotel_group_id,hotel_id,grp_accnt,id,master_id,rsv_class,rmno,rmtype,real_rate,arr,dep,sta FROM master_base WHERE grp_accnt = arg_grp_accnt AND rsv_class='F' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
				 
			INSERT INTO tmp_grpmaster (hotel_group_id,hotel_id,grp_accnt,accnt,master_id,class,rmno,rmtype,real_rate,arr,dep,sta)  
				SELECT hotel_group_id,hotel_id,grp_accnt,id,master_id,rsv_class,rmno,rmtype,real_rate,arr,dep,sta FROM master_base_history WHERE grp_accnt = arg_grp_accnt AND rsv_class='F' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
		END IF ;        
		 
		DROP TEMPORARY TABLE IF EXISTS tmp_grpaccount;
		CREATE TEMPORARY TABLE tmp_grpaccount
		(
			hotel_group_id  INT,
			hotel_id   		INT,
			accnt      		BIGINT(16) NOT NULL,
			biz_date      	DATETIME  ,
			ta_code     	VARCHAR(10)  NOT NULL DEFAULT '',
			ta_descript 	VARCHAR(20)  NOT NULL DEFAULT '',
			arrange_code	VARCHAR(20)  NOT NULL DEFAULT '',
			category_code	VARCHAR(20)  NOT NULL DEFAULT '',
			cat_sum			VARCHAR(20)  NOT NULL DEFAULT '',
			rmno        	VARCHAR(10)  NOT NULL DEFAULT '',
			rmtype     		VARCHAR(20)  NULL,
			rmtype_name     VARCHAR(20)  NULL,
			charge      	DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			pay          	DECIMAL(12,2) NOT NULL DEFAULT '0.00', 
			market       	VARCHAR(10)  NOT NULL DEFAULT '',
			close_flag   	VARCHAR(1)   NOT NULL  DEFAULT '',
			flag         	VARCHAR(4)   NOT NULL DEFAULT '',       
			KEY index1 (hotel_group_id,hotel_id,accnt),
			KEY index2 (hotel_group_id,hotel_id,ta_code),
			KEY index3 (hotel_group_id,hotel_id,flag)
			 ); 
			 
		 IF arg_outstanding = '1' THEN   -- 未结账务  
			INSERT INTO tmp_grpaccount 
				SELECT hotel_group_id,hotel_id,a.accnt,a.biz_date,a.ta_code,a.ta_descript,a.arrange_code,'','',a.rmno,'','',a.charge,a.pay,a.market,a.close_flag,'是' FROM account a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND (a.close_flag ='' OR a.close_flag IS NULL) AND a.biz_date >= arg_begindate AND a.biz_date <= arg_enddate AND EXISTS (SELECT 1 FROM tmp_grpmaster b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.accnt=b.accnt);
			INSERT INTO tmp_grpaccount 
				SELECT hotel_group_id,hotel_id,a.accnt,a.biz_date,a.ta_code,a.ta_descript,a.arrange_code,'','',a.rmno,'','',a.charge,a.pay,a.market,a.close_flag,'是' FROM account_history a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND (a.close_flag ='' OR a.close_flag IS NULL) AND a.biz_date >= arg_begindate AND a.biz_date <= arg_enddate AND EXISTS (SELECT 1 FROM tmp_grpmaster b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.accnt=b.accnt);      
		END IF ; 
		 
		IF arg_hasBeen = '1' THEN	-- 已结账务
			INSERT INTO tmp_grpaccount 
				SELECT hotel_group_id,hotel_id,a.accnt,a.biz_date,a.ta_code,a.ta_descript,a.arrange_code,'','',a.rmno,'','',a.charge,a.pay,a.market,a.close_flag,'是' FROM account a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.close_flag ='B' AND EXISTS (SELECT 1 FROM tmp_grpmaster b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.accnt=b.accnt);
			INSERT INTO tmp_grpaccount
				SELECT hotel_group_id,hotel_id,a.accnt,a.biz_date,a.ta_code,a.ta_descript,a.arrange_code,'','',a.rmno,'','',a.charge,a.pay,a.market,a.close_flag,'是' FROM account_history a WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND a.close_flag ='B' AND EXISTS (SELECT 1 FROM tmp_grpmaster b WHERE b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.accnt=b.accnt);
		END IF ;		
		
		UPDATE tmp_grpaccount a,code_transaction b SET a.category_code = b.category_code WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.ta_code=b.code;
		UPDATE tmp_grpaccount a,code_transaction b SET a.cat_sum = b.cat_sum WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.ta_code=b.code;
		
		UPDATE tmp_grpaccount a,room_no b SET a.rmtype=b.rmtype WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.rmno = b.code;      
		UPDATE tmp_grpaccount a,room_type b SET a.rmtype_name=b.descript WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.rmtype = b.code;
		UPDATE tmp_grpaccount a SET a.rmtype_name ='主单' WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND (a.rmno IS NULL OR a.rmno ='') AND a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id;      

		DELETE FROM tmp_grpaccount WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND ta_code='9';
		
		IF arg_billflag  ='1'  THEN		-- 按项目统计
			DROP TEMPORARY TABLE IF EXISTS tmp_grpaccount1;
			CREATE TEMPORARY TABLE tmp_grpaccount1
			(
				hotel_group_id  INT,
				hotel_id   		INT,
				biz_date    	DATETIME,
				ta_type			CHAR(1),
				ta_code     	VARCHAR(10)  NOT NULL DEFAULT '',
				ta_desc			VARCHAR(50)  NOT NULL DEFAULT '',
				ta_num      	INT,
				charge      	DECIMAL(12,2) NOT NULL DEFAULT '0.00',
				pay          	DECIMAL(12,2) NOT NULL DEFAULT '0.00', 
				grp_name     	VARCHAR(50) NULL,	
				KEY index1 (hotel_group_id,hotel_id,biz_date,ta_code)
				); 
		
		INSERT INTO tmp_grpaccount1 SELECT hotel_group_id,hotel_id,biz_date,'A',arrange_code,'',COUNT(1),SUM(charge),SUM(pay),'' FROM tmp_grpaccount WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arrange_code < '9' GROUP BY biz_date,arrange_code;
		INSERT INTO tmp_grpaccount1 SELECT hotel_group_id,hotel_id,biz_date,'B',category_code,'',COUNT(1),SUM(charge),SUM(pay),'' FROM tmp_grpaccount WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arrange_code > '9' GROUP BY biz_date,category_code;		
		
		UPDATE tmp_grpaccount1 a,code_base b SET a.ta_desc = b.descript WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.ta_type='A' AND a.ta_code=b.code AND b.parent_code='arrangement_bill';
		UPDATE tmp_grpaccount1 a,code_base b SET a.ta_desc = b.descript WHERE a.hotel_group_id=arg_hotel_group_id AND a.hotel_id=arg_hotel_id AND b.hotel_group_id=arg_hotel_group_id AND b.hotel_id=arg_hotel_id AND a.ta_type='B' AND a.ta_code=b.code AND b.parent_code='payment_category';		
		UPDATE tmp_grpaccount1 SET grp_name = var_grp_name WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;
		
		SELECT biz_date,ta_desc,ta_num,charge,pay,grp_name FROM tmp_grpaccount1 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id ORDER BY biz_date,ta_code;
		
	END IF ;
		
	IF arg_billflag  ='2'  THEN		-- 按房号统计
		DROP TEMPORARY TABLE IF EXISTS  tmp_grpaccount2;
		CREATE TEMPORARY TABLE tmp_grpaccount2
		(
			hotel_group_id  INT,
			hotel_id   		INT,
			rmno   			VARCHAR(10) NULL DEFAULT '',
			rev_rm			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			rev_fb			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			rev_mt			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			rev_en			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			rev_sp			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			rev_ot			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			pay     		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			balance			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			grp_name    	VARCHAR(50) NULL,
			KEY index1(hotel_group_id,hotel_id,rmno)
			 );
		
		UPDATE tmp_grpaccount SET flag ='rm' WHERE cat_sum='rm' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arrange_code<'9';
		UPDATE tmp_grpaccount SET flag ='fb' WHERE cat_sum='fb' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arrange_code<'9';
		UPDATE tmp_grpaccount SET flag ='mt' WHERE cat_sum='mt' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arrange_code<'9';
		UPDATE tmp_grpaccount SET flag ='en' WHERE cat_sum='en' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arrange_code<'9';
		UPDATE tmp_grpaccount SET flag ='sp' WHERE cat_sum='sp' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arrange_code<'9';
		UPDATE tmp_grpaccount SET flag ='ot' WHERE cat_sum NOT IN ('rm','fb','mt','en','sp') AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arrange_code<'9';		
		
		INSERT INTO tmp_grpaccount2 SELECT hotel_group_id,hotel_id,rmno,SUM(charge),0,0,0,0,0,SUM(pay),0,'' FROM tmp_grpaccount WHERE flag ='rm' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY rmno;
		INSERT INTO tmp_grpaccount2 SELECT hotel_group_id,hotel_id,rmno,0,SUM(charge),0,0,0,0,SUM(pay),0,'' FROM tmp_grpaccount WHERE flag ='fb' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY rmno;		
		INSERT INTO tmp_grpaccount2 SELECT hotel_group_id,hotel_id,rmno,0,0,SUM(charge),0,0,0,SUM(pay),0,'' FROM tmp_grpaccount WHERE flag ='mt' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY rmno;		
		INSERT INTO tmp_grpaccount2 SELECT hotel_group_id,hotel_id,rmno,0,0,0,SUM(charge),0,0,SUM(pay),0,'' FROM tmp_grpaccount WHERE flag ='en' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY rmno;
		INSERT INTO tmp_grpaccount2 SELECT hotel_group_id,hotel_id,rmno,0,0,0,0,SUM(charge),0,SUM(pay),0,'' FROM tmp_grpaccount WHERE flag ='sp' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY rmno;			
 		INSERT INTO tmp_grpaccount2 SELECT hotel_group_id,hotel_id,rmno,0,0,0,0,0,SUM(charge),SUM(pay),0,'' FROM tmp_grpaccount WHERE flag ='ot' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY rmno;	       	

		INSERT INTO tmp_grpaccount2 SELECT hotel_group_id,hotel_id,rmno,0,0,0,0,0,0,-1*SUM(pay),0,'' FROM tmp_grpaccount WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY rmno;

		UPDATE tmp_grpaccount2 SET rmno ='主单' WHERE (rmno IS NULL OR rmno ='') AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;

		UPDATE tmp_grpaccount2 SET grp_name = var_grp_name WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;

		SELECT rmno,SUM(rev_rm) AS rev_rm,SUM(rev_fb) AS rev_fb,SUM(rev_mt) AS rev_mt,SUM(rev_en) AS rev_en,SUM(rev_sp) AS rev_sp,SUM(rev_ot) AS rev_ot,SUM(pay) AS pay,(SUM(rev_rm) +SUM(rev_fb) +SUM(rev_ot) +SUM(pay)) AS balance,grp_name FROM tmp_grpaccount2 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY rmno ORDER BY rmno+0;		
          	 
	END IF ;
			
	IF arg_billflag  ='3'  THEN	-- 按日期统计
		DROP TEMPORARY TABLE IF EXISTS  tmp_account3;
		CREATE TEMPORARY TABLE tmp_grpaccount3
		(
			hotel_group_id  INT,
			hotel_id   		INT,
			biz_date		DATETIME,
			rev_rm			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			rev_fb			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			rev_mt			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			rev_en			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			rev_sp			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			rev_ot			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			pay     		DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			balance			DECIMAL(12,2) NOT NULL DEFAULT '0.00',
			grp_name    	VARCHAR(50) NULL,
			KEY index1(hotel_group_id,hotel_id,biz_date)
			 );

		UPDATE tmp_grpaccount SET flag ='rm' WHERE cat_sum='rm' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arrange_code<'9';
		UPDATE tmp_grpaccount SET flag ='fb' WHERE cat_sum='fb' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arrange_code<'9';
		UPDATE tmp_grpaccount SET flag ='mt' WHERE cat_sum='mt' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arrange_code<'9';
		UPDATE tmp_grpaccount SET flag ='en' WHERE cat_sum='en' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arrange_code<'9';
		UPDATE tmp_grpaccount SET flag ='sp' WHERE cat_sum='sp' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arrange_code<'9';
		UPDATE tmp_grpaccount SET flag ='ot' WHERE cat_sum NOT IN ('rm','fb','mt','en','sp') AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id AND arrange_code<'9';
		
		INSERT INTO tmp_grpaccount3 SELECT hotel_group_id,hotel_id,biz_date,SUM(charge),0,0,0,0,0,SUM(pay),0,'' FROM tmp_grpaccount WHERE flag ='rm' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY biz_date;
		INSERT INTO tmp_grpaccount3 SELECT hotel_group_id,hotel_id,biz_date,0,SUM(charge),0,0,0,0,SUM(pay),0,'' FROM tmp_grpaccount WHERE flag ='fb' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY biz_date;
 		INSERT INTO tmp_grpaccount3 SELECT hotel_group_id,hotel_id,biz_date,0,0,SUM(charge),0,0,0,SUM(pay),0,'' FROM tmp_grpaccount WHERE flag ='mt' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY biz_date;
		INSERT INTO tmp_grpaccount3 SELECT hotel_group_id,hotel_id,biz_date,0,0,0,SUM(charge),0,0,SUM(pay),0,'' FROM tmp_grpaccount WHERE flag ='en' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY biz_date;
		INSERT INTO tmp_grpaccount3 SELECT hotel_group_id,hotel_id,biz_date,0,0,0,0,SUM(charge),0,SUM(pay),0,'' FROM tmp_grpaccount WHERE flag ='sp' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY biz_date;
		INSERT INTO tmp_grpaccount3 SELECT hotel_group_id,hotel_id,biz_date,0,0,0,0,0,SUM(charge),SUM(pay),0,'' FROM tmp_grpaccount WHERE flag ='ot' AND hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY biz_date;    	

		INSERT INTO tmp_grpaccount3 SELECT hotel_group_id,hotel_id,biz_date,0,0,0,0,0,0,-1*SUM(pay),0,'' FROM tmp_grpaccount WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY biz_date;

		UPDATE tmp_grpaccount3 SET grp_name = var_grp_name WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id;

		SELECT biz_date,SUM(rev_rm) AS rev_rm,SUM(rev_fb) AS rev_fb,SUM(rev_mt) AS rev_mt,SUM(rev_en) AS rev_en,SUM(rev_sp) AS rev_sp,SUM(rev_ot) AS rev_ot,SUM(pay) AS pay,(SUM(rev_rm) +SUM(rev_fb) +SUM(rev_ot) +SUM(pay)) AS balance,grp_name FROM tmp_grpaccount3 WHERE hotel_group_id=arg_hotel_group_id AND hotel_id=arg_hotel_id GROUP BY biz_date ORDER BY biz_date;			 
			 
	END IF ;		
	
	 DROP TEMPORARY TABLE IF EXISTS tmp_grpaccount1;	 
	 DROP TEMPORARY TABLE IF EXISTS tmp_grpaccount2;
	 DROP TEMPORARY TABLE IF EXISTS tmp_grpaccount3;
	 DROP TEMPORARY TABLE IF EXISTS tmp_grpaccount;
	 DROP TEMPORARY TABLE IF EXISTS tmp_grpmaster;
	 
END$$

DELIMITER ;