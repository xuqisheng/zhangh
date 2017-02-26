/* master_snapshot deltail continuity check */
/*
*/
SELECT date(a.biz_date_end) as repbdate,
       a.id,
       a.hotel_group_id as gid,
       a.hotel_id as hid,
       a.master_type,
       a.master_id,
       a.sta,
       a.rmno,
       date(a.biz_date_begin) as biz_date_b,
       date(a.biz_date_end)  as biz_date_e,
       a.till_balance AS tillbl,
       (
        SELECT sum(b.last_balance) FROM master_snapshot b
               WHERE #ba#gh#
                     AND b.master_type = a.master_type
                     AND b.master_id   = a.master_id
                     AND b.biz_date_begin = a.biz_date_end
       ) 
       AS next_lastbl
       FROM master_snapshot a
       WHERE #a#gh#
             and 
             (  
               -- case 1
               a.sta = 'O' and a.till_balance <> 0
               or 
               -- case 2
               a.sta <> "O" and a.biz_date_end < (select date_add(c.biz_date,interval -1 day) from audit_flag c where #c#gh# )
               and
               (
                 -- case 2.1 
                 a.sta='I' and a.master_type <> "reser" and not exists
                 (
                  SELECT b.till_balance FROM master_snapshot b
                         WHERE #ba#gh#
                               AND b.master_type=a.master_type
                               AND b.master_id = a.master_id
                               and b.biz_date_begin = a.biz_date_end
                 )
                 or
                 -- case 2.2 
                 (
                  SELECT sum(b.last_balance) FROM master_snapshot b
                         WHERE #ba#gh#
                               AND b.master_type=a.master_type 
                               AND b.master_id = a.master_id
                               AND b.biz_date_begin = a.biz_date_end
                 ) -  a.till_balance
                 <> 0 
               ) 
             )
         ORDER BY a.hotel_group_id,a.hotel_id,a.master_type,a.master_id,a.biz_date_end



