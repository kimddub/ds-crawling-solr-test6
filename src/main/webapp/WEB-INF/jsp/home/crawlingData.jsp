<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="com.company.demo.dto.Site"%>
<%@ page import="com.company.demo.dto.Category"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<c:set var="title" value="데이터 수집 조회"/>
<%@ include file="../part/header.jspf"%>

<style>
	#chartdiv {
	  width: 90%;
	  height: 500px;
	}
	
	#search_form {
		margin:10px;
		text-align:center;
/* 		background-color:#E6E6FA; */
/* 		padding:20px; */
	}
	
	select {
		width:200px;
		padding:10px;
		border-radius:5px;
	}
	
	#search_btn {
		border:none;
		background-color:#191970;
		color:white; 
		padding:10px 15px;
	}
	
	#comment {
		color:darkgray;
		font-style:oblique;
		font-weight:bold;
		font-size:15px;
	}
	
	.pop-up {
 		display:none; 
		position:absolute;
		top:70%;
		left:50%;
		transform:translateY(-50%) translateX(-50%);
		width:500px;
		height:250px;
		background-color:darkgray;
		text-align:center;
		line-height: 200px;
		opacity: 0.3;
	}
</style>

<!-- Resources -->
<script src="https://www.amcharts.com/lib/4/core.js"></script>
<script src="https://www.amcharts.com/lib/4/charts.js"></script>
<script src="https://www.amcharts.com/lib/4/themes/animated.js"></script>

<!-- Chart code -->
<script>
	function Crawling__siteChanged(el) {
	    var $el = el;
	    var newValue = $el.value;
	
	
	    if (newValue.length == 0 || newValue == '') {
	
	    	return false;
		}
	
	    $.post( 
			"/home/getCategoryList",  
			{
				"siteCode" : newValue
			},
			function( categoryList ) {
				var $categoryBox = $('select[name="categoryCode"]');
				$categoryBox.empty();
				$categoryBox.append('<option value="0">카테고리 > ALL</option>');
				
				var $categoryList = JSON.parse(categoryList);
				
				if ($categoryList.length == 0) {
					alert("카테고리 목록이 없습니다.");
					return false;
				}

				$categoryList.forEach(function(category) {
					
					$categoryBox.append('<option value="' + category.code + '" >'
										+ category.section + '>' + category.subSection
										+ '</option>');
				});

			},
			"html"
		);
	}

	function getCrawlingData() {
		var $popUp = $('.pop-up');
		$popUp.css('display','none');
		
		var siteCode = $('select[name="siteCode"]').val().trim();
		var categoryCode = $('select[name="categoryCode"]').val().trim();
		var mediaCode = $('select[name="mediaCode"]').val().trim();

		//alert(siteCode + ", " + categoryCode + ", " + mediaCode);
		
		$.post( 
			"/home/getCrawlingData",  
			{
				"siteCode":siteCode,
				"categoryCode":categoryCode,
				"mediaCode":mediaCode
			},
			function( dataList ) {
				
				var JSONList = JSON.parse(dataList);

				// 가져올 차트 없으면 이전 차트도 지워버릴지?
				
				if (JSONList.length == 0) {
					alert("크롤링 정보가 없습니다.");

					$popUp.css('display','block');
					
				} else {

					drawChart(JSONList); // 가져올 차트 없으면 그냥 둘지
				}

				
			},
			"html"
		);
	}

	function drawChart(dataList) {
		
		// Themes begin
		am4core.useTheme(am4themes_animated);
		// Themes end
		
		// Create chart
		var chart = am4core.create("chartdiv", am4charts.XYChart);
		chart.paddingRight = 20;

		chart.data = dataList;
		
		var dateAxis = chart.xAxes.push(new am4charts.DateAxis());
		dateAxis.baseInterval = {
		  "timeUnit": "minute",
		  "count": 1
		};
		dateAxis.tooltipDateFormat = "HH:mm, d MMMM";
		
		var valueAxis = chart.yAxes.push(new am4charts.ValueAxis());
		valueAxis.tooltip.disabled = true;
		valueAxis.title.text = "Unique visitors";
		
		var series = chart.series.push(new am4charts.LineSeries());
		series.dataFields.dateX = "timeZone";
		series.dataFields.valueY = "count";
		series.tooltipText = "count: [bold]{valueY}[/]";
		series.fillOpacity = 0.3;
		
		
		chart.cursor = new am4charts.XYCursor();
		chart.cursor.lineY.opacity = 0;
		chart.scrollbarX = new am4charts.XYChartScrollbar();
		chart.scrollbarX.series.push(series);
		
		
		chart.events.on("datavalidated", function () {
		    dateAxis.zoom({start:0, end:1});
		});
	}
</script>


	
	<div class="pop-up">
		<h1>데이터가 없습니다.</h1>
	</div>


	<form id="search_form" onsubmit="getCrawlingData(); return false;" method="GET">
	
		<select name="siteCode" onchange="Crawling__siteChanged(this);">
			<option value="0">사이트 > ALL</option>
			<c:forEach items="${siteList}" var="site">
				<option value="${site.code}">${site.site}</option>
			</c:forEach>
		</select>
		
		<select name="categoryCode" >
		
			<option value="0">카테고리 > All</option>
			
		</select>	
		
		<select name="mediaCode" >
			<option value="0">언론사 > ALL</option>
			<c:forEach items="${mediaList}" var="media">
				<option value="${media.code}">${media.name}</option>
			</c:forEach>
		</select>
		
		<input id="search_btn" type="submit" value="검색">
	</form>
	
	

	<h3 id="comment">검색 조건을 입력하고, 차트를 확인하세요!</h3>

	<div id="chartdiv"></div>



<%@ include file="../part/footer.jspf"%>