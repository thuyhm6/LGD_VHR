package com.lgd.lgvhr.lgvatt.lgvattc0018.service.serviceImpl;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.activation.DataHandler;
import javax.activation.FileDataSource;
import javax.annotation.Resource;
import javax.mail.Message;
import javax.mail.Multipart;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.concurrent.CommonBatchService;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvattc0018.service.LGVATTC0018Service;

@Service(value="LGVATTC0018Service")
public class LGVATTC0018ServiceImpl implements LGVATTC0018Service, CommonBatchService {

	protected final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATTC0018ServiceImpl.class);
	
	//@Value("#{systemProperties['env'] == null ? 'local' : systemProperties['env']}")
	//String env = null;
	
	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Override
	public LGCOMData execute(LGCOMData param) {
		// TODO Auto-generated method stub
		return executeSendAttReport(param);
	}

	@Override
	public LGCOMData executeSendAttReport(LGCOMData param){
		// TODO Auto-generated method stub
		//mail ID, Mail address and organization_id get
		List<LGCOMData> mailInfos = this.commonDao.selectList("LGVATTC0018.getMailInformation", param);
		
		Calendar basicCalendar = Calendar.getInstance();
		
		//2day a go setting
		basicCalendar.add(Calendar.DAY_OF_MONTH, -2);
		
		basicCalendar.set(Calendar.HOUR_OF_DAY, 11);
		basicCalendar.set(Calendar.MINUTE, 0);
		basicCalendar.set(Calendar.SECOND, 0);
		
		Date mailDate = basicCalendar.getTime();
		
		SimpleDateFormat formatter1 = new SimpleDateFormat("yyyy-MM-dd HH:mm");
		String krDay = formatter1.format(mailDate);
		
		SimpleDateFormat formatter2 = new SimpleDateFormat("dd/MM/yyyy");
		String vhDay = formatter2.format(mailDate);
		
		SimpleDateFormat formatter3 = new SimpleDateFormat("HH:mm");
		String time = formatter3.format(mailDate);
		
		Calendar todayCal = Calendar.getInstance();
		String today = formatter2.format(todayCal.getTime()); 
		
		String filePath = "";
		File excelFile = null;
		
		String fileFolder = "E:\\data004\\jussvc01\\attachment\\attendance";
		
		File tempDir = new File(fileFolder);
		if(!tempDir.exists()){
			tempDir.mkdir();
		}
		
		//mailInfo의 organization_id 를 가져와서 daily, weekly, monthly data send
		for(LGCOMData mailInfo : mailInfos){
			String mailAddress = mailInfo.getString("mailAddr");
			String organizationId = mailInfo.getString("organizationId");
			String orgType = mailInfo.getString("orgType");
			//local org name
			String part = mailInfo.getString("orgNameLocal");
			
			Date date = new Date();
			SimpleDateFormat sdformat = new SimpleDateFormat("dd/MM/yyyy");
			
			Calendar cal = Calendar.getInstance();
			
			cal.setTime(date);
			cal.add(Calendar.DATE, -2);
			String paramDate = "";
			
			paramDate = sdformat.format(cal.getTime());
			
			//daily summary setting
			LGCOMData dailyParam = new LGCOMData();
			dailyParam.put("organizationId", organizationId);
			dailyParam.put("attDate", paramDate);
			dailyParam.put("orgType", orgType);
			String dailyHtmlRowCompleted = "";
			String dailyHtml = "";
			
			List<LGCOMData> dailySummaryList = this.commonDao.selectList("LGVATT30090.getDailySummaryList", dailyParam);
			for(LGCOMData dailySummary : dailySummaryList){
				//daily summary list 추출 및 HTML 만들기
				String dailyHtmlRow = "";
				dailyHtmlRowCompleted += makeTableRowData(dailyHtmlRow, dailySummary);
			}
			dailyHtml = makeHtmlTable(dailyHtmlRowCompleted, "Day");
			
			//weekly summary setting
			LGCOMData weeklyFromTo = this.commonDao.select("LGVATT30092.todayWeeklyFromTo");
			String startDate = weeklyFromTo.getString("msStartDate");
			String endDate = weeklyFromTo.getString("msEndDate");
			
			LGCOMData weeklyParam = new LGCOMData();
			weeklyParam.put("organizationId", organizationId);
			weeklyParam.put("dateFrom", startDate);
			weeklyParam.put("dateTo", endDate);
			weeklyParam.put("orgType", orgType);
			
			String weeklyHtmlRowCompleted = "";
			String weeklyHtml = "";
			
			List<LGCOMData> weeklySummaryList = this.commonDao.selectList("LGVATT30092.getWeeklySummaryList",weeklyParam);
			for(LGCOMData weeklySummary : weeklySummaryList){
				//weekly summary list 추출 및 HTML 만들기
				String weeklyHtmlRow = "";
				weeklyHtmlRowCompleted += makeTableRowData(weeklyHtmlRow, weeklySummary);
			}
			weeklyHtml = makeHtmlTable(weeklyHtmlRowCompleted, "Week");
			
			//monthly summary setting
			SimpleDateFormat sdfMonth = new SimpleDateFormat("yyyyMM");
			String paramMonth = "";
			paramMonth = sdfMonth.format(cal.getTime());
			
			LGCOMData monthlyParam = new LGCOMData();
			monthlyParam.put("organizationId", organizationId);
			monthlyParam.put("dateMonth", paramMonth);
			monthlyParam.put("orgType", orgType);
			
			String monthlyHtmlRowCompleted = "";
			String monthlyHtml = "";
			
			List<LGCOMData> monthlySummaryList = this.commonDao.selectList("LGVATT30093.getMonthlySummaryList",monthlyParam);
			for(LGCOMData monthlySummary : monthlySummaryList){
				//monthly summary list 추출 및 HTML 만들기
				String monthlyHtmlRow = "";
				monthlyHtmlRowCompleted += makeTableRowData(monthlyHtmlRow, monthlySummary);
			}
			monthlyHtml = makeHtmlTable(monthlyHtmlRowCompleted, "Month");
			
			filePath = fileFolder + "\\"+krDay.replaceAll("[^a-zA-Z0-9]","")+"_"+organizationId+"_AttReport.xlsx";
			
			//mail subject Replace
			String sender = "nhansu@lgdisplay.com";
			String subject = mailInfo.getString("subjectText").replace("[part]", part).replace("[date]", paramMonth.substring(0,4));
			String senderName = "VHR Attendance System";
			
			//mail Content Replace
			String content = mailInfo.getString("mailDetailContent").replace("[daily]", dailyHtml)
																	.replace("[weekly]", weeklyHtml)
																	.replace("[monthly]", monthlyHtml)
																	.replace("[dataGetDayVhSubject]", vhDay)
																	.replace("[dataGetDayVh]", vhDay)
																	.replace("[dataGetDayKr]", krDay)
																	.replace("[dataGetTime]", time)
																	.replace("[dateToday]", today);
			
			try{
				//excel file create
				excelFile = makeExcelData(organizationId, part, paramDate, filePath);
			}catch(IOException ioe){
				ioe.printStackTrace();
			}
			
			//mail send
			sendEmailAttReport(sender,senderName,content,mailAddress,subject,excelFile);
			
			//excel file delete server
			if (!filePath.equals("")){
				LOGGER.debug("filePath ::: " + filePath);
				deleteFile(filePath);
			}
		}
		
		return param;
	}
	
	public String makeTableRowData(String htmlRowData,LGCOMData param){
		htmlRowData += "<tr>"
				+ "<td> " + param.getString("team") + "</td>"
				+ "<td> " + param.getString("section") + "</td>"
				+ "<td> " + param.getString("task") + "</td>"
				+ "<td> " + param.getString("part") + "</td>"
				+ "<td> " + param.getString("unit") + "</td>"
				+ "<td> " + param.getString("total") + "</td>"
				+ "<td> " + param.getString("lateness") + "</td>"
				+ "<td> " + param.getString("leavingEarly") + "</td>"
				+ "<td> " + param.getString("outing") + "</td>"
				+ "<td> " + param.getString("training") + "</td>"
				+ "<td> " + param.getString("annualLeave") + "</td>"
			+ "</tr>";
		return htmlRowData;
	}
	
	public String makeHtmlTable(String htmlRow, String div){
		String htmlTable = "";
		
		//mail Table Head
		String tableHtmlHead = "";		
		tableHtmlHead += "<!DOCTYPE html><html><head><style> table,th,td {border: 1px solid; text-align: center;}"
						+ "th{font-weight: bolder; background-color: #dcdcdc;}"
						+ "table{width: 100%; border-collapse: collapse;}"
						+ " </style></head>"
						+ "<table>"
						+ "<tr>"
/*							+ "<th rowspan='2'> Devision </th>"
							+ "<th rowspan='2'> Department </th>"*/
							+ "<th rowspan='2'> Team </th>"
							+ "<th rowspan='2'> Section </th>"
							+ "<th rowspan='2'> Task </th>"
							+ "<th rowspan='2'> Part </th>"
							+ "<th rowspan='2'> Unit </th>"
							+ "<th rowspan='2'> Total </th>"
							+ "<th colspan='5'> "+div+" </th>"
						+ "</tr>"
						+ "<tr>"
							+ "<td style='background-color: #dcdcdc; font-weight: bolder;' > Lateness </td>"
							+ "<td style='background-color: #dcdcdc; font-weight: bolder;' > Leaving_early </td>"
							+ "<td style='background-color: #dcdcdc; font-weight: bolder;' > Outing </td>"
							+ "<td style='background-color: #dcdcdc; font-weight: bolder;' > Training </td>"
							+ "<td style='background-color: #dcdcdc; font-weight: bolder;' > annual_leave </td>"
						+ "</tr>";
		
		htmlTable = tableHtmlHead + htmlRow + "</table></body></html>";
		return htmlTable;
	}
	
	public File makeExcelData(String organizationId, String OrgName, String paramDate, String filePath) throws IOException{
		
		LGCOMData param = new LGCOMData();
		param.put("organizationId", organizationId);
		
		List<LGCOMData> data = this.commonDao.selectList("LGVATTC0018.getAttendanceData", param);
		
		//data가 0건인 경우 첨부하지 않음
		if (data.size() > 0){
			Workbook workbook = new XSSFWorkbook();
			Sheet sheet = workbook.createSheet("AttReport");
			
			//부서 정보 입력 ORG_NAME -> 
			Row Department = sheet.createRow(0);
			Cell teamCell = Department.createCell(0);
			teamCell.setCellValue("Team");
			Cell orgName = Department.createCell(1);
			orgName.setCellValue(OrgName);
			
			//Header column add
			Row headerRow = sheet.createRow(1);
			String[] ColumnHeaders = {	 "EmployeeNo"
										,"STATUS"
										,"FULL_NAME_ENGLISH"
										,"TEAM_ID"
										,"TEAM_NAME"
										,"TIME_AND_ATTENDANCE_DATE"
										,"A_DAY_OF_THE_WEEK_CODE"
										,"CHECK_IN_DATE"
										,"WORK_START_DATETIME"
										,"CHECK_OUT_DATE"
										,"WORK_END_DATETIME"
										,"SHIFT_TYPE_CODE"
										,"TIME_AND_ATTENDANCE_CODE"
										,"RES_TIME_AND_ATTENDANCE_CODE"
										,"NIGHT_SHIFT_FLAG"
										,"WORK_START_TIME"
										,"RES_NIGHT_SHIFT_FLAG"
										,"IN_TIME_OVER_YN"};
			
			for(int i = 0; i < ColumnHeaders.length; i++){
				Cell cell = headerRow.createCell(i);
				cell.setCellValue(ColumnHeaders[i]);
			}
			
			//Contents Add (Report Data)
			int rownum = 2;
			for(LGCOMData row : data){
				Row dataRow = sheet.createRow(rownum++);
				LOGGER.debug("dataRow ::: " + row);
				
				Cell employeeNo = dataRow.createCell(0);
				employeeNo.setCellValue(row.get("employeeno").toString());
				
				Cell status = dataRow.createCell(1);
				status.setCellValue(row.get("status").toString());
				
				Cell fullNameEnglish = dataRow.createCell(2);
				fullNameEnglish.setCellValue(row.get("fullnameenglish").toString());
				
				Cell cellOrganizationId = dataRow.createCell(3);
				cellOrganizationId.setCellValue(row.get("organizationid").toString());
				
				Cell orgNameEng = dataRow.createCell(4);
				orgNameEng.setCellValue(row.get("orgnameeng").toString());
				
				Cell timeAndAttendanceDate = dataRow.createCell(5);
				timeAndAttendanceDate.setCellValue(row.get("timeandattendancedate").toString());
				
				Cell aDayOfTheWeekCode = dataRow.createCell(6);
				aDayOfTheWeekCode.setCellValue(row.get("adayoftheweekcode").toString());
				
				Cell checkInDate = dataRow.createCell(7);
				checkInDate.setCellValue(row.get("checkindate").toString());
				
				Cell workStartDatetime = dataRow.createCell(8);
				workStartDatetime.setCellValue(row.get("workstartdatetime").toString());
				
				Cell checkOutDate = dataRow.createCell(9);
				checkOutDate.setCellValue(row.get("checkoutdate").toString());
				
				Cell workEndDatetime = dataRow.createCell(10);
				workEndDatetime.setCellValue(row.get("workenddatetime").toString());
				
				Cell shiftTypeCode = dataRow.createCell(11);
				shiftTypeCode.setCellValue(row.get("shifttypecode").toString());
				
				Cell timeAndAttendanceCode = dataRow.createCell(12);
				timeAndAttendanceCode.setCellValue(row.get("timeandattendancecode").toString());
				
				Cell resTimeAndAttendanceCode = dataRow.createCell(13);
				resTimeAndAttendanceCode.setCellValue(row.get("restimeandattendancecode").toString());
				
				Cell nightShiftFlag = dataRow.createCell(14);
				nightShiftFlag.setCellValue(row.get("nightshiftflag").toString());
				
				Cell workStartTime = dataRow.createCell(15);
				workStartTime.setCellValue(row.get("workstarttime").toString());
				
				Cell resNightShiftFlag = dataRow.createCell(16);
				resNightShiftFlag.setCellValue(row.get("resnightshiftflag").toString());
				
				Cell inTimeOverYn = dataRow.createCell(17);
				inTimeOverYn.setCellValue(row.get("intimeoveryn").toString());
			}
			
			File file = new File(filePath);
			try(FileOutputStream fos = new FileOutputStream(file)){
				workbook.write(fos);
			}finally{
				workbook.close();
			}
			LOGGER.debug("Excel File Created at : " + filePath);
			return file;
			
		}else{
			return null;
		}
	}
	
	//Excel File Delete
	public void deleteFile(String filePath){
		File file = new File(filePath);
		if(file.exists() && file.delete()){
			LOGGER.debug("File deleted successfully : " + filePath);
		}else{
			LOGGER.debug("Failed to delete the File : " + filePath);
		}
	}
	
	public void sendEmailAttReport(String sender, String senderName, String content, String receiver, String subject, File excelFile){
		String smtpServer = "mailrelay.lgdisplay.com";
		String smtpPort   = "25";

	    Properties props = new Properties();
	    props.put("mail.transport.protocol", "smtp");
	    props.put("mail.smtp.host", smtpServer);
	    props.put("mail.smtp.port", smtpPort);
	    
	    try{
	    	//create the session and create the new mail message
		    Session mailSession = Session.getInstance(props);
		    MimeMessage msg = new MimeMessage(mailSession);
		    //set the FROM, TO, DATE and SUBJECT fields
		    msg.setFrom(new InternetAddress(sender,senderName));
		    msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(receiver));
		    msg.setSentDate(new Date());
		    msg.setSubject(subject);
		    
		    if(excelFile == null){
		    	msg.setText(content);
			    msg.setContent(content, "text/html; charset=utf-8");
		    }else{
		    	//Create the message part
			    MimeBodyPart messageBodyPart = new MimeBodyPart();
			    
			    String[] fileName = excelFile.getName().split("\\\\");
			    
			    //Fill the message
			    messageBodyPart.setText(content);
			    messageBodyPart.setContent(content, "text/html; charset=utf-8");
			    Multipart multipart = new MimeMultipart();
			    multipart.addBodyPart(messageBodyPart);
			    
			    //Part two is attachment
			    messageBodyPart = new MimeBodyPart();
			    FileDataSource fds = new FileDataSource(excelFile);
			    messageBodyPart.setDataHandler(new DataHandler(fds));
			    messageBodyPart.setFileName(fileName[fileName.length-1]);
			    multipart.addBodyPart(messageBodyPart);
			    
			    //Put parts in message
			    msg.setContent(multipart);
		    }
		    
		    // Send the message
		    Transport.send(msg);
		    
		    //ask the Transport class to send our mail message
		    LOGGER.debug("E-mail successfully sent!!");
		    //LGCOMData errorData = new LGCOMData();
			//errorData.set("sender", sender);
			//errorData.set("receiver", receiver);
		} catch(Exception e){
			e.printStackTrace();
			LOGGER.debug(e.getMessage());
			LOGGER.debug("Send fail,emailAddress:" + receiver);
			LGCOMData errorData = new LGCOMData();
			errorData.set("sender", sender);
			errorData.set("receiver", receiver);
		}
	}
}
