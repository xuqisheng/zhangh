ALTER TABLE migrate_xmyh.guest ADD tag CHAR(2) NOT NULL DEFAULT ''  AFTER logmark;
ALTER TABLE migrate_xmyh.guest ADD tag1 CHAR(2) NOT NULL DEFAULT ''  AFTER tag;

CREATE INDEX index_tag ON migrate_xmyh.guest(class,tag);
CREATE INDEX index_1 ON migrate_xmyh.hmaster_g(haccnt);
CREATE INDEX index_1 ON migrate_xmyh.master(haccnt);

SELECT * FROM migrate_xmyh.guest;
-- 所有2013.1.1日之后有证件号码的
UPDATE migrate_xmyh.guest SET tag = 'A' WHERE  class = 'F' AND lv_date >='2013.01.01' AND ident <> '';
SELECT COUNT(1) FROM migrate_xmyh.guest WHERE class = 'F' AND lv_date >='2013.01.01' AND ident <> '';
SELECT COUNT(1) FROM migrate_xmyh.guest WHERE tag = 'A'; -- 88778
-- 所有入住次数大于2次且证件号码不为空的
SELECT * FROM migrate_xmyh.guest WHERE i_times >= 2 AND ident <> '';
UPDATE migrate_xmyh.guest SET tag = 'A' WHERE tag <> 'A' AND class = 'F' AND i_times >= 2 AND ident <> '';
SELECT COUNT(1) FROM migrate_xmyh.guest WHERE tag = 'A'; -- 115292
-- 政府客人
SELECT * FROM migrate_xmyh.guest a,migrate_xmyh.hmaster_g b WHERE b.haccnt =a.no;
UPDATE migrate_xmyh.guest a,migrate_xmyh.hmaster_g b SET a.tag = 'A' WHERE a.tag <> 'A' AND a.class = 'F' AND a.no = b.haccnt;
SELECT COUNT(1) FROM migrate_xmyh.guest WHERE tag = 'A'; -- 124941
-- 当前主单
SELECT * FROM migrate_xmyh.guest a,migrate_xmyh.master b WHERE b.haccnt =a.no;
UPDATE migrate_xmyh.guest a,migrate_xmyh.master b SET a.tag = 'A' WHERE a.tag <> 'A' AND a.class = 'F' AND a.no = b.haccnt;
SELECT COUNT(1) FROM migrate_xmyh.guest WHERE tag = 'A'; -- 126201
-- 当前消费帐主单
SELECT * FROM migrate_xmyh.guest WHERE NO ='6000006'
UPDATE migrate_xmyh.guest a,migrate_xmyh.master b SET a.tag = 'A' WHERE a.tag <> 'A' AND a.class = 'H' AND a.no = b.haccnt;
SELECT COUNT(1) FROM migrate_xmyh.guest WHERE tag = 'A'; 
SELECT COUNT(1) FROM migrate_xmyh.guest WHERE tag = 'A'; -- 126214


-- 签单人
SELECT * FROM migrate_xmyh.guest a,migrate_xmyh.argst b WHERE b.no =a.no;
SELECT * FROM migrate_xmyh.argst;
UPDATE migrate_xmyh.guest a,migrate_xmyh.argst b SET a.tag = 'A' WHERE a.tag <> 'A' AND a.class = 'F' AND a.no = b.no;
SELECT COUNT(1) FROM migrate_xmyh.guest WHERE tag = 'A'; -- 126786
SELECT COUNT(1) FROM migrate_xmyh.guest WHERE tag = 'A' AND class = 'F';
 


-- 会员卡关联客史
SELECT  * FROM migrate_xmyh.guest a,migrate_xmyh.vipcard b WHERE b.hno =a.no AND a.tag <> 'A';
UPDATE migrate_xmyh.guest a,migrate_xmyh.vipcard b SET a.tag = 'A' WHERE a.tag <> 'A' AND a.class = 'F' AND a.no = b.hno;
SELECT COUNT(1) FROM migrate_xmyh.guest WHERE tag = 'A'; -- 131398

-- 协议单位整理
SELECT * FROM migrate_xmyh.master ;
-- 2013.01.01日后有消费记录的协议单位
UPDATE migrate_xmyh.guest SET tag = 'B' WHERE  class IN('A','S','C') AND lv_date >='2013.01.01';
SELECT COUNT(1) FROM migrate_xmyh.guest WHERE tag = 'B'; -- 1726 
 
-- 关联当前主单的协议单位 订房中心 旅行社
SELECT * FROM  migrate_xmyh.guest a ,migrate_xmyh.master b WHERE a.class IN('A','S','C') AND a.no = b.cusno;

UPDATE migrate_xmyh.guest a ,migrate_xmyh.master b SET a.tag = 'B'
	WHERE a.class IN('A','S','C') AND a.no = b.cusno;
UPDATE migrate_xmyh.guest a ,migrate_xmyh.master b SET a.tag = 'B'
	WHERE a.class IN('A','S','C') AND a.no = b.agent;
UPDATE migrate_xmyh.guest a ,migrate_xmyh.master b SET a.tag = 'B'
	WHERE a.class IN('A','S','C') AND a.no = b.source;
SELECT COUNT(1) FROM migrate_xmyh.guest WHERE tag = 'B'; -- 7971  -- 1754
-- 订房人卡	
SELECT * FROM  migrate_xmyh.guest a ,migrate_xmyh.vipcard b WHERE a.class IN('A','S','C') AND a.no = b.cno;

UPDATE  migrate_xmyh.guest a ,migrate_xmyh.vipcard b SET a.tag = 'B'
WHERE a.tag <> 'B' AND a.class IN('A','S','C') AND a.no = b.cno;
SELECT COUNT(1) FROM migrate_xmyh.guest WHERE tag = 'B'; -- 1818


SELECT COUNT(1) FROM  migrate_xmyh.guest a WHERE a.class IN('A','S','C');
SELECT COUNT(1) FROM  migrate_xmyh.guest a WHERE a.tag = 'B';
SELECT COUNT(1) FROM  migrate_xmyh.guest   WHERE  class IN('A','S','C') AND lv_date >='2013.01.01';

-- 签单人
SELECT * FROM  migrate_xmyh.guest a ,migrate_xmyh.argst b WHERE a.tag <> 'B' AND a.class IN('A','S','C') AND a.no = b.accnt AND b.accnt NOT LIKE 'AR%';

UPDATE   migrate_xmyh.guest a ,migrate_xmyh.argst b  SET a.tag = 'B'
	WHERE a.tag <> 'B' AND a.class IN('A','S','C') AND a.no = b.accnt AND b.accnt NOT LIKE 'AR%';
SELECT COUNT(1) FROM migrate_xmyh.guest WHERE tag = 'B'; -- 1849
	
-- 20分钟
