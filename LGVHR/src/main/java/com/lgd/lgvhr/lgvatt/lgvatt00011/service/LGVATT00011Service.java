package com.lgd.lgvhr.lgvatt.lgvatt00011.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * 
 * @author ssyauu580
 *
 */
public interface LGVATT00011Service {

	/**
	 * 비정규직 카드 정보 조회
	 * 
	 * @param param
	 * @return
	 */
	public List<LGCOMData> retrieveOSEmpIdCard(LGCOMData param);

	/**
	 * 비정규직 카드 정보 엑셀 다운로드
	 * 
	 * @param param
	 * @return
	 */
	public List<LGCOMData> excelDownData(LGCOMData param);

	/**
	 * 비정규직 카드 정보 저장
	 * 
	 * @param param
	 */
	public void saveOSEmpIdCard(LGCOMData param);
	
    public void createEmpIdCardUpload(LGCOMData param);

	/**
	 * Vendor 목록 조회 (TB_VENDOR_MASTER)
	 *
	 * @param param
	 * @return
	 */
	public List<LGCOMData> retrieveVendorList(LGCOMData param);
    
}
