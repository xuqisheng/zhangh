show databases;		�鿴��ǰ�м������ݿ�
create database dbname;	������Ϊdbname;�����ݿ�
drop database dbname;;	ɾ����Ϊdbname;�����ݿ�
use dbname;		ѡ����Ϊdbname;�����ݿ�
show tables;		�鿴ĳ���ݿ��е����б�
create table tablename(); ��������Ϊtablename��һ����
desc tablename;		�鿴��Ķ���
show create table tablename;	��ȫ��Ĳ鿴��Ķ�����Ϣ
drop table tablename;	ɾ������Ϊtablename��һ����
alter table tablename modify tablename.column;
alter table tablename add tablename.column;
alter table tablename drop tablename.column;
alter table tablename charge tablename.column;
? �������		��һЩ���ݽ��в鿴�����磺? data types

show variables like 'table_type';	�鿴��ǰ��Ĭ�ϴ洢����;
show table status like 'account' \G	�鿴account����������
show engines;		�鿴��ǰ���ݿ�֧�ֵĴ洢����;

SELECT NOW(),USER(),VERSION(),DATABASE()
DESC table_name; 	��ʾ��ṹ

------Select�﷨-------
SELECT select_list
  FORM table_list
    WHERE row_constraint
      GROUP BY grouping_columns
	ORDER BY sorting_columns
	  HAVING grouping_constraint
	    LIMIT count;
--------MySQL�Ż�--------
1��EXPLAIN
2��PROCEDURE ANALYSE    # �˷������԰������������Ƿ�ñ��ض���Ϊ��С���������͡�
   # �﷨ SELECT ... FROM ... WHERE ... PROCEDURE ANALYSE([max_elements,[max_memory]])




MySQL��EXISTS��IN����
EXISTS����еĴ����ԣ�IN���ֵ�Ĵ����ԣ�EXISTSЧ�ʱ�IN��

����5����NOT EXISTS���NOT IN
��NOT IN������Ӳ�ѯ�����Ҳ�ѯ�Ľ�����϶�ʱ��������NOT IN�������NOT IN��������������б����Ӳ�ѯ������Ľ��������ʱ��Ҳ�ǿ����õġ�

ԭ�����Ӳ�ѯ�У�NOT IN�Ӿ佫ִ��һ���ڲ�������ͺϲ���������������£�NOT IN��������ʵģ���Ϊ�����Ӳ�ѯ�еı�ִ����һ��ȫ����������Ը�дΪ�������ʹ��NOT EXISTS��

����6������IN��EXISTS��IN�ǰ��ڱ�������HASH���ӣ���EXISTS�Ƕ������LOOPѭ����ÿ��LOOPѭ���ٶ��ڱ���в�ѯ��
   ����ڱ������С�൱����ʹ��IN��EXISTSЧ�ʲ���١�
   ����Ӳ�ѯ�ı����ʹ��EXISTS������Ӳ�ѯ��С����ʹ��INЧ�ʸߡ�

CALL up_ihotel_rep_channel(2,35,@a,@b)
��out������ִ�з���


������
1,������:inner join; ������ֻ��ʾ���������ݱ������ҵ�ƥ��������С�
2,������(�������������):���������������Ľ���⣬�����԰�����һ�����ݱ�����һ�����ݱ���û��ƥ���������Ҳ��ʾ����
LEFT JOIN:�������ݾݱ��������ݱ���û��ƥ���������Ҳ��ʾ������
RIGHT JOIN:�������ݾݱ��������ݱ���û��ƥ���������Ҳ��ʾ������

INNER JOIN(��ֵ����):ֻ�����������������ֶ���ȵ��У�
LEFT JOIN(������):���ذ�������е����м�¼���ұ��������ֶ���ȵļ�¼,����¼ȫ����ʾ,�ұ�ֻ��ʾ��������
  		  �ļ�¼������ط���ΪNULL��
RIGHT JOIN(������):���ذ����ұ��е����м�¼������������ֶ���ȵļ�¼���ұ��¼ȫ����ʾ,���ֻ��ʾ��������
  		  �ļ�¼������ط���ΪNULL��

---------------------




















