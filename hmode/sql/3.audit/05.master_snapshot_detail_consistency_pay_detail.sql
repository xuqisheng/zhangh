/*
check pay data 
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
      pay_rmb+pay_chk+pay_card_in+pay_card_out+pay_ar+pay_ticket+pay_dscent+pay_ot as pay_sum,
      pay_ttl,       
      pay_rmb+pay_chk+pay_card_in+pay_card_out+pay_ar+pay_ticket+pay_dscent+pay_ot - pay_ttl as diff
      from master_snapshot
      where ##gh# and
            pay_rmb+pay_chk+pay_card_in+pay_card_out+pay_ar+pay_ticket+pay_dscent+pay_ot - pay_ttl <> 0
      order by hotel_group_id,hotel_id,master_type,master_id,biz_date_end

