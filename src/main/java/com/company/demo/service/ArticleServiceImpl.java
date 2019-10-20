package com.company.demo.service;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import org.apache.solr.client.solrj.SolrClient;
import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocumentList;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.company.demo.dto.Article;
import com.company.demo.repository.SolrArticleRepository;

@Service
public class ArticleServiceImpl implements ArticleService{
	@Autowired
	SolrClient solrClient;
	@Autowired
	SolrArticleRepository solrArticleRepo;
	 
    @Override
    public List<Article> getArticles(Map<String,Object> param) {
    	
    	SolrQuery query = new SolrQuery();
    	query.set("*", "*");
    	
    	QueryResponse response = null;
    	
    	try {
			response = solrClient.query(query);
			
		} catch (SolrServerException e) {
			e.printStackTrace();
			
		} catch (IOException e) {
			e.printStackTrace();
		}
    	
    	List<Article> articles = response.getBeans(Article.class);
    	
    	System.out.println(response);
    	
    	return null;
    	
        //return solrArticleRepo.getArticles((String)param.get("keyword"));
    }
    
}
