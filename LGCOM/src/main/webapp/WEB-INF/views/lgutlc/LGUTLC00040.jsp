<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="devonframe.util.DateUtil"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : LGUTLC00040.jsp
	프로젝트명 : LGD WCFW

	Copyright(c) 2017 LG CNS, All rights reserved.

	설 명 : 본 화면은 Notice 유형의 게시판을 관리하는 화면입니다.
	작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<meta charset="utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<style type="text/css">
.view {
	width:100%;
	background-color: #fff;
	padding-bottom:10px;
	display:none;
}
.view .date-picker-wrapper {
	z-index:1001 !important;
}
.view .ckeditor {
	width:100%;
	min-height:300px;
	padding:2px 0px;
	overflow:hidden;
}
.view .panel {
	position : relative;
	margin-bottom : 10px;
}
.view .panel .line .attfile {
	display:block;
}
.view .panel .line .attfile .file {
	display:block;
}
.padt_10 {
	padding:10px 0 0 0;
}
.padt_20 {
	padding:20px 0 0 0;
}
.view .panel .line .comt-label {
	float:left;
	width:15%;
	height:70px;
	text-align:right;
	vertical-align:middle;
	padding:24px 10px;
	display:inline-block;
}
.view .panel .comt-text {
	width:100%;
	height:70px;
}
.view .panel .comt-btn {
	width:70px;
	height:70px;
}
.view .panel .line_seperator {
	width:100%;
	padding:5px 0px;
	margin:10px 0 0 0;
}
.view .panel .line_seperator .comt_label {
	padding-top:5px;
	display:inline-block;
}
.view .board-content {
	margin-bottom:10px;
}
.view .paging {
	width: 100%;
	height: 28px;
	text-align: center;
	display: block;
}
.view .paging .cpager {
	text-align: center;
	display: inline-block;
	margin:0 auto;
}
.view .paging .controls2 {
	float:right;
	height : 28px;
	display:inline-block;
}
.view .filedown {
	display:block;
	padding:5px 10px;
}
.view .form input[type='checkbox'] {
	min-height: 16px !important;
}
.view .reply {margin-top:10px;}
.view .reply .btn-wrap .btn-reply {margin-right:5px;}
.view .reply .btn-wrap .btn-reply:last-child {{margin-right:0px;}
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
//숫자 타입에서 쓸 수 있도록 format() 함수 추가
Number.prototype.format = function() {
	if(this==0) return 0;
	var reg = /(^[+-]?\d+)(\d{3})/;
	var n = (this + '');
	while (reg.test(n)) n = n.replace(reg, '$1' + ',' + '$2');
	return n;
};

var LGUTLC00040 = function() {
	var myForm = this;
	var upFiles;
	var uploadData = [];
	// Form Util 선언
	var listForm = new FormUtil(myForm,".view[data-action='list'] form");
	var writeForm = new FormUtil(myForm,".view[data-action='write'] form");
	var detailForm = new FormUtil(myForm,".view[data-action='detail'] form");

    /* Layout Setting */
	myForm.setLayout( [ 
		{ name : "view",  left : 0, right : 0, top : 0, bottom : 0}		
    ]);
    
	// 에디터 생성
	var editor = new Editor(myForm,'.ckeditor',{
		language: SESSION_USER.languageCode
	});
	// 게시판 기본 정보를 조회한다.
	if($.trim('${urlAddr.bulletinBoardId}') != '') {
		transaction_sync('lgcom','common/board/retrieveBoardMasterData',{bulletinBoardId:'${urlAddr.bulletinBoardId}'},function(data) {
			listForm.clear();
			listForm.setValue({
				systemCode: data.result.systemCode,
				bulletinBoardId: data.result.bulletinBoardId,
				bulletinBoardTypeCode: data.result.bulletinBoardTypeCode,
				bbReplyEnabledFlag: data.result.bbReplyEnabledFlag,
				bbShortReplyEnabledFlag: data.result.bbShortReplyEnabledFlag,
				bbAttachFileEnableFlag: data.result.bbAttachFileEnableFlag
			});
			writeForm.setValue({
				systemCode: data.result.systemCode,
				bulletinBoardId: data.result.bulletinBoardId
			});
		});
	} else {
		Message.alert('<lgcom:message code="error.notgivenItem"/>');
		return;
	}
	// Notice Type Combo 조회
	var code = new CommonCode('lgcom');
	code.add('noticeTypeCode1',{codeTypeCode:'LGCOM_NOTICE_TYPE_CODE'});
	code.add('noticeTypeCode2',{codeTypeCode:'LGCOM_NOTICE_TYPE_CODE'});
	code.add('noticeTypeCode3',{codeTypeCode:'LGCOM_NOTICE_TYPE_CODE'});
	code.add('flag1',{codeTypeCode:'LGCOM_YN_FLAG'});
	code.add('flag2',{codeTypeCode:'LGCOM_YN_FLAG'});
	code.execute();
	listForm.initCombo('noticeTypeCode',code.get('noticeTypeCode1'),{selectAll:true});
	listForm.initCombo('topPostFlag',code.get('flag1'),{selectAll:true});
	listForm.initCombo('popupAlarmFlag',code.get('flag2'),{selectAll:true});
	writeForm.initCombo('noticeTypeCode',code.get('noticeTypeCode2'));
	detailForm.initCombo('noticeTypeCode',code.get('noticeTypeCode3'));
	// Board Search Type Combo 구성
	createBoardSearchTypeCombo();
	/* 게시판 화면 초기화 */
	myForm.initForm = function() {
		// 기간 세팅
		$('div.date-picker-wrapper.single-date').remove();
		myForm.select(".view[data-action='write'] form input[name='periodFromDate']").dateRangePicker({singleDate:true,autoClose:true,language:'<lgcom:message code="calendar.language"/>'});
		myForm.select(".view[data-action='write'] form input[name='periodToDate']").dateRangePicker({singleDate:true,autoClose:true,language:'<lgcom:message code="calendar.language"/>'});
		// 파일 업로드 영역 세팅
		initFileUpload();
		// 주어진 화면 Mode 에 따라 화면을 이동한다.
		switch($.trim('${urlAddr.viewMode}')) {
			// 상세페이지
			case 'detail':
				clearDetailForm();
				retrieveBoardDetail($.trim('${urlAddr.bulletinBoardId}'),$.trim('${urlAddr.bulletinBoardNo}'));
				/* 인트로에서 페이지가 전환되었을 경우 */
				if($.trim('${urlAddr.fromSource}') == 'intro') {
					myForm.select(".view[data-action='detail'] form button[data-action='dreply']").hide();
					myForm.select(".view[data-action='detail'] form button[data-action='dupdate']").hide();
					myForm.select(".view[data-action='detail'] form button[data-action='ddelete']").hide();
					myForm.select(".view[data-action='detail'] form button[data-action='dlist']").hide();
				}
				break;
			// 글쓰기 페이지
			case 'write':
				setTimeout(function() {
					moveWritePage();
				},500);
				break;
			// 수정 화면
			case 'modify':
				moveModifyPage($.trim('${urlAddr.bulletinBoardId}'),$.trim('${urlAddr.bulletinBoardNo}'));
				break;
			// 기본 목록
			default:
				// 목록 화면 열기
				myForm.select("div.view[data-action]").hide();
				myForm.select("div.view[data-action='list']").show();
				/* 초기 조회 */
				myForm.select("button[data-action='search']").trigger('click');
				break;
		}
	};
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var action = $(this).data('action');
		switch(action) {
			// 검색
			case 'search':
				retriveBoardList();
				break;
			// 글쓰기
			case 'create':
				setTimeout(function() {
					moveWritePage();
				},500);
				break;
			// 글쓰기 저장
			case 'wsave':
				// Period 입력 체크
				if($.trim(myForm.select(".view[data-action='write'] form input[name='periodFromDate']").val()) == '') {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='BulletinPeriod'/>"/>');
					myForm.select(".view[data-action='write'] form input[name='periodFromDate']").focus();
					return;
				}
				if($.trim(myForm.select(".view[data-action='write'] form input[name='periodToDate']").val()) == '') {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='BulletinPeriod'/>"/>');
					myForm.select(".view[data-action='write'] form input[name='periodToDate']").focus();
					return;
				}
				// Notice Type 체크
				if($.trim(myForm.select(".view[data-action='write'] form select[name='noticeTypeCode']").val()) == '') {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='NoticeType'/>"/>');
					myForm.select(".view[data-action='write'] form select[name='noticeTypeCode']").focus();
					return;
				}
				// Title 체크
				if($.trim(myForm.select(".view[data-action='write'] form input[name='bulletinBoardTitle']").val()) == '') {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='Title'/>"/>');
					myForm.select(".view[data-action='write'] form input[name='bulletinBoardTitle']").focus();
					return;
				}
				// Editor의 내용 입력 여부 체크
				if($.trim(editor.getBodyContent()) == '') {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='BbBodyContent'/>"/>');
					return;
				}
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					if(upFiles.getFileCount() > 0) {
						upFiles.startUpload();
					} else {
						saveBoardData();
					}
				});
				break;
			// 글쓰기 목록 이동
			case 'wlist':
				// 목록 조회
				retriveBoardList(myForm.select(".view[data-action='list'] .searchBlock form input[name='currentPage']").val());
				break;
			// 상세 Force Delete
			case 'fdelete':
				Message.confirm('<lgcom:message code="question.reallyDelete"/>', function() {
					var param = {
						'bulletinBoardId': myForm.select(".view[data-action='detail'] input[name='bulletinBoardId']").val(),
						'bulletinBoardNo': myForm.select(".view[data-action='detail'] input[name='bulletinBoardNo']").val(),
						'bulletinBoardLevelSeqs': myForm.select(".view[data-action='detail'] input[name='bulletinBoardLevelSeqs']").val(),
						'bulletinBoardParentId': myForm.select(".view[data-action='detail'] input[name='bulletinBoardParentId']").val(),
						'currPage': myForm.select(".view[data-action='list'] input[name='currentPage']").val(),
						'rowBySize': myForm.select(".view[data-action='list'] input[name='rowBySize']").val(),
						'totalCount': myForm.select(".view[data-action='list'] input[name='totalCount']").val() - 1,
						'forceDelete': 'Y'
					};
					transaction_sync('lgcom','lgutlc/LGUTLC00040/deletePhysicalBoardData',param,function(data) {
						Message.notify('<lgcom:message code="note.deleted"/>');
						// 목록 재조회
						retriveBoardList(data.result.currPage);
					});
				});
				break;
			// 상세 목록 이동
			case 'dlist':
				clearDetailForm();
				// 목록 조회
				retriveBoardList(myForm.select(".view[data-action='list'] .searchBlock form input[name='currentPage']").val());
				break;
			// 상세 수정이동
			case 'dupdate':
				moveModifyPage(myForm.select(".view[data-action='detail'] input[name='bulletinBoardId']").val(),myForm.select(".view[data-action='detail'] input[name='bulletinBoardNo']").val());
				break;
			// 상세 답글이동
			case 'dreply':
				var boardId = myForm.select(".view[data-action='detail'] input[name='bulletinBoardId']").val();
				var boardNo = myForm.select(".view[data-action='detail'] input[name='bulletinBoardNo']").val();
				if(typeof(boardId) == 'undefined') return;
				if($.trim(boardId) == '') return;
				if(typeof(boardNo) == 'undefined') return;
				if($.trim(boardNo) == '') return;
				clearWriteForm();
				removeEditorDialog();
				// board level seqs + 1
				var boardLevelSeqs = myForm.select(".view[data-action='detail'] input[name='bulletinBoardLevelSeqs']").val() - 0;
				// 기본 정보 세팅
				writeForm.setValue({
					bulletinBoardParentId: boardNo,
					bulletinBoardId: boardId,
					bulletinBoardNo: '',
					bulletinBoardLevelSeqs: (boardLevelSeqs+1),
					bbReplyLevelDepth: 0,
					systemCode: myForm.select(".view[data-action='detail'] input[name='systemCode']").val()
				});
				// 첨부파일 첨부여부에 따라 첨부영역을 숨기거나 보인다.
				if(myForm.select(".searchBlock form input[name='bbAttachFileEnableFlag']").val() == 'Y') {
					myForm.select(".view[data-action='write'] form tr[data-action='attach_file']").show();
				} else {
					myForm.select(".view[data-action='write'] form tr[data-action='attach_file']").hide();
				}
				// 답글 화면 보이기
				myForm.select(".view[data-action]").hide();
				myForm.select(".view[data-action='write']").show();
				// Editor 객체의 높이를 지정한다.
				myForm.select("div.view[data-action='write'] .ckeditor").height((myForm.select("div.view[data-action='write']").height() - 221) + 'px');
				// Editor 창크기 변경
				editor.resetSize();
				break;
			// 상세 글삭제
			case 'ddelete':
				// 답변글이 있는 게시물의 경우
				var replyCnt = $.trim(myForm.select(".view[data-action='detail'] input[name='bbReplyLevelDepth']").val()) - 0;
				var confirmMsg = '<lgcom:message code="question.delete"/>';
				if(replyCnt > 0) {
					confirmMsg = '<lgcom:message code="note.existsReply"/>\n\n' + confirmMsg;
				}
				Message.confirm(confirmMsg,function() {
					var param = {
						'bulletinBoardId': myForm.select(".view[data-action='detail'] input[name='bulletinBoardId']").val(),
						'bulletinBoardNo': myForm.select(".view[data-action='detail'] input[name='bulletinBoardNo']").val(),
						'bulletinBoardLevelSeqs': myForm.select(".view[data-action='detail'] input[name='bulletinBoardLevelSeqs']").val(),
						'bulletinBoardParentId': myForm.select(".view[data-action='detail'] input[name='bulletinBoardParentId']").val(),
						'currPage': myForm.select(".view[data-action='list'] input[name='currentPage']").val(),
						'rowBySize': myForm.select(".view[data-action='list'] input[name='rowBySize']").val(),
						'totalCount': myForm.select(".view[data-action='list'] input[name='totalCount']").val() - 1,
						'forceDelete': 'N'
					};
					transaction_sync('lgcom','lgutlc/LGUTLC00040/deleteBoardData',param,function(data) {
						Message.notify('<lgcom:message code="note.deleted"/>');
						// 목록 재조회
						retriveBoardList(data.result.currPage);
					},function(error) {
						Message.alert(error.text);
					});
				});
				break;
			// 덧글 저장
			case 'sregist':
				var boardNo = myForm.select(".view[data-action='detail'] input[name='bulletinBoardNo']").val();
				var commentNo = '';
				var commentContent = myForm.select(".view[data-action='detail'] div[data-action='comment-list'] textarea[data-action='commentContent']").val();
				if($.trim(boardNo) == '') return;
				if($.trim(commentContent) == '') {
					Message.alert('<lgcom:message code="error.required" arguments="<lgcom:message code='Comment'/>"/>');
					return;
				}
				saveCommentList(boardNo,commentNo,commentContent);
				break;
		}
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	/* 입력화면 CheckBox */
	myForm.addEvent('click',".view[data-action='write'] input[data-action='notify_flag']",function(event) {
		var flag = $(this).data('flag');
		if($(this).is(':checked')) {
			myForm.select(".view[data-action='write'] input[name='"+flag+"']").val('Y');
		} else {
			myForm.select(".view[data-action='write'] input[name='"+flag+"']").val('N');
		}
	});
	/* 게시판 목록 클릭시 */
	myForm.addEvent('click',".view[data-action='list'] a[data-action='board-list']",function(event) {
		retrieveBoardDetail($.trim($(this).attr('bulletinBoardId')),$.trim($(this).attr('bulletinBoardNo')));
	});
	/* 게시건수 변경시 */
	myForm.addEvent('change',".view[data-action='list'] .board-content select[data-action='row-size']",function(event) {
		retriveBoardList();
	});
	/* 페이지 변경시 */
	myForm.addEvent('change',".view[data-action='list'] .paging .counter select[data-action='page-director']",function(event) {
		retriveBoardList($(this).val()-0);
	});
	/* 페이지 클릭시 */
	myForm.addEvent('click',".view[data-action='list'] .paging .cpager a[data-page]",function(event) {
		retriveBoardList($(this).data('page')-0);
	});
	/***  내부 함수  ***/
	// 게시판 검색 유형 Combo 생성
	function createBoardSearchTypeCombo() {
		var options = [
			{ val: 'title'   , text: '<lgcom:message code="Title"/>' },
			{ val: 'contents', text: '<lgcom:message code="Content"/>' }
		];
		for(var i=0; i < options.length; i++) {
			var opt = $('<option></option>');
			opt.val(options[i].val);
			opt.text(options[i].text);
			myForm.select(".searchBlock form select[data-action='search_type_code']").append(opt);
		}
	}
	// 게시판 목록
	function retriveBoardList(currPage) {
		if($.trim(currPage) == '') currPage = 1;
		var rowSize = myForm.select(".view[data-action='list'] .board-content select[data-action='row-size'] option:selected").val() - 0;
		var rowIdx = (rowSize * (currPage - 1)) + 1;
		// 조회영역에 현재 페이지 설정
		myForm.select(".view[data-action='list'] .searchBlock form input[name='currentPage']").val(currPage);
		myForm.select(".view[data-action='list'] .searchBlock form input[name='rowBySize']").val(rowSize);
		var param = listForm.getValue();
		param['targetRow'] = rowIdx;
		param['rowSize'] = rowSize;
		transaction_sync('lgcom','lgutlc/LGUTLC00040/retrieveBoardList',param,function(data) {
			if(data.result) {
				var totalCount = (data.result.rows ? (data.result.rows-0) : 0);
				var pageSize = myForm.select(".view[data-action='list'] .searchBlock form input[name='pageBySize']").val() - 0;
				// Counter 영역 세팅
				myForm.select(".view[data-action='list'] .board-content .form-control-static small[data-action='totalCount']").html('(<lgcom:message code="TotalCount"/> '+totalCount.format()+')');
				// 페이지 그리기
				generatePager(currPage,rowSize,totalCount);
				// 게시판 목록을 쓴다.
				var list = data.result.resultList;
				myForm.select(".board-content > table > tbody").html('');
				if(list.length == 0) {
					var tr = $('<tr/>');
					var td = $('<td/>');
					td.attr('colspan','7');
					td.html('No Data Found');
					tr.append(td);
					myForm.select(".board-content > table > tbody").append(tr);
				} else {
					var rowNo = totalCount - (rowSize * (currPage - 1));
					for(var i=0; i < list.length; i++) {
						var tr = $('<tr></tr>');
						// No
						var td1 = $('<td></td>');
						td1.addClass('text-right');
						if($.trim(list[i].bbTopPostFlag) == 'Y') {
							td1.html('<strong>'+rowNo+'</strong>');
						} else {
							td1.html(rowNo);
						}
						tr.append(td1);
						rowNo--;
						// Notice Type
						var td2 = $('<td></td>');
						td2.addClass('text-center');
						if($.trim(list[i].bbTopPostFlag) == 'Y') {
							td2.html('<strong>'+list[i].noticeTypeName+'</strong>');
						} else {
							td2.html(list[i].noticeTypeName);
						}
						tr.append(td2);
						// Title
						var td3 = $('<td></td>');
						//td3.addClass('text-left');
						// 최상위 공지이면
						if($.trim(list[i].bbTopPostFlag) == 'Y') {
							// 답글인지
							if(list[i].bulletinBoardLevelSeqs > 1) {
								var blank = '';
								for(var a=0; a < list[i].bulletinBoardLevelSeqs; a++) {
									blank += '&nbsp;&nbsp;';
								}
								// 첨부가 있다면
								if($.trim(list[i].attachFlag) == 'Y') {
									td3.html(blank+'<a href="#" data-action="board-list" bulletinBoardId="'+list[i].bulletinBoardId+'" bulletinBoardNo="'+list[i].bulletinBoardNo+'"><img src="<c:url value="/static/img/icon_reply.png"/>" border="0"/>&nbsp;<strong>'+list[i].bulletinBoardTitle+'</strong></a>&nbsp;<i class="glyphicon glyphicon-paperclip add_file"></i>');
								} else {
									td3.html(blank+'<a href="#" data-action="board-list" bulletinBoardId="'+list[i].bulletinBoardId+'" bulletinBoardNo="'+list[i].bulletinBoardNo+'"><img src="<c:url value="/static/img/icon_reply.png"/>" border="0"/>&nbsp;<strong>'+list[i].bulletinBoardTitle+'</strong></a>');
								}
							} else {
								// 첨부가 있다면
								if($.trim(list[i].attachFlag) == 'Y') {
									td3.html('<a href="#" data-action="board-list" bulletinBoardId="'+list[i].bulletinBoardId+'" bulletinBoardNo="'+list[i].bulletinBoardNo+'"><strong>'+list[i].bulletinBoardTitle+'</strong></a>&nbsp;<i class="glyphicon glyphicon-paperclip add_file"></i>');
								} else {
									td3.html('<a href="#" data-action="board-list" bulletinBoardId="'+list[i].bulletinBoardId+'" bulletinBoardNo="'+list[i].bulletinBoardNo+'"><strong>'+list[i].bulletinBoardTitle+'</strong></a>');
								}
							}
						} else {
							// 답글인지
							if(list[i].bulletinBoardLevelSeqs > 1) {
								var blank = '';
								for(var b=0; b < list[i].bulletinBoardLevelSeqs; b++) {
									blank += '&nbsp;&nbsp;';
								}
								// 첨부가 있다면
								if($.trim(list[i].attachFlag) == 'Y') {
									td3.html(blank+'<a href="#" data-action="board-list" bulletinBoardId="'+list[i].bulletinBoardId+'" bulletinBoardNo="'+list[i].bulletinBoardNo+'"><img src="<c:url value="/static/img/icon_reply.png"/>" border="0"/>&nbsp;'+list[i].bulletinBoardTitle+'</a>&nbsp;<i class="glyphicon glyphicon-paperclip add_file"></i>');
								} else {
									td3.html(blank+'<a href="#" data-action="board-list" bulletinBoardId="'+list[i].bulletinBoardId+'" bulletinBoardNo="'+list[i].bulletinBoardNo+'"><img src="<c:url value="/static/img/icon_reply.png"/>" border="0"/>&nbsp;'+list[i].bulletinBoardTitle+'</a>');
								}
							} else {
								// 첨부가 있다면
								if($.trim(list[i].attachFlag) == 'Y') {
									td3.html('<a href="#" data-action="board-list" bulletinBoardId="'+list[i].bulletinBoardId+'" bulletinBoardNo="'+list[i].bulletinBoardNo+'">'+list[i].bulletinBoardTitle+'</a>&nbsp;<i class="glyphicon glyphicon-paperclip add_file"></i>');
								} else {
									td3.html('<a href="#" data-action="board-list" bulletinBoardId="'+list[i].bulletinBoardId+'" bulletinBoardNo="'+list[i].bulletinBoardNo+'">'+list[i].bulletinBoardTitle+'</a>');
								}
							}
						}
						tr.append(td3);
						// Start Date
						var td4 = $('<td></td>');
						td4.addClass('text-center');
						if($.trim(list[i].bbTopPostFlag) == 'Y') {
							td4.html('<strong>'+list[i].periodFromDate+'</strong>');
						} else {
							td4.html(list[i].periodFromDate);
						}
						tr.append(td4);
						// End Date
						var td5 = $('<td></td>');
						td5.addClass('text-center');
						if($.trim(list[i].bbTopPostFlag) == 'Y') {
							td5.html('<strong>'+list[i].periodToDate+'</strong>');
						} else {
							td5.html(list[i].periodToDate);
						}
						tr.append(td5);
						// Write Date
						var td6 = $('<td></td>');
						td6.addClass('text-center');
						if($.trim(list[i].bbTopPostFlag) == 'Y') {
							td6.html('<strong>'+list[i].wrieDate+'</strong>');
						} else {
							td6.html(list[i].wrieDate);
						}
						tr.append(td6);
						// Hit
						var td7 = $('<td></td>');
						td7.addClass('text-right');
						if($.trim(list[i].bbTopPostFlag) == 'Y') {
							td7.html('<strong>'+list[i].hitCount+'</strong>');
						} else {
							td7.html(list[i].hitCount);
						}
						tr.append(td7);
						myForm.select(".board-content > table > tbody").append(tr);
					}
				}
				// 목록 창 보이기
				myForm.select("div.view[data-action]").hide();
				myForm.select("div.view[data-action='list']").show();
			}
		});
	}
	// 게시판 상세내역 조회
	function retrieveBoardDetail(boardId,boardNo) {
		if(typeof(boardId) == 'undefined') return;
		if($.trim(boardId) == '') return;
		if(typeof(boardNo) == 'undefined') return;
		if($.trim(boardNo) == '') return;
		// 조회수 Count + 1
		transaction_sync('lgcom','common/board/updateBoardHitCount',{'bulletinBoardId':boardId,'bulletinBoardNo':boardNo},function(data) {
			retrieveBoardDetailDetail(boardId,boardNo);
		});
	}
	// 게시판 상세내역 조회
	function retrieveBoardDetailDetail(boardId,boardNo) {
		// 상세내역 조회
		transaction_sync('lgcom','common/board/retrieveBoardDetail',{'bulletinBoardId':boardId,'bulletinBoardNo':boardNo},function(data) {
			if(data.result) {
				var detail = data.result;
				// 작성자인지 판단한다.
				var isOwner = (detail.writerId == '${sessionScope.USER_SESSION.applicationUserId}');
				detailForm.setValue({
					bulletinBoardId: detail.bulletinBoardId,
					bulletinBoardNo: detail.bulletinBoardNo,
					systemCode: detail.systemCode,
					bulletinBoardParentId: detail.bulletinBoardParentId,
					bulletinBoardLevelSeqs: detail.bulletinBoardLevelSeqs,
					bbReplyLevelDepth: detail.bbReplyLevelDepth,
					noticeTypeCode: detail.noticeTypeCode
				});
				// Bulletin Board No
				var bulletinBoardNo = $.trim(detail.bulletinBoardNo) - 0;
				myForm.select(".view[data-action='detail'] form td[data-action='bulletinBoardNo']").html(bulletinBoardNo.format());
				// Registrant
				myForm.select(".view[data-action='detail'] form td[data-action='writerName']").html(detail.writerName);
				// Bulletin Period
				myForm.select(".view[data-action='detail'] form span[data-action='periodFromDate']").html(detail.periodFromDate);
				myForm.select(".view[data-action='detail'] form span[data-action='periodToDate']").html(detail.periodToDate);
				// Options
				if($.trim(detail.bbTopPostFlag) == 'Y') {
					myForm.select(".view[data-action='detail'] form input[name='bbTopPostFlag']")[0].checked = true;
				} else {
					myForm.select(".view[data-action='detail'] form input[name='bbTopPostFlag']")[0].checked = false;
				}
				if($.trim(detail.popUpAlarmFlag) == 'Y') {
					myForm.select(".view[data-action='detail'] form input[name='popUpAlarmFlag']")[0].checked = true;
				} else {
					myForm.select(".view[data-action='detail'] form input[name='popUpAlarmFlag']")[0].checked = false;
				}
				// Title
				myForm.select(".view[data-action='detail'] form td[data-action='bulletinBoardTitle']").html(detail.bulletinBoardTitle);
				// Content
				var contents = $.trim(detail.bbBodyContent).replace(/<style[^>]*>(.*?)\<\/style>/i,'');
				myForm.select(".view[data-action='detail'] form div[data-action='bbBodyContent']").html(contents);
				// Attach
				// 첨부파일 첨부여부에 따라 첨부영역을 숨기거나 보인다.
				myForm.select(".view[data-action='detail'] td[data-action='attachFile']").empty();
				if(myForm.select(".searchBlock form input[name='bbAttachFileEnableFlag']").val() == 'Y') {
					var span;
					if(detail.attachFile1Id != null && detail.attachFile1Id != '') {
						span = $('<span class="filedown"></span>');
						anchor = $('<a href="#"></a>');
						anchor.data('action','file-download');
						anchor.data('fid',detail.attachFile1Id);
						anchor.html(detail.attachFile1Name);
						anchor.click(function() {
							myForm.select(".container > iframe[data-action='download']").attr('src','<c:url value="/download/board/"/>'+$(this).data('fid'));
						});
						span.append(anchor);
						myForm.select(".view[data-action='detail'] td[data-action='attachFile']").append(span);
					}
					if(detail.attachFile2Id != null && detail.attachFile2Id != '') {
						span = $('<span class="filedown"></span>');
						anchor = $('<a href="#"></a>');
						anchor.data('action','file-download');
						anchor.data('fid',detail.attachFile2Id);
						anchor.html(detail.attachFile2Name);
						anchor.click(function() {
							myForm.select(".container > iframe[data-action='download']").attr('src','<c:url value="/download/board/"/>'+$(this).data('fid'));
						});
						span.append(anchor);
						myForm.select(".view[data-action='detail'] td[data-action='attachFile']").append(span);
					}
					if(detail.attachFile3Id != null && detail.attachFile3Id != '') {
						span = $('<span class="filedown"></span>');
						anchor = $('<a href="#"></a>');
						anchor.data('action','file-download');
						anchor.data('fid',detail.attachFile3Id);
						anchor.html(detail.attachFile3Name);
						anchor.click(function() {
							myForm.select(".container > iframe[data-action='download']").attr('src','<c:url value="/download/board/"/>'+$(this).data('fid'));
						});
						span.append(anchor);
						myForm.select(".view[data-action='detail'] td[data-action='attachFile']").append(span);
					}
					myForm.select(".view[data-action='detail'] tr[data-action='attach_file']").show();
				} else {
					myForm.select(".view[data-action='detail'] tr[data-action='attach_file']").hide();
				}
				// Comment 쓰기가 가능하다면 Comment 목록을 조회하고 Comment 입력 영역을 보인다.
				if($.trim(myForm.select(".searchBlock input[name='bbShortReplyEnabledFlag']").val()) == 'Y') {
					// Comment 목록 조회
					drawCommentList(boardNo);
					// Comment 입력부 보이기
					myForm.select(".view[data-action='detail'] div[data-action='comment-list']").show();
				} else {
					// Comment 입력부 숨기기
					myForm.select(".view[data-action='detail'] div[data-action='comment-list']").hide();
				}
				/* 답글 작성여부가 N일 경우 Reply 버튼 숨기기 */
				if(listForm.getValue('bbReplyEnabledFlag') == 'Y') {
					myForm.select(".view[data-action='detail'] form button[data-action='dreply']").show();
				} else {
					myForm.select(".view[data-action='detail'] form button[data-action='dreply']").hide();
				}
				/* 작성자가 아니면 수정/삭제 불가 */
				if(isOwner) {
					myForm.select(".view[data-action='detail'] form button[data-action='dupdate']").show();
					myForm.select(".view[data-action='detail'] form button[data-action='ddelete']").show();
					/* 답글이 존재하면 삭제 불가 */
					if(detail.bbReplyLevelDepth > 0) {
						myForm.select(".view[data-action='detail'] form button[data-action='ddelete']").hide();
					} else {
						myForm.select(".view[data-action='detail'] form button[data-action='ddelete']").show();
					}
				} else {
					myForm.select(".view[data-action='detail'] form button[data-action='dupdate']").hide();
					myForm.select(".view[data-action='detail'] form button[data-action='ddelete']").hide();
				}
				// 상세화면 보이기
				myForm.select(".view[data-action]").hide();
				myForm.select(".view[data-action='detail']").show();
				// Content 영역 높이 재지정
				myForm.select("div.view[data-action='detail'] div[data-action='bbBodyContent']").height((myForm.select("div.view[data-action='detail']").height() - 221) + 'px');
			}
		});
	}
	// 게시판 등록 화면 이동
	function moveWritePage() {
		transaction_sync('lgcom','lgutlc/LGUTLC00040/retrieveBoardWriteForm',param,function(data) {
			removeEditorDialog();
			clearWriteForm();
			// 첨부파일 첨부여부에 따라 첨부영역을 숨기거나 보인다.
			if(myForm.select(".view[data-action='list'] .searchBlock form input[name='bbAttachFileEnableFlag']").val() == 'Y') {
				myForm.select(".view[data-action='write'] form tr[data-action='attach_file']").show();
			} else {
				myForm.select(".view[data-action='write'] form tr[data-action='attach_file']").hide();
			}
			// 모든 View를 숨긴다.
			myForm.select("div.view[data-action]").hide();
			// 쓰기 창 보이기
			myForm.select("div.view[data-action='write']").show();
			// Editor 객체의 높이를 지정한다.
			myForm.select("div.view[data-action='write'] .ckeditor").height((myForm.select("div.view[data-action='write']").height() - 221) + 'px');
			// Editor 창크기 변경
			editor.resetSize();
		});
	}
	// 게시판 수정 화면 이동
	function moveModifyPage(boardId,boardNo) {
		if(typeof(boardId) == 'undefined') return;
		if($.trim(boardId) == '') return;
		if(typeof(boardNo) == 'undefined') return;
		if($.trim(boardNo) == '') return;
		clearWriteForm();
		removeEditorDialog();
		retrieveBoardDetailForMod(boardId,boardNo);
	}
	// 게시판 등록
	function saveBoardData() {
		// Namo Editor의 내용을 복사한다.
		myForm.select(".view[data-action='write'] form input[name='bbBodyContent']").val(Base64.encode(editor.getData()));
		var param = writeForm.getValue();
		if(myForm.select(".view[data-action='detail'] form input[name='bbTopPostFlag']").is(':checked')) {
			param['bbTopPostFlag'] = 'Y';
		} else {
			param['bbTopPostFlag'] = 'N';
		}
		if(myForm.select(".view[data-action='detail'] form input[name='popUpAlarmFlag']").is(':checked')) {
			param['popUpAlarmFlag'] = 'Y';
		} else {
			param['popUpAlarmFlag'] = 'N';
		}
		// 첨부파일 내역을 세팅한다.
		for(var i=0; i < uploadData.length; i++) {
			param['attachFile'+(i+1)] = uploadData[i];
		}
		transaction_sync('lgcom','lgutlc/LGUTLC00040/saveBoardData',param,function(data) {
			Message.notify('<lgcom:message code="note.saved"/>');
			uploadData = null;
			uploadData = [];
			// 목록 재조회
			retriveBoardList(myForm.select(".view[data-action='list'] .searchBlock form input[name='currentPage']").val());
		},function(error) {
			Message.alert(error.text);
		});
	}
	// 게시판 수정화면 조회
	function retrieveBoardDetailForMod(boardId, boardNo) {
		transaction_sync('lgcom','common/board/retrieveBoardDetail',{'bulletinBoardId':boardId,'bulletinBoardNo':boardNo,'bbShortReplyEnabledFlag':'N'},function(data) {
			if(data.result) {
				var detail = data.result;
				// 작성자인지 판단한다.
				var isOwner = (detail.writerId == '${sessionScope.USER_SESSION.applicationUserId}');
				writeForm.setValue({
					bulletinBoardId: detail.bulletinBoardId,
					bulletinBoardNo: detail.bulletinBoardNo,
					bulletinBoardLevelSeqs: detail.bulletinBoardLevelSeqs,
					bbReplyLevelDepth: detail.bbReplyLevelDepth,
					systemCode: detail.systemCode,
					bulletinBoardParentId: detail.bulletinBoardParentId,
					noticeTypeCode: detail.noticeTypeCode,
					bulletinBoardTitle: detail.bulletinBoardTitle
				});
				// Bulletin Board No
				var bulletinBoardNo = $.trim(detail.bulletinBoardNo) - 0;
				myForm.select(".view[data-action='write'] form td[data-action='bulletinBoardNo']").html(bulletinBoardNo.format());
				// Registrant
				myForm.select(".view[data-action='write'] form td[data-action='writerName']").html(detail.writerName);
				// Bulletin Period
				myForm.select(".view[data-action='write'] form input[name='periodFromDate']").val(detail.periodFromDate);
				myForm.select(".view[data-action='write'] form input[name='periodToDate']").val(detail.periodToDate);
				// Options
				if($.trim(detail.bbTopPostFlag) == 'Y') {
					myForm.select(".view[data-action='write'] form input[data-flag='bbTopPostFlag']")[0].checked = true;
					writeForm.setValue({bbTopPostFlag:'Y'});
				} else {
					myForm.select(".view[data-action='write'] form input[data-flag='bbTopPostFlag']")[0].checked = false;
					writeForm.setValue({bbTopPostFlag:'N'});
				}
				if($.trim(detail.popUpAlarmFlag) == 'Y') {
					myForm.select(".view[data-action='write'] form input[data-flag='popUpAlarmFlag']")[0].checked = true;
					writeForm.setValue({popUpAlarmFlag:'Y'});
				} else {
					myForm.select(".view[data-action='write'] form input[data-flag='popUpAlarmFlag']")[0].checked = false;
					writeForm.setValue({popUpAlarmFlag:'N'});
				}
				// Attach
				// 첨부파일 첨부여부에 따라 첨부영역을 숨기거나 보인다.
				myForm.select(".view[data-action='write'] div[data-action='attach-list']").empty();
				if(myForm.select(".searchBlock form input[name='bbAttachFileEnableFlag']").val() == 'Y') {
					if(detail.attachFile1Id != null && detail.attachFile1Id != '') {
						uploadData.push({
							bulletinBoardNo: detail.bulletinBoardNo,
							fileSeqNo: detail.attachFile1Id,
							attachFileName: detail.attachFile1Name,
							systemAttachFileName: detail.attachSystemFile1Name,
							fileSize: detail.attachFile1Size
						});
						var span = $('<span class="filedown"></span>');
						anchor = $('<a href="#"></a>');
						anchor.data('action','file-download');
						anchor.data('fid',detail.attachFile1Id);
						anchor.html(detail.attachFile1Name);
						anchor.click(function() {
							myForm.select(".container > iframe[data-action='download']").attr('src','<c:url value="/download/board/"/>'+$(this).data('fid'));
						});
						span.append(anchor);
						if(isOwner) {
							var delBtn1 = $('<button/>');
							delBtn1.addClass('btn');
							delBtn1.addClass('btn-sm');
							delBtn1.css('margin','0px 5px');
							delBtn1.html('<lgcom:message code="delete"/>');
							delBtn1.click(function() {
								Message.confirm('<lgcom:message code="question.removeAttach"/>',function() {
									transaction_sync('lgcom','common/board/deleteBoardAttachFile',{bulletinBoardNo: detail.bulletinBoardNo, fileSeqNo: detail.attachFile1Id},function(data) {
										Message.notify('<lgcom:message code="note.deleted"/>');
										var containData = [];
										for(var i=0; i < uploadData.length; i++) {
											if($.trim(uploadData[i]['fileSeqNo']) != detail.attachFile1Id) {
												containData.push(uploadData[i]);
											}
										}
										uploadData = containData;
										if(uploadData.length < 3) {
											myForm.select(".view[data-action='write'] div[data-action='file-attach']").show();
										}
										delBtn1.parent().remove();
									});
								});
							});
							span.append(delBtn1);
						}
						myForm.select(".view[data-action='write'] div[data-action='attach-list']").append(span);
					}
					if(detail.attachFile2Id != null && detail.attachFile2Id != '') {
						uploadData.push({
							bulletinBoardNo: detail.bulletinBoardNo,
							fileSeqNo: detail.attachFile2Id,
							attachFileName: detail.attachFile2Name,
							systemAttachFileName: detail.attachSystemFile2Name,
							fileSize: detail.attachFile2Size
						});
						var span = $('<span class="filedown"></span>');
						anchor = $('<a href="#"></a>');
						anchor.data('action','file-download');
						anchor.data('fid',detail.attachFile2Id);
						anchor.html(detail.attachFile2Name);
						anchor.click(function() {
							myForm.select(".container > iframe[data-action='download']").attr('src','<c:url value="/download/board/"/>'+$(this).data('fid'));
						});
						span.append(anchor);
						if(isOwner) {
							var delBtn2 = $('<button/>');
							delBtn2.addClass('btn');
							delBtn2.addClass('btn-sm');
							delBtn2.css('margin','0px 5px');
							delBtn2.html('<lgcom:message code="delete"/>');
							delBtn2.click(function() {
								Message.confirm('<lgcom:message code="question.removeAttach"/>',function() {
									transaction_sync('lgcom','common/board/deleteBoardAttachFile',{bulletinBoardNo: detail.bulletinBoardNo, fileSeqNo: detail.attachFile2Id},function(data) {
										Message.notify('<lgcom:message code="note.deleted"/>');
										var containData = [];
										for(var i=0; i < uploadData.length; i++) {
											if($.trim(uploadData[i]['fileSeqNo']) != detail.attachFile2Id) {
												containData.push(uploadData[i]);
											}
										}
										uploadData = containData;
										if(uploadData.length < 3) {
											myForm.select(".view[data-action='write'] div[data-action='file-attach']").show();
										}
										delBtn2.parent().remove();
									});
								});
							});
							span.append(delBtn2);
						}
						myForm.select(".view[data-action='write'] div[data-action='attach-list']").append(span);
					}
					if(detail.attachFile3Id != null && detail.attachFile3Id != '') {
						uploadData.push({
							bulletinBoardNo: detail.bulletinBoardNo,
							fileSeqNo: detail.attachFile3Id,
							attachFileName: detail.attachFile3Name,
							systemAttachFileName: detail.attachSystemFile3Name,
							fileSize: detail.attachFile3Size
						});
						var span = $('<span class="filedown"></span>');
						anchor = $('<a href="#"></a>');
						anchor.data('action','file-download');
						anchor.data('fid',detail.attachFile3Id);
						anchor.html(detail.attachFile3Name);
						anchor.click(function() {
							myForm.select(".container > iframe[data-action='download']").attr('src','<c:url value="/download/board/"/>'+$(this).data('fid'));
						});
						span.append(anchor);
						if(isOwner) {
							var delBtn3 = $('<button/>');
							delBtn3.addClass('btn');
							delBtn3.addClass('btn-sm');
							delBtn3.css('margin','0px 5px');
							delBtn3.html('<lgcom:message code="delete"/>');
							delBtn3.click(function() {
								Message.confirm('<lgcom:message code="question.removeAttach"/>',function() {
									transaction_sync('lgcom','common/board/deleteBoardAttachFile',{bulletinBoardNo: detail.bulletinBoardNo, fileSeqNo: detail.attachFile3Id},function(data) {
										Message.notify('<lgcom:message code="note.deleted"/>');
										var containData = [];
										for(var i=0; i < uploadData.length; i++) {
											if($.trim(uploadData[i]['fileSeqNo']) != detail.attachFile3Id) {
												containData.push(uploadData[i]);
											}
										}
										uploadData = containData;
										if(uploadData.length < 3) {
											myForm.select(".view[data-action='write'] div[data-action='file-attach']").show();
										}
										delBtn3.parent().remove();
									});
								});
							});
							span.append(delBtn3);
						}
						myForm.select(".view[data-action='write'] div[data-action='attach-list']").append(span);
					}
					myForm.select(".view[data-action='write'] form tr[data-action='attach_file']").show();
				} else {
					myForm.select(".view[data-action='write'] form tr[data-action='attach_file']").hide();
				}
				if(uploadData.length == 3) {
					myForm.select(".view[data-action='write'] div[data-action='file-attach']").hide();
				} else {
					myForm.select(".view[data-action='write'] div[data-action='file-attach']").show();
				}
				// 수정화면 보이기
				myForm.select(".view[data-action]").hide();
				myForm.select(".view[data-action='write']").show();
				// Editor 객체의 높이를 지정한다.
				myForm.select("div.view[data-action='write'] .ckeditor").height((myForm.select("div.view[data-action='write']").height() - 221) + 'px');
				// Editor 창크기 변경
				editor.resetSize();
				// Content
				myForm.showProgress();
				setTimeout(function() {
					editor.setData($.trim(detail.bbBodyContent));
					myForm.hideProgress();
				},500);
			}
		});
	}
	// 게시판 상세내역 초기화
	function clearDetailForm() {
		detailForm.clear();
		// Bulletin Board No
		myForm.select(".view[data-action='detail'] form td[data-action='bulletinBoardNo']").html('');
		// Registrant
		myForm.select(".view[data-action='detail'] form td[data-action='writerName']").html('');
		// Bulletin Period
		myForm.select(".view[data-action='detail'] form span[data-action='periodFromDate']").html('');
		myForm.select(".view[data-action='detail'] form span[data-action='periodToDate']").html('');
		// Options
		myForm.select(".view[data-action='detail'] form input[name='bbTopPostFlag']")[0].checked = false;
		myForm.select(".view[data-action='detail'] form input[name='popUpAlarmFlag']")[0].checked = false;
		// Title
		myForm.select(".view[data-action='detail'] form td[data-action='bulletinBoardTitle']").html('');
		// Content
		myForm.select(".view[data-action='detail'] form div[data-action='bbBodyContent']").html('');
		// Attach
		myForm.select(".view[data-action='detail'] td[data-action='attachFile']").empty();
		// Comment 영역 초기화
		myForm.select(".view[data-action='detail'] div[data-action='comment-list'] textarea[data-action='commentContent']").val('');
		// 기존 화면 초기화
		myForm.select(".view[data-action='detail'] div[data-action='comment-list'] ul.media-list").empty();
	}
	// 게시판 등록화면 초기화
	function clearWriteForm() {
		writeForm.clear();
		writeForm.setValue({
			bulletinBoardId: myForm.select(".searchBlock form input[name='bulletinBoardId']").val(),
			bulletinBoardNo: '',
			bulletinBoardLevelSeqs: 1,
			bbReplyLevelDepth: 0,
			systemCode: myForm.select(".searchBlock form input[name='systemCode']").val(),
			bulletinBoardParentId: 0,
			periodFromDate: '<%=DateUtil.getDate("yyyy-MM-dd")%>',
			periodToDate: '<%=DateUtil.getDate("yyyy-MM-dd")%>',
			bulletinBoardTitle: ''
		});
		// Bulletin Board No
		myForm.select(".view[data-action='write'] form td[data-action='bulletinBoardNo']").html('');
		// Registrant
		myForm.select(".view[data-action='write'] form td[data-action='writerName']").html('${sessionScope.USER_SESSION.fullNameLocal}');
		// Notice Type
		myForm.select(".view[data-action='write'] form select[name='noticeTypeCode'] option:first").attr('selected','selected');
		// Options
		myForm.select(".view[data-action='write'] form input[data-flag='bbTopPostFlag']")[0].checked = false;
		myForm.select(".view[data-action='write'] form input[data-flag='popUpAlarmFlag']")[0].checked = false;
		// Content
		setTimeout(function() {
			editor.setData('');
		},500);
		myForm.select(".view[data-action='write'] form input[name='bbBodyContent']").val('');
		// Attach
		uploadData = null;
		uploadData = [];
		// 기존 첨부 영역 삭제
		myForm.select(".view[data-action='write'] div[data-action='attach-list']").empty();
		if(upFiles) upFiles.reset(true);
	}
	// File Upload 영역 초기화
	function initFileUpload() {
		// File Upload 영역 세팅
		upFiles = myForm.select(".view[data-action='write'] div[data-action='file-attach'] div[data-action='file-data']").uploadFile({
			url: '<c:url value="/upload/board"/>',
			multiple: true,
			dragDrop: false,
			fileName: 'attachFile',
			returnType: 'json',
			sequential: true,
			maxFileCount: 3,
			maxFileSize: <lgcom:message code="note.bulletinMaxFileSize"/>,		// LGCOM_SYSTEM_MESSAGE에 Note 유형으로 관리
			allowedTypes: '<lgcom:message code="note.bulletinAllowFileExt"/>',	// LGCOM_SYSTEM_MESSAGE에 Note 유형으로 관리
			autoSubmit: false,
			showPreview: false,
			previewWidth: 40,
			previewHeight: 40,
			dragdropWidth: '100%',
			statusBarWidth: '100%',
			showDownload: false,
			showDelete: false,
			showProgress: false,
			onSelect: function(files) {
				if((uploadData.length + upFiles.getFileCount() + files.length) <= 3) {
					return true;
				} else {
					Message.notify('3 <lgcom:message code="note.fileManagerFileCount"/>');
					return false;
				}
			},
			onSuccess: function(files,data,xhr,pd) {
				uploadData.push(data.result[0]);
			},
			afterUploadAll:function(obj) {
				saveBoardData();
			},
			onError:function(files, status, message, pd) {
				trace(message);
			}
		});
	}
	// 등록된 Comment 목록 조회
	function drawCommentList(boardNo) {
		myForm.select(".view[data-action='detail'] div[data-action='comment-list'] .line_seperator").html('');
		transaction_sync('lgcom','common/board/retrieveBoardShortReplyList',{'bulletinBoardNo':boardNo},function(data) {
			if(data.result) {
				var list = data.result;
				if(list.length > 0) {
					// 기존 화면 초기화
					myForm.select(".view[data-action='detail'] div[data-action='comment-list'] ul.media-list").empty();
					for(var i=0; i < list.length; i++) {
						var row = $('<li></li>');
						row.addClass('media');
						var div = $('<div></div>');
						div.addClass('media-body');
						row.append(div);
						var cont = $('<p></p>');
						cont.html(list[i].bbShortReplyContent);
						div.append(cont);
						var info = $('<p></p>');
						info.addClass('reply-info');
						div.append(info);
						var writer = $('<span></span>');
						writer.addClass('writer');
						writer.html(list[i].registrantName);
						info.append(writer);
						var date = $('<span></span>');
						date.addClass('date');
						date.html(list[i].creationDate);
						info.append(date);
						var btnwrap = $('<span></span>');
						btnwrap.addClass('btn-wrap');
						info.append(btnwrap);
						// 작성자 본인일 경우
						if($.trim(list[i].ownComment) == 'Y') {
							// 저장버튼
							var btn1 = $('<button class="btn btn-ico btn-reply" aria-label="save"></button>');
							btn1.html('<span class="ico ico-reply-save" aria-hidden="true"></span>');
							btn1.attr('bulletinBoardNo',list[i].bulletinBoardNo);
							btn1.attr('bulletinBoardShortReplyNo',list[i].bulletinBoardShortReplyNo);
							btn1.click(function() {
								var content = $.trim($(this).parent().parent().parent().find('p:first-child > textarea').val());
								saveCommentList($(this).attr('bulletinBoardNo'),$(this).attr('bulletinBoardShortReplyNo'),content);
							});
							btn1.hide();
							btnwrap.append(btn1);
							// 취소버튼
							var btn2 = $('<button class="btn btn-ico btn-reply" aria-label="cancel"></button>');
							btn2.html('<span class="ico ico-reply-cancel" aria-hidden="true"></span>');
							btn2.click(function() {
								// TextArea 없애기
								var content = $.trim($(this).parent().parent().parent().find('p:first-child > textarea').val());
								$(this).parent().parent().parent().find('p:first-child').empty();
								$(this).parent().parent().parent().find('p:first-child').html(content.replace(/(\n)/gi,'<br>'));
								// 저장버튼 숨기기
								$(this).parent().find("button[aria-label='save']").hide();
								// 수정버튼 보이기
								$(this).parent().find("button[aria-label='edit']").show();
								// 자신 숨기기
								$(this).hide();
							});
							btn2.hide();
							btnwrap.append(btn2);
							// 수정버튼
							var btn3 = $('<button class="btn btn-ico btn-reply" aria-label="edit"></button>');
							btn3.html('<span class="ico ico-reply-edit" aria-hidden="true"></span>');
							btn3.click(function() {
								// TextArea 쓰기
								var content = $.trim($(this).parent().parent().parent().find('p:first-child').html());
								var textarea = $('<textarea style="width:100%;height:70px;padding:5px;"></textarea>');
								textarea.val(content.replace(/<br(\/)*>/gi,'\n'));
								$(this).parent().parent().parent().find('p:first-child').empty();
								$(this).parent().parent().parent().find('p:first-child').append(textarea);
								// 저장버튼 보이기
								$(this).parent().find("button[aria-label='save']").show();
								// 취소버튼 보이기
								$(this).parent().find("button[aria-label='cancel']").show();
								// 수정버튼 숨기기
								$(this).hide();
							});
							btnwrap.append(btn3);
							// 삭제버튼
							var btn4 = $('<button class="btn btn-ico btn-reply" aria-label="delete"></button>');
							btn4.html('<span class="ico ico-reply-del" aria-hidden="true"></span>');
							btn4.attr('bulletinBoardNo',list[i].bulletinBoardNo);
							btn4.attr('bulletinBoardShortReplyNo',list[i].bulletinBoardShortReplyNo);
							btn4.click(function() {
								removeCommentList($(this).attr('bulletinBoardNo'),$(this).attr('bulletinBoardShortReplyNo'));
							});
							btnwrap.append(btn4);
						}
						myForm.select(".view[data-action='detail'] div[data-action='comment-list'] ul.media-list").append(row);
					}
				}
			}
		});
	}
	// Comment 저장
	function saveCommentList(boardNo,commentNo,commentContent) {
		Message.confirm('<lgcom:message code="question.save"/>',function() {
			var param = {bulletinBoardNo: boardNo, bulletinBoardShortReplyNo: commentNo, bbShortReplyContent: commentContent};
			transaction_sync('lgcom','common/board/updateBoardShortReply',param,function(data) {
				// Comment 입력란 초기화
				myForm.select(".view[data-action='detail'] div[data-action='comment-list'] textarea[data-action='commentContent']").val('');
				// 완료 메세지
				Message.notify('<lgcom:message code="note.saved"/>');
				// Comment 목록 재조회
				drawCommentList(boardNo);
			});
		});
	}
	// Comment 삭제
	function removeCommentList(boardNo,commentNo) {
		Message.confirm('<lgcom:message code="question.delete"/>',function() {
			var param = {bulletinBoardNo: boardNo, bulletinBoardShortReplyNo: commentNo};
			transaction_sync('lgcom','common/board/deleteBoardShortReply',param,function(data) {
				// 완료 메세지
				Message.notify('<lgcom:message code="note.deleted"/>');
				// Comment 목록 재조회
				drawCommentList(boardNo);
			});
		});
	}
	// 페이저 생성
	function generatePager(curPage, pageSize, totalCount) {
		var totalPage = Math.ceil(totalCount / pageSize);
		// 전체 페이지수 설정
		myForm.select(".view[data-action='list'] .searchBlock form input[name='totalCount']").val(totalCount);
		var startPage = Math.floor((curPage - 1) / 10) * 10 + 1;
		var endPage = startPage + (10 - 1);
		if(endPage > totalPage) {
			endPage = totalPage;
		}
		var firstPage = 1;
		var nextFirstPage = startPage + 10;
		var prevPage = (curPage == 1) ? 1 : (curPage - 1);
		var nextPage = (curPage + 1);

		myForm.select(".paging .cpager").html('');
		if(totalCount > 0) {
			var pager = $('<ul></ul>');
			pager.addClass('pagination');
			var first = $('<li></li>');
			first.addClass('first');
			var prev = $('<li></li>');
			prev.addClass('prev');
			if(curPage == 1) {
				first.append('<a aria-label="Previous"><span class="ico ico-paging-first" aria-hidden="true"></span></a>');
			} else {
				first.append('<a aria-label="Previous" href="#" data-page="'+firstPage+'"><span class="ico ico-paging-first" aria-hidden="true"></span></a>');
			}
			if(prevPage < curPage) {
				prev.append('<a aria-label="Previous" href="#" data-page="'+prevPage+'"><span class="ico ico-paging-prev" aria-hidden="true"></span></a>');
			} else {
				prev.append('<a aria-label="Previous"><span class="ico ico-paging-prev" aria-hidden="true"></span></a>');
			}
			pager.append(first);
			pager.append(prev);

			for(var i=startPage; i <= endPage; i++) {
				var page = $('<li></li>');
				if(curPage == i) {
					page.addClass('active');
					page.append('<a>'+i+'</a>');
				} else {
					page.append('<a href="#" data-page="'+i+'">'+i+'</a>');
				}
				pager.append(page);
			}

			var next = $('<li></li>');
			next.addClass('next');
			var end = $('<li></li>');
			end.addClass('end');
			if(nextPage <= totalPage) {
				next.append('<a aria-label="Previous" href="#" data-page="'+nextPage+'"><span class="ico ico-paging-next" aria-hidden="true"></span></a>');
			} else {
				next.append('<a aria-label="Previous"><span class="ico ico-paging-next" aria-hidden="true"></span></a>');
			}
			if(nextFirstPage <= totalPage) {
				end.append('<a aria-label="Previous" href="#" data-page="'+nextFirstPage+'"><span class="ico ico-paging-end" aria-hidden="true"></span></a>');
			} else {
				end.append('<a aria-label="Previous"><span class="ico ico-paging-end" aria-hidden="true"></span></a>');
			}
			pager.append(next);
			pager.append(end);
			myForm.select(".paging .cpager").append(pager);
		}
	}
	// CKEditor Dialog가 Body 태그에 쓰여지므로 사용 권한이 없습니다. 메세지 출력됨.
	function removeEditorDialog() {
		//$("div.cke_editor_" + editor.getEditorId() + "_dialog[role='dialog'][aria-labelledby='cke_dialog_title_94']").remove();
		$("div.cke_editor_" + editor.getEditorId() + "_dialog[role='dialog']").remove();
	}
};

LGUTLC00040.prototype = new BizForm('${param.bizFormId}');

$(document).ready( function() {
	launch(function() {
		var form = new LGUTLC00040();
		form.init();
		form.initForm();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Notice</h2>
	</div>
	<%-- 목록 화면 --%>
	<div data-action="list" class="view">
		<div class="searchBlock">
			<form class="form search-wrap">
				<input type="hidden" name="bulletinBoardId" value=""/>
				<input type="hidden" name="bulletinBoardTypeCode" value=""/>
				<input type="hidden" name="bbReplyEnabledFlag" value=""/>
				<input type="hidden" name="bbShortReplyEnabledFlag" value=""/>
				<input type="hidden" name="bbAttachFileEnableFlag" value=""/>
				<input type="hidden" name="systemCode" value=""/>
				<input type="hidden" name="currentPage" value="1"/>
				<input type="hidden" name="rowBySize" value=""/>
				<input type="hidden" name="pageBySize" value="10"/>
				<input type="hidden" name="totalCount" value=""/>
					<table class="table table-condensed" >
						<colgroup>
							<col width="90"/>
							<col width="90"/>
							<col width="5"/>
							<col width="90"/>
							<col width="5"/>
							<col width="200"/>
							<col width="5"/>
							<col width="80"/>
							<col width="60"/>
							<col width="5"/>
							<col width="80"/>
							<col width="60"/>
						</colgroup>
						<tbody>
							<tr>
								<th><label class="required"><lgcom:message code="NoticeType" /></label></th>
								<td><select class="form-control input-sm" name="noticeTypeCode"></select></td>
								<td></td>
								<td><select class="form-control input-sm" data-action="search_type_code" name="searchTypeCode"></select></td>
								<td></td>
								<td><input type="text" class="form-control input-sm" name="searchKeyword" placeholder=""/></td>
								<td></td>
								<th><label><lgcom:message code="TopPost"/></label></th>
								<td><select class="form-control input-sm" name="topPostFlag"></select></td>
								<td></td>
								<th><label><lgcom:message code="PopupAlarm"/></label></th>
								<td><select class="form-control input-sm" name="popupAlarmFlag"></select></td>
							</tr>
						</tbody>
					</table>
					<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search" data-access="LGUTLC00040/retrieveBoardList"><lgcom:message code="search" /></button>
			</form>
		</div>
		<div class="board-content grid-wrap">
			<div class="pull-left form-inline">
				<div class="form-group">
					<select class="form-control input-sm" style="width:47px;" data-action="row-size">
						<option value="10" selected="selected">10</option>
						<option value="20">20</option>
						<option value="30">30</option>
						<option value="50">50</option>
						<option value="70">70</option>
						<option value="100">100</option>
					</select>
				</div>
				<div class="form-group">
					<p class="form-control-static"><lgcom:message code="Row"/>&nbsp;/&nbsp;<lgcom:message code="Page"/> <small class="text-gray" data-action="totalCount"></small></p>
				</div>
			</div>
			<table class="table table-condensed" summary="">
				<caption class="sr-only"></caption>
				<colgroup>
					<col width="8%"/>
					<col width="9%"/>
					<col width="48%"/>
					<col width="9%"/>
					<col width="9%"/>
					<col width="9%"/>
					<col width="8%"/>
				</colgroup>
				<thead>
					<tr>
						<th rowspan="2"><lgcom:message code="No."/></th>
						<th rowspan="2"><lgcom:message code="NoticeType"/></th>
						<th rowspan="2"><lgcom:message code="Title"/></th>
						<th colspan="2"><lgcom:message code="DisplayDate"/></th>
						<th rowspan="2"><lgcom:message code="Date"/></th>
						<th rowspan="2"><lgcom:message code="Hit"/></th>
					</tr>
					<tr>
						<th><lgcom:message code="StartDate"/></th>
						<th><lgcom:message code="EndDate"/></th>
					</tr>
				<thead>
				<tbody>
				</tbody>
			</table>
		</div>
		<div class="paging">
			<div class="cpager"></div>
			<div class="controls2">
				<button class="btn btn-save btn-sm" type="button" role="button" data-action="create" data-access="LGUTLC00040/retrieveBoardWriteForm"><lgcom:message code="New"/></button>
			</div>
		</div>
	</div>
	<%-- 글쓰기 화면 --%>
	<div data-action="write" class="view grid-wrap">
		<form class="form" method="post">
			<input type="hidden" name="bulletinBoardId" value=""/>
			<input type="hidden" name="bulletinBoardNo" value=""/>
			<input type="hidden" name="bulletinBoardLevelSeqs" value="1"/>
			<input type="hidden" name="bbReplyLevelDepth" value="0"/>
			<input type="hidden" name="systemCode" value=""/>
			<input type="hidden" name="bulletinBoardParentId" value="0"/>
			<table class="table table-condensed" summary="">
				<caption class="sr-only-lgd"></caption>
				<colgroup>
					<col width="17%"/>
					<col width="33%"/>
					<col width="17%"/>
					<col width="33%"/>
				</colgroup>
				<tbody>
					<tr>
						<th scope="row"><lgcom:message code="BulletinBoardNo"/></th>
						<td class="text-left" data-action="bulletinBoardNo"></td>
						<th scope="row"><lgcom:message code="Registrant"/></th>
						<td class="text-left" data-action="writerName">${sessionScope.USER_SESSION.fullNameLocal}</td>
					</tr>
					<tr>
						<th scope="row"><lgcom:message code="BulletinPeriod"/></th>
						<td class="text-left">
							<input type="text" name="periodFromDate" class="form-control input-sm input-require size_80" style="text-align:center; display:inline-block;" value="<%=DateUtil.getDate("yyyy-MM-dd")%>" placeholder="yyyy-mm-dd"/>
							<span style="text-align:center; display:inline-block;">~</span>
							<input type="text" name="periodToDate" class="form-control input-sm input-require size_80" style="text-align:center; display:inline-block;" value="<%=DateUtil.getDate("yyyy-MM-dd")%>" placeholder="yyyy-mm-dd"/>
						</td>
						<th scope="row"><lgcom:message code="NoticeType"/></th>
						<td class="text-left"><select name="noticeTypeCode" class="form-control input-sm input-require size_100"></select></td>
					</tr>
					<tr>
						<th scope="row"><lgcom:message code="Options"/></th>
						<td colspan="3" class="text-left">
							<div class="checkbox checkbox-uxp checkbox-inline">
								<input type="checkbox" data-action="notify_flag" data-flag="bbTopPostFlag"/>
								<label><lgcom:message code="TopPost"/></label>
							</div>
							<div class="checkbox checkbox-uxp checkbox-inline">
								<input type="checkbox" data-action="notify_flag" data-flag="popUpAlarmFlag"/>
								<label><lgcom:message code="PopupAlarm"/></label>
							</div>
							<input type="hidden" name="bbTopPostFlag" value="N"/>
							<input type="hidden" name="popUpAlarmFlag" value="N"/>
						</td>
					</tr>
					<tr>
						<th scope="row"><lgcom:message code="Title"/></th>
						<td colspan="3" class="text-left"><input type="text" name="bulletinBoardTitle" class="form-control input-sm input-require" style="width:98%;height:28px;font-size:12px;" placeholder=""/></td>
					</tr>
					<tr>
						<td colspan="4" style="padding:0px !important;">
							<input type="hidden" name="bbBodyContent"/>
							<div class="ckeditor"></div>
						</td>
					</tr>
					<tr data-action="attach_file">
						<th scope="row"><lgcom:message code="Attach"/></th>
						<td colspan="3" class="text-left">
							<div data-action="file-attach"><div data-action="file-data"></div></div>
							<div data-action="attach-list"></div>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
		<div class="controls" module-group text-right style="margin-top:10px;">
			<button class="btn btn-gray btn-sm" type="button" role="button" data-action="wsave" data-access="LGUTLC00040/saveBoardData"><lgcom:message code="save"/></button>
			<button class="btn btn-default btn-sm" type="button" role="button" data-action="wlist"><lgcom:message code="list"/></button>
		</div>
	</div>
	<%-- 상세화면 --%>
	<div data-action="detail" class="view grid-wrap">
		<form class="form" method="post">
			<input type="hidden" name="bulletinBoardId" value=""/>
			<input type="hidden" name="bulletinBoardNo" value=""/>
			<input type="hidden" name="systemCode" value=""/>
			<input type="hidden" name="bulletinBoardParentId" value=""/>
			<input type="hidden" name="bulletinBoardLevelSeqs" value=""/>
			<input type="hidden" name="bbReplyLevelDepth" value=""/>
			<table class="table table-condensed" summary="">
				<caption class="sr-only-lgd"></caption>
				<colgroup>
					<col width="17%"/>
					<col width="33%"/>
					<col width="17%"/>
					<col width="33%"/>
				</colgroup>
				<tbody>
					<tr>
						<th><lgcom:message code="BulletinBoardNo"/></th>
						<td class="text-left" data-action="bulletinBoardNo"></td>
						<th><lgcom:message code="Registrant"/></th>
						<td class="text-left" data-action="writerName"></td>
					</tr>
					<tr>
						<th><lgcom:message code="BulletinPeriod"/></th>
						<td class="text-left">
							<span data-action="periodFromDate" style="margin-top:4px;display:inline-block;"></span>
							<span style="margin-top:4px;display:inline-block;">~</span>
							<span data-action="periodToDate" style="margin-top:4px;display:inline-block;"></span>
						</td>
						<th><lgcom:message code="NoticeType"/></th>
						<td class="text-left"><select name="noticeTypeCode" class="form-control input-sm size_100" disabled="disabled"></select></td>
					</tr>
					<tr>
						<th><lgcom:message code="Options"/></th>
						<td colspan="3" class="text-left">
							<label><input type="checkbox" name="bbTopPostFlag" disabled="disabled"/>&nbsp;<lgcom:message code="TopPost"/></label>
							<label><input type="checkbox" name="popUpAlarmFlag" disabled="disabled"/>&nbsp;<lgcom:message code="PopupAlarm"/></label>
						</td>
					</tr>
					<tr>
						<th><lgcom:message code="Title"/></th>
						<td colspan="3" class="text-left" data-action="bulletinBoardTitle"></td>
					</tr>
					<tr>
						<td colspan="4" class="text-left">
							<div data-action="bbBodyContent" style="width:100%;height:100%;padding:10px;overflow:auto;"></div>
						</td>
					</tr>
					<tr data-action="attach_file">
						<th><lgcom:message code="Attach"/></th>
						<td colspan="3" class="text-left" data-action="attachFile"></td>
					</tr>
				</tbody>
			</table>
			<div class="controls module-group text-right" style="margin-top:10px;">
				<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="fdelete" data-access="LGUTLC00040/deletePhysicalBoardData"><lgcom:message code="ForceDelete"/></button>
				<button class="btn btn-default btn-sm" type="button" role="button" data-action="dreply"><lgcom:message code="Reply"/></button>
				<button class="btn btn-default btn-sm" type="button" role="button" data-action="dupdate"><lgcom:message code="Modify"/></button>
				<button class="btn btn-default btn-sm" type="button" role="button" data-action="ddelete"><lgcom:message code="delete"/></button>
				<button class="btn btn-default btn-sm" type="button" role="button" data-action="dlist"><lgcom:message code="list"/></button>
			</div>
			<div data-action="comment-list" class="panel padt_20 grid-wrap">
				<table class="table table-reply table-condensed" summary="">
					<caption class="sr-only-lgd"></caption>
					<colgroup>
						<col width="17%"/>
						<col width="73%"/>
						<col width="10%"/>
					</colgroup>
					<tbody>
						<tr>
							<th scope="row"><lgcom:message code="Comment"/></th>
							<td><textarea data-action="commentContent" class="comt-text"></textarea></td>
							<td class="align-bottom">
							<button class="btn comt-btn btn-gray btn-sm" type="button" role="button" data-action="sregist"><lgcom:message code="Register"/></button></td>
						</tr>
					</tbody>
				</table>
				<div class="reply">
					<ul class="media-list"></ul>
				</div>
			</div>
		</form>
	</div>
	<iframe data-action="download" style="display:none;"></iframe>
	</section>
</div>
</body>
</html>
