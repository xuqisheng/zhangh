// 1. 
//exec sp_rename  guest, a_guest;
//exec sp_rename  guest_log, a_guest_log;
//
//
// 2. 
//  --- create new table 
//
// 3. 
//insert guest
//  SELECT no,sta,sno,cno,hotelid,central,censeq,name,fname,lname,name2,name3,class,type,grade,latency,class1,
//class2,class3,class4,src,market,vip,keep,belong,sex,lang,title,salutation,birth,race,religion,occupation,
//nation,idcls,ident,idend,cusno,unit,cardcode,cardno,cardlevel,country,state,town,city,street,zip,mobile,
//phone,fax,wetsite,email,country1,state1,town1,city1,street1,zip1,mobile1,phone1,fax1,email1,visaid,visaend,
//visano,visaunit,rjplace,rjdate,srqs,'',feature,rmpref,interest,lawman,regno,bank,bankno,taxno,liason,liason1,
//extrainf,refer1,refer2,refer3,comment,remark,override,arr,dep,code1,code2,code3,code4,code5,saleid,araccnt1,
//araccnt2,master,fv_date,fv_room,fv_rate,lv_date,lv_room,lv_rate,i_times,x_times,n_times,l_times,i_days,
//fb_times1,en_times2,rm,fb,en,mt,ot,tl,0,0,null,null,'','','',crtby,crttime,cby,changed,logmark  
//    FROM a_guest;
//insert guest_log
//  SELECT no,sta,sno,cno,hotelid,central,censeq,name,fname,lname,name2,name3,class,type,grade,latency,class1,
//class2,class3,class4,src,market,vip,keep,belong,sex,lang,title,salutation,birth,race,religion,occupation,
//nation,idcls,ident,idend,cusno,unit,cardcode,cardno,cardlevel,country,state,town,city,street,zip,mobile,
//phone,fax,wetsite,email,country1,state1,town1,city1,street1,zip1,mobile1,phone1,fax1,email1,visaid,visaend,
//visano,visaunit,rjplace,rjdate,srqs,'',feature,rmpref,interest,lawman,regno,bank,bankno,taxno,liason,liason1,
//extrainf,refer1,refer2,refer3,comment,remark,override,arr,dep,code1,code2,code3,code4,code5,saleid,araccnt1,
//araccnt2,master,fv_date,fv_room,fv_rate,lv_date,lv_room,lv_rate,i_times,x_times,n_times,l_times,i_days,
//fb_times1,en_times2,rm,fb,en,mt,ot,tl,0,0,null,null,'','','',crtby,crttime,cby,changed,logmark  
//    FROM a_guest_log;
//

// 4. trigger 

