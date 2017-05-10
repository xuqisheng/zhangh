1,34
   
   
   CALL up_ihotel_maint_snapshot_ageing(2,18,'2015-11-30',11517);

SELECT a.master_id,b.NAME,a.last_balance,a.charge_ttl,a.pay_ttl,a.till_balance
FROM master_snapshot a,ar_master_guest b,ar_master c
WHERE a.hotel_id=18 AND a.hotel_group_id=2
AND b.hotel_id=18 AND b.hotel_group_id=2
AND c.hotel_id=18 AND c.hotel_group_id=2
AND a.master_type = 'armaster' AND a.biz_date_begin < '2015-11-30' AND a.biz_date_end >= '2015-11-30' AND a.till_balance<>0
AND a.master_id = b.id AND a.master_id=c.id AND a.master_id=11517
ORDER BY c.ar_category,c.id,a.master_id;

CALL up_ihotel_rep_ar_aging_esd_bak(2,18,'F','AR','2015-11-30',11517);
   
   
   
  
SELECT a.master_id,b.NAME,a.last_balance,a.charge_ttl,a.pay_ttl,a.till_balance
FROM master_snapshot a,ar_master_guest b,ar_master c
WHERE a.hotel_group_id=2 AND a.hotel_id=18 AND b.hotel_group_id=2 AND b.hotel_id=18 AND c.hotel_group_id=2 AND c.hotel_id=18
AND a.master_type = 'armaster' AND a.biz_date_begin < '2015-11-30' AND a.biz_date_end >= '2015-11-30' AND a.till_balance<>0
AND a.master_id = b.id AND a.master_id=c.id AND a.master_id=11519
ORDER BY c.ar_category,c.id,a.master_id;

CALL up_ihotel_rep_ar_aging_esd_bak(2,18,'F','AR','2015-11-30',11519);


SELECT a.hotel_id,a.ar_accnt,a.ar_inumber,(a.charge - a.charge9) AS charge,(a.pay - a.credit9) AS pay,a.ta_code,DATE(c.gen_date),a.ar_tag,a.ar_subtotal FROM ar_detail a,ar_master b,ar_account c 
WHERE a.hotel_group_id = 2  AND a.hotel_id = 18 AND b.hotel_group_id = 2  AND b.hotel_id = 18 AND c.hotel_group_id = 2  AND c.hotel_id = 18
AND c.gen_date < DATE_ADD('2015-11-30',INTERVAL 1 DAY) AND a.ar_accnt = b.id AND a.ar_accnt = c.accnt AND a.ar_inumber = c.number
AND ((a.charge - a.charge9)<>0 OR (a.pay - a.credit9)<>0)
AND b.id=17456 ;

SELECT a.hotel_id,a.ar_accnt,a.ar_inumber,c.charge,c.pay,a.ta_code,DATE(a.gen_date),a.ar_tag,a.ar_subtotal FROM ar_detail a,ar_master b,ar_apply c,ar_account d  WHERE 
a.hotel_group_id = 2  AND a.hotel_id = 18 AND a.ar_accnt = c.accnt AND a.ar_number = c.number 
AND b.hotel_group_id = 2  AND b.hotel_id = 18 AND  b.id = a.ar_accnt
AND c.hotel_group_id = 2  AND c.hotel_id = 18 AND d.hotel_group_id = 2  AND d.hotel_id = 18
AND d.accnt = a.ar_accnt  AND d.number =  a.ar_inumber
AND b.id=17456 
AND d.gen_date <= DATE_ADD('2015-11-30',INTERVAL 1 DAY) AND c.close_id IN
(SELECT DISTINCT(id) FROM ar_apply WHERE hotel_group_id = 2 AND hotel_id = 18 AND close_flag='B' 
AND biz_date > '2015-11-30') ;



SELECT ref.ar_accnt,ref.ar_inumber,SUM(ref.charge) AS charge,SUM(ref.pay) AS pay FROM 
(SELECT a.ar_accnt,a.ar_inumber,(a.charge - a.charge9) AS charge,(a.pay - a.credit9) AS pay,a.ta_code,DATE(c.gen_date),a.ar_tag,a.ar_subtotal FROM ar_detail a,ar_master b,ar_account c 
WHERE a.hotel_group_id = 2  AND a.hotel_id = 18 AND b.hotel_group_id = 2  AND b.hotel_id = 18 AND c.hotel_group_id = 2  AND c.hotel_id = 18
AND c.gen_date < DATE_ADD('2015-11-30',INTERVAL 1 DAY) AND a.ar_accnt = b.id AND a.ar_accnt = c.accnt AND a.ar_inumber = c.number
AND ((a.charge - a.charge9)<>0 OR (a.pay - a.credit9)<>0)
AND b.id=11576) AS ref 
GROUP BY ref.ar_inumber 
HAVING (charge-pay)<>0;

SELECT GROUP_CONCAT(bbb.ar_inumber) FROM (SELECT ref.ar_accnt,ref.ar_inumber,SUM(ref.charge) AS charge,SUM(ref.pay) AS pay FROM 
(SELECT a.ar_accnt,a.ar_inumber,(a.charge - a.charge9) AS charge,(a.pay - a.credit9) AS pay,a.ta_code,DATE(c.gen_date),a.ar_tag,a.ar_subtotal FROM ar_detail a,ar_master b,ar_account c 
WHERE a.hotel_group_id = 2  AND a.hotel_id = 18 AND b.hotel_group_id = 2  AND b.hotel_id = 18 AND c.hotel_group_id = 2  AND c.hotel_id = 18
AND c.gen_date < DATE_ADD('2015-11-30',INTERVAL 1 DAY) AND a.ar_accnt = b.id AND a.ar_accnt = c.accnt AND a.ar_inumber = c.number
AND ((a.charge - a.charge9)<>0 OR (a.pay - a.credit9)<>0)
AND b.id=11858) AS ref 
GROUP BY ref.ar_inumber 
HAVING (charge-pay)<>0)
AS bbb;

UPDATE ar_detail SET charge9=charge 
WHERE hotel_group_id=2 AND hotel_id=18
AND ar_accnt=11858 AND ar_inumber IN(
39,59,60,78,79,80,81,82,83,90,142,201,202,214,215,220,244,245,328,333
)
AND charge<>0;

UPDATE ar_detail SET credit9=pay 
WHERE hotel_group_id=2 AND hotel_id=18
AND ar_accnt=11858 AND ar_inumber IN(
39,59,60,78,79,80,81,82,83,90,142,201,202,214,215,220,244,245,328,333
)
AND pay<>0;


SELECT id,charge,ar_inumber,ar_subtotal,pay,charge9,credit9 FROM ar_detail WHERE hotel_group_id=2 AND hotel_id=18
AND ar_accnt=15372 AND ar_inumber IN (336,377,464,500,1079,1082,1207) ORDER BY ar_inumber 

 