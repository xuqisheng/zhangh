/* master_snapshot charge_ttl vs account_reserve */
/*
----each----:[master_snapshot][account_reserve]
*/
select a.id,
       a.hotel_group_id as gid,
       a.hotel_id as hid,
       a.master_type,
       a.master_id,
       date(a.biz_date_begin) as biz_date_begin,
       date(a.biz_date_end) as biz_date_end,
       sum(a.charge_ttl) as charge_ttl,
       (select ifnull(sum(b.charge),0) from account_reserve b  
                                       where #b#gh# and
                                             b.accnt = a.master_id and
                                             b.biz_date = a.biz_date_begin+interval 1 day)
       -
       (select ifnull(sum(b.charge),0) from account_reserve b  
                                       where #b#gh# and
                                             b.accnt = a.master_id and
                                             b.cancle_bizdate = a.biz_date_begin+interval 1 day)
       -
       (select ifnull(sum(b.charge),0) from account_reserve b  
                                       where #b#gh# and
                                             b.accnt = a.master_id and
                                             b.tran_bizdate = a.biz_date_begin+interval 1 day) as account_reserve_charge_ttl
from master_snapshot a
where #a#gh# and a.master_type='reser'
group by a.hotel_group_id,a.hotel_id,a.master_type,a.master_id,a.biz_date_begin,a.biz_date_end
having charge_ttl <> account_reserve_charge_ttl
order by a.hotel_group_id,a.hotel_id,a.master_type,a.master_id,a.biz_date_begin,a.biz_date_end
;

