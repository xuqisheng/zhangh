/*
----each----:[todo]
----each----:[master_snapshot]
----each----:[account][account_history]
*/

SELECT a.hotel_group_id,
       a.hotel_id,
       a.id,
       a.sta,
       a.rmno,
       a.master_type,
       a.master_id,
       a.biz_date_begin,
       a.biz_date_end,
       a.till_balance AS snapshot_balance,
       (SELECT IFNULL(SUM(b.charge-b.pay),0)
               FROM account b
               WHERE #ba#gh# AND 
                     b.accnt=a.master_id AND b.biz_date<=a.biz_date_end)
       +
       (SELECT IFNULL(SUM(b.charge-b.pay),0)
               FROM account_history b
               WHERE #ba#gh# AND 
                     b.accnt=a.master_id AND b.biz_date<=a.biz_date_end)
       AS account_balance
     

       FROM master_snapshot a
       WHERE #a#gh# AND 
             (a.master_type='master' or a.master_type='consume')
       HAVING snapshot_balance - account_balance <> 0
       ORDER BY a.hotel_group_id,a.hotel_id,a.master_type,a.id
                                              
         