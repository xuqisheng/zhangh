/*
----each----:[rep_jie_history.hotel_group_id][rep_jie_history.hotel_id]
----each----:[rep_jie_history.biz_date][rep_jie_history.classno]
----each----:[#rep_jie_history:hotel_group_id,hotel_id,biz_date,classno]
*/

create unique index modeindex_date_classno on rep_jie_history(hotel_group_id,hotel_id,biz_date,classno)
