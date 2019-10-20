<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="com.company.demo.dto.Site"%>
<%@ page import="com.company.demo.dto.Category"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<c:set var="title" value="검색"/>
<%@ include file="../part/header.jspf"%>

<style>

	#search-form-2 .search-bar {
		width:55%;
		border:4px solid #2196F3;
		border-radius:5px;
		outline:none;
		padding:10px;
		margin:0 auto;
	}
	
	#search-form-2 .search-bar {
	  height: 44px;
	  border-radius: 40px;
	  display: flex;
	  align-items: center;
	  padding: 0 0 0 20px;
	  position: relative;
	  background: #fff;
	}
	
	#search-form-2 .search-bar .input {
	  border: none;
	  height: 25px;
	  width:80%;
	  color: #1b1b1b;
	  font-size: 15px;
	  outline: none;
	}
	
	.article-title {
		font-size:20px;
		border-left:5px solid black;
		cursor:pointer;
	}
	
	.article-title:hover .title {
		text-decoration:underline;
	}
	
	.article-title .side-info {
		font-size:13px;
		font-style:oblique;
		color:darkgray;
	}
	
	.article-body {
		font-size:15px;
	}
	
	.condi {
		height:70px;
		margin:30px auto;
		padding:0 30px;
		text-align:center;
		border-top:1px solid darkgray;
		border-bottom:1px solid darkgray;
	}
	
	.condi .cell{
		width:33.333%;
		padding:10px 20px;
	}
	
	.condi a {
		border:2px solid skyblue;
		border-radius:10px;
		padding:0 3px;
		margin:0 2px;
		conf-size:9px;
	}
	
	.condi a:hover {
		background-color: skyblue;
		color:white;
		font-weight:bold;
	}
	
	.condi input{
	  visibility: hidden;
	  height: 0;
	  width: 0;
	}
	
	.condi label {
	  vertical-align: middle;
	  text-align: center;
	  cursor: pointer;
		border:2px solid skyblue;
		border-radius:10px;
		padding:0 3px;
		margin:0 2px;
		conf-size:9px;
	  .transition;
	}
	.condi input:checked + label{
	  	background-color: skyblue;
		color:white;
		font-weight:bold;
	}
	
	.search-info {
		text-align:left;
		padding:0 50px;
	}
	
	.search-info .search-result {
		color:darkgray;
	}
	
	em { 
		font-weight: bold; 
		font-style:normal;
	}
	
	#showMoreBtn {
		margin:0 auto; 
		width:200px; 
		height:50px; 
		border:1px solid skyblue;
		border-radius:5px;
		color:skyblue;
		cursor:pointer;
		box-sizing:border-box;
	}
	
	#showMoreBtn:hover {
		border:2px solid skyblue;
	}
</style>

<script>
	var cPage = 1;

	var cListSize = 0;

	$(function() {
		getSearchList(0);
		
		cListSize += $('tr.article-title').length;
		$('#cListSize').empty();
		$('#cListSize').append(cListSize);
	});

	function showMoreBtnobserver() {
		$('#cListSize').empty();
		$('#cListSize').append(cListSize);
		
		if (${listSize} <= cListSize) {

			$('#showMoreBtn').remove();
		}
	}

	function setSearchType(el) {
		var newValue = $(el).val();

		var newUrl = getNoDomainUrl();
	    newUrl = replaceUrlParam(newUrl, 'searchType', newValue);
	    newUrl = replaceUrlParam(newUrl, 'q', "${q}");
	    
	    location.href = newUrl;
	}

	function setSort(el) {
		var newValue = $(el).val();

		var newUrl = getNoDomainUrl();
	    newUrl = replaceUrlParam(newUrl, 'sort', newValue);
	    newUrl = replaceUrlParam(newUrl, 'q', "${q}");
	    
	    location.href = newUrl;
	}

	function setPeriod(el) {
		var newValue = $(el).val();

		var newUrl = getNoDomainUrl();
		
	    newUrl = replaceUrlParam(newUrl, 'period', newValue);
	    newUrl = replaceUrlParam(newUrl, 'q', "${q}");
	    
	    location.href = newUrl;
	}

	function doSearch2() {
		var $form = $('#search-form-2'); 
	
		//폼체크
		var keyword = $form.find('.input').val().trim();

		
		if (keyword.length == 0) {
			return false;
		}

		$form.submit();
	}

	function resetOptionSearch() {
		
		$('input[name="searchType"]:checked').attr("checked",false);
		$('input[name="searchType"][value=""]').attr("checked",true);

		$('input[name="sort"]:checked').attr("checked",false);
		$('input[name="sort"][value=""]').attr("checked",true);

		$('input[name="period"]:checked').attr("checked",false);
		$('input[name="period"][value=""]').attr("checked",true);

		
	}

	function showMore() {
		getSearchList(cPage++);
	}

	function getSearchList(page) {
		
		$.post(
				"../article/getSearchList",  
				{"q" : "${q}",
				"searchType" : "${param.searchType}",
				"sort" : "${param.sort}",
				"period" : "${param.period}",
				"cPage" : page},
				function(data) {
					
					if ($(data).length == 0) {
// 						alert("기사가 없습니다.");
						$('#showMoreBtn').remove();
					}

					cListSize += $(data).length;
					showMoreBtnobserver();
					
					var $articleBody = $('.article-box table tbody');
					var html = "";
					
					var listview = $(data);

					$.each(listview, function(entryIndex, entry) {
						var webPath = entry.webPath;
						var title = entry.title;
						var media = entry.media;
						var date = entry.regDate;
						var site = entry.site;
						var section = entry.section1; //배열
// 						var body = entry.body.length > 150 ? entry.body.substring(0,150) + '...' : entry.body;
						var snippetsBody = entry.snippetsBody != null? entry.snippetsBody : entry.body.length > 150 ? entry.body.substring(0,150) + '...' : entry.body;
						
						html += `</br>
							<tr class="article-title space" onclick="window.open('` + webPath + `', '_blank');">
							<th>
								<span class="title">` + title + `</span></br> 
								<span class="side-info article-media">` + media + `&nbsp;│</span> 
								<span class="side-info article-date">` + date + `&nbsp;│</span>
								<span class="side-info article-section">` + site + `&nbsp;>&nbsp;</span>
								<span class="side-info article-section">` + section + `
								</span>
							</th>
						</tr>
						<tr class="article-body">
							<td>
								<p>...` + snippetsBody + `...</p>
							</td>
						</tr>`;

					});

					$articleBody.append(html);	
				},
				"json").fail(function(jqXHR) { //if null
					alert("기사 정보를 업데이트 할 수 없습니다.");
				});

// 					.done(function(jqXHR) {
// 					    alert("second success" );
// 					})
// 					.fail(function(jqXHR) {
// 					    alert("error" );
// 					})
// 					.always(function(jqXHR) {
// 					    alert("finished" );
// 					});
		
		
	}
</script>

	<form id="search-form-2" action="./search" method="POST">		
		<div class="search-bar">
			<input type="text" name="q" class="input" placeholder="검색어를 입력하세요"  value="${q}">
			<div class="search-btn" onclick="doSearch2();">
			    <svg class="icon icon-18">
			      <use xlink:href="#magnify"></use>
			     </svg>
			</div>
		</div>
		
		<div class="condi">
			<nav class="row">
				<div class="cell condi-1">
					<h5>검색범위</h5>
					
					<input onchange="setSearchType(this);" type="radio" name="searchType" id="searchType1" value="" checked /><label for="searchType1">전체</label>
					  
					<input onchange="setSearchType(this);" type="radio" name="searchType" id="searchType2" value="title" /><label for="searchType2">제목</label>
					  
					<input onchange="setSearchType(this);" type="radio" name="searchType" id="searchType3" value="body" /><label for="searchType3">내용</label>
					 
				</div>
				
				<c:if test="${param.searchType != null && param.searchType != '' }">
					<script>
						$('input[name="searchType"]:checked').attr("checked",false);
						$('input[name="searchType"][value="${param.searchType}"]').attr("checked",true);
					</script>
				</c:if>
				
				<div class="cell condi-2" >
					<h5>정렬</h5>
					<input onchange="setSort(this);" type="radio" name="sort" id="sort1" value="" checked /><label for="sort1">정확도순</label>
					  
					<input onchange="setSort(this);" type="radio" name="sort" id="sort2" value="1" /><label for="sort2">최신순</label>
					  
					<input onchange="setSort(this);" type="radio" name="sort" id="sort3" value="2" /><label for="sort3">오래된순</label>
				</div>
				
				<c:if test="${param.sort != null && param.sort != '' }">
					<script>
						$('input[name="sort"]:checked').attr("checked",false);
						$('input[name="sort"][value="${param.sort}"]').attr("checked",true);
					</script>
				</c:if>
				
				<div class="cell condi-3">
					<h5>검색기간</h5>
					<input onchange="setPeriod(this);" type="radio" name="period" id="period1" value="" checked /><label for="period1">전체</label>
					  
					<input onchange="setPeriod(this);" type="radio" name="period" id="period2" value="1" /><label for="period2">1일</label>
					
					<input onchange="setPeriod(this);" type="radio" name="period" id="period3" value="7" /><label for="period3">1주일</label>
					  
					<input onchange="setPeriod(this);" type="radio" name="period" id="period4" value="30" /><label for="period4">1개월</label>
					 
					<input onchange="setPeriod(this);" type="radio" name="period" id="period5" value="365" /><label for="period5">1년</label>
				</div>
				
				<c:if test="${param.period != null && param.period != '' }">
					<script>
						$('input[name="period"]:checked').attr("checked",false);
						$('input[name="period"][value="${param.period}"]').attr("checked",true);
					</script>
				</c:if>
			</nav>
		</div>
	</form>
	
	<div class="search-info">
		<span class="search-result">검색 결과 <span id="cListSize"></span>/<c:out value="${listSize}"/>개</span>
	</div>
	
	<c:if test="${listSize == '0'}">
		<span>'${q}'검색 결과가 없습니다</span>
	</c:if>
	
	<div class="con article-box">
		<table class="common-table">
			<colgroup>
				<col >
			</colgroup>
			
			<tbody>
			
<%-- 				<c:forEach items="${listview}" var="article"> --%>
<%-- 					<tr class="article-title space" onclick="window.open('${article.webPath}', '_blank');"> --%>
<!-- 						<th> -->
<%-- 							<span class="title">${article.title}</span></br>  --%>
<%-- 							<span class="side-info article-media">${article.media}&nbsp;│</span>  --%>
<%-- 							<span class="side-info article-date">${article.regDate}&nbsp;│</span> --%>
<%-- 							<span class="side-info article-section">${article.site}&nbsp;>&nbsp;</span> --%>
<!-- 							<span class="side-info article-section"> -->
<%-- 								<c:forEach items="${article.section1}" var="section">  --%>
<%-- 									${section} >${article.section2} --%>
<%-- 								</c:forEach> --%>
<!-- 							</span> -->
<!-- 						</th> -->
<!-- 					</tr> -->
<!-- 					<tr class="article-body"> -->
<!-- 						<td> -->
<%-- 							<p>...<c:out value='${article.snippetsBody}' escapeXml="false" />...</p> --%>
<%-- 							<c:choose> --%>
<%-- 						        <c:when test="${fn:length(article.body) gt 151}"> --%>
<%-- 							        <c:out value="${fn:substring(article.body, 0, 150)}"/>... --%>
							        
							        
<%-- 							    </c:when> --%>
<%-- 							    <c:otherwise> --%>
<%-- 							        <c:out value="${article.body}"/> --%>
<%-- 							    </c:otherwise> --%>
<%-- 							</c:choose> --%>
<!-- 						</td> -->
<!-- 					</tr> -->
<%-- 				</c:forEach> --%>
				
			</tbody>	
		</table>
		
		<section>
			<div id="showMoreBtn" onclick="showMore();" >Show More</br>▼</div>
		</section>
		
	</div>

<%@ include file="../part/footer.jspf"%>