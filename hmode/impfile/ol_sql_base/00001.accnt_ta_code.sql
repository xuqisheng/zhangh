/*
----each----:[account.hotel_group_id][account.hotel_id][account.accnt][account.ta_code]
----each----:[#account:pofmi_tacode=hotel_group_id,hotel_id,accnt,ta_code]
----each----:[#account:pofimi_gid_hid_accnt_ta_code=hotel_group_id,hotel_id,accnt,ta_code]
*/
create index imi_gid_hid_accnt_ta_code on account(hotel_group_id,hotel_id,accnt,ta_code);

