delete sysoption where catalog='hotel' and item  like 'proom_%';


-- ����ʹ�� 
--INSERT INTO sysoption  VALUES (
--	'hotel',
--	'proom_inst',
--	'T',
--	'F',
--	'�Ƿ����üٷ�����',
--	'Install Pseudo Room Function ?',
--	'GDS',
--	'11-1-2005 0:0:0.000',
--	'T',
--	'');

INSERT INTO sysoption  VALUES (
	'hotel',
	'proom_hsk',
	'PY',
	'PY',
	'�ͷ�������Щ�ٷ�',
	'Managed by House Keeping',
	'GDS',
	'11-1-2005 0:0:0.000',
	'T',
	'');
INSERT INTO sysoption  VALUES (
	'hotel',
	'proom_map',
	'PY',
	'PY',
	'��̬��ѡ����Щ�ٷ�',
	'Using in house map',
	'GDS',
	'11-1-2005 0:0:0.000',
	'T',
	'');
INSERT INTO sysoption  VALUES (
	'hotel',
	'proom_pick',
	'PY,PM',
	'PY,PM',
	'�ַ�ѡ����Щ�ٷ�',
	'Using in Pick Room',
	'GDS',
	'11-1-2005 0:0:0.000',
	'T',
	'');

-- ������ PM 
--INSERT INTO sysoption  VALUES (
--	'hotel',
--	'proom_pm',
--	'PM',
--	'PM',
--	'�ٷ� - ����PM',
--	'PM for Pseudo Type',
--	'GDS',
--	'11-1-2005 0:0:0.000',
--	'T',
--	'');

select * from sysoption where catalog='hotel' and item like 'proom%';