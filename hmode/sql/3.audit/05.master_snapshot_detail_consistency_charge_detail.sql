/*
check charge data 
*/

select 
       date(biz_date_end) as repbdate,
       id,
       hotel_group_id as gid,
       hotel_id as hid,
       master_type,
       master_id,
       sta,
       rmno,
       date(biz_date_begin) as biz_date_b,
       date(biz_date_end)  as biz_date_e,
       charge_rm+charge_rm_svc+charge_rm_bf+charge_rm_cms+charge_rm_lau+charge_rm_pkg+charge_fb+charge_mt+charge_en+charge_sp+charge_ot as charge_sum,
       charge_ttl,       
       charge_rm+charge_rm_svc+charge_rm_bf+charge_rm_cms+charge_rm_lau+charge_rm_pkg+charge_fb+charge_mt+charge_en+charge_sp+charge_ot - charge_ttl as diff
       from master_snapshot
       where ##gh# and
             charge_rm+charge_rm_svc+charge_rm_bf+charge_rm_cms+charge_rm_lau+charge_rm_pkg+charge_fb+charge_mt+charge_en+charge_sp+charge_ot - charge_ttl <> 0
       order by hotel_group_id,hotel_id,master_type,master_id,biz_date_end

