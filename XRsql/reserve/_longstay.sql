//==========================================================================
//	Long Stay Solution 
//
//	Table : ls_master, ls_detail
//
//==========================================================================

-- sysoption 
if not exists(select 1 from sys_function where code='0518' and fun_des='master!ls')
	INSERT INTO sys_function VALUES ('0518','05','�������۸���','Longstay rate define','master!ls');
if not exists(select 1 from sysoption where catalog='reserve' and item='longstay_rate')
	INSERT INTO sysoption(catalog,item,value,remark) 
		VALUES ('reserve','longstay_rate','f','�������۸���');


-- basecode - timeterm 
INSERT INTO basecode VALUES ('timeterm','100','��','Day','F','F',1,'01D','F');
INSERT INTO basecode VALUES ('timeterm','200','��','Week','F','F',7,'01W','F');
INSERT INTO basecode VALUES ('timeterm','300','��','Month','F','F',30,'01M','F');
INSERT INTO basecode VALUES ('timeterm','400','����','Quarter','F','F',90,'01Q','F');
INSERT INTO basecode VALUES ('timeterm','500','����','Half Year','F','F',180,'06M','F');
INSERT INTO basecode VALUES ('timeterm','600','��','One Year','F','F',365,'01Y','F');
INSERT INTO basecode VALUES ('timeterm','700','2��','Two Years','F','F',770,'02Y','F');
INSERT INTO basecode VALUES ('timeterm','800','5��','Five Years','F','F',1825,'05Y','F');
INSERT INTO basecode VALUES ('timeterm','900','10��','Ten Years','F','F',3650,'10Y','F');


if exists(select * from sysobjects where name = "ls_master" and type="U")
	drop table ls_master;
create table ls_master
(
	accnt		   char(10)						not null,
	rmode			char(3)						not null,	-- �۸�ģʽ ��/��/��/����/�� basecode 
	rate			money			default 0	not null,	-- ��λ�۸�
	arr			datetime						not null,
	dep			datetime						not null,
	amount		money			default 0	not null,	-- �ڼ��ܼ۸�
	srate			money			default 0	not null,	-- ��ʾ�۸�
	pmode			char(3)						not null,	-- ��������
	resby			char(10)		default ''	not null,	-- ����
	restime		datetime						not null,			
	cby			char(10)						not null,	-- �޸�
	changed		datetime						not null,	
	logmark     int    default 0 			not null
)
exec sp_primarykey ls_master,accnt
create unique index  ls_master on ls_master(accnt)
;

if exists(select * from sysobjects where name = "ls_detail" and type="U")
	drop table ls_detail;
create table ls_detail
(
	accnt		   char(10)						not null,
	date			datetime						not null,
	rate			money			default 0	not null,
	cby			char(10)						not null,	-- �����޸�����Ϣ
	changed		datetime						not null,	
	logmark     int    default 0 			not null
)
exec sp_primarykey ls_detail,accnt,date
create unique index  ls_detail on ls_detail(accnt,date)
;
