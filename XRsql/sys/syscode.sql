// --------------------------------------------------------------------------
//		basecode:		shift
//		table:			
//							
//
// --------------------------------------------------------------------------


// --------------------------------------------------------------------------
//  basecode : shift  -- ���
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='shift')
	delete basecode_cat(cat,descript,descript1,len) where cat='shift';
insert basecode_cat select 'shift', '���', 'shift', 1;
delete basecode where cat='shift';
insert basecode(cat,code,descript,descript1) select 'shift', '0', '����', 'shift-0';
insert basecode(cat,code,descript,descript1) select 'shift', '1', '���', 'shift-1';
insert basecode(cat,code,descript,descript1) select 'shift', '2', '�а�', 'shift-2';
insert basecode(cat,code,descript,descript1) select 'shift', '3', '���', 'shift-3';
insert basecode(cat,code,descript,descript1) select 'shift', '4', 'ҹ��', 'shift-4';
insert basecode(cat,code,descript,descript1) select 'shift', '5', '��ҹ', 'shift-5';



// --------------------------------------------------------------------------
//  basecode : moduno  -- ����ģ��
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='moduno')
	delete basecode_cat(cat,descript,descript1,len) where cat='moduno';
insert basecode_cat select 'moduno', '����ģ��', 'moduno', 2;
delete basecode where cat='moduno';
insert basecode(cat,code,descript,descript1,sys) select 'moduno', '02', 'ǰ̨����', 'ǰ̨����', 'T';
insert basecode(cat,code,descript,descript1,sys) select 'moduno', '03', '�ͷ�����', '�ͷ�����', 'T';
insert basecode(cat,code,descript,descript1,sys) select 'moduno', '04', '�ۺ�����', '�ۺ�����', 'T';
insert basecode(cat,code,descript,descript1,sys) select 'moduno', '05', '�绰�Ʒ�', '�绰�Ʒ�', 'T';
insert basecode(cat,code,descript,descript1,sys) select 'moduno', '06', '��������', '��������', 'T';
insert basecode(cat,code,descript,descript1,sys) select 'moduno', '09', '�̳�', '�̳�', 'T';
insert basecode(cat,code,descript,descript1,sys) select 'moduno', '12', '�����', '�����', 'T';
insert basecode(cat,code,descript,descript1,sys) select 'moduno', '19', 'VOD', 'VOD',  'T';
insert basecode(cat,code,descript,descript1,sys) select 'moduno', '21', 'INTERNET', 'INTERNET', 'T';


// --------------------------------------------------------------------------
//  basecode : info_cat  -- ������Ϣ���
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='info_cat')
	delete basecode_cat where cat='info_cat';
insert basecode_cat(cat,descript,descript1,len) select 'info_cat', '������Ϣ���', 'info_cat', 10;
delete basecode where cat='info_cat';
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'SERVICE', '�Ƶ����', 'Hotel Service', 'T',100;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'VIEW', '����', 'Viewport', 'T',200;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'TRANS', '��ͨ', 'Transport', 'T',300;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'LEISURE', '����', 'Leisure', 'T',400;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'ORGA', '����', 'Organization', 'T',500;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'SYSTEM', '�Ƶ��ƶ�', 'Hotel Documents', 'T',600;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'HIS', '������ʷ', 'Culture & History', 'T',700;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'TRAIN', 'С����', 'Training', 'T',800;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'PUB', '������Ϣ', 'Public Info.', 'T',900;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'OTHER', '����', 'Other', 'T',1000;






