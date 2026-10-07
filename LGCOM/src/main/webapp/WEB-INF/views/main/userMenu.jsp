<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : userMenu.jsp
    프로젝트명 : LGD WCFW Project

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : 본 화면은 사용자별로 본인의 메뉴 트리를 작성하고 관리하기 위한 화면입니다.
    작성자 : wcfw
     -------------------------------------------------------------%>
<html lang="ko">
<head>
<title>My Menu</title>
<style type="text/css">
.jstree-disabled {
    background-color : #F5F5F5;
    opacity : 0.5;
}
.jstree-disabled:after {
    content : "(Added)"
}

.jstree-disabled .jstree-checkbox {
    display : none;
}

.shuttleButtons { 
    margin-top : 200px;
}
</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
var LGSYSC00220 = function() {
	$(document).data("USER_NEMU_UPDATED", "N");
	var myForm = this;
	
	/* 이 화면의 레이아웃을 아래와 같이 정리 한다. : 자동확장 및 Sizing 을 위해서 
	myForm.setManagedLayout({
		searchBlock : { left : 0 , top : 0 , right : 0 },
		menuTreeTool : { top : 40 , left : 0 ,  width : 310 },
		menuTree : { left : 0 , top : 70, width : 310, bottom : 0 },

		shuttleButtons : { top : 160, left : 320 , width : 60 },
		userMenuTreeToolMove : { top : 40, left : 390 , width : 50 },
		userMenuTreeToolMessage : { top : 43, left : 445 , right : 80 },
		userMenuTreeTool : { top : 40 , width : 80 , right : 0 },
		userMenuTree : { top : 70, left : 390 , right : 0, bottom : 0 },

		_information :  { left : 0 , bottom : 0, width : 600  }
	});
	*/
	
	myForm.setLayout( [ 
	           		{ name : "searchBlock", left : 0, right : 0, top : 0 },
	           		{ name : "menuTreeTool", left : 0, width: 250, top : "searchBlock" },
	           		{ name : "userMenuTreeTool", left : "menuTreeTool", right : 0, top : "searchBlock" },
	           		
	           		{ name : "menuTree", left : 0, width: 250, top : "menuTreeTool", bottom : 0 },
	           		{ name : "shuttleButtons",left : "menuTree", width: 70, top : "menuTreeTool",bottom : 0 },
	           		{ name : "userMenuTree", left : 353, right : 0 , top : "menuTreeTool", bottom : 0 }
	           	]);
	
	myForm.select(".userMenuTreeToolMove button").prop("disabled", true);

	var menuTree =  new JsTree( myForm, ".menuTree", { checkbox : "Y" } );
	var userMenuTree =  new JsTree( myForm, ".userMenuTree", { checkbox : "Y" } );
	menuTree.onOpenNode( function( e, data ){
		var menuId = data.node.id;
		menuData.get( menuId ).state = { "opened" : true };
	});

	menuTree.onCloseNode( function( e, data ){
		var menuId = data.node.id;
		menuData.get( menuId ).state = { "opened" : false };
	});

	userMenuTree.onOpenNode( function( e, data ){
		var menuId = data.node.id;
		userMenuData.get( menuId ).state = { "opened" : true };
	});

	userMenuTree.onCloseNode( function( e, data ){
		var menuId = data.node.id;
		userMenuData.get( menuId ).state = { "opened" : false };
	});

	userMenuTree.onMoveNode( function( e, data ) {
		var param = { created : [] };

		if(data.node.original.type == "root") {
			$( userMenuTree.getNode("#").children ).each( function(inx){
				param.created.push( { menuId : this, sortOrderNo : (inx + 1) } );
			});
		}
		else if(data.node.original.type == "child") {
			$( userMenuTree.getNode(data.node.original.parent).children ).each( function(inx){
				param.created.push( { menuId : this, sortOrderNo : (inx + 1) } );
			});
		}

		myForm.transaction( CONTEXT_PATH, "lgsysc/LGSYSC00220/updateUserTopMenuOrder", param, function() {
			$(document).data("USER_NEMU_UPDATED", "Y");
			Message.notify('<lgcom:message code="note.completed" />');
		});
	});

	userMenuTree.onSelectNode( function( e, data ){
		var node = userMenuTree.getSelectedTopLevelNode();
		myForm.select(".userMenuTreeToolMove button").prop("disabled", true);

		if( (data.node.original.type == "root" || data.node.original.type == "child") && node.length == 1 ) {
			myForm.select(".userMenuTreeToolMove button").removeAttr("disabled");
		}
	});

	userMenuTree.onDeselectNode( function( e, data ){
		var node = userMenuTree.getSelectedTopLevelNode();
		myForm.select(".userMenuTreeToolMove button").prop("disabled", true);

		if( (data.node.original.type == "root" || data.node.original.type == "child") && node.length == 1 ) {
			myForm.select(".userMenuTreeToolMove button").removeAttr("disabled");
		}
	});

	var menuData = new Map();
	var userMenuData = new Map();

	var code = new CommonCode(CONTEXT_PATH);
	code.add(  "LGCOM_SYSTEM_CODE" , { codeTypeCode : "LGCOM_SYSTEM_CODE" } );
	code.add(  "LGCOM_MODULE_CODE" , { codeTypeCode : "LGCOM_MODULE_CODE" } );
	code.execute();

	var searchForm = new FormUtil( myForm, ".searchBlock .form" );
	searchForm.initCombo( "systemCode", code.get("LGCOM_SYSTEM_CODE") , {selectAll : true } );
	searchForm.initCombo( "moduleCode", code.get("LGCOM_MODULE_CODE") , {selectAll : true, filter : "systemCode" } );

	getUserMenuData();

	function getMenuData() {
		myForm.transaction( "lgcom", "lgsysc/LGSYSC00220/retrieveMyMenuListByRole" , searchForm.getValue() , function(data){
			menuData.clear();
			var list = data["result"];

			$(list).each( function( inx ){
				var state = { opened : false, disabled : false, selected : false };
				this["state"] = state;

				menuData.put( this["menuId"], this );
			});

			refreshTree( menuTree, menuData , userMenuData );
			myForm.hideProgress();
		});
	}

	function getUserMenuData(){
		myForm.showProgress();
		myForm.transaction( "lgcom", "lgsysc/LGSYSC00220/retrieveMyMenuUserMenuList", { systemCode : searchForm.getValue("systemCode") } , function(data){
			userMenuData.clear();
			var list = data["result"];

			$(list).each( function( inx ){
				var state = { opened : false, disabled : false, selected : false };
				this["state"] = state;

				userMenuData.put( this["menuId"], this );
			});
			refreshTree( userMenuTree, userMenuData );
			myForm.hideProgress();
		});
	}

	function refreshTree( tree, mapData, compareMap ) {
		if( mapData.size() == 0 ) return;
		var treeData = [];

		$(mapData.keys()).each(function(){
			var menuItem = mapData.get( this );

			if( menuItem["highMenuId"] == undefined ) {
				menuItem["highMenuId"] = "#"; //jsTree 는 root메뉴의 parent 가 # 이어야 한다.
			} else {
				var parent = mapData.get( menuItem["highMenuId"] );
			}

			menuItem["status"] = "N";

			//각 레벨에 따라 type 을 지정한다.
			if( menuItem["menuLevelNo"] == "0" ) {
				menuItem["menuLevelType"] = "root";
			} else if( menuItem["menuLevelNo"] == "1" ) {
				menuItem["menuLevelType"] = "child";
			} else if( menuItem["menuLevelNo"] == "2" ) {
				menuItem["menuLevelType"] = "branch";
			} else if( menuItem["menuLevelNo"] == "3" ) {
				menuItem["menuLevelType"] = "leaf";
			}

			var state = menuItem.state;

			if( menuItem.state == undefined ) {
				state = { opened : false, disabled : false, selected : false };
			}

			if( compareMap != undefined ) {
				if( compareMap.containsKey( menuItem["menuId"] ) ) {
					state.disabled = true;
				} else {
					state.disabled = false;
				}
			}

			treeData.push({
				id : menuItem["menuId"],
				parent : menuItem["highMenuId"],
				text : menuItem["menuName"],
				type : menuItem["menuLevelType"],
				state : state
			});
		});

		tree.setData( treeData  );
		myForm.hideProgress();
	}

	function checkMenuItemAdded( menuData, userMenuData ) {
		$(menuData.keys()).each( function(){
			if( userMenuData.containsKey(this + "" ) ) {
				menuTree.disableNode( this );
			}
		});
	}

	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", ".searchBlock button[data-action]" , function(event){
		var action = $(event.target).data("action");

		switch( action ){
			case "search" :
				myForm.showProgress();
				getMenuData();
				break;
		}
		event.stopPropagation();
	});

	/* Event Handleler */
	this.addEvent( "click", ".menuTreeTool [data-action]", function( event ) {
		var item = event.target;

		if( !$(item).filter("[data-action]").exists() ) {
			item = $(item).parent();
		}

		var action = $(item).data("action");

		switch( action ){
			case "expandAll" :
				menuTree.expandAll();
				break;
			case "expandHalf" :
				menuTree.expandHalf();
				break;
			case "collapseAll" :
				menuTree.collapseAll();
				break;
		}
	});

	this.addEvent( "click", ".userMenuTreeTool [data-action], .userMenuTreeToolMove [data-action]", function( event ) {
		var item = event.target;

		if( !$(item).filter("[data-action]").exists() ) {
			item = $(item).parent();
		}

		var action = $(item).data("action");

		switch( action ){
			case "expandAll" :
				userMenuTree.expandAll();
				break;
			case "expandHalf" :
				userMenuTree.expandHalf();
				break;
			case "collapseAll" :
				userMenuTree.collapseAll();
				break;
			case "moveUp":
				var nodes = userMenuTree.getSelectedTopLevelNode().reverse();
				$( nodes ).each( function( inx ){
					var prev = userMenuTree.getPrevNode(this);
					if( prev == false ) {
						return false;
					}

					var selNode = userMenuTree.getNode(this);
					// 선택된 Node의 타입이 child 이면(Menu Level 1)
					if(selNode.type == 'child') {
						//현재 선택된 항목의 바로 앞선 항목을 찾아서 이의 systemCode 값을 얻는다.
						var prevSystem = userMenuData.get(  $(prev).attr("id") )["systemCode"];
						var currSystem = userMenuData.get(  this )["systemCode"];

						if( prevSystem != currSystem ) {
							myForm.select( ".userMenuTreeToolMessage").text("<lgcom:message code="note.userMenuMoveCancel" />");
							setTimeout( function(){ myForm.select( ".userMenuTreeToolMessage").text(""); }, 3000 );
							return false;
						} else {
							myForm.select( ".userMenuTreeToolMessage").text("");
						}
					}
					userMenuTree.moveNode( this, prev, "before" );
				});
				break;
			case "moveDown":
				var nodes = userMenuTree.getSelectedTopLevelNode().reverse();
				$( nodes ).each( function( inx ){
					var prev = userMenuTree.getNextNode(this);
					if( prev == false ) {
						return false;;
					}

					var selNode = userMenuTree.getNode(this);
					// 선택된 Node의 타입이 child 이면(Menu Level 1)
					if(selNode.type == 'child') {
						//현재 선택된 항목의 바로 앞선 항목을 찾아서 이의 systemCode 값을 얻는다.
						var prevSystem = userMenuData.get(  $(prev).attr("id") )["systemCode"];
						var currSystem = userMenuData.get(  this )["systemCode"];

						if( prevSystem != currSystem ) {
							myForm.select( ".userMenuTreeToolMessage").text("<lgcom:message code="note.userMenuMoveCancel" />");
							setTimeout( function(){ myForm.select( ".userMenuTreeToolMessage").text(""); }, 3000 );
							return false;
						} else {
							myForm.select( ".userMenuTreeToolMessage").text("");
						}
					}
					userMenuTree.moveNode( this, userMenuTree.getNextNode(this), "after" );
				});
				break;
		}
	});

	this.addEvent( "click", ".shuttleButtons [data-action]", function(){
		var item = event.target;

		if( !$(item).filter("[data-action]").exists() ) {
			item = $(item).parent();
		}

		var action = $(item).data("action");

		switch( action ){
			case "addToUserMenu" :
				addToUserMenu();
				break;
			case "removeFromUserMenu" :
				removeFromUserMenu();
				break;
		}
	});

	function addToUserMenu(){
		var topMenuCount = 0;
		$(userMenuData.keys()).each( function(){
			if( userMenuData.get(this)["menuLevelNo"] == 1 ) {
				topMenuCount++;
			}
		});

		var nodes = menuTree.getCheckedNodes();

		var data = { created : [] };

		$( nodes ).each( function(){
			var menuItem = JSON.parse( JSON.stringify( menuData.get( this["id"] ) ) );
			menuItem.state.opened = true;
			menuItem.state.disabled = false;

			if( userMenuData.containsKey( menuItem["menuId"] ) ) {
				return true;
			}
			// 선택된 노드의 high 메뉴를 체크하여, userMenu 에 없으면, 해당 내용을 data.created 에 추가한다.
			if( !userMenuData.containsKey( menuItem["highMenuId"] ) ) {
				if(  menuData.get( menuItem["highMenuId"] ) != undefined  ) {
					var highMenu = JSON.parse( JSON.stringify( menuData.get( menuItem["highMenuId"] ) ) );
					data.created.push( {menuId : highMenu["menuId"], sortOrderNo : highMenu["sortOrderNo"] } );
					userMenuData.put( highMenu["menuId"] , highMenu );
					if( highMenu["menuLevelNo"] == "3" ) {
						// 2 Level 항목을 찾아서 추가한다.
						if( !userMenuData.containsKey( highMenu["highMenuId"] ) ) {
							highMenu = JSON.parse( JSON.stringify( menuData.get( highMenu["highMenuId"] ) ) );
							data.created.push( {menuId : highMenu["menuId"], sortOrderNo : highMenu["sortOrderNo"] } );
							userMenuData.put( highMenu["menuId"] , highMenu );
						}						
						// 1 Level 항목을 찾아서 추가한다.
						if( !userMenuData.containsKey( highMenu["highMenuId"] ) ) {
							highMenu = JSON.parse( JSON.stringify( menuData.get( highMenu["highMenuId"] ) ) );
							data.created.push( {menuId : highMenu["menuId"], sortOrderNo : highMenu["sortOrderNo"] } );
							userMenuData.put( highMenu["menuId"] , highMenu );
						}
						// 0 Level 항목을 찾아서 추가한다.
						if( !userMenuData.containsKey( highMenu["highMenuId"] ) ) {
							highMenu = JSON.parse( JSON.stringify( menuData.get( highMenu["highMenuId"] ) ) );
							data.created.push( {menuId : highMenu["menuId"], sortOrderNo : highMenu["sortOrderNo"] } );
							userMenuData.put( highMenu["menuId"] , highMenu );
						}
					}					
					if( highMenu["menuLevelNo"] == "2" ) {
						// 1 Level 항목을 찾아서 추가한다.
						if( !userMenuData.containsKey( highMenu["highMenuId"] ) ) {
							highMenu = JSON.parse( JSON.stringify( menuData.get( highMenu["highMenuId"] ) ) );
							data.created.push( {menuId : highMenu["menuId"], sortOrderNo : highMenu["sortOrderNo"] } );
							userMenuData.put( highMenu["menuId"] , highMenu );
						}
						// 0 Level 항목을 찾아서 추가한다.
						if( !userMenuData.containsKey( highMenu["highMenuId"] ) ) {
							highMenu = JSON.parse( JSON.stringify( menuData.get( highMenu["highMenuId"] ) ) );
							data.created.push( {menuId : highMenu["menuId"], sortOrderNo : highMenu["sortOrderNo"] } );
							userMenuData.put( highMenu["menuId"] , highMenu );
						}
					}
					if( highMenu["menuLevelNo"] == "1" ) {
						// 0 Level 항목을 찾아서 추가한다.
						if( !userMenuData.containsKey( highMenu["highMenuId"] ) ) {
							highMenu = JSON.parse( JSON.stringify( menuData.get( highMenu["highMenuId"] ) ) );
							data.created.push( {menuId : highMenu["menuId"], sortOrderNo : highMenu["sortOrderNo"] } );
							userMenuData.put( highMenu["menuId"] , highMenu );
						}
					}
				}
			}
			data.created.push( {menuId : menuItem["menuId"], sortOrderNo : menuItem["sortOrderNo"] } );
			userMenuData.put( menuItem["menuId"] , menuItem );
		});

		myForm.showProgress();
		myForm.transaction( CONTEXT_PATH, "lgsysc/LGSYSC00220/insertUserMenuList", data, function(){
			myForm.hideProgress();
			$(document).data("USER_NEMU_UPDATED", "Y");
			getUserMenuData();
			Message.notify('<lgcom:message code="note.completed" />');
			refreshTree( menuTree, menuData , userMenuData );
		});
	}

	function removeFromUserMenu(){
		var nodes = userMenuTree.getCheckedNodes();
		var data = { created : [] };

		$( nodes ).each( function(){
			var menuItem = JSON.parse( JSON.stringify( userMenuData.get( this["id"] ) ) );
			userMenuData.remove( this["id"] ); //복제니까 지워도 된다.
			data.created.push( { menuId : menuItem["menuId"] } );
			userMenuTree.deleteNode( this );
		});

		myForm.showProgress();
		myForm.transaction( CONTEXT_PATH, "lgsysc/LGSYSC00220/deleteUserMenuList", data, function(){
			myForm.hideProgress();
			$(document).data("USER_NEMU_UPDATED", "Y");
			getUserMenuData();
			Message.notify('<lgcom:message code="note.completed" />');

			refreshTree( menuTree, menuData , userMenuData );
		});
	}
}

LGSYSC00220.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	launch( function(){
		var form = new LGSYSC00220();
		form.init();
	});
});
</script>
</head>

<body>
<div class="mdi-container">
  <section class="page-content">
    <div class="pageHeader">
        <h2>My Menu</h2>
    </div>

    <div class="searchBlock">
        <form class="form search-wrap">
	        <table class="table table-condensed" >
	            <colgroup>
	                <col width="90">
	                <col width="90">
	                <col width="90">
	                <col width="90">
	                <col width="120">
	                <col width="280">
	                <col width="*">
	            </colgroup>
	            <tbody>
	                <tr>
	                    <th><label ><lgcom:message code="System" /></label></th>
	                    <td>
	                        <select class="form-control input-sm" name="systemCode"></select>
	                    </td>
	
	                    <th><label ><lgcom:message code="Module" /></label></th>
	                    <td>
	                        <select class="form-control input-sm" name="moduleCode"></select>
	                    </td>
	
	                    <th><label><lgcom:message code="MenuName" /></label></th>
	                    <td><input type="text" class="form-control input-sm" name="menuName"></td>
	
	                </tr>
	            </tbody>
	        </table>
            <button class="btn btn-lgd btn-sm btn-search" type="button" data-action="search"><lgcom:message code="search" /></button>
        </form>
    </div>

    <div class="menuTreeTool module-group text-right">
        <div class="btn-group" role="group" aria-label="First group">
            <button type="button" class="btn btn-default btn-cube btn-sm ico-lgd" data-action ="expandAll" data-toggle="tooltip" data-placement="left" title="Expand All"><i class="fa fa-plus" aria-hidden="true"></i></button>
            <button type="button" class="btn btn-default btn-cube btn-sm ico-lgd" data-action ="expandHalf" data-toggle="tooltip" data-placement="top" title="Expand Half"><i class="fa fa-bars" aria-hidden="true"></i></button>
            <button type="button" class="btn btn-default btn-cube btn-sm ico-lgd" data-action ="collapseAll" data-toggle="tooltip" data-placement="right" title="Collapse All"><i class="fa fa-minus" aria-hidden="true"></i></button>
        </div>
    </div>

    <div class="menuTree panel panel-default" style="overflow-y : auto;"></div>

    <div class="shuttleButtons module-group shuttle text-center" >
        <div class="btn-shuttle">
            <button class="btn btn-ico" data-action="addToUserMenu" data-toggle="tooltip" data-placement="top" title="Add to User Menu">
                <span class="ico ico-shuttle-right" ></span>
            </button>
        </div>
        <div class="btn-shuttle">
            <button class="btn btn-ico" data-action="removeFromUserMenu" data-toggle="tooltip" data-placement="bottom" title="Remove from User Menu">
                <span class="ico ico-shuttle-left"></span>
            </button>
        </div>
    </div>
    

    <div class="userMenuTreeToolMessage"></div>

    <div class="userMenuTreeTool module-group text-right"  >
        <div class="btn-toolbar">
        	<div class="btn-group" >
	            <button type="button" class="btn btn-default btn-sm btn-cube ico-lgd" data-action ="moveUp" data-toggle="tooltip" data-placement="top" title="Move Up"><i class="fa fa-arrow-up" aria-hidden="true" ></i></button>
	            <button type="button" class="btn btn-default btn-sm btn-cube ico-lgd" data-action ="moveDown" data-toggle="tooltip" data-placement="top" title="Move Down" ><i class="fa fa-arrow-down" aria-hidden="true" ></i></button>
            </div>        
        	<div class="btn-group" >
	            <button type="button" class="btn btn-default btn-sm btn-cube ico-lgd" data-action ="expandAll" data-toggle="tooltip" data-placement="left" title="Expand All"><i class="fa fa-plus" aria-hidden="true"></i></button>
	            <button type="button" class="btn btn-default btn-sm btn-cube ico-lgd" data-action ="expandHalf" data-toggle="tooltip" data-placement="top" title="Expand Half"><i class="fa fa-bars" aria-hidden="true"></i></button>
	            <button type="button" class="btn btn-default btn-sm btn-cube ico-lgd" data-action ="collapseAll" data-toggle="tooltip" data-placement="right" title="Collapse All"><i class="fa fa-minus" aria-hidden="true"></i></button>
            </div>
        </div> 
   </div>

    <div class="userMenuTree panel panel-default" style="overflow-y : auto;" ></div>
    </section>
</div>
</body>
</html>
