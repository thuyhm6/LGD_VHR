<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSETC00080.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2016 LG CNS,  All rights reserved.

    설 명 : 본 화면은 각 Scope별 Profile을 관리하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Profile</title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGSETC00080 = function() {
	var myForm = this;
	// 조회조건 Combo 초기화
	var formUtil = new FormUtil(myForm,'.searchBlock form');
	/* 팝업용 변수 선언 */
	myForm.popupInfo = {
		parentCodePopup:{row:-1, col:'', modYn:'N', findKey:'', codeData:[]} ,
		userPopup: { searchMode:'single', departmentName:'', mailAddr:'', employeeNo:'', employeeName:'', userData:[] }
	};
	
    /* Layout Setting 좌측 고정, 우측 Flexible */
	myForm.setLayout( [ 
		{ name  : "searchBlock",   left : 0, right : 0, top : 0 },		
		{ name  : "gridControls1", left : 0, right : 0, top : "searchBlock", width : 600, bottom : "gridContent2" },
		{ name  : "gridControls2", left : "gridControls1", right : 0, top : "searchBlock", bottom : "gridContent2" },	 	
		{ name  : "gridContent1",  left : 0, right : 0, top : "gridControls1", width : 600, bottom : 0},
	 	{ name  : "gridContent2",  left : "gridControls1", right : 0, top : "gridControls2", bottom : 0  }		
	]);    
    
    
	var code = new CommonCode("lgcom");
	code.add('classCode', {codeTypeCode:'LGCOM_PROFILE_CLASS_CODE'});
	code.add('useFlag',{codeTypeCode:'LGCOM_YN_FLAG'});
	code.execute();
	formUtil.initCombo('profileScopeCode',code.get('classCode'),{selectAll:true});
	formUtil.initCombo('useFlag',code.get('useFlag'),{selectAll:true});
	// 사용여부 초기값
	formUtil.setValue({useFlag:'Y'});
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	
	// 그리드 선언
	grid1 = buildGrid(".profileMasterGrid");
	grid2 = buildGrid(".profileSubGrid");
	
	
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			// 조회
			case 'search':
				grid1.getGridBase().cancel();
				grid2.getGridBase().cancel();
				var param = formUtil.getValue();
				grid1.loadData('lgcom','lgsetc/LGSETC00080/retrieveProfileMasterList', param);
				break;
			// M 추가
			case 'add1':
				var cgrid = grid1.getGridBase();
				cgrid.commit();
				if(cgrid.getCurrent().itemIndex < 0) {
					cgrid.beginAppendRow();
				} else {
					cgrid.beginInsertRow(cgrid.getCurrent().itemIndex);
				}
				cgrid.setValue(cgrid.getCurrent().itemIndex,'useFlag','Y');
				cgrid.setCurrent({column:'profileName'});
				cgrid.setFocus();
				break;
			// M 삭제
			case 'del1':
				grid1.getGridBase().deleteSelection(true);
				break;
			// M 저장
			case 'save1':
				try {
					grid1.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				if(grid1.getRowCount() == 0) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
				// 변경건이 있는지 체크
				if(!grid1.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					grid1.saveChanges('lgcom','lgsetc/LGSETC00080/saveProfileMasterList', function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						myForm.select("button[data-action='search']").trigger('click');
					});
				});
				break;
			// S 추가
			case 'add2':
				var egrid = grid1.getGridBase();
				var cgrid = grid2.getGridBase();
				cgrid.commit();
				// 조회된 Profile Master가 없다면 종료
				if(egrid.getItemCount() < 1) return;
				// 선택된 Profile Master Id가 없다면 종료
				if($.trim(egrid.getValue(egrid.getCurrent().itemIndex,'profileId')) == '') return;
				if(cgrid.getCurrent().itemIndex < 0) {
					cgrid.beginAppendRow();
				} else {
					cgrid.beginInsertRow(cgrid.getCurrent().itemIndex);
				}
				cgrid.setValue(cgrid.getCurrent().itemIndex,'profileId',egrid.getValue(egrid.getCurrent().itemIndex,'profileId'));
				cgrid.setValue(cgrid.getCurrent().itemIndex,'useFlag','Y');
				var currCell = cgrid.getCurrent();
				cgrid.setCurrent({column: 'profileApplyTgClassCode'});
				cgrid.setFocus();
				break;
			// S 삭제
			case 'del2':
				grid2.getGridBase().deleteSelection(true);
				break;
			// S 저장
			case 'save2':
				try {
					grid2.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				if(grid2.getRowCount() == 0) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
				// 변경건이 있는지 체크
				if(!grid2.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					grid2.saveChanges('lgcom','lgsetc/LGSETC00080/saveProfileSetupList', function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						fncRetrieveProfileSetupList(grid1.getGridBase().getCurrent().itemIndex);
					});
				});
				break;
			// Force Delete
			case 'purge':
				var cgrid = grid1.getGridBase();
				cgrid.cancel();
				if(cgrid.getItemCount() < 1) return;
				if(cgrid.getCurrent().itemIndex < 0) return;
				Message.confirm('<lgcom:message code="question.reallyDelete"/>', function() {
					var param = cgrid.getValues(cgrid.getCurrent().itemIndex);
					transaction('lgcom','lgsetc/LGSETC00080/deleteProfileForce',param,function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});
				break;
		}
	});
	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	/* 그리드 이벤트 처리 */
	grid1.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		// 신규행이 아니면 Program ID 컬럼 편집 불가
		if(!editable) {
			// 삭제버튼 활성화
			myForm.select(".gridControls1 button[data-action='del1']").attr('disabled','disabled');
		} else {
			// 삭제버튼 비활성화
			myForm.select(".gridControls1 button[data-action='del1']").removeAttr('disabled');
			cgrid.setCellStyles(newRow,'profileName','addStyle');
		}
		fncRetrieveProfileSetupList(newRow);
	};
	grid2.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		var provider = cgrid.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		// 신규행이 아니면 Program ID 컬럼 편집 불가
		if(!editable) {
			cgrid.setColumnProperty('profileApplyTgClassCode','editable',false);
			cgrid.setColumnProperty('applyTargetValue','editable',false);
			cgrid.setColumnProperty('applyTargetValue','button','none');
			// 삭제버튼 활성화
			myForm.select(".gridControls2 button[data-action='del2']").attr('disabled','disabled');
		} else {
			cgrid.setColumnProperty('profileApplyTgClassCode','editable',true);
			cgrid.setColumnProperty('applyTargetValue','editable',true);
			cgrid.setColumnProperty('applyTargetValue','button','action');
			// 삭제버튼 비활성화
			myForm.select(".gridControls2 button[data-action='del2']").removeAttr('disabled');
			// 필수입력 표시
			cgrid.setCellStyles(newRow,'profileApplyTgClassCode','addStyle');
			cgrid.setCellStyles(newRow,'applyTargetValue','addStyle');
			cgrid.setCellStyles(newRow,'profileOptionValue','addStyle');
		}
	};
	grid2.getGridBase().onCellButtonClicked = function(cgrid, itemIndex, column) {
		cgrid.commitEditor();
		// scope
		var scopeCode = $.trim(cgrid.getValue(itemIndex,'profileApplyTgClassCode'));
		var targetName = $.trim(cgrid.getValue(itemIndex,'applyTargetName'));
		switch(scopeCode) {
			// SYSTEM 검색 팝업
			case 'SYSTEM':
				// 팝업에 사용될 Argument 객체 선언
				var _popup = myForm.popupInfo.parentCodePopup;
				// 입력된 사용자명을 세팅한다.
				_popup['systemCode'] = 'LGCOM';
				_popup['moduleCode'] = 'LGSYSC';
				_popup['findKey'] = 'LGCOM_SYSTEM_CODE';
				_popup['row'] = itemIndex;
				_popup['col'] = column.name;
				var popup = new Popup( myForm, "lgcom", "M_LGSETC_1127", '<lgcom:message code="CodeValuePopupTitle"/>' );
				popup.setSize(900,500);
				popup.open(function() {
					var array = _popup.codeData;
					if(!Array.isArray(array)) return;
					if(array.length == 0) return;
					if(array.length == 1) {
						// 중복 체크
						cgrid.setValue(itemIndex,'applyTargetValue',array[0].commonCode);
						cgrid.setValue(itemIndex,'applyTargetName',array[0].commonCodeName);
						if(!fncCheckDuplicateSetup(itemIndex)) {
							Message.alert('<lgcom:message code="error.DupCheck" arguments="'+scopeCode+'/'+targetName+'"/>');
							cgrid.setValue(itemIndex,'applyTargetValue','');
							cgrid.setValue(itemIndex,'applyTargetName','');
						}
						cgrid.commit();
					}
					_popup.codeData = [];
				});
				break;
			// 사용자 검색 팝업
			case 'USER':
				// 팝업에 사용될 Argument 객체 선언
				var _popup = myForm.popupInfo.userPopup;
				// 입력된 사용자명을 세팅한다.
				_popup.employeeName = targetName;
				// 팝업을 호출한다.
				var popup = new Popup(myForm,'lgcom','M_LGUTLC_1142','<lgcom:message code="UserSearch"/>');
				popup.setSize(800,494);	// searchMode 'Single'
				popup.open(function() {
					// Employee No
					cgrid.setValue(itemIndex,'applyTargetValue',$.trim(_popup.userData[0].userId));
					// Employee Name
					cgrid.setValue(itemIndex,'applyTargetName',$.trim(_popup.userData[0].employeeName));
					// 중복 체크
					if(!fncCheckDuplicateSetup(itemIndex)) {
						Message.alert('<lgcom:message code="error.DupCheck" arguments="'+scopeCode+'/'+targetName+'"/>');
						cgrid.setValue(itemIndex,'applyTargetValue','');
						cgrid.setValue(itemIndex,'applyTargetName','');
					}
					cgrid.commit();
					_popup.userData = [];
				});
				break;
		}
	};
	grid2.getGridBase().onEditChange = function(cgrid, index, value) {
		if(index.column == 'profileApplyTgClassCode') {
			if(value == 'SITE') {
				cgrid.setColumnProperty('applyTargetName','button','none');
				cgrid.setValue(index.itemIndex,'applyTargetValue','BizWeb');
				cgrid.setValue(index.itemIndex,'applyTargetName','BizWeb');
				cgrid.setColumnProperty('applyTargetName','editable',false);
			} else {
				cgrid.setColumnProperty('applyTargetName','button','action');
				cgrid.setValue(index.itemIndex,'applyTargetValue','');
				cgrid.setValue(index.itemIndex,'applyTargetName','');
				cgrid.setColumnProperty('applyTargetName','editable',true);
			}
		}
	};
	/*** 내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode( true );
		switch(gridId) {
			case '.profileMasterGrid':
				//컬럼 설정
				grid.setFields([
					{ fieldName:'profileId'  , dataType:'text'},
					{ fieldName:'profileName', dataType:'text'},
					{ fieldName:'profileDesc', dataType:'text'},
					{ fieldName:'useFlag'    , dataType:'text'}
				]);
				// Lookup 세팅
				grid.setLookups({'useflag':code.get('useFlag')});
				// Grid Column 세팅
				grid.setColumns([
					{
						name:'profileName',
						fieldName:'profileName',
						width:180,
						header: {text:'<lgcom:message code="ProfileName"/>', required: true},
					},
					{
						name:'profileDesc',
						fieldName:'profileDesc',
						width:200,
						header: {text:'<lgcom:message code="Description"/>'}
					},
					{
						name:'useFlag',
						fieldName:'useFlag',
						width:90,
						header: {text:'<lgcom:message code="UseFlag"/>'},
						styles: {textAlignment:'center'},
						lookupDisplay: true,
						lookupSourceId: "useflag",
						lookupKeyFields: ['useFlag'],
						editor: {type:'dropDown', textReadOnly : true}
					}
				]);
				// Validation Set
				grid.setValidations([
					{criteria: "value['profileName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='ProfileName'/>"/>',mode:'always',level:'error'},
					{criteria: "value['useFlag'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='UseFlag'/>"/>',mode:'always',level:'error'}
				]);
				break;
			case '.profileSubGrid':
				//컬럼 설정
				grid.setFields([
					{ fieldName:'profileId'              , dataType:'text'  },
					{ fieldName:'dataSerialNo'           , dataType:'number'},
					{ fieldName:'profileApplyTgClassCode', dataType:'text'  },
					{ fieldName:'applyTargetValue'       , dataType:'text'  },
					{ fieldName:'applyTargetName'        , dataType:'text'  },
					{ fieldName:'profileOptionValue'     , dataType:'text'  },
					{ fieldName:'useFlag'                , dataType:'text'  }
				]);
				// Lookup 세팅
				grid.setLookups({
					classCode:code.get('classCode'),
					useflag:code.get('useFlag')
				});
				// Column 세팅
				grid.setColumns([
					{
						name:'profileApplyTgClassCode',
						fieldName:'profileApplyTgClassCode',
						width:80,
						header: {text:'<lgcom:message code="Scope"/>', required: true},
						styles: {textAlignment:'center'},
						lookupDisplay: true,
						lookupSourceId: "classCode",
						lookupKeyFields: ['profileApplyTgClassCode'],
						editor: {type:'dropDown', textReadOnly : true}
					},
					{
						name:'applyTargetName',
						fieldName:'applyTargetName',
						width:150,
						header: {text:'<lgcom:message code="Target"/>'},
						styles: {textAlignment:'center'},
						button: 'action'
					},
					{
						name:'profileOptionValue',
						fieldName:'profileOptionValue',
						width:150,
						header: {text:'<lgcom:message code="Value"/>', required: true},
					},
					{
						name:'useFlag',
						fieldName:'useFlag',
						width:80,
						header: {text:'<lgcom:message code="UseFlag"/>'},
						styles: {textAlignment:'center'},
						lookupDisplay: true,
						lookupSourceId: "useflag",
						lookupKeyFields: ['useFlag'],
						editor: {type:'dropDown', textReadOnly : true}
					}
				]);
				// Validation Set
				grid.setValidations([
					{criteria: "value['profileApplyTgClassCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='Scope'/>"/>',mode:'always',level:'error'},
					{criteria: "value['applyTargetName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='Target'/>"/>',mode:'always',level:'error'},
					{criteria: "value['profileOptionValue'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='Value'/>"/>',mode:'always',level:'error'},
					{criteria: "value['useFlag'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='UseFlag'/>"/>',mode:'always',level:'error'}
				]);
				break;
		}
		//옵션 설정
		grid.setOptions({
			grid: {
				softDeleting: true,
				deleteCreated: true,
				hideDeletedRows:false,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
				stateBar: {visible:true},
				footer: {visible:false},
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
		//마우스 오른쪽 클릭시 메뉴
		grid.setContextMenu();
		return grid;
	}
	// Profile Setup 목록 조회
	function fncRetrieveProfileSetupList(rowIdx) {
		if(grid2.getGridBase()) grid2.getGridBase().cancel();
		if(grid1.getGridBase()) {
			var rowData = grid1.getGridBase().getValues(rowIdx);
			var param = {profileId:''};
			if(rowData && rowData.profileId) {
				param['profileId'] = rowData.profileId;
				grid2.loadData('lgcom','lgsetc/LGSETC00080/retrieveProfileSetupList',param);
			} else {
				grid2.getDataProvider().clearRows();
			}
		}
	}
	// 중복 체크
	function fncCheckDuplicateSetup(rowIdx) {
		var cgrid = grid2.getGridBase();
		var classCode = $.trim(cgrid.getValue(rowIdx,'profileApplyTgClassCode'));
		var targetCode = $.trim(cgrid.getValue(rowIdx,'applyTargetValue'));
		var dupcnt = 0;
		for(var i=0; i < cgrid.getItemCount(); i++) {
			var rowClass = $.trim(cgrid.getValue(i,'profileApplyTgClassCode'));
			var rowTarget = $.trim(cgrid.getValue(i,'applyTargetValue'));
			if(i == rowIdx) continue;
			if(classCode == 'SITE' && classCode == rowClass) {
				dupcnt++;
			}
			else if(classCode == 'SYSTEM' || classCode == 'USER') {
				if(classCode == rowClass && targetCode == rowTarget) {
					dupcnt++;
				}
			}
		}
		if(dupcnt == 0) return true;
		return false;
	}
};

LGSETC00080.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function() {
		var form = new LGSETC00080();
		form.init();
	});
});
</script>
</head>
<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Profile</h2>
	</div>
	<div class="searchBlock">
		<form class="form search-wrap">
				<table class="table">
					<colgroup>
						<col width="70"  />
						<col width="110" />
						<col width="100" />
						<col width="150" />
						<col width="100" />
						<col width="150" />
						<col width="80"  />
						<col width="60"  />
					</colgroup>
					<tbody>
						<tr>
							<th scope="col"><label><lgcom:message code="Scope"/></label></th>
							<td><select name="profileScopeCode" class="form-control input-sm"></select></td>
							<th scope="col"><label><lgcom:message code="ProfileName"/></label></th>
							<td><input type="text" name="profileName" class="form-control input-sm"/></td>
							<th scope="col"><label><lgcom:message code="Description"/></label></th>
							<td><input type="text" name="profileDesc" class="form-control input-sm"/></td>
							<th><label><lgcom:message code="UseFlag"/></label></th>
							<td><select name="useFlag" class="form-control input-sm"></select></td>							
						</tr>
					</tbody>
				</table>
				<button type="button" class="btn btn-lgd btn-sm btn-search" data-action="search"><lgcom:message code="Search"/></button>
		</form>
	</div>
	<div class="gridControls gridControls1 module-group text-right">
		<div class="btn-toolbar">	
			<div class="btn-group">
				<button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="add1"><span class="fa fa-plus" aria-hidden="true"></span><lgcom:message code="Add"/></button>
				<button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="del1"><span class="fa fa-remove" aria-hidden="true"></span><lgcom:message code="Delete"/></button>
			</div>
			<div class="btn-group">	
				<button class="btn btn-gray btn-sm" type="submit" data-action="purge" data-access="LGSETC00080/deleteProfileForce"><lgcom:message code="ForceDelete"/></button>
				<button class="btn btn-gray btn-sm" type="submit" data-action="save1"><lgcom:message code="Save"/></button>
			</div>	
		</div>	
	</div>
	<div class="gridControls gridControls2 module-group text-right">
		<div class="btn-toolbar">	
			<div class="btn-group">
				<button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="add2"><span class="fa fa-plus" aria-hidden="true"></span><lgcom:message code="Add"/></button>
				<button class="btn btn-default btn-sm ico-lgd" type="submit" data-action="del2"><span class="fa fa-remove" aria-hidden="true"></span><lgcom:message code="Delete"/></button>
            </div>
			<div class="btn-group">            
				<button class="btn btn-gray btn-sm" type="submit" data-action="save2"><lgcom:message code="Save"/></button>
			</div>
		</div>		
	</div>
	<div class="gridContent1 grid-wrap">
		<div class="grid profileMasterGrid"></div>
	</div>
	<div class="gridContent2 grid-wrap">
		<div class="grid profileSubGrid"></div>
	</div>
	</section>
</div>
</body>
</html>
