------------------------------------------------------------------------------------
--		crs_syncctrl  ͬ���ֶο���
------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "crs_syncctrl" and type="U")
	drop table crs_syncctrl;

create table crs_syncctrl
(
	tabid 		varchar(60)					not null,   -- ��
	colid 		varchar(60)					not null,   -- ��
	descript 	varchar(60)	            not null,	-- ������
	op		 		integer		default 0	not null  	-- 0:��ͬ�� 1:�ϴ� 2:���� 3:ͬ��
)
exec sp_primarykey crs_syncctrl, tabid,colid
create unique index index1 on crs_syncctrl(tabid,colid)
;

-- ��ʼ��guest
insert into crs_syncctrl(tabid,colid,descript,op)
	select 'guest',c.name,c.name,3 
		from syscolumns c 
		where c.id = object_id('guest')
;
update crs_syncctrl set descript = b.descript 
	from crs_syncctrl a,tabcoldes b 
	where a.tabid = b.tabname and a.colid = b.col 
;
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='no'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='srqs'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='feature'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='rmpref'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='interest'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='extrainf'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='refer1'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='refer2'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='refer3'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='comment'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='remark'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='araccnt1'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='araccnt2'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='master'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='fv_date'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='fv_room'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='fv_rate'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='i_times'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='x_times'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='n_times'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='l_times'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='i_days'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='fb_times1'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='en_times2'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='rm'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='fb'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='en'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='mt'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='ot'
update crs_syncctrl set op = 0 where tabid = 'guest' and colid ='tl'
;


