/*
----each----:[master_snapshot][ar_account][ar_detail]
*/

SELECT a.hotel_group_id as gid,
       a.hotel_id       as hid,
       a.id,
       a.sta,
       a.master_type,
       a.master_id,
       date_format(a.biz_date_begin,'%Y-%m-%d')            as biz_date_b,
       date_format(a.biz_date_end,'%Y-%m-%d')              as biz_date_e,
       date_format(adddate(a.biz_date_begin,1),'%Y-%m-%d') as bdate,

       (SELECT IFNULL(SUM(c.charge),0)
               FROM  ar_detail c 
               WHERE #ca#gh# AND 
                     c.ar_accnt=a.master_id and 
                     c.biz_date = adddate(a.biz_date_begin,1) and 
                     (c.ar_subtotal='F' OR
                      c.ar_subtotal='T' AND
                      (select b.audit_tag from ar_account b where #bc#gh# and b.accnt=c.ar_accnt and b.number=c.ar_inumber)='0'
                     )

       )
       AS ar_charge,

       a.charge_ttl AS snap_charge,

       (SELECT IFNULL(SUM(c.charge),0)
               FROM  ar_detail c 
               WHERE #ca#gh# AND 
                     c.ar_accnt=a.master_id and 
                     c.biz_date = adddate(a.biz_date_begin,1) and 
                     (c.ar_subtotal='F' OR
                      c.ar_subtotal='T' AND
                      (select b.audit_tag from ar_account b where #bc#gh# and b.accnt=c.ar_accnt and b.number=c.ar_inumber)='0'
                     )

       ) 
       - 
       a.charge_ttl
       as diff_charge,


       (SELECT IFNULL(SUM(c.pay),0)
               FROM  ar_detail c 
               WHERE #ca#gh# AND 
                     c.ar_accnt=a.master_id and 
                     c.biz_date = adddate(a.biz_date_begin,1) and 
                     (c.ar_subtotal='F' OR
                      c.ar_subtotal='T' AND
                      (select b.audit_tag from ar_account b where #bc#gh# and b.accnt=c.ar_accnt and b.number=c.ar_inumber)='0'
                     )

       )
       AS ar_pay,
       a.pay_ttl    AS snap_pay,

       (SELECT IFNULL(SUM(c.pay),0)
               FROM  ar_detail c 
               WHERE #ca#gh# AND 
                     c.ar_accnt=a.master_id and 
                     c.biz_date = adddate(a.biz_date_begin,1) and 
                     (c.ar_subtotal='F' OR
                      c.ar_subtotal='T' AND
                      (select b.audit_tag from ar_account b where #bc#gh# and b.accnt=c.ar_accnt and b.number=c.ar_inumber)='0'
                     )

       )
       -
       a.pay_ttl

       as diff_pay
     
       FROM master_snapshot a
       WHERE #a#gh# AND a.master_type='armaster'
       HAVING diff_charge <> 0 or diff_pay <> 0 
       ORDER BY a.biz_date_begin,a.master_type,a.master_id


