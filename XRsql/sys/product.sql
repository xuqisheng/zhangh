
--------------------------------------------------------------------------------------
--
-- 	�汾��Ϣ���ͻ���Ӧ��ͬ�������ΰ汾��Ϣһ�¡�
--		w_info_about.t_ver.text = rtrim(ver) + '.' + rtrim(subver) + '.' + rtrim(comiler) 
--		+ '.' + ' (Build  '+convert(char(12),logdate,2)+')'
--		w_info_about.t_product.text = 'Product ' + productid 
--
--------------------------------------------------------------------------------------

create table sysproduct
(
	ver				char(10)						not null,       -- �汾��
   subver   		char(10)    				not null,		 -- �Ӱ汾��
   compiler  		char(10)    				not null,       -- ���Ӱ汾�������
   author  			char(20) 					not null,		 -- ��������
   logdate  		datetime default getdate()		not null, -- ����������
   productid		char(30) default ''				not null, -- ��Ʒ�ţ���Ȩ�û���
	validdate		datetime						null				 -- ��Ч��
)
;

insert into sysproduct select 'X5','01','01','FOXHIS',getdate(),'',null;