
//INSERT INTO sys_function VALUES ('0311','03','康乐系统','康乐系统_e','appid!S');
//
//INSERT INTO basecode VALUES ('function_class','40','康乐系统','康乐系统_eng','F','F',0,' ','F');

delete sys_function where code like '40%';
INSERT INTO sys_function VALUES ( '4001','40', '康乐开单','康乐开单_e','sp!newmenu');
INSERT INTO sys_function VALUES ( '4002','40', '康乐预订','康乐预订_e','sp!newreserve');
INSERT INTO sys_function VALUES ( '4003','40', '康乐周期预订','康乐周期预订_e','sp!mulreserve');
INSERT INTO sys_function VALUES ( '4004','40', '康乐场地维修','场地维修_e','sp!modiplace');
INSERT INTO sys_function VALUES ( '4005','40', '康乐场地记录','场地记录_e','sp!vipuseplace');
INSERT INTO sys_function VALUES ( '4006','40', '康乐结帐','康乐结帐_e','sp!checkout');
INSERT INTO sys_function VALUES ( '4007','40', '康乐预订转登记','康乐预订转登记_e','sp!res!reg');
INSERT INTO sys_function VALUES ( '4008','40', '康乐结束场地','康乐结束场地_e','sp!place!over');
INSERT INTO sys_function VALUES ( '4009','40', '康乐维修结束','康乐维修结束_e','sp!place!modiover');

INSERT INTO sys_function VALUES ( '4010','40', '康乐删除用户场地','康乐删除用户场地_e','sp!place!use!del');
INSERT INTO sys_function VALUES ( '4011','40', '康乐联单','康乐联单_e','sp!menu!union');
INSERT INTO sys_function VALUES ( '4012','40', '康乐场地结算','康乐场地结算_e','sp!place!cho');
INSERT INTO sys_function VALUES ( '4013','40', '康乐修改用户场地','康乐修改用户场地_e','sp!place!use!modi');
INSERT INTO sys_function VALUES ( '4014','40', '康乐增加用户场地','康乐增加用户场地_e','sp!place!use!add');
INSERT INTO sys_function VALUES ( '4015','40', '康乐费用输入','康乐费用输入_e','sp!inputdish');

INSERT INTO sys_function VALUES ( '4016','40', '康乐重结','康乐重结_e','sp!menu!recheck');
INSERT INTO sys_function VALUES ( '4017','40', '康乐销单','康乐销单_e','sp!menu!cancel');
INSERT INTO sys_function VALUES ( '4018','40', '康乐撤销联单','康乐撤销联单_e','sp!union!cancel');
INSERT INTO sys_function VALUES ( '4019','40', '康乐预订确认','康乐预订确认_e','sp!reserve!ok');
INSERT INTO sys_function VALUES ( '4020','40', '康乐取消预订','康乐取消预订_e','sp!res!cancel');

INSERT INTO sys_function VALUES ( '4021','40', '康乐预付定金','康乐预付定金_e','sp!res!account');
INSERT INTO sys_function VALUES ( '4022','40', '康乐退回定金','康乐退回定金_e','sp!res!reaccount');

INSERT INTO sys_function VALUES ( '4023','40', '康乐预订加场地','康乐预订加场地_e','sp!res!addplace');

INSERT INTO sys_function VALUES ( '4024','40', '康乐预订减场地','康乐预订减场地_e','sp!res!unplace');


INSERT INTO sys_function VALUES ( '4025','40', '康乐代码编辑','康乐代码编辑_e','sp!code!edit');
INSERT INTO sys_function VALUES ( '4026','40', '康乐新建计划','康乐新建计划_e','sp!plan!new');

INSERT INTO sys_function VALUES ( '4027','40', '康乐计划修改','康乐计划修改_e','sp!plan!modi');

INSERT INTO sys_function VALUES ( '4028','40', '康乐新建投诉','康乐新建投诉_e','sp!mind!new');

INSERT INTO sys_function VALUES ( '4029','40', '康乐投诉修改','康乐投诉修改_e','sp!mind!modi');
INSERT INTO sys_function VALUES ( '4030','40', '康乐寄存柜的租用结算','康乐寄存柜的租用结算_e','sp!rent!new');
INSERT INTO sys_function VALUES ( '4031','40', '康乐预订修改','康乐预订修改_e','sp!modireserve');

INSERT INTO sys_function VALUES ( '4032','40', '康乐冲销点菜','康乐冲销点菜_e','sp!cancel!dish');
