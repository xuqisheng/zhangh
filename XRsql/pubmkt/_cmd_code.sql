//exec p_hry_manage_auth_function 21,'cus!cms!a','����Ӷ����','01#02#03#04#05#06#07#08#09#10#11#12#','S';
//exec p_hry_manage_auth_function 21,'cus!cms!l','����ͻ���Ӷ�б��ѯ','01#02#03#04#05#06#07#08#09#10#11#12#','S';
//exec p_hry_manage_auth_function 21,'cus!cms!e','����ͻ���Ӷ�б�༭','01#02#03#04#05#06#07#08#09#10#11#12#','S';


//INSERT INTO basecode VALUES ('cmslink','CNS','C000108','','F','F',0,'','F');
//INSERT INTO basecode VALUES ('cmslink','COA','C000109','','F','F',0,'','F');
//INSERT INTO basecode VALUES ('cmslink','RAC','C000111','','F','F',0,'','F');


//
//INSERT INTO night_audit VALUES (
//	105,
//	'Commision',
//	'��Ӷ���ʴ���',
//	'Commison Post',
//	'w_tcr_audit_cmspost',
//	'',
//	'select count(1) from cms_rec a, sysdata b where a.bdate = b.bdate and a.sta=''I'' and back=''F''',
//	'F',
//	'1-1-2000 0:0:0.000',
//	'T',
//	'T');
//