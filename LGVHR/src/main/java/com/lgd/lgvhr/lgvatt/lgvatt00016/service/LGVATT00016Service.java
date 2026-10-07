package com.lgd.lgvhr.lgvatt.lgvatt00016.service;

import java.util.List;

import com.lgd.lgcom.framework.model.LGCOMData;

/**
 *
 * @author ssyauu580
 *
 */
public interface LGVATT00016Service {

	/**
	 * 연차 정보 조회
	 *
	 * @param param
	 * @return
	 */
	public List<LGCOMData> retrieveAnnualLeave(LGCOMData param);

	/**
	 * 연차 정보 엑셀 다운로드
	 *
	 * @param param
	 * @return
	 */
	public List<LGCOMData> excelDownData(LGCOMData param);

	/**
	 * 연차 정보 저장
	 *
	 * @param param
	 */
	public void saveAnnualLeave(LGCOMData param);

	/**
	 * 그리드에서 체크박스로 선택된 데이터(param의 modifyList)에 대해서만 연차일수를 재계산하여
	 * TB_ATT_EMP_ANNUAL_M에 반영한다.
	 * 재계산된 연차일수는 대상월의 TB_ATT_ANNUAL_LEAVE_N.residual_annual_leave_days에 가산되고,
	 * 대상월의 전월의 TB_ATT_ANNUAL_LEAVE_N.annual_calibration_days에 가산된다.
	 *
	 * @param param
	 */
	public void recalculateAnnualLeave(LGCOMData param);

	/**
	 * 사원 구분(emp_type) 코드/명 목록 조회 (code_type_code = 'LGVHR_AL_EMP_TYPE_CODE')
	 *
	 * @param param
	 * @return
	 */
	public List<LGCOMData> retrieveEmpTypeNameList(LGCOMData param);

    public void createAnnualLeaveUpload(LGCOMData param);

}
