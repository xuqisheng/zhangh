/* biz_month validity - completeness */
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
     (select date(min(b.begin_date)) from  biz_month b where #ba#gh# and b.begin_date > a.begin_date) as next_b_date,
     "date gap occurred between end_date and next begin_date" as remark
     from biz_month a
     where #a#gh# and a.end_date < (select max(b.end_date) from biz_month b where #ba#gh#) and 
           (select date(min(b.begin_date)) from  biz_month b where #ba#gh# and b.begin_date > a.begin_date) > date_add(a.end_date,interval 1 day)
     order by a.hotel_group_id,a.hotel_id,a.begin_date
;
