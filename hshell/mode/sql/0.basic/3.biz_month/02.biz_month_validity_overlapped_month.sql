/* biz_month validity - overlapped month */
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
     "date overlapped with " remark,
     (select date(c.begin_date) from biz_month c
                                where c.id = (select min(id) from biz_month b where #ba#gh# and (b.begin_date >= a.begin_date and b.begin_date <= a.end_date) and b.id <> a.id )
     ) b_date_1,
     (select date(c.end_date) from biz_month c
                                where c.id = (select min(id) from biz_month b where #ba#gh# and (b.begin_date >= a.begin_date and b.begin_date <= a.end_date) and b.id <> a.id )
     ) e_date_1
     from biz_month a
     where #a#gh# and a.end_date < (select max(b.end_date) from biz_month b where #ba#gh#) and 
           exists (select 1 from biz_month b where #ba#gh# and (b.begin_date >= a.begin_date and b.begin_date <= a.end_date) and b.id <> a.id )
     order by a.hotel_group_id,a.hotel_id,a.begin_date,a.end_date,id
;
