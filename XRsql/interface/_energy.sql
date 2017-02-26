
--------------------------------------------------------------------------------
-- �Ƶ���Դ�������� hbb 2008.5 
--------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name  = 'energy' and type = 'U')
	drop table energy;
create table energy (
	 date			datetime	not null,
	 class 		varchar(30) not null,
	 descript	varchar(60) not null,
	 descript1	varchar(60) not null,
	 sequence   int	default 0 not null,
	 used			money default 0 not null,		-- ����
    price		money default 0 not null,		-- ����
	 day			money default 0 not null,		-- �������ѽ��=used*price 
    month		money default 0 not null,		-- ���ۼ�
    year       money default 0 not null,		-- ���ۼ�
	 pday       money default 0 not null,		-- �ռƻ�
	 pmonth     money default 0 not null,		-- �¼ƻ� 
    pyear      money default 0 not null		-- ��ƻ� 
);
EXEC sp_primarykey 'energy', class;
CREATE UNIQUE INDEX index1 ON energy(class);
insert energy(date,class,descript,descript1,sequence) select bdate1,'water', 'ˮ', 'Water', 100 from sysdata; 
insert energy(date,class,descript,descript1,sequence) select bdate1,'electric', '����', 'Electric', 200 from sysdata; 
insert energy(date,class,descript,descript1,sequence) select bdate1,'gas', 'ú��', 'Gas', 300 from sysdata; 
insert energy(date,class,descript,descript1,sequence) select bdate1,'diesel', '����', 'Diesel Oil', 400 from sysdata; 
select * from energy order by sequence ; 


if exists(select 1 from sysobjects where name  = 'yenergy' and type = 'U')
	drop table yenergy;
create table yenergy (
	 date			datetime	not null,
	 class 		varchar(30) not null,
	 descript	varchar(60) not null,
	 descript1	varchar(60) not null,
	 sequence   int	default 0 not null,
	 used			money default 0 not null,		-- ����
    price		money default 0 not null,		-- ����
	 day			money default 0 not null,		-- �������ѽ��=used*price 
    month		money default 0 not null,		-- ���ۼ�
    year       money default 0 not null,		-- ���ۼ�
	 pday       money default 0 not null,		-- �ռƻ�
	 pmonth     money default 0 not null,		-- �¼ƻ� 
    pyear      money default 0 not null		-- ��ƻ� 
);
EXEC sp_primarykey 'yenergy', date,class;
CREATE UNIQUE INDEX index1 ON yenergy(date,class);
