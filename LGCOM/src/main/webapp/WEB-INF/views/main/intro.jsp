<%@ page language ="java"  pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
    파일명 : intro.jsp
    프로젝트명 : LGD WCFW 프로젝트

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : Intro 화면
    작성자 : WCFW
-------------------------------------------------------------%>
<style>
._upper {
    border-right: 1px solid #D1D1D1;
    border-bottom: 2px solid #a0a0a0;
}

._downer {
}
._upper ._row1 {
    height : 299px;
}

._upper ._row2 {
    height : 175px;
}

._upper ._row3 {
    height : 310px;
    border-left: 1px solid #D1D1D1;
}

._upper .col-md-9  {
    border-right: 1px solid #D1D1D1;
}

._downer .col-md-9, ._downer  .col-md-3 {
    border-right: 1px solid #D1D1D1;
    border-bottom: 1px solid #D1D1D1;
}

._downer .col-md-6:first-child {
    height : 300px;
    border-right: 1px solid #D1D1D1;
}

._downer .col-md-12  {
    height : 150px;
}

._downer .col-md-12.first {
    height : 300px;
}
</style>


<script>
var IntroPage = function(){
	var favoriteList = new Map();
    buildChart("#introChart", "chart");
    
	this.refresh = function() {
		favoriteList.clear();

		//공지사항 게시판 조회 및 데이터 표출
		// LGCOM_FAQ : FAQ Board ID
		transaction( CONTEXT_PATH, "lgutlc/LGUTLC00040/retrieveIntroNoticeList", {systemCode : "LGCOM", bulletinBoardId : "LGCOM_NOTICE", targetRow : 1, rowSize : 7 }, function( data ) {
            var list = data["result"]["resultList"];
            var holder = $("._notice").empty();
            $(list).each( function( inx ){
                var item = $('<li class="_item" data-id="'+ this["bulletinBoardNo"]+'" ><span class="pull-left"><span class="text-pink">'+ this["noticeTypeName"] +' | <a href="#" class="boardTitle">'+ this["bulletinBoardTitle"]+'</a></span></span><span class="pull-right date">'+ this["wrieDate"]+'</span></li>');
                holder.append( item );
            });
		});

		transaction( CONTEXT_PATH, "lgutlc/LGUTLC00060/retrieveBoardList", {systemCode : "LGCOM", bulletinBoardId : "LGCOM_FAQ", targetRow : 1, rowSize : 7 }, function( data ) {
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
				var itemCount = Number( this["itemCount"] + "").toLocaleString("kr") ;
				$("#_" +this["itemType"].toLowerCase() ).text( itemCount );
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
	
	function buildChart(chart_id, subject ) {
        var category = [];
        var seriesData = [];

        transaction_sync(CONTEXT_PATH, "lgsysc/LGSYSC00210/retrieveChartWidgetNumbers", {}, function(data) {
            if(data.result.length > 0) {
                for( var i=0; i < data.result.length; i++ ) {
                    category.push(data.result[i].systemCode);
                    
                    for (var k in data.result[i]) {
                    	var key = k.capitalize();
                    	
                        if (k != "systemCode") {
                            if (i == 0) {
                                seriesData.push({name: key, data: [data.result[i][k]]});
                            } else {
                                for (var j = 0; j < seriesData.length; j++) {
                                    if (seriesData[j]["name"] == key) {
                                        seriesData[j]["data"].push(data.result[i][k]);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        });

        $(chart_id).highcharts({
            chart: {
                type: 'spline'
            },
            title : {
                text : '<div class="sub-header"></div>',
                useHTML: true,
                align : 'left',
                margin: 0,
                y: 10
            },
            exporting: {
                enabled: true
            },
            credits: {
                enabled: false
            },
            subtitle : {
                text : null
            },
            xAxis : {
                categories : category,
                tickmarkPlacement : 'on'
            },
            yAxis : {
                title : {
                    text : ''
                },
                labels: {
                    enabled: true
                },
                plotLines : [{
                    value : 0,
                    width : 1,
                    color : '#808080'
                }]
            },
            series : seriesData
        });
    }
	

	//Notice 의 항목을 클릭했을때 발생하는 이벤트
	$(document).on( "click.intro", "._intro ._notice .boardTitle", function( envent ){
		var item = $(event.target);

		if( !item.hasClass("_item") ) {
			item = item.closest("._item");
		}

		var urlAddr = "viewMode=detail&bulletinBoardId=LGCOM_NOTICE&fromSource=intro&bulletinBoardNo=" + item.data("id");
		//var menuItem = { menuId : "board", name : "Notice (" + item.data("id") + ")", systemCode : "LGCOM", programId : "LGUTILC00040", urlAddr : urlAddr };
		var menuItem = { menuId : "board", name : "Notice Detail", systemCode : "LGCOM", programId : "LGUTILC00040", urlAddr : urlAddr };

		LayoutManager.hideIntro( function(){
			LayoutManager.addTabByMenuItem(  uuid(),  menuItem );  //여기에  uuid() 를 주면, 탭을 계속 새로 생성해서 열게 된다.
		});

		event.preventDefault();
	});

	//FAQ 의 항목을 클릭했을때 발생하는 이벤트
	$(document).on( "click.intro", "._intro ._faq .boardTitle", function( envent ){
		var item = $(event.target);

		if( !item.hasClass("_item") ) {
			item = item.closest("._item");
		}

		var urlAddr = "viewMode=detail&bulletinBoardId=LGCOM_FAQ&fromSource=intro&bulletinBoardNo=" + item.data("id");
		//var menuItem = { menuId : "board", name : "FAQ (" + item.data("id") + ")", systemCode : "LGCOM", programId : "LGUTILC00060", urlAddr : urlAddr };
		var menuItem = { menuId : "board", name : "FAQ Detail", systemCode : "LGCOM", programId : "LGUTILC00060", urlAddr : urlAddr };

		LayoutManager.hideIntro( function(){
			LayoutManager.addTabByMenuItem( uuid(),  menuItem );  //여기에  uuid() 를 주면, 탭을 계속 새로 생성해서 열게 된다.
		});

		event.preventDefault();
	});

	// Notice, FAQ More 버튼 클릭
	$(document).on( "click.intro", "._intro ._downer span[data-action='bbs-more']", function(event) {
		var item = $(event.target);
		if( !item.hasClass("_more") ) {
			item = item.closest("._more");
		}

		// 게시판 유형을 얻는다.
		var board = $.trim(item.data('board'));

		var urlAddr = "viewMode=list";
		var menuName = "";
		var menuProgramId = "";
		if(board == 'notice') {
			urlAddr += "&bulletinBoardId=LGCOM_NOTICE";
			menuName = "Notice";
			menuProgramId = "LGUTILC00040";
		}
		else if(board == 'faq') {
			urlAddr += "&bulletinBoardId=LGCOM_FAQ";
			menuName = "FAQ";
			menuProgramId = "LGUTILC00060";
		}
		var menuItem = { menuId : "board", name : menuName, systemCode : "LGCOM", programId : menuProgramId, urlAddr : urlAddr };

		LayoutManager.hideIntro( function(){
			LayoutManager.addTabByMenuItem( uuid(),  menuItem );  //여기에  uuid() 를 주면, 탭을 계속 새로 생성해서 열게 된다.
		});

		event.preventDefault();
	});

	//Frequently used 항목을 클릭했을 때 발생하는 이벤트
	$(document).on( "click.intro", "._top10List a", function( envent ){
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
	
	//Contact Point 항목을 클릭했을 때 발생하는 이벤트
	$(document).on( "click.intro", ".contact", function( envent ){
		var item = $(event.target);

		var menuItem = { menuId : "M_LGUTLC_1172", name : "Contact Point", systemCode : "LGCOM", programId : "LGUTLC00407", urlAddr : "" };

		LayoutManager.hideIntro( function(){
			LayoutManager.addTabByMenuItem( uuid(),  menuItem );  //여기에  uuid() 를 주면, 탭을 계속 새로 생성해서 열게 된다.
		});
		
	});
}

</script>
	<div class="_intro">
         <div class="_wrap">
			<div class="container portal-container">
			    <div class="_upper">
						<div class="row">
						    <div class="col-md-9" style="padding:0px;">
								<div class="row _row1">
								    <div id="introChart" style="height: 300px; width:955px; margin: 0 auto;"></div>
								</div>

								<div class="row _row2">
								    <div class="col-md-4 _counterWidget _user">
						                <h2>User</h2>
						                <div id="_user" class="counter">0</div>
						                <div class="image"></div>
								    </div>
								    <div class="col-md-4 _counterWidget _role">
						                <h2>Role</h2>
						                <div id="_role" class="counter">0</div>
						                <div class="image"></div>
								    </div>
								    <div class="col-md-4 _counterWidget _program">
						                <h2>Program</h2>
						                <div id="_program" class="counter">0</div>
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
										<div class="module-group clearfix">
											<div class="pull-left">
												<h2>Notice</h2>
											</div>
											<div class="pull-right">
												<span data-action="bbs-more" data-board="notice" role="button" class="_more" style="margin-top:15px;display:inline-block;" title="More...">
													<i class="ico ico-shuttle-right-all"></i>
												</span>
											</div>
										</div>
										<ul class="list-group list-notice _notice"></ul>
								    </div>
								    <div class="col-md-6">
										<div class="module-group clearfix">
											<div class="pull-left">
												<h2>FAQ</h2>
											</div>
											<div class="pull-right">
												<span data-action="bbs-more" data-board="faq" role="button" class="_more" style="margin-top:15px;display:inline-block;" title="More...">
													<i class="ico ico-shuttle-right-all"></i>
												</span>
											</div>
										</div>
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
											<i class='fa fa-user' ></i> Contact Point
										</div>


									</div>
								</div>
						    </div>
						</div>
				</div>
		    </div>
		</div>

	</div>