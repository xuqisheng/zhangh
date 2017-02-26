//==========================================================================
//Table : master_des
//
//			master key column's descript 
//
//		���ά���ñ�
//			-- �������� master �������У� ����ϵͳ���к���
//			���ã������޸�  - 
//					״̬�޸�  - update trigger
//
//==========================================================================

//--------------------------------------------------------------------------
//		master_des, master_des_till, master_des_last
//--------------------------------------------------------------------------
if exists(select * from sysobjects where name = "master_des" and type="U")
	drop table master_des;
create table master_des
(
	accnt		   	char(10)						not null,	/* �ʺ�:����(�����ɼ�˵����)  */

	sta_o		   	char(1)			default ''	not null,	
	sta		   	char(20)			default ''	not null,	

	haccnt_o			char(7)			default '' 	not null,	/* ���͵�����  */
	haccnt			varchar(50)		default '' 	not null,	/* ���͵�����  */

	groupno_o		char(10)			default '' 	not null,	/* �����ź�  */
	groupno			varchar(50)		default '' 	not null,	/* �����ź�  */

	blkcode_o		char(10)			default '' 	not null,	/* ����blkcode  */
	blkcode			varchar(50)		default '' 	not null,	

	arr				datetime	   				not null,	/* ��������=arrival */
	dep				datetime	   				not null,	/* �������=departure */

	unit				varchar(60)		default '' 	not null,	// profile unit 

	agent_o			char(7)			default '' 	not null,
	agent				varchar(50)		default '' 	not null,

	cusno_o			char(7)			default '' 	not null,
	cusno				varchar(50)		default '' 	not null,

	source_o			char(7)			default '' 	not null,
	source			varchar(50)		default '' 	not null,

	src_o				char(3)			default '' 	not null,	/* ��Դ */
	src				varchar(40)		default '' 	not null,	/* ��Դ */

	market_o			char(3)			default '' 	not null,	/* �г��� */
	market			varchar(40)		default '' 	not null,	/* �г��� */

	restype_o		char(3)			default '' 	not null,	/* Ԥ����� */
	restype			varchar(40)		default '' 	not null,	/* Ԥ����� */

	channel_o		varchar(3)		default '' 	not null,	/* ���� */
	channel			varchar(40)		default '' 	not null,	/* ���� */

	artag1_o			char(3)			default '' 	not null,
	artag1			varchar(40)		default '' 	not null,

	artag2_o			char(3)			default '' 	not null,
	artag2			varchar(40)		default '' 	not null,
	
	ratecode_o		char(10)    	default '' 	not null,	/* ������  */
	ratecode			varchar(60)    default '' 	not null,	/* ������  */

	rtreason_o		char(3)			default ''	not null,	/* �����Ż�����(cf.rtreason.dbf) */
	rtreason			varchar(20)		default ''	not null,	/* �����Ż�����(cf.rtreason.dbf) */

	paycode_o		char(3)			default ''	not null,	/* ���㷽ʽ */
	paycode			varchar(24)		default ''	not null,	/* ���㷽ʽ */

	wherefrom_o		char(6)			default ''	not null,	/* �ε��� */
	wherefrom		varchar(40)		default ''	not null,	/* �ε��� */

	whereto_o		char(6)			default ''	not null,	/* �ε�ȥ */
	whereto			varchar(40)		default ''	not null,	/* �ε�ȥ */

	saleid_o			char(10)			default ''	not null,	/* ����Ա */
	saleid			varchar(30)		default ''	not null		/* ����Ա */
)
exec sp_primarykey master_des,accnt
create unique index index1 on master_des(accnt)
;


if exists(select * from sysobjects where name = "master_des_till" and type="U")
	drop table master_des_till;
create table master_des_till
(
	accnt		   	char(10)						not null,	/* �ʺ�:����(�����ɼ�˵����)  */

	sta_o		   	char(1)			default ''	not null,	
	sta		   	char(20)			default ''	not null,	

	haccnt_o			char(7)			default '' 	not null,	/* ���͵�����  */
	haccnt			varchar(50)		default '' 	not null,	/* ���͵�����  */

	groupno_o		char(10)			default '' 	not null,	/* �����ź�  */
	groupno			varchar(50)		default '' 	not null,	/* �����ź�  */

	blkcode_o		char(10)			default '' 	not null,	/* ����blkcode  */
	blkcode			varchar(50)		default '' 	not null,	

	arr				datetime	   				not null,	/* ��������=arrival */
	dep				datetime	   				not null,	/* �������=departure */

	unit				varchar(60)		default '' 	not null,	// profile unit 

	agent_o			char(7)			default '' 	not null,
	agent				varchar(50)		default '' 	not null,

	cusno_o			char(7)			default '' 	not null,
	cusno				varchar(50)		default '' 	not null,

	source_o			char(7)			default '' 	not null,
	source			varchar(50)		default '' 	not null,

	src_o				char(3)			default '' 	not null,	/* ��Դ */
	src				varchar(40)		default '' 	not null,	/* ��Դ */

	market_o			char(3)			default '' 	not null,	/* �г��� */
	market			varchar(40)		default '' 	not null,	/* �г��� */

	restype_o		char(3)			default '' 	not null,	/* Ԥ����� */
	restype			varchar(40)		default '' 	not null,	/* Ԥ����� */

	channel_o		varchar(3)		default '' 	not null,	/* ���� */
	channel			varchar(40)		default '' 	not null,	/* ���� */

	artag1_o			char(3)			default '' 	not null,
	artag1			varchar(40)		default '' 	not null,

	artag2_o			char(3)			default '' 	not null,
	artag2			varchar(40)		default '' 	not null,
	
	ratecode_o		char(10)    	default '' 	not null,	/* ������  */
	ratecode			varchar(60)    default '' 	not null,	/* ������  */

	rtreason_o		char(3)			default ''	not null,	/* �����Ż�����(cf.rtreason.dbf) */
	rtreason			varchar(20)		default ''	not null,	/* �����Ż�����(cf.rtreason.dbf) */

	paycode_o		char(3)			default ''	not null,	/* ���㷽ʽ */
	paycode			varchar(24)		default ''	not null,	/* ���㷽ʽ */

	wherefrom_o		char(6)			default ''	not null,	/* �ε��� */
	wherefrom		varchar(40)		default ''	not null,	/* �ε��� */

	whereto_o		char(6)			default ''	not null,	/* �ε�ȥ */
	whereto			varchar(40)		default ''	not null,	/* �ε�ȥ */

	saleid_o			char(10)			default ''	not null,	/* ����Ա */
	saleid			varchar(30)		default ''	not null		/* ����Ա */
)
exec sp_primarykey master_des_till,accnt
create unique index index1 on master_des_till(accnt)
;


if exists(select * from sysobjects where name = "master_des_last" and type="U")
	drop table master_des_last;
create table master_des_last
(
	accnt		   	char(10)						not null,	/* �ʺ�:����(�����ɼ�˵����)  */

	sta_o		   	char(1)			default ''	not null,	
	sta		   	char(20)			default ''	not null,	

	haccnt_o			char(7)			default '' 	not null,	/* ���͵�����  */
	haccnt			varchar(50)		default '' 	not null,	/* ���͵�����  */

	groupno_o		char(10)			default '' 	not null,	/* �����ź�  */
	groupno			varchar(50)		default '' 	not null,	/* �����ź�  */

	blkcode_o		char(10)			default '' 	not null,	/* ����blkcode  */
	blkcode			varchar(50)		default '' 	not null,	

	arr				datetime	   				not null,	/* ��������=arrival */
	dep				datetime	   				not null,	/* �������=departure */

	unit				varchar(60)		default '' 	not null,	// profile unit 

	agent_o			char(7)			default '' 	not null,
	agent				varchar(50)		default '' 	not null,

	cusno_o			char(7)			default '' 	not null,
	cusno				varchar(50)		default '' 	not null,

	source_o			char(7)			default '' 	not null,
	source			varchar(50)		default '' 	not null,

	src_o				char(3)			default '' 	not null,	/* ��Դ */
	src				varchar(40)		default '' 	not null,	/* ��Դ */

	market_o			char(3)			default '' 	not null,	/* �г��� */
	market			varchar(40)		default '' 	not null,	/* �г��� */

	restype_o		char(3)			default '' 	not null,	/* Ԥ����� */
	restype			varchar(40)		default '' 	not null,	/* Ԥ����� */

	channel_o		varchar(3)		default '' 	not null,	/* ���� */
	channel			varchar(40)		default '' 	not null,	/* ���� */

	artag1_o			char(3)			default '' 	not null,
	artag1			varchar(40)		default '' 	not null,

	artag2_o			char(3)			default '' 	not null,
	artag2			varchar(40)		default '' 	not null,
	
	ratecode_o		char(10)    	default '' 	not null,	/* ������  */
	ratecode			varchar(60)    default '' 	not null,	/* ������  */

	rtreason_o		char(3)			default ''	not null,	/* �����Ż�����(cf.rtreason.dbf) */
	rtreason			varchar(20)		default ''	not null,	/* �����Ż�����(cf.rtreason.dbf) */

	paycode_o		char(3)			default ''	not null,	/* ���㷽ʽ */
	paycode			varchar(24)		default ''	not null,	/* ���㷽ʽ */

	wherefrom_o		char(6)			default ''	not null,	/* �ε��� */
	wherefrom		varchar(40)		default ''	not null,	/* �ε��� */

	whereto_o		char(6)			default ''	not null,	/* �ε�ȥ */
	whereto			varchar(40)		default ''	not null,	/* �ε�ȥ */

	saleid_o			char(10)			default ''	not null,	/* ����Ա */
	saleid			varchar(30)		default ''	not null		/* ����Ա */
)
exec sp_primarykey master_des_last,accnt
create unique index index1 on master_des_last(accnt)
;
