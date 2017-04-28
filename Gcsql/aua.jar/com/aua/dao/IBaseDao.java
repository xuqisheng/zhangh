package com.aua.dao;

import com.aua.entity.BaseEntity;
import java.io.Serializable;
import java.util.Collection;
import java.util.List;
import org.hibernate.Filter;
import org.hibernate.LockMode;
import org.hibernate.ReplicationMode;
import org.springframework.dao.DataAccessException;

public abstract interface IBaseDao
{
  public abstract <T extends BaseEntity> T get(Class<T> paramClass, Serializable paramSerializable)
    throws DataAccessException;

  public abstract <T extends BaseEntity> T get(Class<T> paramClass, Serializable paramSerializable, LockMode paramLockMode)
    throws DataAccessException;

  public abstract <T extends BaseEntity> List<T> loadAll(Class<T> paramClass)
    throws DataAccessException;

  public abstract <T extends BaseEntity> T load(Class<T> paramClass, Serializable paramSerializable)
    throws DataAccessException;

  public abstract <T extends BaseEntity> T load(Class<T> paramClass, Serializable paramSerializable, LockMode paramLockMode)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void lock(T paramT, LockMode paramLockMode)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void lock(String paramString, T paramT, LockMode paramLockMode)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void refresh(T paramT)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void refresh(T paramT, LockMode paramLockMode)
    throws DataAccessException;

  public abstract <T extends BaseEntity> boolean contains(T paramT)
    throws DataAccessException;

  public abstract void evict(Object paramObject)
    throws DataAccessException;

  public abstract void initialize(Object paramObject)
    throws DataAccessException;

  public abstract <T extends BaseEntity> Serializable save(T paramT)
    throws DataAccessException;

  public abstract <T extends BaseEntity> Serializable save(String paramString, T paramT)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void update(T paramT)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void update(T paramT, LockMode paramLockMode)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void update(String paramString, T paramT)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void update(String paramString, T paramT, LockMode paramLockMode)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void saveOrUpdate(T paramT)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void saveOrUpdate(String paramString, T paramT)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void saveOrUpdateAll(Collection<T> paramCollection)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void replicate(T paramT, ReplicationMode paramReplicationMode)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void replicate(String paramString, T paramT, ReplicationMode paramReplicationMode)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void persist(T paramT)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void persist(String paramString, T paramT)
    throws DataAccessException;

  public abstract Filter enableFilter(String paramString)
    throws IllegalStateException;

  public abstract <T extends BaseEntity> T merge(T paramT)
    throws DataAccessException;

  public abstract <T extends BaseEntity> T merge(String paramString, T paramT)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void delete(T paramT)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void delete(T paramT, LockMode paramLockMode)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void delete(String paramString, T paramT)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void delete(String paramString, T paramT, LockMode paramLockMode)
    throws DataAccessException;

  public abstract <T extends BaseEntity> void deleteAll(Collection<T> paramCollection)
    throws DataAccessException;

  public abstract void flush()
    throws DataAccessException;

  public abstract void clear()
    throws DataAccessException;
}