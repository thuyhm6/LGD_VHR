# LGD_VHR – Hệ thống HR LG Display Việt Nam (Chấm công & Tính lương)

Dự án mẫu lấy từ hệ thống nhân sự thực tế của LG Display Việt Nam. Trọng tâm nghiệp vụ là **Chấm công (T&A)** và **Tính lương (Payroll)**. Dữ liệu nhân sự gốc (nhân viên, tổ chức, hợp đồng…) chủ yếu được **nhận qua Interface/Batch** từ hệ thống HR/ERP khác, không nhập tay.

## Cấu trúc

```
LGD_VHR/
├── LGCOM/   Portal & nền tảng chung: login/SSO, menu, phân quyền, mã chung, phê duyệt, batch, mail, file
└── LGVHR/   Nghiệp vụ HR Việt Nam: lgvatt (chấm công), lgvpay (lương), lgvinf (interface), lgvcom (request/approval)
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

## Lưu ý

- Một phần logic nằm trong Oracle PL/SQL package (ví dụ `lgvhr_common_pkg.get_shift_type_code_func`), không có trong repo.
- Comment trong code phần lớn bằng tiếng Hàn. Viết code mới phải giữ đúng phong cách xung quanh (header comment, `LGCOMLogger`, `LOGGER.debug("param = " + param)`).
- Một số ngoại lệ quy ước có sẵn, không nên coi là mẫu: `lgsmpc00200` chứa `LGUTLC00200Service`; thư mục `lgvatt/LGVATT30070` viết hoa; file `LGVPAY00007_원본.jsp` là bản sao cũ.
- Thư mục `target/` là output build, không sửa.
