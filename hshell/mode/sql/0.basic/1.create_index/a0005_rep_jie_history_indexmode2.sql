/*
----each----:[rep_jie_history.hotel_group_id][rep_jie_history.hotel_id]
----each----:[rep_jie_history.biz_date][rep_jie_history.classno]
----each----:[#rep_jie_history:hotel_group_id,hotel_id,classno,biz_date]
*/

create unique index modeindex_classno_date on rep_jie_history(hotel_group_id,hotel_id,classno,biz_date)
