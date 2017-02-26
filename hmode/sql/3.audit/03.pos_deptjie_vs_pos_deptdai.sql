/*
----each----:[pos_deptjie_history][pos_deptdai_history]
*/

select 
       a.hotel_group_id gid,
       a.hotel_id hid,
       date(a.biz_date) biz_date,
       ifnull(sum(a.amount_day),0) jie_amount_day,
       (select ifnull(sum(b.amount_day),0) from pos_deptdai_history b where #ab#gh# and b.biz_date=a.biz_date) dai_amount_day,
       ifnull(sum(a.amount_day),0) - (select ifnull(sum(b.amount_day),0) from pos_deptdai_history b where #ab#gh# and b.biz_date=a.biz_date) jie_dai_diff
       from pos_deptjie_history a
       where #a#gh#
       group by a.hotel_group_id,a.hotel_id,a.biz_date
       having jie_dai_diff <> 0
       order by a.hotel_group_id,a.hotel_id,a.biz_date
             