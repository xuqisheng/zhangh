if exists(select 1 from sysobjects where name = 'p_wz_house_oo_list')
	drop proc p_wz_house_oo_list ;
create proc p_wz_house_oo_list
	as
create table #output(
			roomno 		char(5)		not null,
			hall			char(1),
			floor			char(3),
			type			char(5),
			sta			char(1),
			reason		char(3),
			begin_		datetime,
			end_			datetime,
			remark		varchar(40)	
)

insert #output(roomno,hall,floor,type,sta)
		 select roomno,hall,flr,type,sta from rmsta where sta in('O','S') order by roomno

update #output set reason = b.reason , begin_ = b.dbegin , end_ = b.dend,remark =b.remark from rm_ooo b
		where #output.roomno = b.roomno and b.status = 'I'


select * from #output order by roomno

return 0
;
	

