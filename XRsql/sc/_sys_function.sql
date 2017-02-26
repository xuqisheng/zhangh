

// 20-> 15


update sys_function set code='0620', class='06' where fun_des='grpmst!m!i->r';

insert basecode(cat,code,descript,descript1) values('function_class','15','Block 处理','Block 处理');
INSERT INTO sys_function VALUES ('1501','15','Block 新建','Block 新建','blk!a');
INSERT INTO sys_function VALUES ('1502','15','Block 列表','Block 列表','blk!l');
INSERT INTO sys_function VALUES ('1503','15','Block 编辑','Block 编辑','blk!m');
INSERT INTO sys_function VALUES ('1504','15','Block 查询','Block 查询','blk!o');
INSERT INTO sys_function VALUES ('1505','15','Block 订房','Block 订房','blk!rm');
INSERT INTO sys_function VALUES ('1506','15','Block 客房应用','Block 客房应用','blk!tf');
INSERT INTO sys_function VALUES ('1507','15','Block 宴会应用','Block 宴会应用','blk!tp');


select * from sys_function where code like '15%';




