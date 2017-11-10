/*
----each----:[rep_jie]
*/

select a.hotel_group_id gid,
       a.hotel_id hid,
       date(a.biz_date) biz_date,
       a.classno,
       a.descript
      
       from rep_jie a
       where #a#gh# and
             exists(select 1 from rep_jie b 
                             where #ab#gh# and
                                   a.classno=b.classno and 
                                   a.id <> b.id 
                   )
       order by a.hotel_group_id,a.hotel_id,a.classno

