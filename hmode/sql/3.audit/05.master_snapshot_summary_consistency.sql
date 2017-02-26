/*
----each----:[master_snapshot.biz_date_begin][master_snapshot.biz_date_end]
----each----:[master_snapshot.last_charge][master_snapshot.last_pay]
----each----:[master_snapshot.till_charge][master_snapshot.till_pay]
----each----:[master_snapshot.plen]
----each----:[rep_dai_history.biz_date][rep_dai_history.classno][rep_dai_history.last_bl][rep_dai_history.till_bl]
*/

select date(a.biz_date) biz_date,
       (select ifnull(sum(b.last_charge - b.last_pay),0) from master_snapshot b where #b#gh# and b.biz_date_begin=a.biz_date - interval 1 day)
       + 
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen=2 and b.biz_date_end=a.biz_date)
       + 
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen=3 and b.biz_date_end=a.biz_date)
       + 
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen=3 and b.biz_date_end=a.biz_date+interval 1 day)
       +
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen>=4 and b.biz_date_end>a.biz_date - interval 1 day and b.biz_date_begin<a.biz_date - interval 1 day)
       as lastbl,



       (select ifnull(sum(b.charge_ttl),0) from master_snapshot b where #ba#gh# and b.biz_date_begin = a.biz_date - interval 1 day)
       as charge_ttl,



       (select ifnull(sum(b.pay_ttl),0) from master_snapshot b where #ba#gh# and b.biz_date_begin = a.biz_date - interval 1 day )
       as pay_tll,


       (select ifnull(sum(b.last_charge - b.last_pay),0) from master_snapshot b where #b#gh# and b.biz_date_begin=a.biz_date - interval 1 day)
       + 
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen=2 and b.biz_date_end=a.biz_date)
       + 
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen=3 and b.biz_date_end=a.biz_date)
       + 
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen=3 and b.biz_date_end=a.biz_date+interval 1 day)
       +
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen>=4 and b.biz_date_end>a.biz_date - interval 1 day and b.biz_date_begin<a.biz_date - interval 1 day)
       +
       (select ifnull(sum(b.charge_ttl),0) from master_snapshot b where #ba#gh# and b.biz_date_begin = a.biz_date - interval 1 day)
       -
       (select ifnull(sum(b.pay_ttl),0) from master_snapshot b where #ba#gh# and b.biz_date_begin = a.biz_date - interval 1 day )
       as computed_tillbl,



       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.biz_date_end=a.biz_date)
       +
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen=2 and b.biz_date_end=a.biz_date + interval 1 day)
       + 
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen=3 and b.biz_date_end=a.biz_date+interval 1 day)
       + 
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen=3 and b.biz_date_end=a.biz_date + interval 2 day)
       +
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen>=4 and b.biz_date_end>a.biz_date and b.biz_date_begin<a.biz_date)
       as tillbl,

       (select ifnull(sum(b.last_charge - b.last_pay),0) from master_snapshot b where #b#gh# and b.biz_date_begin=a.biz_date - interval 1 day)
       + 
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen=2 and b.biz_date_end=a.biz_date)
       + 
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen=3 and b.biz_date_end=a.biz_date)
       +
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen>=4 and b.biz_date_end>a.biz_date - interval 1 day and b.biz_date_begin<a.biz_date - interval 1 day)
     
       +
       (select ifnull(sum(b.charge_ttl),0) from master_snapshot b where #ba#gh# and b.biz_date_begin = a.biz_date - interval 1 day)
       -
       (select ifnull(sum(b.pay_ttl),0) from master_snapshot b where #ba#gh# and b.biz_date_begin = a.biz_date - interval 1 day )
       -  
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.biz_date_end=a.biz_date)
       -
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen=2 and b.biz_date_end=a.biz_date + interval 1 day)
       - 
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen=3 and b.biz_date_end=a.biz_date + interval 2 day)
       -
       (select ifnull(sum(b.till_charge - b.till_pay),0) from master_snapshot b where #b#gh# and b.plen>=4 and b.biz_date_end>a.biz_date and b.biz_date_begin<a.biz_date)

       as diff_2modes

       from rep_dai_history a

       where #a#gh# and a.classno='02000'
       group by a.biz_date
       having diff_2modes <> 0
       order by a.biz_date
             
