/*
----each----:[master_snapshot.biz_date_begin][master_snapshot.biz_date_end][master_snapshot.charge_ttl][master_snapshot.pay_ttl]
----each----:[rep_dai_history.biz_date][rep_dai_history.classno][rep_dai_history.debit][rep_dai_history.credit]
*/

select date(a.biz_date) biz_date,
       ifnull(sum(a.debit),0) rep_dai_debit,

       ifnull(sum(a.credit),0) rep_dai_credit,

       (select ifnull(sum(b.charge_ttl),0) from master_snapshot b where #ab#gh# and b.biz_date_begin = a.biz_date - interval 1 day) as snapshot_charge,

       (select ifnull(sum(b.pay_ttl),0) from master_snapshot b where #ab#gh# and b.biz_date_begin = a.biz_date - interval 1 day ) as snapshot_pay,

       ifnull(sum(a.debit),0) - 
       (select ifnull(sum(b.charge_ttl),0) from master_snapshot b where #ab#gh# and b.biz_date_begin = a.biz_date - interval 1 day)
       as diff_debit_charge,

       ifnull(sum(a.credit),0) - 
       (select ifnull(sum(b.pay_ttl),0) from master_snapshot b where #ab#gh# and b.biz_date_begin = a.biz_date - interval 1 day )
       as diff_credit_pay

       from rep_dai_history a

       where #a#gh# and (a.classno='02000' or a.classno='03000')
       group by a.biz_date
       having diff_debit_charge <> 0 or diff_credit_pay <> 0
       order by a.biz_date
             