

// 20-> 15


update sys_function set code='0620', class='06' where fun_des='grpmst!m!i->r';

insert basecode(cat,code,descript,descript1) values('function_class','15','Block ����','Block ����');
INSERT INTO sys_function VALUES ('1501','15','Block �½�','Block �½�','blk!a');
INSERT INTO sys_function VALUES ('1502','15','Block �б�','Block �б�','blk!l');
INSERT INTO sys_function VALUES ('1503','15','Block �༭','Block �༭','blk!m');
INSERT INTO sys_function VALUES ('1504','15','Block ��ѯ','Block ��ѯ','blk!o');
INSERT INTO sys_function VALUES ('1505','15','Block ����','Block ����','blk!rm');
INSERT INTO sys_function VALUES ('1506','15','Block �ͷ�Ӧ��','Block �ͷ�Ӧ��','blk!tf');
INSERT INTO sys_function VALUES ('1507','15','Block ���Ӧ��','Block ���Ӧ��','blk!tp');


select * from sys_function where code like '15%';




