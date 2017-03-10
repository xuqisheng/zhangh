SELECT SUM(charge - pay) FROM master_base_till WHERE hotel_group_id = 2 AND hotel_id = 13;
-- 63663.40

SELECT SUM(charge - pay) FROM account WHERE hotel_group_id = 2 AND hotel_id = 13 AND biz_date <='2016.09.09';
-- 63663.40
SELECT SUM(till_balance) FROM master_snapshot  a WHERE a.hotel_id = 13 AND a.hotel_group_id = 2 AND a.biz_date_begin <'2016.09.09'
AND a.biz_date_end >='2016.09.09' AND a.sta IN('I','S','O','X','R') AND a.master_type<>'armaster';
-- 63663.40

SELECT SUM(charge - pay) FROM ar_master_till WHERE hotel_group_id = 2 AND hotel_id = 13;
-- -146298.05
SELECT SUM(till_balance) FROM master_snapshot  a WHERE a.hotel_id = 13 AND a.hotel_group_id = 2 AND a.biz_date_begin <'2016.09.09'
AND a.biz_date_end >='2016.09.09' AND a.sta IN('I','S','O','X','R') AND a.master_type = 'armaster';
-- -146298.05

	SELECT SUM(b.balance) FROM master_base_till a,zzz b WHERE b.hotel_id = 13 AND b.accnt_type = 'master'
	AND b.accnt = a.id AND a.hotel_group_id = 2 AND a.hotel_id = 13 AND a.rsv_class = 'H'; -- -2317.00

	SELECT SUM(b.balance) FROM master_base_till a,zzz b WHERE b.hotel_id = 13 AND b.accnt_type = 'master'
	AND b.accnt = a.id AND a.hotel_group_id = 2 AND a.hotel_id = 13 AND a.rsv_class = 'F'; -- 65601.40

	SELECT SUM(b.balance) FROM master_base_till a,zzz b WHERE b.hotel_id = 13 AND b.accnt_type = 'master'
	AND b.accnt = a.id AND a.hotel_group_id = 2 AND a.hotel_id = 13 AND a.rsv_class = 'G'; -- 379.00

	SELECT -2317.00 + 65601.40 +  379.00  -- 63663.40

	-- 稽核底表的月报的本日余额是和日报的余额一致,并且是通过上月最后一天的rep_dai_history表的till_bl(即月报的上日余额) 计算出来的。
	SELECT * FROM rep_dai_history WHERE hotel_id = 13 AND biz_date='2016.09.09'
	SELECT * FROM rep_dai_history WHERE hotel_id = 13 AND biz_date='2016.09.09'
	SELECT * FROM rep_jiedai WHERE hotel_id = 13
	-- (余额数对不上以实际的数据为准)
	-- 查询贷方合计宾客和AR till_bl 本日余额   贷方汇总  修复rep_dai的宾客合计和AR合计 '02000','03000'
	SELECT * FROM  rep_dai WHERE hotel_id = 13
	SELECT classno,descript,last_bl,debit,credit,till_bl FROM rep_dai WHERE hotel_id = 13 AND classno IN('02000','03000');
	-- 宾客帐余额
	SELECT * FROM migrate_db.dairep WHERE class IN ('02000','03000');
	SELECT SUM(balance) FROM zzz WHERE hotel_id = 13 AND accnt_type = 'master';  -- 295803.33 = till_bl(rep_dai) 修复金额 
	-- 上日余额(last_bl) + 本日发生 (debit) - 本日收回 (credit) = 本日余额(till_bl)
	SELECT 296877.23    + 284827.81       -   285901.71  --    =   295803.33        (dairep )
	SELECT 296877.23    + 284827.81       -   285901.71  --    =   295803.33        (rep_dai)
	-- 差额1  0 rep_dai(till_bl 修复金额 ) - rep_dai(till_bl) 
	SELECT  1449060.23 - 1448290.17  -- = 770.06	       rep_dai(last_bl) = rep_dai(last_bl) + 差额1
	-- last_bl(rep_dai) = last_bl - 差额1 
	SELECT 1311762.52 - 770.06    -- = 1310992.46(last_bl)
	-- 检查 (rep_dai) 上日余额(last_bl) + 本日发生 (debit) - 本日收回 (credit)
	SELECT 1310992.46 + 234061.71  - 96764.00  -- = 1448290.17
	-- 修改查询出的till_bl字段与第一步算出来的宾客帐和AR的余额 一致
	UPDATE rep_dai a SET till_bl =till_bl - 770.06 WHERE  a.hotel_id = 13 AND a.classno ='02000'
	UPDATE rep_dai a SET last_bl =last_bl - 770.06 WHERE  a.hotel_id = 13 AND a.classno ='02000'

	SELECT * FROM rep_dai_history WHERE hotel_id = 13 AND classno ='02000' AND biz_date='2016-09-09'
	
	-- 月报宾客修复 上月最后一天的till_bl就是本月月报的上日余额数
	SELECT * FROM rep_dai_history WHERE hotel_id = 13 AND biz_date='2015-11-03' AND classno ='02000'		 -- Z till_bl 1817627.48月报本日余额
	SELECT * FROM rep_dai_history WHERE hotel_id = 13 AND biz_date='2016.09.09' AND classno ='02000'  -- Y till_bl 295803.33 月报上日余额 
	-- 逆推  本日月报上的余额是通过计算的出来  需要修复上月最后一日的till_
	-- (2016.09.09 日报本日余额till_bl也是本日月报上日余额) +(2015-10-31 日报本日发生月debitm也是月报本日发生) - (2015-10-31 日报本日收回月credtim也是月报本日收回) = (2015-10-31 日报本日余额till_bl也是月报本日余额)  1448290.17  
	-- 上月最后一日本日余额till_bl(月报上日余额) X +  5947282.57 - 5370150.91 = 1448290.17 (Z)
	-- X(上月最后一天till_bl余额即月报上日余额 2016.09.09) = (2015-09-26) till_bl (本日余额即月报余额） + credtim(本日月收回余额即月报月收回余额) - debitm(本日月发生余额即月报月发生余额)
	SELECT 295803.33 + 2357143.52 - 835319.37  -- = 1817627.48  X为需要修复的上月最后一日的till_bl  X
	SELECT 871158.51  + 5947282.57 - 5370150.91  -- = 1448290.17 
	-- X - Y
	SELECT 843597.56 - 871158.51 		     -- = -27560.95     差额(与上月最后一天的till_bl对比)
	-- till_bl - 差额
	UPDATE rep_dai_history SET till_bl = till_bl - -27560.95 WHERE hotel_id = 13 AND classno ='02000' AND biz_date ='2016.09.09';
	-- ---------------------------------------------
	
	-- AR帐余额
	SELECT classno,descript,last_bl,debit,credit,till_bl FROM rep_dai WHERE hotel_id = 13 AND classno IN('02000','03000');
	
	SELECT SUM(b.charge -b.charge9)-SUM(b.credit-b.credit9) FROM  migrate_db.ar_detail a,migrate_db.ar_account b
	WHERE a.accnt = b.ar_accnt AND a.number = b.ar_inumber AND b.ar_subtotal = 'F'   -- -8688022.44
	
	SELECT * FROM migrate_db.dairep WHERE class IN ('02000','03000');
	SELECT SUM(balance) FROM zzz WHERE hotel_id = 13 AND accnt_type = 'armaster'; -- -146298.05 =till_bl(rep_dai) 修复金额 
	-- 上日余额(last_bl) + 本日发生 (debit) - 本日收回 (credit) = 本日余额(till_bl)
	SELECT -764660.15     +  24605.00    -   32441.48 --  =   -772496.63   (dairep )
	SELECT -764660.15     +  24605.00    -   32441.48 --  =   -772496.63      (rep_dai )
	-- 差额1  0 rep_dai(till_bl 修复金额) - rep_dai(till_bl ) 
	SELECT  -772496.63 - -146298.05  -- = -626198.58	    rep_dai(last_bl) = rep_dai(last_bl) + 差额1
	-- last_bl(rep_dai) = last_bl - 差额1 
	SELECT -9033781.39 - 4950.00    -- = -9038731.39(last_bl)
	-- 检查 (rep_dai) 上日余额(last_bl) + 本日发生 (debit) - 本日收回 (credit)
	SELECT -9038731.39 + 343146.41    -   106767.72   -- =  -8802352.70
	-- 修改查询出的till_bl字段与第一步算出来的宾客帐和AR的余额 一致
	UPDATE rep_dai a SET till_bl =till_bl - -626198.58  WHERE  a.hotel_id = 13 AND a.classno ='03000';
	UPDATE rep_dai a SET last_bl =last_bl - -626198.58  WHERE  a.hotel_id = 13 AND a.classno ='03000';
	
	UPDATE rep_dai_history a SET till_bl =till_bl - -626198.58  WHERE  a.hotel_id = 13 AND a.classno ='03000';
	UPDATE rep_dai_history a SET last_bl =last_bl - -626198.58  WHERE  a.hotel_id = 13 AND a.classno ='03000';
	-- 月报AR修复 上月最后一天的till_bl就是本月月报的上日余额数
	SELECT * FROM rep_dai_history WHERE hotel_id = 13 AND biz_date='2015-10-31'  AND classno ='03000' -- Z till_bl -8749451.48  月报本日余额
	SELECT * FROM rep_dai_history WHERE hotel_id = 13 AND biz_date='2016.09.09' AND classno ='03000'  -- Y till_bl -8802352.70 月报上日余额 
	-- 逆推  本日月报上的余额是通过计算的出来  需要修复上月最后一日的till_
	-- (2016.09.09 日报本日余额till_bl也是本日月报上日余额) +(2015-09-26 日报本日发生月debitm也是月报本日发生) - (2015-09-26 日报本日收回月credtim也是月报本日收回) = (2015-09-26 日报本日余额till_bl也是月报本日余额)  1448290.17  
	-- 上月最后一日本日余额till_bl(月报上日余额) X +  4045325.68 - 2903065.02 = 718714.53 (Z)
	-- X(上月最后一天till_bl余额即月报上日余额 2016.09.09) = (2015-09-26) till_bl (本日余额即月报余额） + credtim(本日月收回余额即月报月收回余额) - debitm(本日月发生余额即月报月发生余额)
	SELECT -8802352.70   + 2235008.02 - 2187056.80  -- = -8754401.48  X为需要修复的上月最后一日的till_bl  X
	SELECT -8749451.48  + 2187056.80 - 2235008.02  -- = -8797402.70
	-- X - Y 
	SELECT -8749451.48 - -8754401.48  	      -- = 4950.00  差额
	-- till_bl - 差额
	UPDATE rep_dai_history SET till_bl = till_bl - 16610.00 WHERE hotel_id = 13 AND classno ='03000' AND biz_date ='2016.09.09';

	/*
	UPDATE rep_dai SET credit02 = credit02+ 10867,sumcre=sumcre+10867,credit03m=credit02m+10867,
	sumcrem=sumcrem+10867 WHERE hotel_id = 13 AND classno ='01999'
	 	 
	UPDATE rep_dai SET sumcre=sumcre-10867, 
	sumcrem=sumcrem-10867 WHERE hotel_id = 13 AND classno ='03000'
	
	UPDATE rep_jiedai SET credit=credit+ 2400, last_credit=last_credit - 2400 ,creditm=creditm+ 2400,last_creditm=last_creditm - 2400
	WHERE hotel_id = 13 AND classno ='03A'
	
	SELECT * FROM rep_dai WHERE hotel_id = 13

	SELECT * FROM rep_jiedai WHERE hotel_id = 13
	
	SELECT 6366779.40 + 3407.00  --  6370186.40
	SELECT 12082914.05 - 5734792.65 + 19665.00 - 6367786.40  -- = -13267.00
	
	SELECT * FROM rep_dai WHERE hotel_id = 13 ORDER BY classno
	SELECT * FROM rep_jie WHERE hotel_id = 13 ORDER BY classno
	SELECT 131509.90 -  6243.00 - 176 -- =125090.90
	SELECT 142596.25 -113544.35 +  96039.00 
	
	SELECT SUM(b.balance) FROM master_base_till a,zzz b WHERE b.hotel_id = 13 AND b.accnt_type = 'master'
	AND b.accnt = a.id AND a.hotel_group_id = 2 AND a.hotel_id = 13 AND a.rsv_class = 'H';

	SELECT SUM(b.balance) FROM master_base_till a,zzz b WHERE b.hotel_id = 13 AND b.accnt_type = 'master'
	AND b.accnt = a.id AND a.hotel_group_id = 2 AND a.hotel_id = 13 AND a.rsv_class = 'F';

	SELECT SUM(b.balance) FROM master_base_till a,zzz b WHERE b.hotel_id = 13 AND b.accnt_type = 'master'
	AND b.accnt = a.id AND a.hotel_group_id = 2 AND a.hotel_id = 13 AND a.rsv_class = 'G';
	
	*/
        -- --------------------------------------------------------------------
	-- 消费帐的当日余额  till_charge -  till_credit    修复rep_jiedai
	SELECT SUM(a.balance) FROM zzz a,master_base_till b WHERE  a.hotel_id = 13 AND accnt_type = 'master'
	AND a.accnt = b.id AND b.hotel_group_id = 2 AND b.hotel_id = 13 AND b.rsv_class = 'H'; -- -2317.00
	  
	SELECT * FROM migrate_db.jiedai  WHERE CODE IN ('02C');
	-- 消费帐的贷方明细  修改消费帐贷方明细的余额
	SELECT * FROM rep_jiedai WHERE hotel_group_id = 2 AND hotel_id = 13   AND classno='02C' ; 
	
	SELECT till_charge - till_credit FROM rep_jiedai WHERE hotel_group_id = 2 AND hotel_id = 13  ; 
	-- 累计消费till_charge() - 累计付款till_credit() = 累计余额balance ()
	SELECT -83118380.81 - -83033438.01 -- = -84942.80                       	差额1 (jiedai)     0
	SELECT -83118380.81 - -83033438.01 -- = -84942.80	                        差额2 (rep_jiedai) 0
	SELECT -84942.80 - -20300.00     -- -64642.80				差额3  200.00
	-- 修改till_charge - 0
	SELECT -83118380.81 - -64642.80  	-- = -83053738.01
	SELECT -83053738.01 - -83033438.01  -- = -20300.00
	-- 修改till_charge - 差额3
	UPDATE rep_jiedai SET till_charge = till_charge - -64642.80 WHERE hotel_id = 13 AND classno  = '02C';
	-- 上日累计余额消费last_charge - 上日累计余额付款last_credit + 本日发生charge - 本日收回credit  = 累计余额balance ()
	SELECT -413137.30 - -410073.30 + 95.00 - 95.00  -- = -3064.00
	SELECT -413137.30 - 200.00 			-- = -413337.30
	SELECT -413337.30 - -410073.30 + 95.00 - 95.00  -- = -3264.00
	-- 修改last_charge - 差额3
	UPDATE rep_jiedai SET last_charge = last_charge - -64642.80 WHERE hotel_id = 13 AND classno  = '02C';
	
	-- 月报消费帐修复 上月最后一天的till_charge - till_credit就是本月月报的上日余额数
	SELECT * FROM rep_jiedai WHERE hotel_id = 13 AND biz_date='2015-09-26' AND classno  = '02C';  -- Z(till_charge - till_credit)  -3264.00  月报本日余额
	SELECT till_charge - till_credit FROM rep_jiedai_history WHERE hotel_id = 13 AND biz_date='2016.09.09' AND classno  = '02C';  -- Y (till_charge - till_credit)  -3064.00 月报上日余额 
	-- 逆推  本日月报上的余额是通过计算的出来  需要修复上月最后一日的till_charge - till_credit 
	-- (2016.09.09 日报本日余额till_charge - till_credit也是本日月报上日余额) +(2015-09-26 日报本日发生月chargem也是月报本日发生) - (2015-09-26 日报本日收回月creditm也是月报本日收回) = (2015-09-26 日报本日余额till_charge - till_credit也是月报本日余额)  -3264.00  
	-- 上月最后一日本日余额till_bl(月报上日余额) X +  14636.00 - 14636.00 = -3264.00 (Z)
	-- X(上月最后一天till_bl余额即月报上日余额 2016.09.09) = (2015-09-26) till_bl (本日余额即月报余额） + credtim(本日月收回余额即月报月收回余额) - debitm(本日月发生余额即月报月发生余额)
	SELECT -3264.00   + 14636.00 - 14636.00       -- = -3264.00  X为需要修复的上月最后一日的(till_charge - till_credit)  X
	SELECT -3264.00   + 14636.00 - 14636.00       -- = -3264.00
	-- X - Y 
	SELECT -3264.00 -  -3064.00 	      -- = -200.00  差额
	-- till_charge + 差额
	UPDATE rep_jiedai_history SET till_charge = till_charge + -400.00 WHERE hotel_id = 13 AND classno  = '02C' AND biz_date ='2016.09.09';
 
	
	
	-- ---------------	
	SELECT SUM(balance) FROM zzz WHERE hotel_id = 13 AND accnt_type = 'master';
	-- 宾客的贷方明细  修改宾客帐贷方明细的余额
	-- 宾客   till_charge -  till_credit
	SELECT SUM(a.balance) FROM zzz a,master_base_till b WHERE  a.hotel_id = 13 AND accnt_type = 'master'
	AND a.accnt = b.id AND b.hotel_group_id = 2 AND b.hotel_id = 13 AND b.rsv_class = 'F' ; -- 65601.40
	
	SELECT * FROM migrate_db.jiedai  WHERE CODE='02F';
	SELECT * FROM rep_jiedai WHERE hotel_group_id = 2 AND hotel_id = 13 AND classno='02F' ;
	-- 累计消费till_charge() - 累计付款till_credit() = 累计余额balance ()
	SELECT -195427.31 - -261028.71  -- = 85501.13    	     差额1  (rep_jiedai)   
	-- 修改till_charge - 2087390.77
	SELECT 85501.13 - 65601.40   -- = 19899.73

	-- 修改till_charge - 差额3
	UPDATE rep_jiedai SET till_charge = till_charge - 19899.73 WHERE hotel_id = 13 AND classno  = '02F'; 
	UPDATE rep_jiedai_history SET till_charge = till_charge - 19899.73 WHERE hotel_id = 13 AND classno  = '02F' AND biz_date='2016.09.09';
	UPDATE rep_jiedai SET last_charge = last_charge - 19899.73 WHERE hotel_id = 13 AND classno  = '02F'; 
	UPDATE rep_jiedai_history SET last_charge = last_charge - 19899.73 WHERE hotel_id = 13 AND classno  = '02F' AND biz_date='2016.09.09';
	
	SELECT * FROM rep_jiedai_history WHERE hotel_group_id = 2 AND hotel_id = 13 AND classno='02F' ;
	-- 上日累计余额消费last_charge - 上日累计余额付款last_credit + 本日发生charge - 本日收回credit  = 累计余额balance ()
	SELECT -6914283.84 - -7246201.93 + 101600.53 -  78671.00		  -- = 354847.62
	SELECT 354847.62 -  507641.10 					  	  -- = -152793.48   差额3
	SELECT -6914283.84 - -152793.48						  -- = -6761490.36
	SELECT -6761490.36 - -7246201.93 + 101600.53 -  78671.00		  -- = 507641.10
	-- 修改last_charge - 差额3
	
	SELECT * FROM master_base_till WHERE hotel_id = 13
	
	-- 月报宾客帐修复 上月最后一天的till_charge - till_credit就是本月月报的上日余额数
	SELECT * FROM rep_jiedai WHERE hotel_id = 13 AND biz_date='2015-09-26' AND classno  = '02F';  -- Z (till_charge - till_credit)  507641.10  月报本日余额
	SELECT till_charge - till_credit FROM rep_jiedai_history WHERE hotel_id = 13 AND biz_date='2016.09.09' AND classno  = '02F';  -- Y (till_charge - till_credit)  361085.15 月报上日余额 
	-- 逆推  本日月报上的余额是通过计算的出来  需要修复上月最后一日的till_charge - till_credit 
	-- (2016.09.09 日报本日余额till_charge - till_credit也是本日月报上日余额) +(2015-09-26 日报本日发生月chargem也是月报本日发生) - (2015-09-26 日报本日收回月creditm也是月报本日收回) = (2015-09-26 日报本日余额till_charge - till_credit也是月报本日余额) 507641.10   
	-- 上月最后一日本日余额till_bl(月报上日余额) X +  2783581.64 - 3037507.78 = 507641.10 (Z)
	-- X(上月最后一天till_bl余额即月报上日余额 2016.09.09) = (2015-09-26) till_bl (本日余额即月报余额） + credtim(本日月收回余额即月报月收回余额) - debitm(本日月发生余额即月报月发生余额)
	SELECT 507641.10   + 3037507.78 - 2783581.64       -- = 761567.24  X为需要修复的上月最后一日的(till_charge - till_credit)  X
	SELECT 761567.24   + 2783581.64 - 3037507.78       -- = 507641.10
	-- X - Y 
	SELECT 761567.24 -  361085.15 	      -- = 400482.09  差额
	-- till_charge + 差额
	UPDATE rep_jiedai_history SET till_charge = till_charge + 400482.09 WHERE hotel_id = 13 AND classno  = '02F' AND biz_date ='2016.09.09';

	
	-- ----------------------------------------------
	-- 团体的贷方明细  修改消费帐贷方明细的余额
	-- 团队  till_charge -  till_credit
	SELECT SUM(a.balance) FROM zzz a,master_base_till b WHERE  a.hotel_id = 13 AND accnt_type = 'master'
	AND a.accnt = b.id AND b.hotel_group_id = 2 AND b.hotel_id = 13 AND b.rsv_class = 'G' ; -- 379.00
	
	SELECT * FROM migrate_db.jiedai WHERE CODE='02G';
	SELECT * FROM rep_jiedai WHERE hotel_group_id = 2 AND hotel_id = 13  AND classno='02G' ;
	-- 累计消费till_charge() - 累计付款till_credit() = 累计余额balance ()
	SELECT 615326.04 - 634846.77 				-- = -19520.73   差额1  rep_jiedai 
	SELECT -19520.73 - 379.00 					-- = -19899.73   差额3
	-- 修改till_charge 
	SELECT 208516134.64 - 198469.23   -- = 208317665.41
	SELECT 208317665.41 - 208452684.41  -- = -135019.00
	-- 修改till_charge - 差额3
	UPDATE rep_jiedai SET till_charge = till_charge - 198469.23 WHERE hotel_id = 13 AND classno  = '02G';
	-- 上日累计余额消费last_charge - 上日累计余额付款last_credit + 本日发生charge - 本日收回credit  = 累计余额balance ()
	SELECT 2910167.34 - 1696353.36 + 132366.18 - 17998.00  	-- = 1328182.16
	SELECT 1328182.16 - 943913.07 				-- = 384269.09 	  差额3
	SELECT 2910167.34 - 384269.09				-- = 2525898.25
	SELECT 2525898.25 - 1696353.36 + 132366.18 -  17998.00	-- = 943913.07
	-- 修改last_charge - 差额3
	UPDATE rep_jiedai SET last_charge = last_charge - -19899.73 WHERE hotel_id = 13 AND classno  = '02G' AND biz_date ='2016.09.09';
	UPDATE rep_jiedai_history SET last_charge = last_charge - -19899.73 WHERE hotel_id = 13 AND classno  = '02G' AND biz_date ='2016.09.09';
	-- 月报团队帐修复 上月最后一天的till_charge - till_credit就是本月月报的上日余额数
	SELECT * FROM rep_jiedai_history WHERE hotel_id = 13 AND biz_date='2015-09-26' AND classno  = '02G';  -- Z (till_charge - till_credit)  943913.07  月报本日余额
	SELECT till_charge - till_credit FROM rep_jiedai_history WHERE hotel_id = 13 AND biz_date='2016.09.09' AND classno  = '02G';  -- Y (till_charge - till_credit)  308120.44 月报上日余额 
	-- 逆推  本日月报上的余额是通过计算的出来  需要修复上月最后一日的till_charge - till_credit 
	-- (2016.09.09 日报本日余额till_charge - till_credit也是本日月报上日余额) +(2015-09-26 日报本日发生月chargem也是月报本日发生) - (2015-09-26 日报本日收回月creditm也是月报本日收回) = (2015-09-26 日报本日余额till_charge - till_credit也是月报本日余额) 507641.10   
	-- 上月最后一日本日余额till_bl(月报上日余额) X +  3149064.93 - 2318007.13 = 943913.07 (Z)
	-- X(上月最后一天till_bl余额即月报上日余额 2016.09.09) = (2015-09-26) till_bl (本日余额即月报余额） + credtim(本日月收回余额即月报月收回余额) - debitm(本日月发生余额即月报月发生余额)
	SELECT 943913.07   + 2318007.13  - 3149064.93       -- = 112855.27  X为需要修复的上月最后一日的(till_charge - till_credit)  X
	SELECT 112855.27   + 3149064.93  - 2318007.13       -- = 943913.07
	-- X - Y 
	SELECT 112855.27 -  308120.44	      -- = -195265.17  差额
	-- till_charge + 差额
	UPDATE rep_jiedai_history SET till_charge = till_charge + -19899.73 WHERE hotel_id = 13 AND classno  = '02G' AND biz_date ='2016.09.09';
	UPDATE rep_jiedai SET till_charge = till_charge + -19899.73  WHERE hotel_id = 13 AND classno  = '02G' AND biz_date ='2016.09.09';

	
	-- ------------------------------------------------------------------
	-- AR的贷方明细  修改消费帐贷方明细的余额
	-- AR      till_charge -  till_credit
	SELECT SUM(a.balance) FROM zzz a,ar_master_till b WHERE  a.hotel_id = 13 AND accnt_type = 'armaster'
	AND a.accnt = b.id AND b.hotel_group_id = 2 AND b.hotel_id = 13 ; -- -146298.05
	
	SELECT * FROM migrate_db.jiedai;
	SELECT * FROM rep_jiedai WHERE hotel_group_id = 2 AND hotel_id = 13  AND classno='03A';
	-- 累计消费till_charge() - 累计付款till_credit() = 累计余额balance ()
	SELECT 12559431.89 - 13331928.52 				-- = -772496.63 差额1  rep_jiedai   
	SELECT -772496.63 - -146298.05					-- = -626198.58       差额3 
	-- 修改till_charge 14183844.46
	UPDATE rep_jiedai SET till_charge = till_charge -626198.58 WHERE hotel_id = 13 AND classno  = '03A';
	UPDATE rep_jiedai_history SET till_charge = till_charge -626198.58 WHERE hotel_id = 13 AND classno  = '03A' AND biz_date='2016.09.09';
	UPDATE rep_jiedai SET last_charge = last_charge - -626198.58  WHERE hotel_id = 13 AND classno  = '03A';
	UPDATE rep_jiedai_history SET last_charge = last_charge - -626198.58  WHERE hotel_id = 13 AND classno  = '03A' AND biz_date='2016.09.09';
	-- 上日累计余额消费last_cahre - 上日累计余额付款last_credit + 本日发生charge - 本日收回credit  = 累计余额balance ()
	SELECT 47469320.24 - 46833903.71 +  83298.00	-- = 718714.53
	
	
	
	-- 月报AR帐修复 上月最后一天的till_charge - till_credit就是本月月报的上日余额数
	SELECT * FROM rep_jiedai WHERE hotel_id = 13 AND biz_date='2015-09-26' AND classno  = '03A';  -- Z (till_charge - till_credit)  718714.53  月报本日余额
	SELECT till_charge - till_credit FROM rep_jiedai_history WHERE hotel_id = 13 AND biz_date='2016.09.09' AND classno  = '03A';  -- Y (till_charge - till_credit)  -423546.13 月报上日余额 
	-- 逆推  本日月报上的余额是通过计算的出来  需要修复上月最后一日的till_charge - till_credit 
	-- (2016.09.09 日报本日余额till_charge - till_credit也是本日月报上日余额) +(2015-09-26 日报本日发生月chargem也是月报本日发生) - (2015-09-26 日报本日收回月creditm也是月报本日收回) = (2015-09-26 日报本日余额till_charge - till_credit也是月报本日余额) 507641.10   
	-- 上月最后一日本日余额till_bl(月报上日余额) X +  4045325.68 - 2903065.02 = 718714.53 (Z)
	-- X(上月最后一天till_bl余额即月报上日余额 2016.09.09) = (2015-09-26) till_bl (本日余额即月报余额） + credtim(本日月收回余额即月报月收回余额) - debitm(本日月发生余额即月报月发生余额)
	SELECT 718714.53    + 2903065.02  - 4045325.68       -- = -423546.13  X为需要修复的上月最后一日的(till_charge - till_credit)  X
	SELECT -423546.13   + 4045325.68  - 2903065.02       -- = 718714.53
	-- X - Y 
	SELECT -423546.13  -  -423546.13	      -- = 0  差额
	-- till_charge + 差额
	UPDATE rep_jiedai_history SET till_charge = till_charge + 0 WHERE hotel_id = 13 AND classno  = '03A' AND biz_date ='2016.09.09';

	
	-- 修改好之后更新到历史 rep_dai_history ，rep_jiedai_history
	SELECT * FROM rep_dai_history  WHERE hotel_group_id = 2 AND hotel_id = 13;
	DELETE FROM rep_dai_history  WHERE hotel_group_id = 2 AND hotel_id = 13 AND biz_date <>'2016.09.09';
	DELETE FROM rep_jiedai_history  WHERE hotel_group_id = 2 AND hotel_id = 13 AND biz_date <>'2016.09.09';
	INSERT INTO rep_dai_history SELECT * FROM rep_dai WHERE hotel_group_id = 2 AND hotel_id = 13 ;
	INSERT INTO rep_jiedai_history SELECT * FROM rep_jiedai WHERE hotel_group_id = 2 AND hotel_id = 13 ;	
	
	-- 核对数据  借方合计 贷方合计 月累计  余额数   (余额数对不上以实际的数据为准)
	SELECT * FROM rep_dai WHERE hotel_group_id = 2 AND hotel_id = 13 ORDER BY biz_date,classno; -- sumcre ,sumcrem , till_bl
	SELECT * FROM rep_jiedai WHERE hotel_group_id = 2 AND hotel_id = 13 ORDER BY biz_date,classno; -- till_charge till_credit last_charge
	SELECT * FROM rep_jie WHERE hotel_group_id = 2 AND hotel_id = 13 ORDER BY biz_date,classno; -- day99 , month 99
	SELECT * FROM migrate_db.jierep; -- day 99, month99
	SELECT * FROM migrate_db.dairep; -- sumcre,sumcrem ,till_bl
