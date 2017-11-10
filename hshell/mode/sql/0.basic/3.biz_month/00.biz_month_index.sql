/* biz_month index */
/*
----each----:[biz_month.hotel_group_id][biz_month.hotel_id][biz_month.begin_date]
----each----:[#biz_month:hotel_group_id,hotel_id,begin_date]
*/
create index mi_gid_hid_begin_date on biz_month (hotel_group_id,hotel_id,begin_date);
/*
----each----:[biz_month.hotel_group_id][biz_month.hotel_id][biz_month.end_date]
----each----:[#biz_month:hotel_group_id,hotel_id,end_date]
*/
create index mi_gid_hid_end_date on biz_month (hotel_group_id,hotel_id,end_date);