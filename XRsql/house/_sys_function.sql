-------------------------------------------------------
-- 失物招领 
-------------------------------------------------------
INSERT INTO sys_function VALUES (
	'2510',
	'25',
	'失物招领-列表',
	'失物招领-列表',
	'hs!sw!l');
INSERT INTO sys_function VALUES (
	'2511',
	'25',
	'失物招领-查看单据',
	'失物招领-查看单据',
	'hs!sw!v');
INSERT INTO sys_function VALUES (
	'2512',
	'25',
	'失物招领-新建',
	'失物招领-新建',
	'hs!sw!a');
INSERT INTO sys_function VALUES (
	'2513',
	'25',
	'失物招领-修改',
	'失物招领-修改',
	'hs!sw!m');
INSERT INTO sys_function VALUES (
	'2514',
	'25',
	'失物招领-删除',
	'失物招领-删除',
	'hs!sw!d');


-------------------------------------------------------
-- 增加临时态权限 
-------------------------------------------------------
INSERT INTO sys_function VALUES (
	'0101',
	'01',
	'设定客房临时状态(hsk)',
	'设定客房临时状态_e(hsk)',
	'rmsta!f5');
INSERT INTO sys_function VALUES (
	'0102',
	'01',
	'解除客房临时状态(hsk)',
	'解除客房临时状态(hsk)',
	'rmsta!f5clr');
INSERT INTO sys_function VALUES (
	'0103',
	'01',
	'设定客房临时状态(fo)',
	'设定客房临时状态(fo)',
	'rmsta!ff5');
INSERT INTO sys_function VALUES (
	'0104',
	'01',
	'解除客房临时状态(fo)',
	'解除客房临时状态(fo)',
	'rmsta!ff5clr');
