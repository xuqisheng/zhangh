-- ------------------------------------------------------------------------------
-- crs link pms 
-- 
-- ��������
--		������յ�����,���緿��,�г����, 1-1, 1-n ? 
--		������Ķ������������: crslink_rc & rmratecode �����ݶ�Ӧ��һ������α�֤ 
--		������������ 
--
--
--	2006/9/19 simon
--	���ݽ����¶� ���µĽ��ͣ� ������ϵ��Խӿڼ��ɣ���������һ�����չ�ϵ�����ˡ�
-- ������ϵ�� ���� û�й�ϵ��
-- ���������ԭ��������е�crsid �ֶξ�û�����ˡ� 
--
--
-- ------------------------------------------------------------------------------

-- ########################
-- Part 1: ϵͳ���� 
-- ########################

-- ------------------------
-- CRS Interface ϵͳ���� 
-- ------------------------
if exists(select * from sysobjects where name = "crslink_option")
	drop table crslink_option;
create table crslink_option
(
	crsid			char(30)							not null,	-- ����� CRS �������ԣ����ǽӿ������� �� 
																		-- ԭ����ע��: pms ���ӵ� crs ��ǣ��� HUBS1=�¶� PEGASUS ...
	catalog 		char(12)     					not NULL,
	item    		char(32)     					not NULL,
	value   		varchar(255) 					NULL,
	def			varchar(255) 					NULL,		-- ����ȱʡֵ
	remark  		varchar(255) 					NULL,		-- ����˵��
	remark1		varchar(255) 					NULL,		-- Ӣ��˵��
	addby			varchar(10) 					NULL,		-- �����ߣ��ɻ��ʱ�򣬿��������ʡ���
	addtime		datetime	default getdate() not null,	-- ������ʱ�� 
	usermod		char(1)	default 'T'	null,					-- �û������޸�
	lic			varchar(20) default '' not null			-- ��Ȩ����
)
exec sp_primarykey crslink_option,crsid,catalog,item
create unique index index1 on crslink_option(crsid,catalog,item)
;


-- ########################
-- Part 2: ��ͨ����
-- ########################

-- ------------------------
-- CRS ϵͳ����
-- ------------------------
if exists(select * from sysobjects where name = "crslink_id")
	drop table crslink_id;
create table crslink_id
(
	crsid			char(30)							not null,	-- ����� CRS �������ԣ����ǽӿ������� �� -- ����϶������� 
																		-- ԭ����ע��: pms ���ӵ� crs ��ǣ��� HUBS1=�¶� PEGASUS ...
   descript   		varchar(60) default ''		not null,
   descript1  		varchar(60) default ''		not null,
	flag				char(30)		default ''		not null,	-- ���
	remark			text								null,			-- ����
	halt				char(1)		default 'F'		not null,	-- ͣ��
	sequence			int			default 0		not null		-- ����
)
exec sp_primarykey crslink_id,crsid
create unique index index1 on crslink_id(crsid)
;

-- -------------------------------------------------------------------
-- һ�������ձ�
--
--		�ر�ע�⣬����Ĵ������Ҫ��  CRS  ��PMS = N  ��1  
--		��Ϊ���붩�����ص�ʱ����Ҫ�ܹ�����Ĳ������ض���
--		��ʱ������������Ӧ���. 
--		����ʵ�ʿ�����Ҫ������CRSָ���ı�׼��ͷ������ܶ�Ӧ���Ƶ�������
-- -------------------------------------------------------------------
if exists(select * from sysobjects where name = "crslink_code")
	drop table crslink_code;
create table crslink_code
(
	crsid			char(30)							not null,	-- ����� CRS �������ԣ����ǽӿ������� �� 
																		-- ԭ����ע��: pms ���ӵ� crs ��ǣ��� HUBS1=�¶� PEGASUS ...
	cat				char(30)							not null,	-- ��������� 
   descript   		varchar(60)    				not null,
   descript1  		varchar(60) default ''   	not null,
	pmscode			text			default ''   	not null,
	sequence			int			default 0		not null			-- ����
)
exec sp_primarykey crslink_code,crsid,cat
create unique index index1 on crslink_code(crsid,cat)
;


if exists(select * from sysobjects where name = "crslink_codedef")
	drop table crslink_codedef;
create table crslink_codedef
(
	crsid				char(30)							not null,
	cat				char(30)							not null,	-- ��������� 

	crscode			char(20)							not null,
   crsdes   		varchar(60)    				not null,
   crsdes1  		varchar(60) default ''   	not null,

	pmscode			char(20)							not null,
   pmsdes   		varchar(60)    				not null,
   pmsdes1  		varchar(60) default ''   	not null,

	crsgrp			varchar(20)	default ''   	not null,		-- ����
	sequence			int			default 0		not null			-- ����
)
exec sp_primarykey crslink_codedef,crsid,cat,crscode
create unique index index1 on crslink_codedef(crsid,cat,crscode)
create index index2 on crslink_codedef(crsid,cat,pmscode)
;


-- ########################
-- Part 3: ���۴���
-- ########################

-- ------------------------
-- crslink_rc---���۴���� 
-- ------------------------
if exists(select * from sysobjects where name = "crslink_rc")
	drop table crslink_rc;
create table crslink_rc
(
	crsid				char(30)							not null,
	pmsrc				char(10)							not null,	-- pms ���۴���
	channel_link	varchar(100)	default ''	not null,  	-- �����Щ�������� 
	code          char(10)	    					not null,  	-- ���۴���
	cat          	char(3)	    					not null,
   descript      varchar(60)      				not null,  	-- ����  
   descript1     varchar(60)     default ''	not null,  	-- ����  
   private       char(1) 			default 'T'	not null,  	-- ˽�� or ����
   mode       	  char(1) 			default ''	not null,  	-- ģʽ--�Ժ����������������۵�ȡ��
   folio       	varchar(30) 	default ''	not null, 	-- �ʵ�
	src				char(3)			default ''	not null,	-- ������Դ
	market			char(3)			default ''	not null,	-- �г�����
	packages			char(50)			default ''	not null,	--	����
	amenities  		varchar(30)		default ''	not null,	-- ���䲼��
	begin_			datetime							null,
	end_				datetime							null,
	calendar			char(1)		default 'F'	not null,	-- ��������
	yieldable		char(1)		default 'F'	not null,	-- ���Ʋ���
	yieldcat			char(3)		default ''	not null,
	bucket			char(3)		default ''	not null,
	staymin			int			default 0	not null,
	staymax			int			default 0	not null,
	pccode			char(5)		default ''	not null,
	halt				char(1)		default 'F'	not null,
	sequence			int			default 0	not null
)
exec sp_primarykey crslink_rc,crsid, code;
create unique index index1 on crslink_rc(crsid, code);
create unique index index2 on crslink_rc(crsid, descript);
;


-- -------------------------------
-- crslink_rcdef - ���۶�����ϸ��
-- -------------------------------
if exists(select * from sysobjects where name = "crslink_rcdef")
	drop table crslink_rcdef;
create table crslink_rcdef
(
	crsid				char(30)							not null,
	code          	char(10)	    					not null,  	--  ���۴���  
	id          	char(10)	    					not null,  	--  ��ϸ���
   descript      	varchar(30)						not null,
   descript1     	varchar(40)		default ''	not null,
	begin_			datetime							null,
	end_				datetime							null,

	packages			varchar(50)		default ''	not null,	--	����
	amenities  		varchar(30)		default ''	not null,	-- ���䲼��
	market			char(3)			default ''	not null,	-- �г�����
	src				char(3)			default ''	not null,	-- ������Դ

	year				varchar(100)	default ''	not null,
	month				varchar(34)		default ''	not null,
	day				varchar(100)	default ''	not null,
	week				varchar(20)		default ''	not null,
	stay				int				default 0	not null,

	hall				varchar(20)		default ''	not null,
	gtype				varchar(100)	default ''	not null,
	type				varchar(100)	default ''	not null,
	flr				varchar(30)		default ''	not null,
	roomno			varchar(100)	default ''	not null,
	rmnums			int				default 0	not null,
	ratemode			char(1)			default 'S'	not null,	-- ����ģʽ  S=ʵ�� D=�Ż� (������ԼӴ���С��������ʵ��)
	
	stay_cost		money				default 0	not null,	-- �ο� fidelio
	fix_cost			money				default 0	not null,
	prs_cost			money				default 0	not null,

-- �����۸�
	rate1				money			default 0		not null,		-- 1 �˼�
	rate2				money			default 0		not null,
	rate3				money			default 0		not null,
	rate4				money			default 0		not null,
	rate5				money			default 0		not null,
	rate6				money			default 0		not null,
	extra				money			default 0		not null,		-- �Ӵ�
	child				money			default 0		not null,		-- С����
	crib				money			default 0		not null			-- Ӥ����
)
exec sp_primarykey crslink_rcdef,crsid,code,id
create unique index index1 on crslink_rcdef(crsid,code,id)
;


-- ########################
-- Part 4: �ͷ��ŷ� 
-- ########################
-- ------------------------
-- �ŷ����� 
-- ------------------------
if exists(select * from sysobjects where name = "crslink_rmset")
	drop table crslink_rmset;
create table crslink_rmset
(
	crsid				char(30)							not null,
	date				datetime							not null,
	rmtype			char(5)							not null,
	usetype			char(1)		default ''		not null,	-- �Ƿ�ʹ�ðٷֱ� 
	quantity			int			default 0		not null,
	used				int			default 0		not null,
	cby				char(10)		default ''		not null,
	changed			datetime							null,
	logmark			int			default 0		not null
)
exec sp_primarykey crslink_rmset,crsid,date,rmtype
create unique index index1 on crslink_rmset(crsid,date,rmtype)
;


-- ########################
-- Part 5: ��ش�����, ���� 
-- ########################

if exists(select 1 from sysobjects where name='t_crslink_id_insert' and type='TR')
	drop trigger t_crslink_id_insert
;
//create trigger t_crslink_id_insert		-- ���벻���������ʱ�������������û�����ˡ� 
//   on crslink_id
//   for insert 
//as
//--------------------------------------------------------------------------
//--	crslink_id trigger : Insert 
//--------------------------------------------------------------------------
//declare	@crsid		char(30)
//
//select @crsid = crsid from inserted 
//if @@rowcount = 0 
//   rollback trigger with raiserror 20000 "���Ӵ������HRY_MARK"
//else
//begin
//	insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
//		values (@crsid,"RMTYPE","����","Room Type","ddlb=select type, rtrim(descript)+'-'+descript1 from typim where tag<>'P' order by sequence,type��",100)
//	insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
//		values (@crsid,"RESTYPE","Ԥ������","Resrv. Type","ddlb=select code, rtrim(descript)+'-'+descript1 from restype order by sequence,code�� ",100)
//	insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
//		values (@crsid,"MARKET","�г���","Market","ddlb=select code, rtrim(descript)+'-'+descript1 from mktcode order by sequence,code�� ",100)
//	insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
//		values (@crsid,"SOURCE","��Դ","Source","ddlb=select code, rtrim(descript)+'-'+descript1 from srccode order by sequence,code�� ",100)
//	insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
//		values (@crsid,"CHANNEL","����","Channel","ddlb=select code, rtrim(descript)+'-'+descript1 from basecode where cat='channel' and halt='F' order by sequence,code�� ",100)
//	insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
//		values (@crsid,"REQUEST","����Ҫ��","Request","ddlb=select code, rtrim(descript)+'-'+descript1 from reqcode order by sequence,code�� ",100)
//	insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
//		values (@crsid,"AMENITIES","�ͷ�����","Amenities","ddlb=select code, rtrim(descript)+'-'+descript1 from basecode where cat='amenities' and halt='F' order by sequence,code�� ",100)
//	insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
//		values (@crsid,"VIP","����ȼ�","VIP Grade","ddlb=select code, rtrim(descript)+'-'+descript1 from basecode where cat='vip' and halt='F' order by sequence,code�� ",100)
//end
//;

if exists(select 1 from sysobjects where name='t_crslink_id_delete' and type='TR')
	drop trigger t_crslink_id_delete
;
//create trigger t_crslink_id_delete		-- ���벻���������ʱ�������������û�����ˡ� 
//   on crslink_id
//   for delete
//as
//--------------------------------------------------------------------------
//--	crslink_id trigger : Delete 
//--------------------------------------------------------------------------
//declare	@crsid		char(30)
//select @crsid = crsid from deleted  
//if @@rowcount = 0 
//   rollback trigger with raiserror 20000 "ɾ���������HRY_MARK"
//else
//begin
//	delete crslink_code where crsid=@crsid 
//	delete crslink_codedef where crsid=@crsid 
//	delete crslink_rc where crsid=@crsid 
//	delete crslink_rcdef where crsid=@crsid 
//	delete crslink_rmset where crsid=@crsid 
//end
//;

if exists(select * from sysobjects where name = "p_crslink_rmset_list")
   drop proc p_crslink_rmset_list
;
create proc p_crslink_rmset_list
	@crsid			char(30),
	@begin			datetime,
	@end				datetime,
	@rmtype			char(5),
	@empno			char(10)
as
------------------------------------------------------------------------------
--	CRS Interface �ŷ���¼��ѯ
------------------------------------------------------------------------------
if rtrim(@crsid) is null -- or not exists(select 1 from crslink_id where crsid=@crsid) 
	return 1

select @rmtype = ltrim(rtrim(@rmtype))
if @rmtype is not null and not exists(select 1 from crslink_codedef where crsid='HUBS1' and cat='RMTYPE' and crscode=@rmtype) 
	return 1

if @begin is null or @end is null
	return 1 

-- 
declare	@count		int 
select @begin 	= convert(datetime,convert(char(8),@begin,1))
select @end 	= convert(datetime,convert(char(8),@end,1))
select @count = datediff(dd, @begin, @end) 
if @count<=0 or @count>366 
	return 1 

-- 
declare	@now	datetime 
select @now = getdate()
create table #allrec (date datetime, rmtype char(5), cby char(10)  null )
while @begin <= @end
begin
	insert #allrec 
		select @begin, crscode, null from crslink_codedef
			where crsid='HUBS1' and cat='RMTYPE' and (@rmtype is null or crscode=@rmtype)

	select @begin = dateadd(dd, 1, @begin)
end
update #allrec set cby=a.cby from crslink_rmset a 
	where #allrec.date=a.date and #allrec.rmtype=a.rmtype and a.crsid=@crsid 
insert crslink_rmset(crsid,date,rmtype,quantity,used,cby,changed,logmark)
	select @crsid, date, rmtype, 0, 0, @empno, @now, 0 
		from #allrec a where cby is null 

return 0
;


----------------------------------------------------------------------
--	���������� 
----------------------------------------------------------------------
IF OBJECT_ID('p_crslink_rcset') IS NOT NULL
    DROP PROCEDURE p_crslink_rcset
;
create proc p_crslink_rcset
	@crsid			char(30),
	@code				char(10),
	@des				char(60),
	@des1				char(60),
	@pmsrc			char(10),
	@clink			varchar(100), 
	@sequence		int,
	@empno			char(10)
as
------------------------------------------------------------------------------
--	CRS Interface ���������� 
------------------------------------------------------------------------------
declare	@ret			int,
			@msg			varchar(60)

select @ret=0, @msg=''

-- ����У�� 
select @crsid 	= ltrim(rtrim(@crsid))
select @code 	= ltrim(rtrim(@code))
select @des 	= ltrim(rtrim(@des))
select @des1 	= ltrim(rtrim(@des1))
select @pmsrc 	= ltrim(rtrim(@pmsrc))
select @clink 	= ltrim(rtrim(@clink))
select @sequence = isnull(@sequence, 0) 
			
//if @crsid is null or not exists(select 1 from crslink_id where crsid=@crsid) 
//begin
//	select @ret=1, @msg='����Ԥ���ӿڴ������'
//	goto goutput 
//end
select @crsid = 'HUBS1'

if @code is null 
begin
	select @ret=1, @msg='������%1^���۴���'
	goto goutput 
end
if @des is null  or @des1 is null 
begin
	select @ret=1, @msg='������%1^���۴�������'
	goto goutput 
end
if @pmsrc is null or not exists(select 1 from rmratecode where code=@pmsrc) 
begin
	select @ret=1, @msg='���õı��ط��۴������'
	goto goutput 
end
if @clink is null 
	select @clink = ''

-- 
if not exists(select 1 from crslink_rc where crsid=@crsid and code=@code and pmsrc=@pmsrc)
begin
	delete crslink_rc where crsid=@crsid and code=@code 
	delete crslink_rcdef where crsid=@crsid and code=@code 

	insert crslink_rc (crsid,pmsrc,channel_link,code,cat,descript,descript1,private,mode,folio,src,market,packages,amenities,
			begin_,end_,calendar,yieldable,yieldcat,bucket,staymin,staymax,pccode,halt,sequence )
		SELECT @crsid,b.code,@clink,@code,b.cat,@des,@des1,b.private,b.mode,b.folio,b.src,b.market,b.packages,b.amenities,
					b.begin_,b.end_,b.calendar,b.yieldable,b.yieldcat,b.bucket,b.staymin,b.staymax,b.pccode,b.halt,b.sequence  
			FROM rmratecode b where b.code = @pmsrc

	insert crslink_rcdef(crsid,code,id,descript,descript1,begin_,end_,packages,amenities,market,src,
			year,month,day,week,stay,hall,gtype,type,flr,roomno,rmnums,ratemode,
			stay_cost,fix_cost,prs_cost,rate1,rate2,rate3,rate4,rate5,rate6,extra,child,crib)
		SELECT a.crsid,a.code,c.code,c.descript,c.descript1,c.begin_,c.end_,c.packages,c.amenities,c.market,c.src,c.
				year,c.month,c.day,c.week,c.stay,c.hall,c.gtype,c.type,c.flr,c.roomno,c.rmnums,c.ratemode,c.
				stay_cost,c.fix_cost,c.prs_cost,c.rate1,c.rate2,c.rate3,c.rate4,c.rate5,c.rate6,c.extra,c.child,c.crib  
			FROM crslink_rc a, rmratecode_link b, rmratedef c
				where a.crsid=@crsid and a.code=@code and a.pmsrc=b.code and b.rmcode=c.code 
end
else
begin
	update crslink_rc set descript=@des, descript1=@des1, channel_link=@clink, sequence=@sequence where crsid=@crsid and code=@code and pmsrc=@pmsrc 
end

goutput:
select @ret, @msg

return @ret
;


------------------------------------------------------------------------------
--	�ŷ���¼�޸�
------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "p_crslink_rmset_update" and type='P')
   drop proc p_crslink_rmset_update;
create proc p_crslink_rmset_update
	@crsid			char(30),
	@begin			datetime,
	@end				datetime,
	@rmtype			char(5),
	@rmnum			integer,
	@mode				char(1),	--'1'������'0'����
	@empno			char(10)
as
------------------------------------------------------------------------------
--	CRS Interface �ŷ���¼�޸�
------------------------------------------------------------------------------
if rtrim(@crsid) is null -- or not exists(select 1 from crslink_id where crsid=@crsid) 
	return 1

select @rmtype = ltrim(rtrim(@rmtype))
if @rmtype is not null and not exists(select 1 from crslink_codedef where crsid='HUBS1' and cat='RMTYPE' and crscode=@rmtype) 
	return 1

if @begin is null or @end is null
	return 1 

select @begin 	= convert(datetime,convert(char(8),@begin,1))
select @end 	= convert(datetime,convert(char(8),@end,1))

while @begin <= @end
begin
	if exists( select 1 from crslink_rmset where date=@begin and crsid=@crsid and (@rmtype is null or rmtype=@rmtype) )
		begin
		if @mode = '1'	---����
			update crslink_rmset set quantity = quantity + @rmnum,cby=@empno,changed=getdate(),logmark=logmark+1 where date=@begin and crsid=@crsid and (@rmtype is null or rmtype=@rmtype)
		else
			update crslink_rmset set quantity = @rmnum,cby=@empno,changed=getdate(),logmark=logmark+1 where date=@begin and crsid=@crsid and (@rmtype is null or rmtype=@rmtype)
		end
	else
		begin
		if @rmtype is null
			insert crslink_rmset(crsid,date,rmtype,quantity,used,cby,changed,logmark) 
			 select @crsid,@begin,crscode,@rmnum,0,@empno,getdate(),0 from crslink_codedef where crsid='HUBS1' and cat='RMTYPE'
		else
			insert crslink_rmset(crsid,date,rmtype,quantity,used,cby,changed,logmark) 
			 select @crsid,@begin,@rmtype,@rmnum,0,@empno,getdate(),0
		end

	select @begin = dateadd(dd, 1, @begin)
end

return 0
;



------------------------------------------------------------------------------
-- ���ó�ʼ���ݼ�����ʾ 
------------------------------------------------------------------------------
------------------------
-- 1. ���ݲ���
------------------------
-- ���� crslink_option 
insert crslink_option (crsid,catalog,item,value,def,remark,remark1,addby,addtime)
	select 'HUBS1','channel','selected_for_room','GDS,CTRIP','','������������','������������','FOX','2006/9/1';
insert crslink_option (crsid,catalog,item,value,def,remark,remark1,addby,addtime)
	select 'HUBS1','rmset','mode','1','1','���Ϸ�������ģʽ��0=�Ƶ�ʵ��ʵʱ���� 1=�ֹ����÷���','���Ϸ�������ģʽ��0=�Ƶ�ʵ��ʵʱ���� 1=�ֹ����÷���','FOX','2006/9/1';

-- ���� crslink_id  = ���� 
insert crslink_id(crsid,descript,descript1,sequence) values ('GDS', 'ȫ��Ƶ�Ԥ����', 'Global Distribution System', 100);
insert crslink_id(crsid,descript,descript1,sequence) values ('IDS', '������������', 'Internet Distribution System', 200);
insert crslink_id(crsid,descript,descript1,sequence) values ('CTRIP', 'Я��������', 'Ctrip Traval', 300);
insert crslink_id(crsid,descript,descript1,sequence) values ('ELONG', 'e��������', 'eLong Traval', 400);

-- ���� crslink_code  = һ�������ձ�
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"RMTYPE","����","Room Type","ddlb=select type, type+'-'+rtrim(descript)+'-'+descript1 from typim where tag<>'P' order by sequence,type��",100)
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"RESTYPE","Ԥ������","Resrv. Type","ddlb=select code, code+'-'+rtrim(descript)+'-'+descript1 from restype order by sequence,code�� ",200)
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"MARKET_CAT","�г������","Market Catalog","ddlb=select code, code+'-'+rtrim(descript)+'-'+descript1 from basecode where cat='market_cat' order by sequence,code�� ",300)
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"MARKET","�г���","Market","ddlb=select code, code+'-'+rtrim(descript)+'-'+descript1 from mktcode order by sequence,code�� ",400)
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"SOURCE","��Դ","Source","ddlb=select code, code+'-'+rtrim(descript)+'-'+descript1 from srccode order by sequence,code�� ",500)
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"CHANNEL","����","Channel","ddlb=select code, code+'-'+rtrim(descript)+'-'+descript1 from basecode where cat='channel' and halt='F' order by sequence,code�� ",600)
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"REQUEST","����Ҫ��","Request","ddlb=select code, code+'-'+rtrim(descript)+'-'+descript1 from reqcode order by sequence,code�� ",700)
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"AMENITIES","�ͷ�����","Amenities","ddlb=select code, code+'-'+rtrim(descript)+'-'+descript1 from basecode where cat='amenities' and halt='F' order by sequence,code�� ",800)
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"VIP","����ȼ�","VIP Grade","ddlb=select code, code+'-'+rtrim(descript)+'-'+descript1 from basecode where cat='vip' and halt='F' order by sequence,code�� ",900)
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"RCGRP","���۴������","RateCode Group","ddlb=select code, code+'-'+rtrim(descript)+'-'+descript1 from basecode where cat='rmratecat' and halt='F' order by sequence,code�� ",1000)

-- ���� ��ͨ���� -- crsid ������������ֱ�Ӳ��� HUBS1 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'RMTYPE',type,descript,descript1,type,descript,descript1,'',sequence from typim; 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'RESTYPE',code,descript,descript1,code,descript,descript1,'',sequence from restype; 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'MARKET',code,descript,descript1,code,descript,descript1,'',sequence from mktcode; 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'MARKET_CAT',code,descript,descript1,code,descript,descript1,'',sequence from basecode where cat='market_cat'; 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'SOURCE',code,descript,descript1,code,descript,descript1,'',sequence from srccode; 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'CHANNEL',code,descript,descript1,code,descript,descript1,'',sequence from basecode where cat='channel'; 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'REQUEST',code,descript,descript1,code,descript,descript1,'',sequence from reqcode; 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'AMENITIES',code,descript,descript1,code,descript,descript1,'',sequence from basecode where cat='amenities'; 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'VIP',code,descript,descript1,code,descript,descript1,'',sequence from basecode where cat='vip'; 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'RCGRP',code,descript,descript1,code,descript,descript1,'',sequence from basecode where cat='rmratecat'; 

-- ���� PMS�д��� CRS �����ķ����� - 1��crslink_rc
insert crslink_rc (crsid,pmsrc,code,cat,descript,descript1,private,mode,folio,src,market,packages,amenities,
						begin_,end_,calendar,yieldable,yieldcat,bucket,staymin,staymax,pccode,halt,sequence )
	SELECT 'HUBS1',b.code,b.code,b.cat,b.descript,b.descript1,b.private,b.mode,b.folio,b.src,b.market,b.packages,b.amenities,
			b.begin_,b.end_,b.calendar,b.yieldable,b.yieldcat,b.bucket,b.staymin,b.staymax,b.pccode,b.halt,b.sequence  
	FROM rmratecode b where b.descript like '%CRS%';
-- ���� PMS�д��� CRS �����ķ����� - 2��crslink_rcdef
insert crslink_rcdef(crsid,code,id,descript,descript1,begin_,end_,packages,amenities,market,src,
							year,month,day,week,stay,hall,gtype,type,flr,roomno,rmnums,ratemode,
							stay_cost,fix_cost,prs_cost,rate1,rate2,rate3,rate4,rate5,rate6,extra,child,crib)
	SELECT a.crsid,a.code,c.code,c.descript,c.descript1,c.begin_,c.end_,c.packages,c.amenities,c.market,c.src,c.
			year,c.month,c.day,c.week,c.stay,c.hall,c.gtype,c.type,c.flr,c.roomno,c.rmnums,c.ratemode,c.
			stay_cost,c.fix_cost,c.prs_cost,c.rate1,c.rate2,c.rate3,c.rate4,c.rate5,c.rate6,c.extra,c.child,c.crib  
	FROM crslink_rc a, rmratecode_link b, rmratedef c where a.code=b.code and b.rmcode=c.code;

------------------------
-- 2. ������ʾ
------------------------
select * from sysdata; 
select * from crslink_id order by sequence, crsid; 
select * from crslink_code order by crsid, sequence, cat;
select * from crslink_codedef order by crsid, cat, sequence, crscode;
select * from crslink_rc order by crsid, sequence, code;
select * from crslink_rcdef order by crsid, code, id;
select * from crslink_rmset order by crsid, date, rmtype; 
