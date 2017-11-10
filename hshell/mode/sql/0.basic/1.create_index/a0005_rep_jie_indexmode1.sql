/*
----each----:[rep_jie.hotel_group_id][rep_jie.hotel_id][rep_jie.classno]
----each----:[#rep_jie:hotel_group_id,hotel_id,classno]
*/

create unique index modeindex_classno on rep_jie (hotel_group_id,hotel_id,classno)
