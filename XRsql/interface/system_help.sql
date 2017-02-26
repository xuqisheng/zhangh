drop table system_help;
CREATE TABLE system_help
 (
	appid 		char(1)		default '' not null,
	descript		char(50)		default '' not null,
	descript1	char(100)	default '' null,
	path 			char(100)	default '' not null,
	flag 			char(1)		default '' not null,
	sequence 	integer		default 0  not null			
);

exec sp_primarykey system_help,appid,flag,sequence
create unique index  system_help on system_help(appid,flag,sequence)
;

INSERT INTO system_help VALUES (
	'3',
	'��������',
	'��������_e',
	'c:\1.htm',
	'I',
	0);
INSERT INTO system_help VALUES (
	'3',
	'������������',
	'������̨����_e',
	'c:\2.htm',
	'S',
	1);
INSERT INTO system_help VALUES (
	'3',
	'����ϵͳ����',
	'POS SYSTEM HELP',
	'c:\pos\����ϵͳ����.htm',
	'S',
	0);
INSERT INTO system_help VALUES (
	'3',
	'����Ԥ���Ӵ�',
	'����Ԥ���Ӵ�_e',
	'',
	'S',
	2);
INSERT INTO system_help VALUES (
	'3',
	'������̨������',
	'������̨������_e',
	'',
	'S',
	3);
INSERT INTO system_help VALUES (
	'3',
	'������ʽ����',
	'������ʽ����_e',
	'',
	'S',
	4);
INSERT INTO system_help VALUES (
	'3',
	'������Ϣ��ѯ����',
	'������Ϣ��ѯ����_e',
	'',
	'S',
	5);
INSERT INTO system_help VALUES (
	'3',
	'ģʽ����',
	'ģʽ����_e',
	'',
	'I',
	1);
INSERT INTO system_help VALUES (
	'3',
	'��λͼ',
	'��λͼ_e',
	'',
	'I',
	2);
INSERT INTO system_help VALUES (
	'3',
	'ת�Ǽ�',
	'ת�Ǽ�_e',
	'',
	'I',
	3);
INSERT INTO system_help VALUES (
	'3',
	'���Ͳ͵�',
	'���Ͳ͵�_e',
	'',
	'I',
	4);
INSERT INTO system_help VALUES (
	'3',
	'�ؽ�',
	'�ؽ�_e',
	'',
	'I',
	5);
INSERT INTO system_help VALUES (
	'3',
	'Ԥ����',
	'Ԥ����_e',
	'',
	'I',
	6);
INSERT INTO system_help VALUES (
	'3',
	'���а�',
	'���а�_e',
	'',
	'I',
	7);
INSERT INTO system_help VALUES (
	'3',
	'�ײˣ���׼�ˣ�',
	'�ײˣ���׼�� ��_e',
	'',
	'I',
	8);
INSERT INTO system_help VALUES (
	'3',
	'���Ϲ���',
	'���Ϲ���_e',
	'',
	'I',
	9);
INSERT INTO system_help VALUES (
	'3',
	'̨λ�������Ŷ��壩',
	'̨λ�������Ŷ��壩_e',
	'',
	'I',
	10);
INSERT INTO system_help VALUES (
	'3',
	'��̨����ά��',
	'��̨����ά��_e',
	'',
	'I',
	11);
INSERT INTO system_help VALUES (
	'3',
	'ʱ�ζ���',
	'ʱ�ζ���_e',
	'',
	'I',
	12);
INSERT INTO system_help VALUES (
	'3',
	'������',
	'������_e',
	'',
	'I',
	13);
INSERT INTO system_help VALUES (
	'3',
	'����վ',
	'����վ_e',
	'',
	'I',
	14);
INSERT INTO system_help VALUES (
	'3',
	'Ӫҵ��',
	'Ӫҵ��_e',
	'',
	'I',
	15);
INSERT INTO system_help VALUES (
	'3',
	'�½�',
	'�½�_e',
	'',
	'I',
	16);
INSERT INTO system_help VALUES (
	'3',
	'ϲ�ò�ʽ',
	'ϲ�ò�ʽ_e',
	'',
	'I',
	17);
