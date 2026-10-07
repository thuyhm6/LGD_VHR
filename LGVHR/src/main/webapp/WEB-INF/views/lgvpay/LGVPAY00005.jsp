<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVPAY00005.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2017 LG CNS,  All rights reserved..

    설 명 : 급여대상자 관리
    작성자 : bakderia
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script src="/lgvhr/static/js/lgvatt.js"></script>
<script type="text/javascript">
var LGVPAY00005 = function() {
	var myForm = this;
    var _this = this;
	var result;
	// Form Util 선언
	var srchForm = '.searchBlock form';
	var srchFormUtil = new FormUtil( myForm, srchForm );
	var gridContent = new FormUtil(myForm,'.gridContent form');
	
 	//필수항목 체크
   	var validator = new Validator( myForm, srchForm );
	
   	validator.setRule( {
    	option: {placement: 'right'},
	    rules: {
	    	calculationSetName: {required:true}
	    },
	    messages: {
	    	calculationSetName: {required:'<lgcom:message code="error.required" arguments="<lgcom:message code='calculationSetName'/>" />'}
	    }
    });
   	
   	myForm.setLayout( [ 
   	        		{ name : "searchBlock", left : 0, right : 0, top : 0 },
   	        		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
   	        	    { name : "gridContent", left : 0, right : 0, top : "gridControls", bottom : 0 }
   	        	]);
	
 	// 그리드 선언
	var grid = buildGrid('.calculationEmployeeGrid');
 	
	//파일 매니저 초기화 
    var fileManager = new FileManager( myForm, { moduleCode : "LGCOM", fileCount : 3 } );
	
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	
	// 팝업 데이터 정의 searchMode:single(단수),multi(복수)
	myForm.popupInfo = {
		calculationPopup   : {popupKind:'', confirmKind:'', calculationSetId:'', calculationSetName:'', calculationData:[]},
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
		var calculationSetId = srchFormUtil.getValue("calculationSetId");
		switch( action ) {
		case 'search':
			grid.getGridBase().cancel();
			var param = srchFormUtil.getValue();
			if(validator.isValid()) {
				grid.loadData("lgvhr", "lgvpay/LGVPAY00005/retrieveCalSetEmpList", param, function(data) {
					if( grid.getRowCount() == 0 ) {
						Message.alert('<lgcom:message code="note.nodata"/>');
						return;
					};
				});
			}else{
				myForm.select(".searchBlock form input[name='calculationSetName']").focus();
			}
			break;
		case 'insert':
			if(isNull(calculationSetId)) {
				Message.alert('<lgcom:message code="note.pay.searchCalSet"/>');
				return;
			}
			var cgrid = grid.getGridBase();
			cgrid.commit();
			var curr = cgrid.getCurrent();
			
			if(curr.itemIndex < 0) {
				cgrid.beginAppendRow();
			}else {
				cgrid.beginInsertRow(curr.itemIndex);
			}
			
			break;
		case 'save':
			var grid1 = grid.getGridBase();
			var param = {};
			var empMap = new Map();
			var isDupFlag = false;
			
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
			
			//var gridArr = fncArrangeMultiLineGridAll(grid);
			//param["empList"] = gridArr;
		
			if(isNull(calculationSetId)) {
				Message.alert('<lgcom:message code="note.pay.searchCalSet"/>');
				return;
			}
			
			for(var i=0; i < grid1.getItemCount(); i++) {
				// 삭제건은 제외
				if(grid1.getDataProvider().getRowState(grid1.getDataRow(i)) == 'deleted') continue;
				
				//동일사번 입력체크 alert
				if(empMap.containsKey(grid1.getValue(i,'employeeNo'))) {
					dupEmployeeNo = grid1.getValue(i,'employeeNo');
					isDupFlag = true;
					continue;
				}
				empMap.put(grid1.getValue(i,'employeeNo'),1);
			}
			if(isDupFlag) {
				Message.alert('<lgcom:message code="error.dupEmpNo" arguments="'+dupEmployeeNo+'"/>');
				return;
			}
				
			Message.confirm('<lgcom:message code="question.save"/>', function() {
				grid.useProgress(true);
				grid.saveChanges('lgvhr','lgvpay/LGVPAY00005/saveCalSetEmp', function(data, gridData ) {
					Message.alert('<lgcom:message code="note.saved"/>');
					myForm.select(".searchBlock button[data-action='search']").trigger('click');
				});
			});
			break;
			
		case 'delete':
			grid.getGridBase().deleteSelection(true);
			break;
			
		case 'directCSV':
			if(validator.isValid()) {
				Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
					var downloader = new Downloader( myForm );
					downloader.csvDirectDownload("lgvhr", "LGVPAY00005.createDirectCSVDownloadData", srchFormUtil.getValue());
				});
			}
			break;
			
		case 'excelDownload':
			if(validator.isValid()) {
				Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
					var param = srchFormUtil.getValue();
					var downloader = new Downloader( myForm );
					downloader.excel( "lgvhr", "lgvpay/LGVPAY00005/createExcelExportData", param );
				});
			}
			break;
			 
		case 'excelUpload':
			if(isNull(calculationSetId)) {
				Message.alert('<lgcom:message code="note.pay.searchCalSet"/>');
				return;
			}
			var uploader = new ExcelUploader("lgvhr", "LGVPAY00005", {});
                uploader.open(  processExcelUploadPostProcess );
			break;
		// 급여대상자 SET 조회 팝업
	    case "openPopupCalSet" :
            console.log("openPopupCalSet");
            srchFormUtil.setValue({calculationSetId : '', calculationSetName : ''});
            grid.clear();
            var _popup = _this.popupInfo.calculationPopup;
            _popup.popupKind    = "";
            _popup.confirmKind  = "";

            var popup = new Popup( _this,'lgvhr', 'M_LGVPAY_1018', '<lgcom:message code="label.pay.calculationSet"/>' );
            popup.setSize(800,494);
            popup.open( function(){
            	srchFormUtil.setValue({calculationSetId  :_popup.calculationData[0].calculationSetId});
            	srchFormUtil.setValue({calculationSetName   :_popup.calculationData[0].calculationSetName});
            });
            _popup.calculationData = [];
        	break;
     	// 유저 검색 팝업
	    case "openPopupApprover" :
            console.log("openPopupApprover");
            var _popup = _this.popupInfo.userPopup;
            _popup.searchMode   = "single";
            _popup.popupKind    = "";
            _popup.confirmKind  = "";
            _popup.employeeNo = srchFormUtil.getValue("employeeNo");
            _popup.employeeName = srchFormUtil.getValue("employeeName");
            _popup.fseYn = "N";
            _popup.flsaYn = "N";
        	fncSearchEmpInfoInit();
            
            var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
            popup.setSize(800,494);
            popup.open( function(){
            	srchFormUtil.setValue({employeeNo  :_popup.userData[0].employeeNo});
            	srchFormUtil.setValue({employeeName   :_popup.userData[0].employeeName});
            });
            _popup.userData = [];
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
		emplyoeePopup(itemIndex,column.name,gridRow.userId,gridRow.roleName);
	};
	//user 검색팝업
	function emplyoeePopup(rowIdx, colName, applicationUserId, keyword) {
		var cgrid = grid.getGridBase();
		myForm.popupInfo.userPopup = { searchMode : "single", fseYn:"N", flsaYn:"N"};
		var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
		popup.setSize( 1000, 528 );
		popup.open( function(){
			var array = myForm.popupInfo.userPopup.userData;
			if(array.length == 0) {
				return;
			}else{
				transaction('lgvhr','lgvpay/LGVPAY00005/retrieveEmployeeInfo',{'employeeNo':array[0].employeeNo}, function(data) {
					cgrid.setValue(rowIdx,'employeeNo',data.result.employeeNo);
					cgrid.setValue(rowIdx,'employeeName',data.result.employeeName);
					cgrid.setValue(rowIdx,'gradeCode',data.result.gradeCode);
					cgrid.setValue(rowIdx,'gradeTitleName',data.result.gradeTitleName);
					cgrid.setValue(rowIdx,'organizationName',data.result.organizationName);
					cgrid.setValue(rowIdx,'empCategoryName',data.result.empCategoryName);
					cgrid.setValue(rowIdx,'workTypeName',data.result.workTypeName);
					cgrid.setValue(rowIdx,'dateHireSubsidiary',data.result.dateHireSubsidiary);
					cgrid.setValue(rowIdx,'dateRetire',data.result.dateRetire);
				});
			}
		});
	}
	function processExcelUploadPostProcess( sessionId ) { 
		param.sessionId = sessionId;
		param.calculationSetId = srchFormUtil.getValue("calculationSetId");
		//반드시 transaction_sync 를 써야합니다 !!
		transaction_sync('lgvhr','lgvpay/LGVPAY00005/createCalEmpUpload',param, function(data) {
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
		    { fieldName: 'employeeNo'  				, dataType:'text'},
		    { fieldName: 'employeeName'         	, dataType:'text'},
		    { fieldName: 'gradeCode'         		, dataType:'text'},
		    { fieldName: 'gradeTitleName'    		, dataType:'text'},
		    { fieldName: 'organizationName'         , dataType:'text'},
		    { fieldName: 'empCategoryName'         	, dataType:'text'},
		    { fieldName: 'workTypeName'         	, dataType:'text'},
		    { fieldName: 'dateHireSubsidiary'       , dataType:'text'},
		    { fieldName: 'dateRetire'         		, dataType:'text'}
		]);
		// Lookup 설정
		grid.setLookups({});
		//컬럼 설정
		grid.setColumns([
 				{
					name:'employeeNo',
					fieldName:'employeeNo',
					width:100,
					header: {text:'<lgcom:message code="label.pay.employeeNo" />', required : true},
					styles: {textAlignment:'center'},
					button: 'action',
					editable: false
				},
				{
					name:'employeeName',
					fieldName:'employeeName',
					width:200,
					header: {text:'<lgcom:message code="label.pay.employeeName" />'},
					styles: {textAlignment:'near'},
					editable : false
				},
				{
					name:'gradeCode',
					fieldName:'gradeCode',
					width:100,
					header: {text:'<lgcom:message code="label.pay.grade"/>'},
					styles: {textAlignment:'center'},
					editable : false
				},	
				{
					name:'gradeTitleName',
					fieldName:'gradeTitleName',
					width:150,
					header: {text:'<lgcom:message code="label.pay.title" />'},
					styles: {textAlignment:'near'},
					editable : false
				},	
				{
					name:'organizationName',
					fieldName:'organizationName',
					width:300,
					header: {text:'<lgcom:message code="label.pay.organizationName" />'},
					styles: {textAlignment:'near'},
					editable : false
				},	
				{
					name:'empCategoryName',
					fieldName:'empCategoryName',
					width:150,
					type: 'data',
					header: {text:'<lgcom:message code="label.pay.empCategory" />'},
					styles: {textAlignment:'center'},
					editable : false
				},	
				{
					name:'workTypeName',
					fieldName:'workTypeName',
					width:350,
					type: 'data',
					header: {text:'<lgcom:message code="label.pay.workType" />'},
					styles: {textAlignment:'near'},
					editable : false
				},	
				{
					name:'dateHireSubsidiary',
					fieldName:'dateHireSubsidiary',
					width:120,
					type: 'data',
					header: {text:'<lgcom:message code="label.pay.hireDate" />'},
					styles: {textAlignment:'center'},
					editable : false
				},	
				{
					name:'dateRetire',
					fieldName:'dateRetire',
					width:120,
					type: 'data',
					header: {text:'<lgcom:message code="label.pay.resignationDate" />'},
					styles: {textAlignment:'center'},
					editable : false
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
}

LGVPAY00005.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVPAY00005();
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
						<col width="150"/>
						<col width="220"/>
						<col width="150"/>
						<col width="100"/>
						<col width="160"/>
						<col width="200"/>
					</colgroup>
					<tbody>
						<tr>
		                    <th><i class="asterisk">*</i><label class="required" keyword><lgcom:message code="label.pay.calculationSet"/></label></th>
		                    <td>
		                		<div class="input-group input-group-sm input-search">
		                			<input type="hidden" name="calculationSetId" />
	                                <input class="form-control input-sm _find_origin_" name="calculationSetName" type="text" data-action="emptyAndPopup" readonly>
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupCalSet">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
		                	</td>
		                	<th><label><lgcom:message code="label.pay.employeeNo" /></label></th>
								<td>
			                		<div class="input-group input-group-sm input-search">
		                                <input class="form-control input-sm _find_origin_" name="employeeNo" type="text" data-action="emptyAndPopup">
		                                <span class="input-group-btn">
		                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupApprover">
		                                        <span class="fa fa-search" aria-hidden="true"></span>
		                                    </button>
		                                </span>
		                            </div>
			                	</td>
							<th><label><lgcom:message code="label.pay.employeeName" /></label></th>
								<td><input type="text" class="form-control input-sm" name="employeeName"></td>
								<td></td>
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
					  <%-- <button type="button" class="btn btn-default dropdown-toggle btn-sm" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
					    <span class="ico ico-excel-up" aria-hidden="true"></span> <lgcom:message code="Upload"/><span class="caret"></span>
					  </button> --%>
					  <button class="btn btn-default btn-sm" type="button" data-action="excelUpload"><span class="ico ico-excel-up"></span><lgcom:message code="Upload" /></button>
				</div>
				<div class="btn-group">		
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete"><span class="fa fa-minus" aria-hidden="true"></span> <lgcom:message code="Delete"/></button>
				</div>
				<div class="btn-group">	
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save" data-access="LGVPAY00005/saveCalSetEmp"><lgcom:message code="save"/></button>				
				</div>
			</div>			
		</div>
	<div class="gridContent grid-wrap">
		<div class="grid calculationEmployeeGrid"></div>
	</div>
	</section>
</div>
</body>
</html>
