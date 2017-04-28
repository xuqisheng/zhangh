package com.aua.entity;

import java.io.Serializable;
import org.apache.commons.lang.builder.EqualsBuilder;
import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.commons.lang.builder.ToStringBuilder;

public abstract class BaseEntity
  implements Serializable
{
  private static final long serialVersionUID = 1495948146L;

  public int hashCode()
  {
    return HashCodeBuilder.reflectionHashCode(this);
  }

  public boolean equals(Object obj)
  {
    return EqualsBuilder.reflectionEquals(this, obj);
  }

  public String toString()
  {
    return ToStringBuilder.reflectionToString(this);
  }
}