
update gststa1 set descript1='Total' where descript='合计';
update gststa1 set descript1=' Over Seas' where descript='  境外';
update gststa1 set descript1=' Domestic' where descript='  境内';
update gststa1 set descript1='---Province Inside---' where descript='---省内---';
update gststa1 set descript1='---Province Outside---' where descript='---省外---';
update gststa1 set descript1='--No Address--' where descript='--地址不详--';
update gststa1 set descript1=a.descript1 from prvcode a where gststa1.wfrom=a.code;
update gststa1 set descript1=a.descript1 from cntcode a where gststa1.wfrom=a.code;

update ygststa1 set descript1='Total' where descript='合计';
update ygststa1 set descript1=' Over Seas' where descript='  境外';
update ygststa1 set descript1=' Domestic' where descript='  境内';
update ygststa1 set descript1='---Province Inside---' where descript='---省内---';
update ygststa1 set descript1='---Province Outside---' where descript='---省外---';
update ygststa1 set descript1='--No Address--' where descript='--地址不详--';
update ygststa1 set descript1=a.descript1 from prvcode a where ygststa1.wfrom=a.code;
update ygststa1 set descript1=a.descript1 from cntcode a where ygststa1.wfrom=a.code;

