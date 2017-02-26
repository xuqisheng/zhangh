
// 初步记录那些档案需要删除 
//delete a_del; 
//insert a_del 
//	select no from guest 
//		where class='F' and vip='0' and street='' 
//			and saleid='' and i_times<=1 and changed<'2006.3.1'; 
//select count(1) from a_del; 
//
//

//delete a_del; 
//insert a_del 
//	select no from guest 
//		where i_times=0 and class='F' and saleid='' and changed<'2006.3.1';
//select count(1) from a_del; 
//

// 找出那些档案目前在用 ，放入 bbb 

// 扣除当前正在使用的档案 
//select count(1) from a_del; 
//delete a_del from bbb where a_del.no=bbb.haccnt; 
//select count(1) from a_del; 
//

// 档案整理 
//insert a_guest select * from guest a where a.no not in (select no from a_del); 
//insert guest select * from a_guest; 
