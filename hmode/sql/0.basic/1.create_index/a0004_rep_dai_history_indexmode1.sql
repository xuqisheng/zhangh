/*
----each----:[rep_dai_history.hotel_group_id][rep_dai_history.hotel_id]
----each----:[rep_dai_history.biz_date][rep_dai_history.classno]
----each----:[#rep_dai_history:hotel_group_id,hotel_id,biz_date,classno]
*/

create unique index modeindex_date_classno on rep_dai_history(hotel_group_id,hotel_id,biz_date,classno)
