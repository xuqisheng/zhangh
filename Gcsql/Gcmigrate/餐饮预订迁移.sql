


INSERT INTO `portal_pms`.`pos_res` (
  `hotel_group_id`,`hotel_id`,`accnt`,`type1`,`type2`,`type3`,`type4`,`type5`,
  `res_name`,`res_date`,`pccode`,  `mode`,`shift`, `empid`,`sta`,`osta`,`biz_date`,`table_type`, `tableno`,
  `exttableno`, `numb`,`gsts`, `children`,`market`,`source`,`haccnt`,`name`,`cusno`, `cusinfo`,
  `cardno`, `cardinfo`, `saleid`, `saleinfo`, `phone`, `email`, `begin_time`, `end_time`,
  `arrtime`, `amount`, `type`, `paytype`, `pay`, `charge`, `toaccnt`, `accntinfo`, `cmscode`, `info`,
  `love`, `qr_code`, `create_user`, `create_datetime`, `modify_user`, `modify_datetime`
) 
SELECT 2, 9,resno,'', NULL,NULL, NULL, NULL,
    unit, DATE,pccode, '000',shift,name,sta,NULL,bdate,'001',tableno,
    '',  NULL, guest,NULL, '','','','', cusno,  '', 
    '','',saleid,NULL, phone,email,'', '',
    '', standent,'B', NULL, NULL, NULL,  NULL, NULL,NULL,remark,
    flag,'', empno, DATE, empno,DATE
  FROM migrate_db.pos_reserve;
  
 SELECT * FROM up_map_code WHERE hotel_group_id = 2 AND hotel_id = 13;
-- 市场码 
UPDATE pos_res a,up_map_code b SET a.market = b.code_new WHERE a.hotel_group_id = 2 AND a.hotel_id = 13
AND a.market = b.code_old AND b.hotel_group_id = 2 AND b.hotel_id = 9AND b.code = 'pos_market';
-- 来源码
UPDATE pos_res a,up_map_code b SET a.market = b.code_new WHERE a.hotel_group_id = 2 AND a.hotel_id = 13
AND a.source = b.code_old AND b.hotel_group_id = 2 AND b.hotel_id = 9AND b.code = 'pos_source';
-- 营业点
UPDATE pos_res a,up_map_code b SET a.pccode = b.code_new WHERE a.hotel_group_id = 2 AND a.hotel_id = 13
AND a.pccode = b.code_old AND b.hotel_group_id = 2 AND b.hotel_id = 9AND b.code = 'pos_pccode';
-- 班次
UPDATE pos_res a,up_map_code b SET a.shift = b.code_new WHERE a.hotel_group_id = 2 AND a.hotel_id = 13
AND a.shift = b.code_old AND b.hotel_group_id = 2 AND b.hotel_id = 9AND b.code = 'pos_shift';
-- 桌号
UPDATE pos_res a,up_map_code b SET a.tableno = b.code_new WHERE a.hotel_group_id = 2 AND a.hotel_id = 13
AND a.tableno = b.code_old AND b.hotel_group_id = 2 AND b.hotel_id = 9AND b.code = 'pos_table';
-- 销售员
UPDATE pos_res a,up_map_code b SET a.saleid = b.code_new WHERE a.hotel_group_id = 2 AND a.hotel_id = 13
AND a.saleid = b.code_old AND b.hotel_group_id = 2 AND b.hotel_id = 9AND b.code = 'salesman';

UPDATE pos_res a,sales_man b SET a.saleinfo=b.name WHERE a.hotel_group_id = 2 AND a.hotel_id = 9 AND b.code=a.saleid ;


SELECT * FROM  pos_res WHERE hotel_id = 13;

SELECT DISTINCT paycode FROM migrate_zjbg.pos_pay;

SELECT * FROM code_transaction WHERE hotel_id = 9AND CODE > '9' AND descript LIKE '%支付宝%' ORDER BY CODE;

SELECT * FROM  pos_pay WHERE hotel_id = 13;

INSERT INTO pos_pay (hotel_group_id,hotel_id,accnt,inumber,anumber,subid,trand,taccnt,tnumber,tsubid,shift,empid,tshift,tempid,
biz_date,logdate,tbdate,oldate,opccode,pccode,descript,descript_en,paytype,numb,
charge,credit,bal,billno,foliono,orderno,SIGN,flag,sta,reason,info1,info2,bank,cardcode,dtl_accnt,create_user,
create_datetime,modify_user,modify_datetime) 
SELECT '2','9',b.resno,a.number,NULL,NULL,NULL,NULL,NULL,NULL,'0','2875',NULL,NULL,
'2017-09-13',NOW(),NULL,NULL,NULL,'9810','内部转账',
NULL,NULL,NULL,NULL,a.amount,NULL,NULL,a.foliono,NULL,NULL,NULL,'I',NULL,'',NULL,NULL,NULL,NULL,
'ADMIN',NOW(),'ADMIN',NOW()
FROM migrate_db.pos_pay a,migrate_db.pos_reserve b WHERE a.crradjt='NR' AND a.menu=b.resno;


UPDATE pos_res a SET a.pay=IFNULL((SELECT SUM(b.credit) FROM pos_pay b WHERE a.accnt=b.accnt AND b.hotel_group_id=2 
AND b.hotel_id=9),0) WHERE a.hotel_group_id=2 AND a.hotel_id=9;