//grp_base_hotel ��ŵ���Ƶ������Ϣ
if exists(select 1 from sysobjects where name='grp_base_hotel' and type='U')
	drop table grp_base_hotel;
Create table grp_base_hotel(
	hotelid char(20),//�Ƶ�ID
	hotelname char(60),//�Ƶ�����
	hotelename char(60),//�Ƶ�Ӣ����
	roomnumber money,//�ͷ���
	flag	char(10),
	sequence int
)
;
create unique index index1 on grp_base_hotel(hotelid);
//grp_base_datatype �������ͱ�
if exists(select 1 from sysobjects where name='grp_base_datatype' and type='U')
	drop table grp_base_datatype;
Create table grp_base_datatype(
	datatype char(30),//��������
	description char(60),//������������
	edescription char(60),//��������Ӣ������
	remark varchar(100),//��ע
	sequence int

);
create unique index index1 on grp_base_datatype(datatype);

//grp_base_periodtype �������ͱ�	
if exists(select 1 from sysobjects where name='grp_base_periodtype' and type='U')
	drop table grp_base_periodtype;
Create table grp_base_periodtype(
	periodtype char(10),//��������
	description char(60),//������������
	edescription char(60),//��������Ӣ������
	remark varchar(100),//��ע
	sequence int

);
create unique index index1 on grp_base_periodtype(periodtype);

//grp_group_basedata_day ÿ�����ݼ�
if exists(select 1 from sysobjects where name='grp_group_basedata_day' and type='U')
	drop table grp_group_basedata_day;
Create table grp_group_basedata_day(
	hotelid char(20),//�Ƶ�ID
	datatype char(30),//��������
	crrtday datetime,//��ǰ����
	dayvalue  money//ֵ
)
;
create unique clustered index index1 on grp_group_basedata_day(hotelid,datatype,crrtday);

//grp_group_basedata_period �������ݼ�
if exists(select 1 from sysobjects where name='grp_group_basedata_period' and type='U')
	drop table grp_group_basedata_period;
Create table grp_group_basedata_period(
	hotelid char(20),//�Ƶ�id
	datatype char(30),//��������
	periodtype char(10),//��������
	crrtperiod char(20),//��ǰ����
	dayvalue  money//ֵ
)
;
create unique clustered index index1 on grp_group_basedata_period(hotelid,datatype,periodtype,crrtperiod);

//grp_group_basedata_one �̶����ݼ�
if exists(select 1 from sysobjects where name='grp_group_basedata_one' and type='U')
	drop table grp_group_basedata_one;
Create table grp_group_basedata_one(
	hotelid char(20),//�Ƶ�ID
	datatype char(30),//��������
	onevalue varchar(60)//ֵ
)
;
create unique clustered index index1 on grp_group_basedata_one(hotelid,datatype);