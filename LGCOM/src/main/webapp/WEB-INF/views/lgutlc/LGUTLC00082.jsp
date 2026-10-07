<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGUTLC00082.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 Dynamic Query 금일 실행 결과를 조회하는 화면입니다.
    작성자 : wcfw
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

var LGUTLC00082 = function() {
	var myForm = this;
	var _popupInfo;
	var myInterval;
	/* 상태 Lookup Setting */
	var code = new CommonCode(DQ_CONTEXT_PATH);

    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "dataBlock", left : 0, right : 0, top : 0 },		
		{ name  : "contentGrid", left : 0, right : 0, top : "dataBlock", bottom : "controls"},
		{ name  : "controls", left : 0, right : 0, bottom : 0 }	 	
	]);	
	// Form Util 선언
	var formUtil = new FormUtil(myForm,'.dataBlock form');
	// Grid 초기화
	var grid = buildGrid('.todaySearchListGrid');
	/*** OnLoad 이벤트 **/
	myForm.initMyForm = function() {
		_popupInfo = myForm.getParent().popupInfo;
		fncRetrieveList();
	};
	/***  이벤트 핸들러  ***/
	myForm.addEvent('click','button[data-action]',function(event) {
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch(action) {
			case 'close':
				Popup.closePopup( myForm );
				break;
		}
	});
	/* 마우스 Out 시 쿼리 내용 숨기기 */
	myForm.addEvent('mouseout',".container div[data-action='viewQueryPanel']",function(event) {
		$(this).empty();
		$(this).hide();
	});
	/* Refresh Checkbox 클릭 */
	myForm.addEvent('change',".dataBlock form input[name='refreshFlag']",function(event) {
		var checkbox = $(event.target);
		if(checkbox.is(':checked')) {
			var interval = (formUtil.getValue('refreshInterval') - 0) * 1000;
			if(typeof(myInterval) != 'undefined') {
				clearInterval(myInterval);
			}
			myInterval = setInterval(fncRetrieveList, interval);
			_popupInfo['myInterval'] = myInterval;
		} else {
			if(typeof(myInterval) != 'undefined') clearInterval(myInterval);
		}
	});
	/* Interval 간격 변경 */
	myForm.addEvent('change',".dataBlock form select[name='refreshInterval']",function(event) {
		var interval = (formUtil.getValue('refreshInterval') - 0) * 1000;
		if(typeof(myInterval) != 'undefined') {
			clearInterval(myInterval);
		}
		myInterval = setInterval(fncRetrieveList,interval);
		_popupInfo['myInterval'] = myInterval;
	});
	/* 수행 쿼리 확인 및 Excel Export */
	grid.getGridBase().onDataCellClicked = function(cgrid,index) {
		var columnName = $.trim(index.column);
		switch(columnName) {
			case 'queryName':
				_popupInfo['histRow'] = cgrid.getValues(index.itemIndex);
				Popup.closePopup( myForm, true);
				break;
			case 'statusButton':
				var val = $.trim(cgrid.getValue(index.itemIndex, index.column));
				if(val == '') {
					return;
				}
				var param = {
					sessionId: cgrid.getValue(index.itemIndex,'sessionId'),
					queryId: cgrid.getValue(index.itemIndex,'queryId')
				};
				var downloader = new Downloader( myForm );
				// POI Excel File
				//downloader.excelDynamicQuery(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00080/exportDynamicQueryExcel',param);
				// CSV File
				downloader.csvDynamicQuery(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00080/exportDynamicQueryExcel',param);
				break;
		}
	};
	/*** 내부 함수 ***/
	function buildGrid(gridId) {
		var grid = new RealGrid(myForm, gridId);
		grid.setPagingMode(true);
		// Grid Field Set
		grid.setFields([
			{ fieldName:'accessGroup'      },
			{ fieldName:'orgId'            },
			{ fieldName:'applicationUserId'},
			{ fieldName:'sessionId'        },
			{ fieldName:'queryId'          },
			{ fieldName:'queryName'        },
			{ fieldName:'queryDesc'        },
			{ fieldName:'queryArgs'        },
			{ fieldName:'programId'        },
			{ fieldName:'resultRowCount'   , dataType:'number' },
			{ fieldName:'requestId'        , dataType:'number' },
			{ fieldName:'startDate'        },
			{ fieldName:'endDate'          },
			{ fieldName:'statusCode'       },
			{ fieldName:'resultContent'    },
			{ fieldName:'creationDate'     },
			{ fieldName:'statusButton'     }
		]);
		// Lookup 설정
		var lookup = code.execute('status',{codeTypeCode:'LGCOM_DQ_CONC_STATUS'});
		grid.setLookups({'status':lookup});
		// Grid Column Set
		grid.setColumns([
			{
				name:'creationDate',
				fieldName:'creationDate',
				width:60,
				header: {text:'<lgcom:message code="ExecuteDate"/>'},
				styles:{textAlignment:'center'},
				editable: false
			},
			{
				name:'queryName',
				fieldName:'queryName',
				width:180,
				header: {text:'<lgcom:message code="QueryName"/>'},
				renderer:{showTooltip:true},
				styles:{fontUnderline:true},
				editable: false
			},
			{
				name:'requestId',
				fieldName:'requestId',
				width:74,
				header: {text:'<lgcom:message code="RequestId"/>'},
				styles:{textAlignment:'center'},
				editable: false
			},
			{
				name:'startDate',
				fieldName:'startDate',
				width:60,
				header: {text:'<lgcom:message code="StartTime"/>'},
				styles:{textAlignment:'center'},
				editable: false
			},
			{
				name:'endDate',
				fieldName:'endDate',
				width:60,
				header: {text:'<lgcom:message code="EndTime"/>'},
				styles:{textAlignment:'center'},
				editable: false
			},
			{
				name:'resultRowCount',
				fieldName:'resultRowCount',
				width:60,
				header: {text:'<lgcom:message code="Count"/>'},
				styles:{textAlignment:'far',numberFormat:'#,###'},
				editable: false
			},
			{
				name:'statusCode',
				fieldName:'statusCode',
				width:74,
				header: {text:'<lgcom:message code="Status"/>'},
				styles:{textAlignment:'center'},
				lookupDisplay: true,
				lookupSourceId: 'status',
				lookupKeyFields: ['statusCode'],
				editor: {type:'dropDown',textReadOnly:true,commitOnSelect:true,dropDownPosition:'editor'},
				editable: false
			},
			{
				name:'resultContent',
				fieldName:'resultContent',
				width:150,
				header: {text:'<lgcom:message code="ErrorMessage"/>'},
				renderer:{showTooltip:true},
				editable: false
			},
			{
				name:'statusButton',
				fieldName:'statusButton',
				width:50,
				header: {text:'<lgcom:message code="exportExcel"/>'},
				styles:{textAlignment:'center'},
				renderer: {type:'image',smoothing:false},
				styles: {textAlignment:'center', iconLocation:'center', iconIndex:0, iconLocation:'center', iconAlignment:'center'},
				imageList: 'images',
				cursor:'pointer',
				renderer: {type:'icon',textVisible:false},
				dynamicStyles: [{ criteria:'value is not empty', styles:'iconIndex=5'}],
				editable: false
			}
		]);
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
					height: 30,
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
	function fncRetrieveList() {
		var param = {
			imagePath: '<c:url value="/static/img/realgrid/icon_fileDown.png"/>'
		};
		grid.loadData(DQ_CONTEXT_PATH,'lgutlc/LGUTLC00080/retrieveDynamicQueryTodayList', param);
	}
};

LGUTLC00082.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGUTLC00082();
		form.init();
		form.initMyForm();
	});
});
</script>
</head>

<body>
<div class="mdi-container popup">
  <section class="page-content">
	<div class="pageHeader">
		<h2>Dynamic Query Today List</h2>
	</div>
	<div class="dataBlock">
		<form class="form">
			<table class="table table-condensed">
				<colgroup>
					<col width="15%"/>
					<col width="35%"/>
					<col width="15%"/>
					<col width="35%"/>
				</colgroup>
				<tbody>
					<tr>
						<th scope="col"><label><lgcom:message code="Refresh"/></label></th>
						<td><input type="checkbox" name="refreshFlag" value="Y"/></td>
						<th scope="col"><label><lgcom:message code="Interval"/></label></th>
						<td>
							<select name="refreshInterval" class="form-control input-sm size_50" style="display:inline-block;">
								<option value="10">10</option>
								<option value="20">20</option>
								<option value="30">30</option>
								<option value="60">60</option>
							</select>&nbsp;<label>Sec</label>
						</td>
					</tr>
				</tbody>
			</table>
		</form>
	</div>
	<div class="contentGrid grid-wrap">
		<div class="grid todaySearchListGrid"></div>
	</div>
	<div class="controls modal-footer">
		<button class="btn btn-gray btn-sm" type="button" role="button" data-action="close"><lgcom:message code="Close"/></button>
	</div>
	</section>
</div>
</body>
</html>
