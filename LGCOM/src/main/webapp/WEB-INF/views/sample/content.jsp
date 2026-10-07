<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%---------------------------------------------------------
    파일명 : content.jsp
    프로젝트명 : LGD WCFW

    Copyright(c) 2017 LG CNS,  All rights reserved.

    설 명 : Content Sample
    작성자 : wcfw
-------------------------------------------------------------%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>


<style>
    
</style>
<body>

		<!-- main content -->
				<div class="main">
					<!-- Nav tabs -->
					<!-- mdi 있는 경우 -->
					<div class="mdi_tabs clearfix">
						<ul class="nav nav-tabs pull-left" role="tablist">
							<li role="presentation" class="active"><a href="#" aria-controls="" role="tab" data-toggle="tab">MenuID001 <span class="close">×</span></a></li>
							<li role="presentation"><a href="#" aria-controls="" role="tab" data-toggle="tab">MenuID002 <span class="close">×</span></a></li>
							<li role="presentation"><a href="#" aria-controls="" role="tab" data-toggle="tab">MenuID003 <span class="close">×</span></a></li>
						</ul>
						<div class="pull-right">
							<button type="button" id="partFoldingBtn" class="btn btn-default btn-sm" data-toggle="tooltip" data-placement="top" title="Detail Toggle" aria-label="Detail Toggle">
								<span class="glyphicon glyphicon-resize-vertical" aria-hidden="true"></span>
							</button>
							<button type="button" id="fullFoldingBtn" class="btn btn-default btn-sm" data-toggle="tooltip" data-placement="top" title="Full Toggle" aria-label="Full Toggle">
								<span class="glyphicon glyphicon-open" aria-hidden="true"></span>
							</button>
							<button type="button" class="btn btn-default btn-sm" data-toggle="tooltip" data-placement="top" title="Favorite" aria-label="Favorite">
								<span class="glyphicon glyphicon-star" aria-hidden="true"></span>
							</button>
							<button type="button" class="btn btn-default btn-sm" data-toggle="tooltip" data-placement="top" title="Help" aria-label="Favorite" aria-label="Help">
								<span class="glyphicon glyphicon-question-sign" aria-hidden="true"></span>
							</button>
						</div>
					</div>

					<!-- mdi 없는 경우 -->
					<!-- <div class="page-header clearfix">
						<h2 class="pull-left">Title</h2>
						<div class="pull-right">
							<button type="button" id="srchTogBtn" class="btn btn-default btn-sm" data-toggle="tooltip" data-placement="top" title="Detail Toggle" aria-label="Detail Toggle">
								<i class="fonti um-angle-double-up" ></i>
							</button>
							<button type="button" id="srchFuTogBtn" class="btn btn-default btn-sm" data-toggle="tooltip" data-placement="top" title="Full Toggle" aria-label="Full Toggle">
								<span class="glyphicon glyphicon-open" aria-hidden="true"></span>
							</button>
							<button type="button" class="btn btn-default btn-sm" data-toggle="tooltip" data-placement="top" title="Favorite" aria-label="Favorite">
								<span class="glyphicon glyphicon-star" aria-hidden="true"></span>
							</button>
							<button type="button" class="btn btn-default btn-sm" data-toggle="tooltip" data-placement="top" title="Help" aria-label="Favorite" aria-label="Help">
								<span class="glyphicon glyphicon-question-sign" aria-hidden="true"></span>
							</button>
						</div>
					</div> -->

					<form>
						<div class="table_search">
							<table class="table table_horizontal">
								<colgroup>
									<col width="100">
									<col width="200">
									<col width="100">
									<col width="200">
									<col width="100">
									<col width="280">
									<col width="*">
								</colgroup>
								<tbody>
									<tr>
										<th><label for="search_01"><i class="asterisk">*</i>업체유형</label></th>
										<td>
											<select class="form-control input-sm" id="search_01">
												<option value="">업체유형을 선택하세요</option>
												<option>1</option>
												<option>2</option>
												<option>3</option>
												<option>4</option>
												<option>5</option>
											</select>
										</td>
										<th><label for="search_02">거래유형</label></th>
										<td>
											<select class="form-control input-sm" id="search_02">
												<option value="">거래유형을 선택하세요</option>
												<option>1</option>
												<option>2</option>
												<option>3</option>
												<option>4</option>
												<option>5</option>
											</select>
										</td>
										<th><label for="search_03">등록기간</label></th>
										<td>
											<div class="form-inline"">
												<div class="form-group">
													<label class="sr-only" for="dateFrome">Start Date</label>
													<input type="text" class="form-control input-sm" id="dateFrome" placeholder="yyyy/mm/dd" style="width: 100px;">
												</div> ~
												<div class="form-group">
													<label class="sr-only" for="dateTo">End Date</label>
													<input type="text" class="form-control input-sm" id="dateTo" placeholder="yyyy/mm/dd" style="width: 100px;">
												</div>
												<button type="button" id="setDate" class="btn btn-default btn-sm" aria-label="calendar">
													<span class="glyphicon glyphicon-calendar" aria-hidden="true"></span>
												</button>
											</div>
										</td>
										<td></td>
									</tr>
									<tr>
										<th><label for="">업체상태</label></th>
										<td>
											<label class="checkbox-inline">
												<input type="checkbox" id="inlineCheckbox1" value="option1"> 1
											</label>
											<label class="checkbox-inline">
												<input type="checkbox" id="inlineCheckbox2" value="option2"> 2
											</label>
											<label class="checkbox-inline">
												<input type="checkbox" id="inlineCheckbox3" value="option3"> 3
											</label>
										</td>
										<th><label for="search_05">회사명</label></th>
										<td>
											<div class="input-group">
												<input type="text" class="form-control input-sm" id="search_05" placeholder="Search for...">
												<span class="input-group-btn">
													<button class="btn btn-default btn-sm" type="button">
														<span class="glyphicon glyphicon-search" aria-hidden="true"></span>
													</button>
												</span>
											</div><!-- /input-group -->
										</td>
										<th><label for="search_06">사업자번호</label></th>
										<td>
											<input type="text" class="form-control input-sm" id="search_06" placeholder="사업자번호를 입력해주세요.">
										</td>
										<td>
											<button class="btn btn-danger btn-sm" type="button">조회</button>
										</td>
									</tr>
								</tbody>
							</table>
							<div class="hidden_search" style="display: none;">
								<hr>
								<table class="table table_horizontal">
									<colgroup>
										<col width="100">
										<col width="200">
										<col width="100">
										<col width="200">
										<col width="100">
										<col width="280">
										<col width="*">
									</colgroup>
									<tbody>
										<tr>
											<th><label for="search_07"><i class="asterisk">*</i>업체코드</label></th>
											<td>
												<input type="text" class="form-control input-sm" id="search_07" placeholder="업체코드를 입력해주세요.">
											</td>
											<th><label for="search_08">부품번호</label></th>
											<td>
												<input type="text" class="form-control input-sm" id="search_08" placeholder="부품번호를 입력해주세요.">
											</td>
											<th><label for="search_09">주문번호</label></th>
											<td>
												<input type="text" class="form-control input-sm" id="search_09" placeholder="주문번호를 입력해주세요.">
											</td>
											<td></td>
										</tr>
									</tbody>
								</table>
							</div>
						</div>
					</form>

				<div class="sub_header clearfix">
					<h3 class="pull-left">Section title</h3>
					<div class="pull-right">
						<button class="btn btn-save btn-sm" type="button">저장</button>
						<button class="btn btn-cancel btn-sm" type="button">취소</button>
					</div>
				</div>

				<div class="clearfix module_group">
					<div class="pull-left form-inline">
						<div class="form-group">
							<label for="pageCount" class="sr-only">페이지 갯수</label>
							<select class="form-control input-sm" id="pageCount">
								<option>1</option>
								<option>2</option>
								<option>3</option>
								<option>4</option>
								<option>5</option>
							</select>
						</div>
						<div class="form-group">
							<label class="sr-only">페이징</label>
							<p class="form-control-static">건 / 페이지 (총 1,200건)</p>
						</div>
					</div>

					<!-- <div class="pull-right">
						<button class="btn btn-default btn-sm" type="submit"><span class="fa fa-plus"></span> 추가</button>
						<a class="btn btn-default btn-sm" href="#" role="button"><span class="fa fa-minus"></span> 삭제</a>
						<button class="btn btn-default btn-sm" type="submit"><span class="ico ico-excel"></span> 업로드</button>
						<a class="btn btn-default btn-sm" href="#" role="button"><span class="ico ico-excel"></span> 다운로드</a>
					</div> -->

					<!-- 버튼 그룹핑이 필요한 경우 -->
					<div class="btn-toolbar pull-right" role="toolbar" aria-label="">
						<div class="btn-group">
							<button class="btn btn-default btn-sm" type="submit"><span class="fa fa-plus"  aria-hidden="true"></span> 추가</button>
							<a class="btn btn-default btn-sm" href="#" role="button"><span class="fa fa-minus"  aria-hidden="true"></span> 삭제</a>
							<button class="btn btn-default btn-sm" type="submit"><span class="ico ico-excel"  aria-hidden="true"></span> 업로드</button>
							<a class="btn btn-default btn-sm" href="#" role="button"><span class="ico ico-excel"  aria-hidden="true"></span> 다운로드</a>
						</div>
						<div class="btn-group">
							<button class="btn btn-default btn-sm" type="submit"><span class="fa fa-plus" aria-hidden="true"></span> 추가</button>
							<a class="btn btn-default btn-sm" href="#" role="button"><span class="fa fa-minus" aria-hidden="true"></span> 삭제</a>
							<button class="btn btn-default btn-sm" type="submit"><span class="ico ico-excel" aria-hidden="true"></span> 업로드</button>
							<a class="btn btn-default btn-sm" href="#" role="button"><span class="ico ico-excel" aria-hidden="true"></span> 다운로드</a>
						</div>
					</div>
				</div>

				<div class="grid_wrap">
					<div class="table-responsive">
						<table class="table">
							<thead>
								<tr>
									<th>#</th>
									<th>Header</th>
									<th>Header</th>
									<th>Header</th>
									<th>Header</th>
								</tr>
							</thead>
							<tbody>
								<tr>
									<td>1,001</td>
									<td>Lorem</td>
									<td>ipsum</td>
									<td>dolor</td>
									<td>sit</td>
								</tr>
								<tr>
									<td>1,002</td>
									<td>amet</td>
									<td>consectetur</td>
									<td>adipiscing</td>
									<td>elit</td>
								</tr>
								<tr>
									<td>1,003</td>
									<td>Integer</td>
									<td>nec</td>
									<td>odio</td>
									<td>Praesent</td>
								</tr>
								<tr>
									<td>1,003</td>
									<td>libero</td>
									<td>Sed</td>
									<td>cursus</td>
									<td>ante</td>
								</tr>
								<tr>
									<td>1,004</td>
									<td>dapibus</td>
									<td>diam</td>
									<td>Sed</td>
									<td>nisi</td>
								</tr>
							</tbody>
						</table>
					</div>
				</div>

				<nav class="text-center">
					<ul class="pagination">
						<li>
							<a href="#" aria-label="Previous">
								<span aria-hidden="true">&laquo;</span>
							</a>
						</li>
						<li><a href="#">1</a></li>
						<li><a href="#">2</a></li>
						<li><a href="#">3</a></li>
						<li><a href="#">4</a></li>
						<li><a href="#">5</a></li>
						<li>
							<a href="#" aria-label="Next">
								<span aria-hidden="true">&raquo;</span>
							</a>
						</li>
					</ul>
				</nav>

			</div>
   
<script type="text/javascript">
$(document).ready( function(){
    test();  
});

</script>   
</body>
</html>