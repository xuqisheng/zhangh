
------------------------------------------------------------------------------------
-- 2008.4.12  大扩容，把 act_bal 表相关内容并入，同时增加更多统计代码 
------------------------------------------------------------------------------------

if exists(select 1 from sysobjects where name='cus_xf' and type='U')
	drop table cus_xf;
CREATE TABLE cus_xf 
(
	date    	datetime 					not null,

	actcls  	char(1)  	default 'F'	 not null,		-- 账户类型 F, P, B
	accnt		char(10)						not null,		-- 前台账号、餐饮单号、bos单号等等
   sta		char(1)  	default '' not null,
   name     varchar(50) default '' null,

	master	char(10)		default ''	not null,		-- 前台判断同住
	groupno	char(10)		default ''	not null,		-- 前台账号成员的团体账号

	type		char(5)		default ''	not null,		-- 房类
	up_type	char(5)     default ''	null,  			-- 从哪个房间类型升级  
	up_reason char(3)		default ''	not null,  		-- 升级原因  
	roomno	char(5)		default ''	not null,
	rmreason	char(1)		default ''	not null,		-- 换房理由 
	rmrate	money			default 0	not null,		-- 房间报价 
	setrate	money			default 0	not null,		-- 与优惠及优惠理由一起决定实际房价 
	rtreason	char(3)		default ''	not null,		-- 房价优惠理由(cf.rtreason.dbf) 

	bdate		datetime	   				not null,		-- 当时的营业日期
	arr		datetime	   				not null,		-- 到店日期=arrival 
	dep		datetime	   				not null,		-- 离店日期=departure 

	haccnt	char(7)		default ''	not null,
	cusno		char(7)		default ''	not null,
	agent		char(7)		default ''	not null,
	source	char(7)		default ''	not null,
	contact 	char(7) 		default ''	not null,		-- 联系人 
	saleid  	char(12) 	default ''	not null,
	country	char(3)		default ''	not null,		-- 主要根据 haccnt	居住地国家
	nation	char(3)		default ''	not null,		-- 主要根据 haccnt	国籍

	market	char(3)		default ''	not null,		-- 宾客分析指标。餐饮的指标也可以放在这里
	src		char(3)		default ''	not null,
	channel	char(3)		default ''	not null,
	restype	char(3)		default '' 	not null,		-- 预订类别 

	artag1		char(3)		default '' 	not null,	-- 
	artag2		char(3)		default '' 	not null,	-- 

	ratecode		varchar(10)		default ''	not null,	-- 房价码 
	cmscode		varchar(10)		default ''	not null,	-- 佣金码 
	cardcode		varchar(10)		default ''	not null,	-- 会员卡代码 
	cardno		varchar(20)		default ''	not null,	-- 会员卡号码 

	rmnum		int			default 0 	not null,
	gstno		int			default 0 	not null,
	children	int			default 0	not null,			-- 小孩 

	t_arr   	char(1)  	default 'F'	 not null,			-- 本日到
	t_dep   	char(1)  	default 'F'	 not null,			-- 本日离

	i_days  	money    	default 0 	not null,
	x_times 	money    	default 0 	not null,
	n_times 	money    	default 0 	not null,

	lastd			money			default 0 not null,		-- 上日
	lastc			money			default 0 not null,		-- 上日
	lastbl		money			default 0 not null,		-- 上日

-- 本日帐户自己消费，不包含转帐 
	xf_rm      	money    	default 0 	not null,			-- 客房-已经包含以下包价
	xf_rm_svc  	money    	default 0 	not null,			-- 客房-服务费
	xf_rm_bf   	money    	default 0 	not null,			-- 客房-早餐
	xf_rm_cms  	money    	default 0 	not null,			-- 客房-佣金
	xf_rm_lau  	money    	default 0 	not null,			-- 客房-洗衣
	xf_rm_opak 	money    	default 0 	not null,			-- 客房-其他包价
	xf_fb      	money    	default 0 	not null,			-- 餐饮
	xf_mt      	money    	default 0 	not null,			-- 会议
	xf_en      	money    	default 0 	not null,			-- 康乐
	xf_sp      	money    	default 0 	not null,			-- 商场
	xf_dot   	money    	default 0 	not null,			-- 其他收入
	xf_dtl     	money    	default 0 	not null,			-- 收入合计

-- 本日帐户帐户变化，包含转帐 
	rm      	money    	default 0 	not null,			-- 客房-已经包含以下包价
	rm_svc  	money    	default 0 	not null,			-- 客房-服务费
	rm_bf   	money    	default 0 	not null,			-- 客房-早餐
	rm_cms  	money    	default 0 	not null,			-- 客房-佣金
	rm_lau  	money    	default 0 	not null,			-- 客房-洗衣
	rm_opak 	money    	default 0 	not null,			-- 客房-其他包价
	fb      	money    	default 0 	not null,			-- 餐饮
	mt      	money    	default 0 	not null,			-- 会议
	en      	money    	default 0 	not null,			-- 康乐
	sp      	money    	default 0 	not null,			-- 商场
	dot   	money    	default 0 	not null,			-- 其他收入
	dtl     	money    	default 0 	not null,			-- 收入合计

	t_rm      	money    	default 0 	not null,			-- 客房-已经包含以下包价
	t_rm_svc  	money    	default 0 	not null,			-- 客房-服务费
	t_rm_bf   	money    	default 0 	not null,			-- 客房-早餐
	t_rm_cms  	money    	default 0 	not null,			-- 客房-佣金
	t_rm_lau  	money    	default 0 	not null,			-- 客房-洗衣
	t_rm_opak 	money    	default 0 	not null,			-- 客房-其他包价
	t_fb      	money    	default 0 	not null,			-- 餐饮
	t_mt      	money    	default 0 	not null,			-- 会议
	t_en      	money    	default 0 	not null,			-- 康乐
	t_sp      	money    	default 0 	not null,			-- 商场
	t_dot   		money    	default 0 	not null,			-- 其他收入
	t_dtl     	money    	default 0 	not null,			-- 收入合计

	rmb     	money    	default 0 	not null,			-- 现金
	chk     	money    	default 0 	not null,			-- 支票
	card1   	money    	default 0 	not null,			-- 国内卡
	card2   	money    	default 0 	not null,			-- 国外卡
	ar     	money    	default 0 	not null,			-- 记账
	ticket  	money    	default 0 	not null,			-- 代价券
	dscent  	money    	default 0 	not null,			-- 款待折扣
	cot     	money    	default 0 	not null,			-- 其他收款
	ctl     	money    	default 0 	not null,			-- 收款合计

	t_rmb     	money    	default 0 	not null,			-- 现金
	t_chk     	money    	default 0 	not null,			-- 支票
	t_card1   	money    	default 0 	not null,			-- 国内卡
	t_card2   	money    	default 0 	not null,			-- 国外卡
	t_ar     	money    	default 0 	not null,			-- 记账
	t_ticket  	money    	default 0 	not null,			-- 代价券
	t_dscent  	money    	default 0 	not null,			-- 款待折扣
	t_cot     	money    	default 0 	not null,			-- 其他收款
	t_ctl     	money    	default 0 	not null,			-- 收款合计

	tilld			money			default 0 not null,			-- 本日余额 
	tillc			money			default 0 not null,
	tillbl		money			default 0 not null
);
exec sp_primarykey cus_xf,actcls,accnt;
create unique index index1 on cus_xf(actcls,accnt);



if exists(select 1 from sysobjects where name='ycus_xf' and type='U')
	drop table ycus_xf;
CREATE TABLE ycus_xf 
(
	date    	datetime 					not null,

	actcls  	char(1)  	default 'F'	 not null,		-- 账户类型 F, P, B
	accnt		char(10)						not null,		-- 前台账号、餐饮单号、bos单号等等
   sta		char(1)  	default '' not null,
   name     varchar(50) default '' null,

	master	char(10)		default ''	not null,		-- 前台判断同住
	groupno	char(10)		default ''	not null,		-- 前台账号成员的团体账号

	type		char(5)		default ''	not null,		-- 房类
	up_type	char(5)     default ''	null,  			-- 从哪个房间类型升级  
	up_reason char(3)		default ''	not null,  		-- 升级原因  
	roomno	char(5)		default ''	not null,
	rmreason	char(1)		default ''	not null,		-- 换房理由 
	rmrate	money			default 0	not null,		-- 房间报价 
	setrate	money			default 0	not null,		-- 与优惠及优惠理由一起决定实际房价 
	rtreason	char(3)		default ''	not null,		-- 房价优惠理由(cf.rtreason.dbf) 

	bdate		datetime	   				not null,		-- 当时的营业日期
	arr		datetime	   				not null,		-- 到店日期=arrival 
	dep		datetime	   				not null,		-- 离店日期=departure 

	haccnt	char(7)		default ''	not null,
	cusno		char(7)		default ''	not null,
	agent		char(7)		default ''	not null,
	source	char(7)		default ''	not null,
	contact 	char(7) 		default ''	not null,		-- 联系人 
	saleid  	char(12) 	default ''	not null,
	country	char(3)		default ''	not null,		-- 主要根据 haccnt
	nation	char(3)		default ''	not null,		-- 主要根据 haccnt

	market	char(3)		default ''	not null,		-- 宾客分析指标。餐饮的指标也可以放在这里
	src		char(3)		default ''	not null,
	channel	char(3)		default ''	not null,
	restype	char(3)		default '' 	not null,		-- 预订类别 

	artag1		char(3)		default '' 	not null,	-- 
	artag2		char(3)		default '' 	not null,	-- 

	ratecode		varchar(10)		default ''	not null,	-- 房价码 
	cmscode		varchar(10)		default ''	not null,	-- 佣金码 
	cardcode		varchar(10)		default ''	not null,	-- 会员卡代码 
	cardno		varchar(20)		default ''	not null,	-- 会员卡号码 

	rmnum		int			default 0 	not null,
	gstno		int			default 0 	not null,
	children	int			default 0	not null,			-- 小孩 

	t_arr   	char(1)  	default 'F'	 not null,			-- 本日到
	t_dep   	char(1)  	default 'F'	 not null,			-- 本日离

	i_days  	money    	default 0 	not null,
	x_times 	money    	default 0 	not null,
	n_times 	money    	default 0 	not null,

	lastd			money			default 0 not null,		-- 上日
	lastc			money			default 0 not null,		-- 上日
	lastbl		money			default 0 not null,		-- 上日

-- 本日帐户自己消费，不包含转帐 
	xf_rm      	money    	default 0 	not null,			-- 客房-已经包含以下包价
	xf_rm_svc  	money    	default 0 	not null,			-- 客房-服务费
	xf_rm_bf   	money    	default 0 	not null,			-- 客房-早餐
	xf_rm_cms  	money    	default 0 	not null,			-- 客房-佣金
	xf_rm_lau  	money    	default 0 	not null,			-- 客房-洗衣
	xf_rm_opak 	money    	default 0 	not null,			-- 客房-其他包价
	xf_fb      	money    	default 0 	not null,			-- 餐饮
	xf_mt      	money    	default 0 	not null,			-- 会议
	xf_en      	money    	default 0 	not null,			-- 康乐
	xf_sp      	money    	default 0 	not null,			-- 商场
	xf_dot   	money    	default 0 	not null,			-- 其他收入
	xf_dtl     	money    	default 0 	not null,			-- 收入合计

-- 本日帐户帐户变化，包含转帐 
	rm      	money    	default 0 	not null,			-- 客房-已经包含以下包价
	rm_svc  	money    	default 0 	not null,			-- 客房-服务费
	rm_bf   	money    	default 0 	not null,			-- 客房-早餐
	rm_cms  	money    	default 0 	not null,			-- 客房-佣金
	rm_lau  	money    	default 0 	not null,			-- 客房-洗衣
	rm_opak 	money    	default 0 	not null,			-- 客房-其他包价
	fb      	money    	default 0 	not null,			-- 餐饮
	mt      	money    	default 0 	not null,			-- 会议
	en      	money    	default 0 	not null,			-- 康乐
	sp      	money    	default 0 	not null,			-- 商场
	dot   	money    	default 0 	not null,			-- 其他收入
	dtl     	money    	default 0 	not null,			-- 收入合计

	t_rm      	money    	default 0 	not null,			-- 客房-已经包含以下包价
	t_rm_svc  	money    	default 0 	not null,			-- 客房-服务费
	t_rm_bf   	money    	default 0 	not null,			-- 客房-早餐
	t_rm_cms  	money    	default 0 	not null,			-- 客房-佣金
	t_rm_lau  	money    	default 0 	not null,			-- 客房-洗衣
	t_rm_opak 	money    	default 0 	not null,			-- 客房-其他包价
	t_fb      	money    	default 0 	not null,			-- 餐饮
	t_mt      	money    	default 0 	not null,			-- 会议
	t_en      	money    	default 0 	not null,			-- 康乐
	t_sp      	money    	default 0 	not null,			-- 商场
	t_dot   		money    	default 0 	not null,			-- 其他收入
	t_dtl     	money    	default 0 	not null,			-- 收入合计

	rmb     	money    	default 0 	not null,			-- 现金
	chk     	money    	default 0 	not null,			-- 支票
	card1   	money    	default 0 	not null,			-- 国内卡
	card2   	money    	default 0 	not null,			-- 国外卡
	ar     	money    	default 0 	not null,			-- 记账
	ticket  	money    	default 0 	not null,			-- 代价券
	dscent  	money    	default 0 	not null,			-- 款待折扣
	cot     	money    	default 0 	not null,			-- 其他收款
	ctl     	money    	default 0 	not null,			-- 收款合计

	t_rmb     	money    	default 0 	not null,			-- 现金
	t_chk     	money    	default 0 	not null,			-- 支票
	t_card1   	money    	default 0 	not null,			-- 国内卡
	t_card2   	money    	default 0 	not null,			-- 国外卡
	t_ar     	money    	default 0 	not null,			-- 记账
	t_ticket  	money    	default 0 	not null,			-- 代价券
	t_dscent  	money    	default 0 	not null,			-- 款待折扣
	t_cot     	money    	default 0 	not null,			-- 其他收款
	t_ctl     	money    	default 0 	not null,			-- 收款合计

	tilld			money			default 0 not null,			-- 本日余额 
	tillc			money			default 0 not null,
	tillbl		money			default 0 not null
);
exec sp_primarykey ycus_xf,date,actcls,accnt;
create unique index index1 on ycus_xf(date,actcls,accnt);
create index index2 on ycus_xf(haccnt);
create index index3 on ycus_xf(cusno);
create index index4 on ycus_xf(agent);
create index index5 on ycus_xf(source);
create index index6 on ycus_xf(saleid);
create index index7 on ycus_xf(market);
create index index8 on ycus_xf(src);
create index index9 on ycus_xf(channel);
create index index10 on ycus_xf(country);


-- ------------ cus_xf 表结构升级 ：增加 master, t_dep    2004/10/7 gds
--
--
-- 1. backup data 
--exec sp_rename cus_xf, a_cus_xf;
--exec sp_rename ycus_xf, a_ycus_xf;
--
-- 2. create new stru.
--   exec the up sql.
--
-- 3. restore data
--insert cus_xf select date,actcls,accnt,'',groupno,haccnt,cusno,agent,source,cardno,saleid,
--	market,src,channel,t_arr,'F',gstno,i_days,x_times,n_times,rm,fb,en,sp,ot,ttl,yj,zc from a_cus_xf;
--insert ycus_xf select date,actcls,accnt,'',groupno,haccnt,cusno,agent,source,cardno,saleid,
--	market,src,channel,t_arr,'F',gstno,i_days,x_times,n_times,rm,fb,en,sp,ot,ttl,yj,zc from a_ycus_xf;
--
-- 4. update .master
--update cus_xf set master=a.master from master a where cus_xf.actcls='F' and cus_xf.accnt=a.accnt;
--update cus_xf set master=a.master from hmaster a where cus_xf.actcls='F' and cus_xf.accnt=a.accnt;
--update ycus_xf set master=a.master from master a where ycus_xf.actcls='F' and ycus_xf.accnt=a.accnt;
--update ycus_xf set master=a.master from hmaster a where ycus_xf.actcls='F' and ycus_xf.accnt=a.accnt;
--
-- 5. update .t_dep
--update cus_xf set t_dep='T' from master a where cus_xf.actcls='F' and cus_xf.accnt=a.accnt and datediff(dd,cus_xf.date,a.dep)=0;
--update cus_xf set t_dep='T' from hmaster a where cus_xf.actcls='F' and cus_xf.accnt=a.accnt and datediff(dd,cus_xf.date,a.dep)=0;
--update ycus_xf set t_dep='T' from master a where ycus_xf.actcls='F' and ycus_xf.accnt=a.accnt and datediff(dd,ycus_xf.date,a.dep)=0;
--update ycus_xf set t_dep='T' from hmaster a where ycus_xf.actcls='F' and ycus_xf.accnt=a.accnt and datediff(dd,ycus_xf.date,a.dep)=0;
--
-- 6. correct .t_arr
--update  cus_xf set t_arr='F' from  master  a where  cus_xf.actcls='F'  and  cus_xf.accnt=a.accnt and  cus_xf.t_arr='T' and datediff(dd, cus_xf.date,a.dep)=0;
--update  cus_xf set t_arr='F' from hmaster  a where  cus_xf.actcls='F'  and  cus_xf.accnt=a.accnt and  cus_xf.t_arr='T' and datediff(dd, cus_xf.date,a.dep)=0;
--update ycus_xf set t_arr='F' from  master  a where ycus_xf.actcls='F'  and ycus_xf.accnt=a.accnt and ycus_xf.t_arr='T' and datediff(dd,ycus_xf.date,a.dep)=0;
--update ycus_xf set t_arr='F' from hmaster  a where ycus_xf.actcls='F'  and ycus_xf.accnt=a.accnt and ycus_xf.t_arr='T' and datediff(dd,ycus_xf.date,a.dep)=0;
--
-- 7. maintance
--update statistics cus_xf;
--update statistics ycus_xf;
--
-- 8. view data
--select * from cus_xf;
--select * from ycus_xf;
--
--
--