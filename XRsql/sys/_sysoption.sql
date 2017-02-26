
if not exists(select 1 from sysoption where catalog='hotel' and item='mailitem') 
	insert sysoption(catalog,item,value,def,remark,remark1,addby,addtime,usermod,lic)
		values('hotel','mailitem','345','12345','邮件系统功能选择 1=邮箱 2=实时消息 3=事务 4=交班 5=西软网站','邮件系统功能选择 1=邮箱 2=实时消息 3=事务 4=交班 5=西软网站','GDS','2006/11/28','T',''); 
