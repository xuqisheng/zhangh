
-- 插入康乐系统权限类
exec p_cyj_add_function 'S', '18', 'spo!sale', '费用输入，收银','';

-- 插入康乐系统权限
exec p_cyj_add_function 'F', '18', 'spo!sale', '费用输入，收银','_e';
exec p_cyj_add_function 'F', '18', 'spo!dish', '费用输入','_e';
exec p_cyj_add_function 'F', '18', 'spo!checkout', '收银结账','_e';
exec p_cyj_add_function 'F', '18','spo!menu!a', '开单','';
exec p_cyj_add_function 'F', '18','spo!menu!m', '改单','';
exec p_cyj_add_function 'F', '18','spo!union', '并单','';
exec p_cyj_add_function 'F', '18','spo!division', '分单','';
exec p_cyj_add_function 'F', '18','spo!cancer', '冲销点菜','';
exec p_cyj_add_function 'F', '18','spo!list', '查询账单','';
exec p_cyj_add_function 'F', '18','spo!rsv!a', '增加预订','';
exec p_cyj_add_function 'F', '18','spo!rsv!m', '修改预订','';
exec p_cyj_add_function 'F', '18','spo!rsv!o', '确认预订','';
exec p_cyj_add_function 'F', '18','spo!rsv!r', '预订查询','';
exec p_cyj_add_function 'F', '18','spo!rsv!reg', '预订转登记','';
exec p_cyj_add_function 'F', '18','spo!rsv!c', '取消预订','';
exec p_cyj_add_function 'F', '18','spo!place!a', '增加场地','';
exec p_cyj_add_function 'F', '18','spo!place!m', '修改场地','';
exec p_cyj_add_function 'F', '18','spo!place!d', '减少场地','';
exec p_cyj_add_function 'F', '18','spo!place!r', '查询场地','';
exec p_cyj_add_function 'F', '18','spo!place!o', '维修场地','';
exec p_cyj_add_function 'F', '18','spo!tax!checkout', '会费结算','';
exec p_cyj_add_function 'F', '18','spo!tax!input', '会费输入','';
exec p_cyj_add_function 'F', '18','#spo!vipread#', '贵宾卡读取','';

