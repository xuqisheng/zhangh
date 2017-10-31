/*
----each----:[hotel][#hotel.client_type]
*/
select  h.hotel_group_id,
        (select c.code from hotel_group c where c.id=h.hotel_group_id) as hotel_group_code,
        h.id as hotel_id,
        h.code hotel_code,
        h.descript hotel_descript,
        substring(b.set_value,1,10) as valid_date,
        '已到期或15日内将到期提醒' as remark
        from hotel h,sys_option b
        where  h.hotel_group_id=b.hotel_group_id and
               h.id=b.hotel_id and
               b.catalog='system' and b.item='valid_date' and
               not (b.set_value is null or trim(b.set_value) = '') and
               b.set_value <= adddate(date(now()),interval 15 day) and 
               h.sta='I' and 
               ((select min(c.biz_date) from audit_flag c where c.hotel_group_id=h.hotel_group_id and c.hotel_id=h.id) = date(now())
                 or
                (select min(c.biz_date) from audit_flag c where c.hotel_group_id=h.hotel_group_id and c.hotel_id=h.id) = adddate(date(now()),-1)
               )
;
/*
----each----:[hotel][hotel.client_type][#hotel.client_version]
*/
select  h.hotel_group_id,
        (select c.code from hotel_group c where c.id=h.hotel_group_id) as hotel_group_code,
        h.id as hotel_id,
        h.code hotel_code,
        h.descript hotel_descript,
        if(h.client_type='THEF','商务版或快捷版','标准版') version,
        substring(b.set_value,1,10) as valid_date,
        '已到期或15日内将到期提醒' as remark
        from hotel h,sys_option b
        where  h.hotel_group_id=b.hotel_group_id and
               h.id=b.hotel_id and
               b.catalog='system' and b.item='valid_date' and 
               not (b.set_value is null or trim(b.set_value) = '') and 
               b.set_value <= adddate(date(now()),interval 15 day) and 
               h.sta='I' and 
               ((select min(c.biz_date) from audit_flag c where c.hotel_group_id=h.hotel_group_id and c.hotel_id=h.id) = date(now())
                 or
                (select min(c.biz_date) from audit_flag c where c.hotel_group_id=h.hotel_group_id and c.hotel_id=h.id) = adddate(date(now()),-1)
               )
;
/*
----each----:[hotel][hotel.client_type][hotel.client_version]
*/
select  h.hotel_group_id,
        (select c.code from hotel_group c where c.id=h.hotel_group_id) as hotel_group_code,
        h.id as hotel_id,
        h.code hotel_code,
        h.descript hotel_descript,
        if(h.client_type='THEF',if(h.client_version='THEK','快捷版','商务版'),'标准版') version,
        substring(b.set_value,1,10) as valid_date,
        '已到期或15日内将到期提醒' as remark
        from hotel h,sys_option b
        where  h.hotel_group_id=b.hotel_group_id and
               h.id=b.hotel_id and
               b.catalog='system' and b.item='valid_date' and 
               not (b.set_value is null or trim(b.set_value) = '') and 
               b.set_value <= adddate(date(now()),interval 15 day) and 
               h.sta='I' and 
               ((select min(c.biz_date) from audit_flag c where c.hotel_group_id=h.hotel_group_id and c.hotel_id=h.id) = date(now())
                 or
                (select min(c.biz_date) from audit_flag c where c.hotel_group_id=h.hotel_group_id and c.hotel_id=h.id) = adddate(date(now()),-1)
               )
;
