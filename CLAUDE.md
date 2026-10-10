# LGD_VHR – Hệ thống HR LG Display Việt Nam (Chấm công & Tính lương)

Dự án mẫu lấy từ hệ thống nhân sự thực tế của LG Display Việt Nam. Trọng tâm nghiệp vụ là **Chấm công (T&A)** và **Tính lương (Payroll)**. Dữ liệu nhân sự gốc (nhân viên, tổ chức, hợp đồng…) chủ yếu được **nhận qua Interface/Batch** từ hệ thống HR/ERP khác, không nhập tay.

## Cấu trúc

```
LGD_VHR/
├── LGCOM/   Portal & nền tảng chung: login/SSO, menu, phân quyền, mã chung, phê duyệt, batch, mail, file
├── LGVHR/   Nghiệp vụ HR Việt Nam: lgvatt (chấm công), lgvpay (lương), lgvinf (interface), lgvcom (request/approval)
├── LGD_VHR table.sql   DDL toàn bộ bảng (250 bảng, schema VHR_MGR) – chỉ để tham khảo, không phải script migration
└── LGD_VHR Package/    Source PL/SQL package (spec + body, file .pck) trên DB
```

## Công nghệ

- Java 1.7, Maven, WAR. Tomcat (local/dev), JEUS (prod).
- Spring MVC 4 + DevOn Frame (LG CNS) + **wcfw-framework** (`com.lgd.lgcom.framework.*`, jar nội bộ, không có trong repo; repository nội bộ LG phải truy cập được thì mới build được).
- MyBatis qua `CommonDao`, Oracle, DataSource JNDI `java:comp/env/jdbc/lgcom`.
- Frontend: JSP + jQuery + Bootstrap + **RealGrid** + các lớp JS của framework (`BizForm`, `FormUtil`, `RealGrid`, `Popup`, `CommonCode`, `ValueSet`, `Downloader`, `Message`, `DateUtil`).
- Ehcache (cache menu/mã), Spring Session Redis, Quartz, WebSocket.
- Config theo môi trường: file gốc = local, các bản `*_dev` / `*_prod` đi kèm (`pom_dev.xml`, `context-datasource.xml_prod`, `web.xml_prod`…). Khi sửa config phải cân nhắc sửa cả 3 bản.

## Quy ước đặt tên (BẮT BUỘC)

Mỗi màn hình có một Program ID, ví dụ `LGVATT00010` = `LG` + `V`(Vietnam) + `ATT`(phân hệ) + số. Cùng một ID được dùng ở cả 3 tầng:

| Tầng | Đường dẫn | Ví dụ |
|---|---|---|
| JSP | `LGVHR/src/main/webapp/WEB-INF/views/{module}/{ID}.jsp` | `views/lgvatt/LGVATT00010.jsp` |
| Service interface | `com.lgd.lgvhr.{module}.{id thường}.service.{ID}Service` | `lgvatt/lgvatt00010/service/LGVATT00010Service.java` |
| Service impl | `...service.serviceImpl.{ID}ServiceImpl` với `@Service(value="{ID}Service")` | `LGVATT00010ServiceImpl.java` |
| SQL (MyBatis) | `LGVHR/src/main/resources/sql/oracle/{module}/sql-{id thường}.xml`, `<mapper namespace="{ID}">` | `sql/oracle/lgvatt/sql-lgvatt00010.xml` |

- Tên package/thư mục/file SQL viết **thường** (`lgvatt00010`), tên class/JSP/namespace viết **HOA** (`LGVATT00010`).
- Tên method trong Service = tên segment cuối của URL gọi từ JSP = (thường) id của câu SQL.
- Hậu tố ID: số thường là màn hình chính; `P` là popup (`LGVPAYP0001`); `Q` là Dynamic Query; `C` là batch/service chung (`lgvpayc0013`); `COMM` là SQL/service dùng chung của phân hệ (`LGVATTCOMM`, `lgvpaycomm`).
- LGCOM theo đúng quy ước này với package `com.lgd.lgcom.*` (`lgsysc`, `lgsetc`, `lgutlc`, `lgbatc`, `lgsmpc`).

## Luồng xử lý

```
Menu: /container?menuId=M_XXX → LGCOMExtController → main/container.jsp → nạp {ID}.jsp (tab MDI)
JSP : grid.loadData('lgvhr', 'lgvatt/LGVATT00010/retrieveIdCardHis', param, callback)
   → POST /action/lgvatt/LGVATT00010/retrieveIdCardHis
   → Interceptors: Authentication → ProjectSession → Authorization → ServiceTimeLog → Security
   → Controller chung (trong framework) gọi bean "LGVATT00010Service".retrieveIdCardHis(LGCOMData)
   → commonDao.selectList("LGVATT00010.retrieveIdCardHis", param)
   → JSON trả về → RealGrid hiển thị
```

- `LGCOMData` là kiểu Map dùng chung cho tham số và kết quả. Alias cột SQL viết snake_case (`AS employee_no`) và được map sang camelCase (`employeeNo`), khớp với `fieldName` của RealGrid.
- Thông tin session dùng trực tiếp trong SQL: `#{LGVHR_PROJECT_SESSION.subsidiaryCode}`, `#{LGVHR_PROJECT_SESSION.employeeNo}`. Trong JSP dùng `${sessionScope.LGVHR_PROJECT_SESSION.xxx}` hoặc `SESSION_USER`.
- `CommonDao`: `selectList`, `select`, `insert`, `update`, `delete` với key `"{NAMESPACE}.{sqlId}"`.

## Mẫu code

**Tra cứu**: Service trả về `List<LGCOMData>`. JSP gọi `grid.loadData(...)`.

**Lưu từ grid**: JSP gọi `grid.saveChanges('lgvhr', url, param, cb)`. Service xử lý như sau:
```java
List<LGCOMData> insertData = param.getList(LGCOMConstants.STATUS_INSERT);
List<LGCOMData> updateData = param.getList(LGCOMConstants.STATUS_UPDATE);
List<LGCOMData> deleteData = param.getList(LGCOMConstants.STATUS_DELETE);
// lặp và gọi commonDao.insert/update/delete; method nhiều bước dùng @Transactional(propagation=Propagation.REQUIRED)
```
Tham khảo: `lgvatt/lgvatt20030/.../LGVATT20030ServiceImpl.java`.

**Xuất Excel**: JSP dùng `new Downloader(myForm).excel('lgvhr', '{module}/{ID}/excelDownData', param)`. Service sinh `sessionId = LGCOMUtils.getRandomNumber()`, insert dữ liệu vào bảng tạm rồi trả về `resultCnt` và `sessionId`. Tham khảo `LGVATT00010ServiceImpl.excelDownData`.

**Cấu trúc JSP chuẩn** (xem `LGVATT00010.jsp`):
- Include `/WEB-INF/views/framework/bizFormHeader.jsp` và taglib `lgcom` (`/WEB-INF/tags/lgcomTag.tld`).
- `var {ID} = function(){...}; {ID}.prototype = new BizForm("${param.bizFormId}");` khởi tạo trong `launch(function(){ new {ID}().init(); })`.
- Gọi `myForm.setLayout([...])` cho các vùng `searchBlock` / `gridControls` / `content1`.
- Tạo combo bằng `new CommonCode('lgcom')` + `codeTypeCode` hoặc `new ValueSet('lgcom')` + `valueSetId`, rồi gọi `formUtil.initCombo(...)`.
- Grid tạo bằng `new RealGrid(myForm, gridId, true)` → `setOptions` → `setFields` → `setColumns`.
- Nút bấm dùng `data-action="..."`, xử lý trong `this.addEvent("click", "button[data-action]", ...)` với `switch(action)`.
- Text đa ngôn ngữ dùng `<lgcom:message code="..."/>`. Ngày dùng định dạng `DD/MM/YYYY`.
- Popup: `new Popup(_this, 'lgvhr', '{MENU_ID}', title)`, truyền dữ liệu qua `myForm.popupInfo`.

## Tạo màn hình mới – checklist

1. `views/{module}/{ID}.jsp`
2. `{module}/{id}/service/{ID}Service.java` + `serviceImpl/{ID}ServiceImpl.java` (`@Service(value="{ID}Service")`, inject `@Resource(name="commonDao") CommonDao commonDao`)
3. `sql/oracle/{module}/sql-{id}.xml` với `namespace="{ID}"`. Mapper được nạp tự động theo pattern `classpath:/sql/oracle/**/sql-*.xml`.
4. Đăng ký menu/program và quyền trong DB (màn hình quản trị LGCOM `lgsysc`). Menu được cache bằng Ehcache.

## Các phân hệ LGVHR

- **lgvatt**: lịch sử quẹt thẻ ID, đăng ký/sửa chấm công Office/Line Worker, shift group, đổi ca, OT (đăng ký, OT level, giới hạn năm, Special OT), nghỉ phép năm, đổi ngày nghỉ tuần, Multiple plan, Long term, báo cáo T&A tháng.
- **lgvpay**: Payroll Item, Formula, Aggregate, User Defined Table, đối tượng hưởng lương, Payroll Run / Retroactive Run (`lgvpayc0013`, `lgvpayc0014`), Payment Master, PaySlip (in/gửi/ngày mở), trợ cấp thôi việc, quyết toán phép cho người nghỉ việc, lương outsourcing, Global Value.
- **lgvinf**: các batch nhận I/F gồm mã, tổ chức, nhân sự, HR master, bổ nhiệm, gia đình, bằng cấp, hợp đồng, bậc lương, quyền mặc định, thuế từ ERP.
- **lgvcom**: My Request / My Approval (phê duyệt), popup tìm nhân viên (`M_LGVCOM_1010`), mail chung, mã hóa AES256.

## Database (Oracle, schema `VHR_MGR`)

### Bảng – `LGD_VHR table.sql`

File chỉ có `CREATE TABLE` + PK constraint (không có comment cột, index, sequence, view). Tra cứu cột: `grep -A60 'CREATE TABLE "TÊN_BẢNG"' "LGD_VHR table.sql"`.

Hậu tố tên bảng: `_M` master, `_N` dữ liệu nghiệp vụ, `_C` mã, `_I` interface nhận về, `_T` bảng tạm, `_S` summary/snapshot, `_H` lịch sử. Cột audit chuẩn: `CREATION_USER_ID`, `CREATION_DATE`, `LAST_UPDATE_USER_ID`, `LAST_UPDATE_DATE`. Hầu hết bảng nghiệp vụ có `SUBSIDIARY_CODE`.

| Nhóm | Prefix | Bảng chính |
|---|---|---|
| Chấm công | `TB_ATT_*` | `TB_ATT_PLAN_N` (kế hoạch), `TB_ATT_RESULT_N` / `_H` (kết quả), `TB_ATT_UPDATE_REQ_N` (yêu cầu sửa), `TB_ATT_CODE_C`, `TB_ATT_CALENDAR_N`, `TB_ATT_CLOSE_N`, `TB_ATT_BASE_BAS_N`, `TB_ATT_CONTRACT_N`, `TB_ATT_ANNUAL_LEAVE_N`, `TB_ATT_EMP_ANNUAL_M`, `TB_ATT_IDCARD_ACS_TIME_N`, `TB_ATT_EMP_IDCARD_M`, `TB_ATT_OT_LEVEL*`, `TB_ATT_OT_VALIDATION_N`, `TB_ATT_SPECIAL_OT_RESULT_N`, `TB_ATT_SWAP_HOLIDAY_REQUEST_N`, `TB_ATT_LT_TIME_ATTEND_PLAN_N`, `TB_ATT_HOLIDAY_INFO_N`, `TB_ATT_DAILY_REPORT_S` |
| Lương | `TB_PAY_*`, `TB_RETRO_*` | `TB_PAY_PAYROLL_ITEM_M`, `TB_PAY_ITEM_*` (detail, aggregate, payment plan), `TB_PAY_CALC_*` (set, formula, var, period, exec, result, error), `TB_PAY_RESULT_S`, `TB_PAY_USER_DFIN_TABLE_*` (UDT), `TB_PAY_EMP_*` (hợp đồng, gia đình, bậc, chứng chỉ, thu nhập khác), `TB_PAY_PAID_LEAVE_*`, `TB_PAY_SEVERANCE_ALLOWANCE`, `TB_PAY_SLIP_SEND_N`, `TB_PAY_KPI_*OS*` (outsourcing), `TB_RETRO_*` (truy lĩnh) |
| Nhân sự / tổ chức (nhận I/F) | — | `EMP_MASTER`, `EMP_ASSIG`, `EMP_INFO`, `ORG_MASTER`, `SHIFT_CODE`, `CURRENCY`, `INSURANCE`, `LGCOM_ORGANIZATION_M`, `LGCOM_EHR_R_EMPLOYEE` |
| Interface staging | `TB_INTF_*`, `TB_IFR_*`, `XVH_*_IF`, `XXHR_*` | dữ liệu thô nhận từ EAI/ERP trước khi batch `lgvinf` đổ vào bảng chính |
| Nền tảng LGCOM | `LGCOM_*` | user/role/menu/program (`LGCOM_USER_M`, `LGCOM_ROLE_M`, `LGCOM_MENU_M`, `LGCOM_PROGRAM_M`, `*_N` quan hệ), mã chung (`LGCOM_CODE_TYPE_CODE_C`, `LGCOM_COMMON_CODE_C`, `_MULTI_LANG_C`), phê duyệt (`LGCOM_APPROVAL_*`, `TB_ACPT_*`), batch, mail, board, log, message/label đa ngôn ngữ |
| Dynamic Query | `XXLGE_QUERY*`, `XXLGE_DQ_USE_T` | dùng cho màn hình hậu tố `Q` |

Không dùng làm mẫu: bảng backup/tạm (`*_BK_0618`, `*_ORG_0612`, `*_BAK`, `*_TMP`, `TOAD_PLAN_TABLE`) và các bảng legacy không còn được SQL/package nào tham chiếu (`ACCOUNT*`, `APPLICATION*`, `ATT_*` không có prefix `TB_`, `PAY_INVOICE*`, `WAGE_MASTER`, `TB_DEPARTMENT`, `TB_DIVISION*`…).

### Package PL/SQL – `LGD_VHR Package/`

| Package | Vai trò | Hàm hay được gọi từ SQL mapper |
|---|---|---|
| `lgvhr_common_pkg` | Tiện ích chung HR | `decode_lookup` (giải mã code → tên, dùng nhiều nhất), `decode_message`, `get_shift_type_code_func`, `get_org_resp_flag_func`, `get_emp_master_rec`, `get_organization_name_func` |
| `lgvhr_transaction_pkg` | Gửi mail | `send_mail`, `send_mail_clob` |
| `lgvatt_common_pkg` | Tra cứu chấm công | `get_idcard_inout_time`, `get_approval_status`, `get_att_close_time`, `get_holiday_flag`, `get_input_date`, `get_att_code_info`, `get_shift_inout_time`, `get_curr_att_yyyymm`, `get_unit_requestor`, `get_*_rec` |
| `lgvatt_transaction_pkg` | Ghi dữ liệu chấm công, xử lý sau phê duyệt | `apply_att_*_record`, `apply_att_result_approval`, `apply_att_update_req_approval`, `apply_att_swap_wh_approval`, `apply_att_result_ot_calc` |
| `lgvatt_batch_pkg` | Batch chấm công | `create_att_calendar/base/plan/result/close/annual_leave/ot_level`, `apply_att_result_fr_plan`, `daily_att_count` |
| `lgvatt_ot_calculation_pkg` | Tính giờ OT theo loại ca | `get_item_ot_total`, `get_ot_total`, `calculate_ot`, `set_*_shift_ot`, `validate_calculation` |
| `lgvatt_ot_level_pkg` | OT level | `get_ot_level`, `apply_att_ot_level_calc` |
| `lgvatt_idcard_pkg` | Nhận dữ liệu quẹt thẻ | `idcard_interface`, `inout_time` |
| `lgvatt_resignation_pkg` | Quyết toán phép khi nghỉ việc | `apply_att_annual_lv_corr_retir` |
| `lgvpay_calculation_pkg` | Engine tính lương (lớn nhất) | `main_proc`, `calc_proc`, `calculation_*` (từng khoản: base pay, OT, phụ cấp, BHXH, PIT…) |
| `lgvpay_payroll_run_pkg` / `lgvpay_retro_payroll_run_pkg` | Payroll Run / Retro Run (`lgvpayc0013/14`) | `run_proc`, `retry_run`, `rollback_run`, `summary_proc`, `difference_proc` |
| `lgvpay_info_pkg` | Lấy thông tin lương | `get_type_work_hours`, `get_work_hours`, `get_base_pay`, `get_ordinary_wages*`, `get_*_allowance` |
| `lgvpay_common_pkg` | Tiện ích lương | `get_planned_item_value`, `get_calc_var_value` |
| `lgvpay_aggr_pkg`, `lgvpay_calculation_set_pkg` | Aggregate, đối tượng hưởng lương | `calculation_aggr`, `creation_target_employee` |
| `lgvpay_upload_pkg` | Upload Excel lương | `upload_payroll_employee*`, `entry_payroll_item_by_item` |
| `lgvpay_payroll_invoice_pkg`, `LGVPAY_LOG_PKG` | Gửi kết quả lương, log | `send_pay_result`, `set_log_msg_payroll_result` |
| `lgvinf_if_batch_pkg`, `lgvinf_if_pay_batch_pkg` | Batch I/F `lgvinf` | `main_code/org/emp/per/asg/family/qualification/contract/grade_point`, `user_role_proc`, `main_assess_add` |
| `lgcom_bizweb_approval_pkg` | Phê duyệt | `request_create_proc`, `forward_request_proc`, `get_portal_mandator_info`, `approval_line_create_proc` |
| `lgcom_user_if_pkg`, `lgcom_org_if_pkg` | I/F user, tổ chức cho LGCOM | `main` |
| `lgcom_*` khác | Hạ tầng | `error_log` (`error_prc`, `debug_prc`), `system_logging`, `mtz` (giờ địa phương), `excel`, `dq_batch`, `region`, `soap_handler`/`ws` |

Lưu ý về thư mục package:
- File trùng nội dung: `lgvatt_idcard_pkg.~pck` (backup), `lgvpay_info_pkg.sql`, `lgvpay_payroll_run_pkg.sql`, `soap_handler.pck` (bản cũ tên khác của `lgcom_soap_handler`). `lgvatt_ot_calculation_pkg.sql` là bản cũ hơn `.pck` – luôn đọc file `.pck`.
- Source có thể lệch so với DB thật: ví dụ code Java/SQL gọi `lgvpay_upload_pkg.upload_payroll_emp_paid_leave`, `upload_request_os_kpi_master`… nhưng không có trong file `.pck`.

## Lưu ý

- Nhiều logic nghiệp vụ nằm trong Oracle PL/SQL package (xem mục **Database**); khi sửa SQL gọi package, đọc source trong `LGD_VHR Package/` trước.
- Comment trong code phần lớn bằng tiếng Hàn. Viết code mới phải giữ đúng phong cách xung quanh (header comment, `LGCOMLogger`, `LOGGER.debug("param = " + param)`).
- Một số ngoại lệ quy ước có sẵn, không nên coi là mẫu: `lgsmpc00200` chứa `LGUTLC00200Service`; thư mục `lgvatt/LGVATT30070` viết hoa; file `LGVPAY00007_원본.jsp` là bản sao cũ.
- Thư mục `target/` là output build, không sửa.
