package com.lgd.lgvhr.lgvatt.lgvatt00031.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 * Pregnant EMP Management (임신 직원 관리)
 */
public interface LGVATT00031Service {

	/**
	 * 임신 직원 목록 조회
	 *
	 * @param param
	 * @return
	 */
	public List<LGCOMData> retrievePregnantEmp(LGCOMData param);

	/**
	 * 임신 직원 목록 엑셀 다운로드
	 *
	 * @param param
	 * @return
	 */
	public List<LGCOMData> excelDownData(LGCOMData param);

	/**
	 * 임신 직원 저장 (신규/수정/삭제)
	 *
	 * @param param
	 */
	public void savePregnantEmp(LGCOMData param);

	/**
	 * 임신 직원 엑셀 업로드
	 *
	 * @param param
	 */
	public void createPregnantEmpUpload(LGCOMData param);

}
