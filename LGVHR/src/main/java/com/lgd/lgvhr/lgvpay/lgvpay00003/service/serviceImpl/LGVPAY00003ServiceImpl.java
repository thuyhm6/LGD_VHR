/**
 *------------------------------------------------------------------------------
 * @Project : LGDisplay LGVHR Project
 * @Source  : lgvpay00003ServiceImpl.java
 * @Desc    : 개인별 급여항목 관리
 *
 * Copyright ⓒ 2017 LG Display & LG CNS All rights reserved
 *------------------------------------------------------------------------------
 *                  변         경         사         항
 *------------------------------------------------------------------------------
 *    VER   DATE        AUTHOR      DESCRIPTION
 * -----------------------------------------------------------------------------
 *  1. 0    2017. 12. 11.    bakderia    최초 프로그램 작성
 *------------------------------------------------------------------------------
 */
package com.lgd.lgvhr.lgvpay.lgvpay00003.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpay00003.service.LGVPAY00003Service;

import devonframe.util.NullUtil;

/**
 * <PRE>
 * com.lgd.lgvhr.lgvpay.lgvpay00003.controller.LGVPAY00003Controller.java
 * </PRE>
 *
 * @Author    bakderia
 * @Date      2017. 11. 17. 오전 9:00:58
 * @Version
 */
@Service(value="LGVPAY00003Service")
public class LGVPAY00003ServiceImpl implements LGVPAY00003Service {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00003ServiceImpl.class);

	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

	/**
	 * Desc : 개인별 급여항목을 조회한다.
	 * @Method Name : retrievePayRollItemEntByEmpList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrievePayRollItemEntByEmpList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVPAY00003.retrievePayRollItemEntByEmpList",param);
	}
	/**
	 * Desc : 기등록된 급여대상 SET을 조회한다.
	 * @Method Name : retrieveRegCalEmpChk
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrieveRegCalEmpChk(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData resultData = new LGCOMData();
		resultData = (LGCOMData) this.commonDao.select("LGVPAY00003.retrieveRegCalEmpChk",param);
		
		return resultData;
	}
	
	/**
	 * Desc : MULIPLE_FLAG를 조회한다.
	 * @Method Name : retrieveRegCalEmpChk
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retreiveMutiFlagCheck(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData resultData = new LGCOMData();
		resultData = (LGCOMData) this.commonDao.select("LGVPAY00003.retreiveMutiFlagCheck",param);
		
		return resultData;
	}
	
	/**
	 * Desc : PayrollApplyFlag를 조회한다.
	 * @Method Name : retrievePayrollApplyFlag
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrievePayrollApplyFlag(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData resultData = new LGCOMData();
		resultData = (LGCOMData) this.commonDao.select("LGVPAY00003.retrievePayrollApplyFlag",param);
		
		return resultData;
	}
	
	/**
	 * Desc : applyDate를 조회한다.
	 * @Method Name : retrieveApplyDate
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrieveApplyDate(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData resultData = new LGCOMData();
		resultData = (LGCOMData) this.commonDao.select("LGVPAY00003.retrieveApplyDate",param);
		
		return resultData;
	}
	
	/**
     * Desc : 개인별 급여항목을 저장한다.
     * @Method Name : saveCalSetEmp
     * @param  param
     * @throws Exception
     */
	@SuppressWarnings("unchecked")
	@Transactional(propagation=Propagation.REQUIRED)
	public void savePayrollItem(LGCOMData param) {
		LOGGER.debug("savePayrollItem param = " + param);
		
		LGCOMData masterPlanIdInfo = new LGCOMData();
		LGCOMData deatilPlanIdInfo = new LGCOMData();
		LGCOMData userSession = (LGCOMData)param.get("USER_SESSION");
		String masterPlanId = "";
		String detailPlanId = "";
		
		List<LGCOMData> insertList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_INSERT);
		List<LGCOMData> updateList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_UPDATE);
		List<LGCOMData> deleteList = (List<LGCOMData>)param.get(LGCOMConstants.STATUS_DELETE);
		
		//삭제처리
		for( LGCOMData dItem : LGCOMUtils.emptyIfNull(deleteList) ) {
			this.commonDao.delete("LGVPAY00003.deletePayrollItem",dItem);
		}
		//등록처리
		for( LGCOMData iItem : LGCOMUtils.emptyIfNull(insertList) ) {
			
			//Master 시퀀스 조회
			masterPlanIdInfo = this.commonDao.select("LGVPAY00003.retreiveMasterPaymentPlanIdSeq");
			masterPlanId = masterPlanIdInfo.getString("payrollItemPaymentPlanId");
			
			String[] applyStartDateSplit = iItem.getString("applyStartDate").split("/");
			String[] applyEndDateSplit = iItem.getString("applyEndDate").split("/");
			
			iItem.put("applyStartDate", applyStartDateSplit[2]+applyStartDateSplit[1]+applyStartDateSplit[0]);
			iItem.put("applyEndDate", applyEndDateSplit[2]+applyEndDateSplit[1]+applyEndDateSplit[0]);
			
			iItem.put("payrollItemPaymentPlanId", masterPlanId);
			iItem.put("applicationUserId", userSession.get("applicationUserId"));
			
			//Master table(TB_PAY_ITEM_PAYMENT_PLAN_N)에 등록
			this.commonDao.insert("LGVPAY00003.insertMasterPayrollItem",iItem);
			
			//Detail id값이 있는 데이터만 등록
			for(int i=1; i<= 10; i++) {
				if("Y".equals(iItem.getString("inputYn"+i))) {
					//Detail 시퀀스 조회
					deatilPlanIdInfo = this.commonDao.select("LGVPAY00003.retreiveDetailPaymentPlanIdSeq");
					detailPlanId = deatilPlanIdInfo.getString("payrollItemPayPlnDetailId");
					
					iItem.put("payrollItemPayPlnDetailId", detailPlanId);
					iItem.put("payrollItemDetailDetailId", iItem.getString("inputValueId"+i));
					if ( isNumericInputType(iItem.getString("inputType"+i)) ) {//숫자컬럼인 경우 콤마 제거
						iItem.put("applyTargetValue", iItem.getString("inputValue"+i).replaceAll(",", ""));
					} else {
						iItem.put("applyTargetValue", iItem.getString("inputValue"+i));
					}
					
					//Detail table(TB_PAY_PAYMENT_PLAN_DETAIL_N)에 등록
					this.commonDao.insert("LGVPAY00003.insertDetailPayrollItem",iItem);
				}
			}
		}
		//수정처리
		for( LGCOMData uItem : LGCOMUtils.emptyIfNull(updateList) ) {
			//Master 테이블 수정(applyEndDate 수정 시)
			for( LGCOMData umItem : LGCOMUtils.emptyIfNull(updateList) ) {
				String[] applyEndDateSplit = umItem.getString("applyEndDate").split("/");
				String applyEndDate = applyEndDateSplit[2]+applyEndDateSplit[1]+applyEndDateSplit[0];
				
				//시작일자 또는 종료일자 수정 시 마스터 테이블(tb_pay_item_payment_plan_n) 수정
				if(!umItem.getString("beforeApplyStartDate").equals(umItem.getString("applyStartDate")) 
						|| !umItem.getString("beforeApplyEndDate").equals(applyEndDate)) {
					umItem.set("applyEndDate", applyEndDate);
					umItem.set("payrollItemPaymentPlanId", umItem.getString("payrollItemPaymentPlanId"));
					umItem.set("payrollItemId", umItem.getString("payrollItemId"));
					this.commonDao.update("LGVPAY00003.updateMasterPayrollItem",umItem);
				}
			}
			
			
			for(int i=1; i<= 10; i++) {
				if("Y".equals(uItem.getString("inputYn"+i))) {
					String beforVal = NullUtil.nvl(uItem.getString("beforeValue"+i), "");
					String inputVal = NullUtil.nvl(uItem.getString("inputValue"+i), "");
					
					if(!beforVal.equals(inputVal)) {
						
						if ( isNumericInputType(uItem.getString("inputType"+i)) ) {//숫자컬럼인 경우 콤마 제거
							uItem.put("applyTargetValue", inputVal.replaceAll(",", ""));
						} else {
							uItem.put("applyTargetValue", inputVal);
						}
						
						uItem.put("payrollItemDetailDetailId", uItem.getString("inputValueId"+i));
						uItem.put("payrollItemPaymentPlanId", uItem.getString("payrollItemPaymentPlanId"));
						uItem.put("applicationUserId", userSession.get("applicationUserId"));
						
						this.commonDao.update("LGVPAY00003.updateDetailPayrollItem",uItem);
					}
				}
			}
		}
	}

    /**
	 * Desc : 입력값 유형이 숫자인지 여부를 리턴한다.
	 * @Method Name : isNumericInputType
	 * @param  inputType : A-금액, N-숫자, 그외-문자
	 * @return boolean
	 * @throws Exception
	 */
	private boolean isNumericInputType(String inputType) {
		if ( "A".equals(NullUtil.nvl(inputType, "")) || "N".equals(NullUtil.nvl(inputType, "")) ) {
			return true;
		}
		return false;
	}
    
    /**
	 * Desc : 행추가된 Detail 정보를 조회한다.
	 * @Method Name : retreiveDetailValue
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retreiveDetailValue(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData resultData = new LGCOMData();
		
		resultData = (LGCOMData) this.commonDao.select("LGVPAY00003.retreiveDetailValue",param);
		
		return resultData;
	}
    
    /**
     * Desc : 급여년월에 퇴직자인지 여부 조회한다.
     * @Method Name : retrieveRetireData
     * @param  param
     * @throws Exception
     */
    public LGCOMData retrieveRetireData(LGCOMData param) {
    	return commonDao.select("LGVPAY00003.retrieveRetireData", param);
    }
}
