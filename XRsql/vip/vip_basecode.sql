
// --------------------------------------------------------------------------
//  basecode : vipcard_class
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='vipcard_class')
	delete basecode_cat where cat='vipcard_class';
insert basecode_cat select 'vipcard_class', '�����ϵͳ���', 'VIP CARD CLASS', 3, '', 'F';
delete basecode where cat='vipcard_class';
insert basecode(cat,code,descript,descript1,sequence) values('vipcard_class', '1', '���ֿ�', 'Point Card', 10);
insert basecode(cat,code,descript,descript1,sequence) values('vipcard_class', '2', '���˴�ֵ��', 'Personal AR Card', 20);
insert basecode(cat,code,descript,descript1,sequence) values('vipcard_class', '3', '��λ��ֵ��', 'Company AR Card', 30);
insert basecode(cat,code,descript,descript1,sequence) values('vipcard_class', '4', '��������ֵ��', 'No-Name AR Card', 40);
//
if not exists(select 1 from syscode_maint where code='C2')
	INSERT INTO syscode_maint VALUES ('C2','�����ϵͳ���','VIP Card System Class','hry','','','','cat=vipcard_class');


// --------------------------------------------------------------------------
// basecode - vipcard_sta 
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='vipcard_sta')
	delete basecode_cat where cat='vipcard_sta';
insert basecode_cat select 'vipcard_sta', '�����״̬', 'VIP CARD Sta', 1, '', 'F';
delete basecode where cat='vipcard_sta';
INSERT INTO basecode VALUES (	'vipcard_sta',	'R',	'��ʼ',	'Init',	'F',	'F',	50,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_sta',	'I',	'����',	'Used',	'F',	'F',	100,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_sta',	'S',	'����',	'Sleep',	'F',	'F',	150,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_sta',	'L',	'��ʧ',	'Lose',	'F',	'F',	200,	'2',	'F');
INSERT INTO basecode VALUES (	'vipcard_sta',	'O',	'ͣ��',	'Stop',	'F',	'F',	300,	'1',	'F');
INSERT INTO basecode VALUES (	'vipcard_sta',	'X',	'ע��',	'Cancel',	'F',	'F',	400,	'5',	'F');
INSERT INTO basecode VALUES (	'vipcard_sta',	'D',	'ɾ��',	'Delete',	'F',	'F',	500,	'',	'F');
INSERT INTO basecode VALUES (	'vipcard_sta',	'T',	'��ʧ�ط�',	'ReIssue',	'F',	'F',	600,	'',	'F');


// --------------------------------------------------------------------------
// basecode - vipcard_src 
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='vipcard_src')
	delete basecode_cat where cat='vipcard_src';
insert basecode_cat select 'vipcard_src', '�������Դ', 'VIP CARD SRC', 3, '', 'F';
delete basecode where cat='vipcard_src';
INSERT INTO basecode VALUES (	'vipcard_src',	'1',	'ס���',	'In-house guest',	'F',	'F',	50,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_src',	'2',	'����',	'ENT',	'F',	'F',	100,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_src',	'3',	'ת��',	'Transfer',	'F',	'F',	150,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_src',	'4',	'����',	'Internet',	'F',	'F',	200,	'2',	'F');
INSERT INTO basecode VALUES (	'vipcard_src',	'5',	'����',	'Sales',	'F',	'F',	300,	'1',	'F');
//
if not exists(select 1 from syscode_maint where code='C3')
	INSERT INTO syscode_maint VALUES ('C3','�������Դ','VIP Card Source','hry','','','','cat=vipcard_src');

// --------------------------------------------------------------------------
// basecode - vipcard_flag 
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='vipcard_flag')
	delete basecode_cat where cat='vipcard_flag';
insert basecode_cat select 'vipcard_flag', '�������־', 'VIP CARD FLAG', 3, '', 'F';
delete basecode where cat='vipcard_flag';
INSERT INTO basecode VALUES (	'vipcard_flag',	'ERAD',	'��ַ����',	'Address error',	'F',	'F',	50,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_flag',	'SP',	'�ر��ע',	'Special',	'F',	'F',	100,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_flag',	'HTML',	'�����ʼ�HTML',	'EMAIL FORMAT HTML',	'F',	'F',	100,	'0',	'F');
//
if not exists(select 1 from syscode_maint where code='C4')
	INSERT INTO syscode_maint VALUES ('C4','�������־','VIP Card flag','hry','','','','cat=vipcard_flag');

// --------------------------------------------------------------------------
// basecode - guestcard_cat  : ϵͳ���� GRP
// --------------------------------------------------------------------------
if not exists(select 1 from basecode where cat='guestcard_cat' and code='OWN')
	INSERT INTO basecode VALUES (	'guestcard_cat',	'OWN',	'�Լ����п�',	'Own Card',	'T',	'F',	0,	'90',	'T');

// guest_card_type
delete guest_card_type where cat='OWN' and code like 'JL%';
INSERT INTO guest_card_type VALUES ('JL1','��������Ա','Jinling Elite Membership','OWN','FOX','','F','F',NULL,0);
INSERT INTO guest_card_type VALUES ('JL2','����𿨹����Ա','Jinling Gold Membership','OWN','FOX','','F','F',NULL,0);
INSERT INTO guest_card_type VALUES ('JL3','���견�𿨹����Ա','Jinling Platinum Membership','OWN','FOX','','F','F',NULL,0);


// --------------------------------------------------------------------------
// basecode - vipcard_pwdask 
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='vipcard_pwdask')
	delete basecode_cat where cat='vipcard_pwdask';
insert basecode_cat select 'vipcard_pwdask', '������ʾ����', 'Password question', 1, '', 'F';
delete basecode where cat='vipcard_pwdask';
INSERT INTO basecode VALUES (	'vipcard_pwdask',	'1',	'�ҵĳ����ʲô?',	'What is my pet name?',	'F',	'F',	50,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_pwdask',	'2',	'�ҵ�һ��С����',	'My small secret is ...',	'F',	'F',	100,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_pwdask',	'3',	'���������ĵط�',	'Where is my the expressest place?',	'F',	'F',	100,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_pwdask',	'4',	'�ҵ��������',	'Where is my the most love?',	'F',	'F',	100,	'0',	'F');
