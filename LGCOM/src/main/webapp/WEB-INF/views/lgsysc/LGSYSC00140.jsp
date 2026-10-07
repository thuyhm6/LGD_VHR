<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="devonframe.util.DateUtil" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : LGSYSC00140.jsp
	프로젝트명 : LGD WCFW

	Copyright(c) 2017 LG CNS, All rights reserved.
	설 명 : 본 화면은 Program List를 관리하는 화면입니다.
	작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGSYSC00140 = function() {
	var myForm = this;
	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.searchBlock form');

    /* Layout Setting */
	myForm.setLayout( [ 
		{ name : "searchBlock",  left : 0, right : 0, top : 0 },		
		{ name : "gridControls", left : 0, right : 0, top : "searchBlock", bottom : "contentGrid"},
		{ name : "contentGrid",  left : 0, right : 0, top : "gridControls", bottom : 0 }		
    ]);
    
	// 조회조건 Combo 초기화
	var codeSearch = new CommonCode('lgcom');
	codeSearch.add('systemCode',{codeTypeCode:'LGCOM_SYSTEM_CODE'});
	codeSearch.add('moduleCode',{codeTypeCode:'LGCOM_MODULE_CODE'});
	codeSearch.add('useFlag',{codeTypeCode:'LGCOM_YN_FLAG'});
	codeSearch.execute();
	formUtil.initCombo('systemCode',codeSearch.get('systemCode'),{selectAll:true});
	formUtil.initCombo('moduleCode',codeSearch.get('moduleCode'),{selectAll:true, filter:'systemCode'});
	formUtil.initCombo('useFlag',codeSearch.get('useFlag'),{selectAll:true});
	// 기본 시스템 세팅, 사용여부 초기값
	formUtil.setValue({systemCode:SESSION_USER.systemCode,useFlag:'Y'});
	
	// Lookup 조회, key 속성에 lookup에 매핑될 lookupSourceId 값을 사용한다.
	var code = new CommonCode('lgcom');
	code.add('system', {queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_SYSTEM_CODE'});
	code.add('module', {queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_MODULE_CODE'});
	code.add('programType', {queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_PROGRAM_TYPE_CODE'});
	code.add('effect', {queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_BUSINESS_EFFECT_CODE'});
	code.add('difficult', {queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_DIFFICULTY_CODE'});
	code.add('useFlag', {queryId:'retrieveCommonCodeList',codeTypeCode:'LGCOM_YN_FLAG'});
	code.execute();
	
	// 조회조건 저장 처리
	myForm.searchConditionControl(true);
	// 그리드 초기화
	var grid = buildGrid('.programListGrid');
	
	//파일 매니저 초기화 
    var fileManager = new FileManager( myForm, { moduleCode : "LGCOM", fileCount : 3 } );
	
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			// 조회
			case 'search':
				grid.getGridBase().cancel();
				var param = formUtil.getValue();
				grid.loadData('lgcom','lgsysc/LGSYSC00140/retrieveProgramList',param);
				break;
			// Add
			case 'insert':
				var cgrid = grid.getGridBase();
				cgrid.commit();
				var curr = cgrid.getCurrent();

				if(curr.itemIndex < 0) {
					cgrid.beginAppendRow();
				} else {
					cgrid.beginInsertRow(curr.itemIndex);
				}

				cgrid.setValue(curr.itemIndex,'systemCode','');
				cgrid.setValue(curr.itemIndex,'moduleCode','');
				cgrid.setValue(curr.itemIndex,'programId','');
				cgrid.setValue(curr.itemIndex,'programName','');
				cgrid.setValue(curr.itemIndex,'programTypeCode','');
				cgrid.setValue(curr.itemIndex,'useFlag','Y');
				cgrid.setValue(curr.itemIndex,'transferDate','<%=DateUtil.getDate("yyyy-MM-dd")%>');
				cgrid.setCurrent({column:'systemCode'});
				cgrid.setFocus();
				break;
			// Delete
			case 'delete':
				grid.getGridBase().deleteSelection(true);
				break;
			// Save
			case 'save':
				try {
					grid.getGridBase().commit();
				} catch(e) {
					Message.alert(e.message);
					return;
				}
				if(grid.getRowCount() == 0) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
				// 변경건이 있는지 체크
				if(!grid.isChanged()) {
					Message.alert('<lgcom:message code="error.noChangedData"/>');
					return;
				}
				Message.confirm('<lgcom:message code="question.save"/>', function() {
					grid.saveChanges('lgcom','lgsysc/LGSYSC00140/saveProgramList', function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						myForm.select("button[data-action='search']").trigger('click');
					});
				});
				break;
			// Excel Upload
			case 'excelUpload':
				// 컨텍스트( 어플리케이션 코드 )를 반드시 넣으셔야 합니다.
				var uploader = new ExcelUploader('lgcom','LGSYSC00140',{uploadType:'lgcom'});
				uploader.open( processPostExcelUpload );
				break;
			// Excel Download
			case 'excelDownload':
				Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
					var param = formUtil.getValue();
					var downloader = new Downloader( myForm );
					downloader.excel( "lgcom", "lgsysc/LGSYSC00140/createExcelExportData", param );
				});
				break;
			case 'cacheRetrieve':
				transaction( "lgcom", "lgsysc/LGSYSC00140/retrieveCache", formUtil.getValue() , function(data){
					alert(JSON.stringify(data));
				});
				break;
			case 'cacheSave':
				transaction( "lgcom", "lgsysc/LGSYSC00140/saveCache", formUtil.getValue() , function(data){
					alert(JSON.stringify(data));
				});
				break;
			case 'cacheRemove':
				transaction( "lgcom", "lgsysc/LGSYSC00140/removeCache", formUtil.getValue() , function(data){
					alert(JSON.stringify(data));
				});
				break;
			case 'directCSV':
				Message.confirm('<lgcom:message code="question.excelDownload"/>',function() {
					var downloader = new Downloader( myForm );
					downloader.csvDirectDownload("lgcom", "LGSYSC00140.createDirectCSVDownloadData", formUtil.getValue());
				});
				break;

			case 'batch':
				transaction( "lgcom", "lgsysc/LGSYSC00140/execBatch", JSON.parse('{"V_PARAM" : "TestBatch param1 param2 param3"}') , function(data){
					alert(JSON.stringify(data));
				});
				break;

			case "report" :
				var param = formUtil.getValue();
				var report = new Report( myForm, "lgcom", "lgsysc/LGSYSC00140/retrieveProgramListForReport", param );
				report.open( "M_LGPSBM_1031", { width : 1036, height : 700 }, function(){
					trace( "Report opened!!!!");
				});

				break;
		}
	});

	function processPostExcelUpload( sessionId, uploadType ) {
		//반드시 transaction_sync 를 써야합니다 !!
		transaction_sync('lgcom','lgsysc/LGSYSC00140/createProgramInfoFromUpload',{ 'sessionId' : sessionId, 'uploadType' : uploadType }, function(data) {
			Message.notify('<lgcom:message code="note.completed"/>');
		});
	}

	/* Form Submit 방지 */
	myForm.addEvent('submit','.searchBlock form',function(event) {
		event.preventDefault();
	});
	/* 그리드 이벤트 처리 */
	grid.getGridBase().onCurrentRowChanged = function(grid1, oldRow, newRow) {
		var provider = grid1.getDataProvider();
		var editable = newRow < 0 || provider.getRowState(newRow) === 'created';
		// 신규행이 아니면 Program ID 컬럼 편집 불가
		if(!editable) {
			grid1.setColumnProperty('programId','editable',false);
			// 메뉴에 등록된 프로그램이냐에 따라 삭제버튼 활성화/비활성화
			if(provider.getJsonRow(grid1.getCurrent().dataRow).isMenu == 'Y') {
				// 삭제버튼 비활성화
				myForm.select(".gridControls button[data-action='delete']").attr('disabled','disabled');
			} else {
				// 삭제버튼 활성화
				myForm.select(".gridControls button[data-action='delete']").removeAttr('disabled');
			}
		} else {
			grid1.setColumnProperty('programId','editable',true);
			// 삭제버튼 활성화
			myForm.select(".gridControls button[data-action='delete']").removeAttr('disabled');
		}
	};
	grid.getGridBase().onEditCommit = function(cgrid, index, oldValue, newValue) {
		if(index.column == 'systemCode') {
			var exists = cgrid.existsLookupData('module',[newValue,cgrid.getValue(index.itemIndex,'moduleCode')]);
			if(!exists) {
				var moduleLookup = code.get('module');
				var moduleCode = '';
				for(var i=0; i < moduleLookup.length; i++) {
					if($.trim(moduleLookup[i]['pCode']) == newValue) {
						moduleCode = $.trim(moduleLookup[i]['code']);
						break;
					}
				}
				cgrid.setValue(index.itemIndex,'moduleCode',moduleCode);
			}
		}
		else if(index.column == 'programId') {
			var editable = index.dataRow < 0 || cgrid.getDataProvider().getRowState(editRow) === 'created';
			if(editable) {
				var rst = checkDuplicateProgramId(newValue);
				if(rst) {
					Message.alert('<lgcom:message code="error.duplicateValue"/>');
					cgrid.setCurrent({column:'programId'});
					cgrid.setFocus();
					return false;
				}
			}
		}
	};

	grid.getGridBase().onDataCellClicked =  function (grid, index) {
		if( index.column == "etcAttachFileId" ) {
			var attachmentId = grid.getValue( index.itemIndex, index.fieldIndex );

			fileManager.open( { fileGroupId : attachmentId, 
				editable : true, 
                callback : function( fileGroupId ){
                    grid.setValue( index.itemIndex, index.fieldIndex, fileGroupId );
                }	
            });
		}
	};

    grid.getGridBase().onValidationFail = function(cgrid,itemIndex,column,error) {
        Message.alert(error.message);
    };

	/***  내부 함수  ***/
	function checkDuplicateProgramId(pgmId) {
		var rslt = false;
		transaction_sync('lgcom','lgsysc/LGSYSC00140/retrieveCheckDuplicatedProgramId',{programId:pgmId},function(data) {
			rslt = data.result;
		});
		return rslt;
	}
	// RealGrid 초기화
	function buildGrid(gridId) {
		var grid = new RealGrid( myForm, gridId );
		grid.setPagingMode(true);
		// Data Provider Field 선언
		grid.setFields([
			{ fieldName:'systemCode'        },
			{ fieldName:'moduleCode'        },
			{ fieldName:'programId'         },
			{ fieldName:'programName'       },
			{ fieldName:'programTypeCode'   },
			{ fieldName:'businessEffectCode'},
			{ fieldName:'difficultyCode'    },
			{ fieldName:'transferDate'      },
			{ fieldName:'useFlag'           },
			{ fieldName:'isMenu'            },
			{ fieldName:'etcAttachFileId'   },
			{ fieldName:'linkUrlAddr'   }
		]);

		grid.setLookupsMultiLvl({
			'system': code.get('system'),
			'module': {data:code.get('module'), keyField:['pCode','code']},
			'programType': code.get('programType'),
			'effect': code.get('effect'),
			'difficult': code.get('difficult'),
			'useFlag': code.get('useFlag')
		});
		// Grid Column Set
		grid.setColumns([
			{
				name:'systemCode',
				fieldName:'systemCode',
				width:80,
				header: {text:'<lgcom:message code="System"/>', required : true },
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'system',
				lookupKeyFields: ['systemCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'moduleCode',
				fieldName:'moduleCode',
				width:80,
				header: {text:'<lgcom:message code="Module"/>', required : true},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'module',
				lookupKeyFields: ['systemCode','moduleCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'programId',
				fieldName:'programId',
				width:150,
				header: {text:'<lgcom:message code="ProgramId"/>', required : true},
				styles: {textAlignment:'center'},
				editable: false
			},
			{
				name:'programName',
				fieldName:'programName',
				width:300,
				header: {text:'<lgcom:message code="ProgramName"/>', required : true },
			},
			{
				name:'programTypeCode',
				fieldName:'programTypeCode',
				width:100,
				header: {text:'<lgcom:message code="ProgramType"/>', required : true},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'programType',
				lookupKeyFields: ['programTypeCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'businessEffectCode',
				fieldName:'businessEffectCode',
				width:100,
				header: {text:'<lgcom:message code="BusinessEffect"/>'},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'effect',
				lookupKeyFields: ['businessEffectCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'difficultyCode',
				fieldName:'difficultyCode',
				width:100,
				header: {text:'<lgcom:message code="Difficulty"/>'},
				styles: {textAlignment:'center' },
				lookupDisplay: true,
				lookupSourceId: 'difficult',
				lookupKeyFields: ['difficultyCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
            {
                name:'etcAttachFileId',
                fieldName:'etcAttachFileId',
                width:50,
                cursor: "pointer",
                editable : false,
                header: {text:'<lgcom:message code="Manual"/>'},
                styles: {textAlignment:'center',  iconLocation : "center", iconIndex : 0, iconLocation: "center", iconAlignment : "center"},
                imageList: "images",
                renderer: { type : "icon" , textVisible : false  },
                dynamicStyles : [ { criteria: "value != ''",  styles : "iconIndex=1" } ]
            },
			{
				name:'transferDate',
				fieldName:'transferDate',
				width:100,
				header: {text:'<lgcom:message code="DeployDate"/>'},
				styles: {textAlignment:'center'},
				editor: {type:'date', datetimeFormat:'yyyy-MM-dd'}
			},
			{
				name:'useFlag',
				fieldName:'useFlag',
				width:80,
				header: {text:'<lgcom:message code="UseFlag"/>', required : true},
				styles: {textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'useFlag',
				lookupKeyFields: ['useFlag'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'}
			},
			{
				name:'linkUrlAddr',
				fieldName:'linkUrlAddr',				
				width:200,				
				header: {text:'<lgcom:message code="linkUrlAddr"/>'},
				styles: {textAlignment:'center'}
			}
		]);
		// Grid Option Set
		grid.setOptions({
			grid: {
                select : { style : "block" },
				hideDeletedRows: false,
				indicator: {visible:false},
				panel: {visible:false},
				checkBar: {visible:false},
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
		// Context Menu Set
		grid.setContextMenu();
		// Validation Set
		grid.setValidations([
			{criteria: "value['systemCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='System'/>"/>',mode:'always',level:'info'},
			{criteria: "value['moduleCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='Module'/>"/>',mode:'always',level:'info'},
			{criteria: "value['programId'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='ProgramId'/>"/>',mode:'always',level:'info'},
			{criteria: "value['programName'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='ProgramName'/>"/>',mode:'always',level:'info'},
			{criteria: "value['programTypeCode'] is not empty",message:'<lgcom:message code="error.required" arguments="<lgcom:message code='ProgramType'/>"/>',mode:'always',level:'info'}
		]);


		return grid;
	}
};

LGSYSC00140.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function() {
		var form = new LGSYSC00140();
		form.init();
		<% if(com.lgd.lgcom.common.util.LGCOMUtils.isEnvDev()) { %>
		if(SESSION_USER.ssoId != "sskeun") {
			$("button[test='true']").remove();
		}
		<% } %>
	});
});

</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Program List</h2>
	</div>
	<%-- 조회영역 --%>
	<div class="searchBlock">
		<form class="form search-wrap">
		        <table class="table" >
		            <colgroup>
		                <col width="90">
		                <col width="90">
		                <col width="90">
		                <col width="90">
		                <col width="120">
		                <col width="220">
		                <col width="90">
		                <col width="90">
		            </colgroup>
		            <tbody>
		                <tr>
		                    <th><label class="required" ><lgcom:message code="System" /></label></th>
		                    <td>
		                        <select class="form-control input-sm" name="systemCode"></select>
		                    </td>

		                    <th><label ><lgcom:message code="Module" /></label></th>
		                    <td>
		                        <select class="form-control input-sm" name="moduleCode"></select>
		                    </td>

		                    <th><label><lgcom:message code="ProgramName" /></label></th>
		                    <td><input type="text" class="form-control input-sm" name="programName"></td>

		                    <th><label ><lgcom:message code="UseFlag" /></label></th>
		                    <td>
		                        <select class="form-control input-sm" name="useFlag"></select>
		                    </td>

		                </tr>
		            </tbody>
		        </table>
		    <button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search" data-access="LGSYSC00140/retrieveProgramList" ><lgcom:message code="search" /></button>
	    </form>

	</div>
	<%-- 그리드 버튼 영역 --%>
	<div class="gridControls module-group text-right">
		<div class="btn-toolbar">	
			<div class="btn-group">	
			    <button type="button" class="btn btn-default btn-sm" data-action="report"><span class="ico ico-excel-down"  aria-hidden="true"></span> Report</button>
		        <button type="button" class="btn btn-default btn-sm" data-action="excelDownload"><span class="ico ico-excel-down"  aria-hidden="true"></span> <lgcom:message code="Download"/></button>
		        <% if(com.lgd.lgcom.common.util.LGCOMUtils.isEnvDev()) { %>
		        <button type="button" class="btn btn-default btn-sm" data-action="directCSV"><span class="ico ico-excel-down"  aria-hidden="true"></span> DirectCSV</button>
		        <% } %>
		     </div>
			<div class="btn-group">
				  <button type="button" class="btn btn-default dropdown-toggle btn-sm" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
				    <span class="ico ico-excel-up" aria-hidden="true"></span> <lgcom:message code="Upload"/><span class="caret"></span>
				  </button>
				  <ul class="dropdown-menu">
				    <li><a href="#" data-action="excelUpload"><lgcom:message code="Upload"/></a></li>
				  </ul>
			</div>
			<div class="btn-group">		
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="insert"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Add"/></button>
				<button class="btn btn-default btn-sm ico-lgd" type="button" role="button" data-action="delete"><span class="fa fa-plus" aria-hidden="true"></span> <lgcom:message code="Delete"/></button>
			</div>
			<div class="btn-group">	
				<button class="btn btn-darkgray btn-sm" type="button" role="button" data-action="save" data-access="LGSYSC00140/saveProgramList"><lgcom:message code="save"/></button>				
			</div>
		</div>			
	</div>
	<%-- RealGrid 영역 --%>
	<div class="contentGrid grid-wrap">
		<div class="grid programListGrid"></div>
	</div>
	</section>
</div>
</body>
</html>
