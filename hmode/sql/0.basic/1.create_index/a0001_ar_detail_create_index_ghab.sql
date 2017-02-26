/*
----each----:[ar_detail.hotel_group_id][ar_detail.hotel_id][ar_detail.ar_accnt][ar_detail.biz_date]
----each----:[#ar_detail:hotel_group_id,hotel_id,ar_accnt,biz_date]
*/

create index ghab on ar_detail(hotel_group_id,hotel_id,ar_accnt,biz_date)
