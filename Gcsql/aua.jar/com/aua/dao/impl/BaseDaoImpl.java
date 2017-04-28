package com.aua.dao.impl;

import com.aua.dao.IBaseDao;
import com.aua.entity.BaseEntity;
import com.aua.jdbc.core.JdbcTemplate;
import com.aua.orm.hibernate3.HibernateTemplate;
import com.aua.util.SQLHelper;
import java.io.Serializable;
import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Filter;
import org.hibernate.LockMode;
import org.hibernate.ReplicationMode;
import org.hibernate.SessionFactory;
import org.hibernate.criterion.DetachedCriteria;
import org.springframework.dao.DataAccessException;

public class BaseDaoImpl
  implements IBaseDao
{
  private HibernateTemplate hibernateTemplate;
  private JdbcTemplate jdbcTemplate;
  protected static Log log = LogFactory.getLog(BaseDaoImpl.class);

  public void setSessionFactory(SessionFactory sessionFactory)
  {
    this.hibernateTemplate = new HibernateTemplate(sessionFactory); }

  public HibernateTemplate getHibernateTemplate() {
    return this.hibernateTemplate; }

  public JdbcTemplate getJdbcTemplate() {
    return this.jdbcTemplate;
  }

  public void setJdbcTemplate(JdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }

  public void setHibernateTemplate(HibernateTemplate hibernateTemplate) {
    this.hibernateTemplate = hibernateTemplate;
  }

  public <T extends BaseEntity> T get(Class<T> entityClass, Serializable id) throws DataAccessException {
    return get(entityClass, id, null);
  }

  public <T extends BaseEntity> T get(Class<T> entityClass, Serializable id, LockMode lockMode) {
    return ((BaseEntity)this.hibernateTemplate.get(entityClass, id, lockMode));
  }

  public <T extends BaseEntity> List<T> loadAll(Class<T> entityClass) throws DataAccessException {
    return this.hibernateTemplate.loadAll(entityClass);
  }

  public <T extends BaseEntity> T load(Class<T> entityClass, Serializable id) throws DataAccessException {
    return load(entityClass, id, null);
  }

  public <T extends BaseEntity> T load(Class<T> entityClass, Serializable id, LockMode lockMode) throws DataAccessException {
    return ((BaseEntity)this.hibernateTemplate.load(entityClass, id, lockMode));
  }

  public <T extends BaseEntity> void lock(T entity, LockMode lockMode) throws DataAccessException {
    this.hibernateTemplate.lock(entity, lockMode);
  }

  public <T extends BaseEntity> void lock(String entityName, T entity, LockMode lockMode) throws DataAccessException
  {
    this.hibernateTemplate.lock(entityName, entity, lockMode);
  }

  public <T extends BaseEntity> void refresh(T entity) throws DataAccessException {
    this.hibernateTemplate.refresh(entity);
  }

  public <T extends BaseEntity> void refresh(T entity, LockMode lockMode) throws DataAccessException {
    this.hibernateTemplate.refresh(entity, lockMode);
  }

  public <T extends BaseEntity> boolean contains(T entity) throws DataAccessException {
    return this.hibernateTemplate.contains(entity);
  }

  public void evict(Object object) throws DataAccessException {
    this.hibernateTemplate.evict(object);
  }

  public void initialize(Object proxy) throws DataAccessException {
    this.hibernateTemplate.initialize(proxy);
  }

  public <T extends BaseEntity> Serializable save(T entity) throws DataAccessException {
    return this.hibernateTemplate.save(entity);
  }

  public <T extends BaseEntity> Serializable save(String entityName, T entity) throws DataAccessException {
    return this.hibernateTemplate.save(entityName, entity);
  }

  public <T extends BaseEntity> void update(T entity) throws DataAccessException {
    this.hibernateTemplate.update(entity);
  }

  public <T extends BaseEntity> void update(T entity, LockMode lockMode) throws DataAccessException {
    this.hibernateTemplate.update(entity, lockMode);
  }

  public <T extends BaseEntity> void update(String entityName, T entity) throws DataAccessException {
    this.hibernateTemplate.update(entityName, entity);
  }

  public <T extends BaseEntity> void update(String entityName, T entity, LockMode lockMode) throws DataAccessException
  {
    this.hibernateTemplate.update(entityName, entity, lockMode);
  }

  public <T extends BaseEntity> void saveOrUpdate(T entity) throws DataAccessException {
    this.hibernateTemplate.saveOrUpdate(entity);
  }

  public <T extends BaseEntity> void saveOrUpdate(String entityName, T entity) throws DataAccessException {
    this.hibernateTemplate.saveOrUpdate(entityName, entity);
  }

  public <T extends BaseEntity> void saveOrUpdateAll(Collection<T> entities) throws DataAccessException {
    this.hibernateTemplate.saveOrUpdateAll(entities);
  }

  public <T extends BaseEntity> void replicate(T entity, ReplicationMode replicationMode) throws DataAccessException {
    this.hibernateTemplate.replicate(entity, replicationMode);
  }

  public <T extends BaseEntity> void replicate(String entityName, T entity, ReplicationMode replicationMode) throws DataAccessException
  {
    this.hibernateTemplate.replicate(entityName, entity, replicationMode);
  }

  public <T extends BaseEntity> void persist(T entity) throws DataAccessException {
    this.hibernateTemplate.persist(entity);
  }

  public <T extends BaseEntity> void persist(String entityName, T entity) throws DataAccessException {
    this.hibernateTemplate.persist(entityName, entity);
  }

  public <T extends BaseEntity> T merge(T entity) throws DataAccessException {
    return ((BaseEntity)this.hibernateTemplate.merge(entity));
  }

  public <T extends BaseEntity> T merge(String entityName, T entity) throws DataAccessException {
    return ((BaseEntity)this.hibernateTemplate.merge(entityName, entity));
  }

  public <T extends BaseEntity> void delete(T entity) throws DataAccessException {
    this.hibernateTemplate.delete(entity);
  }

  public <T extends BaseEntity> void delete(T entity, LockMode lockMode) throws DataAccessException {
    this.hibernateTemplate.delete(entity, lockMode);
  }

  public <T extends BaseEntity> void delete(String entityName, T entity) throws DataAccessException {
    this.hibernateTemplate.delete(entityName, entity);
  }

  public <T extends BaseEntity> void delete(String entityName, T entity, LockMode lockMode) throws DataAccessException
  {
    this.hibernateTemplate.delete(entityName, entity, lockMode);
  }

  public <T extends BaseEntity> void deleteAll(Collection<T> entities) throws DataAccessException {
    this.hibernateTemplate.deleteAll(entities);
  }

  public Filter enableFilter(String filterName) throws IllegalStateException {
    return this.hibernateTemplate.enableFilter(filterName);
  }

  public void flush() throws DataAccessException {
    this.hibernateTemplate.flush();
  }

  public void clear() throws DataAccessException {
    this.hibernateTemplate.clear();
  }

  protected <T> List<T> find(String queryString) throws DataAccessException {
    return find(queryString, null);
  }

  protected <T> List<T> find(String queryString, Object value) throws DataAccessException {
    return find(queryString, new Object[] { value });
  }

  protected <T> List<T> find(String queryString, Object[] values) throws DataAccessException
  {
    return this.hibernateTemplate.find(queryString, values);
  }

  protected <T> List<T> findByValueBean(String queryString, Object valueBean) throws DataAccessException
  {
    return this.hibernateTemplate.findByValueBean(queryString, valueBean);
  }

  protected <T> List<T> findByNamedQueryAndNamedParam(String queryName, String paramName, Object value) throws DataAccessException
  {
    return findByNamedQueryAndNamedParam(queryName, new String[] { paramName }, new Object[] { value });
  }

  protected <T> List<T> findByNamedQueryAndNamedParam(String queryName, String[] paramNames, Object[] values)
    throws DataAccessException
  {
    return this.hibernateTemplate.findByNamedQueryAndNamedParam(queryName, paramNames, values);
  }

  protected <T> List<T> findByNamedQueryAndValueBean(String queryName, Object valueBean) throws DataAccessException
  {
    return this.hibernateTemplate.findByNamedQueryAndValueBean(queryName, valueBean);
  }

  protected <T> List<T> findByCriteria(DetachedCriteria criteria) throws DataAccessException {
    return findByCriteria(criteria, -1, -1);
  }

  protected <T> List<T> findByCriteria(DetachedCriteria criteria, int firstResult, int maxResults)
    throws DataAccessException
  {
    return this.hibernateTemplate.findByCriteria(criteria, firstResult, maxResults);
  }

  protected <T> List<T> findByExample(Object exampleEntity) throws DataAccessException {
    return findByExample(null, exampleEntity, -1, -1);
  }

  protected <T> List<T> findByExample(String entityName, Object exampleEntity) throws DataAccessException {
    return findByExample(entityName, exampleEntity, -1, -1);
  }

  protected <T> List<T> findByExample(Object exampleEntity, int firstResult, int maxResults) throws DataAccessException {
    return findByExample(null, exampleEntity, firstResult, maxResults);
  }

  protected <T> List<T> findByExample(String entityName, Object exampleEntity, int firstResult, int maxResults) throws DataAccessException
  {
    return findByExample(entityName, exampleEntity, firstResult, maxResults);
  }

  protected <T> List<T> findByNamedParam(String queryString, String paramName, Object value) {
    return findByNamedParam(queryString, new String[] { paramName }, new Object[] { value });
  }

  protected <T> List<T> findByNamedParam(String queryString, String[] paramNames, Object[] values)
  {
    return this.hibernateTemplate.findByNamedParam(queryString, paramNames, values);
  }

  protected <T> List<T> findByNamedQuery(String queryName) throws DataAccessException {
    return findByNamedQuery(queryName, null);
  }

  protected <T> List<T> findByNamedQuery(String queryName, Object value) throws DataAccessException {
    return findByNamedQuery(queryName, new Object[] { value });
  }

  protected <T> List<T> findByNamedQuery(String queryName, Object[] values) throws DataAccessException
  {
    return this.hibernateTemplate.findByNamedQuery(queryName, values);
  }

  protected <T> Iterator<T> iterate(String queryString) throws DataAccessException {
    return iterate(queryString, null);
  }

  protected <T> Iterator<T> iterate(String queryString, Object value) throws DataAccessException {
    return iterate(queryString, new Object[] { value });
  }

  protected <T> Iterator<T> iterate(String queryString, Object[] values) throws DataAccessException
  {
    return this.hibernateTemplate.iterate(queryString, values);
  }

  protected <T> void closeIterator(Iterator<T> it) throws DataAccessException {
    this.hibernateTemplate.closeIterator(it);
  }

  protected int bulkUpdate(String queryString) throws DataAccessException {
    return this.hibernateTemplate.bulkUpdate(queryString);
  }

  protected int bulkUpdate(String queryString, Object value) throws DataAccessException {
    return this.hibernateTemplate.bulkUpdate(queryString, value);
  }

  protected int bulkUpdate(String queryString, Object[] values) throws DataAccessException {
    return this.hibernateTemplate.bulkUpdate(queryString, values);
  }

  protected <T> List<T> findByNativeSQL(SQLHelper sh, Class<T> clazz) throws DataAccessException {
    return this.hibernateTemplate.findByNativeSQL(sh, clazz);
  }

  protected <T> List<T> findByNativeSQL(SQLHelper sh) throws DataAccessException {
    return findByNativeSQL(sh, null);
  }

  protected int countByNativeSQL(SQLHelper sh) throws DataAccessException {
    return this.hibernateTemplate.countByNativeSQL(sh);
  }

  protected int bulkUpdateByNativeSQL(SQLHelper sh) {
    return this.hibernateTemplate.bulkUpdateByNativeSQL(sh);
  }

  protected <T> List<T> find(SQLHelper sh) throws DataAccessException {
    return find(sh, null);
  }

  protected <T> List<T> find(SQLHelper sh, Class<T> clazz) throws DataAccessException {
    return this.hibernateTemplate.find(sh, clazz);
  }

  protected int count(SQLHelper sh) throws DataAccessException {
    return this.hibernateTemplate.count(sh);
  }

  protected int bulkUpdate(SQLHelper sh) throws DataAccessException {
    return this.hibernateTemplate.bulkUpdate(sh);
  }
}