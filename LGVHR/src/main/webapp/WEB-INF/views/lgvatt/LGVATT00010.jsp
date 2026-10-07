<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="devonframe.util.DateUtil" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%---------------------------------------------------------
    파일명 : LGVATT00010.jsp
    프로젝트명 : LGD BizWeb

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : ID Card History
    작성자 : 이형준S
-------------------------------------------------------------%>

<c:set var="flg_vn_att_master" value="N"/>
<c:forEach var="roles" items="${sessionScope.USER_SESSION.roleList}">
    <c:if test="${roles.systemCode=='LGVHR' && roles.moduleCode=='LGVATT' && fn:indexOf(roles.roleCode,'VN_ATT_MASTER_USER')>=0 }">
        <c:set var="flg_vn_att_master" value="Y"/>
    </c:if>   
</c:forEach>

<html lang="ko">
<head>
<title>ID Card History</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<style type="text/css">
</style>
<script type="text/javascript">

var LGVATT00010 = function(){
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
    
    //날짜 설정
    formUtil.setValue( {
    	fromDate : DateUtil.format(DateUtil.today().add(-1,'month'), 'DD/MM/YYYY'),
    	toDate : DateUtil.today("DD/MM/YYYY")
    });

	formUtil.setCalendar( { from : "fromDate", to : "toDate", language:SESSION_USER.languageCode, format: 'DD/MM/YYYY' } );
  	
	// grid combo
	var code = new CommonCode('lgcom');
	code.add('shiftCode', {codeTypeCode:'LGVHR_SHIFT_TYPE_CODE'});
	code.add('inOutFlag', {codeTypeCode:'LGVHR_ATT_IN_OUT_FLAG'});
	code.execute();
	
	// Search Block combo
	var valueSet = new ValueSet("lgcom");
	valueSet.add('orgName', {valueSetId : 'LGVATT_LW_ADMIN_ORG_NAME', employeeNum : '${sessionScope.LGVHR_PROJECT_SESSION.employeeNo}', subsidiaryCode : '${sessionScope.LGVHR_PROJECT_SESSION.subsidiaryCode}'});
	valueSet.execute(); 
	
	formUtil.initCombo('orgName',valueSet.get('orgName'),{selectAll: true});
	formUtil.initCombo('shiftCode',code.get('shiftCode'),{selectAll: true});
	formUtil.initCombo('inOutFlag',code.get('inOutFlag'),{selectAll: true});
	
   	grid1 = buildGrid("LGVATT00010_grid1");
    
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
				
				grid1.loadData('lgvhr','lgvatt/LGVATT00010/retrieveIdCardHis', param, function(data){
					
					if( grid1.getDataProvider().getRowCount() == 0 ) {
						Message.alert('<lgcom:message code="note.nodata"/>');
					} else {
						if(grid1.getDataProvider().getRowCount() > 0){
				    		var index = {itemIndex: 0};
							grid1.getGridBase().setCurrent(index);
				    	}
					}
					
				} );
				
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
                
		    case "excelDown" :
		    	var param =  myForm.select(".searchBlock form").toJSON();
				Message.confirm( "<lgcom:message code='question.excelDownload' />", function(){

					var downloader = new Downloader( myForm );
				    downloader.excel( "lgvhr", "lgvatt/LGVATT00010/excelDownData", param );

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
	
	//검색조건에 값을 입력하고 조회하면 방금 입력한 값을 저장하여 화면에 고정값으로 셋팅 
    myForm.searchConditionControl( true );
	
	/*** 내부 함수  ***/
	
    //그리드 초기화
	function buildGrid(gridId) {
		var grid;
		switch(gridId){
			case 'LGVATT00010_grid1':
				grid = new RealGrid(myForm, gridId, true);
				grid.setPagingMode(true);
				
				//옵션 설정
				grid.setOptions({
					grid: {
						softDeleting: false,
						deleteCreated: false,
						hideDeletedRows: false,
						indicator: {visible: false},
						panel: {visible: false},
						checkBar: {visible: false},
						stateBar: {visible: false},
						footer: {visible: false},
						sortMode: "explicit",
						edit: {
							insertable: false,
							appendable: false,
							updatable: false,
							deletable: false
						},
						header:{
					         height: 40
					    }
					},
					dataProvider: {
						insertable: false,
						updatable: false,
						deletable: false,
						softDeleting: false,
						deleteCreated: false
					}
				});

				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();

				//필드 설정
				grid.setFields(
						[
							{ fieldName:'employeeNo'		, dataType:'text'  },
							{ fieldName:'employeeName'		, dataType:'text'  },
							{ fieldName:'employeeGrade'		, dataType:'text'  },
							{ fieldName:'empOrgName'		, dataType:'text'  },
							{ fieldName:'shiftTypeCode'		, dataType:'text'  },
							{ fieldName:'building'			, dataType:'text'  },
							{ fieldName:'locationName'		, dataType:'text'  },
							{ fieldName:'inOut'				, dataType:'text'  },
							{ fieldName:'transactionDate'	, dataType:'text'  },
							{ fieldName:'transferFlag'		, dataType:'text'  },
							{ fieldName:'transferDate'		, dataType:'text'  }
						]
				);
				
				//컬럼 설정
				grid.setColumns(
						[
							{	name:'employeeNo',    
								fieldName:'employeeNo',    
								width:70,  
								header: {text:'<lgcom:message code="label.att.id" />'},	 
								editable: false, 
								styles: {textAlignment:'center'}
							},
							{	name:'employeeName',  
								fieldName:'employeeName',  
								width:120, 
								header: {text:'<lgcom:message code="label.att.employeeName" />'},	 
								editable: false, 
								styles: {textAlignment:'near'}
							},
							{	name:'employeeGrade', 
								fieldName:'employeeGrade', 
								width:100,
								header: {text:'<lgcom:message code="label.att.jobTitle" />'},
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
							{	name:'shiftTypeCode',
								fieldName:'shiftTypeCode',
								width:80,
								header: {text:'<lgcom:message code="label.att.actualShiftCode" />'},
								editable: false,
								styles: {textAlignment:'near' }
							},
							{	name:'building', 
								fieldName:'building', 
								width:90,
								header: {text:'<lgcom:message code="label.att.building" />'},
								editable: false,
								styles: {textAlignment:'near'}
							},
							{	name:'locationName', 
								fieldName:'locationName', 
								width:180,
								header: {text:'<lgcom:message code="label.att.locationName" />'},
								editable: false,
								styles: {textAlignment:'near'}
							},
							{	name:'inOut', 
								fieldName:'inOut', 
								width:60,
								header: {text:'<lgcom:message code="label.att.inOut" />'},
								editable: false,
								styles: {textAlignment:'near'}
							},
							{	name:'transactionDate', 
								fieldName:'transactionDate', 
								width:170,
								header: {text:'<lgcom:message code="label.att.transactionDate" />'},
								editable: false,
								styles: {textAlignment:'center'}
							},
							{	name:'transferFlag',
								fieldName:'transferFlag',
								width:80,
								header: {text:'<lgcom:message code="label.att.transferFlag" />'},
								editable: false,
								styles: {textAlignment:'center'}
							},
							{	name:'transferDate', 
								fieldName:'transferDate', 
								width:170,
								header: {text:'<lgcom:message code="label.att.transferDate" />'},
								editable: false,
								styles: {textAlignment:'center'}
							}
						]
				);
				break;
		}
		return grid;
	}
	
	//그리드에 값 세팅하는 함수
	function setValue(grid, field, val) {
	    var row = 0;
	    var current = grid.getGridBase().getCurrent();
	    if (current) {
	        row = Math.max(0, current.dataRow);
	    }
	    grid.getDataProvider().setValue(row,field,val);
	}
}


LGVATT00010.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGVATT00010();
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
		    <h2>ID Card History</h2>
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
							<col width="*"  />
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
								
			                </tr>
			                <tr>
			                
								<th><label><lgcom:message code="label.att.date" /></label></th>
			                    <td>
			                        <div class="form-inline ">
	                                <input type="text" class="form-control input-sm input-require" name="fromDate" id="fromDate" placeholder="dd/mm/yyyy" readonly>
	                                ~
	                                <input type="text" class="form-control input-sm input-require" name="toDate" id="toDate" placeholder="dd/mm/yyyy" readonly>
	                                <button type="button" id="setSingleDateSample" class="btn btn-ico" aria-label="calendar">
								        <span class="ico ico-calendar" aria-hidden="true"></span>
								    </button>
	                            	</div>
			                    </td>
			                	
			                	<th><label><lgcom:message code="label.att.inOut" /></label></th>
								<td><select class="form-control input-sm" name="inOutFlag"></select></td>
			                	
			                	<th><label><lgcom:message code="label.att.shiftCode" /></label></th>
								<td><select class="form-control input-sm" name="shiftCode"></select></td>
			                	
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
	        </div>	
	    </div>
		
		<div class="content content1 grid-wrap" >
		    <div id="LGVATT00010_grid1" class="grid"></div>
		</div>
	</section>
</div>
</body>
</html>
