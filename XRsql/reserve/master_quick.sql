//--------------------------------------------------------------------------------
// ���ٵǼ���ʱ��
//
//		������ master, guest �й�����
//		���ٵǼ�ÿ��ÿ����סһ���� !
//--------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "master_quick" and type="U")
	drop table master_quick;
//create table master_quick
//(
//	modu_id		char(2)							not null,
//	pc_id			char(4)							not null,
//	ratemode		char(10)		default ''		not null,
//	type		   char(3)		default ''		not null,	//��������
//	roomno		char(5)		default ''		not null,	//����
//	arr			datetime	   					null,			//��������=arrival
//	dep			datetime	   					null,			//�������=departure
//	num			int	   						null,			//����
//	cusno			char(10)							null,
//	agent			char(10)							null,
//	source		char(10)							null,
//	market		char(3)							null,			//�г���
//	src			char(3)							null,			//��Դ
//	channel		char(3)							null,			//����
//	qtrate		money			default 0		null,			//���䱨��
//	rmrate		money			default 0		null,			//Э���
//	setrate		money			default 0		null,			//ʵ��
//	rtreason	   char(3)		default ''		null,			//�����Ż�����(cf.rtreason.dbf)
//	discount	   money			default 0		not null,	//�Żݶ�
//	discount1	money			default 0		not null,	//�Żݱ���
//
//	name		   varchar(50)	 					not null,	//����: ���� 
//	fname       varchar(30)	default ''		not null, 	//Ӣ���� 
//	lname			varchar(30)	default '' 		not null,	//Ӣ���� 
//	name2		   varchar(50)	default '' 		not null,	//�������� 
//	name3		   varchar(50)	default '' 		not null,	//�������� 
//   idcls       char(3)     default ''		not null,   //֤�����
//	ident			char(20)		default ''		not null,	//֤������
//	sex			char(1)		default '1'		not null,   //�Ա�:M,F 
//	lang			char(1)		default 'C'		not null,	//���� 
//	birth       datetime							null,			//����with format mm/dd
//	vip			char(3)		default '0'		not null,  	//vip 
//	nation		char(3)		default ''		not null,	//�����������
//	pcusno		char(7)		default ''		not null,	//��λ�� 
//	punit       varchar(60)	default ''		not null,	//��λ 
//	street	   varchar(60)	default ''		not null,	//סַ 
//	birthplace	char(6)							null,			//����
//	haccnt		char(7)							null,			//��ʷ�ʺ�
//
//	paycode		char(5)							null,			//���㷽ʽ
//	exp_s			varchar(10)						null,
//	applicant	varchar(30)						null,			//��λ/ί�е�λ
//	master	   char(10)							null,			//������־�˺� 
//	pcrec		   char(10)							null,			//������־�˺� 
//	secret		char(1) 		default 'F'		null,  		//���� 
//	phonesta	   char(1)							null,			//�ֻ��ȼ�
//	vodsta	   char(1)							null,			//�ֻ��ȼ�
//	intsta	   char(1)							null,			//�ֻ��ȼ�
//	ref			varchar(255)					null,			//��ע
//	resby			char(10)							not null,	//�Ǽ�Ա����=reserved by
//	reserved		datetime							not null,	//��������ʱ��,��ϵͳʱ��,�����޸�
//	accnt			char(10)							not null		//�ʺ�
//)
//exec sp_primarykey master_quick, modu_id, pc_id, roomno
//create unique index  master_quick on master_quick(modu_id, pc_id, roomno)
//;


CREATE TABLE master_quick 
(
    modu_id   char(2)     NOT NULL,
    pc_id     char(4)     NOT NULL,
    accnt     char(10)    NULL,
    haccnt    char(7)     DEFAULT '' NOT NULL,
    type      char(3)     DEFAULT space(3) NULL,
    roomno    char(5)     DEFAULT space(5) NULL,
    arr       datetime    NULL,
    dep       datetime    NULL,
    num       int         NULL,
    class     char(1)     DEFAULT '' NOT NULL,
    src       char(3)     DEFAULT '' NOT NULL,
    market    char(3)     DEFAULT '' NOT NULL,
    restype   char(3)     DEFAULT '' NOT NULL,
	 channel	  char(3)     DEFAULT '' NOT NULL,
    ratecode  char(10)    DEFAULT '' NOT NULL,
    packages  char(20)    DEFAULT '' NOT NULL,
    master    char(10)    DEFAULT '' NOT NULL,
    saccnt    char(10)    DEFAULT '' NOT NULL,
    pcrec     char(10)    DEFAULT '' NOT NULL,
    resno     varchar(10) DEFAULT '' NOT NULL,
    extra     char(30)    DEFAULT '' NOT NULL,
    qtrate    money       DEFAULT 0 NULL,
    setrate   money       DEFAULT 0 NULL,
    rtreason  char(3)     DEFAULT ' ' NULL,
    discount  money       DEFAULT 0 NOT NULL,
    discount1 money       DEFAULT 0 NOT NULL,
    name      varchar(50) NOT NULL,
    lname     varchar(30) DEFAULT "" NULL,
    nation    char(3)     DEFAULT '' NULL,
    resby     char(10)    DEFAULT '' NOT NULL,
    restime   datetime    NULL,
    sta       char(1)     NULL
)
EXEC sp_primarykey master_quick, modu_id,pc_id,roomno
CREATE UNIQUE INDEX index1 ON master_quick(modu_id,pc_id,type,roomno)
;