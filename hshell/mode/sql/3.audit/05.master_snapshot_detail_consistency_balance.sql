/*
*/

select 
       date(biz_date_end) as repbdate,
       id,
       hotel_group_id as gid,
       hotel_id as hid,
       master_type,
       master_id,
       sta,
       rmno,
       date(biz_date_begin) as biz_date_b,
       date(biz_date_end)  as biz_date_e,
       last_balance,
       charge_ttl,
       pay_ttl,
       till_balance,
       last_balance+charge_ttl-pay_ttl  - till_balance as diff
       from master_snapshot
       where ##gh# and
             last_balance+charge_ttl-pay_ttl <> till_balance
       order by hotel_group_id,hotel_id,master_type,master_id,biz_date_end

