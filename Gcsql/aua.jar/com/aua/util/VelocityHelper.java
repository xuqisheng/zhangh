package com.aua.util;

import java.io.StringWriter;
import java.util.Iterator;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.VelocityEngine;

public class VelocityHelper
{
  public static String merge(String content, Map<String, Object> params, String encoding)
  {
    VelocityEngine ve = new VelocityEngine();
    Properties p = new Properties();
    p.put("resource.loader", "aua");
    p.put("aua.resource.loader.class", "com.aua.velocity.ResourceLoader");
    StringWriter writer = new StringWriter();
    try {
      ve.init(p);
      Template t = ve.getTemplate(content, encoding);
      VelocityContext context = new VelocityContext();
      if (params != null)
        for (Iterator iter = params.keySet().iterator(); iter.hasNext(); ) {
          String key = (String)iter.next();
          context.put(key, params.get(key));
        }

      t.merge(context, writer);
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
    return writer.toString();
  }

  public static String mergeGBK(String content, Map<String, Object> params)
  {
    return merge(content, params, "gbk");
  }

  public static String mergeUTF8(String content, Map<String, Object> params) {
    return merge(content, params, "utf-8");
  }
}