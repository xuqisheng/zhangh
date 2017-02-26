/* biz_month validity - warning */
/*
----each----:[biz_month.hotel_group_id][biz_month.hotel_id]
----each----:[biz_month.begin_date][biz_month.end_date]
----each----:[biz_month.biz_year][biz_month.biz_month]
----each----:[audit_flag.biz_date]
*/
select
     a.hotel_group_id,
     a.hotel_id,
     date(a.begin_date) as b_date,
     date(a.end_date)   as e_date,
     a.biz_year,
     a.biz_month,
     "suggest defining more data" as remark
     from biz_month a
     where #a#gh# and a.end_date = (select max(b.end_date) from biz_month b where #ba#gh# ) and 
           datediff((select max(b.end_date) from biz_month b where #ba#gh#),(select b.biz_date from audit_flag b where #ba#gh#)) < 100
     order by a.hotel_group_id,a.hotel_id,a.begin_date,a.end_date
;