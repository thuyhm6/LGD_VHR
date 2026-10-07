<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : userProfile.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2012 LG CNS,  All rights reserved.

    설 명 : 본 화면은 My Page로 사용자 정보를 관리하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="//WEB-INF/views/framework/bizFormHeader.jsp" %>
<style type="text/css">
</style>
<script type="text/javascript">
var LGSYSC00050 = function() {
	$(document).data("USER_NEMU_UPDATED", "N");

	var myForm = this;
	var orgData;
	// Form Util 선언
	var form1Util = new FormUtil(myForm,'.tab-pane#userProfile_tab01 .dataBlock1 form');
	var form2Util = new FormUtil(myForm,'.tab-pane#userProfile_tab02 .searchBlock form');
	
	/* 화면 레이아웃 정의 
	myForm.setLayout([
        { name : "tabPaneContainer",    top : 33, left : 0, right : 0, bottom : 0 },
        { name : "tabPane1",    top : 0, left : 0, right : 0, bottom : 0, parent : "tabPaneContainer" },
        { name : "tabPane2",    top : 0, left : 0, right : 0, bottom : 0, parent : "tabPaneContainer" },
        { name : "searchBlock", top : 0, left : 0, right : 0 },
        { name : "gridContent", top : "searchBlock", left : 0, right : 0, bottom : 0 }
	]);*/
	
	// Lookup 설정
	var _code = new CommonCode(CONTEXT_PATH);
	_code.add('language',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_LANGUAGE_CODE'});
	//_code.add('defsystem',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_SYSTEM_CODE'});
	_code.add('usrsystem',{queryId:'retrieveUserOwnSystemList'});
	_code.add('userorg',{queryId:'retrieveUserOrganizationList'});
	_code.add('flag',{queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_YN_FLAG'});
	_code.execute();
	orgData = _code.get('userorg');
	form1Util.initCombo('languageCode',_code.get('language'));
	form1Util.initCombo('systemCode',_code.get('usrsystem'));
	form1Util.initCombo('defaultOrgId',orgData);
	form1Util.initCombo('requestRegionCodeUseFlag',_code.get('flag'));
	form1Util.initCombo('defaultOrgIdUseFlag',_code.get('flag'));
	form1Util.initCombo('menuUseFlag',_code.get('flag'));
	form2Util.initCombo('systemCode',_code.get('usrsystem'),{selectAll:true});
	
	// 그리드 선언
	var grid = buildGrid(".mypageUserAuthGrid");
	
	// 화면 Open시
	myForm.initMyForm = function() {
		// 사용자 정보 조회
		retrieveMyInfomation();
		// 사용자 권한 목록 조회
		retrieveUserRoleList();
	};
	
	/*** 이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var action = $(event.target).data('action');
		if(action == 'save') {
			Message.confirm('<lgcom:message code="question.save"/>', function() {
				var param = form1Util.getValue();
				param = fncGetSelectOrgInfo(param);
				transaction_sync(CONTEXT_PATH,'lgsysc/LGSYSC00050/updateMyInfomationData',param,function(data) {
					$(document).data("USER_NEMU_UPDATED", "Y");
					Message.alert('<lgcom:message code="note.completed"/>');
					// 전체 화면 Reload
					var nav = new Navigate('lgcom','main');
					nav.goPost();
				});
			});
		}
		else if(action == 'link') {
			//Message.alert('Under construction');
		}
	});
	
	myForm.addEvent('change',".searchBlock form select[name='systemCode']",function(event) {
		retrieveUserRoleList();
	});
	
	myForm.addEvent('shown.bs.tab',".pageContent .nav-tabs a[data-toggle='tab']",function(event) {
		
		if( isSmallLayout() ) {
			myForm.select(".gridContent").css({ height : "213px"});
		} else {
			myForm.select(".gridContent").css({ height : "215px"});
		}

		var action = $(event.target).data('action');
		if(action == 'tab02') {
			grid.getGridBase().resetSize();
			myForm.resetLayout();	
		}
	});
	
	/*** 내부 함수  ***/
	// 사용자 정보 조회
	function retrieveMyInfomation() {
		// 사용자 정보 조회
		var param = form1Util.getValue();
		transaction_sync(CONTEXT_PATH,'lgsysc/LGSYSC00050/retrieveMyInfomationData',param,function(data) {
			if(data.result) {
				myForm.select("#userProfile_tab01 .dataBlock1 span[data-action='userId']").html($.trim(data.result.applicationUserId));
				myForm.select("#userProfile_tab01 .dataBlock1 span[data-action='employeeNo']").html($.trim(data.result.userName));
				myForm.select("#userProfile_tab01 .dataBlock1 span[data-action='localEmployeeName']").html($.trim(data.result.fullNameLocal));
				myForm.select("#userProfile_tab01 .dataBlock1 span[data-action='employeeName']").html($.trim(data.result.englishFullName));
				myForm.select("#userProfile_tab01 .dataBlock1 span[data-action='departmentName']").html($.trim(data.result.organizationNameEng));
				myForm.select("#userProfile_tab01 .dataBlock1 span[data-action='mailAddr']").html($.trim(data.result.mailAddr));
				myForm.select("#userProfile_tab01 .dataBlock1 span[data-action='regionName']").html($.trim(data.result.requestRegionName));
				myForm.select("#userProfile_tab01 .dataBlock1 span[data-action='timezoneName']").html($.trim(data.result.timeZoneName));
				form1Util.setValue({
					applicationUserId: $.trim(data.result.applicationUserId),
					mailAddr: $.trim(data.result.mailAddr),
					languageCode: $.trim(data.result.languageCode),
					systemCode: $.trim(data.result.systemCode),
					requestRegionCodeUseFlag: $.trim(data.result.requestRegionCodeUseFlag),
					defaultOrgId: $.trim(data.result.defaultOrgId),
					defaultOrgIdUseFlag: $.trim(data.result.defaultOrgIdUseFlag),
					screenDesignThemeId: $.trim(data.result.screenDesignThemeId),
					menuUseFlag: $.trim(data.result.menuUseFlag),
					ouUseFlag: $.trim(data.result.ouUseFlag)
				});
				// OU 사용자가 아닐 경우 Org, Org Use 비활성화
				if($.trim(data.result.ouUseFlag) == 'N') {
					myForm.select(".tab-pane#userProfile_tab01 .dataBlock1 form select[name='defaultOrgId']").prop('disabled',true);
					myForm.select(".tab-pane#userProfile_tab01 .dataBlock1 form select[name='defaultOrgIdUseFlag']").prop('disabled',true);
				}
				
				if( data.result.defaultOrgId == undefined ) {
					myForm.select(".orgInfo").hide();  
				} 
				
			}
		});
	}
	
	// 사용자 권한 조회
	function retrieveUserRoleList() {
		var param = {};
		param['systemCode'] = form2Util.getValue('systemCode');		//myForm.select(".dataBlock1 form select[name='systemCode'] > option:selected").val();
		grid.loadData(CONTEXT_PATH,'lgsysc/LGSYSC00050/retrieveMyAuthorityList',param);
	}
	
	// 사용자 정보 초기화
	function clearMyInfomation() {
		myForm.select("#userProfile_tab01 .dataBlock1 span[data-action='userId']").html('');
		myForm.select("#userProfile_tab01 .dataBlock1 span[data-action='employeeNo']").html('');
		myForm.select("#userProfile_tab01 .dataBlock1 span[data-action='localEmployeeName']").html('');
		myForm.select("#userProfile_tab01 .dataBlock1 span[data-action='employeeName']").html('');
		myForm.select("#userProfile_tab01 .dataBlock1 span[data-action='departmentName']").html('');
		myForm.select("#userProfile_tab01 .dataBlock1 span[data-action='mailAddr']").html('');
		myForm.select("#userProfile_tab01 .dataBlock1 span[data-action='regionName']").html('');
		myForm.select("#userProfile_tab01 .dataBlock1 span[data-action='timezoneName']").html('');
		form1Util.setValue({
			applicationUserId: '',
			mailAddr: '',
			languageCode: '',
			systemCode: '',
			requestRegionCodeUseFlag: '',
			defaultOrgId: '',
			defaultOrgIdUseFlag: '',
			screenDesignThemeId: '',
			menuUseFlag: '',
			ouUseFlag: ''
		});
	}
	
	//그리드 초기화
	function buildGrid(gridId, lookupList) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(false);
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
					insertable: false,
					appendable: false,
					updatable: false,
					deletable: false
				},
				header: {
					height: 30
				}
			},
			display: { fitStyle: 'evenFill' }
		});

		//필드 설정
		grid.setFields([
			{ fieldName:'userId'    , dataType:'number'},
			{ fieldName:'systemName', dataType:'text'  },
			{ fieldName:'moduleName', dataType:'text'  },
			{ fieldName:'roleCode'  , dataType:'text'  },
			{ fieldName:'roleName'  , dataType:'text'  }
		]);
		//컬럼 설정
		grid.setColumns([
			{
				name:'systemName',
				fieldName:'systemName',
				width:100,
				header: {text:'<lgcom:message code="System"/>'},
				styles: {textAlignment:'center'},
				mergeRule: {criteria:'value'},
				editable: false
			},
			{
				name:'moduleName',
				fieldName:'moduleName',
				width:100,
				header: {text:'<lgcom:message code="Module"/>'},
				styles: {textAlignment:'center'},
				mergeRule: {criteria:"values['systemName'] + value"},
				editable: false
			},
			{
				name:'roleCode',
				fieldName:'roleCode',
				width:150,
				header: {text:'<lgcom:message code="RoleCode"/>'},
				editable: false
			},
			{
				name:'roleName',
				fieldName:'roleName',
				width:120,
				header: {text:'<lgcom:message code="RoleName"/>'},
				editable: false
			}
		]);
		// Context Menu Set
		grid.setContextMenu();
		return grid;
	}
	// 선택된 Org에 대한 정보를 세팅한다.
	function fncGetSelectOrgInfo(arg) {
		for(var i=0; i < orgData.length; i++) {
			if($.trim(orgData[i].code) == $.trim(arg.defaultOrgId)) {
				arg['defaultOrgName'] = $.trim(orgData[i].name);
				arg['defaultOrgShortCode'] = $.trim(orgData[i].shortCode);
				break;
			}
		}
		return arg;
	}
}

LGSYSC00050.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGSYSC00050();
		form.init();
		form.initMyForm();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageContent">
		<ul class="nav nav-tabs tabHeader">
			<li class="active"><a href="#userProfile_tab01" data-toggle="tab" data-action="tab01"><lgcom:message code="Infomation"/></a></li>
			<li><a href="#userProfile_tab02" data-toggle="tab" data-action="tab02"><lgcom:message code="Authority"/></a></li>
		</ul>
		<div class="tab-content tabPaneContainer" >
			<div id="userProfile_tab01" class="tab-pane fade active in  tabPane1">
				<div class="gridControls module-group text-right">
		            <div class="btn-toolbar">
		                <div class="btn-group">
							<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save"><lgcom:message code="save"/></button>
		                </div>
		            </div>
		        </div>
				
				<div class="dataBlock1">
					<form class="form" method="post">
						<input type="hidden" name="applicationUserId"/>
						<input type="hidden" name="mailAddr"/>
						<input type="hidden" name="ouUseFlag"/>
						<table class="table table-condensed">
							<colgroup>
								<col width="20%"/>
								<col width="30%"/>
								<col width="20%"/>
								<col width="30%"/>
							</colgroup>
							<tbody>
								<tr>
									<th scope="col"><lgcom:message code="UserID"/></th>
									<td><span data-action="userId"></span></td>
									<th scope="col"><lgcom:message code="EmployeeNo"/></th>
									<td><span data-action="employeeNo"></span></td>
								</tr>
								<tr>
									<th scope="col"><lgcom:message code="EmployeeName"/></th>
									<td><span data-action="localEmployeeName"></span></td>
									<th scope="col"><lgcom:message code="EmployeeEngName"/></th>
									<td><span data-action="employeeName"></span></td>
								</tr>
								<tr>
									<th scope="col"><lgcom:message code="Department"/></th>
									<td><span data-action="departmentName"></span></td>
									<th scope="col"><lgcom:message code="E-Mail"/></th>
									<td><span data-action="mailAddr"></span></td>
								</tr>
								<tr>
									<th scope="col"><lgcom:message code="Language"/></th>
									<td><select name="languageCode" class="form-control input-sm size_90"></select></td>
									<th scope="col"><lgcom:message code="DefaultSystem"/></th>
									<td><select name="systemCode" class="form-control input-sm size_90"></select></td>
								</tr>
								<tr>
									<th scope="col"><lgcom:message code="DefaultRegion"/></th>
									<td colspan="3"><span data-action="regionName"></span></td>
								</tr>
								<tr>
									<th scope="col"><lgcom:message code="TimezoneName"/></th>
									<td><span data-action="timezoneName"></span></td>
									<th scope="col"><lgcom:message code="RegionFix"/></th>
									<td><select name="requestRegionCodeUseFlag" class="form-control input-sm size_60"></select></td>
								</tr>
								<tr class="orgInfo" >
									<th scope="col"><lgcom:message code="DefaultOrg"/></th>
									<td><select name="defaultOrgId" class="form-control input-sm"></select></td>

									<th scope="col"><lgcom:message code="DefaultOrgFix"/></th>
									<td><select name="defaultOrgIdUseFlag" class="form-control input-sm size_60"></select></td>
								</tr>
								<tr>
									<th scope="col"><lgcom:message code="Theme"/></th>
									<td>
										<select name="screenDesignThemeId" class="form-control input-sm size_60">
											<option value="A"><lgcom:message code="Dark"/></option>
											<option value="B"><lgcom:message code="Light"/></option>
										</select>
									</td>
									<th scope="col"><lgcom:message code="UserMenuUse"/></th>
									<td><select name="menuUseFlag" class="form-control input-sm size_60"></select></td>
								</tr>
							</tbody>
						</table>
					</form>
				</div>
			</div>
			<div id="userProfile_tab02" class="tab-pane fade tabPane2">
				<div class="searchBlock">
					<form class="form search-wrap">
							<table class="table table-condensed">
								<colgroup>
									<col width="90"/>
									<col width="*"/>
								</colgroup>
								<tbody>
									<tr>
										<th scope="col"><label><lgcom:message code="System"/></label></th>
										<td><select name="systemCode" class="form-control input-sm size_120"></select></td>
									</tr>
								</tbody>
							</table>
					</form>
				</div>

				<div class="gridContent grid-wrap">
					<div class="grid mypageUserAuthGrid"></div>
				</div>				
				
			</div>
		</div>
	</div>
	</section>
</div>
</body>
</html>
