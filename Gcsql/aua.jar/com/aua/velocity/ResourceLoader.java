package com.aua.velocity;

import com.aua.util.StringHelper;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import org.apache.commons.collections.ExtendedProperties;
import org.apache.velocity.exception.ResourceNotFoundException;
import org.apache.velocity.runtime.resource.Resource;
import org.apache.velocity.runtime.resource.loader.ResourceLoader;

public class ResourceLoader extends org.apache.velocity.runtime.resource.loader.ResourceLoader
{
  public void init(ExtendedProperties configuration)
  {
  }

  public InputStream getResourceStream(String source)
    throws ResourceNotFoundException
  {
    InputStream result = null;
    if (StringHelper.isEmpty(source))
      throw new ResourceNotFoundException("template not defined");

    result = new ByteArrayInputStream(source.getBytes());
    return result;
  }

  public boolean isSourceModified(Resource resource)
  {
    return false;
  }

  public long getLastModified(Resource resource)
  {
    return 0L;
  }
}