/*
----each----:[rep_dai_history.credit06]
*/

select 
       a.hotel_group_id as gid,
       a.hotel_id       as hid,
       date(a.biz_date) as biz_date,
       (select ifnull(sum(b.credit06),0) from rep_dai_history b where #b#gh# and b.biz_date=a.biz_date and b.classno like '01%' and b.classno <> '01010') as credit06_S,
       (select ifnull(sum(b.credit06),0) from rep_dai_history b where #b#gh# and b.biz_date=a.biz_date and b.classno = '01010') as credit06_T,
       (select ifnull(sum(b.credit06),0) from rep_dai_history b where #b#gh# and b.biz_date=a.biz_date and b.classno like '01%' and b.classno <> '01010')
       -
       (select ifnull(sum(b.credit06),0) from rep_dai_history b where #b#gh# and b.biz_date=a.biz_date and b.classno = '01010')
       as diff
       from rep_dai_history a
       where #a#gh# and a.classno = '01010'
       group by a.hotel_group_id,a.hotel_id,a.biz_date
       having credit06_S <> credit06_T
       order by a.hotel_group_id,a.hotel_id,a.biz_date
;
             