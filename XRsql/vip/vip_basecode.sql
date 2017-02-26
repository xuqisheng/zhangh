
// --------------------------------------------------------------------------
//  basecode : vipcard_class
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='vipcard_class')
	delete basecode_cat where cat='vipcard_class';
insert basecode_cat select 'vipcard_class', '贵宾卡系统类别', 'VIP CARD CLASS', 3, '', 'F';
delete basecode where cat='vipcard_class';
insert basecode(cat,code,descript,descript1,sequence) values('vipcard_class', '1', '积分卡', 'Point Card', 10);
insert basecode(cat,code,descript,descript1,sequence) values('vipcard_class', '2', '个人储值卡', 'Personal AR Card', 20);
insert basecode(cat,code,descript,descript1,sequence) values('vipcard_class', '3', '单位储值卡', 'Company AR Card', 30);
insert basecode(cat,code,descript,descript1,sequence) values('vipcard_class', '4', '不记名储值卡', 'No-Name AR Card', 40);
//
if not exists(select 1 from syscode_maint where code='C2')
	INSERT INTO syscode_maint VALUES ('C2','贵宾卡系统类别','VIP Card System Class','hry','','','','cat=vipcard_class');


// --------------------------------------------------------------------------
// basecode - vipcard_sta 
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='vipcard_sta')
	delete basecode_cat where cat='vipcard_sta';
insert basecode_cat select 'vipcard_sta', '贵宾卡状态', 'VIP CARD Sta', 1, '', 'F';
delete basecode where cat='vipcard_sta';
INSERT INTO basecode VALUES (	'vipcard_sta',	'R',	'初始',	'Init',	'F',	'F',	50,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_sta',	'I',	'在用',	'Used',	'F',	'F',	100,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_sta',	'S',	'休眠',	'Sleep',	'F',	'F',	150,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_sta',	'L',	'挂失',	'Lose',	'F',	'F',	200,	'2',	'F');
INSERT INTO basecode VALUES (	'vipcard_sta',	'O',	'停用',	'Stop',	'F',	'F',	300,	'1',	'F');
INSERT INTO basecode VALUES (	'vipcard_sta',	'X',	'注销',	'Cancel',	'F',	'F',	400,	'5',	'F');
INSERT INTO basecode VALUES (	'vipcard_sta',	'D',	'删除',	'Delete',	'F',	'F',	500,	'',	'F');
INSERT INTO basecode VALUES (	'vipcard_sta',	'T',	'挂失重发',	'ReIssue',	'F',	'F',	600,	'',	'F');


// --------------------------------------------------------------------------
// basecode - vipcard_src 
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='vipcard_src')
	delete basecode_cat where cat='vipcard_src';
insert basecode_cat select 'vipcard_src', '贵宾卡来源', 'VIP CARD SRC', 3, '', 'F';
delete basecode where cat='vipcard_src';
INSERT INTO basecode VALUES (	'vipcard_src',	'1',	'住店客',	'In-house guest',	'F',	'F',	50,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_src',	'2',	'公关',	'ENT',	'F',	'F',	100,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_src',	'3',	'转卡',	'Transfer',	'F',	'F',	150,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_src',	'4',	'网络',	'Internet',	'F',	'F',	200,	'2',	'F');
INSERT INTO basecode VALUES (	'vipcard_src',	'5',	'购买',	'Sales',	'F',	'F',	300,	'1',	'F');
//
if not exists(select 1 from syscode_maint where code='C3')
	INSERT INTO syscode_maint VALUES ('C3','贵宾卡来源','VIP Card Source','hry','','','','cat=vipcard_src');

// --------------------------------------------------------------------------
// basecode - vipcard_flag 
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='vipcard_flag')
	delete basecode_cat where cat='vipcard_flag';
insert basecode_cat select 'vipcard_flag', '贵宾卡标志', 'VIP CARD FLAG', 3, '', 'F';
delete basecode where cat='vipcard_flag';
INSERT INTO basecode VALUES (	'vipcard_flag',	'ERAD',	'地址错误',	'Address error',	'F',	'F',	50,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_flag',	'SP',	'特别关注',	'Special',	'F',	'F',	100,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_flag',	'HTML',	'电子邮件HTML',	'EMAIL FORMAT HTML',	'F',	'F',	100,	'0',	'F');
//
if not exists(select 1 from syscode_maint where code='C4')
	INSERT INTO syscode_maint VALUES ('C4','贵宾卡标志','VIP Card flag','hry','','','','cat=vipcard_flag');

// --------------------------------------------------------------------------
// basecode - guestcard_cat  : 系统代码 GRP
// --------------------------------------------------------------------------
if not exists(select 1 from basecode where cat='guestcard_cat' and code='OWN')
	INSERT INTO basecode VALUES (	'guestcard_cat',	'OWN',	'自己发行卡',	'Own Card',	'T',	'F',	0,	'90',	'T');

// guest_card_type
delete guest_card_type where cat='OWN' and code like 'JL%';
INSERT INTO guest_card_type VALUES ('JL1','金陵贵宾会员','Jinling Elite Membership','OWN','FOX','','F','F',NULL,0);
INSERT INTO guest_card_type VALUES ('JL2','金陵金卡贵宾会员','Jinling Gold Membership','OWN','FOX','','F','F',NULL,0);
INSERT INTO guest_card_type VALUES ('JL3','金陵铂金卡贵宾会员','Jinling Platinum Membership','OWN','FOX','','F','F',NULL,0);


// --------------------------------------------------------------------------
// basecode - vipcard_pwdask 
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='vipcard_pwdask')
	delete basecode_cat where cat='vipcard_pwdask';
insert basecode_cat select 'vipcard_pwdask', '密码提示问题', 'Password question', 1, '', 'F';
delete basecode where cat='vipcard_pwdask';
INSERT INTO basecode VALUES (	'vipcard_pwdask',	'1',	'我的宠物叫什么?',	'What is my pet name?',	'F',	'F',	50,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_pwdask',	'2',	'我的一个小秘密',	'My small secret is ...',	'F',	'F',	100,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_pwdask',	'3',	'我最难忘的地方',	'Where is my the expressest place?',	'F',	'F',	100,	'0',	'F');
INSERT INTO basecode VALUES (	'vipcard_pwdask',	'4',	'我的最爱在那里',	'Where is my the most love?',	'F',	'F',	100,	'0',	'F');
