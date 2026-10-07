<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAYQ0001.jsp
    프로젝트명 : LGDisplay LGVHR Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 임직원이 급여에서 사용하는 다이나믹쿼리 화면입니다.
    작성자 : 손수양	
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

var LGUTLC00080 = function() {
	var grid;
	var procType = ""    ;		// 기존방식일 경우 "", 신규 Tread 방식일 경우 2로 표시
	var myForm   = this ;	
	/* 팝업용 변수 선언 */
	myForm.popupInfo = {};
	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	
	/* 화면 레이아웃 정의 */
/*
	var zeroRowLayout = {
		searchBlock :{ left:0, top:0 , right:0 },
		gridControls:{ left:0, top:SINGLE_LINE.top1, right:0 },
		dataBlock   :{ left:0, top:SINGLE_LINE.top2, right:0 },
		contentGrid :{ left:0, top:SINGLE_LINE.top2, right:0, bottom:0 }
	}
	var singleRowLayout = {
		searchBlock :{ left:0, top:0  , right:0 },
		gridControls:{ left:0, top:47 , right:0 },
		dataBlock   :{ left:0, top:77 , right:0 },
		contentGrid :{ left:0, top:118, right:0, bottom:0 }
	};
	var dualRowLayout = {
		searchBlock :{ left:0, top:0  , right:0 },
		gridControls:{ left:0, top:47 , right:0 },
		dataBlock   :{ left:0, top:77 , right:0 },
		contentGrid :{ left:0, top:153, right:0, bottom:0 }
	};
	var thirdRowLayout = {
		searchBlock :{ left:0, top:0  , right:0 },
		gridControls:{ left:0, top:47 , right:0 },
		dataBlock   :{ left:0, top:77 , right:0 },
		contentGrid :{ left:0, top:188, right:0, bottom:0 }
	};
	myForm.setManagedLayout(zeroRowLayout);   
*/
   // Small, Normal
   var zeroRowLayout=[ 
 	           		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
 	        		{ name : "gridControls", left : 0, right : 0, top : "searchBlock"},
 	        		{ name : "dataBlock",    left : 0, right : 0, top : "gridControls"},
 	        		{ name : "contentGrid",  left : 0, right : 0, top : "dataBlock", bottom : 0 }
 	        		]; 	        		
 	// Small        		
	var singleRowLayout=[ 
	           		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
	        		{ name : "gridControls", left : 0, right : 0, top : 47 },
	        		{ name : "dataBlock",    left : 0, right : 0, top : 77 },
	        		{ name : "contentGrid",  left : 0, right : 0, top : 118, bottom : 0 }
	   ];	
    var dualRowLayout=[ 
     	           		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
     	        		{ name : "gridControls", left : 0, right : 0, top : 47},
     	        		{ name : "dataBlock",    left : 0, right : 0, top : 77},
     	        		{ name : "contentGrid",  left : 0, right : 0, top : 153, bottom : 0 }
      	];
    var thirdRowLayout=[ 
    	           		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
    	        		{ name : "gridControls", left : 0, right : 0, top : 47},
    	        		{ name : "dataBlock",    left : 0, right : 0, top : 77},
    	        		{ name : "contentGrid",  left : 0, right : 0, top : 188, bottom : 0 }
    	];  
    // Normal
	var singleRowLayoutNormal=[ 
	   	 	           		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
	   	 	        		{ name : "gridControls", left : 0, right : 0, top : 68 },
	   	 	        		{ name : "dataBlock",    left : 0, right : 0, top : 106 },
	   	 	        		{ name : "contentGrid",  left : 0, right : 0, top : 147, bottom : 0 }
	   	 	   ];    
    var dualRowLayoutNormal=[ 
    	           		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
    	        		{ name : "gridControls", left : 0, right : 0, top : 68},
    	        		{ name : "dataBlock",    left : 0, right : 0, top : 106},
    	        		{ name : "contentGrid",  left : 0, right : 0, top : 182, bottom : 0 }
     	];    
    var thirdRowLayoutNormal=[ 
         	           		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
         	        		{ name : "gridControls", left : 0, right : 0, top : 68},
         	        		{ name : "dataBlock",    left : 0, right : 0, top : 106},
         	        		{ name : "contentGrid",  left : 0, right : 0, top : 217, bottom : 0 }
          	];  
    
    if(!isSmallLayout()){
    	singleRowLayout = singleRowLayoutNormal;
    	dualRowLayout = dualRowLayoutNormal;
    	thirdRowLayout = thirdRowLayoutNormal;
    }
    
    myForm.setLayout(zeroRowLayout);
    
	
	// Grid 초기화
	var grid = buildGrid('.dynamicQueryGrid');
	// 조회조건 Combo 초기화
	
	var code = new CommonCode(DQ_CONTEXT_PATH);
	code.add('group',{queryId:'retrieveDynamicAccessGroupList', accessGroup:'${urlAddr.accessGroup}'});
	code.execute();
	formUtil.initCombo('accessGroup',code.get('group'),{selectAll:false});
	// Access Group 초기값
	formUtil.setValue({accessGroup:'${urlAddr.accessGroup}'});
	// Access Group 값이 주어지면
	if($.trim('${urlAddr.accessGroup}') != '') {
		// Access Group 비활성화
		myForm.select(".searchBlock form select[name='accessGroup']").prop('disabled',true);
	}
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	/***  이벤트 핸들러  ***/
	/* 버튼 이벤트 */
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			case 'execute':
				// Access Group 선택 여부
				if($.trim(formUtil.getValue('accessGroup')) == '') {
					Message.alert('<lgcom:message code="error.mustSelected" arguments="<lgcom:message code='AccessGroup'/>"/>');
					myForm.select(".searchBlock form select[name='accessGroup']").focus();
					return;
				}
				if($.trim(formUtil.getValue('queryId')) == '') {
					Message.alert('<lgcom:message code="error.mustSelected" arguments="<lgcom:message code='UseQueryName'/>"/>');
					myForm.select(".searchBlock form input[name='queryName']").focus();
					return;
				}
				// 기존 조회조건 초기화
				initialSearchCondition();
				// Setup Parameter Value 팝업
				myForm.popupInfo['queryId'] = $.trim(formUtil.getValue('queryId'));
				var valpop = new Popup(myForm,DQ_CONTEXT_PATH,'M_LGUTLC_1155','<lgcom:message code="inputParam"/>');
				valpop.setSize(500,384);
				valpop.open(function() {
					if(myForm.popupInfo.selData) {
						// 진행바 보이기
						myForm.showProgress();
						var args = myForm.popupInfo.selData;
						drawSearchCondition(args);
						// 기존 조회된 Data Clear
						grid.getDataProvider().clearRows();
						/* DQ Parameter를 조합해서 조회를 수행한다. */
						var param;
						if(procType == '2') {
							param = {
								queryMode: 'RUN',
								accessGroup: $.trim(formUtil.getValue('accessGroup')),
								queryId: $.trim(formUtil.getValue('queryId')),
								executeAs: (myForm.select(".searchBlock form table input[name='executeAs']").is(':checked') ? 'Y':'N'),
								sqlArg: {}
							};
						} else {
							param = {
								queryMode: 'RUN',
								accessGroup: $.trim(formUtil.getValue('accessGroup')),
								queryId: $.trim(formUtil.getValue('queryId')),
								executeAs: (myForm.select(".searchBlock form table input[name='executeAs']").is(':checked') ? 'Y':'N'),
								sqlArg: {}
							};
						}
						for(key in myForm.popupInfo.selData) {
							param['sqlArg'][key] = $.trim(myForm.popupInfo.selData[key]);
						}
						transaction(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00080/saveDynamicQueryResultList'+procType,param,function(data) {
							if(data.result) {
								if($.trim(data.result['executeAs']) == 'Y') {
									myForm.hideProgress();
									Message.alert('<lgcom:message code="note.runbackground"/>');
								} else {
									if(data.result['executeCount'] == 0) {
										Message.alert('<lgcom:message code="note.nodata"/>');
										// 진행바 숨기기
										myForm.hideProgress();
										return;
									}
									trace('fileId = ' + $.trim(data.result['fileId']));
									formUtil.setValue({
										sessionId:$.trim(data.result['sessionId']),
										queryId:$.trim(data.result['queryId']),
										fileId:$.trim(data.result['fileId'])
									});
									/* 생성된 목록을 조회한다. */
									var param1 = {
										sessionId: $.trim(formUtil.getValue('sessionId')),
										queryId: $.trim(formUtil.getValue('queryId'))
									};
									grid.loadData(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00080/retrieveDynamicQueryResultList', param1, function(data) {
										// 진행바 숨기기
										myForm.hideProgress();
									});
								}
							}
							// 진행바 숨기기
							myForm.hideProgress();
						}, function(error) {
							// 진행바 숨기기
							myForm.hideProgress();
						});
					}
					myForm.popupInfo = null;
					myForm.popupInfo = {};
				},function() {
					myForm.popupInfo = null;
					myForm.popupInfo = {};
				});
				break;
			case 'export':
				var cgrid = grid.getGridBase();
				if($.trim(formUtil.getValue('sessionId')) == '') {
					Message.alert('<lgcom:message code="error.preexec"/>');
					return;
				}
				if($.trim(formUtil.getValue('queryId')) == '') {
					Message.alert('<lgcom:message code="error.preexec"/>');
					return;
				}
				if(cgrid.getItemCount() == 0) {
					Message.notify('<lgcom:message code="note.nodata"/>');
					return;
				}
				var downloader = new Downloader( myForm );
				if(procType == '2') {
					if($.trim(formUtil.getValue('fileId')) == '') return;
					// 기존 파일 다운로드
					downloader.attachment($.trim(formUtil.getValue('fileId')),function() {},function() {},'LGCOM');
				} else {
					// POI Excel File
					//downloader.excelDynamicQuery(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00080/exportDynamicQueryExcel',formUtil.getValue());
					// CSV File
					downloader.csvDynamicQuery(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00080/exportDynamicQueryExcel',formUtil.getValue());
				}
				break;
			case 'history':
				myForm.popupInfo = null;
				myForm.popupInfo = {};
				var pop1 = new Popup(myForm,DQ_CONTEXT_PATH,'M_LGUTLC_1159','<lgcom:message code="TodayList"/>');
				pop1.setSize(880,450);
				pop1.open(function() {
					if(typeof(myForm.popupInfo['myInterval']) != 'undefined') clearInterval(myForm.popupInfo['myInterval']);
					if(myForm.popupInfo['histRow']) {
						trace(myForm.popupInfo['histRow']);
						/* 선택된 항목을 출력한다. */
						formUtil.setValue({
							accessGroup: $.trim(myForm.popupInfo.histRow.accessGroup),
							sessionId: $.trim(myForm.popupInfo.histRow.sessionId),
							queryId: $.trim(myForm.popupInfo.histRow.queryId),
							queryName: $.trim(myForm.popupInfo.histRow.queryName),
							queryDesc: $.trim(myForm.popupInfo.histRow.queryDesc)
						});
						// 조회조건을 세팅한다.
						initialSearchCondition();
						drawSearchCondition(JSON.parse($.trim(myForm.popupInfo.histRow.queryArgs)));
						// Query ID로 컬럼을 조회한 후 Grid를 생성한다.
						var param = formUtil.getValue();
						transaction_sync(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00080/retrieveDynamicQueryColumnList',param,function(data) {
							if(data.result) {
								makeGridColumn(data.result);
								/* 생성된 목록을 조회한다. */
								var param1 = {
									sessionId: $.trim(formUtil.getValue('sessionId')),
									queryId: $.trim(formUtil.getValue('queryId'))
								};
								grid.loadData(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00080/retrieveDynamicQueryResultList',param1);
								myForm.popupInfo = null;
								myForm.popupInfo = {};
							}
						});
					}
					myForm.popupInfo = null;
					myForm.popupInfo = {};
				},function() {
					if(typeof(myForm.popupInfo['myInterval']) != 'undefined') clearInterval(myForm.popupInfo['myInterval']);
					myForm.popupInfo = null;
					myForm.popupInfo = {};
				});
				break;
			case 'popup':
				if($.trim(formUtil.getValue('accessGroup')) == '') {
					Message.alert('<lgcom:message code="error.mustSelected" arguments="<lgcom:message code='AccessGroup'/>"/>');
					return;
				}
				// 기존 조회조건 초기화
				myForm.select(".dataBlock form table tbody").empty();
				myForm.setManagedLayout(zeroRowLayout);
				myForm.popupInfo['accessGroup'] = $.trim(formUtil.getValue('accessGroup'));
				myForm.popupInfo['queryName'] = $.trim(formUtil.getValue('queryName'));
				// Popup Open
				var pop = new Popup(myForm,DQ_CONTEXT_PATH,'M_LGUTLC_1157','<lgcom:message code="DqSearch"/>');
				pop.setSize(650,450);
				pop.open(function() {
					if(myForm.popupInfo.row) {
						formUtil.setValue({
							queryId: $.trim(myForm.popupInfo.row['queryId']),
							queryName: $.trim(myForm.popupInfo.row['queryName']),
							queryDesc: $.trim(myForm.popupInfo.row['queryDesc'])
						});
						var param = formUtil.getValue();
						// Query ID로 컬럼을 조회한 후 Grid를 생성한다.
						transaction_sync(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00080/retrieveDynamicQueryColumnList',param,function(data) {
							if(data.result) {
								makeGridColumn(data.result);
								myForm.popupInfo = null;
								myForm.popupInfo = {};
							}
						});
					}
				},function() {
					myForm.popupInfo = null;
					myForm.popupInfo = {};
				});
				break;
		}
	});
	/* Access Group 변경시 Use Query 초기화 */
	myForm.addEvent('change',".searchBlock form select[name='accessGroup']",function(event) {
		// Session ID, Query ID, Query Name, Query Desc 초기화
		formUtil.setValue({sessionId:'',queryId:'',queryName:'',queryDesc:''});
	});
	/* Query Name 값이 없을시 ID 및 설명 초기화 */
	myForm.addEvent('change',".searchBlock form input[name='queryName']",function(event) {
		if($.trim($(this).val()) == '') {
			// Session ID, Query ID, Query Name, Query Desc 초기화
			formUtil.setValue({sessionId:'',queryId:'',queryName:'',queryDesc:''});
		}
	});
	/* 쿼리가 변경될 경우 */
	myForm.addEvent('change',".searchBlock .form input[name='queryName']",function(event) {
		if($.trim(formUtil.getValue('accessGroup')) == '') {
			Message.alert('<lgcom:message code="error.mustSelected" arguments="<lgcom:message code='AccessGroup'/>"/>');
			return;
		}
		// 기존 조회조건 초기화
		myForm.select(".dataBlock form table tbody").empty();
		myForm.setManagedLayout(zeroRowLayout);
		myForm.popupInfo['accessGroup'] = $.trim(formUtil.getValue('accessGroup'));
		myForm.popupInfo['queryName'] = $.trim(formUtil.getValue('queryName'));
		// Popup Open
		var pop = new Popup(myForm,DQ_CONTEXT_PATH,'M_LGUTLC_1157','<lgcom:message code="DqSearch"/>');
		pop.setSize(650,450);
		pop.open(function() {
			if(myForm.popupInfo.row) {
				formUtil.setValue({
					queryId: $.trim(myForm.popupInfo.row['queryId']),
					queryName: $.trim(myForm.popupInfo.row['queryName']),
					queryDesc: $.trim(myForm.popupInfo.row['queryDesc'])
				});
				var param = formUtil.getValue();
				// Query ID로 컬럼을 조회한 후 Grid를 생성한다.
				transaction_sync(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00080/retrieveDynamicQueryColumnList',param,function(data) {
					if(data.result) {
						makeGridColumn(data.result);
						myForm.popupInfo = null;
						myForm.popupInfo = {};
					}
				});
			}
		},function() {
			myForm.popupInfo = null;
			myForm.popupInfo = {};
		});
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	/* Grid 컬럼이 없을 경우 세팅할 Dummy */
	var dummyColumns = [{
		width:100,
		header: {text:''}
	}];
	/*** 내부 함수 ***/
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		grid.useProgress( false );
		grid.setColumns([{
			width:100,
			header: {text:''}
		}]);
		grid.setOptions({
			grid: {
				hideDeletedRows: false,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				stateBar: {visible:false},
				footer: {visible:false},
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
				},
				header: {
					resizable: true
				}
			},
			dataProvider: {
				insertable: true,
				updatable: true,
				deletable: true,
				softDeleting: true,
				deleteCreated: true
			},
			display: { fitStyle: 'none' }
		});
		// Context Menu Set
		grid.setContextMenu();
		return grid;
	}
	/* 그리드 컬럼 생성 */
	function makeGridColumn(columnList) {
		var fields = [
			{ fieldName: 'sessionId', dataType: 'number' },
			{ fieldName: 'queryId', dataType: 'number' }
		];
		var columns = [];
		var colIdx = 1;
		for(var i=0; i < columnList.length; i++) {
			var cIdx = ((colIdx < 10) ? '0'+colIdx:colIdx+'');
			var field = { fieldName: 'f'+cIdx };
			if($.trim(columnList[i].dataType) == 'N') field['dataType'] = 'number';
			fields.push(field);

			var column = {
				name: 'f'+cIdx,
				fieldName: 'f'+cIdx,
				width: (($.trim(columnList[i].columnWidth) == '') ? 100:$.trim(columnList[i].columnWidth)-0),
				header: { text: $.trim(columnList[i].columnPrompt) },
				renderer: {showTooltip:true},
				editable: false
			};
			if($.trim(columnList[i].dataType) == 'N') {
				column['styles'] = {textAlignment:'far', numberFormat:'#,###.##'};
			}
			columns.push(column);
			colIdx++;
		}
		// Grid Field Set
		grid.setFields(fields);
		// Grid Column Set
		if(columns.length > 0) {
			grid.setColumns(columns);
		} else {
			grid.setColumns(dummyColumns);
		}
	}
	/* 조회조건 초기화 */
	function initialSearchCondition() {
		// 기존 조회조건 초기화
		myForm.select(".dataBlock form table tbody").empty();
		myForm.setManagedLayout(zeroRowLayout);
	}
	/* 조회조건을 쓴다. */
	function drawSearchCondition(args) {
		/* 입력된 Parmeter를 화면에 그린다. */
		var idx = 0;
		var tr;
		for(key in args) {
			if((idx % 4) == 0) {
				if(tr) {
					myForm.select(".dataBlock form table tbody").append(tr);
				}
				tr = $('<tr></tr>');
			}
			var th = $('<th></th>');
			th.attr('scope','col');
			th.html(key);
			tr.append(th);
			var td = $('<td></td>');
			var input = $('<input type="text"/>');
			//input.prop('readonly',true);
			input.prop('disabled',true);
			input.val(args[key]);
			td.append(input);
			tr.append(td);
			idx++;
		}
		var remainCellCnt = 0;
		if(tr) {
			if((idx % 4) > 0) {
				remainCellCnt = (4 - (idx % 4));
			}
			if(remainCellCnt > 0) {
				for(var k=0; k < remainCellCnt; k++) {
					tr.append($('<th scope="col"></th>'));
					tr.append($('<td></td>'));
				}
			}
			myForm.select(".dataBlock form table tbody").append(tr);
		}
/*		
		if(Math.ceil(idx / 4) == 0) {
			myForm.setManagedLayout(zeroRowLayout);
		} else if(Math.ceil(idx / 4) == 1) {
			myForm.setManagedLayout(singleRowLayout);
		} else if(Math.ceil(idx / 4) == 2) {
			myForm.setManagedLayout(dualRowLayout);
		} else if(Math.ceil(idx / 4) == 3) {
			myForm.setManagedLayout(thirdRowLayout);
		}
*/
		if(Math.ceil(idx / 4) == 0) {
			myForm.setLayout(zeroRowLayout);
		} else if(Math.ceil(idx / 4) == 1) {
			myForm.setLayout(singleRowLayout);
		} else if(Math.ceil(idx / 4) == 2) {
			myForm.setLayout(dualRowLayout);
		} else if(Math.ceil(idx / 4) == 3) {
			myForm.setLayout(thirdRowLayout);
		}
	}
};

LGUTLC00080.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGUTLC00080();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Dynamic Query</h2>
	</div>
	<div class="searchBlock">
		<form class="search-wrap form" method="post" action="">
			<input type="hidden" name="sessionId"/>
			<input type="hidden" name="queryId"/>
			<input type="hidden" name="fileId"/>
				<table class="table table-condensed">
					<colgroup>
						<col width="90" />
						<col width="110" />
						<col width="90" />
						<col width="200" />
						<col width="220" />
						<col width="200" />
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><label class="required"><i class="asterisk">*</i><lgcom:message code="AccessGroup"/></label></th>
							<td><select name="accessGroup" class="form-control input-sm input-require"></select></td>
							<th scope="col"><label class="required"><i class="asterisk">*</i><lgcom:message code="UseQueryName" /></label></th>
							<td>
								<div class="input-group input-group-sm input-search input-require">
									<input type="text" name="queryName" class="form-control input-sm  required" placeholder=""/>
									<span class="input-group-btn">
										<button class="btn btn-default ico-lgd find" type="button" data-action="popup">
											<span class="fa fa-search" aria-hidden="true"></span>
										</button>
									</span>
								</div>
							</td>
							<td><input type="text" name="queryDesc" class="form-control input-sm" placeholder="<lgcom:message code='placeholder.desc'/>" disabled="disabled" /></td>
							<td align="center">
								<div class="checkbox checkbox-uxp checkbox-inline">
									<input type="checkbox" name="executeAs"/>
									<label><lgcom:message code="RunAsBack"/></label>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="execute"><lgcom:message code="execute" /></button>
		</form>
	</div>
	<div class="gridControls module-group text-right">
		<div class="btn-toolbar">	
			<div class="btn-group">
				<button class="btn btn-default btn-sm" type="button" data-action="export"><span class="ico ico-excel-down"></span> <lgcom:message code="Download"/></button>
			</div>	
			<div class="btn-group">
				<button class="btn btn-gray btn-sm" type="button" data-action="history"><lgcom:message code="TodayList"/></button>
			</div>	
		</div>	
	</div>
	<div class="dataBlock">	    
		<form class="form" method="post" action="">
				<table class="table table-condensed">
					<colgroup>
						<col width="10%"/>
						<col width="15%"/>
						<col width="10%"/>
						<col width="15%"/>
						<col width="10%"/>
						<col width="15%"/>
						<col width="10%"/>
						<col width="15%"/>
					</colgroup>
					<tbody>
					</tbody>
				</table>
		</form>
	</div>
	<div class="contentGrid grid-wrap">
		<div class="grid dynamicQueryGrid"></div>
	</div>
	</section>
</div>
</body>
</html>