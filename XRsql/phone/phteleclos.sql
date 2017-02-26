// ------------------------------------------------------------------------------------
//	PMS TABLE : 包含升降等级(phngrade), 和留言灯(A,B)
//
//		数据的自动插入在 master's trigger 
//
// ------------------------------------------------------------------------------------
if exists (select * from sysobjects where name = 'phteleclos')
	drop table phteleclos
;
create table phteleclos (
	roomno 		char(8)									not null,	-- 这里现在要存放分机号,不是房号,主要是为了应付一个房间多个分机 !
	type 			char(4)									not null,	
			-- ckin-CI ckou-CO grad-等级,wake-叫醒,mail-留言,room-房态 dnd-
	tag 			char(1)		default '1' 			null,
	wktime 		datetime		default getdate() 	null,
	changed 		char(1)		default 'F' 			null,
	settime 		datetime		default getdate() 	null,
	chgtime 		datetime		default getdate() 	null,
	accnt			char(10)									null,
   toroomno 	char(8)  	default '' 				null NULL
)
exec sp_primarykey phteleclos, roomno, type, wktime   -- 注意一个客房可以同时设置多个叫醒服务
create unique index index1 on phteleclos(roomno, type, wktime)
;

if exists (select * from sysobjects where name = 'phteleclos_task')
	drop table phteleclos_task
;
create table phteleclos_task (
	roomno 		char(8)									not null,	-- 这里现在要存放分机号,不是房号,主要是为了应付一个房间多个分机 !
	type 			char(4)									not null,	
			-- ckin-CI ckou-CO grad-等级,wake-叫醒,mail-留言,room-房态 dnd-
	tag 			char(1)		default '1' 			null,
	wktime 		datetime		default getdate() 	null,
	changed 		char(1)		default 'F' 			null,
	settime 		datetime		default getdate() 	null,
	chgtime 		datetime		default getdate() 	null,
	accnt			char(10)									null,
   toroomno 	char(8)  	default '' 				null NULL
)
exec sp_primarykey phteleclos_task, roomno, type, wktime   -- 注意一个客房可以同时设置多个叫醒服务
create unique index index1 on phteleclos_task(roomno, type, wktime)
;