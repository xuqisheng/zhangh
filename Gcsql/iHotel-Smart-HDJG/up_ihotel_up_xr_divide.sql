DELIMITER $$

DROP PROCEDURE IF EXISTS `up_ihotel_up_xr_divide`$$

CREATE DEFINER=`root`@`%` PROCEDURE `up_ihotel_up_xr_divide`(
	IN arg_foxhis_ip	INT,
	IN arg_foxhis_db	VARCHAR(20)
	)
SQL SECURITY INVOKER
label_0:
BEGIN
	
	-- 用于判断是否存在同一主单中存在不同楼号的房间
	/*
	SELECT a.groupno,a.roomno,b.hall FROM MASTER a LEFT JOIN migrate_db.rmsta b ON a.roomno = b.roomno
		WHERE a.accnt NOT LIKE 'AR%' AND a.groupno<>'' AND a.sta IN ('R','I','O','S')
		GROUP BY a.groupno,b.hall HAVING COUNT(DISTINCT hall)>1
	*/
	-- master.exp_s2 作为 hotel_id的区分字段 | 同时为 exp_s2 那个索引
	-- 删除一些无效档案数据
	DELETE FROM migrate_db.guest WHERE ident='' AND no NOT IN (SELECT haccnt FROM migrate_db.master) AND class IN ('F','G'); 
	
	IF arg_foxhis_ip = 90 AND arg_foxhis_db = 'hfoxhis' THEN
		-- 合欢谷 	hotel_id = 30  	rmsta.hall = 'C'
			-- 散客和成员通过房号结合楼栋更新
			UPDATE migrate_db.master SET exp_s2 = 30 WHERE class = 'F' AND sta IN ('R','I','O','S') 
				AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'C');

			-- 团队|会议 结合成员房号
			UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 30 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
				AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
				AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'C');				
		
			-- 团队|会议 结合姓名
			UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 30 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
				AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '合欢%';
			
			-- 消费账建议所有账结清			
		
		-- 欢乐		hotel_id = 31	rmsta.hall = 'E'	
			UPDATE migrate_db.master SET exp_s2 = 31 WHERE class = 'F' AND sta IN ('R','I','O','S') 
				AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'E');

			UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 31 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
				AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
				AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'E');
				
			UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 31 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
				AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '欢乐%';		
		
		-- 休闲 	hotel_id = 32	rmsta.hall = 'A'
			UPDATE migrate_db.master SET exp_s2 = 32 WHERE class = 'F' AND sta IN ('R','I','O','S') 
				AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'A');
				
			UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 32 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
				AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
				AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'A');
				
			UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 32 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
				AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '休%';

		-- 人工特殊判断后结果
		UPDATE migrate_db.master SET exp_s2 = 30 WHERE accnt IN ('G506290027','G602150004');
		-- 判断有哪几条数据未处理		
		SELECT a.accnt,a.groupno,b.name,a.sta,a.roomno,a.arr,a.dep,a.charge,a.credit,(a.charge - a.credit) AS balance FROM migrate_db.master a LEFT JOIN migrate_db.guest b ON a.haccnt = b.no
		WHERE a.sta IN ('R','I','O','S') AND a.exp_s2 = '' AND a.class <> 'A' ORDER BY a.groupno,b.name;
	
	END IF;	
	
	IF arg_foxhis_ip = 120 AND arg_foxhis_db = 'jdglfoxhis' THEN
		-- 京华 	hotel_id = 15
		UPDATE migrate_db.master SET exp_s2 = 15;	

		-- 判断有哪几条数据未处理		
		SELECT a.accnt,a.groupno,b.name,a.sta,a.roomno,a.arr,a.dep,a.charge,a.credit,(a.charge - a.credit) AS balance FROM migrate_db.master a LEFT JOIN migrate_db.guest b ON a.haccnt = b.no
		WHERE a.sta IN ('R','I','O','S') AND a.exp_s2 = '' AND a.class <> 'A' ORDER BY a.groupno,b.name;
	
	END IF;		
	
	IF arg_foxhis_ip = 120 AND arg_foxhis_db = 'foxhis' THEN	
		-- 长征主楼 	hotel_id = 17	rmsta.hall = 'C'
			UPDATE migrate_db.master SET exp_s2 = 17 WHERE class = 'F' AND sta IN ('R','I','O','S') 
				AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'C');		
			UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 17 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
				AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '长征主楼%';	
			UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 17 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
				AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
				AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'C');
				
		-- 长征副楼 	hotel_id = 23	rmsta.hall = 'B'
			UPDATE migrate_db.master SET exp_s2 = 23 WHERE class = 'F' AND sta IN ('R','I','O','S') 
				AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'B');		
			UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 23 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
				AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '长征副楼%';
			UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 23 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
				AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
				AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'B');				
		
		-- 花木 		hotel_id = 24	rmsta.hall = 'Q'
			UPDATE migrate_db.master SET exp_s2 = 24 WHERE class = 'F' AND sta IN ('R','I','O','S') 
				AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'Q');		
			UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 24 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
				AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '花木%';		
			UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 24 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
				AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
				AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'Q');	
				
		-- 明清民居 	hotel_id = 25	rmsta.hall = 'S'
			UPDATE migrate_db.master SET exp_s2 = 25 WHERE class = 'F' AND sta IN ('R','I','O','S') 
				AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'S');		
			UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 25 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
				AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '明清%';		
			UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 25 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
				AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
				AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'S');
				
		-- 鑫悦		 	hotel_id = 26	rmsta.hall = 'V'
			UPDATE migrate_db.master SET exp_s2 = 26 WHERE class = 'F' AND sta IN ('R','I','O','S') 
				AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'V');		
			UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 26 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
				AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '鑫悦%';		
			UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 26 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
				AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
				AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'V');
				
		-- 华尔康居 	hotel_id = 27	rmsta.hall = 'W'
			UPDATE migrate_db.master SET exp_s2 = 27 WHERE class = 'F' AND sta IN ('R','I','O','S') 
				AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'W');		
			UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 27 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
				AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '华%';		
			UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 27 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
				AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
				AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'W');
				
		-- 中奥		 	hotel_id = 28	rmsta.hall = 'E'		
			UPDATE migrate_db.master SET exp_s2 = 28 WHERE class = 'F' AND sta IN ('R','I','O','S') 
				AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'E');		
			UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 28 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
				AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '中奥%';
			UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 28 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
				AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
				AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'E');			
		
		-- 景瑞		 	hotel_id = 29	rmsta.hall = 'U'
			UPDATE migrate_db.master SET exp_s2 = 29 WHERE class = 'F' AND sta IN ('R','I','O','S') 
				AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'U');		
			UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 29 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
				AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '景瑞%';
			UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 29 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
				AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
				AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'U');				

		-- 判断有哪几条数据未处理		
		SELECT a.accnt,a.groupno,b.name,a.sta,a.roomno,a.arr,a.dep,a.charge,a.credit,(a.charge - a.credit) AS balance FROM migrate_db.master a LEFT JOIN migrate_db.guest b ON a.haccnt = b.no
		WHERE a.sta IN ('R','I','O','S') AND a.exp_s2 = '' AND a.class <> 'A' ORDER BY a.groupno,b.name;	
		
	END IF;		
	
	IF arg_foxhis_ip = 12 AND arg_foxhis_db = 'foxhis' THEN	
		-- 明南 	hotel_id = 41	rmsta.hall = 'B'
		UPDATE migrate_db.master SET exp_s2 = 41 WHERE class = 'F' AND sta IN ('R','I','O','S') 
			AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'B');		
		UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 41 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
			AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '明南%';	
		UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 41 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
			AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
			AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'B');
			
		-- 假日 	hotel_id = 42	rmsta.hall = 'C'		
		UPDATE migrate_db.master SET exp_s2 = 42 WHERE class = 'F' AND sta IN ('R','I','O','S') 
			AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'C');		
		UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 42 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
			AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '假日%';	
		UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 42 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
			AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
			AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'C');
			
		-- 清源 	hotel_id = 43	rmsta.hall = 'E'
		UPDATE migrate_db.master SET exp_s2 = 43 WHERE class = 'F' AND sta IN ('R','I','O','S') 
			AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'E');		
		UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 43 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
			AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '清源%';	
		UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 43 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
			AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
			AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'E');		
		
		-- 万豪 	hotel_id = 44	rmsta.hall = 'Q'
		UPDATE migrate_db.master SET exp_s2 = 44 WHERE class = 'F' AND sta IN ('R','I','O','S') 
			AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'Q');		
		UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 44 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
			AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '万豪%';	
		UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 44 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
			AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
			AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'Q');
			
		-- 明前 	hotel_id = 45	rmsta.hall = 'S'
		UPDATE migrate_db.master SET exp_s2 = 45 WHERE class = 'F' AND sta IN ('R','I','O','S') 
			AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'S');		
		UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 45 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
			AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '明前%';	
		UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 45 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
			AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
			AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'S');
			
		-- 金汇 	hotel_id = 46	rmsta.hall = 'U'
		UPDATE migrate_db.master SET exp_s2 = 46 WHERE class = 'F' AND sta IN ('R','I','O','S') 
			AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'U');		
		UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 46 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
			AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '金汇%';	
		UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 46 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
			AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
			AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'U');
			
		-- 宝岛 	hotel_id = 47	rmsta.hall = 'V'		
		UPDATE migrate_db.master SET exp_s2 = 47 WHERE class = 'F' AND sta IN ('R','I','O','S') 
			AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'V');		
		UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 47 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
			AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '宝%';	
		UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 47 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
			AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
			AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'V');
			
		-- 振宇 	hotel_id = 48	rmsta.hall = 'W'
		UPDATE migrate_db.master SET exp_s2 = 48 WHERE class = 'F' AND sta IN ('R','I','O','S') 
			AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'W');		
		UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 48 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
			AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '振宇%';	
		UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 48 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
			AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
			AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'W');

		-- 判断有哪几条数据未处理		
		SELECT a.accnt,a.groupno,b.name,a.sta,a.roomno,a.arr,a.dep,a.charge,a.credit,(a.charge - a.credit) AS balance FROM migrate_db.master a LEFT JOIN migrate_db.guest b ON a.haccnt = b.no
		WHERE a.sta IN ('R','I','O','S') AND a.exp_s2 = '' AND a.class <> 'A' ORDER BY a.groupno,b.name;		
			
	END IF;	
	
	IF arg_foxhis_ip = 9 AND arg_foxhis_db = 'foxhis5' THEN
		-- 不夜城 	hotel_id = 35	rmsta.hall = 'C'
		UPDATE migrate_db.master SET exp_s2 = 35 WHERE class = 'F' AND sta IN ('R','I','O','S') 
			AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'C');		
		UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 35 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
			AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '不夜%';	
		UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 35 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
			AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
			AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'C');
			
		-- 凯兴 	hotel_id = 36	rmsta.hall = 'E'
		UPDATE migrate_db.master SET exp_s2 = 36 WHERE class = 'F' AND sta IN ('R','I','O','S') 
			AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'E');		
		UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 36 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
			AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '凯兴%';	
		UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 36 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
			AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
			AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'E');
			
		-- 岭南 	hotel_id = 37	rmsta.hall = 'L'	
		UPDATE migrate_db.master SET exp_s2 = 37 WHERE class = 'F' AND sta IN ('R','I','O','S') 
			AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'L');		
		UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 37 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
			AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '岭南%';	
		UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 37 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
			AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
			AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'L');
			
		-- 度假村 	hotel_id = 38	rmsta.hall = 'G','H','K'
		UPDATE migrate_db.master SET exp_s2 = 38 WHERE class = 'F' AND sta IN ('R','I','O','S') 
			AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall IN ('G','H','K'));		
		UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 38 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
			AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '度%';	
		UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 38 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
			AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
			AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall IN ('G','H','K'));
				
		-- 影都 	hotel_id = 39	rmsta.hall = 'S','T'
		UPDATE migrate_db.master SET exp_s2 = 39 WHERE class = 'F' AND sta IN ('R','I','O','S') 
			AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall IN ('S','T'));		
		UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 39 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
			AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '影%';	
		UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 39 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
			AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
			AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall IN ('S','T'));
			
		-- 秦东 	hotel_id = 40	rmsta.hall = 'Q'
		UPDATE migrate_db.master SET exp_s2 = 40 WHERE class = 'F' AND sta IN ('R','I','O','S') 
			AND roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'Q');		
		UPDATE migrate_db.master a,migrate_db.guest b SET a.exp_s2 = 40 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S')
			AND a.roomno = '' AND a.haccnt=b.no AND b.name LIKE '秦%';	
		UPDATE migrate_db.master a,migrate_db.master b SET a.exp_s2 = 40 WHERE a.class IN ('M','G') AND a.sta IN ('R','I','O','S') 
			AND a.accnt = b.groupno AND b.class = 'F' AND b.sta IN ('R','I','O','S')
			AND b.roomno IN (SELECT roomno FROM migrate_db.rmsta WHERE hall = 'Q');
			
		-- 判断有哪几条数据未处理		
		SELECT a.accnt,a.groupno,b.name,a.sta,a.roomno,a.arr,a.dep,a.charge,a.credit,(a.charge - a.credit) AS balance FROM migrate_db.master a LEFT JOIN migrate_db.guest b ON a.haccnt = b.no
		WHERE a.sta IN ('R','I','O','S') AND a.exp_s2 = '' AND a.class <> 'A' ORDER BY a.groupno,b.name;
			
	END IF;
	
END$$

DELIMITER ;