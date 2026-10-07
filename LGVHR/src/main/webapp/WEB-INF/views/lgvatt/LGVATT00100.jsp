<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGVATT20450.jsp
    프로젝트명 : 베트남 근태 급여 시스템 구축

   Copyright(c) 2016 LG CNS,  All rights reserved..

    설 명 : PIC 조회 등록 삭제 화면
    작성자 : H.W.JANG
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGVATT00100 = function() {
	var myForm = this;
	var _this = this;
	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	var gridContent = new FormUtil(myForm,'.gridContent form');
	
	
	
	/*팝업관련*/
	myForm.popupInfo = {
        userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', attDate:'', userData:[]},
        returnPopup : {returnComment:''}
    };
	
	myForm.popupInfoOrg = {
	        orgPopup   : {searchMode:'single', popupKind:'', confirmKind:'', orgName:'',orgCode:'', orgData:[]},
	        returnPopup : {returnComment:''}
	};
	
	
	myForm.setLayout( [ 
		{ name : "searchBlock", left : 0, right : 0, top : 0 },
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock" },
	    { name : "gridContent", left : 0, right : 0, top : "gridControls", bottom : 0 }
	]);
	// 그리드 선언
	var grid = buildGrid('.orgContactListGrid');

	// Selection Mode 변경
    grid.setSelectMode(RealGrid.SELECTION_BLOCKLINE);

	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	// 화면 초기 세팅
	myForm.loadCompleted = function() {
		myForm.select(".searchBlock button[data-action='search']").trigger('click');
	};
	
	
    function processUserPopup() {
    	var _popup = _this.popupInfo.userPopup;
        
    	var grid1 = grid.getGridBase();
    	
    	_popup.searchMode   = "single";
        _popup.popupKind    = "";
        _popup.confirmKind  = "";
        _popup.employeeNo = '';
        _popup.employeeName = '';
        _popup.attDate = '';

        var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
        popup.setSize(800,494);
        popup.open( function(){
        
	        grid1.setValue(grid1.getCurrent().itemIndex,'employeeNumber',_popup.userData[0].employeeNo);
	        grid1.setValue(grid1.getCurrent().itemIndex,'fullNameLocal',_popup.userData[0].employeeName);
	        grid1.setValue(grid1.getCurrent().itemIndex,'gradeTitle',_popup.userData[0].employeeGrade);
	        grid1.commit();
	        
        });
        _popup.userData = [];
    }
    
    
    function processOrgPopup() {
    	var _popup = _this.popupInfoOrg.orgPopup;
        
    	var grid1 = grid.getGridBase();
    	
    	_popup.searchMode   = "single";
        _popup.popupKind    = "";
        _popup.confirmKind  = "";
        _popup.orgName = "";
        
        var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1014', 'Search Org' );
        popup.setSize(800,494);
        popup.open( function(){
        	grid1.setValue(grid1.getCurrent().itemIndex,'organizationId',_popup.orgData[0].organizationId);
            grid1.setValue(grid1.getCurrent().itemIndex,'organizationCode',_popup.orgData[0].organizationCode);
            grid1.setValue(grid1.getCurrent().itemIndex,'orgNameLocal',_popup.orgData[0].organizationName);
            grid1.commit();
            
        });
        _popup.orgData = [];
    }
		
	
	
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ) {
			case 'search':
				grid.getGridBase().cancel();
				
				var param = formUtil.getValue();
				
				if(formUtil.getValue('orgName') == ''){
					param.orgCode = '';
				}
				
				grid.loadData('lgvhr','lgvatt/LGVATT00100/retrieveOrgContactList',param);
				break;
			case 'insert':
				
				grid.getGridBase().cancel();
				
				grid.getGridBase().beginInsertRow(0);
				
				
				
				break;
			case 'delete':
				grid.getGridBase().deleteSelection(true);
				break;
			case 'save':
				try {
					grid.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				
		        if( grid.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				}
				
				if(!grid.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				
				
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					var param = formUtil.getValue();
					grid.useProgress(true);
					grid.saveChanges('lgvhr','lgvatt/LGVATT00100/saveContactList', function(data, gridData ) {
                        //키워드를 저장하는 함수를 호출하였다
                        myForm.sendKeyword( "commonCodeType", "codeTypeCode", gridData );
						
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
						
					
					});
				});
				break;
		    // 유저 검색 팝업
		    case "openPopupApprover" :
                var _popup = _this.popupInfo.userPopup;
                _popup.searchMode   = "single";
                _popup.popupKind    = "";
                _popup.confirmKind  = "";
                _popup.employeeNo = formUtil.getValue("employeeNo");
                _popup.employeeName = formUtil.getValue("employeeName");
                _popup.attDate = formUtil.getValue("attDate");

                var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
                popup.setSize(800,494);
                popup.open( function(){
                    formUtil.setValue({employeeNo  :_popup.userData[0].employeeNo});
                });
                _popup.userData = [];
                break;
       
            // 조직 검색 팝업
		    case "openPopupOrg" :
                var _popup = _this.popupInfoOrg.orgPopup;
                _popup.searchMode   = "single";
                _popup.popupKind    = "";
                _popup.confirmKind  = "";
                _popup.orgName = formUtil.getValue("orgName");
                
                var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1014', 'Search Org' );
                popup.setSize(800,494);
                popup.open( function(){
                    formUtil.setValue({orgName  :_popup.orgData[0].organizationName});
                    formUtil.setValue({orgCode  :_popup.orgData[0].organizationCode});
                });
                _popup.orgData = [];
                break;    
			case 'excelUpload':
				var uploader = new ExcelUploader("lgvhr", "LGVATT00100", {});
	                uploader.open(  processExcelUploadPostProcess );
				break; 
			case 'deleteVal':
				var uploader = new ExcelUploader("lgvhr", "LGVATT00100", {});
	                uploader.open(  processExcelDeletePostProcess );
				break;	
				
			
		}
	});
	
	
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	
	function processExcelUploadPostProcess( sessionId ) { 
		param.sessionId = sessionId;
		//반드시 transaction_sync 를 써야합니다 !!
		transaction_sync('lgvhr','lgvatt/LGVATT00100/insertOrgForPic',param, function(data) {
			Message.notify('<lgcom:message code="note.completed"/>');
			myForm.select(".searchBlock button[data-action='search']").trigger('click');
		});
	}
	
	function processExcelDeletePostProcess( sessionId ) { 
		param.sessionId = sessionId;
		//반드시 transaction_sync 를 써야합니다 !!
		transaction_sync('lgvhr','lgvatt/LGVATT00100/deletePermission',param, function(data) {
			Message.notify('<lgcom:message code="note.completed"/>');
			myForm.select(".searchBlock button[data-action='search']").trigger('click');
		});
	}
	
	/***  내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId );
		grid.setPagingMode(true);
		//필드 설정
		grid.setFields([
            { fieldName: 'organizationId'            , dataType:'text'},
		    { fieldName: 'organizationCode'          , dataType:'text'},
			{ fieldName: 'orgNameLocal'              , dataType:'text'},
			{ fieldName: 'employeeNumber'            , dataType:'text'},
			{ fieldName: 'fullNameLocal'             , dataType:'text'},
			{ fieldName: 'gradeTitle'                , dataType:'text'},
			
		]);
		
	    
		//컬럼 설정
		grid.setColumns([
				
				{
					name:'organizationId',
					fieldName:'organizationId',
					width:0,
					type: 'data',
					header: {text:'<lgcom:message code="OrganizationCode2" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'organizationCode',
					fieldName:'organizationCode',
					width:130,
					type: 'data',
					header: {text:'<lgcom:message code="OrganizationCode2" />'},
					styles: {textAlignment:'center'},
					editable : false
				},
				{
					name:'orgNameLocal',
					fieldName:'orgNameLocal',
					width:300,
					type: 'data',
					header: {text:'<lgcom:message code="OrganizationName" />'},
					styles: {textAlignment:'near'},
					button: 'action',
					editable : false
				},	
				{
					name:'fullNameLocal',
					fieldName:'fullNameLocal',
					width:200,
					header: {text:'<lgcom:message code="EmployeeName" />',required : true},
					styles: {textAlignment:'near'},
					button: 'action',
					editable: false
					
					
					
				},	
				{
					name:'employeeNumber',
					fieldName:'employeeNumber',
					width:150,
					type: 'data',
					header: {text:'<lgcom:message code="label.att.employeeNo2" />'},
					styles: {textAlignment:'center'},
					editable : false
				},	
				{
					name:'gradeTitle',
					fieldName:'gradeTitle',
					width:150,
					type: 'data',
					header: {text:'<lgcom:message code="Grade1" />'},
					styles: {textAlignment:'near'},
					editable : false,
				}
				
		]);
		//옵션 설정
		grid.setOptions({
			grid: {
				softDeleting: true,
				deleteCreated: true,
				hideDeletedRows:true,
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
					height: 40
				}
			},
			dataProvider: {
				insertable: true,
				updatable: true,
				deletable: true,
				softDeleting: true,
				deleteCreated: true
			}
				
		});

		// Context Menu Set
		grid.setContextMenu();
		
		grid.setValidations([
		 					{criteria: "value['fullNameLocal'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='EmployeeName'/>"/>',mode:'always',level:'error'}
		 				   ]);
		

		return grid;
	}
	
	grid.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		// 신규행이 아니면 Program ID 컬럼 편집 불가
		if(!editable) {
			cgrid.setColumnProperty('fullNameLocal','editable',false);
			cgrid.setColumnProperty('fullNameLocal','button','none');
			
			cgrid.setColumnProperty('orgNameLocal','editable',false);
			cgrid.setColumnProperty('orgNameLocal','button','none');
		} else {
			cgrid.setColumnProperty('fullNameLocal','editable',true);
			cgrid.setColumnProperty('fullNameLocal','button','action');
			
			cgrid.setColumnProperty('orgNameLocal','editable',true);
			cgrid.setColumnProperty('orgNameLocal','button','action');
		}
	};
	
	grid.getGridBase().onCellButtonClicked = function(cgrid, itemIndex, column) {
		cgrid.commitEditor();
		
		var currRow = cgrid.getCurrent();
		var gridRow = cgrid.getValues(currRow.itemIndex);
		
		if(column.name == 'fullNameLocal'){
			processUserPopup();
		}else{
			processOrgPopup();
		}
		
	};
	
	
	
	
	
}

LGVATT00100.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGVATT00100();
		form.init();
		form.loadCompleted();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
    <section class="page-content">
		<div class="pageHeader">
			<h2><lgcom:message code="UserList"/></h2> 
		</div>
		<div class="searchBlock">
		 <form class="form search-wrap">
		    <fieldset>	
			   <table class="table">
					<colgroup>
						<col width="90"/>
						<col width="220"/>
						<col width="60"/>
						<col width="180"/>
						<col width="90"/>
						<col width="120"/>
						<col width="*"/>
					</colgroup>
					<tbody>
						<tr>
		                    <th><label><lgcom:message code="label.att.organization" /></label></th>
		                    <td>
		                         <div class="input-group input-group-sm input-search">
	                                <input class="form-control input-sm _find_origin_" name="orgName" type="text" data-action="emptyAndPopup">
	                                <span class="input-group-btn">
	                                    <button class="btn btn-default ico-lgd find" type="button" data-action="openPopupOrg">
	                                        <span class="fa fa-search" aria-hidden="true"></span>
	                                    </button>
	                                </span>
	                            </div>
		                    </td>
		                    <input class="form-control input-sm _find_origin_" name="orgCode" type="hidden" data-action="emptyAndPopup"> 
		                    <th><label><lgcom:message code="label.att.employeeNo2" /></label></th>
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
		                </tr>
					</tbody>
				</table>
			 </fieldset>
			  <button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search" ><lgcom:message code="search" /></button>
			</form>
		</div>
		<div class="gridControls module-group text-right">
		 <div class="btn-toolbar">
			<div class="btn-group">
				<div class="btn-group">
					  <button class="btn btn-default btn-sm" type="button" data-action="excelUpload"><span class="ico ico-excel-up"></span><lgcom:message code="UploadAll" /></button>
					  <button class="btn btn-default btn-sm" type="button" data-action="deleteVal"><span class="ico ico-excel-up"></span><lgcom:message code="DeleteAll" /></button>
				</div>
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete"><span class="fa fa-remove" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
			</div>
			<div class="btn-group">					      
				<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save" ><lgcom:message code="save"/></button>
			</div>
		 </div>
	   </div>
		<div class="gridContent grid-wrap">
			<div class="grid orgContactListGrid"></div>
		</div>
	</section>
</div>
</body>
</html>
