// ��˱��ṹ

// �Ƶ����ƶ���
// select value from sysoption where catalog = 'hotel' and item = 'name';

// ��վ����
insert into basecode_cat (cat,descript,descript1,len,flag,center) select 'poswdt_base','��վ����','��վ����',1,'','F';
insert into basecode (cat,code,descript,descript1) select 'poswdt_base','1','COM1','COM1';

// ��˻�����
create table poswdt_station (
	base		char(1)  default space(1) not null,             --��վ���
	code		char(3)  default space(3) not null,             --���
	empno		char(10) default space(10) not null,            --��ǰ����Ա, û��Ϊ��
	date0		datetime														--��½ʱ��
);
	

//	��Ʒ����
insert into basecode_cat (cat,descript,descript1,len,flag,center) select 'poswdt_sort','����','����',2,'','F';

// ��Ʒ
create table poswdt_plu (
	code		char(5)  default space(5) not null,             --���
	sort 		char(2)  default space(2) not null,					--����(2λ)��
	name1		char(18) default space(18) not null,			 	--��������(18λ)��
 	price1	money 	default 0 		  not null,					--	25����1(8λ)��
 	price2	money 	default 0 		  not null,					--	25����2(8λ)��
 	price3	money 	default 0 		  not null,					--	25����3(8λ)��
 	price4	money 	default 0 		  not null,					--	25����4(8λ)��
	unit1		char(4)	default space(4) not null,					--	57��λ1(4λ)��
	unit2		char(4)	default space(4) not null,					--	57��λ2(4λ)��
	unit3		char(4)	default space(4) not null,					--	57��λ3(4λ)��
	unit4		char(4)	default space(4) not null,					--	57��λ4(4λ)��
	cook		char(30) default space(30) not null,				--	73����Ҫ��(30λ)��
 	helpcode char(4)	default space(4) not null,					--	103ƴ������(4λ) 
	id			int		default 0 		  not null					-- ��ӦPos_plu.id
);

// ��Ʒ�ײ�
insert into basecode_cat (cat,descript,descript1,len,flag,center) select 'poswdt_std','�ײ�','�ײ�',2,'','F';


//	��Ʒ�ײ���ϸ����
create table poswdt_stdmx (
	std		char(2)  default space(2) not null,             --���
	code		char(5)  default space(5) not null,             --��Ʒ���
	number	money		default 0		  not null,					-- ����
	price		money		default 0		  not null,					-- ����
	unit		char(4)  default space(5) not null	            --��λ
)
;

//	�Ƽ���Ʒ��, ��ʱ������  


// �Ƽ���Ʒ���ݱ�, ��ʱ������

// �ͻ�Ҫ���, ��pos_condst ����

// �˲����� select * from basecode where cat = 'pos_dish_cancel'

// ����Ϣ��
insert into basecode_cat (cat,descript,descript1,len,flag,center) select 'poswdt_mail','����Ϣ','����Ϣ',2,'','F';
insert into basecode (cat,code,descript,descript1) select 'poswdt_mail','01','���ϲ�','���ϲ�';

// �������Ʊ�, pos_tblsta ����, pos_tblsta.tableno  Ϊ4λ,Ϊ����,������ͬ


//	������־
create table poswdt_log (
	type		char(10) default space(10) not null,            --�������
	base		char(1)  default space(1) not null,             --��վ
	posno		char(5)  default space(5) not null,             --��˻���
	empno		char(10) default space(10) not null,            --����Ա
	logdate	datetime	,													--ʱ��
	ref		varchar(255)  null						            --����, ������ݴ���ڱ����ļ���
)
;
	
// �������ش��������
insert into basecode_cat (cat,descript,descript1,len,flag,center) select 'poswdt_down','�������ش��������','�������ش��������',2,'','F';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','01','�Ƶ�����','�Ƶ�����';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','02','��վ����','��վ����';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','03','��˻�����','��˻�����';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','04','��Ʒ��','��Ʒ��';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','05','��Ʒ����','��Ʒ����';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','06','��Ʒ�ײͱ�','��Ʒ�ײͱ�';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','07','��Ʒ�ײ����ݱ�','��Ʒ�ײ����ݱ�';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','08','�ͻ�Ҫ���','�ͻ�Ҫ���';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','09','�˲����ɱ�','�˲����ɱ�';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','10','����Ϣ��','����Ϣ��';
insert into basecode (cat,code,descript,descript1) select 'poswdt_down','11','�������Ʊ�','�������Ʊ�';

