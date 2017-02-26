if exists(select 1 from sysobjects where name = "p_gds_master_roombook_list")
	drop proc p_gds_master_roombook_list;
create proc p_gds_master_roombook_list
	@accnt		char(10),		-- �˺�
	@arr			datetime,
 	@type			varchar(50),
	@name			varchar(50),
	@vip			char(1),
	@inc_book	char(1),			-- �����Ѿ��ŷ�?
	@inc_i		char(1),			-- ������ס?
	@req			char(1) = 'F',
	@resno		char(10),
	@cusno		char(7)
as
----------------------------------------------------------------------------------------------
--		������Ҫ�ŷ����б�
--			���������������
--				1���˺�
--				2����������
----------------------------------------------------------------------------------------------
create table #goutput(
	accnt				char(10)			not null,
	id					int				not null,
	sta				char(1)			not null,
	class				char(1)			not null,
	arr				datetime			not null,
	dep				datetime			not null,
	type				char(5)			not null,
	roomno			char(5)			null,
	name				varchar(50)		not null,
	rmnum				int	default 0	not null,
	gstno				int	default 0	not null,
	child				int	default 0	not null,
	vip				char(1)				not null,
	grpno				char(10)		default '' not null,
	cusno				char(7)		default '' not null,
	agent				char(7)		default '' not null,
	source			char(7)		default '' not null,
	grpname			varchar(50)			null,	  -- ����,��λ
	agentname		varchar(50)			null,		-- ������,��Դ
	amenities		varchar(30)			null
)

if rtrim(@accnt) is null
begin
	if rtrim(@type) is null select @type=''
	if rtrim(@name) is null select @name='%'

	if ascii(@name) > 128 
	begin		-- ������������
		select @name = '%'+ rtrim(@name) +'%'
		insert #goutput(accnt,id,sta,class,arr,dep,type,roomno,name,rmnum,gstno,child,vip,grpno,cusno,agent,source,amenities)
			select a.accnt,a.id,b.sta,b.class,a.arr,a.dep,a.type,a.roomno,c.name,a.quantity,a.gstno,b.children,c.vip,b.groupno,b.cusno,b.agent,b.source,
					isnull(rtrim(isnull(rtrim(a.amenities),b.amenities)),c.feature)
				from rsvsrc a, master b, guest c
				where a.accnt=b.accnt and b.haccnt=c.no and a.blkmark<>'T'
					and (@arr is null or a.begin_=@arr)
					and (@type='' or charindex(rtrim(a.type),@type)>0)
					and (c.name like @name or c.name2 like @name)
					and (@vip='F' or (@vip='T' and c.vip>'0'))
					and (a.roomno<'0' or (@inc_book='T' and a.roomno>'0'))
					and (b.sta='R' or (@inc_i='T' and b.sta='I'))
					and (@resno is null or b.resno=@resno)
					and (@cusno is null or b.cusno=@cusno or b.source=@cusno or b.agent=@cusno )
	end
	else
	begin		-- Ӣ����������
		select @name = '%'+ upper(rtrim(@name)) +'%'
		insert #goutput(accnt,id,sta,class,arr,dep,type,roomno,name,rmnum,gstno,child,vip,grpno,cusno,agent,source,amenities)
			select a.accnt,a.id,b.sta,b.class,a.arr,a.dep,a.type,a.roomno,c.name,a.quantity,a.gstno,b.children,c.vip,b.groupno,b.cusno,b.agent,b.source,
					isnull(rtrim(isnull(rtrim(a.amenities),b.amenities)),c.feature)
				from rsvsrc a, master b, guest c
				where a.accnt=b.accnt and b.haccnt=c.no and a.blkmark<>'T'
					and (@arr is null or a.begin_=@arr)
					and (@type='' or charindex(rtrim(a.type),@type)>0)
					and (upper(c.name) like @name or upper(c.name2) like @name)
					and (@vip='F' or (@vip='T' and c.vip>'0'))
					and (a.roomno<'0' or (@inc_book='T' and a.roomno>'0'))
					and (b.sta='R' or (@inc_i='T' and b.sta='I'))
					and (@resno is null or b.resno=@resno)
					and (@cusno is null or b.cusno=@cusno or b.source=@cusno or b.agent=@cusno )
	end
	
end
else		-- ֻ���ĳһ���˺�
begin
	declare	@class	char(1),
				@pcrec	char(10),
--				@resno	char(10),
				@master	char(10)

	select @class = class, @pcrec=pcrec, @resno=resno, @master=saccnt from master where accnt=@accnt
	if @@rowcount = 0 or charindex(@class,'FGM')=0 
		goto gout

	-- himself
	if @class='F' 
		insert #goutput(accnt,id,sta,class,arr,dep,type,roomno,name,rmnum,gstno,child,vip,grpno,cusno,agent,source,amenities)
			select a.accnt,a.id,b.sta,b.class,a.arr,a.dep,a.type,a.roomno,c.name,a.quantity,a.gstno,b.children,c.vip,b.groupno,b.cusno,b.agent,b.source,
					isnull(rtrim(isnull(rtrim(a.amenities),b.amenities)),c.feature)
				from rsvsrc a, master b, guest c
				where a.accnt=b.accnt and b.haccnt=c.no and b.sta in ('R', 'I') and a.accnt=@accnt and a.blkmark<>'T'
	else   -- ״̬��Ҫ��ʾΪ R
		insert #goutput(accnt,id,sta,class,arr,dep,type,roomno,name,rmnum,gstno,child,vip,grpno,cusno,agent,source,amenities)
			select a.accnt,a.id,'R',b.class,a.arr,a.dep,a.type,a.roomno,c.name,a.quantity,a.gstno,0,c.vip,b.accnt,b.cusno,b.agent,b.source,
					isnull(rtrim(isnull(rtrim(a.amenities),b.amenities)),c.feature)
				from rsvsrc a, master b, guest c
				where a.accnt=b.accnt and b.haccnt=c.no and b.sta in ('R', 'I') and a.accnt=@accnt and a.blkmark<>'T'

	-- ��ؿͷ�
	if @class='F'
	begin
		if @pcrec<>''  -- ����
			insert #goutput(accnt,id,sta,class,arr,dep,type,roomno,name,rmnum,gstno,child,vip,grpno,cusno,agent,source,amenities)
				select a.accnt,a.id,b.sta,b.class,a.arr,a.dep,a.type,a.roomno,c.name,a.quantity,a.gstno,b.children,c.vip,b.groupno,b.cusno,b.agent,b.source,
						isnull(rtrim(isnull(rtrim(a.amenities),b.amenities)),c.feature)
					from rsvsrc a, master b, guest c
					where a.accnt=b.accnt and b.haccnt=c.no and b.sta in ('R', 'I')  and a.blkmark<>'T'
						and b.pcrec=@pcrec and a.accnt not in (select accnt from #goutput)
		if @resno<>''  -- ͬԤ��
			insert #goutput(accnt,id,sta,class,arr,dep,type,roomno,name,rmnum,gstno,child,vip,grpno,cusno,agent,source,amenities)
				select a.accnt,a.id,b.sta,b.class,a.arr,a.dep,a.type,a.roomno,c.name,a.quantity,b.gstno,b.children,c.vip,b.groupno,b.cusno,b.agent,b.source,
						isnull(rtrim(isnull(rtrim(a.amenities),b.amenities)),c.feature)
					from rsvsrc a, master b, guest c
					where a.accnt=b.accnt and b.haccnt=c.no and b.sta in ('R', 'I')  and a.blkmark<>'T'
						and b.resno=@resno and a.accnt not in (select accnt from #goutput)
		if @master<>''  -- ͬס
			insert #goutput(accnt,id,sta,class,arr,dep,type,roomno,name,rmnum,gstno,child,vip,grpno,cusno,agent,source,amenities)
				select a.accnt,a.id,b.sta,b.class,a.arr,a.dep,a.type,a.roomno,c.name,a.quantity,b.gstno,b.children,c.vip,b.groupno,b.cusno,b.agent,b.source,
						isnull(rtrim(isnull(rtrim(a.amenities),b.amenities)),c.feature)
					from rsvsrc a, master b, guest c
					where a.accnt=b.accnt and b.haccnt=c.no and b.sta in ('R', 'I')  and a.blkmark<>'T'
						and b.saccnt=@master and a.accnt not in (select accnt from #goutput)
	end
	if @class <> 'F'   -- ��Ա
		insert #goutput(accnt,id,sta,class,arr,dep,type,roomno,name,rmnum,gstno,child,vip,grpno,cusno,agent,source,amenities)
			select a.accnt,a.id,b.sta,b.class,a.arr,a.dep,a.type,a.roomno,c.name,a.quantity,b.gstno,b.children,c.vip,b.groupno,b.cusno,b.agent,b.source,
					isnull(rtrim(isnull(rtrim(a.amenities),b.amenities)),c.feature)
				from rsvsrc a, master b, guest c
				where a.accnt=b.accnt and b.haccnt=c.no and b.sta in ('R', 'I') and b.groupno=@accnt and a.blkmark<>'T'
end

-- grp. name, company name
update #goutput set grpname = a.groupno+'/'+a.cusno, agentname = a.agent+'/'+a.source from master_des a
	where #goutput.accnt=a.accnt

--
if @req = 'T'
	delete #goutput where rtrim(amenities) is null

gout:
delete #goutput where accnt like '[GMC]%' and id=0   
select accnt,id,sta,class,arr,dep,type,roomno,name,rmnum,gstno,child,vip,grpno,grpname,agentname,amenities
	from #goutput order by roomno,arr,type

return 0
;

