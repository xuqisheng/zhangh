/*
----each----:[hotel][rep_jie][rep_dai][audit_flag][#hotel.client_type]
*/
select  hotel_group_id,
        (select b.code from hotel_group b where b.id=hotel.hotel_group_id) as hotel_group_code,
        id as hotel_id,
        code hotel_code,
        descript hotel_descript,
        (select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) as biz_date,
        (select a.day99 from rep_jie_history a
                         where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and
                               a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                               a.classno=(select max(b.classno) from rep_jie b where b.hotel_group_id=a.hotel_group_id and b.hotel_id=a.hotel_id)
        ) as rep_jie_history,
        (select ifnull(sum(a.sumcre),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and 
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                                                             a.classno='01010') +
        (select ifnull(sum(a.debit-a.credit),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and 
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                                                             (a.classno='02000' or a.classno='03000')) -  
        (select ifnull(sum(a.debit-a.credit),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and 
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                                                             (a.classno='04000')) +  
        (select ifnull(sum(a.sumcre),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and 
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                                                             (a.classno='06000' or a.classno='08000'))  as rep_dai_history

        from hotel
        where sta='I' and (select min(c.biz_date) from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id) = date(now()) and 
              (select a.day99 from rep_jie_history a
                         where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and
                               a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                               a.classno=(select max(b.classno) from rep_jie b where b.hotel_group_id=a.hotel_group_id and b.hotel_id=a.hotel_id)
              ) <>
        (select ifnull(sum(a.sumcre),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and 
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                                                             a.classno='01010') +
        (select ifnull(sum(a.debit-a.credit),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and 
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                                                             (a.classno='02000' or a.classno='03000')) -  
        (select ifnull(sum(a.debit-a.credit),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and 
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                                                             (a.classno='04000')) +  
        (select ifnull(sum(a.sumcre),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and 
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                                                             (a.classno='06000' or a.classno='08000'))
        order by hotel_group_id,id
;
/*
----each----:[hotel][rep_jie][rep_dai][audit_flag][hotel.client_type][#hotel.client_version]
*/
select  hotel_group_id,
        (select b.code from hotel_group b where b.id=hotel.hotel_group_id) as hotel_group_code,
        id as hotel_id,
        code hotel_code,
        descript hotel_descript,
        (select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) as biz_date,
        (select a.day99 from rep_jie_history a
                         where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and
                               a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                               a.classno=(select max(b.classno) from rep_jie b where b.hotel_group_id=a.hotel_group_id and b.hotel_id=a.hotel_id)
        ) as rep_jie_history,
        (select ifnull(sum(a.sumcre),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and 
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                                                             a.classno='01010') +
        (select ifnull(sum(a.debit-a.credit),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and 
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                                                             (a.classno='02000' or a.classno='03000')) -  
        (select ifnull(sum(a.debit-a.credit),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and 
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                                                             (a.classno='04000')) +  
        (select ifnull(sum(a.sumcre),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and 
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                                                             (a.classno='06000' or a.classno='08000'))  as rep_dai_history,
        if(client_type='THEF','商务版或快捷版','标准版') version

        from hotel
        where sta='I' and (select min(c.biz_date) from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id) = date(now()) and 
              (select a.day99 from rep_jie_history a
                         where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and
                               a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                               a.classno=(select max(b.classno) from rep_jie b where b.hotel_group_id=a.hotel_group_id and b.hotel_id=a.hotel_id)
              ) <>
        (select ifnull(sum(a.sumcre),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and 
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                                                             a.classno='01010') +
        (select ifnull(sum(a.debit-a.credit),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and 
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                                                             (a.classno='02000' or a.classno='03000')) -  
        (select ifnull(sum(a.debit-a.credit),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and 
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                                                             (a.classno='04000')) +  
        (select ifnull(sum(a.sumcre),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and 
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and 
                                                             (a.classno='06000' or a.classno='08000'))
        order by hotel_group_id,id
;
/*
----each----:[hotel][rep_jie][rep_dai][audit_flag][hotel.client_type][hotel.client_version]
*/
select  hotel_group_id,
        (select b.code from hotel_group b where b.id=hotel.hotel_group_id) as hotel_group_code,
        id as hotel_id,
        code hotel_code,
        descript hotel_descript,
        (select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) as biz_date,
        (select a.day99 from rep_jie_history a
                         where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and
                               a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and
                               a.classno=(select max(b.classno) from rep_jie b where b.hotel_group_id=a.hotel_group_id and b.hotel_id=a.hotel_id)
        ) as rep_jie_history,
        (select ifnull(sum(a.sumcre),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and
                                                             a.classno='01010') +
        (select ifnull(sum(a.debit-a.credit),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and
                                                             (a.classno='02000' or a.classno='03000')) -
        (select ifnull(sum(a.debit-a.credit),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and
                                                             (a.classno='04000')) +
        (select ifnull(sum(a.sumcre),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and
                                                             (a.classno='06000' or a.classno='08000'))  as rep_dai_history,
        if(client_type='THEF',if(client_version='THEK','快捷版','商务版'),'标准版') version

        from hotel
        where sta='I' and (select min(c.biz_date) from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id) = date(now()) and
              (select a.day99 from rep_jie_history a
                         where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and
                               a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and
                               a.classno=(select max(b.classno) from rep_jie b where b.hotel_group_id=a.hotel_group_id and b.hotel_id=a.hotel_id)
              ) <>
        (select ifnull(sum(a.sumcre),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and
                                                             a.classno='01010') +
        (select ifnull(sum(a.debit-a.credit),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and
                                                             (a.classno='02000' or a.classno='03000')) -
        (select ifnull(sum(a.debit-a.credit),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and
                                                             (a.classno='04000')) +
        (select ifnull(sum(a.sumcre),0) from rep_dai_history a where a.hotel_group_id=hotel.hotel_group_id and a.hotel_id=hotel.id and
                                                             a.biz_date=(select min(c.biz_date)-interval 2 day  from audit_flag c where c.hotel_group_id=hotel.hotel_group_id and c.hotel_id=hotel.id ) and
                                                             (a.classno='06000' or a.classno='08000'))
        order by hotel_group_id,id
;

