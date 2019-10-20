<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<%@ page import="com.company.demo.dto.Site"%>
<%@ page import="com.company.demo.dto.Category"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<c:set var="title" value="이슈 키워드 조회"/>
<%@ include file="../part/header.jspf"%>
<!-- dateTimePicker -->

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datetimepicker/4.17.37/css/bootstrap-datetimepicker.min.css" />

<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.10.6/moment.min.js"></script>   
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.24.0/locale/fr.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>	
<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-datetimepicker/4.17.37/js/bootstrap-datetimepicker.min.js"></script>
	
<!-- amChart Resources -->
<script src="https://www.amcharts.com/lib/4/core.js"></script>
<script src="https://www.amcharts.com/lib/4/charts.js"></script>
<script src="https://www.amcharts.com/lib/4/plugins/forceDirected.js"></script>
<script src="https://www.amcharts.com/lib/4/themes/animated.js"></script>


<style>
	/*  폰트 적용 */
	@import url(//fonts.googleapis.com/earlyaccess/notosanskr.css);
		
	.body {
		background-color:#afafaf;
	}

	#chartdiv {
		margin:0 auto;
		width: 90%;
		height: 600px;v 
	}
	
	select {
		width: 200px;
	}
	
	#search_form .row {
		width:600px;
		margin:0 auto;
	}
	
	.row > div {
		width:300px;
		margin:0 auto;
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
	
	#condition_2 {
		margin:20px auto;
	}
	
	.date_term {
		top:40%;
		left:49.5%;
		font-size:15px;
	}
	
	#comment {
		color:darkgray;
		font-style:oblique;
		font-weight:bold;
		font-size:15px;
	}
	
	.pop-up {
		display: none;
		position: absolute;
		top: 50%;
		left: 50%;
		transform: translateY(-50%) translateX(-50%);
		width: 500px;
		height: 250px;
		background-color: darkgray;
		text-align: center;
		line-height: 200px;
		opacity: 0.3;
	}
	
</style>

<!-- <script -->
<!-- 	src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script> -->
	

<script>
	$(function () {
		$('#datetimepicker1').datetimepicker({
			format: 'YYYY-MM-DD'
		});
		$('#datetimepicker2').datetimepicker({
			format: 'YYYY-MM-DD'
		});
		$('#datetimepicker3').datetimepicker({
			format: 'LT'
		});
		$('#datetimepicker4').datetimepicker({
			format: 'LT'
		});

	});

	function Crawling__siteChanged(el) {
		var $el = el;
		var newValue = $el.value;

		if (newValue.length == 0 || newValue == '') {

			return false;
		}

		$.post("/home/getCategoryList", {
			"siteCode" : newValue
		}, function(categoryList) {
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

		}, "html");
	}

	function getAnalyzedData() {
// 		var $popUp = $('.pop-up');
// 		$popUp.css('display', 'none');

		var startDate = $('input[name="startDate"]').val().trim();
		var endDate = $('input[name="endDate"]').val().trim();
		var startTime = $('input[name="startTime"]').val().trim();
		var endTime = $('input[name="endTime"]').val().trim();

		var date_pattern = /^(19|20)\d{2}-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[0-1])$/; 

		if (!date_pattern .test(startDate)) {
			alert("조회 시작일자를 확인해주세요");
			return false;
		} 
		if (!date_pattern .test(endDate)) {
			alert("조회 종료일자를 확인해주세요");
			return false;
		}
		
		var time_pattern = /^(0[0-9]|1[0-9]|2[0-3]):([0-5][0-9])$/; 

		if(!time_pattern .test(startTime)){
			alert("조회 시작시간을 확인해주세요");
			return false;
		}

		if(!time_pattern .test(endTime)){
			alert("조회 종료시간을 확인해주세요");
			return false;
		}

		var siteCode = $('select[name="siteCode"]').val().trim();
		var categoryCode = $('select[name="categoryCode"]').val().trim();
		var mediaCode = $('select[name="mediaCode"]').val().trim();

// 		alert(siteCode + ", " + categoryCode + ", " + mediaCode);

		$.post("/home/getAnalyzedData", {
			"siteCode" : siteCode,
			"categoryCode" : categoryCode,
			"mediaCode" : mediaCode,
			"startDate" : startDate,
			"endDate" : endDate,
			"startTime" : startTime,
			"endTime" : endTime
		}, function(dataList) {

			var JSONList = JSON.parse(dataList);

			// 가져올 차트 없으면 이전 차트도 지워버릴지?

			if (JSONList.length == 0) {
				alert("크롤링 정보가 없습니다.");

				$popUp.css('display', 'block');

			} else {
// 				alert("크롤링 정보를 가져옵니다.");
				
				drawChart(JSONList); // 가져올 차트 없으면 그냥 둘지
			}

		}, "html");
	}

	function drawChart(dataList) {

		// Themes begin
		am4core.useTheme(am4themes_animated);
		// Themes end

		var chart = am4core.create("chartdiv", am4plugins_forceDirected.ForceDirectedTree);
		var networkSeries = chart.series.push(new am4plugins_forceDirected.ForceDirectedSeries())

		var data = []
		for(var i = 0; i < 15; i++){
		  data.push({name: "Node " + i, value:Math.random() * 50 + 10});
		}

		chart.data = dataList;

		networkSeries.dataFields.value = "frequency";
		networkSeries.dataFields.name = "word";
		networkSeries.dataFields.children = "children";
		networkSeries.nodes.template.tooltipText = "{word}:{frequency}";
		networkSeries.nodes.template.fillOpacity = 1;
		networkSeries.dataFields.id = "name";
		networkSeries.dataFields.linkWith = "linkWith";


		networkSeries.nodes.template.label.text = "{word}"
		networkSeries.fontSize = 20;

		var selectedNode;

		var label = chart.createChild(am4core.Label);
		label.text = "이슈 키워드 순위 50"
		label.x = 50;
		label.y = 50;
		label.isMeasured = false;


		networkSeries.nodes.template.events.on("up", function (event) {
		  var node = event.target;
		  if (!selectedNode) {
		    node.outerCircle.disabled = false;
		    node.outerCircle.strokeDasharray = "3,3";
		    selectedNode = node;
		  }
		  else if (selectedNode == node) {
		    node.outerCircle.disabled = true;
		    node.outerCircle.strokeDasharray = "";
		    selectedNode = undefined;
		  }
		  else {
		    var node = event.target;

		    var link = node.linksWith.getKey(selectedNode.uid);

		    if (link) {
		      node.unlinkWith(selectedNode);
		    }
		    else {
		      node.linkWith(selectedNode, 0.2);
		    }
		  }
		})

	}
</script>



<!-- 	<div class="pop-up"> -->
<!-- 		<h1>데이터가 없습니다.</h1> -->
<!-- 	</div> -->

	<form id="search_form" onsubmit="getAnalyzedData(); return false;" method="GET">

		<div id="condition_1">

			<select name="siteCode" onchange="Crawling__siteChanged(this);">
				<option value="0">사이트 > ALL</option>
				<c:forEach items="${siteList}" var="site">
					<option value="${site.code}">${site.site}</option>
				</c:forEach>
			</select> 
			
			<select name="categoryCode">

				<option value="0">카테고리 > All</option>

			</select> 
			
			<select name="mediaCode">
				<option value="0">언론사 > ALL</option>
				<c:forEach items="${mediaList}" var="media">
					<option value="${media.code}">${media.name}</option>
				</c:forEach>
			</select> <input id="search_btn" type="submit" value="검색">

		</div>

		<div id="condition_2">
		
			<div class="row relative">
				<div class='col-sm-4'>
					<div class="form-group">
						<div class='input-group date' id='datetimepicker1'>
							<input type='text' name="startDate" class="form-control" value="2019-10-10" /> <span
								class="input-group-addon"> <span
								class="glyphicon glyphicon-calendar"></span>
							</span> 
						</div>
					</div>
				</div>
				
				<span class="date_term absolute-middle"> ~ </span>
				
				<div class='col-sm-4'>
					<div class="form-group">
						<div class='input-group date' id='datetimepicker2'>
							<input type='text' name="endDate" class="form-control" value="2019-10-12"/> <span
								class="input-group-addon"> <span
								class="glyphicon glyphicon-calendar"></span>
							</span>
						</div>
					</div>
				</div>
			</div>

			<div class="row relative">
				<div class='col-sm-4'>
					<div class="form-group">
						<div class='input-group date' id='datetimepicker3'>
							<input type='text' name="startTime" class="form-control" value="00:00"/> <span
								class="input-group-addon"> <span
								class="glyphicon glyphicon-time"></span>
							</span>
						</div>
					</div>
				</div>
				
				<span class="date_term absolute-middle"> ~ </span>
				
				<div class='col-sm-4'>
					<div class="form-group">
						<div class='input-group date' id='datetimepicker4'>
							<input type='text' name="endTime" class="form-control"  value="24:00"/> <span
								class="input-group-addon"> <span
								class="glyphicon glyphicon-time"></span>
							</span>
						</div>
					</div>
				</div>
			</div>
		</div>

	</form>
	

	<h3 id="comment">검색 조건을 입력하고, 차트를 확인하세요!</h3>

	<div id="chartdiv"></div>

<%@ include file="../part/footer.jspf"%>