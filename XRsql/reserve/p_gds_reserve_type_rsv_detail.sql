if exists(select 1 from sysobjects where name = "p_gds_reserve_type_rsv_detail")
   drop proc p_gds_reserve_type_rsv_detail
;
create  proc p_gds_reserve_type_rsv_detail
	@rm_type    	varchar(255) = '',			-- ����ʾ�����ַ������, ��Ϊ"",���ʾ��ʾ���з���
	@time				datetime = '2000/01/01',  	-- ĳ��
	@item				char(1)	= 'Y',				-- Y-Ԥ�� D-���յ���
	@langid			int		= 0
as
--------------------------------------------------------------------------------
--		ĳ��ĳ����ʹ����ϸ�б�
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

if @rm_type = 'tentative'  -- ��ʱ��������£�û����Է������ 
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

-- ��������Ԥ�� 
update #blocklist set sta='R' where accnt not like 'F%'

-- Ԥ���������� 
if @langid = 0
	update #blocklist set restype = isnull(rtrim(a.descript),''), resseq=a.sequence from restype a where #blocklist.restype=a.code
else
	update #blocklist set restype = isnull(rtrim(a.descript1),''), resseq=a.sequence from restype a where #blocklist.restype=a.code

-- �����ź� 
update #blocklist set groupno = a.groupno from master a where #blocklist.accnt = a.accnt
update #blocklist set groupno = accnt where accnt like '[MG]%'

-- ���յ�,���ܰ�����ǰ��ס? ������Ա���Ե���  
if @item = 'D' 
	delete #blocklist where sta='I' 

-- output 
select restype,accnt,name,sta,type,roomno,s_time,e_time,quan,gstno,rate,groupno
	from #blocklist order by resseq, restype, type, s_time

return 0
;


/*
_com_p_����Ԥ����ϸ�б�;
(exec p_gds_reserve_type_rsv_detail 'DK','#Bdate0#','YYYY',#langid# resultset=char50,char10,char60,char01,char03,char05,date1,date2,numb041,numb042,mone101,char101);
char101:�ź�=10;char10:�ʺ�;char60:����=20;char01:״̬;char03:����;char05:����;numb041:����=4=0=alignment="2";numb042:����=4=0=alignment="2";date1:����=10=yy/mm/dd=alignment="2";date2:�뿪=10=yy/mm/dd=alignment="2"
headerds=[header=4 player=3 footer=2 autoappe=0]
group_by=1:1:1:( "nodispchar50" )
computes=c1_headname:nodispchar50:header.1:1::char101:char60::alignment="0" border="0"  !
computes=c_yshu:'ҳ��('+string(page(),'0')+'/'+string(pagecount(),'0')+')':header:3::date2:date2::alignment="2" border="0"!
computes=c_0:( sum( numb041 * if( char05 ='', 1, 0) for group 1 )+count( char05 for group 1 distinct ) - if((sum( numb041 * if( char05 ='', 1, 0) for group 1 ))>0, 1, 0) ):trailer.1:1::numb041:numb041::alignment="2"!
computes=c_00:sum( numb041*numb042 for group 1 ):trailer.1:1::numb042:numb042::alignment="2"! 
computes=c_1:( sum( numb041 * if( char05 ='', 1, 0))+count( char05 for all distinct ) - if((sum( numb041 * if( char05 ='', 1, 0)))>0, 1, 0) ):footer:1::numb041:numb041::alignment="2"! 
computes=c_2:sum( numb041*numb042 ):footer:1::numb042:numb042::alignment="2"! 
computes=c_3:nodispchar50 + 'С��':trailer.1:1::char50:char05::alignment="2"! 
texttext=t_title:#hotel#:header:1::char50:date2::border="0" alignment="2" font.height="-12" font.italic="1"! 
texttext=t_title1:��#Bdate0#��TYPE_RSV_DETAIL��ϸ�б�:header:2::char50:date2::border="0" alignment="2" font.height="-12" font.italic="1"! 
texttext=t_typ:����-TYPE_RSV_ITEM:header:3::char10:date1::border="0" alignment="0" ! 
texttext=t_sum:�ϼ�:footer:1::char10:char05::alignment="2"! 
texttext=p_date:��ӡʱ�� #pdate#:footer:2::char10:date2::alignment="0" border="0" font.italic="1"!*/
