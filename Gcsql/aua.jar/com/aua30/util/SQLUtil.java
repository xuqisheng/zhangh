package com.aua30.util;

import java.util.ArrayList;
import java.util.List;

public class SQLUtil {
      private StringBuilder sb = new StringBuilder();
      private List<Object> values = new ArrayList<Object>();
      public SQLUtil appendSql(String subSql){
    	  sb.append(subSql);
    	  return this;
      }
      public SQLUtil insertValue(Object val){
    	  values.add(val);
    	  return this;
      }
      public String getSql(){
    	  return sb.toString();
      }
      public Object[] getValues(){
    	  return values.toArray();
      }
}
