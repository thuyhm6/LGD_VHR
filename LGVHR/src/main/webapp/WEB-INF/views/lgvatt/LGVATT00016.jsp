<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<jsp:useBean id="date" class="java.util.Date" />
<fmt:formatDate value="${date}" pattern="yyyy" var="currentYear" />

<%---------------------------------------------------------
    파일명 : LGVATT00016.jsp
    프로젝트명 : LGD BizWeb

    Copyright(c) 2020 LG CNS,  All rights reserved.

    설 명 : Annual Leave Days Info
    작성자 : 전승규
-------------------------------------------------------------%>

<c:set var="flg_vn_att_master" value="N"/>
<c:forEach var="roles" items="${sessionScope.USER_SESSION.roleList}">
    <c:if test="${roles.systemCode=='LGVHR' && roles.moduleCode=='LGVATT' && fn:indexOf(roles.roleCode,'VN_ATT_MASTER_USER')>=0 }">
        <c:set var="flg_vn_att_master" value="Y"/>
    </c:if>
</c:forEach>

<html lang="ko">
<head>
<title>Annual Leave Days History</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<style type="text/css">
</style>
<script type="text/javascript">

var LGVATT00016 = function(){
    var grid1;
    var _this = this;
    var myForm = this;
    var formUtil = new FormUtil(myForm,'.searchBlock form');
    var isAttMaster = ('<c:out value="${flg_vn_att_master}"/>' == 'Y')?true:false;

    /* Layout Setting 하측 고정, 상측 Flexible*/
	myForm.setLayout( [
		{ name  : "searchBlock", left : 0, right : 0, top : 0 },
		{ name  : "gridControls", left : 0, right : 0, top : "searchBlock"},
		{ name  : "content1", left : 0, right : 0, top : "gridControls", bottom : 0 }
	]);

  	//검색조건에 값을 입력하고 조회하면 방금 입력한 값을 저장하여 화면에 고정값으로 셋팅
    myForm.searchConditionControl( false );

	// Search Block combo
	var valueSet = new ValueSet("lgcom");
	valueSet.add('orgName', {valueSetId : 'LGVATT_LW_ADMIN_ORG_NAME', employeeNum : '${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}', subsidiaryCode : '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}'});
	valueSet.execute();

	formUtil.initCombo('orgName',valueSet.get('orgName'),{selectAll: true});

   	grid1 = buildGrid("LGVATT00016_grid1");

    grid1.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};

	myForm.popupInfo = {
		userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', userData:[]},
        returnPopup : {returnComment:''}
    };

	this.addEvent('change',"select[name='timeAndAttendanceYyyy']",function(event) {
		myForm.select(".searchBlock button[data-action='search']").trigger('click');
	});

	/*** 이벤트 핸들러  ***/
	this.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ){
		    case "search" :
		    	grid1.getGridBase().cancel();
				var param =  myForm.select(".searchBlock form").toJSON();

				grid1.loadData('lgvhr','lgvatt/LGVATT00016/retrieveAnnualLeave', param, function(data){

					if( grid1.getDataProvider().getRowCount() == 0 ) {
						Message.alert('<lgcom:message code="note.nodata"/>');
					} else {
						var index = {itemIndex: 0};
						grid1.getGridBase().setCurrent(index);

						// annual_leave_days가 이미 DB에 계산되어 있는(isCalculated === 'Y') 행은 체크박스를 체크할 수 없도록 막음
						for(var i=0; i<grid1.getDataProvider().getRowCount(); i++) {
							if(data.result[i]["isCalculated"] == 'Y') {
								grid1.getGridBase().setCheckable(i, false);
							}
						}
					}

				} );

				break;
			case 'insert':
				grid1.getGridBase().cancel();
				grid1.getGridBase().beginInsertRow(0);
				break;
			case 'calculate':
				fncCalculate();
				break;
			case 'delete':
				grid1.getGridBase().deleteSelection(true);
				break;
			case 'save':
				try {
					grid1.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}

		        if( grid1.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				}

				if(!grid1.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}


				Message.confirm('<lgcom:message code="question.save"/>', function() {
					var param = formUtil.getValue();
					grid1.useProgress(true);
					grid1.saveChanges('lgvhr','lgvatt/LGVATT00016/saveAnnualLeave', function(data, gridData) {

						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger('click');


					});
				});
				break;
			// 유저 검색 팝업
		    case "openPopupApprover" :
                console.log("openPopupApprover");
                var _popup = _this.popupInfo.userPopup;
                _popup.searchMode   = "single";

                if(!isAttMaster) {
                	_popup.popupKind    = "PIC";
                } else {
                	_popup.popupKind    = "";
                }

                _popup.confirmKind  = "";
                _popup.employeeNo = formUtil.getValue("employeeNo");
                _popup.employeeName = formUtil.getValue("employeeName");

                var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
                popup.setSize(800,494);
                popup.open( function(){
                    formUtil.setValue({employeeNo  :_popup.userData[0].employeeNo});
                    formUtil.setValue({employeeName   :_popup.userData[0].employeeName});
                    formUtil.setValue({orgName   :_popup.userData[0].organizationId});
                });
                _popup.userData = [];
                break;

			case 'excelUpload':
				var uploader = new ExcelUploader("lgvhr", "LGVATT00016", {});
	                uploader.open(  processExcelUploadPostProcess );
				break;

		    case "excelDown" :
		    	var param =  myForm.select(".searchBlock form").toJSON();
				Message.confirm( "<lgcom:message code='question.excelDownload' />", function(){

					var downloader = new Downloader( myForm );
				    downloader.excel( "lgvhr", "lgvatt/LGVATT00016/excelDownData", param );

				});
		}
	});

	this.addEvent( "change", "input[data-action]" , function(event){
        var action = $(event.target).data("action");
        switch( action ){
            case "emptyAndPopup" :
                $(event.target).prev("input[type=hidden]").val(""); // 코드값 비우기
                if($(event.target).val() != ""){
                    $("body").one("focusout", function(e){
                        $(event.target).next("span").children("button").trigger('click');
                    });
                }
                break;
        }
    });

	function processExcelUploadPostProcess( sessionId ) {
		param.sessionId = sessionId;
		//반드시 transaction_sync 를 써야합니다 !!
		transaction_sync('lgvhr','lgvatt/LGVATT00016/createAnnualLeaveUpload',param, function(data) {
			Message.notify('<lgcom:message code="note.completed"/>');
			myForm.select(".searchBlock button[data-action='search']").trigger('click');
		});
	}

	//검색조건에 값을 입력하고 조회하면 방금 입력한 값을 저장하여 화면에 고정값으로 셋팅
    myForm.searchConditionControl( true );

	/*** 내부 함수  ***/

	// 연차일수 재계산 ( annual_leave_days = CEIL( 근무개월수 / 12 * 계수 * 2 ) / 2, 0~4 범위 )
	// 체크박스로 선택된 데이터에 대해서만 DB에 바로 반영되며, 별도로 Save를 누를 필요가 없음
	function fncCalculate() {
		try {
			grid1.getGridBase().commit();
		} catch(e) {
			Message.alert(e.message);
			return;
		}

		var checkedRows = grid1.getGridBase().getCheckedRows(true);

		if( checkedRows.length == 0 ) {
			Message.alert('<lgcom:message code="error.noChangedData"/>');
			return;
		}

		var provider = grid1.getDataProvider();
		var arr = [];
		for(var i=0; i<checkedRows.length; i++) {
			// 이미 계산된(annual_leave_days 값이 DB에 있는) 행은 Calculate 대상에서 제외
			if( provider.getValue(checkedRows[i], 'isCalculated') !== 'Y' ) {
				arr.push(provider.getJsonRow(checkedRows[i]));
			}
		}

		if( arr.length == 0 ) {
			Message.alert('<lgcom:message code="error.noChangedData"/>');
			return;
		}

		Message.confirm('<lgcom:message code="question.pay.calculate"/>', function() {
			var param = { modifyList : arr };
			myForm.showProgress();
			myForm.transaction('lgvhr', 'lgvatt/LGVATT00016/recalculateAnnualLeave', param, function(data){
				Message.notify('<lgcom:message code="note.completed"/>');
				myForm.select(".searchBlock button[data-action='search']").trigger('click');
				myForm.hideProgress();
			});
		});
	}

    //그리드 초기화
	function buildGrid(gridId) {
		var grid;
		switch(gridId){
			case 'LGVATT00016_grid1':
				grid = new RealGrid(myForm, gridId, true);
				grid.setPagingMode(true);

				//옵션 설정
				grid.setOptions({
					grid: {
						softDeleting: true,
						deleteCreated: true,
						hideDeletedRows: true,
						indicator: {visible: false},
						panel: {visible: false},
						checkBar: {visible: true},
						stateBar: {visible: false},
						footer: {visible: false},
						sortMode: "explicit",
						edit: {
							insertable: true,
							appendable: false,
							updatable: true,
							deletable: true
						},
						header:{
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

				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();

				var empTypeCodeList = new Array();
				var empTypeNameList = new Array();

				//사원 구분(emp_type) Combo 조회
				transaction_sync("lgvhr", "lgvatt/LGVATT00016/retrieveEmpTypeNameList", {languageCode:SESSION_USER.languageCode}, function(data){
					var empTypeList = data.result;
					$(empTypeList).each( function(){
						empTypeCodeList.push(this.code);
						empTypeNameList.push(this.name);
					});
				});

				//필드 설정
				grid.setFields(
						[
							{ fieldName:'employeeNo'		, dataType:'text'  },
							{ fieldName:'employeeName'		, dataType:'text'  },
							{ fieldName:'empOrgName'		, dataType:'text'  },
							{ fieldName:'resignationDate'	, dataType:'text'  },
							{ fieldName:'empType'			, dataType:'text'  },
							{ fieldName:'annualLeaveDays'	, dataType:'number', numberFormat:'0.0'  },
							{ fieldName:'isCalculated'		, dataType:'text'  },
							{ fieldName:'effectiveStartDate', dataType:'text'  },
							{ fieldName:'effectiveEndDate'	, dataType:'text'  },
							{ fieldName:'creationDate'	    , dataType:'text'  },
						]
				);

				//컬럼 설정
				grid.setColumns(
						[
							{	name:'employeeNo',
								fieldName:'employeeNo',
								width:100,
								header: {text:'<lgcom:message code="label.att.employeeNo2" />', required : true},
								styles: {textAlignment:'center'},
								editable: false
							},
							{	name:'employeeName',
								fieldName:'employeeName',
								width:120,
								header: {text:'<lgcom:message code="label.att.employeeName" />'},
								editable: false,
								styles: {textAlignment:'near'}
							},
							{	name:'empOrgName',
								fieldName:'empOrgName',
								width:250,
								header: {text:'<lgcom:message code="label.att.organization" />'},
								editable: false,
								styles: {textAlignment:'near'}
							},
							{	name:'resignationDate',
								fieldName:'resignationDate',
								width:120,
								header: {text:'<lgcom:message code="label.pay.resignationDate" />'},
								editable: false,
								styles: {textAlignment:'center'}
							},
							{	name:'empType',
								fieldName:'empType',
								width:80,
								header: {text:'<lgcom:message code="label.att.empType" />', required : true},
								styles: {textAlignment:'center'},
								lookupDisplay: true,
								values: empTypeCodeList,
								labels: empTypeNameList,
								editor: {type:'dropDown', textReadOnly: true, editable: true}
							},
							{	name:'annualLeaveDays',
								fieldName:'annualLeaveDays',
								width:120,
								header: {text:'<lgcom:message code="label.att.annualLeaveDays" />'},
								styles: {textAlignment:'far', numberFormat: '0.0'},
								editable: false
							},
							{	name:'effectiveStartDate',
								fieldName:'effectiveStartDate',
								width:180,
								header: {text:'<lgcom:message code="label.att.effectiveStartDate" />', required : true},
								styles: {textAlignment:'center'},
								editor: {type:'date', datetimeFormat:'dd/MM/yyyy'}
							},
							{	name:'effectiveEndDate',
								fieldName:'effectiveEndDate',
								width:180,
								header: {text:'<lgcom:message code="label.att.effectiveEndDate" />'},
								styles: {textAlignment:'center'},
								editor: {type:'date', datetimeFormat:'dd/MM/yyyy'}
							},
							{	name:'creationDate',
								fieldName:'creationDate',
								width:180,
								header: {text:'<lgcom:message code="label.att.creationDate" />'},
								styles: {textAlignment:'center'},
								editor: {type:'date', datetimeFormat:'dd/MM/yyyy'}
							}
						]
				);
				break;
		}

		// 유효성 검사
		grid.setValidations([{criteria: "value['employeeNo'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.employeeNo2' />"/>',mode:'always',level:'error'},
		                     {criteria: "value['empType'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.empType' />"/>',mode:'always',level:'error'},
		                     {criteria: "value['effectiveStartDate'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.effectiveStartDate' />"/>',mode:'always',level:'error'}

			 				]);
		return grid;
	}

	// 그리드 버튼
	grid1.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var created = newRow < 0 || provider.getRowState(newRow) === 'created';

		// 신규행이 아니면 Program ID 컬럼 편집 불가
		if(created) {
			cgrid.setColumnProperty('employeeNo','editable',true);
			cgrid.setColumnProperty('employeeNo','button','action');
		} else {
			cgrid.setColumnProperty('employeeNo','editable',false);
			cgrid.setColumnProperty('employeeNo','button','none');
		}
	};

	// 그리드 클릭 이벤트
	grid1.getGridBase().onCellButtonClicked = function(cgrid, itemIndex, column) {
		cgrid.commitEditor();

		var currRow = cgrid.getCurrent();
		var gridRow = cgrid.getValues(currRow.itemIndex);

		if(column.name == 'employeeNo'){
			processUserPopup();
		}

	};

	// 유저 검색 팝업
	function processUserPopup() {
    	var _popup = _this.popupInfo.userPopup;

    	var grid2 = grid1.getGridBase();

    	_popup.searchMode   = "single";
        _popup.popupKind    = "";
        _popup.confirmKind  = "";
        _popup.employeeNo = '';
        _popup.employeeName = '';
        _popup.attDate = '';

        var popup = new Popup( _this,'lgvhr', 'M_LGVCOM_1010', '<lgcom:message code="UserSearch"/>' );
        popup.setSize(800,494);
        popup.open( function(){
        	grid2.setValue(grid2.getCurrent().itemIndex,'employeeNo',_popup.userData[0].employeeNo);
        	grid2.setValue(grid2.getCurrent().itemIndex,'employeeName',_popup.userData[0].employeeName);
        	grid2.setValue(grid2.getCurrent().itemIndex,'empOrgName',_popup.userData[0].organizationName);
        	grid2.commit();

        });
        _popup.userData = [];
    }
}

LGVATT00016.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT00016();
		form.init();
		//form.loadCompleted();
	});
});

</script>
<style>
</style>
</head>

<body>
<div class="mdi-container">
	<section class="page-content">
		<div class="pageHeader">
		    <h2>Annual Leave Days History</h2>
		</div>

		<div class="searchBlock">
		    <form class="form search-wrap">
				<fieldset>
					<table class="table">
						<colgroup>
							<col width="100" />
							<col width="220"/>
							<col width="100" />
							<col width="150"/>
							<col width="100" />
							<col width="150" />
							<col width="150" />
							<col width="150" />
						</colgroup>
						<tbody>
			                <tr>
								<th><label><i class="asterisk">*</i><lgcom:message code="label.att.organization" /></label></th>
								<td><select class="form-control input-sm input-require" name="orgName"></select></td>

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

								<th><label><lgcom:message code="label.att.employeeName" /></label></th>
								<td><input type="text" class="form-control input-sm" name="employeeName"></td>

								<th><label class="required"><lgcom:message code="label.att.attendanceYear" /></label></th>
			                    <td>
			                        <div class="form-inline ">
	                                	<select class="form-control input-sm input-require" name="timeAndAttendanceYyyy" id="timeAndAttendanceYyyy">
	                                		<c:forEach begin="0" end="2" var="idx" step="1">
	                                		<option value="<c:out value="${currentYear+idx}"/>"><c:out value="${currentYear+idx}"/></option>
	                                		</c:forEach>
	                                	</select>
	                            	</div>
			                    </td>
			                </tr>
						</tbody>
					</table>
				</fieldset>
				<button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search" ><lgcom:message code="search" /></button>
		    </form>
		</div>

		<%-- 그리드 버튼 영역 --%>
		<div class="gridControls gridControls1 module-group text-right">
			<div class="btn-toolbar">
				<div class="btn-group">
					<button class="btn btn-default btn-sm" type="button" data-action="excelDown"><span class="ico ico-excel-down"></span> <lgcom:message code="Download"/></button>
				</div>
				<div class="btn-group">
					  <button class="btn btn-default btn-sm" type="button" data-action="excelUpload"><span class="ico ico-excel-up"></span><lgcom:message code="Upload" /></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-gray btn-sm" type="button" data-action="calculate" ><lgcom:message code="button.pay.calculate"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete"><span class="fa fa-remove" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save" data-access="LGSYSC00140/saveProgramList"><lgcom:message code="save"/></button>
				</div>
			</div>
		</div>

		<div class="content content1 grid-wrap" >
		    <div id="LGVATT00016_grid1" class="grid"></div>
		</div>
	</section>
</div>
</body>
</html>
