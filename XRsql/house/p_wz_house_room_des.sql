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

insert #des select '����״̬',sta,descript from rmstalist 
insert #des select '��ʱ��״̬',code,descript from rmstalist1 

select * from #des

return 0 ;

	