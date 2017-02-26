drop procedure if exists p_hry_rebuild_reser;
delimiter //
create procedure p_hry_rebuild_reser()
begin
   declare v_hotel_group_id bigint;
   declare v_hotel_id       bigint;
   declare v_accnt          bigint;
   declare v_done           int default 0;
   declare v_bdate          datetime;
   declare v_edate          datetime;
   declare v_ldate          datetime;
   declare v_id             bigint;

 
   declare c_cursor cursor for 
           select hotel_group_id,hotel_id,accnt from account_deposit
                  union 
           select hotel_group_id,hotel_id,accnt from account_reserve;
   declare continue handler for not found set v_done = 1;
   open c_cursor;
   fetch c_cursor into v_hotel_group_id,v_hotel_id,v_accnt;
   mywhile:while v_done =0 do
      begin
      set v_id = null;
      select min(biz_date_begin),min(biz_date_end),min(id) into v_bdate,v_edate,v_id
             from master_snapshot
             where hotel_group_id = v_hotel_group_id
                   and hotel_id = v_hotel_id
                   and master_type='reser'
                   and master_id = v_accnt
                   and datediff(biz_date_end,biz_date_begin) > 1;
      if v_id is null  then
         fetch c_cursor into v_hotel_group_id,v_hotel_id,v_accnt;
         iterate mywhile;
      end if;
      set v_ldate = v_bdate;
      while v_ldate < v_edate do
            insert into master_snapshot 
                   select 
                          a.hotel_group_id,
                          a.hotel_id,
                          null,
                          v_ldate,
                          v_ldate + interval 1 day,
                          a.master_type,
                          a.master_id,
                          a.master_grp_id,
                          a.name,
                          a.biz_date,
                          a.sta,
                          a.rmtype,
                          a.rmno,
                          a.rmnum,
                          a.arr,
                          a.dep,
                          a.adult,
                          a.children,
                          a.rack_rate,
                          a.nego_rate,
                          a.real_rate,
                          a.dsc_reason,
                          a.dsc_amount,
                          a.company_id,
                          a.agent_id,
                          a.source_id,
                          a.member_type,
                          a.member_no,
                          a.ar_category,
                          a.limit_type,
                          a.salesman,
                          a.src,
                          a.market,
                          a.rsv_type,
                          a.channel,
                          a.ratecode,
                          a.cmscode,
                          a.packages,
                          a.last_num,
                          a.last_num_link,
                          a.modify_datetime,
                          a.is_today_arr,
                          a.is_today_dep,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          0,
                          a.remark,
                          a.credit,
                          a.pay_code
                          from master_snapshot a
                          where a.id = v_id;
          set v_ldate=adddate(v_ldate,1);
      end while;
      delete from master_snapshot where id = v_id;
      fetch c_cursor into v_hotel_group_id,v_hotel_id,v_accnt;
      end;
   end while ;
   close c_cursor;
   update master_snapshot set last_charge=0,last_pay=0,last_balance=0,
                              till_charge=0,till_pay=0,till_balance=0,
                              charge_ttl=0,pay_ttl=0
                 where master_type='reser';
   update master_snapshot set pay_ttl=pay_ttl+(select iFnull(sum(b.pay),0)
                                               from account_deposit b
                                               where b.hotel_group_id=master_snapshot.hotel_group_id 
                                                     and b.hotel_id=master_snapshot.hotel_id
                                                     and b.accnt=master_snapshot.master_id
                                                     and b.biz_date=master_snapshot.biz_date_end)
                 where master_type='reser';
   update master_snapshot set pay_ttl=pay_ttl-(select iFnull(sum(b.pay),0)
                                               from account_deposit b
                                               where b.hotel_group_id=master_snapshot.hotel_group_id
                                                     and b.hotel_id=master_snapshot.hotel_id
                                                     and b.accnt=master_snapshot.master_id
                                                     and b.tran_bizdate=master_snapshot.biz_date_end)
                 where master_type='reser';
   update master_snapshot set pay_ttl=pay_ttl-(select iFnull(sum(b.pay),0)
                                               from account_deposit b
                                               where b.hotel_group_id=master_snapshot.hotel_group_id
                                                     and b.hotel_id=master_snapshot.hotel_id
                                                     and b.accnt=master_snapshot.master_id
                                                     and b.cancle_bizdate=master_snapshot.biz_date_end)
                 where master_type='reser';
  update master_snapshot set charge_ttl=charge_ttl+(select iFnull(sum(b.charge),0)
                                               from account_reserve b
                                               where b.hotel_group_id=master_snapshot.hotel_group_id
                                                     and b.hotel_id=master_snapshot.hotel_id
                                                     and b.accnt=master_snapshot.master_id
                                                     and b.biz_date=master_snapshot.biz_date_end)
                 where master_type='reser';
  update master_snapshot set charge_ttl=charge_ttl-(select iFnull(sum(b.charge),0)
                                               from account_reserve b
                                               where b.hotel_group_id=master_snapshot.hotel_group_id
                                                     and b.hotel_id=master_snapshot.hotel_id
                                                     and b.accnt=master_snapshot.master_id
                                                     and b.tran_bizdate=master_snapshot.biz_date_end)
                 where master_type='reser';

  update master_snapshot a set a.last_charge= (select ifnull(sum(b.charge_ttl),0)
                                                  from (select c.hotel_group_id,c.hotel_id,c.master_type,
                                                               c.master_id,c.biz_date_end,c.charge_ttl
                                                         from master_snapshot c where c.master_type='reser') b
                                                  where b.hotel_group_id = a.hotel_group_id and 
                                                        b.hotel_id = a.hotel_id and 
                                                        b.master_type = a.master_type and 
                                                        b.master_id = a.master_id and 
                                                        b.biz_date_end <= a.biz_date_begin)
                           where a.master_type='reser';
  update master_snapshot a set a.last_pay= (select ifnull(sum(b.pay_ttl),0)
                                                  from (select c.hotel_group_id,c.hotel_id,c.master_type,
                                                               c.master_id,c.biz_date_end,c.pay_ttl
                                                         from master_snapshot c where c.master_type='reser') b
                                                  where b.hotel_group_id = a.hotel_group_id and 
                                                        b.hotel_id = a.hotel_id and 
                                                        b.master_type = a.master_type and 
                                                        b.master_id = a.master_id and 
                                                        b.biz_date_end <= a.biz_date_begin)
                           where a.master_type='reser';

   update master_snapshot set charge_ot = charge_ttl - (charge_rm+charge_fb+charge_en+charge_sp+charge_mt)
                              where master_type='reser';
   update master_snapshot set pay_ot = pay_ttl - (pay_rmb+pay_chk+pay_card_in+pay_card_out+pay_ar+pay_ticket+pay_dscent)
                              where master_type='reser';
   update master_snapshot set last_balance = last_charge - last_pay where master_type='reser';
   update master_snapshot set till_charge  = last_charge + charge_ttl where master_type='reser';
   update master_snapshot set till_pay     = last_pay +    pay_ttl where master_type='reser';
   update master_snapshot set till_balance = till_charge - till_pay where master_type='reser';

 

end;//
delimiter ;
call p_hry_rebuild_reser();
drop procedure if exists p_hry_rebuild_reser;
