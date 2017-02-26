/* biz_month validity - month */
/*
----each----:[biz_month.hotel_group_id][biz_month.hotel_id]
----each----:[biz_month.begin_date][biz_month.end_date]
----each----:[biz_month.biz_year][biz_month.biz_month]
----dbug----
*/
select
     a.hotel_group_id,
     a.hotel_id,
     date(a.begin_date) as b_date,
     date(a.end_date)   as e_date,
     a.biz_year,
     a.biz_month,
     "month not between 1 and 12" as remark
     from biz_month a
     where #a#gh# and not (a.biz_month >=1 and a.biz_month <= 12)
     order by a.hotel_group_id,a.hotel_id,a.begin_date,a.end_date
;