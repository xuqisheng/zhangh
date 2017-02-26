drop  proc p_gds_reserve_grp_rmuse_rep;
create  proc p_gds_reserve_grp_rmuse_rep
	@begin_		datetime,
	@end_			datetime,
	@stas			varchar(10)
as

declare
	@gcolno		int,
	@gin			int,
	@gline		int,
	@glinestr	varchar(80)

declare
	@groupno		char(10),
	@resno		varchar(10),
	@accnt		char(10),
	@groupno_old	char(10),
	@resno_old		varchar(10),
	@accnt_old		char(10),
	@roomno		char(5),
	@type			char(5),
	@mst_vip		char(1),
	@vip			varchar(6),
	@srqs			varchar(30),
	@name			varchar(60),
	@addr			varchar(60),
	@applicant	varchar(60),
	@ref			varchar(120),
	@exp_s		varchar(10),
	@arr			datetime,
	@dep			datetime,
	@gstno		int,
	@tmp			varchar(5),
	@haccnt		char(7)

declare
	@gcode		char(2),
	@gdes			char(20),
	@grno			int,
	@grmno		int

create table #grp_rmuse (
	line				int				not null,
	resno				char(10)			null,
	accnt				char(10)			null,
	name				varchar(50)		null,
	vip				char(1)			null,
	arr				datetime			null,
	dep				datetime			null,
	srqs				varchar(30)		null,
	applicant		varchar(60)		null,
	exp_s					varchar(10)	null,
	rooms				int				null,
	gstno				int				null,
	content			varchar(80)	default '' null,
	ref				varchar(90)	default '' null
)
create unique index index1 on #grp_rmuse(line)

create table #grp_rmuse_add (
	type				char(5)			not null,
	descript			varchar(30) 	null,
	rooms				int				null
)
create unique index index1 on #grp_rmuse_add(type)

select @gline = 0, @gin = 0

declare @gst_srqs	varchar(255), @tmp_srqs varchar(20)
declare c_srq cursor for select srqs from guest where no=@haccnt




declare c_grp  cursor for
	select isnull(rtrim(a.resno),'-'),a.accnt,a.type,a.roomno,a.groupno,a.haccnt
	from master a, master b
	where a.class='F' and a.groupno=b.accnt and charindex(a.sta, 'XNLODSE')=0 
			and (@stas is null or charindex(b.sta,@stas)>0)
			and (@begin_ is null or datediff(dd,@begin_,b.arr)>=0)
			and (@end_ is null or datediff(dd,b.dep,@end_)>=0)
	order by a.groupno,a.accnt
open c_grp
select @groupno_old=''
select @grmno=0, @grno=0,@gcolno=0, @glinestr = ''
fetch c_grp into @resno,@accnt,@type,@roomno,@groupno,@haccnt
while @@sqlstatus = 0
	begin

	if @groupno<>@groupno_old
		begin

		if @glinestr<>''
			update #grp_rmuse set content=@glinestr where line=@gline

		update #grp_rmuse set rooms=@grmno, gstno=@grno where line=@gin


		select @gline=@gline+1
		select @grmno=0, @grno=0,@gcolno = 0, @glinestr = ''
//		select @resno=resno,@arr=arr,@dep=dep,@applicant=applicant,@gstno=gstno,@srqs=srqs,@exp_s=exp_s,@vip=vip,@ref=ref from master where accnt=@groupno
		select @resno=resno,@arr=arr,@dep=dep,@applicant=applicant,@gstno=gstno,@srqs=srqs,@ref=ref from master where accnt=@groupno
		select @vip=vip, @name = name from guest where no=@haccnt
		insert #grp_rmuse(line,resno,accnt,name,vip,arr,dep,srqs,applicant,exp_s,rooms,gstno,content,ref)
			values(@gline,@resno,@groupno,@name,@vip,@arr,@dep,@srqs,@applicant,@exp_s,0,0,'',@ref)
		select @gin = @gline
		end

	select @gcolno=@gcolno+1, @grmno=@grmno+1, @grno=@grno+1
	if rtrim(@roomno) is null
		select @tmp = @type
	else
		select @tmp = @roomno
	select @glinestr = @glinestr + @tmp
	select @mst_vip = isnull(max(vip),'0') from guest where no=@haccnt


	select @gst_srqs = ''
	open c_srq
	fetch c_srq into @tmp_srqs
	while @@sqlstatus = 0
	begin
		select @gst_srqs = @gst_srqs + isnull(@tmp_srqs, ' ')
		fetch c_srq into @tmp_srqs
	end
	close c_srq


	if @mst_vip is not null and @mst_vip > '0'
		select @glinestr = @glinestr + '★ '
	else if charindex('LD', @gst_srqs) > 0
		select @glinestr = @glinestr + '§ '
	else if charindex('DP', @gst_srqs) > 0
		select @glinestr = @glinestr + '※ '
	else if charindex('QP', @gst_srqs) > 0
		select @glinestr = @glinestr + '〓 '
	else
		select @glinestr = @glinestr + '   '

	if not exists(select 1 from #grp_rmuse_add where type=@type)
		insert #grp_rmuse_add select @type, '', 0
	update #grp_rmuse_add set rooms=rooms+1 where type=@type

	if @gcolno = 5
		begin
		update #grp_rmuse set content=@glinestr where line=@gline

		select @gline = @gline + 1
		insert #grp_rmuse(line,rooms,gstno,content) values(@gline,null,null,'')
		select @gcolno = 0
		select @glinestr = ''
		end

	select @groupno_old = @groupno
	fetch c_grp into @resno,@accnt,@type,@roomno,@groupno,@haccnt
	end
close c_grp
deallocate cursor c_grp
deallocate cursor c_srq


if @glinestr<>''
	update #grp_rmuse set content=@glinestr where line=@gline
update #grp_rmuse set rooms=@grmno, gstno=@grno where line=@gin

// update #grp_rmuse set exp_s = a.descript from jscode a	where exp_s=a.code  //?

update #grp_rmuse set vip = '' where vip='0'
update #grp_rmuse set vip = a.descript from basecode a where a.cat='vip' and #grp_rmuse.vip=a.code
update #grp_rmuse_add set #grp_rmuse_add.descript = a.descript from typim a where #grp_rmuse_add.type=a.type


select @gline = @gline + 1
insert #grp_rmuse(line,rooms,gstno,content) values(@gline,null,null,'--------------------------')
select @gline = @gline + 1
insert #grp_rmuse(line,rooms,gstno,content) values(@gline,null,null,'注意：★/重要客人  §/领队  ※/地配  〓/全陪')
select @gline = @gline + 1
insert #grp_rmuse(line,rooms,gstno,content) values(@gline,null,null,'--------------------------')

select line,resno,accnt,name,vip,arr,dep,rooms,gstno,content,srqs,applicant,ref from #grp_rmuse
union all
select line=999, '',  '合计',type+'-'+descript,'',null,null,rooms,null,null,null,null,null from #grp_rmuse_add
 order by line

return 0
;
