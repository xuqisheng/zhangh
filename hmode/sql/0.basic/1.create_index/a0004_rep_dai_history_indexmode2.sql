/*
----each----:[rep_dai_history.hotel_group_id][rep_dai_history.hotel_id]
----each----:[rep_dai_history.biz_date][rep_dai_history.classno]
----each----:[#rep_dai_history:hotel_group_id,hotel_id,classno,biz_date]
*/

create unique index modeindex_classno_date on rep_dai_history(hotel_group_id,hotel_id,classno,biz_date)
