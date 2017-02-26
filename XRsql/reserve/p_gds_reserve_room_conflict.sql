if object_id('p_gds_reserve_room_conflict') is not null
drop proc p_gds_reserve_room_conflict
;
create proc p_gds_reserve_room_conflict
	@roomno    		char(5),
	@arr				datetime,
	@dep				datetime,
	@accnt			char(10)=''	 -- 过滤账号
as
-- ------------------------------------------------------------------------------------
--  冲突客房列表  -- 宾客主单窗口提示 (排除同住关系的宾客)
--
--		有两种情况：交叉 或者 紧靠
--		同时注意共享参数
-- ------------------------------------------------------------------------------------
create table #goutput
(
	flag				varchar(20)					not null,	-- 属性：cross, aside
	accnt				char(10)						not null,
	sta				char(1)						not null,
	haccnt			char(7)						not null,
	name				varchar(50)	default ''	not null,
	arr				datetime						not null,
	dep				datetime						not null,
	restype			char(3)						null,
	groupno			varchar(60)	default ''	not null,
	agent				varchar(60)	default ''	not null,
	cusno				varchar(60)	default ''	not null,
	source			varchar(60)	default ''	not null,
	rate				money			default 0	not null,
	vip				char(1)		default ''	not null,
	bal				money			default 0	not null,
	ref				varchar(100) default ''	not null,
	share				char(1)		default ''	not null
)

select @arr = convert(datetime,convert(char(8),@arr,1))
select @dep = convert(datetime,convert(char(8),@dep,1))

-- Master
declare	@saccnt 	char(10),
			@master 	char(10)

if rtrim(@accnt) is null
	select @saccnt='', @master=''
else
	select @saccnt = saccnt, @master = master from master where accnt=@accnt

------------------------
--		交叉
------------------------
insert #goutput
	select 'cross',a.accnt,b.sta,b.haccnt,c.haccnt,a.arr,a.dep,b.restype,
			c.groupno,c.agent,c.cusno,c.source, b.setrate,'',b.charge-b.credit,b.ref,b.share
		from rsvsrc a, master b, master_des c
		where a.accnt=b.accnt and b.accnt*=c.accnt
			and a.roomno=@roomno and @arr<a.end_ and @dep>a.begin_
			and ((a.accnt<>@accnt and a.saccnt<>@saccnt and a.master<>@master) or @accnt='')

insert #goutput
	select 'Maintain',folio,sta,'-','OO/OS',dbegin,dend,'-',
			'-','-','-','-', 0,'',0,'',''
		from rm_ooo 
		where  roomno=@roomno and (@arr=dend or @arr=dbegin or @dep=dbegin or @dep=dend) and (@arr<>dbegin and @dep<>dend) and
			 status='I'

------------------------
--		紧靠
------------------------
insert #goutput
	select 'aside',a.accnt,b.sta,b.haccnt,c.haccnt,a.arr,a.dep,b.restype,
			c.groupno,c.agent,c.cusno,c.source, b.setrate,'',b.charge-b.credit,b.ref,b.share
		from rsvsrc a, master b, master_des c
		where a.accnt=b.accnt and b.accnt*=c.accnt
			and a.roomno=@roomno and (@arr=a.end_ or @dep=a.begin_)
			and ((a.accnt<>@accnt and a.saccnt<>@saccnt and a.master<>@master) or @accnt='')



update #goutput set vip=a.vip from guest a where #goutput.haccnt=a.no

select * from #goutput order by arr
return 0
;