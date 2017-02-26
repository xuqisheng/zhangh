
//  basecode : cat = vod_grade


------------------------------------------------------------------------------------
--  		ԭʼ��¼
------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "vod_src" and type="U")
	drop table vod_src;
create table vod_src 
(
    log_date datetime     not null,
    src      varchar(100) null
)
exec sp_primarykey 'vod_src', log_date
create unique nonclustered index index1 on vod_src(log_date)
;

------------------------------------------------------------------------------------
--  		�ƷѴ���ԭʼ��¼  --- �����¼��Ч,���ֹ���������
------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "vod_err" and type="U")
	drop table vod_err;
create table vod_err 
(
    log_date datetime     not null,
    src      varchar(100) null
)
exec sp_primarykey 'vod_err', log_date
create unique nonclustered index index1 on vod_err(log_date)
;


if exists(select * from sysobjects where name = "vod_posterr" and type="U")
	drop table vod_posterr;
create table vod_posterr 
(
    logdate datetime     not null,
    des     varchar(100) not null
)
exec sp_primarykey 'vod_posterr', logdate
create unique nonclustered index index1 on vod_posterr(logdate)
;


------------------------------------------------------------------------------------
--       �Ʒ���ˮ���ļ�
------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "vodfolio" and type="U")
	drop table vodfolio;
create table vodfolio 
(
    inumber  int         not null,	
    log_date datetime    not null,		-- FOXHIS ϵͳ����ʱ��
    status   char(1)     not null,		-- ״̬
    seq_id   varchar(10) not null,		-- �㲥��ˮ��
    usr_id   varchar(10) not null,		-- �ͷ����
    pgm_name varchar(20) not null,		-- �㲥���ݵ����� 
    p_time   datetime    not null,		-- ����ʱ��
    pgm_amt  money       not null,		-- ����
    refer    char(10)    null,
    empno    char(10)    null,
    shift    char(1)     null
)
exec sp_primarykey 'vodfolio', inumber
create unique nonclustered index index1  on vodfolio(inumber)
create unique nonclustered index index2  on vodfolio(log_date)
;


------------------------------------------------------------------------------------
--       �Ʒ���ˮ���ļ� - ��ʷ
------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "vodhfolio" and type="U")
	drop table vodhfolio;
create table vodhfolio 
(
    inumber  int         not null,
    log_date datetime    not null,		-- FOXHIS ϵͳ����ʱ��
    status   char(1)     not null,		-- ״̬
    seq_id   varchar(10) not null,		-- �㲥��ˮ��
    usr_id   varchar(10) not null,		-- �ͷ����
    pgm_name varchar(20) not null,		-- �㲥���ݵ����� 
    p_time   datetime    not null,		-- ����ʱ��
    pgm_amt  money       not null,		-- ����
    refer    char(10)    null,
    empno    char(10)    null,
    shift    char(1)     null
)
exec sp_primarykey 'vodhfolio', inumber
create unique nonclustered index index1 on vodhfolio(inumber)
create unique nonclustered index index2 on vodhfolio(log_date)
;


------------------------------------------------------------------------------------
-- 		�ͷ� VOD �ȼ�
--			�趨,ȡ��,�޸� ---> ǰ̨,���Է� ����ȫ�����
--			���˽������ ---> ����MASTER��״̬�仯����(����TRIGGER)
------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "vod_grd" and type="U")
	drop table vod_grd;
create table vod_grd 
(
    roomno    char(5)       not null,					-- �Ƶ�ͷ����
    changed   char(1)       default 'f' null,
    ograde    char(1)       null,						-- ״̬���
    grade     char(1)       not null,
    obox_addr varchar(10)   null,						-- �ͷ������е�ַ
    box_addr  varchar(10)   null,
    gst_grd   char(1)       default '1' null,		-- �ͷ��������˵ļ��� 1->A, 3->B 
    gst_name  varchar(10)   default 'vod' not null,-- ��������
    empno     char(10)      null,
    shift     char(1)       null,
    date      datetime      null,
    logmark   numeric(10,0) default 0  null
)
exec sp_primarykey 'vod_grd', roomno
create unique nonclustered index index1 on vod_grd(roomno)
;


------------------------------------------------------------------------------------
-- 		�ͷ� VOD �ȼ�  --- ��־�ļ�
------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "vod_grd_log" and type="U")
	drop table vod_grd_log;
create table vod_grd_log 
(
    roomno    char(5)       not null,					-- �Ƶ�ͷ����
    changed   char(1)       default 'f' null,
    ograde    char(1)       null,						-- ״̬���
    grade     char(1)       not null,
    obox_addr varchar(10)   null,						-- �ͷ������е�ַ
    box_addr  varchar(10)   null,
    gst_grd   char(1)       default '1' null,		-- �ͷ��������˵ļ��� 1->A, 3->B 
    gst_name  varchar(10)   default 'vod' not null,-- ��������
    empno     char(10)      null,
    shift     char(1)       null,
    date      datetime      null,
    logmark   numeric(10,0) default 0  null
)
exec sp_primarykey 'vod_grd_log', roomno,logmark
create unique nonclustered index index1 on vod_grd_log(roomno,logmark)
;


------------------------------------------------------------------------------------
--  		���а� 
------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "vod_board" and type="U")
	drop table vod_board;
create table vod_board 
(
    pc_id   char(4)     not null,
    no      int         not null,
    program varchar(20) default '?' not null,
    number  int         default 0 not null
)
exec sp_primarykey 'vod_board', pc_id,program
create unique nonclustered index index1 on vod_board(pc_id,program)
;


------------------------------------------------------------------------------------
--  		���а�  (��ʱ��)
------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "vod_board_tmp" and type="U")
	drop table vod_board_tmp;
create table vod_board_tmp 
(
    pc_id   char(4)     not null,
    program varchar(20) default '?' not null,
    number  int         default 0 not null
)
exec sp_primarykey 'vod_board_tmp', pc_id,program
create unique nonclustered index index1 on vod_board_tmp(pc_id,program)
;

