/*
----each----:[stopped_because_of_cc]
----each----:[pos_deptjie_history.hotel_group_id][pos_deptjie_history.hotel_id]
----each----:[pos_deptjie_history.biz_date][pos_deptjie_history.code]
----each----:[#pos_deptjie_history:hotel_group_id,hotel_id,code,biz_date]
*/

create index modeindex_code_date on pos_deptjie_history(hotel_group_id,hotel_id,code,biz_date)
