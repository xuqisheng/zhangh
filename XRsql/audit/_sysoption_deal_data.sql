if not exists(select 1 from sysoption where catalog='deal_data' and item='checkroom')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'checkroom',
		'31',
		'31',
		'ҹ�����������������ݱ����������鷿�뱨��',
		'ҹ�����������������ݱ����������鷿�뱨��',
		'GDS',
		'1-1-2005 0:0:0.000',
		'T',
		'');
if not exists(select 1 from sysoption where catalog='deal_data' and item='discrepant_room')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'discrepant_room',
		'7',
		'7',
		'ҹ�����������������ݱ����������ͷ��������в鷿������ì�ܷ�',
		'ҹ�����������������ݱ����������ͷ��������в鷿������ì�ܷ�',
		'GDS',
		'1-1-2005 0:0:0.000',
		'T',
		'');
if not exists(select 1 from sysoption where catalog='deal_data' and item='message_x')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'message_x',
		'90',
		'90',
		'ҹ�����������������ݱ������������ԣ���Ϣ',
		'ҹ�����������������ݱ������������ԣ���Ϣ',
		'ZHJ',
		'1-1-2005 0:0:0.000',
		'T',
		'');
if not exists(select 1 from sysoption where catalog='deal_data' and item='mktsummaryrep_detail')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'mktsummaryrep_detail',
		'40',
		'40',
		'ҹ�����������������ݱ����������г���ͳ����ϸ��¼',
		'ҹ�����������������ݱ����������г���ͳ����ϸ��¼',
		'GDS',
		'1-1-2005 0:0:0.000',
		'T',
		'');
if not exists(select 1 from sysoption where catalog='deal_data' and item='package_detail')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'package_detail',
		'40',
		'40',
		'ҹ�����������������ݱ�������������ʹ����ϸ��¼',
		'ҹ�����������������ݱ�������������ʹ����ϸ��¼',
		'GDS',
		'1-1-2005 0:0:0.000',
		'T',
		'');
if not exists(select 1 from sysoption where catalog='deal_data' and item='qroom')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'qroom',
		'30',
		'30',
		'ҹ�����������������ݱ���������ǰ̨ Q-Room',
		'ҹ�����������������ݱ���������ǰ̨ Q-Room',
		'GDS',
		'1-1-2005 0:0:0.000',
		'T',
		'');
if not exists(select 1 from sysoption where catalog='deal_data' and item='rmpostbucket')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'rmpostbucket',
		'365',
		'40',
		'ҹ�����������������ݱ���������ҹ�󷿷����˼�¼',
		'ҹ�����������������ݱ���������ҹ�󷿷����˼�¼',
		'GDS',
		'1-1-2005 0:0:0.000',
		'T',
		'');

if not exists(select 1 from sysoption where catalog='deal_data' and item='lgfl')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'lgfl',
		'60',
		'60',
		'ҹ�����������������ݱ���������������־',
		'ҹ�����������������ݱ���������������־',
		'GDS',
		'12-1-2006 0:0:0.000',
		'T',
		'');

if not exists(select 1 from sysoption where catalog='deal_data' and item='rsvsrc_log')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'rsvsrc_log',
		'60',
		'60',
		'ҹ�����������������ݱ���������Ԥ������־',
		'ҹ�����������������ݱ���������Ԥ������־',
		'GDS',
		'12-1-2006 0:0:0.000',
		'T',
		'');

if not exists(select 1 from sysoption where catalog='deal_data' and item='ncr')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'ncr',
		'60',
		'60',
		'ҹ�����������������ݱ��������������ӿ�ԭʼ����',
		'ҹ�����������������ݱ��������������ӿ�ԭʼ����',
		'GDS',
		'12-1-2006 0:0:0.000',
		'T',
		'');

if not exists(select 1 from sysoption where catalog='deal_data' and item='phfolio')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'phfolio',
		'400',
		'400',
		'ҹ�����������������ݱ����������绰�Ʒ�����',
		'ҹ�����������������ݱ����������绰�Ʒ�����',
		'GDS',
		'12-1-2006 0:0:0.000',
		'T',
		'');

if not exists(select 1 from sysoption where catalog='deal_data' and item='pos_menu')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'pos_menu',
		'400',
		'400',
		'ҹ�����������������ݱ���������������˼�¼',
		'ҹ�����������������ݱ���������������˼�¼',
		'GDS',
		'12-1-2006 0:0:0.000',
		'T',
		'');

if not exists(select 1 from sysoption where catalog='deal_data' and item='rm_ooo_log')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'rm_ooo_log',
		'100',
		'100',
		'ҹ�����������������ݱ���������ά�޷���־',
		'ҹ�����������������ݱ���������ά�޷���־',
		'GDS',
		'12-1-2006 0:0:0.000',
		'T',
		'');

if not exists(select 1 from sysoption where catalog='deal_data' and item='doorcard_req')
	INSERT INTO sysoption VALUES (
		'deal_data',
		'doorcard_req',
		'14',
		'14',
		'ҹ�����������������ݱ����������ſ��ӿڼ�¼',
		'ҹ�����������������ݱ����������ſ��ӿڼ�¼',
		'GDS',
		'12-4-2006 0:0:0.000',
		'T',
		'');


//select * from sysoption where catalog='deal_data' order by item; 




























