/*
----each----:[code_transaction.hotel_group_id][code_transaction.hotel_id][code_transaction.cat_sum][code_transaction.code]
----each----:[#code_transaction:hotel_group_id,hotel_id,cat_sum,code]
*/
create index imi_gid_hid_cat_sum_code on code_transaction(hotel_group_id,hotel_id,cat_sum,code);
