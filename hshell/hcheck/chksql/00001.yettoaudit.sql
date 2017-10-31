/*
----each----:[hotel][audit_flag][#hotel.client_type]
*/
select hotel_group_id,(select b.code from hotel_group b where b.id=hotel.hotel_group_id) as hotel_group_code,id as hotel_id,code hotel_code,
        descript hotel_descript,(select min(c.biz_date) from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) as biz_date,
        '本营业日夜审待完成' remark
        from hotel
        where sta='I' and (select min(c.biz_date) from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) < curdate()
              and (select min(c.biz_date) from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) > adddate(curdate(),-30)
        order by hotel_group_id,id
;
/*
----each----:[hotel][audit_flag][hotel.client_type][#hotel.client_version]
*/
select hotel_group_id,(select b.code from hotel_group b where b.id=hotel.hotel_group_id) as hotel_group_code,id as hotel_id,code hotel_code,
        descript hotel_descript,(select min(c.biz_date) from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) as biz_date,
        '本营业日夜审待完成' remark,
        if(client_type='THEF','商务版或快捷版','标准版') version
        from hotel
        where sta='I' and (select min(c.biz_date) from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) < curdate()
              and (select min(c.biz_date) from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) > adddate(curdate(),-30)
        order by hotel_group_id,id
;
/*
----each----:[hotel][audit_flag][hotel.client_type][hotel.client_version]
*/
select hotel_group_id,(select b.code from hotel_group b where b.id=hotel.hotel_group_id) as hotel_group_code,id as hotel_id,code hotel_code,
        descript hotel_descript,(select min(c.biz_date) from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) as biz_date,
        '本营业日夜审待完成' remark,
        if(client_type='THEF',if(client_version='THEK','快捷版','商务版'),'标准版') version
        from hotel
        where sta='I' and (select min(c.biz_date) from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) < curdate()
              and (select min(c.biz_date) from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) > adddate(curdate(),-30)
        order by hotel_group_id,id
;
