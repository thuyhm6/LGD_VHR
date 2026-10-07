<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00121.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2016 LG CNS,  All rights reserved.

    설 명 : 본 화면은 화면 Guide 문서를 조회 및 등록/수정하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Manual</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp"%>
<style type="text/css">
.contents > .nav-tabs > li > a.contained {background: transparent url(/lgcom/static/img/bg_contain.png) no-repeat right top;background-color:#f7f7f7;}
.contents > .nav-tabs > li.active > a.contained {background: transparent url(/lgcom/static/img/bg_contain.png) no-repeat right top;background-color:#fff;}
.contents > .tab-content {position:absolute;top:26px;left:0px;right:0px;bottom:0px;}
.contents > .tab-content > .tab-pane {height:100%;}
.contents > .tab-content > .tab-pane > .manual {position:relative;height:100%;}
.contents > .tab-content > .tab-pane > .manual > .ckeditor {height:calc(100% - 33px);overflow:auto;border:1px solid #c8c8c8;}
</style>
<script type="text/javascript">
var LGUTLC00121 = function() {
	var myForm = this;

	/* Layout Setting */
	myForm.setLayout( [ 
		{ name : "contents",  left : 0, right : 0, top : 0, bottom : 29 },		
		{ name : "controls",  left : 0, right : 0, height : 27, bottom : 0 }		
    ]);		
	// 조회조건 Combo 초기화
	var code = new CommonCode('lgcom');
	code.execute('languageCode',{codeTypeCode:'LGCOM_LANGUAGE_CODE'});
	// 언어탭 그리기
	drawLanguageTab();
	// 메뉴얼 내용 조회
	retrieveUserManualContent();
	/** 이벤트 핸들러 **/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = event.target;
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).parent();
		}
		var action = $(item).data("action");
		if(action == 'close') {
			top.close();
		}
	});
	/* 첨부파일 다운로드 */
	myForm.addEvent('click',"a.download",function(event) {
		var fileId = $(event.target).data('fileId');
		var downloader = new Downloader();
		downloader.attachment(fileId, function(){
			Message.notify('<lgcom:message code="note.fileDownloadCompleted"/>');
		});
	});
	/*** 내부 함수 ***/
	// 언어별 Tab 구성
	function drawLanguageTab() {
		myForm.select('.contents>ul.nav-tabs').empty();
		myForm.select('.contents>div.tab-content').empty();
		$(code.get('languageCode')).each(function(idx) {
			// 탭 구성
			var li = $('<li></li>');
			li.attr('data-language',this.code);
			var anchor = $('<a></a>');
			anchor.attr('href','#_user_manual_' + this.code + '_tab_');
			anchor.attr('data-toggle','tab');
			anchor.html(this.name);
			li.append(anchor);
			myForm.select('.contents>ul.nav-tabs').append(li);
			// 탭 내용
			var div = $('<div></div>');
			div.addClass('tab-pane').addClass('fade');
			div.attr('id','_user_manual_' + this.code + '_tab_');
			myForm.select('.contents>div.tab-content').append(div);
		});
	}
	// 사용자 메뉴얼 조회
	function retrieveUserManualContent() {
		myForm.showProgress();
		var param = {
			manualProgramId: '${urlAddr.manualProgramId}'
		};
		transaction_sync('lgcom','lgutlc/LGUTLC00120/retrieveMenuManualViewData',param,function(data) {
			if(data.result) {
				var list = data.result;
				for(var i=0; i < list.length; i++) {
					var item = list[i];
					// 내용이 있는 Tab 표시
					if($.trim(item.existManual) == 'Y') {
						myForm.select(".contents>ul.nav-tabs>li[data-language='"+$.trim(item.languageCode)+"']>a").addClass('contained');
					}
					// Manual
					var div = $('<div></div>');
					div.addClass('manual');
					// Manual Content
					var div1 = $('<div></div>');
					div1.addClass('ckeditor');
					div1.html(item.manualContent);
					div.append(div1);
					// Manual Attach File
					fncDrawAttachFile(div,$.trim(item.etcAttachFileId),$.trim(item.fileId),$.trim(item.fileName));
					// 추가
					myForm.select('.contents>div.tab-content>div#_user_manual_'+$.trim(item.languageCode)+'_tab_').append(div);
				}
				// 세션에 사용된 언어를 기본으로 선택
				myForm.select('.contents>ul.nav-tabs>li[data-language="${sessionScope.USER_SESSION.languageCode}"]>a').trigger('click');
			}
		});
		myForm.hideProgress();
	}
	// 첨부파일 테이블 만들기
	function fncDrawAttachFile(div, attachFileId, fileSeq, fileName) {
		var table = $('<table></table>');
		table.addClass('table').addClass('table-condensed');
		table.attr('summary','메뉴얼 파일');
		table.css('margin-top','2px');
		var caption = $('<caption></caption>');
		caption.addClass('sr-only-lgd');
		caption.text('메뉴얼 파일');
		table.append(caption);
		var colgroup = $('<colgroup><col width="15%"/><col width="*"/></colgroup>');
		table.append(colgroup);
		var tbody = $('<tbody></tbody>');
		table.append(tbody);
		var tr = $('<tr></tr>');
		var th = $('<th></th>');
		th.attr('scope','col');
		th.css('height','30px');
		th.text('<lgcom:message code="Manual"/>');
		tr.append(th);
		var td = $('<td></td>');
		td.html('<a href="#" class="download" data-file-id="'+fileSeq+'">'+$.trim(fileName)+'</a>');
		tr.append(td);
		tbody.append(tr);
		div.append(table);
	}
};

LGUTLC00121.prototype = new BizForm("${param.bizFormId}");

$(document).ready(function() {
	launch(function() {
		var form = new LGUTLC00121();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Manual Viewer</h2>
	</div>
	<div class="contents">
		<ul class="nav nav-tabs">
		</ul>
		<!-- /nav-tabs -->
		<div class="tab-content">
		</div>
		<!-- /tab-content -->
	</div>
	<div class="controls module-group text-right">
		<button type="button" class="btn btn-gray btn-sm" role="button" data-action="close"><lgcom:message code="Close"/></button>
	</div>
	</section>
</div>
</body>
</html>
