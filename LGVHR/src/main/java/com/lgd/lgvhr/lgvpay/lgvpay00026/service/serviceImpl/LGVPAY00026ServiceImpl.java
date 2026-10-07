package com.lgd.lgvhr.lgvpay.lgvpay00026.service.serviceImpl;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
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

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.xhtmlrenderer.pdf.ITextFontResolver;
import org.xhtmlrenderer.pdf.ITextRenderer;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpay00026.service.LGVPAY00026Service;
import com.lgd.lgvhr.lgvpay.lgvpayp0002.service.LGVPAYP0002Service;
import com.lowagie.text.DocumentException;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.ColumnText;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfGState;
import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.PdfStamper;
import com.lowagie.text.pdf.PdfWriter;

/**
 * com.lgd.lgcom.lgvpay.lgvpay00026.service.serviceImpl.LGVPAY00026ServiceImpl.java
 * Send PaySlip By Employee
 * @Author    HaMinhThuy
 * @Date      2022.06.25. 15:35:32
 * @Version
 * HMT_20220901 add dependant_count and other_income_kind
 */
@Service("LGVPAY00026Service")
public class LGVPAY00026ServiceImpl implements LGVPAY00026Service {
	//static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00026ServiceImpl.class);
	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Resource(name="LGVPAYP0002Service")
    private LGVPAYP0002Service lgvpayp0002;

    /**
     * Desc : 확정된 Payroll Run 리스트 데이터를 조회한다. 
     * @Method Name : retrievePayrollRunList
     * @param param
     * @return List<LGCOMData>
     * @throws Exception
     */
    public List<LGCOMData> retrievePayrollRunList(LGCOMData param) {
    	return this.commonDao.selectList("LGVPAY00026.retrievePayrollRunList", param);
    }
    
    @Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData createPaySlip(LGCOMData param) {
		try{
			//Create payslip PDF
			LGCOMData mailParamData =  this.commonDao.select("LGVPAY00025.retrieveSendEmailInfo", param);
			String filepath = mailParamData.getString("value3");
			String adminPassWord = mailParamData.getString("value4");
			this.createPaySlipPDF(param, filepath, adminPassWord);
			System.out.println("Completed create PDF Payslip");
			} catch(Exception e){
				e.printStackTrace();
				System.out.println("Create PDF Payslip fail");
				param = null;
			}
    	return param;
    }
	
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData deletePaySlip(LGCOMData param) {
		
		try{
			//Delete payslip PDF
			LGCOMData mailParamData =  this.commonDao.select("LGVPAY00025.retrieveSendEmailInfo", param);
			String filepath = mailParamData.getString("value3");
			String calSet = param.getString("payrollCalculationExecId");
			File file = new File(filepath+calSet);
			if (file.isDirectory()) {
				String[] files = file.list();
				for (String child : files) {
					File childDir = new File(file, child);
					childDir.delete();
					System.out.println("File deleted: "+childDir.getAbsolutePath());
				}
				if (file.list().length == 0) {
					file.delete();
					System.out.println("File deleted: "+file.getAbsolutePath());
					param = null;
				}
			}
			System.out.println("Completed delete PDF Payslip");
			} catch(Exception e){
				e.printStackTrace();
				System.out.println("Delete PDF Payslip fail");
				param = null;
			}
    	return param;
    }
	
	/**
     * Desc : Add send payslip by email.
     * - confirm_flag = Y 변경
     * 
     * @Method Name : sendPayslipByEmail
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@Transactional(propagation=Propagation.REQUIRED)
    public LGCOMData sendPayslipByEmail(LGCOMData param) {
		
		try{
			/*LGCOMData tempData = lgvpayp0002.retrievePayrollCalculationExecIdData(param);
			if ( !NullUtil.isNull(tempData) ) {
				param.set( "payMonth", tempData.get("payMonthName") );
				param.set( "payType", tempData.get("payTypeName") );
			}*/
			//String calSet = param.getString("payrollCalculationExecId");
			String payMonthName = param.getString("payMonthName");
			String payMonth = param.getString("payMonth");
			LGCOMData mailParamData =  this.commonDao.select("LGVPAY00025.retrieveSendEmailInfo", param);
			String sender = mailParamData.getString("sender");
			String senderName = mailParamData.getString("senderName");
			String subject = mailParamData.getString("subject").replace("[payMonth]", payMonthName);
			String filepath = mailParamData.getString("value3");
			int mailSplit = mailParamData.getInt("value5");
			//get create employee
			//param.set( "sendFlag", "N" );
			List<LGCOMData> empEmailList = this.commonDao.selectList("LGVPAY00025.retrieveEmpEmailList", param);
			List<List<LGCOMData>> parts = chopped(empEmailList,mailSplit);
			for (List<LGCOMData> part : parts) {
				for(LGCOMData empEmail: part){
					String vhID = empEmail.getString("employeeNo");
					String vhName = empEmail.getString("employeeName");
					String emailOutside = empEmail.getString("emailOutside");
					//String lastName = empEmail.getString("lastnameEng");
					String calSetID = empEmail.getString("payrollCalculationExecId");
					String content = mailParamData.getString("mailContent").replace("[payMonth]", payMonthName);
					content = content.replace("[vhName]", vhName);
					this.sendMailByJavax(subject, content, sender, senderName, emailOutside, vhID, payMonth, calSetID, filepath);
					System.out.println("==================================");
					System.out.println("completed send email");
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
			
    	return param;
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
	 
public void sendMailByJavax(String title,String content, String sender, String senderName, String address, String vhID, String payMonth, String calSetID, String filepath) {
		
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
		    
		     // Part two is attachment
		    messageBodyPart = new MimeBodyPart();
		    File file = new File(filepath+calSetID+"\\"+vhID+"_"+calSetID+"_password"+".pdf");
		    FileDataSource fds = new FileDataSource(file);
		    messageBodyPart.setDataHandler(new DataHandler(fds));
		    messageBodyPart.setFileName(title.replace("Phiếu lương tháng", "Phieu luong thang")+".pdf");
		    multipart.addBodyPart(messageBodyPart);
		    
		 /*// Part three is image 1
		    BodyPart messageBodyPartIMG1 = new MimeBodyPart();
		    DataSource fds1 = new FileDataSource(filepath+"Password.png");
		    messageBodyPartIMG1.setDataHandler(new DataHandler(fds1));
		    messageBodyPartIMG1.setHeader("Content-ID", "<password>");
		    messageBodyPartIMG1.setFileName("img1");
		    multipart.addBodyPart(messageBodyPartIMG1);
		    
		 // Part three is image 2
		    BodyPart messageBodyPartIMG2 = new MimeBodyPart();
		    DataSource fds2 = new FileDataSource(filepath+"LGDisplay.png");
		    messageBodyPartIMG2.setDataHandler(new DataHandler(fds2));
		    messageBodyPartIMG2.setHeader("Content-ID", "<LGDisplay>");
		    messageBodyPartIMG2.setFileName("img2");
		    multipart.addBodyPart(messageBodyPartIMG2);
		    
		 // Part three is image 3
		    BodyPart messageBodyPartIMG3 = new MimeBodyPart();
		    DataSource fds3 = new FileDataSource(filepath+"YouDream.png");
		    messageBodyPartIMG3.setDataHandler(new DataHandler(fds3));
		    messageBodyPartIMG3.setHeader("Content-ID", "<YouDream>");
		    messageBodyPartIMG3.setFileName("img3");
		    multipart.addBodyPart(messageBodyPartIMG3);*/
		 
		    // Put parts in message
		    msg.setContent(multipart);
		 
		    // Send the message
		    Transport.send(msg);
		 
		    //ask the Transport class to send our mail message
		    System.out.println("E-mail successfully sent!!");
		    LGCOMData errorData = new LGCOMData();
			errorData.set("payrollCalculationExecId", calSetID);
			errorData.set("employeeNo", vhID);
			errorData.set("payFlag", "Y");
			errorData.set("payError", "");
			errorData.set("payType", "SEND");
			errorData.set("payMonth", payMonth);
			//this.commonDao.update("LGVPAY00026.updateEmailEmpSendError",errorData);
			this.commonDao.select("LGVPAY00026.updateEmailEmpPKG",errorData);
		} catch(Exception e){
			e.printStackTrace();
			System.out.println(e.getMessage());
			System.out.println("Send fail,emailAddress:" + address);
			LGCOMData errorData = new LGCOMData();
			errorData.set("payrollCalculationExecId", calSetID);
			errorData.set("employeeNo", vhID);
			errorData.set("payFlag", "N");
			errorData.set("payError", "Fail to send");
			errorData.set("payType", "SEND");
			errorData.set("payMonth", payMonth);
			//this.commonDao.update("LGVPAY00026.updateEmailEmpSendError",errorData);
			this.commonDao.select("LGVPAY00026.updateEmailEmpPKG",errorData);
		}
	}
	
	public void createPaySlipPDF(LGCOMData param, String filepath, String adminPassWord) throws InterruptedException{

		String calSet = param.getString("payrollCalculationExecId");
		String basePath = filepath+calSet+"\\";
		String inputFile = filepath+"paySlip.htm";
		String outputFile = filepath+calSet+"\\"+"paySlip.pdf";
		String payMonth   = param.getString("payMonth");
		File paySlipDir = new File(filepath+calSet);
		if (paySlipDir.mkdir()) {
			System.out.println("Completed create Payslip folder");
		} else {
			System.out.println("Fail create PDF Payslip folder");
		}
		InputStream is = null;
		InputStreamReader isr = null;
		String result = "";
		String replaceStr = "";
		/*LGCOMData tempData = lgvpayp0002.retrievePayrollCalculationExecIdData(param);
		if ( !NullUtil.isNull(tempData) ) {
			param.set( "payMonth", tempData.get("payMonthName") );
			param.set( "payType", tempData.get("payTypeName") );
		}*/
			LGCOMData mailParamData =  this.commonDao.select("LGVPAY00025.retrieveSendEmailInfo", param);
			int fileSplit = 5500; //mailParamData.getInt("value5");  //run 5000 data then break
			//get create employee
			//param.set( "createFlag", "N" );
			List<LGCOMData> empEmailList = this.commonDao.selectList("LGVPAY00025.retrieveEmpEmailList", param);
			List<List<LGCOMData>> parts = chopped(empEmailList,fileSplit);
			for (List<LGCOMData> part : parts) {
			for(LGCOMData empEmail: part){
				try {
				param.set( "employeeNo", empEmail.get("employeeNo") );
				/*取三种项目最多的数量*/
				
				/*读取模板*/
				int data=0;
				char[] ch =new char[1024];
				is = new FileInputStream(inputFile);
				isr = new InputStreamReader(is,"UTF8");
				result = "";
				while((data = isr.read(ch))!=-1){
	                 result+=new String(ch,0,data);
				}
				
				//personal info
				LGCOMData employeeData = this.commonDao.select("LGVPAY00001.retrieveEmployeeData", param);
	        	//contract salary info
				param.set( "payMonth", param.get("payMonthName") );
				LGCOMData contractSalaryData = this.commonDao.select("LGVPAY00001.retrieveContractSalaryData", param);
	        	//salary detail info
				LGCOMData salaryDetailData = this.commonDao.select("LGVPAY00026.retrieveSalaryDetailDataSend", param);
	        	
	        	param.set( "incomeDeductionCode", "INCOME");
	        	param.set( "incomeDeductionTimeCode", "TIME_N");
	        	//income(시간 없는 항목) 상세 리스트
	        	List<LGCOMData> incomeTimeNList = this.commonDao.selectList("LGVPAY00026.retrieveSalaryDetailListSend", param);
	        	
	        	param.set( "incomeDeductionCode", "INCOME");
	        	param.set( "incomeDeductionTimeCode", "TIME_Y");
	        	//income(시간 있는 항목) 상세 리스트
	        	List<LGCOMData> incomeTimeYList = this.commonDao.selectList("LGVPAY00026.retrieveSalaryDetailListSend", param);
	        	
	        	param.set( "incomeDeductionCode", "DEDUCTION");
	        	param.set( "incomeDeductionTimeCode", "");
	        	//deduction 상세 리스트
	        	List<LGCOMData> deductionList = this.commonDao.selectList("LGVPAY00026.retrieveSalaryDetailListSend", param);
	        	
	        	//etc - adjustment 리스트
	        	List<LGCOMData> adjustmentList = this.commonDao.selectList("LGVPAY00026.retrieveAdjustmentListSend", param);
	        	
				result = result.replace("[PAY_DATE]", param.get("payMonthName")==null?"":param.get("payMonthName")+"");
				result = result.replace("[DEPARTMENT]", employeeData.get("organizationName")==null?"":employeeData.get("organizationName")+"");
				result = result.replace("[EMPLOYEE NO]", employeeData.get("employeeNo")==null?"":employeeData.get("employeeNo")+"");
				result = result.replace("[NAME]", employeeData.get("employeeName")==null?"":employeeData.get("employeeName")+"");
				result = result.replace("[GRADE]", employeeData.get("gradeTitleCode")==null?"":employeeData.get("gradeTitleCode")+"");
				result = result.replace("[RANK]", employeeData.get("gradeTitleName")==null?"":employeeData.get("gradeTitleName")+"");
				result = result.replace("[EMPLOYEE TYPE]", employeeData.get("empCategoryName")==null?"":employeeData.get("empCategoryName")+"");
				result = result.replace("[EMPLOYEE SHIFT]", employeeData.get("workTypeName")==null?"":employeeData.get("workTypeName")+"");
				result = result.replace("[START DATE]", employeeData.get("hireDate")==null?"":employeeData.get("hireDate")+"");
				result = result.replace("[CONTRACT TYPE]", employeeData.get("contractTypeName")==null?"":employeeData.get("contractTypeName")+"");
				result = result.replace("[DEPENDANT_COUNT]", employeeData.get("dependantCount")==null?"":employeeData.get("dependantCount")+""); //HMT_20220901
				result = result.replace("[OTHER_INCOME_KIND]", employeeData.get("otherIncomeKind")==null?"":employeeData.get("otherIncomeKind")+""); //HMT_20220901
				
				result = result.replace("[OLD SAL]", contractSalaryData.get("probationPeriodOdwgAmount")==null?"":contractSalaryData.get("probationPeriodOdwgAmount")+"");
				result = result.replace("[NEW SAL]", contractSalaryData.get("ordinaryWagesAmount")==null?"":contractSalaryData.get("ordinaryWagesAmount")+"");
				result = result.replace("[USE_AL_DAYS]", contractSalaryData.get("useAlDays")==null?"":contractSalaryData.get("useAlDays")+"");
				result = result.replace("[REMAIN_AL_DAYS]", contractSalaryData.get("remainAlDays")==null?"":contractSalaryData.get("remainAlDays")+"");
				result = result.replace("[DEPENDANT_COUNT_PAY]", contractSalaryData.get("dependantCountPay")==null?"":contractSalaryData.get("dependantCountPay")+"");
				result = result.replace("[BANK_NAME]", salaryDetailData.get("bankName")==null?"":salaryDetailData.get("bankName")+"");
				result = result.replace("[BANK_ACCOUNT_NO]", salaryDetailData.get("bankAccountNo")==null?"":salaryDetailData.get("bankAccountNo")+"");
				
				result = result.replace("[NIGHT_HOURS]", salaryDetailData.get("nightHours")==null?"":salaryDetailData.get("nightHours")+"");
				result = result.replace("[OT_HOURS]", salaryDetailData.get("otHours")==null?"":salaryDetailData.get("otHours")+"");
				result = result.replace("[OTNT_HOURS]", salaryDetailData.get("otntHours")==null?"":salaryDetailData.get("otntHours")+"");
				result = result.replace("[LATENESS_HOURS]", salaryDetailData.get("latenessHours")==null?"":salaryDetailData.get("latenessHours")+"");
				result = result.replace("[LEAVING_EARLY_HOURS]", salaryDetailData.get("leavingEarlyHours")==null?"":salaryDetailData.get("leavingEarlyHours")+"");
				result = result.replace("[GOOUT_HOURS]", salaryDetailData.get("gooutHours")==null?"":salaryDetailData.get("gooutHours")+"");
				result = result.replace("[ABSENCE_LEAVE_DAYS]", salaryDetailData.get("absenceLeaveDays")==null?"":salaryDetailData.get("absenceLeaveDays")+"");
				result = result.replace("[UNPAID_LEAVE_DAYS]", salaryDetailData.get("unpaidLeaveDays")==null?"":salaryDetailData.get("unpaidLeaveDays")+"");
				result = result.replace("[SUSPENSION_LEAVE_DAYS]", salaryDetailData.get("suspensionLeaveDays")==null?"":salaryDetailData.get("suspensionLeaveDays")+"");
				
				result = result.replace("[INCOME_TIME_N_AMOUNT]", salaryDetailData.get("incomeTimeNAmount")==null?"":salaryDetailData.get("incomeTimeNAmount")+"");
				result = result.replace("[INCOME_TIME_Y_AMOUNT]", salaryDetailData.get("incomeTimeYAmount")==null?"":salaryDetailData.get("incomeTimeYAmount")+"");
				
				//Add allowance
				replaceStr = "";
				int rowAllw = 0;
				int rowOther = 0;
				int rowPay = incomeTimeNList.size();
				if (rowPay < incomeTimeYList.size()) {
					rowPay = incomeTimeYList.size();
				}
				if (rowPay < deductionList.size()) {
					rowPay = deductionList.size();
				}
				for(LGCOMData incomeTimeN: incomeTimeNList){
					if (incomeTimeN.getString("code2").equals("BS")) {
						replaceStr += "<tr><td class='td_title' width='70px'>"+incomeTimeN.get("codeName1")+"</td>"
				                  + "<td class='td_type' width='100px' style='text-align: center;'>"+incomeTimeN.get("codeName2")+"</td>"
				                  + "<td class='td_type_right' width='60px'>"+incomeTimeN.get("itemAmount")+"</td></tr>";
					}
					
					if (incomeTimeN.getString("code1").equals("FA") && incomeTimeN.getString("rank1").equals("1")) {
						rowAllw = incomeTimeN.getInt("rowspanCnt1");
						if (!incomeTimeN.getString("itemAmount").equals("0")) {
							replaceStr += "<tr><td class='td_title' rowspan='"+incomeTimeN.getInt("rowspanCnt1")+"'>"+incomeTimeN.get("codeName1")+"</td>"
					                  + "<td class='td_type' style='text-align: center;'>"+incomeTimeN.get("codeName2")+"</td>"
					                  + "<td class='td_type_right'>"+incomeTimeN.get("itemAmount")+"</td></tr>";
						} else {
							replaceStr += "<tr><td class='td_title' rowspan='"+incomeTimeN.getInt("rowspanCnt1")+"'>"+incomeTimeN.get("codeName1")+"</td>"
					                  + "<td class='td_type' style='text-align: center;'>&nbsp;</td>"
					                  + "<td class='td_type_right'>&nbsp;</td></tr>";
						}
					}
					if (incomeTimeN.getString("code1").equals("FA") && !incomeTimeN.getString("rank1").equals("1")) {
						if (!incomeTimeN.getString("itemAmount").equals("0")) {
							replaceStr += "<tr><td class='td_type' style='text-align: center;'>"+incomeTimeN.get("codeName2")+"</td>"
					                  + "<td class='td_type_right'>"+incomeTimeN.get("itemAmount")+"</td></tr>";
						} else {
							replaceStr += "<tr><td class='td_type' style='text-align: center;'>&nbsp;</td>"
					                  + "<td class='td_type_right'>&nbsp;</td></tr>";
						}
					}
					int rowNum = rowPay - rowAllw - 1;
					
					if (incomeTimeN.getString("code1").equals("ETC_INCOME") && incomeTimeN.getString("rank1").equals("1")) {
						rowOther = incomeTimeN.getInt("rowspanCnt1");
						if (!incomeTimeN.getString("itemAmount").equals("0")) {
							replaceStr += "<tr><td class='td_title' rowspan='"+rowNum+"'>"+incomeTimeN.get("codeName1")+"</td>"
					                  + "<td class='td_type' style='text-align: center;'>"+incomeTimeN.get("codeName2")+"</td>"
					                  + "<td class='td_type_right'>"+incomeTimeN.get("itemAmount")+"</td></tr>";
						} else {
							replaceStr += "<tr><td class='td_title' rowspan='"+rowNum+"'>"+incomeTimeN.get("codeName1")+"</td>"
					                  + "<td class='td_type' style='text-align: center;'>&nbsp;</td>"
					                  + "<td class='td_type_right'>&nbsp;</td></tr>";
						}
					}
					if (incomeTimeN.getString("code1").equals("ETC_INCOME") && !incomeTimeN.getString("rank1").equals("1")) {
						if (!incomeTimeN.getString("itemAmount").equals("0")) {
							replaceStr += "<tr><td class='td_type' style='text-align: center;'>"+incomeTimeN.get("codeName2")+"</td>"
					                  + "<td class='td_type_right'>"+incomeTimeN.get("itemAmount")+"</td></tr>";
						} else {
							replaceStr += "<tr><td class='td_type' style='text-align: center;'>&nbsp;</td>"
					                  + "<td class='td_type_right'>&nbsp;</td></tr>";
						}
					}
				}
				if (rowPay - rowAllw - rowOther - 1 > 0) {
					for (int i = 0; i< rowPay - rowAllw - rowOther - 1; i++) {
						replaceStr += "<tr><td class='td_type' style='text-align: center;'>&nbsp;</td>"
				                  + "<td class='td_type_right'>&nbsp;</td></tr>";
					}
				}
				result = result.replace("[SALARY_ALLOWANCE]", replaceStr);
				//Add overtime
				replaceStr = "";
				for(LGCOMData incomeTimeY: incomeTimeYList){
					if (incomeTimeY.getString("code1").equals("NT") || incomeTimeY.getString("code1").equals("ET")) {
						if (!incomeTimeY.getString("itemAmount").equals("0")) {
							replaceStr += "<tr><td class='td_title' width='100px'>"+incomeTimeY.get("codeName1")+"</td>"
					                  + "<td class='td_type' width='35px' style='text-align: center;'>"+incomeTimeY.get("codeName2")+"</td>"
					                  + "<td class='td_type_right' width='45px' >"+incomeTimeY.get("itemHours")+"</td>"
					                  + "<td class='td_type_right' width='60px'>"+incomeTimeY.get("itemAmount")+"</td></tr>";
						} else {
							replaceStr += "<tr><td class='td_title' width='100px'>"+incomeTimeY.get("codeName1")+"</td>"
					                  + "<td class='td_type' width='35px' style='text-align: center;'>"+incomeTimeY.get("codeName2")+"</td>"
					                  + "<td class='td_type_right' width='45px' >&nbsp;</td>"
					                  + "<td class='td_type_right' width='60px'>&nbsp;</td></tr>";
						}
					}
					if (incomeTimeY.getString("code1").equals("OT") && incomeTimeY.getString("rank1").equals("1")) {
						if (!incomeTimeY.getString("itemAmount").equals("0")) {
							replaceStr += "<tr><td class='td_title' rowspan='"+incomeTimeY.getInt("rowspanCnt1")+"'>"+incomeTimeY.get("codeName1")+"</td>"
					                  + "<td class='td_type' style='text-align: center;'>"+incomeTimeY.get("codeName2")+"</td>"
					                  + "<td class='td_type_right'>"+incomeTimeY.get("itemHours")+"</td>"
					                  + "<td class='td_type_right'>"+incomeTimeY.get("itemAmount")+"</td></tr>";
						} else {
							replaceStr += "<tr><td class='td_title' rowspan='"+incomeTimeY.getInt("rowspanCnt1")+"'>"+incomeTimeY.get("codeName1")+"</td>"
					                  + "<td class='td_type' style='text-align: center;'>"+incomeTimeY.get("codeName2")+"</td>"
					                  + "<td class='td_type_right'>&nbsp;</td>"
					                  + "<td class='td_type_right'>&nbsp;</td></tr>";
						}
					}
					if (incomeTimeY.getString("code1").equals("OT") && !incomeTimeY.getString("rank1").equals("1")) {
						if (!incomeTimeY.getString("itemAmount").equals("0")) {
							replaceStr += "<tr><td class='td_type' style='text-align: center;'>"+incomeTimeY.get("codeName2")+"</td>"
					                  + "<td class='td_type_right'>"+incomeTimeY.get("itemHours")+"</td>"
					                  + "<td class='td_type_right'>"+incomeTimeY.get("itemAmount")+"</td></tr>";
						} else {
							replaceStr += "<tr><td class='td_type' style='text-align: center;'>"+incomeTimeY.get("codeName2")+"</td>"
					                  + "<td class='td_type_right'>&nbsp;</td>"
					                  + "<td class='td_type_right'>&nbsp;</td></tr>";
						}
					}
					//int rowNum = rowPay - 5;
					if (incomeTimeY.getString("code1").equals("OTNT") && incomeTimeY.getString("rank1").equals("1")) {
						if (!incomeTimeY.getString("itemAmount").equals("0")) {
							replaceStr += "<tr><td class='td_title' rowspan='"+incomeTimeY.getInt("rowspanCnt1")+"'>"+incomeTimeY.get("codeName1")+"</td>"
					                  + "<td class='td_type' style='text-align: center;'>"+incomeTimeY.get("codeName2")+"</td>"
					                  + "<td class='td_type_right'>"+incomeTimeY.get("itemHours")+"</td>"
					                  + "<td class='td_type_right'>"+incomeTimeY.get("itemAmount")+"</td></tr>";
						} else {
							replaceStr += "<tr><td class='td_title' rowspan='"+incomeTimeY.getInt("rowspanCnt1")+"'>"+incomeTimeY.get("codeName1")+"</td>"
					                  + "<td class='td_type' style='text-align: center;'>"+incomeTimeY.get("codeName2")+"</td>"
					                  + "<td class='td_type_right'>&nbsp;</td>"
					                  + "<td class='td_type_right'>&nbsp;</td></tr>";
						}
					}
					if (incomeTimeY.getString("code1").equals("OTNT") && !incomeTimeY.getString("rank1").equals("1")) {
						if (!incomeTimeY.getString("itemAmount").equals("0")) {
							replaceStr += "<tr><td class='td_type' style='text-align: center;'>"+incomeTimeY.get("codeName2")+"</td>"
					                  + "<td class='td_type_right'>"+incomeTimeY.get("itemHours")+"</td>"
					                  + "<td class='td_type_right'>"+incomeTimeY.get("itemAmount")+"</td></tr>";
						} else {
							replaceStr += "<tr><td class='td_type' style='text-align: center;'>"+incomeTimeY.get("codeName2")+"</td>"
					                  + "<td class='td_type_right'>&nbsp;</td>"
					                  + "<td class='td_type_right'>&nbsp;</td></tr>";
						}
					}
				}
				if (rowPay - 9 > 0) {
					for (int i = 0; i< rowPay - 9; i++) {
						replaceStr += "<tr><td class='td_type'>&nbsp;</td>"
								  + "<td class='td_type'>&nbsp;</td>"
								  + "<td class='td_type'>&nbsp;</td>"
				                  + "<td class='td_type_right'>&nbsp;</td></tr>";
					}
				}
				result = result.replace("[SALARY_OT]", replaceStr);
				
				//Add Deduction
				int rAttendance = 0;
				int rOther = 0;
				int rInsurance = 0;
				replaceStr = "";
				for(LGCOMData deduction: deductionList){
					//Atendance
					if (deduction.getString("code1").equals("ATT_DED") && deduction.getString("rank1").equals("1")) {
						rAttendance = deduction.getInt("rowspanCnt1");
						if (!deduction.getString("itemAmount").equals("0")) {
							replaceStr += "<tr><td class='td_title' width='55px' rowspan='"+deduction.getInt("rowspanCnt1")+"'>"+deduction.get("codeName1")+"</td>"
					                  + "<td class='td_type' width='160px' style='text-align: center;'>"+deduction.get("codeName2")+"</td>"
					                  + "<td class='td_type_right' width='65px'>"+deduction.get("itemAmount")+"</td></tr>";
						} else {
							replaceStr += "<tr><td class='td_title' width='55px' rowspan='"+deduction.getInt("rowspanCnt1")+"'>"+deduction.get("codeName1")+"</td>"
					                  + "<td class='td_type' width='160px' style='text-align: center;'>&nbsp;</td>"
					                  + "<td class='td_type_right' width='65px'>&nbsp;</td></tr>";
						}
					}
					if (deduction.getString("code1").equals("ATT_DED") && !deduction.getString("rank1").equals("1")) {
						if (!deduction.getString("itemAmount").equals("0")) {
							replaceStr += "<tr><td class='td_type' style='text-align: center;'>"+deduction.get("codeName2")+"</td>"
					                  + "<td class='td_type_right'>"+deduction.get("itemAmount")+"</td></tr>";
						} else {
							replaceStr += "<tr><td class='td_type' style='text-align: center;'>&nbsp;</td>"
					                  + "<td class='td_type_right'>&nbsp;</td></tr>";
						}
					}
					//Other
					if (deduction.getString("code1").equals("ETC_DED") && deduction.getString("rank1").equals("1")) {
						rOther = deduction.getInt("rowspanCnt1");
						if (!deduction.getString("itemAmount").equals("0")) {
							replaceStr += "<tr><td class='td_title' rowspan='"+deduction.getInt("rowspanCnt1")+"'>"+deduction.get("codeName1")+"</td>"
					                  + "<td class='td_type' style='text-align: center;'>"+deduction.get("codeName2")+"</td>"
					                  + "<td class='td_type_right'>"+deduction.get("itemAmount")+"</td></tr>";
						} else {
							replaceStr += "<tr><td class='td_title' rowspan='"+deduction.getInt("rowspanCnt1")+"'>"+deduction.get("codeName1")+"</td>"
					                  + "<td class='td_type' style='text-align: center;'>&nbsp;</td>"
					                  + "<td class='td_type_right'>&nbsp;</td></tr>";
						}
					}
					if (deduction.getString("code1").equals("ETC_DED") && !deduction.getString("rank1").equals("1")) {
						if (!deduction.getString("itemAmount").equals("0")) {
							replaceStr += "<tr><td class='td_type' style='text-align: center;'>"+deduction.get("codeName2")+"</td>"
					                  + "<td class='td_type_right'>"+deduction.get("itemAmount")+"</td></tr>";
						} else {
							replaceStr += "<tr><td class='td_type' style='text-align: center;'>&nbsp;</td>"
					                  + "<td class='td_type_right'>&nbsp;</td></tr>";
						}
					}
					//Insurance
					int rowspan = rowPay - rAttendance - rOther;
					if (deduction.getString("code1").equals("CONT_PIT") && deduction.getString("rank1").equals("1")) {
						rInsurance = deduction.getInt("rowspanCnt1");
						replaceStr += "<tr><td class='td_title' rowspan='"+rowspan+"'>"+deduction.get("codeName1")+"</td>"
				                  + "<td class='td_type' style='text-align: center;'>"+deduction.get("codeName2")+"</td>"
				                  + "<td class='td_type_right'>"+deduction.get("itemAmount")+"</td></tr>";
					}
					if (deduction.getString("code1").equals("CONT_PIT") && !deduction.getString("rank1").equals("1")) {
						replaceStr += "<tr><td class='td_type' style='text-align: center;'>"+deduction.get("codeName2")+"</td>"
				                  + "<td class='td_type_right'>"+deduction.get("itemAmount")+"</td></tr>";
					}
				}
				if (rowPay - rAttendance - rOther - rInsurance> 0) {
					for (int i = 0; i< rowPay - rAttendance - rOther - rInsurance; i++) {
						replaceStr += "<tr><td class='td_type'>&nbsp;</td>"
				                  + "<td class='td_type_right'>&nbsp;</td></tr>";
					}
				}
				result = result.replace("[SALARY_DEDUCTION]", replaceStr);
				
				//HMT_20251010 Other Income Input
				//etc - adjustment 리스트
				param.set( "payMonth", payMonth );
	        	List<LGCOMData> otherIncomeInputList = this.commonDao.selectList("LGVPAY00026.retrieveOtherIncomeInputList", param);
				replaceStr = "";
				if (otherIncomeInputList.size() > 1) {
					for(LGCOMData otherIncomeInput: otherIncomeInputList){
						replaceStr += "<tr><td class='td_type' width='160px' style='text-align: center;'>"+otherIncomeInput.get("remark")+"</td>"
				                  + "<td class='td_type_right' width='60px'>"+otherIncomeInput.get("payment")+"</td>"
				                  + "<td class='td_type' width='80px' style='text-align: center;'>"+otherIncomeInput.get("apNumber")+"</td>"
				                  + "<td class='td_type' width='60px' style='text-align: center;'>"+otherIncomeInput.get("picId")+"</td>"
				                  + "<td class='td_type' width='100px' style='text-align: center;'>"+otherIncomeInput.get("picName")+"</td></tr>";
					}
				}
				result = result.replace("[OTHER_INCOM_INPUT]", replaceStr);
				
				//Total
				result = result.replace("[SALARY_TOTAL_AMOUNT]", salaryDetailData.get("salaryTotalAmount")==null?"":salaryDetailData.get("salaryTotalAmount")+"");
				result = result.replace("[DEDUCTION_TOTAL_AMOUNT]", salaryDetailData.get("deductionTotalAmount")==null?"":salaryDetailData.get("deductionTotalAmount")+"");
				result = result.replace("[BANK_TRANSFER_AMOUNT]", salaryDetailData.get("bankTransferAmount")==null?"":salaryDetailData.get("bankTransferAmount")+"");
				
				//Employee's Attendace Month
				replaceStr = "";
				param.set( "payMonth", payMonth );
				List<LGCOMData> attendanceList = this.commonDao.selectList("LGVPAY00026.retrievePaySlipAttendanceList", param);
				for(LGCOMData attendanceN: attendanceList){
					replaceStr += "<tr><td class='td_type' style='text-align: center;'>"+attendanceN.get("attendanceYmd")+"</td>" //Date
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceN.get("vietWeekName")+"</td>" //Week
			                  + "<td class='td_type' style='text-align: left;'>"+attendanceN.get("attendanceName")+"</td>" //Attendance type
			                  //+ "<td class='td_type' style='text-align: left;'>"+attendanceN.get("attendanceDetailName")+"</td>" //Attendance detail
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceN.get("actualShiftCode")+"</td>" // Shift
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceN.get("actualStartTm")+"</td>" // Begin time
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceN.get("weekday")+"</td>"
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceN.get("weekdayHoliday")+"</td>"
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceN.get("publicHoliday")+"</td>"
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceN.get("atNightWeekday")+"</td>"
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceN.get("atNightWeekdayAfterOT")+"</td>"
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceN.get("atNightWeekdayHoliday")+"</td>"
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceN.get("atNightPublicHoliday")+"</td>"
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceN.get("specialOT")+"</td>"
			                  //+ "<td class='td_type' style='text-align: center;'>"+attendanceN.get("totalOt")+"</td>" // Total OT
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceN.get("nightNormal")+"</td>" // Night Work
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceN.get("deductionLateness")+"</td>" // Late
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceN.get("deductionLeavingEarly")+"</td>" // Early
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceN.get("deductionGoingOut")+"</td>" // Go out
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceN.get("deductionSubTotal")+"</td></tr>"; // Total deduction
					
				}
				result = result.replace("[ATENDANCE_MONTH]", replaceStr);
				
				replaceStr = "";
				param.set( "payMonth", payMonth );
				String yearOtTotal = "";
				List<LGCOMData> attendanceTotalList = this.commonDao.selectList("LGVPAY00026.retrievePaySlipAttendanceTottalList", param);
				for(LGCOMData attendanceTotal: attendanceTotalList){
					replaceStr += "<tr><td class='td_type' colspan='5' style='text-align: center;'>TỔNG</td>" //Date
							+ "<td class='td_type' style='text-align: center;'>"+attendanceTotal.get("weekday")+"</td>"
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceTotal.get("weekdayHoliday")+"</td>"
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceTotal.get("publicHoliday")+"</td>"
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceTotal.get("atNightWeekday")+"</td>"
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceTotal.get("atNightWeekdayAfterOT")+"</td>"
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceTotal.get("atNightWeekdayHoliday")+"</td>"
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceTotal.get("atNightPublicHoliday")+"</td>"
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceTotal.get("specialOT")+"</td>"
			                  //+ "<td class='td_type' style='text-align: center;'>"+attendanceN.get("totalOt")+"</td>" // Total OT
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceTotal.get("nightNormal")+"</td>" // Night Work
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceTotal.get("deductionLateness")+"</td>" // Late
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceTotal.get("deductionLeavingEarly")+"</td>" // Early
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceTotal.get("deductionGoingOut")+"</td>" // Go out
			                  + "<td class='td_type' style='text-align: center;'>"+attendanceTotal.get("deductionSubTotal")+"</td></tr>"; // Total deduction
					
					yearOtTotal = attendanceTotal.getString("yearOtTotal");
					
				}
				result = result.replace("[ATENDANCE_TOTAL_MONTH]", replaceStr);
				result = result.replace("[YEAR_OT_TOTAL]", yearOtTotal==null?"":yearOtTotal+"");
				
			    /*特殊字符设置*/
				result = result.replace("&", "&amp;");
				result = result.replace("&amp;nbsp;", "&nbsp;");
				
				String empID = empEmail.getString("employeeNo");
				String payID = empEmail.getString("payrollCalculationExecId");
				String waterMark = empEmail.getString("employeeNo") +"/"+empEmail.getString("employeeName");
				String outFile = outputFile.replace("paySlip", empID+"_"+payID);
				
				OutputStream os = new FileOutputStream(outputFile.replace("paySlip", empID+"_"+payID));     
		        
				ITextRenderer renderer = new ITextRenderer();
		        renderer.setDocumentFromString(result);
		        
		        // 解决越南语支持问题     
		        ITextFontResolver fontResolver = renderer.getFontResolver();    
		        fontResolver.addFont(filepath.replace("\\", "/")+"/"+"times.TTF", BaseFont.IDENTITY_H, BaseFont.EMBEDDED);     
		        //解决图片的相对路径问题 
		        renderer.getSharedContext().setBaseURL("file:/"+basePath.replace("\\", "/")+"/");
		        //System.out.print("file:/"+basePath.replace("\\", "/")+"/");
		        renderer.layout();    
		        renderer.createPDF(os);  
		
		        os.flush();
				os.close();
				
				//Add Wartermark
				this.addWarterMarkPDF(outFile, waterMark, payID);
				//Add password
				this.addPasswordPDF(outFile, empID, payID, adminPassWord);
				
				//String payMonth   = param.getString("payMonth");
				LGCOMData errorData = new LGCOMData();
				errorData.set("payrollCalculationExecId", payID);
				errorData.set("employeeNo", empID);
				errorData.set("payFlag", "Y");
				errorData.set("payError", "");
				errorData.set("payType", "CREATE");
				errorData.set("payMonth", payMonth);
				//this.commonDao.update("LGVPAY00026.updatePaySlipEmpCreateError",errorData);
				this.commonDao.select("LGVPAY00026.updateEmailEmpPKG",errorData);
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
				LGCOMData errorData = new LGCOMData();
				errorData.set("payrollCalculationExecId", empEmail.getString("payrollCalculationExecId"));
				errorData.set("employeeNo", empEmail.getString("employeeNo"));
				errorData.set("payFlag", "N");
				errorData.set("payError", "Fail to create payslip");
				errorData.set("payType", "CREATE");
				errorData.set("payMonth", payMonth);
				//this.commonDao.update("LGVPAY00026.updatePaySlipEmpCreateError",errorData);
				this.commonDao.select("LGVPAY00026.updateEmailEmpPKG",errorData);
			}
		}
			if (part.size() == fileSplit) {
				//Thread.sleep(30000);
				break;
			}
		}	
	}
	
	public void addWarterMarkPDF(String outFile, String empID, String payDate) throws FileNotFoundException, IOException, DocumentException {
		
		Float a = (float) 297;//Float.parseFloat((String) paramMap.get("A"));
		Float b = (float) 450;//Float.parseFloat((String) paramMap.get("B"));
		Float c = (float) 30;//Float.parseFloat((String) paramMap.get("C"));
        InputStream outputFile = new FileInputStream(outFile);     
        OutputStream destFile = new FileOutputStream(outFile.replace(".pdf", "_waterMark.pdf"));     
        
        PdfReader reader = new PdfReader(outputFile);
    	PdfStamper stamper = new PdfStamper(reader, destFile);
    	int pageNo = reader.getNumberOfPages();
    	Font font = new Font(Font.HELVETICA, 15);
        Phrase phrase = new Phrase(empID+"   "+empID+"   "+empID+"   "+empID+"   "+empID+"   "+empID+"   "+empID+"   "+empID+"   "+empID+"   "+empID+" ", font);
    	for (int i=1;i<=pageNo;i++) {
    		PdfContentByte over = stamper.getOverContent(i);
    		over.saveState();
    		PdfGState gs1 = new PdfGState();
    		gs1.setFillOpacity(0.1f);
    		over.setGState(gs1);
    		ColumnText.showTextAligned(over, Element.ALIGN_CENTER, phrase, a+600, b, c);
    		ColumnText.showTextAligned(over, Element.ALIGN_CENTER, phrase, a+400, b, c);
    		ColumnText.showTextAligned(over, Element.ALIGN_CENTER, phrase, a+200, b, c);
    		ColumnText.showTextAligned(over, Element.ALIGN_CENTER, phrase, a, b, c);
    		ColumnText.showTextAligned(over, Element.ALIGN_CENTER, phrase, a-200, b, c);
    		ColumnText.showTextAligned(over, Element.ALIGN_CENTER, phrase, a-400, b, c);
    		ColumnText.showTextAligned(over, Element.ALIGN_CENTER, phrase, a-600, b, c);
    		over.restoreState();
    	}
    	stamper.close();
    	reader.close();
	}
	
public void addPasswordPDF(String outFile, String empID, String payDate, String adminPassWord) throws FileNotFoundException, IOException, DocumentException {
		
        InputStream outputFile = new FileInputStream(outFile.replace(".pdf", "_waterMark.pdf"));     
        OutputStream destFile = new FileOutputStream(outFile.replace(".pdf", "_password.pdf"));     
        
        PdfReader reader = new PdfReader(outputFile);
    	PdfStamper stamper = new PdfStamper(reader, destFile);
    	String pdfPassword = empID;
                String pdfAdminPassword = adminPassWord;
                stamper.setEncryption(
                        pdfPassword.getBytes(),
                        pdfAdminPassword.getBytes(),
                        PdfWriter.ALLOW_PRINTING, PdfWriter.ENCRYPTION_AES_128 | PdfWriter.DO_NOT_ENCRYPT_METADATA);
    	stamper.close();
    	reader.close();
	}

}
