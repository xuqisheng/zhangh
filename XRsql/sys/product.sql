
--------------------------------------------------------------------------------------
--
-- 	版本信息，客户端应该同服务器段版本信息一致。
--		w_info_about.t_ver.text = rtrim(ver) + '.' + rtrim(subver) + '.' + rtrim(comiler) 
--		+ '.' + ' (Build  '+convert(char(12),logdate,2)+')'
--		w_info_about.t_product.text = 'Product ' + productid 
--
--------------------------------------------------------------------------------------

create table sysproduct
(
	ver				char(10)						not null,       -- 版本号
   subver   		char(10)    				not null,		 -- 子版本号
   compiler  		char(10)    				not null,       -- 本子版本编译次数
   author  			char(20) 					not null,		 -- 最后编制者
   logdate  		datetime default getdate()		not null, -- 最后编译日期
   productid		char(30) default ''				not null, -- 产品号（授权用户）
	validdate		datetime						null				 -- 有效期
)
;

insert into sysproduct select 'X5','01','01','FOXHIS',getdate(),'',null;