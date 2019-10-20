package com.company.demo.controller;

import java.io.IOException;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.apache.solr.client.solrj.SolrQuery;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.client.solrj.response.QueryResponse;
import org.apache.solr.common.SolrDocumentList;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.company.demo.client.SolrJDriver;
import com.company.demo.dto.Article;
import com.company.demo.service.ArticleService;

@Controller
public class ArticleController {
	@Autowired
	ArticleService articleService;
	@Autowired
	SolrJDriver solrJDriver;
	
	@RequestMapping("/article/search1")
	public String searchArticle(Model model, @RequestParam Map<String,Object> param) {
		
		List<Article> articles = articleService.getArticles(param);
		
		model.addAttribute("articles", articles);
		
		return "article/search";
	}
	
	public static String escapeSpecialChar(String str){       
	      String match = "[^\uAC00-\uD7A3xfe0-9a-zA-Z\\s]";
	      str =str.replaceAll(match, "");
	      return str;
	   }
	
	@RequestMapping("/article/search")
	public String getArticle(Model model, @RequestParam Map<String,Object> param) throws SolrServerException, IOException {
		
		param.put("q", escapeSpecialChar((String)param.get("q")));
		
		if (param.containsKey("guide")) {
			model.addAttribute("guide", "true");
			return "article/search";
		}
		
		QueryResponse queryResponse = getSolrResponse(param);
		
	    DecimalFormat formatter = new DecimalFormat("###,###");
	 
	    model.addAttribute("q", (String)param.get("q"));
		model.addAttribute("listSize", formatter.format(getSolrData(queryResponse).getNumFound()));
		  
		return "article/search";
	}
	
	@RequestMapping("/article/getSearchList")
	@ResponseBody
	public JSONArray getSearchList(@RequestParam Map<String,Object> param) throws SolrServerException, IOException {
	
		param.put("q", escapeSpecialChar((String)param.get("q")));
		
		QueryResponse queryResponse = getSolrResponse(param);
	    SolrDocumentList docList = getSolrData(queryResponse);
	    Map<String, Map<String, List<String>>> snippets = getHighlighting(queryResponse);
	    
	    JSONArray results = new JSONArray();
	    
	    SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm");
	    
	    for(Map<String,Object> singleDoc : docList)
	    { 
	    
	    	JSONObject jsonObject = new JSONObject();
			
	        for( Map.Entry<String, Object> entry : singleDoc.entrySet() ) {
	        	
	            String key = entry.getKey();
	            Object value = entry.getValue();
	            
	            jsonObject.put(key, value);
	            
	            if (key.equals("article_id") && snippets.get((String)value).get("body") != null) {
	            	
	            	//관련 키워드의 첫 문단
	            	String snippetsBody = snippets.get((String)value).get("body").get(0);
	            	jsonObject.put("snippetsBody",snippetsBody);
	            }
	            
	            if (key.equals("regDate")) {
	            	String date = null;
					date = formatter.format((Date)value);
	            	
	            	jsonObject.put(key, date.toString());
	            }
	        }
	        results.add(jsonObject);
	    }
	    
		    System.out.println("article: " + results); //JSON 형식으로 사용가능
//		    System.out.println(docList); //Map 형식임
	   	    
	    
	    return results;
	  
	}
	
	public QueryResponse getSolrResponse(@RequestParam Map<String,Object> param) throws SolrServerException, IOException {
		
		String q = ((String)param.get("q")).trim();
		 
		  if(!"".equals(q)) {
			SolrQuery query = new SolrQuery();

	        
	        System.out.println(q);

			if (param.containsKey("searchType") && ((String)param.get("searchType")).trim().length() != 0) {

				System.out.println(q);

				query.setQuery((String)param.get("searchType") + ":" + q );
				
				System.out.println(query);
			} else {
				query.setQuery("title:" + q + " OR body:" + q);
			}
			
			if (param.containsKey("sort") && !param.get("sort").equals("")) {
				
				if (param.get("sort").equals("1")) {
					query.setSort("regDate",SolrQuery.ORDER.desc);
					
				} else if (param.get("sort").equals("2")) {
					query.setSort("regDate",SolrQuery.ORDER.asc);
				}
			}
			
			if (param.containsKey("period") && !param.get("period").equals("")) {
				SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
				
				if (param.get("period").equals("1")) {
					query.setFilterQueries("regDate:[NOW/DAY-1DAYS TO NOW]");
				}
				
				if (param.get("period").equals("7")) {
					query.setFilterQueries("regDate:[NOW/DAY-7DAYS TO NOW]");
				}
				
				if (param.get("period").equals("30")) {
					query.setFilterQueries("regDate:[NOW/MONTH-1MONTH TO NOW]");
				}
				
				if (param.get("period").equals("365")) {
					query.setFilterQueries("regDate:[NOW/YEAR-1YEAR TO NOW]");
				}
			}
						
			int cPage = 0;
			
			if (param.containsKey("cPage")) {
				try {
					cPage = Integer.parseInt((String)param.get("cPage"));
					
				} catch(Exception e) {
					return null;
				}
			} 
		
			query.setStart(cPage*10); // 0부터 10개, 10부터 10개
			query.setRows(10);
			
			query.setParam("hl.fl", "*");
			query.setHighlight(true).setHighlightSnippets(2);
			 
          QueryResponse responseSolr = solrJDriver.solr.query(".", query);
          
          return responseSolr;
          
		  }
		  return null;		
	}

	public SolrDocumentList getSolrData(QueryResponse responseSolr) {
		
        SolrDocumentList results = responseSolr.getResults();
	    
	    return results;
	}
	
	public Map getHighlighting(QueryResponse responseSolr) {
        Map<String, Map<String, List<String>>> snippets = responseSolr.getHighlighting();
        
        return snippets;
	}
}
