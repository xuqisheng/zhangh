/* master_snapshot last_pay vs account_deposit */
/*
----each----:[master_snapshot][account_deposit]
*/
select a.id,
       a.hotel_group_id as gid,
       a.hotel_id as hid,
       a.master_type,
       a.master_id,
       date(a.biz_date_begin) as biz_date_begin,
       date(a.biz_date_end) as biz_date_end,
       sum(a.last_pay) as last_pay,
       (select ifnull(sum(b.pay),0) from account_deposit b  
                                       where #b#gh# and
                                             b.accnt = a.master_id and
                                             b.biz_date <= a.biz_date_begin)
       -
       (select ifnull(sum(b.pay),0) from account_deposit b  
                                       where #b#gh# and
                                             b.accnt = a.master_id and
                                             b.cancle_bizdate <= a.biz_date_begin)
       -
       (select ifnull(sum(b.pay),0) from account_deposit b  
                                       where #b#gh# and
                                             b.accnt = a.master_id and
                                             b.tran_bizdate <= a.biz_date_begin) as account_deposit_last_pay
from master_snapshot a
where #a#gh# and a.master_type='reser'
group by a.hotel_group_id,a.hotel_id,a.master_type,a.master_id,a.biz_date_begin,a.biz_date_end
having last_pay <> account_deposit_last_pay
order by a.hotel_group_id,a.hotel_id,a.master_type,a.master_id,a.biz_date_begin,a.biz_date_end
;

