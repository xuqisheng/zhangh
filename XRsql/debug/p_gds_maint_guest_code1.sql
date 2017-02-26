
if exists (select * from sysobjects where name ='p_gds_maint_guest_code1' and type ='P')
	drop proc p_gds_maint_guest_code1;
create proc p_gds_maint_guest_code1
as
---------------------------------------
--	Î¬»¤ guest.code1 
---------------------------------------
delete guest_extra where item='ratecode' and value not in (select code from rmratecode)

create table #guest_extra_adm (no  char(7) null, value  varchar(20) null)
create unique index index1 on #guest_extra_adm(no)
insert #guest_extra_adm select no, min(value) from guest_extra where item='ratecode'  group by no

update guest set code1=b.value from #guest_extra_adm b where guest.no=b.no and guest.code1<>b.value

update guest set code1='' where code1<>'' and not exists(select 1 from guest_extra b where guest.no=b.no)
;
