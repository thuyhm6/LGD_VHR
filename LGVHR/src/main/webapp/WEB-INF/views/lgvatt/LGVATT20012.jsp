<%@ page language ="java" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="lgcom" uri="/WEB-INF/tags/lgcomTag.tld" %>
<%---------------------------------------------------------
	파일명 : LGVATT20012.jsp
	프로젝트명 : LGD WCFW

	Copyright(c) 2017 LG CNS, All rights reserved.

	2021/03/19   HMT_20210319      Add Popup - Alarming working hours
-------------------------------------------------------------%>
<html lang="ko">
<head>
<title></title>
<%@ include file="/WEB-INF/views/framework/bizFormHeader.jsp" %>

</head>

<body>
<div class="mdi-container popup">
  <section class="page-content">
	<div class="guideline_Viet">
			<table class="table table-bordered table-condensed">
				<colgroup>
					<col width="*" />
				</colgroup>
				<thead>
					<tr>
						<th>Warning</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td>
							<b>Alarming working hours compliance</b><br>
							1. Do not work more than 60 hours/week<br>
							2. Do not work for more than 6 consecutive days<br>
							3. Daily overtime must not exceed 50% of normal working hours.<br>
							
							<b>Tuân thủ thời gian làm việc.</b><br>
							1. Không làm việc quá 60h/tuần<br>
							2. Không làm việc quá 6 ngày liên tiếp<br>
							3. Thời gian tăng ca hàng ngày không vượt quá 50% số giờ làm việc bình thường

						</td>
					</tr>
					
				</tbody>
			</table>
		</div>
	</section>
</div>
</body>
</html>
