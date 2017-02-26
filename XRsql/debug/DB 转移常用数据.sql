// 在目标库状态下执行.  foxhis3 -- 数据源 

//insert sysoption 
//select * from foxhis3..sysoption a where a.catalog+a.item not in (select catalog+item from sysoption );

//insert sys_function 
//select * from foxhis3..sys_function a where a.code not in (select code from sys_function );

//insert syscode_maint 
//select * from foxhis3..syscode_maint a where a.code not in (select code from syscode_maint );

//insert workselect 
//select * from foxhis3..workselect a where a.modu_id+a.window not in (select modu_id+window from workselect );

//insert genput_f9 
//select * from foxhis3..genput_f9 a where a.modu_id+a.window_name+a.window_option not in (select modu_id+window_name+window_option from genput_f9);

//insert bill_mode 
//select * from foxhis3..bill_mode a where a.code not in (select code from bill_mode);

//insert bill_unit 
//select * from foxhis3..bill_unit a where a.printtype+a.language not in (select printtype+language from bill_unit);

//insert sys_extraid 
//select * from foxhis3..sys_extraid a where a.cat not in (select cat from sys_extraid);

//insert basecode_cat 
//select * from foxhis3..basecode_cat a where a.cat not in (select cat from basecode_cat);

//insert basecode
//select * from foxhis3..basecode a where a.cat not in (select distinct cat from basecode);

//insert auditprg 
//select * from foxhis3..auditprg a where a.prgname not in (select prgname from auditprg);

//insert adtrep  
//select * from foxhis3..adtrep a where needinst='T' and instready='T' and a.callform not in (select callform from adtrep);




