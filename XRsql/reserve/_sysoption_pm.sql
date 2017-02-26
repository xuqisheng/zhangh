delete sysoption where catalog='hotel' and item  like 'proom_%';


-- 自由使用 
--INSERT INTO sysoption  VALUES (
--	'hotel',
--	'proom_inst',
--	'T',
--	'F',
--	'是否启用假房功能',
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
	'客房管理那些假房',
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
	'房态表选择那些假房',
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
	'分房选择那些假房',
	'Using in Pick Room',
	'GDS',
	'11-1-2005 0:0:0.000',
	'T',
	'');

-- 必须是 PM 
--INSERT INTO sysoption  VALUES (
--	'hotel',
--	'proom_pm',
--	'PM',
--	'PM',
--	'假房 - 房类PM',
--	'PM for Pseudo Type',
--	'GDS',
--	'11-1-2005 0:0:0.000',
--	'T',
--	'');

select * from sysoption where catalog='hotel' and item like 'proom%';