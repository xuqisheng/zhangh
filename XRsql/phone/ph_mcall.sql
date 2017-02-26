
if exists (select * from sysobjects where name = 'ph_mcall')
	drop table ph_mcall
;
create table ph_mcall (
	roomno 		char(8)									not null,	// ��������Ҫ��ŷֻ���,���Ƿ���,��Ҫ��Ϊ��Ӧ��һ���������ֻ� !
	type 			char(4)									not null,	// wake-����
	tag 			char(1)		default '1' 			null,
	wktime 		datetime		default getdate() 	null,
	changed 		char(1)		default 'F' 			null,
	settime 		datetime		default getdate() 	null,
	chgtime 		datetime		default getdate() 	null

)
exec sp_primarykey ph_macall, roomno, type
create unique index index1 on ph_mcall(roomno, type)
;