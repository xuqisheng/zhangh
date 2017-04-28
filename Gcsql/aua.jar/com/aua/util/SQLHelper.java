package com.aua.util;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class SQLHelper
  implements Serializable
{
  private static final long serialVersionUID = -1696744130L;
  private static Log log = LogFactory.getLog(SQLHelper.class);
  private StringBuilder sql = new StringBuilder(0);
  private List<Object> values = new ArrayList(0);
  private Integer firstResult;
  private Integer maxResults;
  private boolean nesting;

  public SQLHelper(String subSql)
  {
    this.sql.append(subSql);
  }

  public boolean isNesting()
  {
    return this.nesting;
  }

  public void setNesting(boolean nesting) {
    this.nesting = nesting;
  }

  public Integer getFirstResult() {
    return this.firstResult;
  }

  public void setFirstResult(Integer firstResult) {
    this.firstResult = firstResult;
  }

  public Integer getMaxResults() {
    return this.maxResults;
  }

  public void setMaxResults(Integer maxResults) {
    this.maxResults = maxResults;
  }

  public void setSql(String sql) {
    this.sql.setLength(0);
    this.sql.append(sql); }

  public void clear() {
    this.sql.setLength(0);
    this.values.clear();
    this.firstResult = null;
    this.maxResults = null;
    this.nesting = false;
  }

  public String getCountSQL()
  {
    String spellSql = this.sql.toString().replaceAll("\\s+", " ");
    String countSql = null;
    if (this.nesting)
      countSql = String.format("select count(1) from ( %1$s ) tab ", new Object[] { spellSql });
    else {
      countSql = spellSql;
    }

    if (log.isDebugEnabled())
      log.debug(String.format("sql:%1$s\nvalues:%2$s", new Object[] { countSql, this.values }));

    return countSql;
  }

  public SQLHelper appendSql(String subSql) {
    this.sql.append(subSql);
    return this;
  }

  public SQLHelper insertValue(Object obj) {
    this.values.add(obj);
    return this;
  }

  public SQLHelper appendInSql(String preInSql, List<?> list) {
    if ((list != null) && (list.size() > 0)) {
      this.sql.append(preInSql);
      this.sql.append(" IN(");
      for (Iterator iter = list.iterator(); iter.hasNext(); ) {
        this.sql.append("?");
        this.values.add(iter.next());
        if (!(iter.hasNext())) break label87;
        label87: this.sql.append(",");
      }

      this.sql.append(") ");
    }
    return this;
  }

  public SQLHelper appendInSql(String preInSql, Object[] objs) {
    if ((objs != null) && (objs.length > 0)) {
      this.sql.append(preInSql);
      this.sql.append(" IN(");
      for (int i = 0; i < objs.length; ++i) {
        this.sql.append("?");
        this.values.add(objs[i]);
        if (i < objs.length - 1)
          this.sql.append(",");
      }

      this.sql.append(") ");
    }
    return this;
  }

  public SQLHelper appendOrSql(String singleOrSql, List<?> list)
  {
    if ((list != null) && (list.size() > 0))
    {
      this.sql.append(" and ( 1=2");
      for (Iterator iter = list.iterator(); iter.hasNext(); ) {
        this.sql.append(singleOrSql);
        this.values.add(iter.next());
      }

      this.sql.append(") ");
    }
    return this;
  }

  public SQLHelper appendOrSql(String singleOrSql, Object[] objs) {
    if ((objs != null) && (objs.length > 0)) {
      this.sql.append(" and ( 1=2");
      for (int i = 0; i < objs.length; ++i) {
        this.sql.append(singleOrSql);
        this.values.add(objs[i]);
      }

      this.sql.append(") ");
    }
    return this; }

  public String getSQL() {
    String spellSql = this.sql.toString().replaceAll("\\s+", " ");
    if (log.isDebugEnabled())
      log.debug(String.format("sql:%1$s\nvalues:%2$s\nfirstResult:%3$d\nmaxResults:%4$s", new Object[] { spellSql, this.values, this.firstResult, this.maxResults }));

    return spellSql;
  }

  public Object[] getValues() {
    return this.values.toArray();
  }
}