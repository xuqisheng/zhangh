/*
----each----:[todo]
----each----:[master_snapshot]
----each----:[ar_account][ar_detail]
*/

SELECT a.hotel_group_id,
       a.hotel_id,
       a.id,
       a.sta,
       a.master_type,
       a.master_id,
       a.biz_date_begin,
       a.biz_date_end,
       a.till_balance AS snapshot_balance,
       (SELECT IFNULL(SUM(c.charge-c.pay),0)
               FROM  ar_detail c 
               WHERE #ca#gh# AND 
                     c.ar_accnt=a.master_id and 
                     c.biz_date <= a.biz_date_end and 
                     (c.ar_subtotal='F' OR
                      c.ar_subtotal='T' AND
                      (select b.audit_tag from ar_account b where #bc#gh# and b.accnt=c.ar_accnt and b.number=c.ar_inumber)='0'
                     )

       )
       AS ar_account_balance
     
       FROM master_snapshot a
       WHERE #a#gh# AND a.master_type='armaster'
       HAVING snapshot_balance - ar_account_balance <> 0
       ORDER BY a.hotel_group_id,a.hotel_id,a.master_type,a.id
