/*
----each----:[stopped_because_of_cc]
----each----:[pos_deptdai_history.hotel_group_id][pos_deptdai_history.hotel_id]
----each----:[pos_deptdai_history.biz_date][pos_deptdai_history.code]
----each----:[#pos_deptdai_history:hotel_group_id,hotel_id,biz_date,code]
*/

create index modeindex_date_code on pos_deptdai_history(hotel_group_id,hotel_id,biz_date,code)
