/*
----each----:[account.hotel_group_id][account.hotel_id][account.accnt][account.biz_date]
----each----:[#account:hotel_group_id,hotel_id,accnt,biz_date]
*/

create index ghab on account(hotel_group_id,hotel_id,accnt,biz_date)
