/*
----each----:[master_snapshot][#master_snapshot.plen]
*/
alter table master_snapshot add column plen bigint(16) default 1;
/*
----each----:[master_snapshot][#master_snapshot:hotel_group_id,hotel_id,plen,biz_date_end]
*/
create index mi_plen on master_snapshot(hotel_group_id,hotel_id,plen,biz_date_end);
  