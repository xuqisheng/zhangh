/*
----each----:[rep_jiedai_history.hotel_group_id][rep_jiedai_history.hotel_id]
----each----:[rep_jiedai_history.biz_date][rep_jiedai_history.classno]
----each----:[#rep_jiedai_history:hotel_group_id,hotel_id,classno,biz_date]
*/

create unique index modeindex_classno_date on rep_jiedai_history(hotel_group_id,hotel_id,classno,biz_date)
