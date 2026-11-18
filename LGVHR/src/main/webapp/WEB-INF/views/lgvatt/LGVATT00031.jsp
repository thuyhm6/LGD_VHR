<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="devonframe.util.DateUtil" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%---------------------------------------------------------
    파일명 : LGVATT00031.jsp
    프로젝트명 : VHR LGD

    설 명 : Pregnant EMP Management (임신 직원 관리)
            - 사번, 시작일/종료일, OT 가능여부(Y/N, 기본 N), 비고 등록 / 엑셀 업로드
            - OT 가능여부 = N 인 기간에는 LGVATT20011, LGVATT20020, LGVATT20040, LGVATT20060 에서 OT 입력 불가
-------------------------------------------------------------%>

<c:set var="flg_vn_att_master" value="N"/>
<c:forEach var="roles" items="${sessionScope.USER_SESSION.roleList}">
    <c:if test="${roles.systemCode=='LGVHR' && roles.moduleCode=='LGVATT' && fn:indexOf(roles.roleCode,'VN_ATT_MASTER_USER')>=0 }">
        <c:set var="flg_vn_att_master" value="Y"/>
    </c:if>
</c:forEach>

<html lang="ko">
<head>
<title>Pregnant EMP Management</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<style type="text/css">
</style>
<script type="text/javascript">

var LGVATT00031 = function(){
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

    //날짜 설정 (기간이 조회기간과 겹치는 건 조회)
    formUtil.setValue( {
    	fromDate : DateUtil.format(DateUtil.today().add(-1,'year'), 'DD/MM/YYYY'),
    	toDate : DateUtil.format(DateUtil.today().add(1,'year'), 'DD/MM/YYYY')
    });

	formUtil.setCalendar( { from : "fromDate", to : "toDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );

	// Search Block combo
	var valueSet = new ValueSet("lgcom");
	valueSet.add('orgName', {valueSetId : 'LGVATT_LW_ADMIN_ORG_NAME', employeeNum : '${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}', subsidiaryCode : '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}'});
	valueSet.execute();

	formUtil.initCombo('orgName',valueSet.get('orgName'),{selectAll: true});

   	grid1 = buildGrid("LGVATT00031_grid1");

    grid1.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
		Message.alert(error.message);
	};

	myForm.popupInfo = {
		userPopup   : {searchMode:'single', popupKind:'', confirmKind:'', employeeNo:'', employeeName:'', userData:[]},
        returnPopup : {returnComment:''}
    };

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

				grid1.loadData('lgvhr','lgvatt/LGVATT00031/retrievePregnantEmp', param, function(data){

					// 분류가 임신(PREGNANT) 이 아닌 행은 25주차 시작일 입력 불가
					for(var r=0; r<grid1.getDataProvider().getRowCount(); r++) {
						fncSetWeek25Editable(r);
					}

					if( grid1.getDataProvider().getRowCount() == 0 ) {
						Message.alert('<lgcom:message code="note.nodata"/>');
					} else {
						var index = {itemIndex: 0};
						grid1.getGridBase().setCurrent(index);
					}

				} );

				break;
			case 'insert':
				try {
					grid1.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				// 신규행 : OT 가능여부 기본값 N
				grid1.getDataProvider().insertRow(0, { otAllowFlag : 'N', empCategoryCode : 'PREGNANT' });
				// insertRow 로 기존 행 index 가 밀리므로 전체 행 재설정
				for(var r=0; r<grid1.getDataProvider().getRowCount(); r++) {
					fncSetWeek25Editable(r);
				}
				grid1.getGridBase().setCurrent({ dataRow : 0 });
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

				if(!grid1.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}

				// 종료일 >= 시작일 체크
				var provider = grid1.getDataProvider();
				var changedRows = provider.getStateRows('created').concat(provider.getStateRows('updated'));
				for(var i=0; i<changedRows.length; i++) {
					var startDate = provider.getValue(changedRows[i], 'effectiveStartDate');
					var endDate   = provider.getValue(changedRows[i], 'effectiveEndDate');
					if( endDate && fncToYmd(endDate) < fncToYmd(startDate) ) { // 종료일은 선택 (공백 = 무기한)
						Message.alert('End Date is earlier than Start Date : ' + provider.getValue(changedRows[i], 'employeeNo'));
						return;
					}
					// 임신(PREGNANT) : 25주차 시작일 필수, 시작일 ~ 종료일 사이 (OT 제한 기간 = 25주차 시작일 ~ 종료일)
					if( provider.getValue(changedRows[i], 'empCategoryCode') == 'PREGNANT' ) {
						var week25Date = provider.getValue(changedRows[i], 'week25Date');
						if( !week25Date ) {
							Message.alert('Week 25 Date is required for Pregnant : ' + provider.getValue(changedRows[i], 'employeeNo'));
							return;
						}
						if( fncToYmd(week25Date) < fncToYmd(startDate) || (endDate && fncToYmd(week25Date) > fncToYmd(endDate)) ) {
							Message.alert('Week 25 Date must be between Start Date and End Date : ' + provider.getValue(changedRows[i], 'employeeNo'));
							return;
						}
					}
				}

				Message.confirm('<lgcom:message code="question.save"/>', function() {
					grid1.useProgress(true);
					grid1.saveChanges('lgvhr','lgvatt/LGVATT00031/savePregnantEmp', function(data, gridData) {

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
				// 엑셀 양식 (Download 파일과 동일) : A.Employee No / B.Employee Name(무시) / C.Organization(무시) / D.Start Date(DD/MM/YYYY) / E.End Date(DD/MM/YYYY, 선택 - 공백=무기한)
				//   / F.OT Allowed(Y/N, 공백=N) / G.Category(Pregnant/Raising Young Child 또는 PREGNANT/CHILD_CARE, 공백=PREGNANT) / H.Week 25 Date(DD/MM/YYYY, Pregnant 인 경우 필수) / I.Remark (1행 헤더)
				var uploader = new ExcelUploader("lgvhr", "LGVATT00031", {});
	            uploader.open(  processExcelUploadPostProcess );
				break;

		    case "excelDown" :
		    	var param =  myForm.select(".searchBlock form").toJSON();
				Message.confirm( "<lgcom:message code='question.excelDownload' />", function(){

					var downloader = new Downloader( myForm );
				    downloader.excel( "lgvhr", "lgvatt/LGVATT00031/excelDownData", param );

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
		var param = { sessionId : sessionId };
		//반드시 transaction_sync 를 써야합니다 !!
		transaction_sync('lgvhr','lgvatt/LGVATT00031/createPregnantEmpUpload',param, function(data) {
			Message.notify('<lgcom:message code="note.completed"/>');
			myForm.select(".searchBlock button[data-action='search']").trigger('click');
		});
	}

	//검색조건에 값을 입력하고 조회하면 방금 입력한 값을 저장하여 화면에 고정값으로 셋팅
    myForm.searchConditionControl( true );

	/*** 내부 함수  ***/

	// 'DD/MM/YYYY' -> 'YYYYMMDD'
	function fncToYmd(ddmmyyyy) {
		if( !ddmmyyyy ) return '';
		var arr = String(ddmmyyyy).split('/');
		return (arr.length == 3) ? (arr[2] + arr[1] + arr[0]) : String(ddmmyyyy);
	}

    //그리드 초기화
	function buildGrid(gridId) {
		var grid;
		switch(gridId){
			case 'LGVATT00031_grid1':
				grid = new RealGrid(myForm, gridId, true);
				grid.setPagingMode(true);

				//옵션 설정
				grid.setOptions({
					grid: {
						softDeleting: true,
						deleteCreated: true,
						hideDeletedRows: false,
						indicator: {visible: false},
						panel: {visible: false},
						checkBar: {visible: true},
						stateBar: {visible: true},
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

				//필드 설정
				grid.setFields(
						[
							{ fieldName:'employeeNo'		, dataType:'text'  },
							{ fieldName:'employeeName'		, dataType:'text'  },
							{ fieldName:'empOrgName'		, dataType:'text'  },
							{ fieldName:'effectiveStartDate', dataType:'text'  },
							{ fieldName:'effectiveEndDate'	, dataType:'text'  },
							{ fieldName:'empCategoryCode'	, dataType:'text'  },
							{ fieldName:'week25Date'	    , dataType:'text'  },
							{ fieldName:'otAllowFlag'	    , dataType:'text'  },
							{ fieldName:'remark'	        , dataType:'text'  },
							{ fieldName:'creationDate'	    , dataType:'text'  }
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
								width:150,
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
							{	name:'effectiveStartDate',
								fieldName:'effectiveStartDate',
								width:130,
								header: {text:'<lgcom:message code="label.att.effectiveStartDate" />', required : true},
								styles: {textAlignment:'center'},
								editable: false,
								editor: {type:'date', datetimeFormat:'dd/MM/yyyy'}
							},
							{	name:'effectiveEndDate',
								fieldName:'effectiveEndDate',
								width:130,
								header: {text:'<lgcom:message code="label.att.effectiveEndDate" />'},
								styles: {textAlignment:'center'},
								editor: {type:'date', datetimeFormat:'dd/MM/yyyy'}
							},
							// 분류 : 임신 / 육아 (분류용, OT 제한 로직과 무관)
							{	name:'empCategoryCode',
								fieldName:'empCategoryCode',
								width:150,
								header: {text:'Category', required : true},
								styles: {textAlignment:'center'},
								lookupDisplay: true,
								values: ['PREGNANT', 'CHILD_CARE'],
								labels: ['Pregnant', 'Raising Young Child'],
								editor: {type:'dropDown', textReadOnly: true, editable: true}
							},
							// 임신 25주차 시작일 : 분류가 임신(PREGNANT) 인 경우만 입력 (필수). 임신은 이 날짜 ~ 종료일 OT 제한
							{	name:'week25Date',
								fieldName:'week25Date',
								width:130,
								header: {text:'Week 25 Date', required : true},
								styles: {textAlignment:'center'},
								editor: {type:'date', datetimeFormat:'dd/MM/yyyy'}
							},
							{	name:'otAllowFlag',
								fieldName:'otAllowFlag',
								width:110,
								header: {text:'OT Allowed', required : true},
								styles: {textAlignment:'center'},
								lookupDisplay: true,
								values: ['Y', 'N'],
								labels: ['Yes', 'No'],
								editor: {type:'dropDown', textReadOnly: true, editable: true}
							},
							{	name:'remark',
								fieldName:'remark',
								width:300,
								header: {text:'Remark'},
								styles: {textAlignment:'near'},
								editor: {maxLength: 1000}
							},
							{	name:'creationDate',
								fieldName:'creationDate',
								width:110,
								header: {text:'<lgcom:message code="label.att.creationDate" />'},
								styles: {textAlignment:'center'},
								editable: false
							}
						]
				);
				break;
		}

		// 유효성 검사
		grid.setValidations([{criteria: "value['employeeNo'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.employeeNo2' />"/>',mode:'always',level:'error'},
		                     {criteria: "value['effectiveStartDate'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='label.att.effectiveStartDate' />"/>',mode:'always',level:'error'},
		                     {criteria: "value['empCategoryCode'] is not empty",message:'<lgcom:message code="error.required" arguments="Category"/>',mode:'always',level:'error'},
		                     {criteria: "value['otAllowFlag'] is not empty",message:'<lgcom:message code="error.required" arguments="OT Allowed"/>',mode:'always',level:'error'}
			 				]);
		return grid;
	}

	// 임신 25주차 시작일 : 분류가 임신(PREGNANT) 인 행만 입력 가능
	grid1.getGridBase().addCellStyles([
		{ id: "unableEdit", background: '#e9e9e9', editable: false },
		{ id: "enableEdit", background: 'none',    editable: true  }
	]);

	function fncSetWeek25Editable(dataRow) {
		var provider = grid1.getDataProvider();
		if( provider.getValue(dataRow, 'empCategoryCode') == 'PREGNANT' ) {
			grid1.getGridBase().setCellStyle(dataRow, 'week25Date', 'enableEdit', true);
		} else {
			if( provider.getValue(dataRow, 'week25Date') ) {
				provider.setValue(dataRow, 'week25Date', null);
			}
			grid1.getGridBase().setCellStyle(dataRow, 'week25Date', 'unableEdit', true);
		}
	}

	// 분류 변경 시 25주차 시작일 입력 가능 여부 재설정
	grid1.getGridBase().onCellEdited = function(cgrid, itemIndex, dataRow, field) {
		if( cgrid.getDataProvider().getOrgFieldName(field) == 'empCategoryCode' ) {
			cgrid.commit();
			fncSetWeek25Editable(dataRow);
		}
	};

	// 신규행만 사번 / 시작일(PK) 편집 가능
	grid1.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var created = newRow < 0 || provider.getRowState(newRow) === 'created';

		if(created) {
			cgrid.setColumnProperty('employeeNo','editable',true);
			cgrid.setColumnProperty('employeeNo','button','action');
			cgrid.setColumnProperty('effectiveStartDate','editable',true);
		} else {
			cgrid.setColumnProperty('employeeNo','editable',false);
			cgrid.setColumnProperty('employeeNo','button','none');
			cgrid.setColumnProperty('effectiveStartDate','editable',false);
		}
	};

	// 그리드 클릭 이벤트
	grid1.getGridBase().onCellButtonClicked = function(cgrid, itemIndex, column) {
		cgrid.commitEditor();

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

LGVATT00031.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT00031();
		form.init();
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
		    <h2>Pregnant EMP Management</h2>
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
							<col width="80" />
							<col width="300" />
							<col width="90" />
							<col width="100" />
							<col width="80" />
							<col width="160" />
						</colgroup>
						<tbody>
			                <tr>
								<th><label><lgcom:message code="label.att.organization" /></label></th>
								<td><select class="form-control input-sm" name="orgName"></select></td>

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

								<th><label>Period</label></th>
			                    <td>
			                        <div class="form-inline ">
	                                <input type="text" class="form-control input-sm" name="fromDate" id="fromDate" placeholder="dd/mm/yyyy" readonly>
	                                ~
	                                <input type="text" class="form-control input-sm" name="toDate" id="toDate" placeholder="dd/mm/yyyy" readonly>
	                                <button type="button" class="btn btn-ico" aria-label="calendar">
								        <span class="ico ico-calendar" aria-hidden="true"></span>
								    </button>
	                            	</div>
			                    </td>

								<th><label>OT Allowed</label></th>
								<td>
									<select class="form-control input-sm" name="otAllowFlag">
										<option value="">All</option>
										<option value="Y">Yes</option>
										<option value="N">No</option>
									</select>
								</td>

								<th><label>Category</label></th>
								<td>
									<select class="form-control input-sm" name="empCategoryCode">
										<option value="">All</option>
										<option value="PREGNANT">Pregnant</option>
										<option value="CHILD_CARE">Raising Young Child</option>
									</select>
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
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
					<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete"><span class="fa fa-remove" aria-hidden="true"></span> <lgcom:message code="delete"/></button>
				</div>
				<div class="btn-group">
					<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save"><lgcom:message code="save"/></button>
				</div>
			</div>
		</div>

		<div class="content content1 grid-wrap" >
		    <div id="LGVATT00031_grid1" class="grid"></div>
		</div>
	</section>
</div>
</body>
</html>
