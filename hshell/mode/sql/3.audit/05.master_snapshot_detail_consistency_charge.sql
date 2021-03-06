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
       last_charge,
       charge_ttl,
       till_charge,
      last_charge+charge_ttl - till_charge as diff
      from master_snapshot
      where ##gh# and
             last_charge+charge_ttl <> till_charge
      order by hotel_group_id,hotel_id,master_type,master_id,biz_date_end

