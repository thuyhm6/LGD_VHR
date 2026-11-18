# Paid Leave (PL_SW / PL_PLP) – Quy trình xử lý dữ liệu LGVPAY00031 · 00032 · 00033

Tài liệu mô tả luồng dữ liệu của chức năng **nghỉ hưởng lương** gồm 2 loại:

- **PL_SW** – ngừng việc (Stop Working)
- **PL_PLP** – nghỉ khám thai (Prenatal Leave)

Nguồn tổng hợp: JSP, Service, SQL mapper của 3 màn hình, package `LGD_VHR Package/lgvpay_paid_leave_pkg.pck` và DDL `LGD_VHR Package/lgvpay_paid_leave_ddl.sql`.

---

## 0. Tổng quan

### Thứ tự sử dụng

```
LGVPAY00033              LGVPAY00031                   LGVPAY00032               Payroll Running
(Cài đặt – làm 1 lần) →  (Đăng ký – hàng tháng)     →  (Tính tiền – hàng tháng) → (LGVPAY00008)
 Tỷ lệ + Mapping item     Ai nghỉ, từ ngày–đến ngày,    Tính số ngày liên tục,    Formula đọc kết quả
                          ghi mã PL vào chấm công       tier, số tiền             00032 → item lương
```

### Luồng dữ liệu

| Bước | Màn hình / Chức năng | Đọc từ | Ghi vào |
|---|---|---|---|
| 0 | 00033 Rate Setup | – | `TB_PAY_PL_RATE_M`, `TB_PAY_PL_ITEM_MAP_M` |
| 1 | 00031 Đăng ký (tay / Excel) | Excel (`LGCOM_IMPORT_N`) / nhập tay | `TB_PAY_PAID_LEAVE_N` |
| 2 | 00031 Apply to T&A | `TB_PAY_PAID_LEAVE_N` | `TB_ATT_PLAN_N`, `TB_ATT_RESULT_N` (mã `PL`) |
| 3 | 00032 Calculate | `TB_ATT_RESULT_N`, `TB_PAY_PL_RATE_M`, lương/phụ cấp NV | `TB_PAY_PL_CALC_DAILY_N`, `TB_PAY_PL_CALC_RESULT_N` |
| 4 | Payroll Running | `TB_PAY_PL_CALC_RESULT_N`, `TB_PAY_PL_ITEM_MAP_M` | Kết quả lương (`lgvpay_calculation_pkg.create_result`) |

### Thành phần source

| Màn hình | Menu | JSP / Service / SQL | Package |
|---|---|---|---|
| LGVPAY00031 Paid Leave Registration | `M_LGVPAY_1057` | `views/lgvpay/LGVPAY00031.jsp`, `lgvpay00031/.../LGVPAY00031ServiceImpl.java`, `sql/oracle/lgvpay/sql-lgvpay00031.xml` | `upload_paid_leave_emp` |
| LGVPAY00032 Paid Leave Payment Calculation | `M_LGVPAY_1058` | `LGVPAY00032.jsp`, `LGVPAY00032ServiceImpl.java`, `sql-lgvpay00032.xml` | `calculate_paid_leave` |
| LGVPAY00033 Paid Leave Payment Rate Setup | `M_LGVPAY_1059` | `LGVPAY00033.jsp`, `LGVPAY00033ServiceImpl.java`, `sql-lgvpay00033.xml` | – |
| Formula item lương | – | Formula Management (LGVPAY00014) | `calculation_pl_item`, `get_pl_days`, `get_pl_hours` |

---

## 1. LGVPAY00033 – Paid Leave Payment Rate Setup (dữ liệu cài đặt)

### 1.0 Mục đích – tại sao cần màn hình này?

Chính sách trả lương cho ngày PL **không cố định** mà phụ thuộc 4 yếu tố:

| Yếu tố | Ví dụ |
|---|---|
| Loại nghỉ | PL_SW khác PL_PLP |
| Nhóm nhân viên | OW được 60% lương CB, LW được lương tối thiểu vùng |
| Đã nghỉ liên tục bao lâu | Tháng thứ 1: 60%, tháng thứ 2: 30%, từ tháng thứ 3: 0% |
| Thời điểm | Chính sách đổi từ 01/07 thì tỷ lệ mới áp dụng từ 01/07 |

Nếu viết cứng những con số này trong PL/SQL thì mỗi lần chính sách thay đổi phải sửa code và deploy package. LGVPAY00033 **đưa toàn bộ chính sách ra thành dữ liệu**, để HR/Payroll tự cấu hình:

1. **Grid trên – "trả bao nhiêu"**: cho mỗi ngày PL, engine tính (00032) tìm ra *tỷ lệ % của từng thành phần lương* dựa vào loại PL, nhóm NV, số ngày liên tục và ngày phát sinh.
2. **Grid dưới – "trả vào đâu"**: kết quả tính ra được đưa vào *payroll item nào* trên phiếu lương. Nhờ vậy cùng một kết quả có thể hiện thành nhiều dòng riêng (ví dụ "Base salary PL_SW tháng 1", "Base salary PL_SW tháng 2") hoặc thành một dòng trừ (`ADJ`) nếu lương thường đã trả đủ 100%.

> Không có dữ liệu ở grid trên → 00032 **không tính** ngày PL (ngày đó bị bỏ qua hoặc vào tier 0).
> Không có mapping ở grid dưới → 00032 vẫn tính, nhưng **không có tiền nào vào phiếu lương**.

### 1.1 Grid trên – Tỷ lệ chi trả (`TB_PAY_PL_RATE_M`)

Mỗi dòng = **(Loại PL, Nhóm NV, Tier, khoảng ngày From–To, thời gian hiệu lực)** + tỷ lệ % của 7 thành phần lương: Base salary, Position allowance, Job allowance, Qualification allowance, Adjustment 1/2/3 allowance.

| Cột | Ý nghĩa |
|---|---|
| Paid Leave Type | `PL_SW`, `PL_PLP` (mã chung `LGVHR_ATTENDANCE_PL_DETAIL_CODE`) |
| Emp. Category | `LGD_OW`, `LGD_LW` (= `EMP_MASTER.ASSIGNMENT_CATEGORY`) hoặc `ALL` |
| Tier | "Tháng thứ mấy" của đợt nghỉ (1, 2, 3…) |
| From Days / To Days | Khoảng **a** (số ngày liên tục, xem mục 3.1). `To Days` trống = không giới hạn |
| Base Amount Type | `BASE_SALARY` = lương cơ bản; `MIN_WAGE` = thay lương cơ bản bằng **lương tối thiểu vùng** (Global Value `REGION_MINIMUM_WAGE`, LGVPAY10001) |
| Rate (%) | 0 ~ 100 cho từng thành phần |
| Start / End Date | Thời gian hiệu lực của tỷ lệ |

Thao tác:

- **Add / Delete / Save** – sửa trực tiếp trên grid.
- **Copy** – sao chép dòng đang chọn thành dòng mới với Start Date = hôm nay, End Date = 31/12/4712. Dùng khi đổi tỷ lệ từ một ngày; cần tự sửa End Date của dòng cũ.
- Khi lưu, server kiểm tra (`retrievePlRateConflict`): không được có 2 dòng cùng PL + nhóm NV mà **vừa chồng khoảng ngày, vừa chồng thời gian hiệu lực** → báo lỗi và rollback toàn bộ.

Dữ liệu khởi tạo trong DDL (theo file `Tính lương PL_SW&PLP.xlsx`), các phụ cấp đều 0%:

| PL | Nhóm | Tier 1 (1–30 ngày) | Tier 2 (31–60) | Tier 3 (> 60) |
|---|---|---|---|---|
| PL_SW | OW | 60% lương CB | 30% lương CB | 0 |
| PL_SW | LW | 100% lương tối thiểu vùng | 50% lương CB | 0 |
| PL_PLP | ALL | 60% lương CB (mọi số ngày) | | |

### 1.2 Grid dưới – Mapping item lương (`TB_PAY_PL_ITEM_MAP_M`)

Mỗi dòng = **(Loại PL, Tier, Thành phần) → Payroll Item**, kèm **Apply Value**:

| Apply Value | Giá trị đưa vào item |
|---|---|
| `PAY` | Số tiền trả cho các ngày PL (đã áp tỷ lệ) |
| `ADJ` | `PAY − FULL` (số âm). Dùng khi item lương thường đã trả 100% cho ngày PL, cần trừ phần chênh lệch |

- (PL, Tier, Thành phần) là duy nhất (`UK_TB_PAY_PL_ITEM_MAP_M`).
- Combo Payroll Item lấy các item còn hiệu lực trong `TB_PAY_PAYROLL_ITEM_M`.

---

## 2. LGVPAY00031 – Paid Leave Registration (đăng ký + ghi vào chấm công)

Điều kiện tìm kiếm: **Tháng lương + Loại PL** (+ nhân viên).

### 2.1 Đăng ký → `TB_PAY_PAID_LEAVE_N`

Mỗi dòng = 1 nhân viên, Start Date – End Date, Note.

- **Nhập tay** (Insert / Delete / Save): `savePaidLeaveEmp` gọi `checkOverlap` cho từng dòng. Cùng NV + cùng loại PL mà trùng khoảng ngày → báo lỗi, rollback cả lần lưu.
- **Upload Excel** – cột: `1 Mã NV / 2 Tên / 3 Start Date / 4 End Date (DD/MM/YYYY) / 5 Note`.
  File → `LGCOM_IMPORT_N` → `lgvpay_paid_leave_pkg.upload_paid_leave_emp`. Mỗi dòng được kiểm tra:
  - Mã NV tồn tại trong `EMP_MASTER`
  - Ngày đúng định dạng và Start ≤ End
  - Không trùng kỳ với đăng ký đã có

  **Chỉ cần 1 dòng lỗi là không lưu dòng nào**; dòng lỗi được đánh dấu `ATTRIBUTE199 = 'Y'`, thông báo ở `ATTRIBUTE200`.
- **Delete All** – xóa toàn bộ đăng ký của tháng + loại PL.
- **Excel Download** – xuất danh sách đăng ký.

### 2.2 Apply to T&A (`saveCalculateAttendancePL`)

Ghi các ngày nằm trong khoảng đăng ký vào chấm công:

| Bảng | Thay đổi |
|---|---|
| `TB_ATT_PLAN_N` (kế hoạch) | `TIME_AND_ATTENDANCE_CODE = 'PL'`, `TIME_ATTEND_DETAIL_CODE = PL_SW/PL_PLP`, OT = 0 |
| `TB_ATT_RESULT_N` (kết quả) | Như trên, đồng thời giờ công, OT, đi muộn, về sớm, ra ngoài = 0; lý do = `Paid Leave Registration (LGVPAY00031)` |

**Không ghi đè** các ngày:
- Ngày lễ theo lịch ca (`TB_ATT_BASE_BAS_N` = `PH`)
- Ngày đang có mã `PL`, `PH`, `WH` (nghỉ tuần), `US`, `NN`

Màn hình trả về số dòng plan / actual đã cập nhật.

> **Lưu ý**
> - Chỉ ngày đã thành `PL` trong `TB_ATT_RESULT_N` mới được 00032 tính tiền → sửa đăng ký sau khi Apply thì phải **Apply lại**.
> - **Xóa đăng ký không tự khôi phục mã chấm công cũ** → phải sửa T&A thủ công.

---

## 3. LGVPAY00032 – Paid Leave Payment Calculation (tính tiền)

Nút **Calculate** gọi `lgvpay_paid_leave_pkg.calculate_paid_leave(subsidiary, tháng, loại PL, mã NV)` (loại PL / mã NV để trống = tất cả).
Trước tiên **xóa kết quả cũ** của phạm vi đó, sau đó tính 2 tầng.

### 3.1 Tầng ngày → `TB_PAY_PL_CALC_DAILY_N` (grid dưới "Daily Detail")

1. **Lấy ngày PL trong tháng**: `TB_ATT_RESULT_N` có mã `PL` và loại PL có cài tỷ lệ ở 00033.
   Giờ PL của ngày = `lgvpay_info_pkg.get_work_hours(..., 'pay_perfect_hours')`.
2. **Tính a – số ngày liên tục** cho từng ngày PL:
   - Chuỗi = các ngày dương lịch liên tục gồm **cùng loại PL**, **WH**, **PH**; nhìn ngược tối đa 400 ngày → **chuỗi kéo qua nhiều tháng**.
   - Chuỗi bắt đầu tại **ngày PL đầu tiên** (WH/PH đứng trước ngày PL đầu tiên không tính).
   - `a = ngày đang xét − ngày bắt đầu chuỗi + 1`. WH/PH nằm giữa chuỗi được cộng vào a nhưng bản thân không được trả tiền.
3. **Chọn dòng tỷ lệ**: cùng loại PL, `FROM_DAYS ≤ a ≤ TO_DAYS`, hiệu lực vào ngày đó.
   Dòng của đúng nhóm NV (`LGD_OW` / `LGD_LW`) **ưu tiên** hơn dòng `ALL`; cùng mức ưu tiên thì lấy Start Date mới nhất.
   Không tìm được dòng → tier trống → ngày đó không được trả.

### 3.2 Tầng tháng → `TB_PAY_PL_CALC_RESULT_N` (grid trên)

1 dòng = **nhân viên × loại PL × tier**.

- **Ngày tham chiếu** = cuối tháng, hoặc ngày nghỉ việc nếu sớm hơn.
- **Giờ công chuẩn tháng** (`PERFECT_WORK_HOURS`) = tổng giờ chuẩn mọi ngày trong tháng theo lịch ca.
- **Số tiền tháng** của từng thành phần tại ngày tham chiếu:

| Thành phần | Nguồn |
|---|---|
| Base salary | `lgvpay_info_pkg.get_base_pay` |
| Position / Job / Qualification | `get_position_allowance`, `get_job_allowance`, `get_qualification_allowance` |
| Adjustment 1/2/3 | Planned item ID 23 / 24 / 25 (`get_planned_item_value`) |
| Lương tối thiểu vùng | Global Value `REGION_MINIMUM_WAGE` |

- Mỗi thành phần ra 4 cột:

| Cột | Công thức |
|---|---|
| Monthly (`*_BASE`) | Số tiền tháng |
| 100% Value (`*_FULL`) | Số tiền tháng × Σ giờ PL ÷ giờ chuẩn tháng |
| Pay (`*_PAY`) | Σ(giờ PL ngày × tỷ lệ %) × số tiền tháng ÷ giờ chuẩn tháng. Base salary loại `MIN_WAGE` dùng lương tối thiểu vùng thay số tiền tháng |
| Adjustment | Pay − 100% Value (hiển thị trên grid) |

- Ngày không có tỷ lệ được gom vào **tier 0** – chỉ để thống kê, không trả tiền.
- **Excel Download** – xuất kết quả tháng.

---

## 4. Đưa vào lương – Payroll Running

Payroll item (ví dụ "Base salary PL_SW 1") được cài formula `lgvpay_paid_leave_pkg.calculation_pl_item` ở Formula Management, với 6 tham số IN:
`P_EMPLOYEE_NO, P_PERIOD_ID, P_PAYROLL_CALCULATION_EXEC_ID, P_PAYROLL_ITEM_ID, P_RUN_TYPE_NAME, P_USER_ID`.

Khi chạy lương:

1. Nếu NV đã có **planned item** cho item này trong kỳ → bỏ qua (nhập tay được ưu tiên).
2. Tìm các mapping của item ở 00033, join `TB_PAY_PL_CALC_RESULT_N` theo (tháng, NV, loại PL, tier) → cộng `PAY` (hoặc `PAY − FULL` nếu Apply Value = `ADJ`) của thành phần tương ứng.
3. Ghi kết quả bằng `lgvpay_calculation_pkg.create_result` (detail `PAY_VALUE`). Lỗi được ghi vào log payroll (`lgvpay_log_pkg`).

Hàm phụ cho các formula khác (chuyên cần, đi lại…): `get_pl_days`, `get_pl_hours` – số ngày / giờ PL trong tháng, đọc từ `TB_PAY_PL_CALC_DAILY_N`.

> **Bắt buộc chạy 00032 Calculate trước Payroll Running.** Formula chỉ đọc kết quả đã lưu, không tự tính lại.

---

## 5. Ví dụ minh họa

Nhân viên **OW**, lương CB **10.000.000**, giờ chuẩn tháng **208h**, nghỉ **PL_SW từ 15/03 đến 20/04**, mỗi ngày làm việc 8h.

**Tháng 3**
- Ngày 15–31/03 có a = 1 … 17 → **Tier 1 (60%)**.
- Giả sử 13 ngày làm việc thành `PL` (các ngày WH vẫn được cộng vào a).
- Pay = 13 × 8 × 60% × 10.000.000 ÷ 208 ≈ **3.000.000**
- 100% Value ≈ 5.000.000 → Adjustment ≈ −2.000.000

**Tháng 4**
- Chuỗi nối tiếp từ 15/03 → ngày 01/04 có a = 18.
- Từ ngày 14/04 (a = 31) chuyển sang **Tier 2 (30%)** → tháng 4 có **2 dòng kết quả** (tier 1 và tier 2).

**Đưa vào lương**
- Mapping (PL_SW, Tier 1, BASE_SALARY) → item "Base salary PL_SW 1", Apply Value = `PAY` → khi chạy lương tháng 3 item này nhận **3.000.000**.

---

## 6. Quy trình thực hiện

### Giai đoạn A – Thiết lập (làm 1 lần, hoặc khi chính sách thay đổi)

| # | Màn hình | Việc làm | Kết quả cần thấy |
|---|---|---|---|
| A1 | DB | Chạy `lgvpay_paid_leave_ddl.sql` rồi `lgvpay_paid_leave_pkg.pck` | Có 4 bảng `TB_PAY_PL_*`, package VALID |
| A2 | LGVPAY10001 Global Value | Kiểm tra / cập nhật `REGION_MINIMUM_WAGE` | Có giá trị hiệu lực cho tháng cần tính |
| A3 | LGVPAY00013 Payroll Item Mgt. | Tạo các payroll item cho PL (VD: `Base salary PL_SW 1`, `Base salary PL_SW 2`, `Base salary PL_PLP`) | Item có detail `PAY_VALUE` |
| A4 | LGVPAY00014 Formula Mgt. | Gán formula `lgvpay_paid_leave_pkg.calculation_pl_item` (6 tham số IN) cho các item ở A3 | – |
| A5 | **LGVPAY00033** grid trên | Kiểm tra / nhập tỷ lệ → **Save** | Không báo lỗi trùng tier |
| A6 | **LGVPAY00033** grid dưới | Map (PL, Tier, Thành phần) → item ở A3 → **Save** | Combo Payroll Item hiện đúng item |
| A7 | Calculation Set (LGVPAY00021) | Đưa các item ở A3 vào calculation set dùng để chạy lương | – |

### Giai đoạn B – Hàng tháng

| # | Màn hình | Việc làm | Kết quả cần thấy |
|---|---|---|---|
| B1 | – | Đảm bảo batch chấm công đã tạo `TB_ATT_RESULT_N` cho tháng | Tháng có dữ liệu T&A |
| B2 | **LGVPAY00031** | Chọn **Tháng + Loại PL** → nhập tay (Insert/Save) hoặc **Excel Upload** | Danh sách đăng ký hiện trên grid |
| B3 | **LGVPAY00031** | Bấm **Apply to T&A** | Thông báo số dòng plan / actual đã cập nhật |
| B4 | T&A (LGVATT00020 hoặc SQL mục 7.5) | Kiểm tra các ngày đăng ký đã thành mã `PL` (trừ WH/PH) | Ngày làm việc = `PL`, giờ công = 0 |
| B5 | **LGVPAY00032** | Chọn tháng → **Calculate** → **Search** | Grid tháng: số ngày, giờ, tier, tiền; Daily Detail: a, tier, tỷ lệ từng ngày |
| B6 | LGVPAY00008 Payroll Running | Chạy lương | Item PL có giá trị trên kết quả lương / PaySlip |

### Khi có thay đổi sau khi đã tính

| Thay đổi | Phải chạy lại |
|---|---|
| Sửa / thêm đăng ký ở 00031 | B3 → B5 → B6 |
| Xóa đăng ký ở 00031 | Sửa tay chấm công các ngày đó → B5 → B6 |
| Sửa chấm công trực tiếp | B5 → B6 |
| Sửa tỷ lệ ở 00033 | B5 → B6 |
| Sửa mapping ở 00033 | B6 |
| Đổi lương CB / phụ cấp / lương tối thiểu | B5 → B6 |

---

## 7. Dữ liệu mẫu để test

### 7.0 Giả định chung

- Subsidiary `LGDVN`, tháng test **10/2026** và **11/2026**, batch T&A đã tạo dữ liệu cho 2 tháng này.
- Chọn 3 nhân viên thật trong `EMP_MASTER`, chưa nghỉ việc, có lịch ca hành chính (8h/ngày, nghỉ Chủ nhật):

| Ký hiệu | `ASSIGNMENT_CATEGORY` | Lương CB | Ghi chú |
|---|---|---|---|
| **NV_OW** | `LGD_OW` | 10.000.000 | |
| **NV_LW** | `LGD_LW` | 6.000.000 | |
| **NV_PLP** | `LGD_OW` | 10.000.000 | Có thể dùng chung NV_OW nếu không trùng ngày |

```sql
-- Tìm nhân viên test
SELECT employee_number, full_name, assignment_category, date_retire
FROM   emp_master
WHERE  assignment_category IN ('LGD_OW', 'LGD_LW')
AND    (date_retire IS NULL OR date_retire > DATE '2026-12-31')
AND    ROWNUM <= 20;
```

- Số tiền mong đợi bên dưới tính với **giờ chuẩn tháng = 208h** (26 ngày × 8h). Giờ chuẩn thực tế lấy từ cột *Perfect Work Hours* trên 00032 – nếu khác 208 thì thay vào công thức.

### 7.1 LGVPAY00033 – grid tỷ lệ

DDL đã insert sẵn 7 dòng (mục 1.1). Nếu chưa có, nhập tay:

| PL Type | Category | Tier | From | To | Base Amount | Base salary % | Các phụ cấp % | Start | End |
|---|---|---|---|---|---|---|---|---|---|
| PL_SW | OW | 1 | 1 | 30 | Base Salary | 60 | 0 | 01/01/2026 | 31/12/4712 |
| PL_SW | OW | 2 | 31 | 60 | Base Salary | 30 | 0 | 01/01/2026 | 31/12/4712 |
| PL_SW | OW | 3 | 61 | *(trống)* | Base Salary | 0 | 0 | 01/01/2026 | 31/12/4712 |
| PL_SW | LW | 1 | 1 | 30 | Minimum Wage | 100 | 0 | 01/01/2026 | 31/12/4712 |
| PL_SW | LW | 2 | 31 | 60 | Base Salary | 50 | 0 | 01/01/2026 | 31/12/4712 |
| PL_SW | LW | 3 | 61 | *(trống)* | Base Salary | 0 | 0 | 01/01/2026 | 31/12/4712 |
| PL_PLP | ALL | 1 | 1 | *(trống)* | Base Salary | 60 | 0 | 01/01/2026 | 31/12/4712 |

**Test kiểm tra lỗi (phải báo lỗi, không lưu):**

| Test | Thao tác | Kết quả mong đợi |
|---|---|---|
| T33-1 | Add dòng `PL_SW / OW / Tier 4 / From 50 / To 70`, Start 01/01/2026 | Lỗi *Tier 2 and Tier 4 overlap…* (chồng 50–60) |
| T33-2 | Add dòng có Base salary % = 120 | Lỗi *Rate : 0 ~ 100 (%)* |
| T33-3 | Add dòng From 40, To 30 | Lỗi *From Days <= To Days* |
| T33-4 | Chọn dòng `PL_SW / OW / Tier 1` → **Copy** → sửa tỷ lệ 70, Start 01/12/2026; **chưa** sửa End của dòng cũ → Save | Lỗi trùng (2 dòng Tier 1 cùng hiệu lực từ 01/12/2026). Sửa End dòng cũ = 30/11/2026 → Save thành công. *(Test xong thì xóa dòng mới, trả End dòng cũ về 31/12/4712.)* |

### 7.2 LGVPAY00033 – grid mapping

Giả sử đã tạo các item ở bước A3 (tên tùy chọn):

| PL Type | Tier | Component | Payroll Item | Apply Value |
|---|---|---|---|---|
| PL_SW | 1 | Base salary | Base salary PL_SW 1 | PAY |
| PL_SW | 2 | Base salary | Base salary PL_SW 2 | PAY |
| PL_PLP | 1 | Base salary | Base salary PL_PLP | PAY |

| Test | Thao tác | Kết quả mong đợi |
|---|---|---|
| T33-5 | Add thêm dòng `PL_SW / 1 / Base salary` (trùng dòng đầu) → Save | Lỗi unique (`UK_TB_PAY_PL_ITEM_MAP_M`) |
| T33-6 | Add dòng thiếu Payroll Item → Save | Lỗi *required … Payroll Item* |

### 7.3 LGVPAY00031 – đăng ký

**Kịch bản S1 – OW, nghỉ ngắn trong 1 tháng** (Tháng `202611`, Loại `PL_SW`)

| Employee No | Start Date | End Date | Note |
|---|---|---|---|
| NV_OW | 02/11/2026 | 06/11/2026 | Test S1 – 5 ngày (T2–T6) |

**Kịch bản S2 – LW, dùng lương tối thiểu vùng** (Tháng `202611`, Loại `PL_SW`)

| Employee No | Start Date | End Date | Note |
|---|---|---|---|
| NV_LW | 09/11/2026 | 11/11/2026 | Test S2 – 3 ngày (T2–T4) |

**Kịch bản S3 – PL_PLP 1 ngày** (Tháng `202611`, Loại `PL_PLP`)

| Employee No | Start Date | End Date | Note |
|---|---|---|---|
| NV_PLP | 17/11/2026 | 17/11/2026 | Test S3 – khám thai |

> Nếu NV_PLP dùng chung NV_OW thì vẫn được, vì S1 và S3 khác loại PL và khác ngày.

**Kịch bản S4 – chuỗi nghỉ kéo qua 2 tháng, chuyển tier** (dùng NV_OW **khác** NV ở S1, hoặc làm sau khi xóa S1)

| Tháng | Loại | Employee No | Start Date | End Date |
|---|---|---|---|---|
| `202610` | PL_SW | NV_OW2 | 20/10/2026 | 31/10/2026 |
| `202611` | PL_SW | NV_OW2 | 01/11/2026 | 30/11/2026 |

**File Excel upload mẫu** (dòng 1 là tiêu đề, bị bỏ qua):

| Employee No | Employee Name | Start Date | End Date | Note |
|---|---|---|---|---|
| NV_OW | | 02/11/2026 | 06/11/2026 | Test S1 |
| NV_LW | | 09/11/2026 | 11/11/2026 | Test S2 |

**Test kiểm tra lỗi:**

| Test | Thao tác | Kết quả mong đợi |
|---|---|---|
| T31-1 | Sau khi lưu S1, Insert thêm `NV_OW 05/11/2026 – 08/11/2026` (PL_SW) → Save | Lỗi *Period overlaps an existing registration* |
| T31-2 | Upload file có 1 dòng mã NV `XXXXX` + 1 dòng đúng | Báo *Total : 2 Error : 1*, **không dòng nào** được lưu |
| T31-3 | Upload dòng Start `10/11/2026`, End `05/11/2026` | Lỗi *Start Date must be less than or equal to End Date* |
| T31-4 | Upload dòng ngày sai định dạng `2026-11-10` | Lỗi *Check Start/End Date (DD/MM/YYYY)* |

Sau khi lưu xong từng tháng / loại PL → bấm **Apply to T&A**.

**Kiểm tra Apply (B4):**
- S1: 02–06/11 thành `PL` / `PL_SW`, giờ công = 0.
- S4: các **Chủ nhật** (25/10, 01/11, 08/11, 15/11, 22/11, 29/11) **giữ nguyên `WH`**, không bị đổi thành `PL`.

### 7.4 LGVPAY00032 – kết quả mong đợi (tháng `202611`)

Chọn tháng 11/2026 → **Calculate** → **Search**.

**S1 – NV_OW, PL_SW, 5 ngày × 8h = 40h, Tier 1 (60%)**

| Cột | Công thức | Mong đợi |
|---|---|---|
| PL Days / Hours | | 5 / 40 |
| Base salary – 100% | 10.000.000 × 40 ÷ 208 | **1.923.077** |
| Base salary – Pay | 10.000.000 × 40 × 60% ÷ 208 | **1.153.846** |
| Base salary – Adj | Pay − 100% | **−769.231** |
| Daily Detail | Continuous days | 02/11 → a=1 … 06/11 → a=5, Tier 1, rate 60 |

**S2 – NV_LW, PL_SW, 3 ngày × 8h = 24h, Tier 1 (MIN_WAGE 100%)**

| Cột | Công thức | Mong đợi |
|---|---|---|
| Min Wage | `REGION_MINIMUM_WAGE` | 4.680.000 |
| Base salary – 100% | 6.000.000 × 24 ÷ 208 | **692.308** |
| Base salary – Pay | **4.680.000** × 24 × 100% ÷ 208 | **540.000** |
| Daily Detail | Base Amount Type | `MIN_WAGE` |

**S3 – NV_PLP, PL_PLP, 1 ngày × 8h, Tier 1 (60%)**

| Cột | Công thức | Mong đợi |
|---|---|---|
| Base salary – Pay | 10.000.000 × 8 × 60% ÷ 208 | **230.769** |

**S4 – NV_OW2, PL_SW, chuỗi bắt đầu 20/10/2026**

Chuỗi gồm ngày PL + WH liên tục từ 20/10 nên a ở tháng 11 = *ngày − 20/10 + 1*:

| Ngày | a | Tier |
|---|---|---|
| 01/11 (CN – WH) | 13 | *(không trả, chỉ cộng vào a)* |
| 02/11 (T2) | 14 | 1 |
| 18/11 (T4) | 30 | 1 |
| **19/11 (T5)** | **31** | **2** |
| 30/11 (T2) | 42 | 2 |

Tháng 11 có 25 ngày làm việc (30 ngày − 5 Chủ nhật):

| Dòng kết quả | Ngày làm việc | Giờ | Pay (lương CB 10.000.000) |
|---|---|---|---|
| Tier 1 (02–18/11) | 15 | 120 | 10.000.000 × 120 × 60% ÷ 208 = **3.461.538** |
| Tier 2 (19–30/11) | 10 | 80 | 10.000.000 × 80 × 30% ÷ 208 = **1.153.846** |

> Nếu tính tháng 10 (`202610`): 20–31/10 có 11 ngày làm việc (trừ CN 25/10), a = 1…12, toàn bộ Tier 1 → Pay = 10.000.000 × 88 × 60% ÷ 208 = **2.538.462**.

### 7.5 Payroll Running – kết quả mong đợi (tháng 11/2026)

| Nhân viên | Item | Giá trị |
|---|---|---|
| NV_OW (S1) | Base salary PL_SW 1 | 1.153.846 |
| NV_LW (S2) | Base salary PL_SW 1 | 540.000 |
| NV_PLP (S3) | Base salary PL_PLP | 230.769 |
| NV_OW2 (S4) | Base salary PL_SW 1 | 3.461.538 |
| NV_OW2 (S4) | Base salary PL_SW 2 | 1.153.846 |

**Test thêm `ADJ`**: đổi Apply Value của dòng mapping `PL_SW / 1 / Base salary` sang `ADJ` → chạy lại lương → item của NV_OW (S1) = **−769.231** (= Pay − 100%).

**Test planned item ưu tiên**: nhập planned item `Base salary PL_SW 1` = 999 cho NV_OW ở LGVPAY00003 → chạy lại lương → item = 999 (formula bị bỏ qua).

### 7.6 SQL kiểm tra nhanh

```sql
-- B4 : chấm công sau Apply to T&A
SELECT employee_no, time_and_attendance_date, time_and_attendance_code, time_attend_detail_code, work_hours
FROM   tb_att_result_n
WHERE  employee_no IN ('NV_OW', 'NV_LW', 'NV_PLP', 'NV_OW2')
AND    time_and_attendance_yyyymm = '202611'
ORDER BY employee_no, time_and_attendance_date;

-- B5 : kết quả theo ngày
SELECT employee_no, time_and_attendance_date, paid_leave_detail_code, emp_category_code,
       chain_start_date, continuous_days, tier_no, pl_hours, base_amount_type, base_salary_rate
FROM   tb_pay_pl_calc_daily_n
WHERE  payment_yyyymm = '202611'
ORDER BY employee_no, time_and_attendance_date;

-- B5 : kết quả theo tháng
SELECT employee_no, paid_leave_detail_code, tier_no, pl_days, pl_hours, perfect_work_hours,
       min_wage, base_salary_base, base_salary_full, base_salary_pay
FROM   tb_pay_pl_calc_result_n
WHERE  payment_yyyymm = '202611'
ORDER BY employee_no, paid_leave_detail_code, tier_no;

-- Dọn dữ liệu test
DELETE FROM tb_pay_pl_calc_daily_n  WHERE payment_yyyymm IN ('202610', '202611') AND employee_no IN ('NV_OW', 'NV_LW', 'NV_PLP', 'NV_OW2');
DELETE FROM tb_pay_pl_calc_result_n WHERE payment_yyyymm IN ('202610', '202611') AND employee_no IN ('NV_OW', 'NV_LW', 'NV_PLP', 'NV_OW2');
DELETE FROM tb_pay_paid_leave_n     WHERE payment_yyyymm IN ('202610', '202611') AND employee_no IN ('NV_OW', 'NV_LW', 'NV_PLP', 'NV_OW2');
-- Chấm công các ngày đã Apply phải khôi phục thủ công (hoặc chạy lại batch T&A cho các NV này).
```

> Thay `NV_OW`, `NV_LW`, `NV_PLP`, `NV_OW2` bằng mã nhân viên thật trước khi chạy.
