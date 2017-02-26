/*
----each----:[this_sql_will_not_be_used_by_each]
----each----:[master_snapshot.biz_date_begin][master_snapshot.biz_date_end]
----each----:[master_snapshot.last_charge][master_snapshot.last_pay]
----each----:[master_snapshot.till_charge][master_snapshot.till_pay]
----each----:[master_snapshot.plen]
----each----:[rep_dai_history.biz_date][rep_dai_history.classno][rep_dai_history.last_bl][rep_dai_history.till_bl]
*/

select date(a.biz_date) biz_date,
       ifnull(sum(a.last_bl),0) rep_dai_last_bl,

       ifnull(sum(a.till_bl),0) rep_dai_till_bl,

       (select ifnull(sum(b.last_charge - b.last_pay),0) from master_snapshot b where #b#gh# and b.biz_date_begin=a.biz_date - interval 1 day ) + 
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh#  and b.plen>1 and b.biz_date_end>=a.biz_date and b.biz_date_begin<a.biz_date - interval 1 day)
       as snapshot_last_bl,

       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen=1 and b.biz_date_end = a.biz_date)
       +
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh#  and b.plen>1 and b.biz_date_begin < a.biz_date and b.biz_date_end >=a.biz_date)
       as snapshot_till_bl,

       ifnull(sum(a.last_bl),0) 
       - 
       (select ifnull(sum(b.last_charge - b.last_pay),0) from master_snapshot b where #b#gh# and b.biz_date_begin=a.biz_date - interval 1 day ) 
       - 
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh#  and b.plen>1 and b.biz_date_end>=a.biz_date and b.biz_date_begin<a.biz_date - interval 1 day)
       as diff_last_bl,

       ifnull(sum(a.till_bl),0) 
       - 
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen=1 and b.biz_date_end = a.biz_date)
       -
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen>1 and b.biz_date_begin < a.biz_date and b.biz_date_end >=a.biz_date)
       as diff_till_bl


       from rep_dai_history a

       where #a#gh# and (a.classno='02000' or a.classno='03000')
       group by a.biz_date
       having diff_last_bl <> 0 or diff_till_bl <> 0
       order by a.biz_date
             