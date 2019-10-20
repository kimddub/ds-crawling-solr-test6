package com.company.demo.dto;

import java.util.Date;
import java.util.Map;

import org.apache.solr.client.solrj.beans.Field;
import org.springframework.data.annotation.Id;
import org.springframework.data.solr.core.mapping.Indexed;
import org.springframework.data.solr.core.mapping.SolrDocument;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Article {
	private int code;
	
	private String id;
	private int siteCode;
	private int mediaCode;
	private String webPath;
	private Date regDate;
	private Date colDate;
	
	private String title;
	
	private String body;
	
	private boolean analysisState;
	private Map<String,Object> extra;
}
