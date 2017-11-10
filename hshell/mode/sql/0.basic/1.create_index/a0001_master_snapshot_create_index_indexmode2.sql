/*
----each----:[master_snapshot.hotel_group_id][master_snapshot.hotel_id]
----each----:[master_snapshot.master_type][master_snapshot.master_id]
----each----:[master_snapshot.biz_date_end][master_snapshot.biz_date_begin]
----each----:[#master_snapshot:hotel_group_id,hotel_id,master_type,master_id,biz_date_begin,biz_date_end]
*/

create index indexmode2 on master_snapshot(hotel_group_id,hotel_id,master_type,master_id,biz_date_begin,biz_date_end)
