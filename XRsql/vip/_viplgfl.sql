if exists(select * from sysobjects where type ="U" and name = "viplgfl")
   drop table viplgfl;
create table viplgfl
(
	no				char(20)		not null,							-- 卡号
	modu_id		char(2)		not null,							-- 模块号
	accnt			char(10)		default '' not null,				-- 账号
	date			datetime		not null,							-- 营业日期
	i_days		money			default 0 not null,				-- 房晚数
	charge		money			default 0 not null,				-- 总消费
	credit		money			default 0 not null,				-- 储值额
	credit_db	money			default 0 not null,				-- 使用储值付款的金额
	credit_m5	money			default 0 not null,				-- 使用非积分方式(如ENT,DSC,PTS等)付款的金额,对应vippoint.m5
	vippoint_c	money			default 0 not null,				-- 产生积分，对应vippoint.credit
	vippoint_d	money			default 0 not null,				-- 使用积分，对应vippoint.charge
	type			char(1)		default 'R' not null				-- 使用贵宾卡的方式 : R.住房,P.用餐,B.商务中心,D.打折
)
;
exec   sp_primarykey viplgfl, no, modu_id, accnt, date
create unique index index1 on viplgfl(no, modu_id, accnt, date)
;
