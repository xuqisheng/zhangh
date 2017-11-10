/*
----each----:[pos_deptjie_history.code][code_transaction.code]
*/

select c.hotel_group_id as gid,c.hotel_id as hid,c.code,c.descript,c.remark
       from 
       (select
       a.hotel_group_id,
       a.hotel_id,
       a.code,
       a.descript,
       'code not in table code_transaction' as remark
       from pos_deptjie_history a
       where #a#gh# 
       group by a.hotel_group_id,a.hotel_id,a.code,a.descript
       ) c left join code_transaction b
       on #cb#gh# and c.code = b.code 
       where b.code = null
       order by c.hotel_group_id,c.hotel_id,c.code

             