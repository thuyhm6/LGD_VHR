package com.lgd.lgvhr.lgvpay.lgvpay00034.service.serviceImpl;

import java.util.List;

import javax.annotation.Resource;

import org.springframework.context.support.MessageSourceAccessor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.lgd.lgcom.common.dao.CommonDao;
import com.lgd.lgcom.common.util.LGCOMConstants;
import com.lgd.lgcom.common.util.LGCOMUtils;
import com.lgd.lgcom.framework.exception.LGCOMException;
import com.lgd.lgcom.framework.log.LGCOMLogger;
import com.lgd.lgcom.framework.log.LGCOMLoggerFactory;
import com.lgd.lgcom.framework.model.LGCOMData;
import com.lgd.lgvhr.lgvpay.lgvpay00034.service.LGVPAY00034Service;

@Service(value="LGVPAY00034Service")
public class LGVPAY00034ServiceImpl implements LGVPAY00034Service  {
	static final LGCOMLogger LOGGER = LGCOMLoggerFactory.getLogger(LGVPAY00034ServiceImpl.class);
	@Resource(name="commonDao")
	CommonDao commonDao;
	
	@Resource(name="messageSourceAccessor")
    protected MessageSourceAccessor messageSourceAccessor;

	/**
	 * Desc : Retrieve Al Summary Set Emp List.
	 * @Method Name : retrieveOtherIncomeSetEmpList
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public List<LGCOMData> retrieveAlSummaryEmpList(LGCOMData param) {
		LOGGER.debug("param = " + param);
		return this.commonDao.selectList("LGVPAY00034.retrieveAlSummaryEmpList",param);
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
        int resultCnt = this.commonDao.insert("LGVPAY00034.createExcelDownloadData",param);
        
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

    /**
	 * Desc : 행추가된 사용자 정보를 조회한다.
	 * @Method Name : retrieveEmployeeInfo
	 * @param  param
	 * @return List<?>
	 * @throws Exception
	 */
	public LGCOMData retrieveEmployeeInfo(LGCOMData param) {
		LOGGER.debug("param = " + param);
		LGCOMData resultData = new LGCOMData();
		
		resultData = (LGCOMData) this.commonDao.select("LGVPAY00034.retrieveEmployeeInfo",param);
		
		return resultData;
	}
	
	/**
     * Desc : 급여대상자 Set에 있는 퇴직자의 연차를 계산하여 보정한다. 
     * - 연차 계산 전 체크
     * 
     * @Method Name : caculateCalculateAnnualLeave
     * @param param
     * @return LGCOMData
     * @throws Exception
     */
	@Override
	@Transactional(propagation=Propagation.REQUIRED)
    public void caculateAnnualLeave(LGCOMData param) throws LGCOMException{
		LOGGER.debug("caculateAnnualLeave.param====>" + param);
		
		//퇴직자 연차 계산 및 보정
		this.commonDao.update("LGVPAY00034.caculateAnnualLeave", param);
    	
    }

}
