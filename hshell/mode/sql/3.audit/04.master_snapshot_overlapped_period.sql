/*
----each----:[master_snapshot]
----dbug----
*/

select distinct a.hotel_group_id,a.hotel_id,a.master_type,a.master_id,a.biz_date_begin,a.biz_date_end
       from master_snapshot a
       where #a#gh# 
             and 
             exists (select 1 from master_snapshot b 
                              where 
                                   #ba#gh# and
                                   b.master_type=a.master_type and 
                                   b.master_id=a.master_id and 
                                   b.id <> a.id and 
                                   (b.biz_date_begin >= a.biz_date_begin and b.biz_date_begin < a.biz_date_end
                                    or b.biz_date_end > a.biz_date_begin and b.biz_date_end <= a.biz_date_end)
                    )
       order by a.hotel_group_id,a.hotel_id,a.master_type,a.master_id,a.biz_date_begin,a.biz_date_end

  