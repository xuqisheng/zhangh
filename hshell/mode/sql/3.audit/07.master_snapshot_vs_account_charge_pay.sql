/*
----each----:[master_snapshot]
----each----:[account][account_history]
*/

SELECT a.hotel_group_id as gid,
       a.hotel_id as hid,
       a.id,
       a.sta,
       a.rmno,
       a.master_type,
       a.master_id,
       date_format(a.biz_date_begin,'%Y-%m-%d')            as biz_date_b,
       date_format(a.biz_date_end,'%Y-%m-%d')              as biz_date_e,
       date_format(adddate(a.biz_date_begin,1),'%Y-%m-%d') as bdate,

       (SELECT IFNULL(SUM(b.charge),0)
               FROM account b
               WHERE #ba#gh# AND 
                     b.accnt=a.master_id AND b.biz_date=adddate(a.biz_date_begin,1))
       +
       (SELECT IFNULL(SUM(b.charge),0)
               FROM account_history b
               WHERE #ba#gh# AND 
                     b.accnt=a.master_id AND b.biz_date=adddate(a.biz_date_begin,1))
       AS account_charge,

       a.charge_ttl AS snap_charge,

       (SELECT IFNULL(SUM(b.charge),0)
               FROM account b
               WHERE #ba#gh# AND 
                     b.accnt=a.master_id AND b.biz_date=adddate(a.biz_date_begin,1))
       +
       (SELECT IFNULL(SUM(b.charge),0)
               FROM account_history b
               WHERE #ba#gh# AND 
                     b.accnt=a.master_id AND b.biz_date=adddate(a.biz_date_begin,1))
       - a.charge_ttl

       as diff_charge,

       (SELECT IFNULL(SUM(b.pay),0)
               FROM account b
               WHERE #ba#gh# AND 
                     b.accnt=a.master_id AND b.biz_date=adddate(a.biz_date_begin,1))
       +
       (SELECT IFNULL(SUM(b.pay),0)
               FROM account_history b
               WHERE #ba#gh# AND 
                     b.accnt=a.master_id AND b.biz_date=adddate(a.biz_date_begin,1))
       AS account_pay,

       a.pay_ttl    AS snap_pay,

       (SELECT IFNULL(SUM(b.pay),0)
               FROM account b
               WHERE #ba#gh# AND 
                     b.accnt=a.master_id AND b.biz_date=adddate(a.biz_date_begin,1))
       +
       (SELECT IFNULL(SUM(b.pay),0)
               FROM account_history b
               WHERE #ba#gh# AND 
                     b.accnt=a.master_id AND b.biz_date=adddate(a.biz_date_begin,1))
       - a.pay_ttl
     
       AS diff_pay

       FROM master_snapshot a
       WHERE #a#gh# AND (a.master_type='master' or a.master_type='consume')
       HAVING diff_charge <> 0 or diff_pay <> 0
       ORDER BY a.biz_date_begin,a.master_type,a.master_id
                                              
         