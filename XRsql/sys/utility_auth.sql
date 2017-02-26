--------------------------------------------------
-- 文档管理，物品租赁，会议室，事务，去向，留言等等权限管理功能
--------------------------------------------------

exec p_cyj_add_function 'A','00','sys!doccls','文档类型维护','文档类型维护_e';

exec p_cyj_add_function 'A','90','mt!rmq','会议室预定查询','会议室预定查询_e';
exec p_cyj_add_function 'A','90','mt!rmai','会议室预定','会议室预定_e';
exec p_cyj_add_function 'A','90','mt!rmm','会议室预定修改','会议室预定修改_e';
exec p_cyj_add_function 'A','90','mt!rmx','会议室预定取消','会议室预定取消_e';

exec p_cyj_add_function 'A','90','mt!rmoq','会议室维修单查询','会议室维修单查询_e';
exec p_cyj_add_function 'A','90','mt!rmo','会议室维修','会议室维修_e';
exec p_cyj_add_function 'A','90','mt!rmom','会议室维修单修改','会议室维修单修改_e';
exec p_cyj_add_function 'A','90','mt!rmox','会议室维修单删除','会议室维修单删除_e';

exec p_cyj_add_function 'A','90','res!q','物品租赁单查询','物品租赁单查询_e';
exec p_cyj_add_function 'A','90','res!ai','物品租赁','物品租赁_e';
exec p_cyj_add_function 'A','90','res!m','物品租赁单修改','物品租赁单修改_e';
exec p_cyj_add_function 'A','90','res!p','物品租赁单打印','物品租赁单打印_e';
exec p_cyj_add_function 'A','90','res!x','物品租赁单取消','物品租赁单取消_e';

exec p_cyj_add_function 'A','99','trace!q','事务单查询','事务单查询_e';
exec p_cyj_add_function 'A','99','trace!a','事务单增加','事务单增加_e';
exec p_cyj_add_function 'A','99','trace!p','事务单打印','事务单打印_e';
exec p_cyj_add_function 'A','99','trace!r','事务单处理','事务单处理_e';
exec p_cyj_add_function 'A','99','trace!x','事务单删除','事务单删除_e';

exec p_cyj_add_function 'A','99','gstmsg!locq','宾客去向查询','宾客去向查询_e';
exec p_cyj_add_function 'A','99','gstmsg!loca','宾客去向增加','宾客去向增加_e';
exec p_cyj_add_function 'A','99','gstmsg!locx','宾客去向删除','宾客去向删除_e';

exec p_cyj_add_function 'A','99','gstmsg!msgq','宾客留言查询','宾客留言查询_e';
exec p_cyj_add_function 'A','99','gstmsg!msga','宾客留言增加','宾客留言增加_e';
exec p_cyj_add_function 'A','99','gstmsg!msgm','宾客留言修改','宾客留言修改_e';
exec p_cyj_add_function 'A','99','gstmsg!msgr','宾客留言处理','宾客留言处理_e';
exec p_cyj_add_function 'A','99','gstmsg!msgp','宾客留言打印','宾客留言打印_e';
exec p_cyj_add_function 'A','99','gstmsg!msgx','宾客留言删除','宾客留言删除_e';
--------------------------------------------------
