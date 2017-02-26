if exists(select * from sysobjects where name = 'p_xr_spaceused' and type = 'P')
	drop proc p_xr_spaceused;

create procedure p_xr_spaceused
	@tblike		varchar(20) = '%'
as

create table #xr_spaceused
(
	name	      char(20) 	not null,
	iname	      char(20) 	not null,
	rowtotal		int 			not null,
   reservered	int 			not null,
   dataused		int 			not null,
   indexused	int 			not null,
   unused		int 			not null
)

insert #xr_spaceused(name,iname,rowtotal,reservered,dataused,indexused,unused)
	  select  name = o.name,iname = i.name,
		rowtotal = rowcnt(i.doampg),
		reserved = 2 * convert(numeric(20,9),
			(reserved_pgs(i.id, i.doampg) + reserved_pgs(i.id, i.ioampg))),
		data = 2 * convert(numeric(20,9),data_pgs(i.id, i.doampg)),
		index_size =  2 * convert(numeric(20,9), data_pgs(i.id, i.ioampg)),
		unused = 2 * convert(numeric(20,9), 
			((reserved_pgs(i.id, i.doampg) +	reserved_pgs(i.id, i.ioampg)) - 
			(data_pgs(i.id, i.doampg) + data_pgs(i.id, i.ioampg))))
	from sysobjects o, sysindexes i
			where i.id = o.id and o.type='U' and o.name like @tblike+'%'

-- select * from #xr_spaceused order by reservered desc
select name, rowcounts = sum(rowtotal), reserver = sum(reservered), dateuse = sum(dataused), indexuse = sum(indexused), unuse = sum(unused)
	from #xr_spaceused group by name order by reserver desc
return 0;
