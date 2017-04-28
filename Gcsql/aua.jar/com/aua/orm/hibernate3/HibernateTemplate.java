package com.aua.orm.hibernate3;

import com.aua.util.BeanUtils;
import com.aua.util.SQLHelper;
import java.lang.reflect.InvocationTargetException;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.SQLQuery;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.transform.Transformers;
import org.springframework.dao.DataAccessException;
import org.springframework.orm.hibernate3.HibernateCallback;
import org.springframework.orm.hibernate3.HibernateTemplate;

public class HibernateTemplate extends org.springframework.orm.hibernate3.HibernateTemplate
{
  public HibernateTemplate(SessionFactory sessionFactory, boolean allowCreate)
  {
    super(sessionFactory, allowCreate);
  }

  public HibernateTemplate(SessionFactory sessionFactory) {
    super(sessionFactory);
  }

  private int convertObject2Int(Object object) {
    if (object instanceof BigDecimal)
      return ((BigDecimal)object).intValue();
    if (object instanceof BigInteger)
      return ((BigInteger)object).intValue();
    if (object instanceof Integer)
      return ((Integer)object).intValue();
    if (object instanceof Short)
      return ((Short)object).intValue();
    if (object instanceof Long)
      return ((Long)object).intValue();
    if (object instanceof Float)
      return ((Float)object).intValue();
    if (object instanceof Double)
      return ((Double)object).intValue();

    throw new RuntimeException("unknow type please up grade code");
  }

  private void fillValues(Query queryObject, SQLHelper sh)
  {
    Object[] values = sh.getValues();
    if (values != null)
      for (int i = 0; i < values.length; ++i)
        queryObject.setParameter(i, values[i]);
  }

  private void fillPageSet(Query queryObject, SQLHelper sh)
  {
    if (sh.getFirstResult() != null)
      queryObject.setFirstResult(sh.getFirstResult().intValue());

    if ((sh.getMaxResults() != null) && (sh.getMaxResults().intValue() > 0))
      queryObject.setMaxResults(sh.getMaxResults().intValue());
  }

  public <T> List<T> find(SQLHelper sh, Class<T> clazz) throws DataAccessException
  {
    return ((List)executeWithNativeSession(new HibernateCallback(this, sh, clazz)
    {
      public List<T> doInHibernate() throws HibernateException, SQLException {
        Query queryObject = session.createQuery(this.val$sh.getSQL());
        HibernateTemplate.access$0(this.this$0, queryObject);
        HibernateTemplate.access$1(this.this$0, queryObject, this.val$sh);
        HibernateTemplate.access$2(this.this$0, queryObject, this.val$sh);
        if (this.val$clazz == null)
          return queryObject.list();
        if (this.val$clazz.equals(Map.class)) {
          queryObject.setResultTransformer(Transformers.ALIAS_TO_ENTITY_MAP);
          return queryObject.list(); }
        if (this.val$clazz.equals(List.class)) {
          queryObject.setResultTransformer(Transformers.TO_LIST);
          return queryObject.list();
        }
        queryObject.setResultTransformer(Transformers.ALIAS_TO_ENTITY_MAP);
        List list = queryObject.list();
        List ls = new ArrayList();
        for (Iterator iter = list.iterator(); iter.hasNext(); );
        return ls;
      }
    }));
  }

  public int count(SQLHelper sh) throws DataAccessException
  {
    return ((Integer)executeWithNativeSession(new HibernateCallback(this, sh) {
      public Integer doInHibernate() throws HibernateException {
        Query queryObject = session.createQuery(this.val$sh.getCountSQL());
        HibernateTemplate.access$0(this.this$0, queryObject);
        HibernateTemplate.access$1(this.this$0, queryObject, this.val$sh);
        return Integer.valueOf(HibernateTemplate.access$3(this.this$0, queryObject.uniqueResult()));
      }
    })).intValue
      ();
  }

  public <T> List<T> findByNativeSQL(SQLHelper sh, Class<T> clazz) throws DataAccessException {
    return ((List)executeWithNativeSession(new HibernateCallback(this, sh, clazz)
    {
      public List<T> doInHibernate() throws HibernateException, SQLException {
        SQLQuery queryObject = session.createSQLQuery(this.val$sh.getSQL());
        HibernateTemplate.access$0(this.this$0, queryObject);
        HibernateTemplate.access$1(this.this$0, queryObject, this.val$sh);
        HibernateTemplate.access$2(this.this$0, queryObject, this.val$sh);
        if (this.val$clazz == null)
          return queryObject.list();
        if (this.val$clazz.equals(Map.class)) {
          queryObject.setResultTransformer(Transformers.ALIAS_TO_ENTITY_MAP);
          return queryObject.list(); }
        if (this.val$clazz.equals(List.class)) {
          queryObject.setResultTransformer(Transformers.TO_LIST);
          return queryObject.list();
        }
        queryObject.setResultTransformer(Transformers.ALIAS_TO_ENTITY_MAP);
        List list = queryObject.list();
        List ls = new ArrayList();
        for (Iterator iter = list.iterator(); iter.hasNext(); );
        return ls;
      }
    }));
  }

  public int countByNativeSQL(SQLHelper sh) throws DataAccessException
  {
    return ((Integer)executeWithNativeSession(new HibernateCallback(this, sh) {
      public Integer doInHibernate() throws HibernateException, SQLException {
        SQLQuery queryObject = session.createSQLQuery(this.val$sh.getCountSQL());
        HibernateTemplate.access$0(this.this$0, queryObject);
        HibernateTemplate.access$1(this.this$0, queryObject, this.val$sh);
        return Integer.valueOf(HibernateTemplate.access$3(this.this$0, queryObject.uniqueResult()));
      }
    })).intValue();
  }

  public int bulkUpdateByNativeSQL(SQLHelper sh)
    throws DataAccessException
  {
    return ((Integer)executeWithNativeSession(new HibernateCallback(this, sh) {
      public Integer doInHibernate() throws HibernateException, SQLException {
        SQLQuery queryObject = session.createSQLQuery(this.val$sh.getSQL());
        HibernateTemplate.access$0(this.this$0, queryObject);
        HibernateTemplate.access$1(this.this$0, queryObject, this.val$sh);
        return Integer.valueOf(queryObject.executeUpdate());
      }
    })).intValue();
  }

  public int bulkUpdate(SQLHelper sh)
    throws DataAccessException
  {
    return ((Integer)executeWithNativeSession(new HibernateCallback(this, sh) {
      public Integer doInHibernate() throws HibernateException, SQLException {
        Query queryObject = session.createQuery(this.val$sh.getSQL());
        HibernateTemplate.access$0(this.this$0, queryObject);
        HibernateTemplate.access$1(this.this$0, queryObject, this.val$sh);
        return Integer.valueOf(queryObject.executeUpdate());
      }
    })).intValue();
  }
}