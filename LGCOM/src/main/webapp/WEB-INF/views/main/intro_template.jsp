<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : intro_template.jsp
    프로젝트명 : LGD WCFW 프로젝트

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 :Intro 화면 Template
    작성자 : WCFW
-------------------------------------------------------------%>
<!-- Style 정의 부  
  intro 화면에서만 사용할 css 를 정의하는 부분 입니다. 
  모든 class 정의는 ._intro 로 시작하여, intro 화면 요소를 담고있는 블럭 안에서만 유효해야 합니다.
-->
<style>
._intro ._upper {
    border-right: 1px solid #D1D1D1;
    border-bottom: 2px solid #a0a0a0;
}

._intro ._downer {
}

._intro ._upper ._row1 {
    height : 299px;
}

._intro ._upper ._row2 {
    height : 175px;
}

._intro ._upper ._row3 {
    height : 310px;
    border-left: 1px solid #D1D1D1;    
}

._intro ._upper .col-md-9  {
    border-right: 1px solid #D1D1D1;
}

._intro ._downer .col-md-9,
._intro ._downer  .col-md-3 {
    border-right: 1px solid #D1D1D1;
    border-bottom: 1px solid #D1D1D1;    
}

._intro ._downer .col-md-6:first-child {
    height : 300px;
    border-right: 1px solid #D1D1D1;
}

._intro ._downer .col-md-12  {
    height : 150px;
}

._intro ._downer .col-md-12.first {
    height : 150px;
    border-bottom: 1px solid #D1D1D1;    
}
</style>


<script>
/* [주의!] 이 클래스의 이름은 바꾸면 안됩니다. */
IntroPage = function(){
	
	/* 클래스 내부 변수 */
	var favoriteList = new Map();
	
	/* 멤버 메소드 선언 */
	
	/* 
	   refresh 메소드는 intro 화면이 처음 노출 될 때 한번 호출 되며, 
	   main 화면의 시스템 로고를 클릭해서, intro 화면이 다시 노출 될 때 마다 한번씩 호출 됩니다.
	   
	   데이터의 표출과 갱신을 위해 사용되는 코드가 들어가는 부분입니다.
	   이 메소드의 내부가 비워져 있으면, intro 는 스스로 데이터 갱신을 하지 못합니다. 
	 */
	this.refresh = function() {
		favoriteList.clear();
		
		//공지사항 게시판 조회 및 데이터 표출
		// LGCOM_FAQ : FAQ Board ID
		transaction( CONTEXT_PATH, "lgutlc/LGUTLC00040/retrieveBoardList", {systemCode : "LGCOM", bulletinBoardId : "LGCOM_NOTICE", targetRow : 1, rowSize : 7 }, function( data ) {
            var list = data["result"]["resultList"];
            var holder = $("._notice").empty();
            $(list).each( function( inx ){
                var item = $('<li class="_item" data-id="'+ this["bulletinBoardNo"]+'" ><span class="pull-left"><span class="text-pink">'+ this["noticeTypeName"] +' | <a href="#" class="boardTitle">'+ this["bulletinBoardTitle"]+'</a></span></span><span class="pull-right date">'+ this["wrieDate"]+'</span></li>');
                holder.append( item );
            });
		});		
		
		transaction( CONTEXT_PATH, "lgutlc/LGUTLC00040/retrieveBoardList", {systemCode : "LGCOM", bulletinBoardId : "LGCOM_FAQ", targetRow : 1, rowSize : 7 }, function( data ) {
            var list = data["result"]["resultList"];
            var holder = $("._faq").empty();
            $(list).each( function( inx ){
                var item = $('<li class="_item" data-id="'+ this["bulletinBoardNo"]+'"  ><a href="#" class="boardTitle">'+ this["bulletinBoardTitle"]+'</a></span></span><span class="pull-right date">'+ this["wrieDate"]+'</span></li>');
                holder.append( item );
            });
		});		
		
		transaction( CONTEXT_PATH, "lgsysc/LGSYSC00070/retrieveTop10ListForMain", { targetRow : 1, rowSize : 10 }, function( data ) {
			//top10List  counterWidgetList
            var list = data["result"]["resultList"];
			
            var holder = $("._top10List").empty();
			$(list).each( function(inx){
				var type = "lgd";
				var id = uuid();
				holder.append( '<li data-id="'+ id +'" class="_item"><span class="label label-'+type+'">'+ ( inx+ 1 )+'</span> <a href="#">'+ this["menuName"]+'</a></li>'); 
				favoriteList.put( id, { systemCode : this["systemCode"], name : this["menuName"],  programId : this["programId"], menuId : this["menuId"] , urlAddr : nvl( this["urlAddr"] ), menuAuthoFlag : this["menuAuthoFlag"] }  );
			});
		});			
		
		
		transaction( CONTEXT_PATH, "lgsysc/LGSYSC00210/retrieveWidgetNumbers", { }, function( data ) {
			var list = data["result"];
			$(list).each( function(inx){
				autoIncrementVal( $("._counterWidget._"+ this["itemType"].toLowerCase() +" .counter"),  this["itemCount"], 1000 );
			});
		});		
		
		transaction( CONTEXT_PATH, "lgsysc/LGSYSC00210/retrieveWidgetSystemList", { }, function( data ) {
			var list = data["result"];
			var select = $(".systemChanger select[name='systemCode']");
			$(list).each( function(){
				select.append("<option value='" + this["code"]+"'>"+ this["name"] +"</option>");
			});
			
			select.find("option").first().prop("selected", true );
		});			
		
	}
	
	/* 내부 함수 선언부 : 이 클래스 내부에서만 사용하는 함수를 정의하는 부분입니다. */
	function autoIncrementVal(obj, val, durationVal) {
        $({someValue: 0}).animate({someValue: val}, {
		    duration: durationVal,
		    easing:'swing', // can be anything
		    step: function() { // called on every step
		    	var val = Math.ceil(this.someValue);
		    	val = Number( val + "" ).toLocaleString("kr");
		        $(obj).text( val );
		    }         
		});
	}
	
	
	/* 이벤트 핸들러 정의 부 : 하단의 화면 오브젝트에서 발생하는 이벤트의 핸들러를 정의하는 부분입니다 
	   이 화면은 main 이 로딩될 때 단 한번만 호출되어 전역으로 사용되기 때문에, 
	   BizForm.addEvent 를 사용하지 않고, jquery 의 이벤트 핸들러를 직접 호출하여 코드 합니다.	*/
	   
	//Notice 의 항목을 클릭했을때 발생하는 이벤트 
	$(document).on( "click", "._intro ._notice .boardTitle", function( envent ){
		var item = $(event.target);
		
		if( !item.hasClass("_item") ) {
			item = item.closest("._item");
		}
		
		var urlAddr = "viewMode=detail&bulletinBoardId=LGCOM_NOTICE&bulletinBoardNo=" + item.data("id");
		var menuItem = { menuId : "board", name : "Notice (" + item.data("id") + ")", systemCode : "LGCOM", programId : "LGUTILC00040", urlAddr : urlAddr };
		
		LayoutManager.hideIntro( function(){
			LayoutManager.addTabByMenuItem(  uuid(),  menuItem );  //여기에  uuid() 를 주면, 탭을 계속 새로 생성해서 열게 된다.
		});
		
		event.preventDefault();
	});	
	
	//FAQ 의 항목을 클릭했을때 발생하는 이벤트 
	$(document).on( "click", "._intro ._faq .boardTitle", function( envent ){
		var item = $(event.target);
		
		if( !item.hasClass("_item") ) {
			item = item.closest("._item");
		}
		
		var urlAddr = "viewMode=detail&bulletinBoardId=LGCOM_FAQ&bulletinBoardNo=" + item.data("id");
		var menuItem = { menuId : "board", name : "FAQ (" + item.data("id") + ")", systemCode : "LGCOM", programId : "LGUTILC00060", urlAddr : urlAddr };
		
		LayoutManager.hideIntro( function(){
			LayoutManager.addTabByMenuItem( uuid(),  menuItem );  //여기에  uuid() 를 주면, 탭을 계속 새로 생성해서 열게 된다.
		});
		
		event.preventDefault();
	});	
	
	//Frequently used 항목을 클릭했을 때 발생하는 이벤트
	$(document).on( "click", "._top10List a", function( envent ){
		var item = $(event.target);
		
		if( !item.hasClass("_item") ) {
			item = item.closest("._item");
		}
		
		var menuItem = favoriteList.get( item.data("id") );
        
		if( menuItem["menuAuthoFlag"] == "N" ) {
            Message.alert("<lgcom:message code="note.notAssignedMenu"/>");
		} else {
			LayoutManager.hideIntro( function(){
				LayoutManager.addTabByMenuItem( item.data("id"),  menuItem );
			});
		}
		
		event.preventDefault();
	});
}
</script>


<!-- 화면 오브젝트 선언부 
    1. div class _intro 로 감싸져 있어야 합니다. 
    2. 이후 내부는 시스템 특성에 맞게 작성하면 됩니다. 
    3. 각 오브젝트를 지목할 때는, id를 사용하지 말고, class 의 이름을 부여하는 방식으로 코드해 주십시오
    4. 이미지 static 요소를 지목하는 경우에는 미리 지정된 폴더에 배치합니다.  
       ex) LGBPC 프로젝트의 경우
         이미지 저장소 :  /LGBPC/src/main/webapp/static/lgbpc/img  
       그리고 다음과 같이 태깅 합니다.  ( 주소에 프로젝트 이름의 소문자 형식으로 context 를 붙여야 합니다.
       <img src="/lgbpc/static/lgbpc/img" >
 -->
	<div class="_intro">
         <div class="_wrap">
			<div class="container portal-container">
			    <div class="_upper">
						<div class="row">  
						    <div class="col-md-9" style="padding:0px;">  
								<div class="row _row1">  
								    <div class="col-md-12 _image">
							       	       
								    </div>
								</div>
						
								<div class="row _row2">  
								    <div class="col-md-4 _counterWidget _user">
						                <h2>User</h2>
						                <div class="counter">0</div>
						                <div class="image"></div>
								    </div>
								    <div class="col-md-4 _counterWidget _role">
						                <h2>Role</h2>
						                <div class="counter">0</div>
						                <div class="image"></div>
								    </div>
								    <div class="col-md-4 _counterWidget _program">
						                <h2>Program</h2>
						                <div class="counter">0</div>
						                <div class="image"></div>
								    </div>
								</div>					
						
						    </div>
						    <div class="col-md-3">
						        <h2>Frequently Used</h2>
								<ul class="list-group list-todo _top10List"></ul>
						    </div>
						</div>
			    </div>
			    <div class="_downer" >
						<div class="row _row3">  
						    <div class="col-md-9" >
								<div class="row">  
								    <div class="col-md-6">
										<h2>Notice</h2>
										<ul class="list-group list-notice _notice"></ul>
								    </div>
								    <div class="col-md-6">
										<h2>FAQ</h2>
										<ul class="list-group list-notice _faq"></ul>
								    </div>							    
								</div>
						    </div>
						    <div class="col-md-3" style="padding:0px;">
								
	                            <div class="row">
	                                <div class="col-md-12 first _contactPointWidget">
										<h2>Contact Point</h2>
										<div class="image"></div>
										<div class="content-box help-desk">
											<p>IT Service Help Desk : 1544-3999
										</div>

										<div class="content-box contact">
											<i class='fa fa-user' ></i> 업무별 담당자 연락처
										</div>

										
									</div>
								</div>
								<div class="row">
								    <div class="col-md-12 _systemLinkWidget" >
								        <h2>My System Link</h2>
										
										<form class="systemChanger">
										    <select class="_systemCode" name="systemCode"></select>
										</form>
										
									</div>
								</div>							
								
						    </div>
						</div>
				</div>
		    </div>	
		</div>
	
	</div>