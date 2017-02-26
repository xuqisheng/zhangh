if exists(select 1 from sysobjects where name = "p_gds_reserve_type_rsv_detail")
   drop proc p_gds_reserve_type_rsv_detail
;
create  proc p_gds_reserve_type_rsv_detail
	@rm_type    	varchar(255) = '',			-- 需显示房类字符串组合, 若为"",则表示显示所有房类
	@time				datetime = '2000/01/01',  	-- 某日
	@item				char(1)	= 'Y',				-- Y-预留 D-当日到达
	@langid			int		= 0
as
--------------------------------------------------------------------------------
--		某日某房类使用明细列表
--------------------------------------------------------------------------------
create table #blocklist(
	restype	varchar(50)			not null,
	resseq	int					not null,
	accnt		char(10)				not null,
	name		varchar(60)	default ''	not null,
	sta		char(1)		default ''	not null,
	type		char(5)		default ''	not null,
	roomno	char(5)		default ''	not null,
	s_time	datetime		null,
	e_time	datetime		null,
	quan		int	default 0	null,
	gstno		int	default 0	null,
	rate		money	default 0	null,
	groupno	char(10)		default ''	null
)

if @rm_type = 'tentative'  -- 暂时这种情况下，没有针对房类过滤 
begin
	insert #blocklist 		-- fo 
		select b.restype,0,a.accnt,c.haccnt,b.sta,a.type,a.roomno,a.begin_,a.end_,a.quantity,a.gstno,a.rate, ''
			from rsvsrc a, master b, master_des c, restype d
			where a.accnt=b.accnt and b.accnt=c.accnt
				and ((@item='Y' and a.begin_<=@time and a.end_>@time)
						or (@item='D' and a.begin_=@time and a.end_>@time))
				and b.restype=d.code and d.definite='F'
--				and (charindex(','+rtrim(a.type)+',', ','+rtrim(@rm_type)+',')>0 or rtrim(@rm_type) is null)
	insert #blocklist 		-- sc 
		select b.restype,0,a.accnt,c.haccnt,b.sta,a.type,a.roomno,a.begin_,a.end_,a.quantity,a.gstno,a.rate, ''
			from rsvsrc a, sc_master b, master_des c, restype d
			where b.foact='SS' and a.accnt=b.accnt and b.accnt=c.accnt
				and ((@item='Y' and a.begin_<=@time and a.end_>@time)
						or (@item='D' and a.begin_=@time and a.end_>@time))
				and b.restype=d.code and d.definite='F'
--				and (charindex(','+rtrim(a.type)+',', ','+rtrim(@rm_type)+',')>0 or rtrim(@rm_type) is null)
end
else
begin
	insert #blocklist 		-- fo 
		select b.restype,0,a.accnt,c.haccnt,b.sta,a.type,a.roomno,a.begin_,a.end_,a.quantity,a.gstno,a.rate, ''
			from rsvsrc a, master b, master_des c
			where a.accnt=b.accnt and b.accnt=c.accnt
				and ((@item='Y' and a.begin_<=@time and a.end_>@time)
						or (@item='D' and a.begin_=@time and a.end_>@time))
				and (charindex(','+rtrim(a.type)+',', ','+rtrim(@rm_type)+',')>0 or rtrim(@rm_type) is null)
	insert #blocklist 		-- sc 
		select b.restype,0,a.accnt,c.haccnt,b.sta,a.type,a.roomno,a.begin_,a.end_,a.quantity,a.gstno,a.rate, ''
			from rsvsrc a, sc_master b, master_des c
			where a.accnt=b.accnt and b.accnt=c.accnt
				and ((@item='Y' and a.begin_<=@time and a.end_>@time)
						or (@item='D' and a.begin_=@time and a.end_>@time))
				and (charindex(','+rtrim(a.type)+',', ','+rtrim(@rm_type)+',')>0 or rtrim(@rm_type) is null)
end

-- 团体主单预留 
update #blocklist set sta='R' where accnt not like 'F%'

-- 预订类型描述 
if @langid = 0
	update #blocklist set restype = isnull(rtrim(a.descript),''), resseq=a.sequence from restype a where #blocklist.restype=a.code
else
	update #blocklist set restype = isnull(rtrim(a.descript1),''), resseq=a.sequence from restype a where #blocklist.restype=a.code

-- 更新团号 
update #blocklist set groupno = a.groupno from master a where #blocklist.accnt = a.accnt
update #blocklist set groupno = accnt where accnt like '[MG]%'

-- 当日到,不能包含当前在住? 工程人员可以调整  
if @item = 'D' 
	delete #blocklist where sta='I' 

-- output 
select restype,accnt,name,sta,type,roomno,s_time,e_time,quan,gstno,rate,groupno
	from #blocklist order by resseq, restype, type, s_time

return 0
;


/*
_com_p_房类预留明细列表;
(exec p_gds_reserve_type_rsv_detail 'DK','#Bdate0#','YYYY',#langid# resultset=char50,char10,char60,char01,char03,char05,date1,date2,numb041,numb042,mone101,char101);
char101:团号=10;char10:帐号;char60:姓名=20;char01:状态;char03:房类;char05:房号;numb041:房数=4=0=alignment="2";numb042:人数=4=0=alignment="2";date1:到达=10=yy/mm/dd=alignment="2";date2:离开=10=yy/mm/dd=alignment="2"
headerds=[header=4 player=3 footer=2 autoappe=0]
group_by=1:1:1:( "nodispchar50" )
computes=c1_headname:nodispchar50:header.1:1::char101:char60::alignment="0" border="0"  !
computes=c_yshu:'页次('+string(page(),'0')+'/'+string(pagecount(),'0')+')':header:3::date2:date2::alignment="2" border="0"!
computes=c_0:( sum( numb041 * if( char05 ='', 1, 0) for group 1 )+count( char05 for group 1 distinct ) - if((sum( numb041 * if( char05 ='', 1, 0) for group 1 ))>0, 1, 0) ):trailer.1:1::numb041:numb041::alignment="2"!
computes=c_00:sum( numb041*numb042 for group 1 ):trailer.1:1::numb042:numb042::alignment="2"! 
computes=c_1:( sum( numb041 * if( char05 ='', 1, 0))+count( char05 for all distinct ) - if((sum( numb041 * if( char05 ='', 1, 0)))>0, 1, 0) ):footer:1::numb041:numb041::alignment="2"! 
computes=c_2:sum( numb041*numb042 ):footer:1::numb042:numb042::alignment="2"! 
computes=c_3:nodispchar50 + '小计':trailer.1:1::char50:char05::alignment="2"! 
texttext=t_title:#hotel#:header:1::char50:date2::border="0" alignment="2" font.height="-12" font.italic="1"! 
texttext=t_title1:【#Bdate0#】TYPE_RSV_DETAIL明细列表:header:2::char50:date2::border="0" alignment="2" font.height="-12" font.italic="1"! 
texttext=t_typ:房类-TYPE_RSV_ITEM:header:3::char10:date1::border="0" alignment="0" ! 
texttext=t_sum:合计:footer:1::char10:char05::alignment="2"! 
texttext=p_date:打印时间 #pdate#:footer:2::char10:date2::alignment="0" border="0" font.italic="1"!*/
