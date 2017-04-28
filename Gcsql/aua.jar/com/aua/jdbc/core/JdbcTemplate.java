package com.aua.jdbc.core;

import com.aua.util.SQLHelper;
import java.lang.reflect.Method;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.hibernate.property.BasicPropertyAccessor;
import org.hibernate.property.Getter;
import org.hibernate.property.Setter;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.PreparedStatementCreator;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.JdbcUtils;

public class JdbcTemplate extends org.springframework.jdbc.core.JdbcTemplate
{
  private static final BasicPropertyAccessor BASIC_PROPERTY_ACCESSOR = new BasicPropertyAccessor();

  public <T> List<T> queryForList(SQLHelper sh, Class<T> clazz)
  {
    return query(new PreparedStatementCreator(this, sh)
    {
      public PreparedStatement createPreparedStatement() throws SQLException {
        PreparedStatement ps = con.prepareStatement(this.val$sh.getSQL());
        Object[] values = this.val$sh.getValues();
        if (values != null)
          for (int i = 1; i <= values.length; ++i)
            ps.setObject(i, values[(i - 1)]);


        return ps; }
    }
    , new RowMapper(this, clazz)
    {
      public T mapRow(, int rowNum) throws SQLException {
        int i;
        ResultSetMetaData rsmd = rs.getMetaData();
        int nrOfColumns = rsmd.getColumnCount();
        Object t = null;
        try {
          t = this.val$clazz.newInstance();
        } catch (Exception localException) {
        }
        for (int i = 1; i <= nrOfColumns; ++i) {
          String label = rsmd.getColumnLabel(i);
          if (label.contains("_")) {
            Matcher m = Pattern.compile("_(.)").matcher(label);
            StringBuffer sb = new StringBuffer();
            while (m.find())
              m.appendReplacement(sb, m.group(1).toUpperCase());

            m.appendTail(sb);
            label = sb.toString();
          }
          try {
            getter = JdbcTemplate.access$0().getGetter(this.val$clazz, label);
            Setter setter = JdbcTemplate.access$0().getSetter(this.val$clazz, label);
            Object arg = JdbcUtils.getResultSetValue(rs, i, getter.getReturnType());
            setter.getMethod().invoke(t, new Object[] { arg });
          } catch (Exception getter) {
          }
        }
        return t;
      }
    });
  }
}