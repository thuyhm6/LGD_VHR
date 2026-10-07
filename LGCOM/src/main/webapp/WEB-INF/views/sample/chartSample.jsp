<%@ page language="java"  pageEncoding="utf-8"%>
<%---------------------------------------------------------
    파일명 : chartSample.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : Chart Sample
    작성자 : wcfw
-------------------------------------------------------------%>
<!DOCTYPE html>
<html lang="ko">
<head>
<title>Chart</title>
<meta http-equiv="x-ua-compatible" content="IE=edge">
<%@ include file="/WEB-INF/views/framework/header.jsp" %>
<script type="text/javascript">
$(function() {
	var chart;

	transaction('lgcom','',{},function(data) {
		//chart.options.series();
		//$('#chartPanel').highcharts({
		//});
		chart = new Highcharts.Chart({
			chart: {
				plotBackgroundColor: null,
				plotBorderWidth: null,
				plotShadow: false,
				type: 'pie'
			},
			title: {
				text: null
			},
			tooltip: {
				pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
			},
			plotOptions: {
				pie: {
					allowPointSelect: true,
					cursor: 'normal',
					dataLabels: {
						enabled: false
					},
					showInLegend: true
				}
			},
			legend: {
				align: 'left',
				verticalAlign: 'middle',
				layout: 'vertical'
			},
			credits: {
				enabled: false
			}
		});
	});
});
</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Chart Samle</h2>
	</div>
	<div class="content">
		<div class="panel panel-default uxp-example">
			<div class="panel-body">
				<div id="chartPanel" style="min-width: 310px; max-width: 400px; height: 290px; margin: 0 auto"></div>
			</div>
			<!-- /panel-body -->
		</div>
		<!-- /panel -->
	</div>
	</section>
</div>
</body>
</html>
