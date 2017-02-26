/*
----each----:[rep_dai_history.credit07][rep_dai_history.sumcre]
*/

select 
       a.hotel_group_id as gid,
       a.hotel_id       as hid,
       date(a.biz_date) as biz_date,
       a.classno,         
       a.descript,
       a.credit01,
       a.credit02,
       a.credit03,
       a.credit04,
       a.credit05,
       a.credit06,
       a.credit07,
       a.credit01+a.credit02+a.credit03+a.credit04+a.credit05+a.credit06+a.credit07 as computed_sumcre,
       a.sumcre,
       a.credit01+a.credit02+a.credit03+a.credit04+a.credit05+a.credit06+a.credit07 - a.sumcre as diff
       from rep_dai_history a
       where #a#gh# and a.classno like '01%' and 
             a.credit01+a.credit02+a.credit03+a.credit04+a.credit05+a.credit06+a.credit07 - a.sumcre <> 0 
       order by a.hotel_group_id,a.hotel_id,a.biz_date,a.classno
;
             