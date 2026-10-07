<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00120.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 화면 Guide 문서를 관리하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Manual</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp"%>
<style type="text/css">
.editor {
	height:100%;
	padding:0px;
	margin:5px 0 0 0;
}
span.lblSpan {
	width: 100%;
	height: 17px;
	overflow: hidden;
	text-overflow: ellipsis;
	padding: 2px 0 0 0;
	margin: 0px;
	display: inline-block;
}
</style>
<script type="text/javascript">
var LGUTLC00120 = function() {
	var myForm = this;
	// 조회조건 Combo 초기화
	var srchFrmUtil = new FormUtil(myForm,'.searchBlock form');
	var langFrmUtil = new FormUtil(myForm,'.manualControls form');
	var dataFrmUtil = new FormUtil(myForm,'.dataBlock form');
	
	
	//파일 매니저 초기화 
    var fileManager = new FileManager( myForm, { moduleCode : "LGCOM", fileCount : 1 } );
	
	
	/* 화면 레이아웃 정의 */
	/*
	myForm.setManagedLayout({
		searchBlock   : { left:0, top:0, right:0 },
		treeControls  : { left:0, top:33, width:270, right:0 },
		menuTree      : { left:0, top:SINGLE_LINE.top2, width:270, bottom:0 },
		manualControls: { left:280, top:33, right:0 },
		dataBlock     : { left:280, top:SINGLE_LINE.top2, right:0, height:72 },
		editBlock     : { left:280, top:133, right:0, bottom:5 }
	});
	*/

    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "searchBlock",    left : 0, right : 0, top : 0 },		
		{ name  : "treeControls",   left : 0, right : 0, top : "searchBlock", width : 270 },
		{ name  : "manualControls", left : "treeControls", right : 0, top : "searchBlock" },
		
		{ name  : "menuTree",       left : 0, right : 0, top : "treeControls", width : 270, bottom : 0},
		{ name  : "dataBlock",      left : "treeControls", right : 0, top : "manualControls", bottom :0 },	 	
		{ name  : "editBlock",      left : "treeControls", right : 0, top : "dataBlock", bottom : 0  }
	]);    
	
	// 조회조건 Combo 초기화
	var code = new CommonCode('lgcom');
	code.add('systemCode',{codeTypeCode:'LGCOM_SYSTEM_CODE'});
	code.add('moduleCode',{codeTypeCode:'LGCOM_MODULE_CODE'});
	code.add('languageCode',{codeTypeCode:'LGCOM_LANGUAGE_CODE'});
	code.execute();
	srchFrmUtil.initCombo('systemCode',code.get('systemCode'),{selectAll:false});
	srchFrmUtil.initCombo('moduleCode',code.get('moduleCode'),{selectAll:true, filter:'systemCode'});
	langFrmUtil.initCombo('languageCode',code.get('languageCode'));
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	/* 사용자 세션 언어코드 세팅 */
	langFrmUtil.setValue('languageCode',SESSION_USER.languageCode);
	/* 메뉴 Tree 생성 */
	var menuData = new Map();
	var tree = new JsTree(myForm,'.menuTree',{});
	tree.onSelectNode(function(event,data) {
	if(nvl(data.node.li_attr['programId']) != '') {
		fncRetrieveManual($.trim(data.node.li_attr['menuId']),$.trim(data.node.li_attr['programId']),langFrmUtil.getValue('languageCode'));
	}		
		/*
		if(data && data.node && data.node.type) {
			if($.trim(data.node.type) == 'leaf') {
				fncRetrieveManual($.trim(data.node.li_attr['menuId']),$.trim(data.node.li_attr['programId']),langFrmUtil.getValue('languageCode'));
			}
		}
		*/
		event.preventDefault();
		return false;
	});
	// CKEditor 생성
	var editor = new Editor(myForm,'.editor',{
		language: SESSION_USER.languageCode
	});
	// 화면 초기화
	fcnInitScreen();
	// 초기 메뉴 조회
	fncRetrieveMenuTree();
	/** 이벤트 핸들러 **/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = event.target;
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).parent();
		}
		var action = $(item).data("action");
		switch(action) {
			case 'search':
				fncRetrieveMenuTree();
				break;
			// 메뉴얼 보기
			case 'preview':
				var popup = new Popup(myForm,'lgcom','M_LGUTLC_1183','<lgcom:message code="Guide"/>');
				popup.setSize(1036,600);
				popup.addParam("manualProgramId",$.trim(dataFrmUtil.getValue('manualProgramId')));
				popup.openWindow(function() {
				});
				break;
			// 메뉴얼 저장
			case 'save':
				// 에디터 내용이 있던지 아니면 첨부파일이 있던지 해야 한다.
				var manualFileId = $.trim(dataFrmUtil.getValue('manualAttachFileId'));
				var manualContent = $.trim(editor.getBodyContent());
				if(manualFileId == '' && manualContent == '') {
					Message.alert('<lgcom:message code="error.enterRequireData"/>');
					return;
				}
				Message.confirm('<lgcom:message code="question.save"/>',function() {
					var param = dataFrmUtil.getValue();
					// 에디터에 입력된 내용이 있다면
					if(manualContent != '') {
						param["manualContent"] = Base64.encode(editor.getData());
					}
					transaction_sync('lgcom','lgutlc/LGUTLC00120/saveManualData',param,function(data) {
						Message.notify('<lgcom:message code="note.saved"/>');
						fncRetrieveManual($.trim(param.manualMenuId),$.trim(param.manualProgramId),$.trim(param.manualLanguageCode));
					});
				});
				break;
			// 메뉴얼 삭제
			case 'delete':
				var param = dataFrmUtil.getValue();
				Message.confirm('<lgcom:message code="question.delete"/>',function() {
					transaction_sync('lgcom','lgutlc/LGUTLC00120/deleteManualData',param,function(data) {
						Message.notify('<lgcom:message code="note.deleted"/>');
						fncRetrieveManual($.trim(param.manualMenuId),$.trim(param.manualProgramId),$.trim(param.manualLanguageCode));
					});
				});
				break;
			// 메뉴얼 파일 첨부
			case 'attach':
				fileManager.open({
					fileGroupId : dataFrmUtil.getValue('manualAttachFileId'), 
					editable : true,
					callback : function( reqNumber ){
						if(reqNumber != null) {
							dataFrmUtil.setValue('manualAttachFileId',reqNumber);
							myForm.select(".dataBlock form td[data-name='attachFile']").empty();
							var anchor = $('<a></a>');
							anchor.attr('href','#').addClass('download').attr('data-file-id',$.trim(fileData[0].fileId)).css('margin-right','10px').text($.trim(fileData[0].fileName));
							var button = $('<span></span>');
							button.addClass('ico').addClass('ico-reply-del').attr('role','button').attr('aria-hidden','true').attr('data-id',$.trim(fileData[0].fileId));
							myForm.select(".dataBlock table td[data-name='attachFile']").append(anchor).append(button);
						}
					}
				});
				break;
			// 메뉴 확장
			case 'expandAll':
				tree.expandAll();
				break;
			// 메뉴 접기
			case 'collapseAll':
				tree.collapseAll();
				break;
		}
	});
	/* 첨부파일 다운로드 */
	myForm.addEvent('click',".dataBlock td[data-name='attachFile'] a.download",function(event) {
		var fileId = $(event.target).data('fileId');
		var downloader = new Downloader();
		downloader.attachment(fileId, function(){
			Message.notify('<lgcom:message code="note.fileDownloadCompleted"/>');
		});
	});
	/* 첨부파일 삭제 */
	myForm.addEvent('click',".dataBlock td[data-name='attachFile'] span.ico-reply-del",function(event) {
		var manualFileId = $.trim($(event.target).data('id'));
		var manualFileName = $.trim($(event.target).prev().html());
		var param = dataFrmUtil.getValue();
		param["fileId"] = manualFileId;
		Message.confirm('<lgcom:message code="question.removeAttach"/><br/><br/>Name : <strong>'+ manualFileName +'</strong>', function() {
			transaction_sync('lgcom','lgutlc/LGUTLC00120/deleteManualAttachFile',param,function(data) {
				Message.notify('<lgcom:message code="note.deleted"/>');
				fncRetrieveManual($.trim(param.manualMenuId),$.trim(param.manualProgramId),$.trim(param.manualLanguageCode));
			});
		});
	});
	/* 언어 변경시 메뉴얼 내용 재조회 */
	myForm.addEvent('change',".manualControls select[name='languageCode']",function(event) {
		if($.trim(dataFrmUtil.getValue('manualProgramId')) == '') return;
		fncRetrieveManual($.trim(dataFrmUtil.getValue('manualMenuId')),$.trim(dataFrmUtil.getValue('manualProgramId')),$.trim($(this).find('>option:selected').val()));
	});
 	/** 메뉴 Tree 조회 */
	function fncRetrieveMenuTree() {
		transaction_sync('lgcom','lgutlc/LGUTLC00120/retrieveMenuTreeList',srchFrmUtil.getValue(),function(data) {
			menuData.clear();
			var list = data['result'];
			var treeData = [];
			
            if($(list).size() == 0 ){
            	 Message.confirm('<lgcom:message code="note.nodata" />');
            	 return;
            }
            
			$(list).each(function(inx) {
				// 각 레코드의 데이터 보정 및 정리
				if( this['highMenuId'] == undefined ) {
					this['highMenuId'] = '#'; // jsTree 는 root메뉴의 parent 가 # 이어야 한다.
				} else {
					var parent = menuData.get( this['highMenuId'] );
					this['parentMenuName'] = parent['menuName'];
				}
				this['status'] = 'N';
/*
				// 각 레벨에 따라 type 을 지정한다.
				if(this['menuLevelNo'] == '1') {
					this['menuLevelType'] = 'root';
				} else if(this['menuLevelNo'] == "2") {
					this['menuLevelType'] = 'branch';
				} else if( this['menuLevelNo'] == "3" ) {
					this['menuLevelType'] = 'leaf';
				}
*/
				treeData.push({
					id : this['menuId'],
					parent : this['highMenuId'],
					text : this['menuName'],
					li_attr: {
						systemCode: this['systemCode'],
						moduleCode: this['moduleCode'],
						menuId: this['menuId'],
						menuName: this['menuName'],
						programId: this['programId'],
						programName: this['programName']
					}
				});
				menuData.put(this['menuId'],this);
			});
			tree.setData(treeData);
		});
	}
	/* 화면 초기화 */
	function fcnInitScreen() {
		// Data 영역 초기화
		dataFrmUtil.clear();
		// 메뉴명
		myForm.select(".dataBlock span.lblSpan[data-name='menuName']").empty();
		// 프로그램명
		myForm.select(".dataBlock span.lblSpan[data-name='programName']").empty();
		// 첨부파일
		myForm.select(".dataBlock td[data-name='attachFile']").empty();
		// 메뉴얼 초기화
		editor.setData('');
		// Preview 버튼
		myForm.select(".manualControls button[data-action='preview']").hide();
		// 저장 버튼
		myForm.select(".manualControls button[data-action='save']").hide();
		// 삭제 버튼
		myForm.select(".manualControls button[data-action='delete']").hide();
	}
	/** 메뉴ID에 따른 Manual 조회 **/
	function fncRetrieveManual(menuId,programId,languageCode) {
		myForm.showProgress();
		var param = {
			manualMenuId: menuId,
			manualProgramId: programId,
			manualLanguageCode: languageCode
		};
		fcnInitScreen();
		transaction_sync('lgcom','lgutlc/LGUTLC00120/retrieveMenuManualData',param,function(data) {
			if(data.result) {
				dataFrmUtil.setValue({
					manualMenuId: $.trim(data.result.menuId),
					manualProgramId: $.trim(data.result.programId),
					manualLanguageCode: $.trim(data.result.languageCode),
					manualAttachFileId: $.trim(data.result.attachFileId)
				});
				var menuInfo = '';
				if($.trim(data.result.menuId) != '') {
					menuInfo += '[' + $.trim(data.result.menuId) + '] ';
				}
				if($.trim(data.result.menuId) != '') {
					menuInfo += $.trim(data.result.menuName);
				}
				myForm.select(".dataBlock span.lblSpan[data-name='menuName']").html(menuInfo);
				myForm.select(".dataBlock span.lblSpan[data-name='menuName']").attr('title',menuInfo);
				var programInfo = '';
				if($.trim(data.result.programId) != '') {
					programInfo += '[' + $.trim(data.result.programId) + '] ';
				}
				if($.trim(data.result.programName) != '') {
					programInfo += $.trim(data.result.programName);
				}
				myForm.select(".dataBlock span.lblSpan[data-name='programName']").html(programInfo);
				myForm.select(".dataBlock span.lblSpan[data-name='programName']").attr('title',programInfo);
				// 첨부파일
				if($.trim(data.result.attachFileId) == '') {
					myForm.select(".dataBlock table td[data-name='attachFile']").append('<button class="btn btn-default btn-sm" type="button" role="button" data-action="attach"><lgcom:message code="Attachment"/></button>');
				} else {
					var anchor = $('<a></a>');
					anchor.attr('href','#').addClass('download').attr('data-file-id',$.trim(data.result.fileId)).css('margin-right','10px').text($.trim(data.result.fileName));
					var button = $('<span></span>');
					button.addClass('ico').addClass('ico-reply-del').attr('role','button').attr('aria-hidden','true').attr('data-id',$.trim(data.result.fileId));
					myForm.select(".dataBlock table td[data-name='attachFile']").append(anchor).append(button);
				}
				// 편집화면
				setTimeout(function() {
					editor.setData($.trim(data.result.manualContent));
				},100);
				// Preview 버튼
				myForm.select(".manualControls button[data-action='preview']").show();
				// 저장 버튼
				myForm.select(".manualControls button[data-action='save']").show();
				// 삭제 버튼
				myForm.select(".manualControls button[data-action='delete']").show();
			} else {
				// 좌측 메뉴에서 선택된 Node를 얻는다.
				var selectedNode = tree.getNode(tree.getSelectedNode());
				dataFrmUtil.setValue({
					manualMenuId: $.trim(selectedNode.li_attr.menuId),
					manualProgramId: $.trim(selectedNode.li_attr.programId),
					manualLanguageCode: $.trim(langFrmUtil.getValue('languageCode'))
				});
				var menuInfo = '';
				if($.trim(selectedNode.li_attr.menuId) != '') {
					menuInfo += '[' + $.trim(selectedNode.li_attr.menuId) + '] ';
				}
				if($.trim(selectedNode.li_attr.menuId) != '') {
					menuInfo += $.trim(selectedNode.li_attr.menuName);
				}
				myForm.select(".dataBlock span[data-name='menuName']").html(menuInfo);
				myForm.select(".dataBlock span.lblSpan[data-name='menuName']").attr('title',menuInfo);
				var programInfo = '';
				if($.trim(selectedNode.li_attr.programId) != '') {
					programInfo += '[' + $.trim(selectedNode.li_attr.programId) + '] ';
				}
				if($.trim(selectedNode.li_attr.programName) != '') {
					programInfo += $.trim(selectedNode.li_attr.programName);
				}
				myForm.select(".dataBlock span[data-name='programName']").html(programInfo);
				myForm.select(".dataBlock span.lblSpan[data-name='programName']").attr('title',programInfo);
				// 첨부파일
				myForm.select(".dataBlock table td[data-name='attachFile']").append('<button class="btn btn-default btn-sm" type="button" role="button" data-action="attach"><lgcom:message code="Attachment"/></button>');
				// 편집화면
				editor.setData('');
				// 저장 버튼
				myForm.select(".manualControls button[data-action='save']").show();
			}
		});
		myForm.hideProgress();
	}
};

LGUTLC00120.prototype = new BizForm("${param.bizFormId}");

$(document).ready(function() {
	launch(function() {
		var form = new LGUTLC00120();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Manual</h2>
	</div>
	
	<div class="searchBlock">
		<form class="form search-wrap">
				<table class="table">
					<colgroup>
						<col width="100"/>
						<col width="90"/>
						<col width="100"/>
						<col width="90"/>
					</colgroup>
					<tbody>
						<tr>
							<th><label><lgcom:message code="System"/></label></th>
							<td><select class="form-control input-sm" name="systemCode"></select></td>
							<th><label><lgcom:message code="Module"/></label></th>
							<td><select class="form-control input-sm" name="moduleCode"></select></td>							
						</tr>
					</tbody>
				</table>
			<button type="button" class="btn btn-lgd btn-sm btn-search" data-action="search"><lgcom:message code="Search"/></button>
		</form>
	</div>
	
	<div class="treeControls module-group text-right">
		<div class="btn-toolbar">	
			<div class="btn-group">
				<button type="button" class="btn btn-default btn-sm ico-lgd" aria-label="추가" data-action ="expandAll"  >
				    <span class="fa fa-plus" aria-hidden="true"></span>
				</button>
				<button type="button" class="btn btn-default btn-sm ico-lgd" aria-label="추가" data-action ="collapseAll" >
				    <span class="fa fa-minus" aria-hidden="true"></span>
				</button>
			</div>
		</div>	
	</div>
	
	<div id="_menuTree" class="menuTree noselect panel panel-default" style="overflow-y:auto;"></div>
	
	<div class="manualControls module-group text-right">
		<div class="btn-toolbar">	
		    <div class="btn-group">
	             <form class="form">		                    	
					 <select name="languageCode" class="form-control input-sm size_80" style="display: inline;"></select>
				 </form>   			    
	        </div>					
			<div class="btn-group">						
				<button class="btn btn-default btn-sm" type="button" data-action="preview"><lgcom:message code="Preview"/></button>
				<button class="btn btn-gray btn-sm" type="button" data-action="delete"><lgcom:message code="delete"/></button>
			</div>
			<div class="btn-group">	
				<button class="btn btn-darkgray btn-sm" type="button" data-action="save"><lgcom:message code="save"/></button>
			</div>
		</div>		
	</div>				
	
	<div class="dataBlock grid-wrap">
		<form class="form">
			<input type="hidden" name="manualMenuId"/>
			<input type="hidden" name="manualProgramId"/>
			<input type="hidden" name="manualLanguageCode"/>
			<input type="hidden" name="manualAttachFileId"/>
			<table class="table table-condensed" summary="메뉴얼 편집">
				<caption class="sr-only-lgd">메뉴얼 편집</caption>
				<colgroup>
					<col width="15%"/>
					<col width="35%"/>
					<col width="15%"/>
					<col width="35%"/>
				</colgroup>
				<tbody>
					<tr>
						<th scope="row"><lgcom:message code="MenuName"/></th>
						<td><span class="lblSpan" data-name="menuName"></span></td>
						<th scope="row"><lgcom:message code="ProgramName"/></th>
						<td><span class="lblSpan" data-name="programName"></span></td>
					</tr>
					<tr>
						<th><label><lgcom:message code="Manual"/></label></th>
						<td colspan="3" data-name="attachFile">
							<button class="btn btn-default btn-sm" type="button" role="button" data-action="attach"><lgcom:message code="Attachment"/></button>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
	</div>
	
	<div class="editBlock">
		<div class="editor"></div>
	</div>
	
	</section>
</div>
</body>
</html>
