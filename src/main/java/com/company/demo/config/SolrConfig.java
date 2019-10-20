package com.company.demo.config;

import javax.annotation.Resource;

import org.apache.solr.client.solrj.SolrClient;
import org.apache.solr.client.solrj.impl.HttpSolrClient;
import org.apache.solr.client.solrj.impl.XMLResponseParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.solr.repository.config.EnableSolrRepositories;

@Configuration
public class SolrConfig {
	
//	@Bean
//    public SolrClient solrClient() {
//		
//		String urlString = "http://localhost:8983/solr/article";
//		
//		HttpSolrClient solr = new HttpSolrClient.Builder(urlString).build();
//		solr.setParser(new XMLResponseParser());
//		
//		return solr;
//    }


}
//
//@Configuration
//@EnableSolrRepositories(basePackages = "com.baeldung.spring.data.solr.repository", namedQueriesLocation = "classpath:solr-named-queries.properties", multicoreSupport = true)
//@ComponentScan
//public class SolrConfig {
//
//    @Bean
//    public SolrClient solrClient() {
//        return new HttpSolrClient("http://localhost:8983/solr");
//    }
//
//    @Bean
//    public SolrTemplate solrTemplate(SolrClient client) throws Exception {
//        return new SolrTemplate(client);
//    }
//}