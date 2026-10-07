<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00094.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Dynamic Query Parameter Lookup Search Popup 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Dynamic Query</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
/**
 * TODO DQ 프로그램 복제시 해당 Context 명을 변경함으로써 적용가능하다.
 */
var DQ_CONTEXT_PATH = 'lgcom';

var LGUTLC00094 = function() {
	var myForm = this;
	var _popupInfo;
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	/* 화면 레이아웃 정의 */
	/*
	myForm.setManagedLayout({
		searchBlock:{ left:10, top:0 , right:10 },
		contentGrid:{ left:10, top:47, right:10, bottom:30 },
		controls   :{ left:10, bottom:0, right:10 }
	});
	*/
	myForm.setLayout( [ 
	           		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
	           		{ name : "contentGrid", left : 0, right : 0, top : "searchBlock", bottom : "controls"},
	           		{ name : "controls",  left : 0, right : 0, top : "contentGrid", bottom : 0 }		
	               ]);		
	// 그리드 초기화
	var grid = buildGrid('.dqParameterSearchListGrid');
	grid.setPagingMode(true,{rowSize:10});
	/*** OnLoad 이벤트 **/
	myForm.initMyForm = function() {
		_popupInfo = myForm.getParent().popupInfo;
		formUtil.setValue({
			queryId: $.trim(_popupInfo['queryId']),
			paraName: $.trim(_popupInfo['paraName']),
			keyword: $.trim(_popupInfo['keyword']) + '%',
		});
		myForm.select(".searchBlock form button[data-action='search']").trigger('click');
	};
	/***  이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			case 'search':
				var param = formUtil.getValue();
				grid.loadData(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00090/retrieveParamSearchListForInput',param,function(data) {
					grid.getDataProvider().fillJsonData(data['result'], { fillMode: "set" } );
					// 결과가 1건이면 자동선택후 종료한다.
					if(data.result.length == 1) {
						fncSelectRows();
					}
				});
				break;
			case 'ok1':
				if(grid.getGridBase().getItemCount() == 0) {
					Message.alert('<lgcom:message code="note.nocheckdata"/>');
					return;
				}
				fncSelectRows();
				break;
			case 'cancel1':
				Popup.closePopup( myForm );
				break;
		}
	});
	grid.getGridBase().onDataCellDblClicked = function(cgrid,index) {
		fncSelectRows();
	};
	/***  내부 함수  ***/
	// 그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(false);
		// Grid Field Set
		grid.setFields([
			{ fieldName:'code'        },
			{ fieldName:'description' }
		]);
		// Grid Column Set
		grid.setColumns([
			{
				name:'code',
				fieldName:'code',
				width:100,
				header: {text:'<lgcom:message code="CommonCode"/>'},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'description',
				fieldName:'description',
				width:250,
				header: {text:'<lgcom:message code="Description"/>'},
				styles: {textAlignment:'near'},
				editable: false
			}
		]);

		//
		grid.setOptions({
			grid: {
				hideDeletedRows:false,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				stateBar: {visible:false},
				footer: {visible:false},
				edit: {
					insertable: false,
					appendable: false,
					updatable: false,
					deletable: false
				},
				header: {
					height: 30
				}
			},
			dataProvider: {
				insertable: false,
				updatable: false,
				deletable: false,
				softDeleting: true,
				deleteCreated: true
			},
			display: { fitStyle: 'evenFill' }
		});
		// Context Menu Set
		grid.setContextMenu();
		return grid;
	}
	// Grid 선택
	function fncSelectRows() {
		var gview = grid.getGridBase();
		var curr = gview.getCurrent();
		_popupInfo['row'] = gview.getValues(curr.itemIndex);
		Popup.closePopup( myForm, true);
	}
};

LGUTLC00094.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGUTLC00094();
		form.init();
		form.initMyForm();
	});
});
</script>
</head>

<body>
<div class="mdi-container popup">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Preview Dynamic Query</h2>
	</div>
	<div class="searchBlock">
		<form class="search-wrap form" method="post" action="">
			<input type="hidden" name="queryId" value=""/>
			<input type="hidden" name="paraName" value=""/>
				<table class="table">
					<colgroup>
						<col width="100"/>
						<col width="*"/>
						<col width="100"/>
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><lgcom:message code="Find"/></th>
							<td><input type="text" name="keyword" class="form-control input-sm" value="%"/></td>
						</tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search" ><lgcom:message code="search" /></button>
		</form>
	</div>
	<div class="contentGrid grid-wrap">
		<div class="grid dqParameterSearchListGrid"></div>
	</div>
	<%-- 서버 버튼 영역 --%>
	<div class="controls modal-footer">
		<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="ok1"><lgcom:message code="ok"/></button>
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="cancel1"><lgcom:message code="cancel"/></button>
	</div>
	</section>
</div>
</body>
</html>
