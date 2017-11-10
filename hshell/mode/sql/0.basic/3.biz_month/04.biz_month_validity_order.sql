/* biz_month validity - order */
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
     "end_date should be greater than or equal to begin_date" as remark
     from biz_month a
     where #a#gh# and a.end_date < a.begin_date
     order by a.hotel_group_id,a.hotel_id,a.begin_date,a.end_date
;