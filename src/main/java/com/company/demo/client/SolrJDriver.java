package com.company.demo.client;

import org.apache.solr.client.solrj.SolrClient;
import org.apache.solr.client.solrj.impl.HttpSolrClient;
import org.springframework.stereotype.Component;

@Component
public class SolrJDriver {
	 public static String url = "http://localhost:8983/solr/article";
	 public static SolrClient solr = new HttpSolrClient.Builder(url).build();
}
