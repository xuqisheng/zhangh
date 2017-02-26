
--------------------------------------------------------------------------------
-- 酒店能源消耗输入 hbb 2008.5 
--------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name  = 'energy' and type = 'U')
	drop table energy;
create table energy (
	 date			datetime	not null,
	 class 		varchar(30) not null,
	 descript	varchar(60) not null,
	 descript1	varchar(60) not null,
	 sequence   int	default 0 not null,
	 used			money default 0 not null,		-- 消耗
    price		money default 0 not null,		-- 单价
	 day			money default 0 not null,		-- 本日消费金额=used*price 
    month		money default 0 not null,		-- 月累计
    year       money default 0 not null,		-- 年累计
	 pday       money default 0 not null,		-- 日计划
	 pmonth     money default 0 not null,		-- 月计划 
    pyear      money default 0 not null		-- 年计划 
);
EXEC sp_primarykey 'energy', class;
CREATE UNIQUE INDEX index1 ON energy(class);
insert energy(date,class,descript,descript1,sequence) select bdate1,'water', '水', 'Water', 100 from sysdata; 
insert energy(date,class,descript,descript1,sequence) select bdate1,'electric', '电力', 'Electric', 200 from sysdata; 
insert energy(date,class,descript,descript1,sequence) select bdate1,'gas', '煤气', 'Gas', 300 from sysdata; 
insert energy(date,class,descript,descript1,sequence) select bdate1,'diesel', '柴油', 'Diesel Oil', 400 from sysdata; 
select * from energy order by sequence ; 


if exists(select 1 from sysobjects where name  = 'yenergy' and type = 'U')
	drop table yenergy;
create table yenergy (
	 date			datetime	not null,
	 class 		varchar(30) not null,
	 descript	varchar(60) not null,
	 descript1	varchar(60) not null,
	 sequence   int	default 0 not null,
	 used			money default 0 not null,		-- 消耗
    price		money default 0 not null,		-- 单价
	 day			money default 0 not null,		-- 本日消费金额=used*price 
    month		money default 0 not null,		-- 月累计
    year       money default 0 not null,		-- 年累计
	 pday       money default 0 not null,		-- 日计划
	 pmonth     money default 0 not null,		-- 月计划 
    pyear      money default 0 not null		-- 年计划 
);
EXEC sp_primarykey 'yenergy', date,class;
CREATE UNIQUE INDEX index1 ON yenergy(date,class);
