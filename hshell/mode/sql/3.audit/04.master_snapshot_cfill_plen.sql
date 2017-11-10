/*
----each----:[master_snapshot.biz_date_begin][master_snapshot.biz_date_end][master_snapshot.plen]
*/
update master_snapshot set plen=datediff(biz_date_end,biz_date_begin) where ##gh#;

