/*
----each----:[rep_jiedai_history.hotel_group_id][rep_jiedai_history.hotel_id]
----each----:[rep_jiedai_history.biz_date][rep_jiedai_history.classno]
----each----:[#rep_jiedai_history:hotel_group_id,hotel_id,biz_date,classno]
*/

create unique index modeindex_date_classno on rep_jiedai_history(hotel_group_id,hotel_id,biz_date,classno)
