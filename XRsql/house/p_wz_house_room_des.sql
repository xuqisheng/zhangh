if exists(select 1 from sysobjects where name = 'p_wz_house_room_des')
	drop proc p_wz_house_room_des ;

create proc p_wz_house_room_des
		@empno		char(10)
as
declare
		@ret 			integer
		
create table #des(
			des			varchar(10),
			sta			char(1),
			descript		varchar(10)
)

insert #des select '房间状态',sta,descript from rmstalist 
insert #des select '临时房状态',code,descript from rmstalist1 

select * from #des

return 0 ;

	