package com.aua.util;

import java.io.Serializable;
import java.util.List;

public class Container<T>
  implements Serializable
{
  private static final long serialVersionUID = -936679158L;
  private int totalRows;
  private int firstResult;
  private int maxResults;
  private List<T> results;

  public int getTotalRows()
  {
    return this.totalRows; }

  public void setTotalRows(int totalRows) {
    this.totalRows = totalRows; }

  public int getFirstResult() {
    return this.firstResult;
  }

  public void setFirstResult(int firstResult) {
    this.firstResult = firstResult;
  }

  public int getMaxResults() {
    return this.maxResults;
  }

  public void setMaxResults(int maxResults) {
    this.maxResults = maxResults;
  }

  public List<T> getResults() {
    return this.results;
  }

  public void setResults(List<T> results) {
    this.results = results;
  }
}