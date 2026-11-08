# AutoCare – Repair Operation & Parts (Giang)

Hiện thực 5 use case của Nguyễn Trường Giang trên kiến trúc **Next.js + NestJS + PostgreSQL** (không dùng Docker):

| UC | Tên | Actor | Màn hình | API |
|----|-----|-------|----------|-----|
| UC27 | Assign Mechanic | Lễ tân, Quản lý CN | Lệnh sửa chữa → chi tiết → *Phân công thợ máy* | `POST /api/repair-orders/:id/assign` |
| UC29 | Update Repair Progress | Thợ máy | Công việc của tôi → mở lệnh → *Cập nhật tiến độ* | `PATCH /api/repair-tasks/:id/progress` |
| UC32 | Complete Repair Order | Thợ máy → Lễ tân | Thợ: *Đánh dấu hoàn thành* · Lễ tân: *Kiểm tra & chuyển thu ngân* | `POST /api/repair-orders/:id/complete`, `POST /api/repair-orders/:id/verify` |
| UC37 | Request Parts | Thợ máy | Chi tiết lệnh → *Yêu cầu phụ tùng* | `POST /api/part-requests` |
| UC38 | Issue Parts | Lễ tân | Yêu cầu phụ tùng → chi tiết → *Xác nhận xuất kho* | `POST /api/part-requests/:id/issue` (`/reject` để từ chối) |

Business rules được kiểm tra trong service: BR4 (phân quyền), BR19 (chỉ phụ tùng đã duyệt), BR22 (đúng thợ được giao), BR24 (hoàn thành khi mọi hạng mục DONE), BR25/26 (đủ tồn kho, ưu tiên phần đã giữ chỗ), BR27 (mỗi lần xuất ghi một bút toán `inventory_transactions` bất biến – có trigger chặn UPDATE/DELETE), BR48 (chỉ thao tác dữ liệu chi nhánh mình), BR50 (audit log), NFR-4/NFR-5 (khóa dòng `SELECT … FOR UPDATE`, phiên 30 phút, khóa tài khoản 15 phút sau 5 lần sai).

## 1. Cài đặt database (một lần)

Yêu cầu: PostgreSQL ≥ 12 (máy Giang dùng 18), Node.js ≥ 20.

```powershell
# tạo user + database (nhập mật khẩu user postgres của máy bạn)
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -h localhost -c "CREATE ROLE autocare LOGIN PASSWORD 'autocare123' CREATEDB;" -c "CREATE DATABASE autocare OWNER autocare ENCODING 'UTF8' TEMPLATE template0;"

# nạp toàn bộ schema + dữ liệu mẫu (file gửi cho cả nhóm)
$env:PGPASSWORD="autocare123"; & "C:\Program Files\PostgreSQL\18\bin\psql.exe" -U autocare -h localhost -d autocare -f database\export\autocare_full.sql
```

Muốn làm sạch và nạp lại dữ liệu gốc bất cứ lúc nào: `.\database\reset-db.ps1`

| File | Dùng khi |
|------|----------|
| `database/export/autocare_full.sql` | **File gửi nhóm** – schema + data (45 bảng), SQL thuần, chạy được trên PostgreSQL 12+ |
| `database/export/autocare_dump_pg18.sql` | Bản `pg_dump` gốc – chỉ nạp được bằng psql/PostgreSQL 17.6+ / 18 |
| `database/01_schema.sql`, `02_seed.sql` | Schema và dữ liệu tách riêng (được `reset-db.ps1` dùng) |
| `database/seed_generator.py` | Sinh lại `02_seed.sql` (Python thuần, không cần thư viện) |

## 2. Chạy ứng dụng

```powershell
cd backend;  npm install; npm run build; npm start      # API  http://localhost:4000/api
cd frontend; npm install; npm run dev                   # Web  http://localhost:3000
```

Cấu hình kết nối trong `backend/.env` (mẫu: `.env.example`), địa chỉ API của web trong `frontend/.env.local`.

## 3. Tài khoản demo – mật khẩu chung `Password@123`

| Chi nhánh | Quản lý | Lễ tân | Thu ngân | Thợ máy |
|-----------|---------|--------|----------|---------|
| HN-CG01 Cầu Giấy | `manager.cg@autocare.vn` | `reception1.cg@…`, `reception2.cg@…` | `cashier.cg@…` | `mechanic1.cg@…`, `mechanic2.cg@…`, `mechanic3.cg@…` |
| HN-HD01 Hà Đông | `manager.hd@autocare.vn` | `reception1.hd@…`, `reception2.hd@…` | `cashier.hd@…` | `mechanic1.hd@…` … `mechanic3.hd@…` |
| HCM-Q701 Quận 7 | `manager.q7@autocare.vn` | `reception1.q7@…`, `reception2.q7@…` | `cashier.q7@…` | `mechanic1.q7@…` … `mechanic3.q7@…` |

Quản trị hệ thống: `admin@autocare.vn`. Khách hàng: `customer1@gmail.com` … `customer12@gmail.com`.

## 4. Kịch bản demo có sẵn trong data (chi nhánh Cầu Giấy)

| Lệnh | Trạng thái ban đầu | Dùng để demo |
|------|--------------------|--------------|
| RO-261108-0003, RO-261108-0004 | NEW, chưa có thợ | UC27 phân công |
| RO-261108-0002 | ASSIGNED cho mechanic1 | UC29 bắt đầu làm |
| RO-261108-0001 | IN_PROGRESS, phụ tùng đã giữ chỗ | UC29, UC37 yêu cầu phụ tùng |
| RO-261107-0002 | IN_PROGRESS, có yêu cầu PR-261107-0002 chờ xuất | UC38 xuất kho (có phần giữ chỗ) |
| RO-261107-0003 | WAITING_PARTS (mechanic2), yêu cầu PR-261107-0003 chờ xuất | UC38 xuất từ tồn kho tự do, UC29 tiếp tục |
| RO-261107-0001 | IN_PROGRESS, mọi hạng mục DONE | UC32 thợ đánh dấu hoàn thành |
| RO-261106-0001 | COMPLETED, lịch hẹn IN_SERVICE | UC32 lễ tân xác nhận, chuyển thu ngân |

### Dữ liệu sẵn cho các UC của thành viên khác

| Nhóm UC | Dữ liệu |
|---------|---------|
| Đặt lịch (UC10–UC16) | Time slot 08:00–16:00 từ 01/10 đến 30/11/2026 cả 3 chi nhánh; lịch hẹn PENDING (APT-261109-0003, APT-261111-0001, APT-261112-0001/0002), CONFIRMED (APT-261109-0001/0002, APT-261110-0001, APT-261113-0001), CANCELLED, REJECTED |
| Tiếp nhận (UC17–UC22) | Hôm 09/11/2026: 2 xe CONFIRMED chờ nhận, APT-261109-0004 đã nhận chưa phân kiểm tra, APT-261109-0005 và APT-261108-0006 chờ thợ kiểm tra; APT-261108-0009 đã kiểm tra xong chờ báo giá |
| Báo giá / tạo lệnh (UC23–UC26) | QT-261108-0005 SENT chờ khách duyệt; QT-261108-0008 đã duyệt một phần, chờ tạo lệnh (có phụ tùng SHOCK-FR thiếu hàng) |
| Kho (UC33–UC40) | 20 phụ tùng, 3 kho, phiếu nhập, sổ kho 116 bút toán khớp tồn kho; WIPER-24 tồn thấp |
| Bảo hành (UC43–UC50) | 4 chính sách, 4 phiếu bảo hành, yêu cầu WQ-261107-0001 (SUBMITTED) và WQ-261106-0001 (ASSESSED) |
| Thanh toán (UC51–UC59) | Thuế VAT 8%/10% theo thời gian, cấu hình MISA meInvoice; APT-261105-0001 WAITING_PAYMENT chưa chốt chi phí (UC52); INV-261108-0001/0002 đã chốt chưa thu; INV-261107-0001 đã thu chờ HĐĐT & bàn giao; INV-261106-0001 HĐĐT bị MISA từ chối; INV-261107-0002 bảo hành 0 đ; 4 hóa đơn đã hoàn tất, 1 HĐĐT đã thay thế |
| Quản trị (UC60–UC65) | 3 chi nhánh, 22 nhân viên, 10 dịch vụ, 4 đánh giá dịch vụ |

## 5. Cấu trúc mã nguồn (theo Package Diagram IV.3.2)

```
backend/src
├── controller/   autocare.controller – REST endpoints (không chứa nghiệp vụ)
├── service/      autocare.service    – repair/, inventory/, account/, common/ (notification + audit)
├── dao/          autocare.dao        – truy vấn SQL đọc dữ liệu
├── model/        autocare.model      – TypeORM entities ↔ bảng PostgreSQL
├── dto/          autocare.dto        – dữ liệu vào có kiểm tra (class-validator)
├── common/       security (JWT, RolesGuard, BranchScope), util (sinh mã PR-yymmdd-nnnn)
└── config/       cấu hình từ .env
frontend/app
├── login/                      đăng nhập (nút chọn nhanh tài khoản demo)
├── (app)/repair-orders/        danh sách + chi tiết lệnh (UC27, UC29, UC32, UC37)
├── (app)/my-tasks/             công việc của thợ
└── (app)/part-requests/        danh sách + chi tiết yêu cầu (UC38)
```

## 6. Kiểm thử

`backend/test/smoke-test.mjs` chạy 53 kiểm tra đầu-cuối cho 5 UC (gồm các trường hợp bị từ chối: sai chi nhánh, sai vai trò, vượt số lượng, nhảy trạng thái…). Test **thay đổi dữ liệu**, nạp lại bằng `reset-db.ps1` sau khi chạy.

```powershell
.\database\reset-db.ps1; cd backend; npm start   # terminal 1
node test\smoke-test.mjs                         # terminal 2
```

## 7. Thay đổi so với thiết kế DB trong SRS (IV.5)

Đặc tả UC27/UC32/UC37 cần thêm: bảng `part_requests`, `part_request_items`, cột `repair_task_parts.request_item_id`, trạng thái `ASSIGNED` cho `repair_orders` và `WAITING_PAYMENT` cho `appointments`. Module của Huy (UC22, UC23) thêm bảng `inspection_items` (đề xuất của thợ, không có giá) và cột `quotation_items.expected_wait_days`. Module của Trâm (UC55) thêm cột `e_invoices.external_status`, `e_invoices.attempt_count` để truy vết HĐĐT (BR42). Schema hiện có 45 bảng.
