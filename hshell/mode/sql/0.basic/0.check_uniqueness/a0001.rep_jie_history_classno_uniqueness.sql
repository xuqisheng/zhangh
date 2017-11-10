/*
----each----:[rep_jie_history]
*/

select a.hotel_group_id gid,
       a.hotel_id hid,
       date(a.biz_date) biz_date,
       a.classno,
       a.descript
      
       from rep_jie_history a
       where #a#gh# and
             exists(select 1 from rep_jie_history b 
                             where #ab#gh# and
                                   a.biz_date=b.biz_date and 
                                   a.classno=b.classno and 
                                   a.id <> b.id 
                   )
       order by a.hotel_group_id,a.hotel_id,a.biz_date,a.classno

