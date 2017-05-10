select date(a.biz_date) biz_date,
       ifnull(sum(a.last_bl),0) rep_dai_last_bl,
       ifnull(sum(a.till_bl),0) rep_dai_till_bl,

       (select ifnull(sum(b.last_balance),0) from master_snapshot b where b.hotel_group_id=2 and b.hotel_id=18 and b.biz_date_begin=a.biz_date - interval 1 day AND b.master_type='armaster') + 
       (select ifnull(sum(b.last_balance),0) from master_snapshot b where b.hotel_group_id=2 and b.hotel_id=18  and b.plen>1 and b.biz_date_end>=a.biz_date and b.biz_date_begin<a.biz_date - interval 1 day AND b.master_type='armaster')
       as snapshot_last_bl,

       (select ifnull(sum(b.till_balance),0) from master_snapshot b where b.hotel_group_id=2 and b.hotel_id=18 and b.plen=1 and b.biz_date_end = a.biz_date AND b.master_type='armaster')
       +
       (select ifnull(sum(b.till_balance),0) from master_snapshot b where b.hotel_group_id=2 and b.hotel_id=18  and b.plen>1 and b.biz_date_begin < a.biz_date and b.biz_date_end >=a.biz_date AND b.master_type='armaster')
       as snapshot_till_bl,

       ifnull(sum(a.last_bl),0) 
       - 
       (select ifnull(sum(b.last_balance),0) from master_snapshot b where b.hotel_group_id=2 and b.hotel_id=18 and b.biz_date_begin=a.biz_date - interval 1 day AND b.master_type='armaster') 
       - 
       (select ifnull(sum(b.last_balance),0) from master_snapshot b where b.hotel_group_id=2 and b.hotel_id=18  and b.plen>1 and b.biz_date_end>=a.biz_date and b.biz_date_begin<a.biz_date - interval 1 day AND b.master_type='armaster')
       as diff_last_bl,

       ifnull(sum(a.till_bl),0) 
       - 
       (select ifnull(sum(b.till_balance),0) from master_snapshot b where b.hotel_group_id=2 and b.hotel_id=18 and b.plen=1 and b.biz_date_end = a.biz_date AND b.master_type='armaster')
       -
       (select ifnull(sum(b.till_balance),0) from master_snapshot b where b.hotel_group_id=2 and b.hotel_id=18 and b.plen>1 and b.biz_date_begin < a.biz_date and b.biz_date_end >=a.biz_date AND b.master_type='armaster')
       as diff_till_bl

       from rep_dai_history a
       where a.hotel_group_id=2 and a.hotel_id=18 and a.classno='03000'
       group by a.biz_date
       having diff_last_bl <> 0 or diff_till_bl <> 0
       order by a.biz_date
             