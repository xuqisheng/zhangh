
IF OBJECT_ID('process_flag') IS NOT NULL
	drop table process_flag;
CREATE TABLE process_flag 
(
    flag  varchar(20)  NOT NULL,   -- 标志
    value varchar(100) NOT NULL
);
CREATE UNIQUE NONCLUSTERED INDEX flag ON process_flag(flag);

-- 重建消费业绩用
insert process_flag(flag, value) values('master_reb', '0');
insert process_flag(flag, value) values('guest_reb', '0');

-- Action history 
insert process_flag(flag, value) values('Bill', 'w_gl_accnt_billing');
insert process_flag(flag, value) values('Profile', 'w_gds_guest');
insert process_flag(flag, value) values('Reservation', 'w_gds_master');
insert process_flag(flag, value) values('Vipcard', 'w_gds_vipcard');
