if exists (select 1 from sysobjects where name ='p_wz_reserve_group_rmocc_rep')
	drop  proc p_wz_reserve_group_rmocc_rep;
create  proc p_wz_reserve_group_rmocc_rep
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
	@groupno			char(10),
	@resno			varchar(10),
	@accnt			char(10),
	@groupno_old	char(10),
	@resno_old		varchar(10),
	@accnt_old		char(10),
	@roomno			char(5),
	@type				char(5),
	@mst_vip			char(1),
	@vip				varchar(6),
	@srqs				varchar(20),
	@name				varchar(60),
	@addr				varchar(60),
	@applicant		varchar(60),
	@ref				varchar(120),
	@exp_s			varchar(10),
	@arr				datetime,
	@dep				datetime,
	@gstno			int,
	@tmp				varchar(5)

declare
	@gcode			char(2),
	@gdes				char(20),
	@grno				int,
	@grmno			int

create table #grp_rmuse (
	line				int				not null,
	resno				char(10)			null,
	accnt				char(10)			null,
	name				varchar(50)		null,
	vip				char(1)			null,
	arr				datetime			null,
	dep				datetime			null,
	srqs				varchar(20)		null,
	applicant		varchar(60)		null,
	exp_s				varchar(10)		null,
	rooms				int				null,
	gstno				int				null,
	content			varchar(80)		default '' null,
	ref				varchar(90)		default '' null
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

declare c_srq cursor for select srqs from master where accnt=@accnt

declare c_grpno  cursor for
	select isnull(rtrim(a.resno),'-'),a.accnt
	from master 
	where  charindex(sta, 'XNODS')=0
			and (@stas is null or charindex(sta,@stas)>0)
			and (@begin_ is null or datediff(dd,@begin_,arr)>=0)
			and (@end_ is null or datediff(dd,dep,@end_)>=0)
	order by groupno,accnt

declare c_grp  cursor for
	select a.type,a.roomno,a.groupno
	from master 
	where  charindex(sta, 'XNODS')=0
			and (@stas is null or charindex(sta,@stas)>0)
			and (@begin_ is null or datediff(dd,@begin_,arr)>=0)
			and (@end_ is null or datediff(dd,dep,@end_)>=0)
	order by groupno,accnt









deallocate cursor c_grp
deallocate cursor c_srq


if @glinestr<>''
update #grp_rmuse set content=@glinestr where line=@gline
update #grp_rmuse set rooms=@grmno, gstno=@grno where line=@gin

//update #grp_rmuse set exp_s = a.descript from jscode a	where exp_s=a.code
//update #grp_rmuse set vip = '' where vip='0'
//update #grp_rmuse set vip = a.flag from vipcode a where vip=a.code
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
