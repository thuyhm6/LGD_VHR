/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvatt50060Service.java
 * @Desc    : Employee Unpaid Leave Warning
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2025.11.11  HMT_20251111    Employee Unpaid Leave Warning
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvatt.lgvatt50060.service.serviceImpl;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Properties;

import javax.annotation.Resource;
import javax.mail.Message;
import javax.mail.Multipart;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeBodyPart;
import javax.mail.internet.MimeMessage;
import javax.mail.internet.MimeMultipart;

import org.springframework.stereotype.Service;
import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvatt.lgvatt50060.service.LGVATT50060Service;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvatt.lgvatt50060.controller.LGVATT50060Controller.java
 * </PRE>
 *
 * @Author    HMT
 * @Date      2021. 03. 17. 11:06 AM
 * @Version
 */
@Service(value="LGVATT50060Service")
public class LGVATT50060ServiceImpl implements LGVATT50060Service{
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVATT50060ServiceImpl.class);
	
	@Resource(name="commonDao")
	CommonDao commonDao;
	
	/**
	 * Desc : 공휴일을 조회한다.
	 * @Method Name : retrieveEmpULWarning
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveEmpULWarning(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVATT50060.retrieveEmpULWarning",param);
	}
	
	/**
     * Desc : 급여대상자 리스트 엑셀 다운로드
     * @Method Name : createExcelExportData
     * @param  param
     * @throws Exception
     */
    public List<LGCOMData> createExcelExportData(LGCOMData param) {
        int sessionId = LGCOMUtils.getRandomNumber();
        param.set("sessionId", sessionId);
        LOGGER.debug("param = " + param);
        int resultCnt = this.commonDao.insert("LGVATT50060.createExcelDownloadData",param);
        
        List<LGCOMData> list = LGCOMData.createList();
        
        try {
        	LGCOMData result = new LGCOMData();
            result.set("resultCnt", resultCnt);
            result.set("sessionId", sessionId);
            
            list.add(result);
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), e);
        }
        
        return list;
    }
    
    @SuppressWarnings("unchecked")
   	public void cancelSendEmail(LGCOMData param) {
   		LOGGER.debug("cancelSendEmail param = " + param);
   		
   		List<LGCOMData> modifyList = (List<LGCOMData>)param.get("modifyList");
		
   		LOGGER.debug("modifyList = " + modifyList);
    	
        for ( LGCOMData item : LGCOMUtils.emptyIfNull(modifyList) ) {
        	item.set("subsidiaryCode", ((LGCOMData)param.get("LGVHR_PROJECT_SESSION")).get("subsidiaryCode"));
        	item.set("sendEmailFlag", param.get("sendEmailFlag"));
        	item.set("applicationUserId", ((LGCOMData)param.get(LGCOMConstants.HTTP_SESSION_KEY)).get("applicationUserId"));
    		
    		this.commonDao.update("LGVATT50060.cancelSendEmail", item);
        }
        
   	}
    
    /**
     * Desc : 휴일을 저장한다.
     * @Method Name : saveHolidayManage
     * @param  param
     * @throws Exception
     */
    @SuppressWarnings("unchecked")
	public void saveEmpUlWarning(LGCOMData param) {
		LOGGER.debug("saveEmpUlWarning param = " + param);

		LGCOMData projectSession = (LGCOMData)param.get("LGVHR_PROJECT_SESSION");
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		LGCOMData parameter = (LGCOMData)param.get("parameter");
		
		List<LGCOMData> insertList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		List<LGCOMData> updateList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		List<LGCOMData> deleteList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);

		//삭제처리
		for( LGCOMData dItem : LGCOMUtils.emptyIfNull(deleteList) ) {
			
			dItem.put("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			dItem.put("applicationUserId", userSession.get("applicationUserId"));
			
			this.commonDao.update("LGVATT50060.deleteEmpUlWarning",dItem);
		}
		//수정처리
		for( LGCOMData uItem : LGCOMUtils.emptyIfNull(updateList) ) {
			
			uItem.put("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			uItem.put("applicationUserId", userSession.get("applicationUserId"));
			
			this.commonDao.update("LGVATT50060.updateEmpUlWarning",uItem);
		}
		//등록처리
		for( LGCOMData iItem : LGCOMUtils.emptyIfNull(insertList) ) {
			
			iItem.put("subsidiaryCode", projectSession.getString("subsidiaryCode"));
			iItem.put("applicationUserId", userSession.get("applicationUserId"));
			
			this.commonDao.update("LGVATT50060.insertEmpUlWarning",iItem);
		}
			
	}
    
    @SuppressWarnings("unchecked")
   	public void sendEmail(LGCOMData param) {
   		LOGGER.debug("sendEmail param = " + param);
   		
   		//Send Email
   		this.sendEmpUlWarningByEmail(param);
   	}
    
    public void sendEmpUlWarningByEmail(LGCOMData param) {
		try{
			// Date format
	        SimpleDateFormat formatter = new SimpleDateFormat("dd/MM/yyyy");
			// 1. Initialize Calendar with the current time
	        Calendar calendar = Calendar.getInstance();

	        // 2. Get the first day of the year
	        calendar.set(Calendar.DAY_OF_YEAR, 1);
	        Date firstDay = calendar.getTime();

	        // 3. Get the last day of the year
	        // Reset the current date for accurate calculation (if needed)
	        calendar.setTime(new Date()); 
	        Date currentDay = calendar.getTime();
	        String noticeDate = formatter.format(currentDay);
	        // Logic to get the last day: Month 12 (index 11), day 31
	        calendar.set(Calendar.MONTH, 11); 
	        calendar.set(Calendar.DAY_OF_MONTH, 31);
	        Date lastDay = calendar.getTime();

	        System.out.println("Đầu năm: " + firstDay);
	        System.out.println("Cuối năm: " + lastDay);

	        param.set( "atendanceStartDate", formatter.format(firstDay));
	        param.set( "atendanceEndDate", formatter.format(lastDay));
			
			param.set( "emailInfo", "EMP_UL_WARNING_SEND_EMAIL_INFO");
			LGCOMData mailParamData =  this.commonDao.select("LGVATT50060.retrieveSendEmailInfo", param);
			String sender = mailParamData.getString("sender");
			String senderName = mailParamData.getString("senderName");
			String subject = mailParamData.getString("subject");
			//String subject = mailParamData.getString("subject").replace("[payMonth]", payMonthName);
			int mailSplit = mailParamData.getInt("value5");

			List<LGCOMData> managerEmailList = this.commonDao.selectList("LGVATT50060.retrieveManagerEmailList", param);
			List<List<LGCOMData>> parts = chopped(managerEmailList,mailSplit);
			for (List<LGCOMData> part : parts) {
				for(LGCOMData empEmail: part){
					//String vhID = empEmail.getString("employeeNo");
					//String vhName = empEmail.getString("employeeName");
					//String managerID = empEmail.getString("managerNo1");
					String managerNo = empEmail.getString("managerNo");
					String managerName = empEmail.getString("managerName");
					String managerEmail = empEmail.getString("managerEmail");
					//String subject = mailParamData.getString("subject").replace("[empName]", vhID + " - " + vhName);
					
					//get Employee List
					param.set( "managerNo", managerNo);
					param.set( "sendEmailFlag", "1");
					List<LGCOMData> employeeList = this.commonDao.selectList("LGVATT50060.retrieveEmpULWarning", param);
					if (employeeList.size() > 0) {
						String employeeInfoList = buildHtmlTable(employeeList);
						String content = mailParamData.getString("mailContent").replace("[managerName]", managerName);
						content = content.replace("[noticeDate]", noticeDate);
						content = content.replace("[empUlTableList]", employeeInfoList); 
										
						this.sendMailByJavax(subject, content, sender, senderName, managerEmail);
						System.out.println("==================================");
						System.out.println("completed send email");
					}
					
				}
				if (part.size() == mailSplit) {
					Thread.sleep(60000);
				}
			}
			
			} catch(Exception e){
				e.printStackTrace();
				System.out.println("Mail send fail,emailAddress:");
				param = null;
			}
			
	}
	
	// Create employee table
    private static String buildHtmlTable(List<LGCOMData> list) {
        StringBuilder sb = new StringBuilder();
        
        sb.append("<table border='1' style='border-collapse: collapse; width: 100%;'>");
        sb.append("<tr style='background-color: #f2f2f2;'>");
        sb.append("<th style='padding: 8px;'>Employee No</th>");
        sb.append("<th style='padding: 8px;'>Employee Name</th>");
        sb.append("<th style='padding: 8px;'>Start Date</th>");
        sb.append("<th style='padding: 8px;'>End Date</th>");
        sb.append("<th style='padding: 8px;'>Total Days</th>");
        sb.append("<th style='padding: 8px;'>Note</th>");
        sb.append("</tr>");

        for (LGCOMData w : list) {
            sb.append("<tr>");
            sb.append("<td style='padding: 8px; text-align: center;'>").append(w.getString("employeeNo")).append("</td>");
            sb.append("<td style='padding: 8px; text-align: center;'>").append(w.getString("employeeName")).append("</td>");
            sb.append("<td style='padding: 8px; text-align: center;'>").append(w.getString("startDate")).append("</td>");
            sb.append("<td style='padding: 8px; text-align: center;'>").append(w.getString("endDate")).append("</td>");
            sb.append("<td style='padding: 8px; text-align: center;'>").append(w.getString("totalDays")).append("</td>");
            sb.append("<td style='padding: 8px;'>").append(w.getString("note")).append("</td>");
            sb.append("</tr>");
        }
        sb.append("</table>");
        return sb.toString();
    }
	
	//split data
	public  List<List<LGCOMData>> chopped(List<LGCOMData> list, final int l) {
		List<List<LGCOMData>> parts = new ArrayList<List<LGCOMData>>();
		final int n = list.size();
		for (int i = 0; i < n; i += l) {
			parts.add(new ArrayList<LGCOMData>(list.subList(i, Math.min(n, i+l))));
		}
		return parts;
	}
	
	public void sendMailByJavax(String title,String content, String sender, String senderName, String address) {
		
		String smtpServer = "mailrelay.lgdisplay.com";
		String smtpPort   = "25";

	    Properties props = new Properties();
	    props.put("mail.transport.protocol", "smtp");
	    props.put("mail.smtp.host", smtpServer);
	    props.put("mail.smtp.port", smtpPort);
	    try {
		  //create the session and create the new mail message
		    Session mailSession = Session.getInstance(props);
		    MimeMessage msg = new MimeMessage(mailSession);
		    //set the FROM, TO, DATE and SUBJECT fields
		    msg.setFrom(new InternetAddress(sender, senderName, "UTF-8"));
		    msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(address));
		    msg.setSentDate(new Date());
		    msg.setSubject(title);
		    msg.setText(content);
		    msg.setContent(content, "text/html; charset=utf-8");
		    
		    // Create the message part
		    MimeBodyPart messageBodyPart = new MimeBodyPart();
		 
		    // Fill the message
		    messageBodyPart.setText(content);
		    messageBodyPart.setContent(content, "text/html; charset=utf-8");
		    Multipart multipart = new MimeMultipart();
		    multipart.addBodyPart(messageBodyPart);
		    
		    // Put parts in message
		    msg.setContent(multipart);
		 
		    // Send the message
		    Transport.send(msg);
		 
		    //ask the Transport class to send our mail message
		    System.out.println("E-mail successfully sent!!");
		    LGCOMData errorData = new LGCOMData();
			errorData.set("payFlag", "Y");
			errorData.set("payError", "");
			errorData.set("payType", "SEND");
			//this.commonDao.update("LGVATT50060.updateEmailEmpSendError",errorData);
		} catch(Exception e){
			e.printStackTrace();
			System.out.println(e.getMessage());
			System.out.println("Send fail,emailAddress:" + address);
			LGCOMData errorData = new LGCOMData();
			errorData.set("payFlag", "N");
			errorData.set("payError", "Fail to send");
			errorData.set("payType", "SEND");
			//this.commonDao.update("LGVATT50060.updateEmailEmpSendError",errorData);
		}
	}
	

}
