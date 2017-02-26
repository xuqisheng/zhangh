IF OBJECT_ID('dbo.p_pyn_helpdb') IS NOT NULL
    DROP PROCEDURE dbo.p_pyn_helpdb
;
create procedure p_pyn_helpdb
	@dbname varchar(30) = NULL
as

declare @showdev	int
declare @allopts	int
declare @all2opts	int
declare @thisopt	int
declare @optmask	int
declare @pagekb		int
declare @msg 		varchar(90)
declare @sptlang	int
declare @len1 int, @len2 int, @len3 int


if @@trancount = 0
begin
	set chained off
end

set transaction isolation level 1

select @sptlang = @@langid

if @@langid != 0
begin
	if not exists (
		select * from master.dbo.sysmessages where error
		between 17050 and 17069
		and langid = @@langid)
	    select @sptlang = 0
	else
	if not exists (
		select * from master.dbo.sysmessages where error
		between 17110 and 17119
		and langid = @@langid)
	    select @sptlang = 0
end

set nocount on



if @dbname is null
	select @dbname = "%",
	       @showdev = count(*) from master.dbo.sysdatabases
else
	select @showdev = count(*)
			   from master.dbo.sysdatabases
			   where name like @dbname


if @showdev = 0
begin

	exec sp_getmessage 17590, @msg out
	print @msg
	return (1)
end


select @allopts = number
from master.dbo.spt_values
where	type = "D"
  and	name = "ALL SETTABLE OPTIONS"
if (@allopts is NULL)
	select @allopts = 4 | 8 | 16 | 512 | 1024 | 2048 | 4096 | 8192

select @all2opts = number
from master.dbo.spt_values
where	type = "D2"
  and	name = "ALL SETTABLE OPTIONS"
if (@all2opts is NULL)
	select @all2opts = 1 | 2 | 4


select @allopts = @allopts | 32 | 256


select @all2opts = @all2opts | 16


create table #spdbdesc
(
	dbid	smallint null,
	dbdesc	varchar(102) null
)



insert into #spdbdesc (dbid)
		select dbid
			from master.dbo.sysdatabases
				where name like @dbname

declare @curdbid smallint
declare @dbdesc varchar(102)
declare @bitdesc varchar(30)


select @curdbid = min(dbid)
	from #spdbdesc
while @curdbid is not NULL
begin

	select @dbdesc = ""


	select @thisopt = 1
	select @optmask = @allopts
	while (@optmask != 0)
	begin

		if (@optmask & @thisopt = @thisopt)
		begin
			select @bitdesc = null

			select @bitdesc = m.description
			from master.dbo.spt_values v,
			     master.dbo.sysdatabases d,
			     master.dbo.sysmessages m
			where d.dbid = @curdbid
				and v.type = "D"
				and d.status & v.number = @thisopt
				and v.number = @thisopt
				and v.msgnum = m.error
				and isnull(m.langid, 0) = @sptlang
			if @bitdesc is not null
			begin
				if @dbdesc != ""
					select @dbdesc = @dbdesc + ", " +  @bitdesc
				else select @dbdesc = @bitdesc
			end


			select @optmask = @optmask & ~(@thisopt)
		end


		if (@thisopt < 1073741824)
			select @thisopt = @thisopt * 2
		else
			select @thisopt = -2147483648
	end


	select @thisopt = 1
	select @optmask = @all2opts
	while (@optmask != 0)
	begin

		if (@optmask & @thisopt = @thisopt)
		begin
			select @bitdesc = null

			select @bitdesc = m.description
			from master.dbo.spt_values v,
			     master.dbo.sysdatabases d,
			     master.dbo.sysmessages m
			where d.dbid = @curdbid
				and v.type = "D2"
				and d.status2 & v.number = @thisopt
				and v.number = @thisopt
				and v.msgnum = m.error
				and isnull(m.langid, 0) = @sptlang
			if @bitdesc is not null
			begin
				if @dbdesc != ""
					select @dbdesc = @dbdesc + ", " +  @bitdesc
				else select @dbdesc = @bitdesc
			end


			select @optmask = @optmask & ~(@thisopt)
		end


		if (@thisopt < 1073741824)
			select @thisopt = @thisopt * 2
		else
			select @thisopt = -2147483648
	end


	if @dbdesc = ""
	begin

		exec sp_getmessage 17591, @dbdesc out
	end


	update #spdbdesc
		set dbdesc = @dbdesc
			from #spdbdesc
				where dbid = @curdbid


	select @curdbid = min(dbid)
		from #spdbdesc
			where dbid > @curdbid
end


declare @numpgsmb 	float

select @numpgsmb = (1048576. / v.low)
	from master.dbo.spt_values v
		 where v.number = 1
		 and v.type = "E"


select distinct @len1 = max(datalength(d.name)),
		@len2 = max(datalength(l.name))
		from master.dbo.sysdatabases d, master.dbo.syslogins l,
			master.dbo.sysusages u, #spdbdesc
		where d.dbid = #spdbdesc.dbid
			and d.suid = l.suid
			and #spdbdesc.dbid = u.dbid








































select name = db.name, attribute_class = convert(char(30),cn.char_value),
	attribute = convert(char(30),an.char_value), a.int_value,
	a.char_value, a.comments
into #spdbattr
from master.dbo.sysdatabases db, #spdbdesc d,
	master.dbo.sysattributes a, master.dbo.sysattributes an,
	master.dbo.sysattributes cn
where db.dbid = d.dbid
and a.class = cn.object
and a.attribute = an.object_info1
and a.class = an.object
and a.object_type = "D"
and a.object = d.dbid
and cn.class = 0
and cn.attribute = 0
and an.class = 0
and an.attribute = 1
and a.object = db.dbid

if exists (select * from #spdbattr)
begin
	select name, attribute_class, attribute, int_value, char_value,
		comments
	from #spdbattr
end



if @showdev = 1
begin
	select @curdbid = dbid
		from master.dbo.sysdatabases
		where name like @dbname
	select @pagekb = (low / 1024)
		from master.dbo.spt_values
		where number = 1
		  and type = 'E'


	select distinct @len3 = max(datalength(m.description))
	    from master.dbo.sysdatabases d, master.dbo.sysusages u, master.dbo.sysdevices v, master.dbo.spt_values a,
			master.dbo.spt_values b, master.dbo.sysmessages m
		where d.dbid = u.dbid
			and v.low <= u.size + vstart
			and v.high >= u.size + vstart - 1
			and v.status & 2 = 2
			and d.name = @dbname
			and a.type = "E"
			and a.number = 1
			and b.type = "S"
			and u.segmap & 7 = b.number
			and b.msgnum = m.error
			and isnull(m.langid, 0) = @sptlang

	if (@len3 > 20)

	    select device_fragments = v.name, size =
			str(size / @numpgsmb, 10, 1) + " MB",
		usage = m.description,
		(curunreservedpgs(@curdbid, u.lstart,
				u.unreservedpgs) * @pagekb) "free kbytes"
	    from master.dbo.sysdatabases d,
		 master.dbo.sysusages u,
		 master.dbo.sysdevices v,
		 master.dbo.spt_values a,
		 master.dbo.spt_values b,
		 master.dbo.sysmessages m
		where d.dbid = u.dbid
			and v.low <= u.size + vstart
			and v.high >= u.size + vstart - 1
			and v.status & 2 = 2
			and d.name = @dbname
			and a.type = "E"
			and a.number = 1
			and b.type = "S"
			and u.segmap & 7 = b.number
			and b.msgnum = m.error
			and isnull(m.langid, 0) = @sptlang
	    order by 1

	else

	    select device_fragments = v.name, size =
		convert(varchar(10),
			round(
			(a.low * convert(float, u.size))
			/ 1048576, 1)) + " " + "MB",
		usage = convert(char(20), m.description),
		(curunreservedpgs(@curdbid, u.lstart,
				u.unreservedpgs) * @pagekb) "free kbytes"
	    from master.dbo.sysdatabases d,
		 master.dbo.sysusages u,
		 master.dbo.sysdevices v,
		 master.dbo.spt_values a,
		 master.dbo.spt_values b,
		 master.dbo.sysmessages m
		where d.dbid = u.dbid
			and v.low <= u.size + vstart
			and v.high >= u.size + vstart - 1
			and v.status & 2 = 2
			and d.name = @dbname
			and a.type = "E"
			and a.number = 1
			and b.type = "S"
			and u.segmap & 7 = b.number
			and b.msgnum = m.error
			and isnull(m.langid, 0) = @sptlang
	    order by 1


	if exists (select *
			from #spdbdesc
				where db_id() = dbid)
	begin
		declare @curdevice	varchar(30),
			@curseg		smallint,
			@segbit		int

		delete #spdbdesc

		select @curdevice = min(d.name)
			from  master.dbo.sysusages u, master.dbo.sysdevices d
				where u.dbid = db_id()
					and d.low <= size + vstart
					and d.high >= size + vstart - 1
					and d.status & 2 = 2
		while (@curdevice is not null)
		begin

			select @curseg = min(segment)
					from syssegments
			while (@curseg is not null)
			begin
				if (@curseg < 31)
					select @segbit = power(2, @curseg)
				else select @segbit = low
					from master.dbo.spt_values
						where type = "E"
							and number = 2
				insert into #spdbdesc
					select @curseg, @curdevice
						from master.dbo.sysusages u,
							master.dbo.sysdevices d,
							master.dbo.spt_values v
					where u.segmap & @segbit = @segbit
						and d.low <= u.size + u.vstart
						and d.high >= u.size + u.vstart - 1
						and u.dbid = db_id()
						and d.status & 2 = 2
						and v.number = 1
						and v.type = "E"
						and d.name = @curdevice
				select @curseg = min(segment)
						from syssegments
							where segment > @curseg
			end

			select @curdevice = min(d.name)
				from  master.dbo.sysusages u,
					master.dbo.sysdevices d
				where u.dbid = db_id()
					and d.low <= size + vstart
					and d.high >= size + vstart - 1
					and d.status & 2 = 2
					and d.name > @curdevice
		end


		insert into #spdbdesc
			select null, d.name
				from master.dbo.sysusages u,
					master.dbo.sysdevices d
			where u.segmap = 0
				and d.low <= u.size + u.vstart
				and d.high >= u.size + u.vstart - 1
				and u.dbid = db_id()
				and d.status & 2 = 2


		exec sp_getmessage 17592, @msg out


		select distinct @len1 = max(datalength(dbdesc))
			from #spdbdesc, syssegments
				where dbid *= segment














	end

end

drop table #spdbdesc
drop table #spdbattr
return (0)
;
