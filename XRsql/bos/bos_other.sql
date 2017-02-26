
// 增加 bos 相关帐务冲销的权限
insert sys_function(code,class,descript,descript1,fun_des)
	values('2505','25','客房中心帐务冲销','HouseKeeping account delete','hs!coact');
insert sys_function(code,class,descript,descript1,fun_des)
	values('2805','28','商场帐务冲销','Shop account delete','shop!coact');
insert sys_function(code,class,descript,descript1,fun_des)
	values('2705','27','商务中心帐务冲销','Business account delete','bus!coact');
