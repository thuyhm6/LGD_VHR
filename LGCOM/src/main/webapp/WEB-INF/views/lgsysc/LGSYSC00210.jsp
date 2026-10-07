<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%---------------------------------------------------------
    파일명 : LGSYSC00210.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : Short Cut Menu
    작성자 : wcfw
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title>Short Cut Menu</title>
<style type="text/css">

</style>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>
<script type="text/javascript">
MenuTree = function( myForm, selector, menuForm , searchForm ){
    var menuTree = myForm.select(selector);
    var selected;
    var treeTools = myForm.select(".treeTools");
    var menuInfoMap = new Map();
    var deletedMenuInfo = new Array();
    
    this.getMenuInfo = function( menuId ){
    	return menuInfoMap.get( menuId );
    }
    
    this.setMenuInfo = function( menuInfo ){
    	menuInfoMap.put( menuInfo["menuId"], menuInfo );
    	selected.find("._name").text( menuInfo["menuName"] );
    }    
 
	function select( item ) {
		//해당 아이템을 선택한것으로 표시한다. 
		menuTree.find(".selected").removeClass("selected");
		item.children("._name").addClass("selected");

		var menuInfo = menuInfoMap.get( $(item).data("id") );

		if( menuForm != null) {
			menuForm.setValue( menuInfo );
			
			if( menuInfo["menuLevelNo"] != "3" ) {
				menuForm.disable("programName");
				menuForm.disable("urlAddr");
				myForm.select(".treeTools button[data-action='addChild']").prop( "disabled", false );
			} else {
				menuForm.enable("programName");
				menuForm.enable("urlAddr");
				myForm.select(".treeTools button[data-action='addChild']").prop( "disabled", true );
			}
			
			if( menuInfo["menuLevelNo"] == "1" ) {
				menuForm.enable("moduleCode");
			} else {
				menuForm.disable("moduleCode");
			}		
			
		}
		
        selected = item;
	}
	
	function _node( item ) {
		var node = $('<li class="_item" data-level="'+item["menuLevelNo"]+'" data-id="'+item["menuId"]+'"><i class="_folder glyphicon glyphicon-triangle-bottom"></i><div class="_name">'+ item["menuName"] +'</div><span class="_exisingLabel label label-lgd">Added</span><ul class="_itemList" data-level="'+item["menuLevelNo"]+'" data-id="'+item["menuId"]+'"></ul></li>');

		if( item["userMenuYn"] == "Y" ) {
			node.find("._exisingLabel").fadeIn(200);
		}
		
		if( item["menuLevelNo"] == "3" ) {
			node.find("._folder").remove();   
		}
		
		return node;
	}
	
	this.loadData = function( quite ){
		loadMenuTree( quite );
	}
    
    function loadMenuTree( quite ) {
    	if( quite != true ) {
    	    myForm.showProgress(".tree");
    	}
    	
    	transaction( "lgsysc/LGSYSC00220/retrieveMenuListByRole", { systemCode : searchForm.getValue("systemCode") } , function(data){
    		if( quite != true ) {
    		    myForm.hideProgress();
    		}
    		
    		//삭제 대상 목록을 모두 비운다. 
    		deletedMenuInfo.length = 0;
    		menuInfoMap.clear();
    		
    		var root  = $('<div class="_tree" ><ul class="_itemList" data-level="root"></ul></div>');
    		myForm.select(".tree").empty().append( root );
    		
			$(data["result"]).each( function(inx){
    			var item = this;
    			//이 모든 항목은 이미 DB에서 온 것이기 때문에, status 를  N ( normal ) 로 지정해준다. 
    			item["status"] = "N";
    			
        		//이 메뉴의 부모 메뉴를 불러서, 그 정보를 일부 사용한다. 
        		var parentMenuInfo = menuInfoMap.get( item["highMenuId"] );
        		if( parentMenuInfo != undefined && parentMenuInfo["menuName"] != undefined ) {
        			item["parentMenuName"] = parentMenuInfo["menuName"];	
        		} else {
        			item["parentMenuName"] = "";        		
        		}
        		//menuInfo 에  menuId 별로 적재한다. 
        		menuInfoMap.put( item["menuId"], item );        		
        		
    			if( item["menuLevelNo"] == "1" ) {
    				var node = _node(item);
    				menuTree.find("._itemList[data-level='root']").append( node );
    			} else  if( item["menuLevelNo"] == "2" ||  item["menuLevelNo"] == "3" ) {
    				var node = _node(item);
    				menuTree.find("._itemList[data-id='"+item["highMenuId"]+"']").append( node );
    			}   
    		}); 

    	    myForm.select(".tree ._item[data-level='3']").draggable({
    	    	scroll: false,
    	    	helper: function(){
    	    		$copy = $(this).clone();
    	    		$copy.find("._exisingLabel").remove(); 
    	    		
    	    		$copy.css({"list-style":"none", "width":$(this).outerWidth() + "px", "z-index" : "99999" }); 
    	    		$( $copy ).addClass("_dragging_");
    	    		return $copy; 
    	    	},
                appendTo: "div#" + BizForm.getFormId()
    	    });
    	    
    	    
    	    
    	    select( $(root).find("._item").first() );
    	});
    }
    
    this.reorderMenuItems = function() {
    	_reorderMenuItems();
    }
    
    function _reorderMenuItems( root , highMenuId ) {
    	if( root == undefined ) {
    		root = myForm.select("[data-level='root']._itemList");
    	}
    	
    	if( highMenuId == undefined ) {
    		highMenuId = "";
    	}
    	
    	var children = $(root).children("._item ");
    	
    	var sortOrderNo = 0;
    	$(children).each( function(){
    		var menuInfo = menuInfoMap.get( $(this).data("id") );

    		if( menuInfo != undefined && menuInfo.status != "D" ) {
        		sortOrderNo++;
        		menuInfo.sortOrderNo = sortOrderNo;
        		menuInfo.highMenuId = highMenuId; // 위에서 들어온 상위 메뉴 아이디는 자기에게 담고
        		
        		if( $(this).children("._itemList ").exists() ) {
        			_reorderMenuItems( $(this).children("._itemList "), menuInfo.menuId  ); //자기의 메뉴아이디를 하위로 내려보낸다
        		}
    		}
    	});
    	
    }
    
   	// 이 함수는 메뉴 아이템( item ) 가 드롭될 때, 드롭되는 곳 ( holder )과의 상호 비교를 통하여, 유효한 장소인지 확인을 하기 위한 함수이다. 
   	function isValidDrop( sorceList, targetList ) {
   	    var valid = true;
   	    var sorceListLevel   = $(sorceList).data("level");
   	    var targetListLevel = $(targetList).data("level");
   	    if( sorceListLevel != targetListLevel ) {
   	    	valid = false;
   	    }
   	    return valid;
   	}    
   	
   	
   	this.getChangedList = function() {
   		var result = { updated : [], created :[] , deleted : deletedMenuInfo };

   		$( menuInfoMap.values() ).each( function(){
   			var menuInfo = this;
   			
			if( menuInfo.status == "C" ) {
				result.created.push( menuInfo );	
			} else if( menuInfo.status == "U" ) {
				result.updated.push( menuInfo );	
			} 
   		});
   		return result;
   	}
    
    myForm.addEvent( "click", ".tree li ._folder", function( event ){
    	var item = $(event.target);

    	//바로 하위항목이 없을때는, 이 버튼이 동작할 필요가 없다.
    	if( $(item).parent().children("._itemList").children("._item").length == 0 ) {
    		retrn;
    	}
    	
    	if( $(item).data("closed") == undefined || $(item).data("closed") == "N" ) {
    		$(item).parent().children("._itemList").slideUp( 500 , function(){
    			$(item).data("closed","Y");
    		});
    		$(item).stop().velocity({"rotateZ": "-=90"}, {duration: 500});
    	} else {
    		$(item).parent().children("._itemList").slideDown( 500 , function(){
    			$(item).data("closed","N");
    		});
    		$(item).stop().velocity({"rotateZ": "+=90"}, {duration: 500});
    	}
		
		event.stopPropagation();
	});	
    
	myForm.addEvent( "click", ".tree li ._name", function( event ){
		var item = $(event.target);
		select( item.parent() );

		event.stopPropagation();
	});	
	
	
	myForm.addEvent( "click", ".treeTools .btn, .treeTools .btn i", function( event ){
		var item = $(event.target);
		
		if( !item.hasClass("btn") ) {
			item = $(item).parent();
		}
		
		var action = $(item).data("action");
		
		if ( action == "expandAll" ) {
			menuTree.find("._folder").data("closed","N").stop().velocity({"rotateZ": "0"}, {duration: 500 });
			menuTree.find("._itemList").slideDown( 500 );
			
		} else if ( action == "collapseAll" ) {
			
			menuTree.find("._folder").data("closed","Y").stop().velocity({"rotateZ": "0"}, {duration: 0}).velocity({"rotateZ": "-=90"}, {duration: 500});
			menuTree.find("._itemList:not([data-level='root'])").slideUp( 500 );
			
		} 
		  
		event.stopPropagation();
	});   
	
	function findNearest( target, selector ) {  
		if( target.next(selector).exists() ) {
			return target.next(selector);	
		}
		
		if( target.prev(selector).exists() ) {
			return target.prev(selector);
		}
		
	    return target.parent().parent();
	}
}


var LGSYSC00210 = function(){
    var myForm = this;
    
    /* 이 화면의 레이아웃을 아래와 같이 정리 한다. : 자동확장 및 Sizing 을 위해서 */
    myForm.setManagedLayout({
   	 searchBlock : { left : 0 , top : 0 , right : 0 }, 
   	 treeTools : { left : 0 , top : 65, width : 350  },
   	 tree : { left : 0 , top : 100, width : 400, bottom : 0 },
   	 controlGroup1 : { top : 65 , left : 0 ,  width : 400 },
   	 controlGroup2 : { top : 65 , left : 410 , right : 0 },
     tree2 : { top : 100, left : 410 , right : 0, bottom : 0 }
    });     
        
    myForm.searchConditionControl( true );
    
    var code = new CommonCode();
    code.add(  "LGCOM_SYSTEM_CODE" , { codeTypeCode : "LGCOM_SYSTEM_CODE" } );
    code.add(  "LGCOM_MODULE_CODE" , { codeTypeCode : "LGCOM_MODULE_CODE" } );
    code.execute();
    
    var searchForm = new FormUtil( myForm, ".searchBlock .form" );
    searchForm.initCombo( "systemCode", code.get("LGCOM_SYSTEM_CODE")  );
    searchForm.initCombo( "moduleCode", code.get("LGCOM_MODULE_CODE") , {selectAll : true, filter : "systemCode" } );     
    
    var menuTree = new MenuTree( myForm, ".tree", null, searchForm ); //myForm.select(".tree");
    
	/*** 이벤트 핸들러  ***/
	myForm.addEvent( "click", "button[data-action]" , function(event){
		var item = $(event.target);
		if(!$(item).filter('[data-action]').exists()) {
			item = $(item).closest('[data-action]');
		}
		var action = $.trim(item.data('action'));
		switch( action ){
		    case "search" :
		    	menuTree.loadData();
		    	userMmenuTree.loadData();
				break;
		    case "save" :
         		saveTreeData();	
		    	break;		    	
		} 
		
		event.stopPropagation();
	});   
	
}


LGSYSC00210.prototype = new BizForm("${param.bizFormId}");

$(document).ready( function() {
	var form = new LGSYSC00210();
	form.init();
});

</script>
<style>


._tree ul {
    padding-left : 30px;
}

._tree li {
    list-style-type: none;
}

._tree .selected {
    background-color : #E3E4E5 !important;
    font-weight : bold;
}

._tree ._item   {
    position: relative;
    margin: 2px 0px;
}

._tree ._item ._folder  {
    position : absolute;
    left : -20px;
    top: 5px;
    font-size : 12px;
    cursor : pointer;
}

._tree ul[data-level='root'] ._name  {
    border-left : 10px solid #8F9DA6;
}

._tree ul[data-level='1']  ._name  {
    border-left : 10px solid  #BFADA8;
}

._tree ul[data-level='2'] ._name  {
    border-left : 10px solid  #FFE2DA;
}

._tree ._treeItemPlaceHolder {
    height : 20px;
    border : 1px dashed #c0c0c0;
    background-color : #ffffe8;  	
}

._tree ._item ._name   {
    padding : 2px 15px;
    height : 20px;
    font-size : 12px;
    cursor : pointer;
    background-color : #FAFAFA;    
}

._tree ._item ._exisingLabel {
    position : absolute;
    right : 10px;
    top : 3px;
    height : 15px;
    font-size: 10px;
    display : none;
    background-color : #D55D5A;
}

.tree { 
    overflow-y : auto;     
    overflow-x : hidden;  
}

</style>
</head>   

<body>
<div class="container">
    
	<div class="tree noselect box"></div>
	      
</div>	
</body>
</html>
