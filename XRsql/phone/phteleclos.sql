// ------------------------------------------------------------------------------------
//	PMS TABLE : ���������ȼ�(phngrade), �����Ե�(A,B)
//
//		���ݵ��Զ������� master's trigger 
//
// ------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 'phteleclos')
	drop table phteleclos
;
create table phteleclos (
	roomno 		char(8)									not null,	-- ��������Ҫ��ŷֻ���,���Ƿ���,��Ҫ��Ϊ��Ӧ��һ���������ֻ� !
	type 			char(4)									not null,	
			-- ckin-CI ckou-CO grad-�ȼ�,wake-����,mail-����,room-��̬ dnd-
	tag 			char(1)		default '1' 			null,
	wktime 		datetime		default getdate() 	null,
	changed 		char(1)		default 'F' 			null,
	settime 		datetime		default getdate() 	null,
	chgtime 		datetime		default getdate() 	null,
	accnt			char(10)									null,
   toroomno 	char(8)  	default '' 				null NULL
)
exec sp_primarykey phteleclos, roomno, type, wktime   -- ע��һ���ͷ�����ͬʱ���ö�����ѷ���
create unique index index1 on phteleclos(roomno, type, wktime)
;

if exists (select * from sysobjects where name = 'phteleclos_task')
	drop table phteleclos_task
;
create table phteleclos_task (
	roomno 		char(8)									not null,	-- ��������Ҫ��ŷֻ���,���Ƿ���,��Ҫ��Ϊ��Ӧ��һ���������ֻ� !
	type 			char(4)									not null,	
			-- ckin-CI ckou-CO grad-�ȼ�,wake-����,mail-����,room-��̬ dnd-
	tag 			char(1)		default '1' 			null,
	wktime 		datetime		default getdate() 	null,
	changed 		char(1)		default 'F' 			null,
	settime 		datetime		default getdate() 	null,
	chgtime 		datetime		default getdate() 	null,
	accnt			char(10)									null,
   toroomno 	char(8)  	default '' 				null NULL
)
exec sp_primarykey phteleclos_task, roomno, type, wktime   -- ע��һ���ͷ�����ͬʱ���ö�����ѷ���
create unique index index1 on phteleclos_task(roomno, type, wktime)
;