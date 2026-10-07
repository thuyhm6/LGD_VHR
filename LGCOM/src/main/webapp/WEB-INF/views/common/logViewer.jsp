<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%---------------------------------------------------------
	파일명 : logViewer.jsp
	프로젝트명 : LGD WCFW

	Copyright(c) 2017 LG CNS, All rights reserved.

	설 명 : 본 화면은 서버 로그 Tail을 확인하는 화면입니다.
	작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<style type="text/css">
.LogViewer .dataBlock .consolBlock {height:100%;}
.LogViewer .dataBlock .consolBlock .console {width:100%;height:100%;font-family:Consolas,monaco,monospace;font-size:12pt;color:#90ee90;background-color:#000;padding:5px;line-height:1.2em;}
</style>
<script type="text/javascript">
var LogViewer = function() {
	var myForm = this;
	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	/* 화면 레이아웃 정의 */
	myForm.setManagedLayout({
		searchBlock : { left:0, top:0 , right:0 },
		dataBlock   : { left:0, top:SINGLE_LINE.top1, right:0, bottom:0 }
	});
	// 로그구분
	var logList = [];
	var logTypeCombo = JSON.parse('${logType}');
	$(logTypeCombo).each(function() {
		logList.push(this);
	});
	formUtil.initCombo('logPos',logList);
	// 시스템 코드 Combo
	var code = new CommonCode('lgcom');
	code.execute('system',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_SYSTEM_CODE'});
	formUtil.initCombo('systemCode',code.get('system'),{selectAll:false,selectEmpty:false});
	// 로그 Tailling을 위한 timer 변수
	var timer;
	// 버튼 이벤트
	myForm.addEvent('click',".searchBlock button[data-action]", function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			case 'start':
				formUtil.setValue({
					tailFlag: 'Y',
					pEndPoint: 0
				});
				fncStartTailling();
				myForm.select(".searchBlock button[data-action='start']").prop('disabled',true);
				myForm.select(".searchBlock button[data-action='stop']").prop('disabled',false);
				break;
			case 'stop':
				formUtil.setValue({
					tailFlag: 'N',
					pEndPoint: 0
				});
				if(!timer) {
					clearTimeout(timer);
					timer = null;
				}
				myForm.select(".searchBlock button[data-action='start']").prop('disabled',false);
				myForm.select(".searchBlock button[data-action='stop']").prop('disabled',true);
				break;
		}
	});
	// 내부 함수
	function fncStartTailling() {
		if($.trim(formUtil.getValue('tailFlag')) == 'Y') {
			$.ajax({
				type: 'POST',
				url: '/lgcom/logviewer/logtail',
				dataType: 'json',
				data: formUtil.getValue(),
				success : function(data) {
					if(data) {
						var console = myForm.select(".dataBlock .consolBlock textarea[data-name='consolePrint']");
						var preConsole = $.trim(console.val());
						if($.trim(data['logCode']) == '0') {
							console.val(preConsole + '\n' + $.trim(data['logLine']).replace(/(?:\r\n|\n)/g,'\n'));
							formUtil.setValue('pEndPoint', $.trim(data['logEndPoint']));
							console.scrollTop(console.prop('scrollHeight'));
							timer = setTimeout(function() {fncStartTailling();}, 1000);
						} else {
							myForm.select(".dataBlock .consolBlock textarea[data-name='consolePrint']").val(preConsole + '\n' + $.trim(data['logMessage']));
							// Stop 버튼 클릭
							myForm.select(".searchBlock button[data-action='stop']").click();
						}
					}
				}
			});
		}
	}
}

LogViewer.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LogViewer();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container popup LogViewer">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Log Viewer</h2>
	</div>
	<div class="searchBlock">
		<form class="form search-wrap">
			<input type="hidden" name="tailFlag" value="N"/>
			<input type="hidden" name="pEndPoint" value="0"/>
				<table class="table">
					<colgroup>
						<col width="90" />
						<col width="80" />
						<col width="80" />
						<col width="80"/>
						<col width="110"/>
						<col width="200"/>
						<col width="*"/>
					</colgroup>
					<tbody>
						<tr>
							<th scope="col">LOG Type</th>
							<td><select name="logPos" class="form-control input-sm size_80"></select></td>
							<th scope="col">System</th>
							<td><select name="systemCode" class="form-control input-sm size_80"></select></td>
							<th scope="col">Options(grep)</th>
							<td><input type="text" name="grepOptions" class="form-control input-sm size_180"/></td>
						</tr>
					</tbody>
				</table>
				<button type="button" class="btn btn-default btn-sm" data-action="start"><i class="fa fa-play" aria-hidden="true"></i> Start</button>
				<button type="button" class="btn btn-default btn-sm" data-action="stop" disabled><i class="fa fa-stop" aria-hidden="true"></i> Stop</button>
		</form>
	</div>
	<div class="dataBlock">
		<div class="consolBlock"><textarea data-name="consolePrint" class="console"></textarea></div>
	</div>
	</section>
</div>
</body>
</html>
