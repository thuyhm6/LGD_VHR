<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : LGSYSC00110.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 role별 메뉴 정보를 관리하는 화면입니다.
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Role Menu</title>
<script type="text/javascript">
var LGSYSC00110 = function(){
	var grid1,grid2;
	var myForm = this;

    /* Layout Setting */
	myForm.setLayout( [ 
		{ name  : "searchBlock",  left : 0, right : 0, top : 0 },		
		{ name  : "gridControls", left : 0, right : 0, top : "searchBlock", bottom : "gridContent" },
		{ name  : "gridContent",  left : 0, right : 0, top : "gridControls", width : 700, bottom : 0 },	 	
		{ name  : "treeContent",  left : "gridContent", right : 0, top : "gridControls", bottom : 0},		
	]); 	
	
	var formUtil = new FormUtil(myForm,'.searchBlock form');

 	// combo 목록 조회
	var code = new CommonCode("lgcom");
	code.add( "LGCOM_SYSTEM_CODE", { codeTypeCode:'LGCOM_SYSTEM_CODE' });
	code.add( "LGCOM_MODULE_CODE", { codeTypeCode:'LGCOM_MODULE_CODE' });
	code.execute();

	formUtil.initCombo( "systemCode", code.get("LGCOM_SYSTEM_CODE"), {selectAll : true } );
	formUtil.initCombo( "moduleCode", code.get("LGCOM_MODULE_CODE"), {selectAll : true, filter : "systemCode" } );

	grid1 = buildGrid("LGSYSC00110_grid1");
	grid2 = buildGrid("LGSYSC00110_grid2");

	/* 그리드 이벤트 처리 */
	grid1.getGridBase().onCurrentRowChanged = function(cgrid, oldRow, newRow) {
		if(newRow < 0) return;
		var rowData = cgrid.getValues(newRow);
		grid2.loadData('lgcom','lgsysc/LGSYSC00110/retrieveRoleMenuList',{
			roleCode: rowData.roleCode,
			systemCode: rowData.systemCode,
			moduleCode: rowData.moduleCode
		}, function (provider) {
			//전체 그리드 로우수 체크 , 수만큼 돌려서 ynFlag가 Y인놈은 체크
			var indexList = [];
			grid2.getGridBase().expandAll();
			var gridCount = grid2.getDataProvider().getRowCount();
			for(var inx = 0; inx < gridCount; inx++) {
				var rowData2 = grid2.getDataProvider().getJsonRow(grid2.getGridBase().getDataRow(inx));
				if(rowData2.ynFlag=='Y') {
					indexList.push(inx);
				}
			}
			grid2.getGridBase().checkItems(indexList,true);
			grid2.getGridBase().collapseAll();
		});
	}

	/*** 부모메뉴 선택/해제시 자식노드 전체 선택/해제 ***/
	grid2.getGridBase().onItemChecked = function (grid,itemIndex,checked) {
		var gridProvider = grid2.getDataProvider();
		var gridMain = grid2.getGridBase();
		treeChecked(gridProvider,gridMain,itemIndex,checked);
	}

	function treeChecked(gridProvider, gridMain, index, checked) {
		index = gridMain.getDataRow(index);
		var childrens = gridProvider.getChildren(index);
		var cdrows = [];
		if(childrens != null) {
			$.each(childrens, function(k, v) {
				if (v < 0)
					return false;
				cdrows.push(v);
				var childrens2 = gridProvider.getChildren(v);
				$.each(childrens2, function(k, v) {
					if (v < 0)
						return false;
					cdrows.push(v);
				})
			});
			gridMain.checkRows(cdrows, checked);
		}
		var parent = gridProvider.getParent(index);
		var mlevel = gridProvider.getValue(index,'menuLevelNo') - 0;
		var parents = [];
		var ptrows = [];
		if(parent != -1) {
			parents.push(parent);
			if(mlevel > 1) {
				for(var i=mlevel; i > 1; i--) {
					var parent = gridProvider.getParent(parent);
					parents.push(parent);
				}
			}
			$.each(parents, function(k, v) {
				if (v < 0) return false;
				if(!gridMain.isCheckedRow(v)) {
					ptrows.push(v);
				}
			});
			gridMain.checkRows(ptrows, checked);
		}
	}

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
				grid2.getDataProvider().clearRows();
				var param =  myForm.select(".searchBlock form").toJSON();
				grid1.loadData('lgcom','lgsysc/LGSYSC00090/retrieveRoleList', param );
				if(grid1.getDataProvider().getRowCount() > 0){
					var index = {itemIndex: 0};
					grid1.getGridBase().setCurrent(index);
				}
				break;

			case "save" :
				grid2.getGridBase().commit();
				grid2.getGridBase().expandAll();
				for(var i=0; i < grid2.getRowCount(); i++){
					if(grid2.getGridBase().isCheckedRow(grid2.getGridBase().getDataRow(i))){
						grid2.getDataProvider().setRowState(grid2.getGridBase().getDataRow(i), "created", false);
					} else {
						grid2.getDataProvider().setRowState(grid2.getGridBase().getDataRow(i), "none", false);
					}
				}
				grid2.getGridBase().collapseAll();
				if( grid2.getRowCount() == 0 ) {
					Message.alert('<lgcom:message code="note.nodata"/>');
					return;
				};
				Message.confirm( '<lgcom:message code="question.save"/>' , function() {
					grid2.useProgress(true);
					grid2.saveChanges('lgcom','lgsysc/LGSYSC00110/saveRoleMenuList', function(data) {
						Message.notify('<lgcom:message code="note.completed"/>');
						// 저장 완료후 목록 재조회
						myForm.select(".searchBlock button[data-action='search']").trigger('click');
					});
				});
				break;

			case "expand" :
				grid2.getGridBase().expandAll();
				break;

			case "collapse" :
				grid2.getGridBase().collapseAll();
				break;
		}
	});

	/*** 내부 함수  ***/
	//그리드 초기화
	function buildGrid(gridId) {
		var grid;
		switch(gridId) {
			case 'LGSYSC00110_grid1':
				grid = new RealGrid(myForm, gridId);
				grid.setPagingMode(true);
				//필드 설정
				grid.setFields([
					{ fieldName:'systemCode'     , dataType:'text'  },
					{ fieldName:'moduleCode'     , dataType:'text'  },
					{ fieldName:'roleCode'       , dataType:'text'  },
					{ fieldName:'roleName'       , dataType:'text'  }
				]);
				//마우스 오른쪽 클릭시 메뉴
				grid.setContextMenu();
				//컬럼 설정
				grid.setColumns([
					{
						name:'systemCode',
						fieldName:'systemCode',
						width:80,
						header: {text:'<lgcom:message code="System"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'moduleCode',
						fieldName:'moduleCode',
						width:80,
						header: {text:'<lgcom:message code="Module"/>'},
						styles: {textAlignment:'center'},
						editable: false
					},
					{
						name:'roleCode',
						fieldName:'roleCode',
						width:200,
						header: {text:'<lgcom:message code="RoleCode"/>'},
						editable: false
					},
					{
						name:'roleName',
						fieldName:'roleName',
						width:250,
						header: {text:'<lgcom:message code="RoleName"/>'},
						editable: false
					}
				]);
				grid.setOptions({
					grid: {
						softDeleting: true,
						deleteCreated: true,
						hideDeletedRows:false,
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
						}
					},
					dataProvider: {
						insertable: true,
						updatable: true,
						deletable: true,
						softDeleting: true,
						deleteCreated: true
					},
					display: { fitStyle: 'evenFill' }
				});
				break;
			case 'LGSYSC00110_grid2':
				grid = new RealGrid(myForm, gridId, 'treeview' );
				grid.setOptions({
					grid: {
						iconWidth: 0,
						softDeleting: true,
						deleteCreated: true,
						hideDeletedRows:true,
						indicator: {visible:false},
						panel: {visible:false},
						checkBar: {visible:true},
						stateBar: {visible:false},
						footer: {visible:false},
						edit: {
							insertable: true,
							appendable: true,
							updatable: true,
							deletable: true
						}
					},
					display: { fitStyle: 'none' }
				});
				//필드 설정
				grid.setFields([
					{ fieldName:'systemCode' , dataType:'text' },
					{ fieldName:'menuId'     , dataType:'text' },
					{ fieldName:'menuName'   , dataType:'text' },
					{ fieldName:'programName', dataType:'text' },
					{ fieldName:'menuLevelNo', dataType:'text' },
					{ fieldName:'sortOrderNo', dataType:'text' },
					{ fieldName:'highMenuId' , dataType:'text' },
					{ fieldName:'ynFlag'     , dataType:'text' },
					{ fieldName:'roleCode'   , dataType:'text' },
					{ fieldName:'fullMenuId' , dataType:'text' }
				]);
				//컬럼 설정
				grid.setColumns([
					{
						name:'menuName',
						fieldName:'menuName',
						width:300,
						type:'data',
						header: {text:'<lgcom:message code="MenuList"/>'},
						editable: false
					}
				]);
				break;
		}
		return grid;
	}
}

LGSYSC00110.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch(function(){
		var form = new LGSYSC00110();
		form.init();
	});
});

</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
	<div class="pageHeader">
	    <h2>Role Menu</h2>
	</div>

	<div class="searchBlock">

		<form class="form search-wrap">
		        <table class="table" >
		            <colgroup>
		                <col width="90">
		                <col width="90">
		                <col width="90">
		                <col width="90">
		                <col width="120">
		                <col width="180">
		                <col width="120">
		                <col width="250">
		            </colgroup>
		            <tbody>
		                <tr>
		                    <th><label class="required"><lgcom:message code="System" /></label></th>
		                    <td>
		                        <select class="form-control input-sm" name="systemCode"></select>
		                    </td>

		                    <th><label ><lgcom:message code="Module" /></label></th>
		                    <td>
		                        <select class="form-control input-sm" name="moduleCode"></select>
		                    </td>

		                    <th><label><lgcom:message code="RoleCode" /></label></th>
		                    <td><input type="text" class="form-control input-sm" name="roleCode"></td>

		                    <th><label><lgcom:message code="RoleName" /></label></th>
		                    <td><input type="text" class="form-control input-sm size_250" name="roleName"></td>
		                </tr>
		            </tbody>
		        </table>
		        <button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
		</form>
	</div>

	<div class="gridControls module-group text-right" >
		<div class="btn-toolbar">	
			<div class="btn-group">	
				<button class="btn btn-default btn-sm" type="button" role="button" data-action="expand"><lgcom:message code="AllExpand"/></button>
				<button class="btn btn-default btn-sm" type="button" role="button" data-action="collapse"><lgcom:message code="AllCollapse"/></button>
			</div>
			<div class="btn-group">
		        <button class="btn btn-gray btn-sm" type="submit" data-action="save" ><lgcom:message code="save"/></button>
		    </div>
		</div>        
    </div>

	<div class="gridContent grid-wrap" >
		<div id="LGSYSC00110_grid1" class="grid"></div>
	</div>
	<div class="treeContent grid-wrap" >
		<div id="LGSYSC00110_grid2" class="grid"></div>
	</div>
	</section>
</div>
</body>
</html>
