
update gststa1 set descript1='Total' where descript='�ϼ�';
update gststa1 set descript1=' Over Seas' where descript='  ����';
update gststa1 set descript1=' Domestic' where descript='  ����';
update gststa1 set descript1='---Province Inside---' where descript='---ʡ��---';
update gststa1 set descript1='---Province Outside---' where descript='---ʡ��---';
update gststa1 set descript1='--No Address--' where descript='--��ַ����--';
update gststa1 set descript1=a.descript1 from prvcode a where gststa1.wfrom=a.code;
update gststa1 set descript1=a.descript1 from cntcode a where gststa1.wfrom=a.code;

update ygststa1 set descript1='Total' where descript='�ϼ�';
update ygststa1 set descript1=' Over Seas' where descript='  ����';
update ygststa1 set descript1=' Domestic' where descript='  ����';
update ygststa1 set descript1='---Province Inside---' where descript='---ʡ��---';
update ygststa1 set descript1='---Province Outside---' where descript='---ʡ��---';
update ygststa1 set descript1='--No Address--' where descript='--��ַ����--';
update ygststa1 set descript1=a.descript1 from prvcode a where ygststa1.wfrom=a.code;
update ygststa1 set descript1=a.descript1 from cntcode a where ygststa1.wfrom=a.code;

