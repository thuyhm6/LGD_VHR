<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT00015.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : Request for OS KPI Master
    작성자 : HMT_20260401
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<script type="text/javascript">
var LGVATT00015 = function() {
	var myForm = this;
    var _this = this;
	var result;
	// Form Util 선언
	var srchForm = '.searchBlock form';
	var srchFormUtil = new FormUtil( myForm, srchForm );
	var gridContent = new FormUtil(myForm,'.gridContent form');
	
 	//필수항목 체크
   	var validator = new Validator( myForm, srchForm );
	
   	
   	
   	myForm.setLayout( [ 
   	        		{ name : "searchBlock", left : 0, right : 0, top : 0 },
   	        		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
   	        	    { name : "gridContent", left : 0, right : 0, top : "gridControls", bottom : 0 }
   	        	]);
	
   	transaction_sync( "lgvhr","lgvatt/LGVATT50030/retrieveAttendanceYyyymm", {}, function(data) {
    	if ( data.result ) {
    		yyyymmList = data.result.yyyymmList;
    		
    		srchFormUtil.initCombo("timeAndAttendanceYyyymm", data.result.yyyymmList,   {selectAll:false});
    		srchFormUtil.setValue({timeAndAttendanceYyyymm: data.result.currentYyyymmData.attendanceYyyymm});
    	}
    });
 	// 그리드 선언
	var grid = buildGrid('.requestOsKpiMasterGrid');
	var gridView = grid.getGridBase();
	var provider = grid.getDataProvider();
 	
	//파일 매니저 초기화 
    var fileManager = new FileManager( myForm, { moduleCode : "LGCOM", fileCount : 3 } );
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	
	this.addEvent('change',"select[name='timeAndAttendanceYyyymm']",function(event) {
		search();
	});
	
	// 팝업 데이터 정의 searchMode:single(단수),multi(복수)
	myForm.popupInfo = {
		userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', attDate:'', userData:[]},
        returnPopup : {returnComment:''}
    };

	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ) {
		case 'search':
			search();
			break;

		case 'save':
			var grid1 = grid.getGridBase();
			var timeAndAttendanceYyyymm = $.trim(myForm.select(".searchBlock select[name='timeAndAttendanceYyyymm']").val());
			var param = {};
			var empMap = new Map();
			
			try {
				grid.getGridBase().commit();
			} catch(e) {
				Message.alert(e.message);
				return;
			}
			if( grid.getRowCount() == 0 ) {
				Message.alert('<lgcom:message code="note.nodata"/>');
				return;
			};
			if(!grid.isChanged()) {
				Message.alert('<lgcom:message code="error.noChangedData"/>');
				return;
			}
		
			Message.confirm('<lgcom:message code="question.save"/>', function() {
				grid.useProgress(true);
				grid.saveChanges('lgvhr','lgvpay/LGVATT00015/saveRequestOsKpiMaster', function(data) {
					Message.alert('<lgcom:message code="note.saved"/>');
					myForm.select(".searchBlock button[data-action='search']").trigger('click');
				});
			});
			break;
			
		case 'directCSV':
			if(validator.isValid()) {
				Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
					var downloader = new Downloader( myForm );
					downloader.csvDirectDownload("lgvhr", "LGVATT00015.createDirectCSVDownloadData", srchFormUtil.getValue());
				});
			}
			break;
			
		case 'excelDownload':
			if(validator.isValid()) {
				Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
					var param = srchFormUtil.getValue();
					var downloader = new Downloader( myForm );
					downloader.excel( "lgvhr", "lgvpay/LGVATT00015/createExcelExportData", param );
				});
			}
			break;
			 
		case 'excelUpload':
			var timeAndAttendanceYyyymm = $.trim(myForm.select(".searchBlock select[name='timeAndAttendanceYyyymm']").val());
			if( timeAndAttendanceYyyymm == '' ) {
				Message.alert('<lgcom:message code="note.nodata"/>');
				return;
			};
			var uploader = new ExcelUploader("lgvhr", "LGVATT00015", {});
                uploader.open(  processExcelUploadPostProcess );
			break;
			
		}
	});
	
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	//사번 또는 성명 클릭 시 값 초기화
    myForm.addEvent ( "click", ".searchBlock form input[name='employeeNo'], input[name='employeeName']", function(event) {
    	fncSearchEmpInfoInit();
    });
  	//사번, 성명값 초기화
	function fncSearchEmpInfoInit() { 
		srchFormUtil.setValue({employeeNo : '', employeeName : ''});		
	}
	grid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		// 신규행이 아니면 employeeNo 컬럼 편집 불가
		if(!editable) {
			cgrid.setColumnProperty('employeeNo','editable',false);
			cgrid.setColumnProperty('employeeNo','button','none');
			// 삭제버튼 활성화
			//myForm.select(".gridControls button[data-action='delete']").attr('disabled','disabled');
		} else {
			cgrid.setColumnProperty('employeeNo','editable',true);
			cgrid.setColumnProperty('employeeNo','button','action');
			// 삭제버튼 비활성화
			//myForm.select(".gridControls button[data-action='delete']").removeAttr('disabled');
		}
	};
	//employeeNo 클릭 시 user검색 팝업호출
	grid.getGridBase().onCellButtonClicked = function(cgrid, itemIndex, column) {
		cgrid.commitEditor();
		var currRow = cgrid.getCurrent();
		var gridRow = cgrid.getValues(currRow.itemIndex);
	};
	//Search
	function search() {
		grid.getGridBase().cancel();
		var param = srchFormUtil.getValue();
		if(validator.isValid()) {
			grid.loadData("lgvhr", "lgvpay/LGVATT00015/retrieveRequestOsKpiMasterList", param, function(data) {
				if( grid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
			});
		}
	}

	function processExcelUploadPostProcess( sessionId ) { 
		param.sessionId = sessionId;
		param.timeAndAttendanceYyyymm = $.trim(myForm.select(".searchBlock select[name='timeAndAttendanceYyyymm']").val());
		//반드시 transaction_sync 를 써야합니다 !!
		transaction_sync('lgvhr','lgvpay/LGVATT00015/createRequestOsKpiMasterUpload',param, function(data) {
			Message.notify('<lgcom:message code="note.completed"/>');
			myForm.select(".searchBlock button[data-action='search']").trigger('click');
		});
	}
	
	$("input[name=employeeNo]").keydown(function (key) {
		if(key.keyCode == 13) {
			myForm.select(".searchBlock button[data-action='openPopupApprover']").trigger('click');
		}
	});
	/***  내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		//필드 설정
		grid.setFields([
		    { fieldName:'timeAndAttendanceYyyymm' , dataType:'text'},
		    { fieldName:'requestSeqNo'            , dataType:'text'},
			{ fieldName:'organizationId'          , dataType:'text'},
			{ fieldName:'orgName'                 , dataType:'text'},
			{ fieldName:'vendorCode'              , dataType:'text'},
			{ fieldName:'vendorName'              , dataType:'text'},
			{ fieldName:'itemNo'	              , dataType:'text'},
			{ fieldName:'itemName' 	              , dataType:'text'},
			{ fieldName:'perfectTarget'           , dataType:'text'},
			{ fieldName:'perfectPoint'            , dataType:'number'},
			{ fieldName:'actualTarget'            , dataType:'text'},
			{ fieldName:'actualPoint'             , dataType:'number'},
			{ fieldName:'criteria'                , dataType:'text'}
		]);
		grid.setLookups({});
		//컬럼 설정
		grid.setColumns([
 				{	name:'requestSeqNo',    
					fieldName:'requestSeqNo',    
					width:0,  
					header: {text:'<lgcom:message code="label.att.requestSeqNo" />'},	 
					editable: false, 
					styles: {textAlignment:'near', background: '#e9e9e9' },
					footer: {text:'<lgcom:message code="Total" />', styleName: 'footer-text-style'}
				},
				{	name:'timeAndAttendanceYyyymm',    
					fieldName:'timeAndAttendanceYyyymm',    
					width:80,  
					header: {text:'<lgcom:message code="label.att.month" />'},	 
					editable: false, 
					styles: {textAlignment:'near', background: '#e9e9e9' },
					footer: {text:'<lgcom:message code="Total" />', styleName: 'footer-text-style'}
				},
				{	name:'vendorName',    
					fieldName:'vendorName',    
					width:80,  
					header: {text:'<lgcom:message code="label.att.itemNo" />'},	 
					editable: false, 
					styles: {textAlignment:'near', background: '#e9e9e9' }
				},
				{	name:'orgName',    
					fieldName:'orgName',    
					width:180,  
					header: {text:'<lgcom:message code="label.att.organization" />'},	 
					editable: false, 
					styles: {textAlignment:'near', background: '#e9e9e9' }
				},
				{	name:'itemNo',    
					fieldName:'itemNo',    
					width:0,  
					header: {text:'<lgcom:message code="label.att.itemNo" />'},	 
					editable: false, 
					styles: {textAlignment:'near', background: '#e9e9e9' }
				},
				{	name:'itemName',  
					fieldName:'itemName',  
					width:120, 
					header: {text:'<lgcom:message code="label.att.itemName" />'},	 
					editable: false, 
					styles: {textAlignment:'near', background: '#e9e9e9' }
				},
				{	name:'perfectTarget',
					fieldName:'perfectTarget',
					width:100,
					header: {text:'<lgcom:message code="label.att.perfectTarget"/>'},
					styles: {textAlignment:'center', background: '#e9e9e9'},						
					editable: false
				},
				{	name:'perfectPoint',
					fieldName:'perfectPoint',
					width:80,
					header: {text:'<lgcom:message code="label.att.perfectPoint"/>'},
					styles: {textAlignment:'far', background: '#e9e9e9'},
					editable: false,
					footer: {text:'', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}}, expression: "sum"}
				},
				{	name:'actualTarget',
					fieldName:'actualTarget',
					width:80,
					header: {text:'<lgcom:message code="label.att.actualTarget"/>'},
					styles: {textAlignment:'far'}
				},
				{	name:'actualPoint',
					fieldName:'actualPoint',
					width:80,
					header: {text:'<lgcom:message code="label.att.actualPoint"/>'},
					styles: {textAlignment:'far'},
					footer: {text:'', summary:{styles: {textAlignment: "far", numberFormat: "#,##0"}}, expression: "sum"}
				},
				{	name:'criteria',
					fieldName:'criteria',
					width:650,
				    renderer: {showTooltip: true},
					header: {text:'<lgcom:message code="label.att.criteria"/>'},
					styles: {textAlignment:'near', background: '#e9e9e9'},
					editable: false
				}
		]);
		//옵션 설정
		grid.setOptions({
			grid: {
				hideDeletedRows: false,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				footer: {visible:false},
				/* 상단 합계 표시 */
				header: {summary: {visible: true, 
					               styles: {background: "#e9e9e9",
					            	        borderLeft : "#dfdfdf,1",
					            	        borderRight : "#dfdfdf,1",
					            	        borderTop : "#dfdfdf,1",
					        				borderBottom : "#dfdfdf, 1",
					        				fontSize : 12,
					        				fontBold : "false",
					        				paddingLeft : 5,
					        				paddingRight : 5
					            	       }
				                    },
			             height:30
			            },
				paste: {enabled:false}, /*paste 기능막기 */
				sorting  : {enabled:false}, /*Sorting 기능을 막는다.*/
                sortMode : "explicit",
				edit: {
					insertable: true,
					appendable: true,
					updatable: true,
					deletable: true
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
	gridView.onCellEdited = function(grid, itemIndex, dataRow, field){
		grid.commit();
	}
}


LGVATT00015.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVATT00015();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2></h2> 
		</div>
		<div class="searchBlock">
			<form class="form search-wrap">
				<table class="table">
					<colgroup>
						<col width="50"/>
						<col width="100"/>
						<col width="150"/>
						<col width="160"/>
						<col width="160"/>
					</colgroup>
					<tbody>
						<tr>
							<th><label class="required"><lgcom:message code="label.att.month"/></label></th>
		                    <td>
		                        <div class="form-inline ">
                                	<select class="form-control input-sm input-require" name="timeAndAttendanceYyyymm" id="timeAndAttendanceYyyymm"></select>
                            	</div>
		                    </td>
		                	<th><lgcom:message code="label.att.vendorName" /></th>
							<td>
		                        <div class="form-inline ">
                               		<select class="form-control input-sm input-require" name="vendorCode" id="vendorCode"></select>
                            	</div>
		                    </td>
							</tr>
					</tbody>
				</table>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
			</form>
		</div>
		<%-- 그리드 버튼 영역 --%>
		<div class="gridControls module-group text-right">
			<div class="btn-toolbar">	
				<div class="btn-group">	
			        <button type="button" class="btn btn-default btn-sm" data-action="excelDownload"><span class="ico ico-excel-down"  aria-hidden="true"></span> <lgcom:message code="Download"/></button>
			        <button type="button" class="btn btn-default btn-sm" data-action="directCSV"><span class="ico ico-excel-down"  aria-hidden="true"></span> DirectCSV</button>
			     </div>
				<div class="btn-group">
					  <button class="btn btn-default btn-sm" type="button" data-action="excelUpload"><span class="ico ico-excel-up"></span><lgcom:message code="Upload" /></button>
				</div>
				<div class="btn-group">	
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save" data-access="LGVATT00015/saveRequestOsKpiMaster">
					<lgcom:message code="save"/></button>				
				</div>
			</div>			
		</div>
	<div class="gridContent grid-wrap">
		<div class="grid requestOsKpiMasterGrid"></div>
	</div>
	</section>
</div>
</body>
</html>
