
if exists ( select * from sysobjects where name = 'p_foxhis_create_grp_datatype' and type = 'P')
	drop proc p_foxhis_create_grp_datatype;
create proc p_foxhis_create_grp_datatype
as
----------------------------------------------------
-- grp_base_datatype �������ͱ�
----------------------------------------------------

-- ������ݣ�ȫ�²���
delete grp_base_datatype

-- ָ��¼��


------------------
-- 1.����
------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('RevTtl', '������', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RevRm', '�ͷ�����', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RevRm.f', '�ͷ�����-ɢ��', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RevRm.g', '�ͷ�����-����', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RevRm.c', '�ͷ�����-����', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RevRm.l', '�ͷ�����-����', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RevFB', '��������', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RevOth', '��������', '', '')

------------------
-- 2.����
------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsTtl', '�ͷ�����', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsOO', 'ά�޷�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsOS', '������', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsSold', '���۷�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsSold.f', '���۷�-ɢ��', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsSold.g', '���۷�-����', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsSold.c', '���۷�-����', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsSold.l', '���۷�-����', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsHtl', '���÷�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsEnt', '��ѷ�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsAvl', '���÷�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsExtra', '�Ӵ�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsArr', '�ͷ�-���յִ�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsDep', '�ͷ�-�������', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsDaybook', '�ͷ�-����Ԥ����', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsNoshow', '�ͷ�-NoShow', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsCXL', '�ͷ�-ȡ��Ԥ��', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsExtend', '�ͷ�-��ס', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmsRetu', '�ͷ�-��ͷ��', '', '')

------------------
-- 3.����
------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('GstTtl', '��������', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Gst.f', '������-ɢ��', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Gst.g', '������-����', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Gst.c', '������-����', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Gst.l', '������-����', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Gst.in', '������-�ڱ�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Gst.ou', '������-���', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Gst.retu', '������-��ͷ��', '', '')

------------------
-- 4.�г������ 
------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmRev.1', '�г���-����-��Э��ɢ��', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmRev.2', '�г���-����-�Ŷ�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmRev.3', '�г���-����-��������', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmRev.4', '�г���-����-Э�鹫˾', '', '')
--------------------------------------------------------------------------------------------------------------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmNgt.1', '�г���-����-��Э��ɢ��', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmNgt.2', '�г���-����-�Ŷ�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmNgt.3', '�г���-����-��������', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmNgt.4', '�г���-����-Э�鹫˾', '', '')
--------------------------------------------------------------------------------------------------------------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmGst.1', '�г���-����-��Э��ɢ��', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmGst.2', '�г���-����-�Ŷ�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmGst.3', '�г���-����-��������', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Mkt.RmGst.4', '�г���-����-Э�鹫˾', '', '')

------------------
-- 5.��Դ�����
------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmRev.1', '��Դ��-����-����Ԥ��', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmRev.2', '��Դ��-����-����ɢ��', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmRev.3', '��Դ��-����-����Ԥ��', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmRev.4', '��Դ��-����-������', '', '')
--------------------------------------------------------------------------------------------------------------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmNgt.1', '��Դ��-����-����Ԥ��', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmNgt.2', '��Դ��-����-����ɢ��', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmNgt.3', '��Դ��-����-����Ԥ��', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmNgt.4', '��Դ��-����-������', '', '')
--------------------------------------------------------------------------------------------------------------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmGst.1', '��Դ��-����-����Ԥ��', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmGst.2', '��Դ��-����-����ɢ��', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmGst.3', '��Դ��-����-����Ԥ��', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('Src.RmGst.4', '��Դ��-����-������', '', '')

---------------
-- 6.�������
---------------
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmRev.1', '����-����-���÷�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmRev.2', '����-����-����', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmRev.3', '����-����-��ͥ�׷�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmRev.4', '����-����-���˷�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmRev.5', '����-����-��׼��', '', '')
--------------------------------------------------------------------------------------------------------------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmNgt.1', '����-����-���÷�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmNgt.2', '����-����-����', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmNgt.3', '����-����-��ͥ�׷�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmNgt.4', '����-����-���˷�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmNgt.5', '����-����-��׼��', '', '')
--------------------------------------------------------------------------------------------------------------------------
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmGst.1', '����-����-���÷�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmGst.2', '����-����-����', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmGst.3', '����-����-��ͥ�׷�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmGst.4', '����-����-���˷�', '', '')
insert grp_base_datatype(datatype,description,edescription,remark) values('RmType.RmGst.5', '����-����-��׼��', '', '')

;


if exists ( select * from sysobjects where name = 'p_foxhis_create_grp_data_x' and type = 'P')
	drop proc p_foxhis_create_grp_data_x;
create proc p_foxhis_create_grp_data_x
	@date		datetime 
as
----------------------------------------------------
-- ����Ƶ꼯�����ݲɼ� for X ϵ��
--
-- �ù����ڳ�Ա�Ƶ�ÿ��ִ��
-- ���ݼ���ָ�����Ĺ涨����������Բɼ� 
----------------------------------------------------
declare
	@hotelid 	char(20),
	@hotelname 	char(60),
	@hotelename char(60),
	@roomnumber money

----------------------------------------------------
-- 0. grp_base_hotel ��ŵ���Ƶ������Ϣ
----------------------------------------------------
select @hotelid = isnull(rtrim(ltrim(value)),'') from sysoption where catalog='hotel' and item='hotelid'
if @hotelid <> ''
begin
	delete from grp_base_hotel where hotelid=@hotelid  -- ÿ�θ��� 

	select @hotelname = isnull(rtrim(ltrim(value)), '') from sysoption where catalog='hotel' and item='name'
	select @hotelename = isnull(rtrim(ltrim(value)), '') from sysoption where catalog='hotel' and item='ename'
	select @roomnumber = isnull((select sum(quantity) from typim where tag<>'P'), 0) 
	insert grp_base_hotel(hotelid, hotelname, hotelename, roomnumber)
		values (@hotelid, @hotelname, @hotelename, @roomnumber)
end
else
	return 


------------------------------------
-- ��ʼ�ɼ�ÿ������ 
------------------------------------
delete grp_group_basedata_day where hotelid=@hotelid and crrtday=@date
insert grp_group_basedata_day(hotelid,datatype,crrtday,dayvalue)
	select @hotelid, datatype, @date, 0 from grp_base_datatype 
--
-- update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype=''

---------------------------------------------------------------------
-- 1.���� - �Ƽ�ȡ�� yjourrep or yaudit_impdata 
---------------------------------------------------------------------
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class='000100'), 0) where hotelid=@hotelid and crrtday=@date and datatype='RevTtl'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class='000005'), 0) where hotelid=@hotelid and crrtday=@date and datatype='RevRm'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010140', '010168')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RevRm.f'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class='010150'), 0) where hotelid=@hotelid and crrtday=@date and datatype='RevRm.g'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class='010155'), 0) where hotelid=@hotelid and crrtday=@date and datatype='RevRm.c'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class='010160'), 0) where hotelid=@hotelid and crrtday=@date and datatype='RevRm.l'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class='000020'), 0) where hotelid=@hotelid and crrtday=@date and datatype='RevFB'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class<'000100' and class<>'000071'), 0) where hotelid=@hotelid and crrtday=@date and datatype='RevOth'

---------------------------------------------------------------------
-- 2.���� - �Ƽ�ȡ�� yjourrep or yaudit_impdata 
---------------------------------------------------------------------
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010012', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsTtl'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010014', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsOO'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsOS'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010030', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsSold'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010040', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsSold.f'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010050', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsSold.g'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010060', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsSold.c'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010070', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsSold.l'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010015', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsHtl'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010016', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsEnt'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010020', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsAvl'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010075', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsExtra'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010505', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsArr'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010506', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsDep'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010510', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsDaybook'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010502', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsNoshow'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010503', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsCXL'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('010504', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsExtend'
update grp_group_basedata_day set dayvalue=isnull((select sum(day) from yjourrep where date=@date and class in ('', '')), 0) where hotelid=@hotelid and crrtday=@date and datatype='RmsRetu'


---------------------------------------------------------------------
-- 3.���� - �Ƽ�ȡ�� yjourrep or yaudit_impdata or yrmsalerep_new 
---------------------------------------------------------------------


---------------------------------------------------------------------
-- 4.�г������ - �Ƽ�ȡ�� ymktsummaryrep (class='M' �г���=code)
---------------------------------------------------------------------


---------------------------------------------------------------------
-- 5.��Դ����� - �Ƽ�ȡ�� ymktsummaryrep (class='S' ��Դ��=code)
---------------------------------------------------------------------


---------------------------------------------------------------------
-- 6.������� - �Ƽ�ȡ�� yrmsalerep_new (gkey='t' ����=code) 
---------------------------------------------------------------------


;


//exec p_foxhis_create_grp_datatype;
//exec p_foxhis_create_grp_data_x '2005.11.11';
//
////select * from grp_base_datatype;
////select * from grp_base_hotel;
//select * from grp_group_basedata_day;
//