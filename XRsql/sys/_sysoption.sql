
if not exists(select 1 from sysoption where catalog='hotel' and item='mailitem') 
	insert sysoption(catalog,item,value,def,remark,remark1,addby,addtime,usermod,lic)
		values('hotel','mailitem','345','12345','�ʼ�ϵͳ����ѡ�� 1=���� 2=ʵʱ��Ϣ 3=���� 4=���� 5=������վ','�ʼ�ϵͳ����ѡ�� 1=���� 2=ʵʱ��Ϣ 3=���� 4=���� 5=������վ','GDS','2006/11/28','T',''); 
