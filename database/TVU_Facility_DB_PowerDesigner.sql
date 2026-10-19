/* =========================================================================================
   HỆ THỐNG BÁO CÁO & THEO DÕI SỰ CỐ CƠ SỞ VẬT CHẤT - ĐẠI HỌC TRÀ VINH (TVU FACILITY)
   TẬP TIN DDL DÀNH RIÊNG CHO SAP / SYBASE POWERDESIGNER (REVERSE ENGINEER -> ERD)
   
   HƯỚNG DẪN IMPORT TRONG POWERDESIGNER:
   1. Mở PowerDesigner -> Vào menu: File -> Reverse Engineer -> Database...
   2. Đặt tên Model (Ví dụ: TVU_Facility_ERD)
   3. Chọn DBMS: "Microsoft SQL Server 2016" (hoặc 2012 / 2014 / 2019 / ANSI)
   4. Chọn "Using script files" -> Bấm biểu tượng Folder -> Chọn file này
   5. Bấm OK -> PowerDesigner sẽ tự động sinh Sơ đồ ERD (PDM/CDM) chuẩn 100% không lỗi!
   ========================================================================================= */

/* =========================================================================================
   1. BẢNG KHUÔN VIÊN TRƯỜNG (CAMPUSES)
   ========================================================================================= */
CREATE TABLE Campuses (
    Id INT NOT NULL,
    Name NVARCHAR(250) NOT NULL,
    Code NVARCHAR(50) NOT NULL,
    Address NVARCHAR(500) NULL,
    Description NVARCHAR(1000) NULL,
    CONSTRAINT PK_Campuses PRIMARY KEY (Id),
    CONSTRAINT UQ_Campuses_Code UNIQUE (Code)
);

/* =========================================================================================
   2. BẢNG TÒA NHÀ / DÃY PHÒNG (BUILDINGS)
   ========================================================================================= */
CREATE TABLE Buildings (
    Id INT NOT NULL,
    CampusId INT NOT NULL,
    Name NVARCHAR(250) NOT NULL,
    Code NVARCHAR(50) NOT NULL,
    TotalFloors INT NOT NULL,
    CONSTRAINT PK_Buildings PRIMARY KEY (Id),
    CONSTRAINT UQ_Buildings_Code UNIQUE (Code)
);

/* =========================================================================================
   3. BẢNG PHÒNG HỌC & TRANG THIẾT BỊ HIỆN TRẠNG (ROOMS)
   Trang bị chuẩn Khu A & B: 2 máy lạnh, quạt trần/quạt điện, 1 TV, 1 HDMI, 1 bảng, 14-18 bàn SV, 1 bàn GV
   ========================================================================================= */
CREATE TABLE Rooms (
    Id INT NOT NULL,
    BuildingId INT NOT NULL,
    RoomNumber NVARCHAR(50) NOT NULL,
    RoomType NVARCHAR(50) NOT NULL,
    Floor INT NOT NULL,
    QrCode NVARCHAR(100) NOT NULL,
    Description NVARCHAR(1000) NULL,
    AirConditioners INT NOT NULL,
    Fans INT NOT NULL,
    FanType NVARCHAR(50) NOT NULL,
    TvCount INT NOT NULL,
    HdmiPorts INT NOT NULL,
    Whiteboards INT NOT NULL,
    StudentDesks INT NOT NULL,
    TeacherDesks INT NOT NULL,
    IsActive BIT NOT NULL,
    CONSTRAINT PK_Rooms PRIMARY KEY (Id),
    CONSTRAINT UQ_Rooms_QrCode UNIQUE (QrCode)
);

/* =========================================================================================
   4. BẢNG DANH MỤC LOẠI SỰ CỐ (CATEGORIES)
   ========================================================================================= */
CREATE TABLE Categories (
    Id INT NOT NULL,
    Name NVARCHAR(200) NOT NULL,
    Icon NVARCHAR(100) NOT NULL,
    Description NVARCHAR(1000) NULL,
    CONSTRAINT PK_Categories PRIMARY KEY (Id)
);

/* =========================================================================================
   5. BẢNG NGƯỜI DÙNG HỆ THỐNG (USERS)
   Vai trò: Admin, Technician, Student, Lecturer
   ========================================================================================= */
CREATE TABLE Users (
    Id INT NOT NULL,
    Username NVARCHAR(100) NOT NULL,
    FullName NVARCHAR(200) NOT NULL,
    Email NVARCHAR(200) NOT NULL,
    PhoneNumber NVARCHAR(50) NULL,
    PasswordHash NVARCHAR(500) NOT NULL,
    Role NVARCHAR(50) NOT NULL,
    DepartmentOrClass NVARCHAR(200) NULL,
    CreatedAt DATETIME NOT NULL,
    IsActive BIT NOT NULL,
    CONSTRAINT PK_Users PRIMARY KEY (Id),
    CONSTRAINT UQ_Users_Username UNIQUE (Username),
    CONSTRAINT UQ_Users_Email UNIQUE (Email)
);

/* =========================================================================================
   6. BẢNG SỰ CỐ BÁO CÁO (INCIDENTS) - THỰC THỂ GIAO DỊCH TRUNG TÂM
   ========================================================================================= */
CREATE TABLE Incidents (
    Id INT NOT NULL,
    IncidentCode NVARCHAR(100) NOT NULL,
    Title NVARCHAR(300) NOT NULL,
    Description NVARCHAR(2000) NOT NULL,
    RoomId INT NOT NULL,
    CategoryId INT NOT NULL,
    SpecificLocation NVARCHAR(250) NULL,
    Priority NVARCHAR(50) NOT NULL,
    Status NVARCHAR(50) NOT NULL,
    ReportedByUserId INT NOT NULL,
    AssignedToUserId INT NULL,
    CreatedAt DATETIME NOT NULL,
    AssignedAt DATETIME NULL,
    ResolvedAt DATETIME NULL,
    ClosedAt DATETIME NULL,
    CONSTRAINT PK_Incidents PRIMARY KEY (Id),
    CONSTRAINT UQ_Incidents_IncidentCode UNIQUE (IncidentCode)
);

/* =========================================================================================
   7. BẢNG HÌNH ẢNH MINH CHỨNG (INCIDENT_IMAGES)
   Loại ảnh: Report (ảnh trước khi sửa) / Resolution (ảnh nghiệm thu sau khi sửa)
   ========================================================================================= */
CREATE TABLE IncidentImages (
    Id INT NOT NULL,
    IncidentId INT NOT NULL,
    ImageUrl NVARCHAR(500) NOT NULL,
    ImageType NVARCHAR(50) NOT NULL,
    UploadedAt DATETIME NOT NULL,
    UploadedByUserId INT NOT NULL,
    CONSTRAINT PK_IncidentImages PRIMARY KEY (Id)
);

/* =========================================================================================
   8. BẢNG LỊCH SỬ TIẾN TRÌNH XỬ LÝ (INCIDENT_HISTORIES)
   Lưu vết timeline thời gian: Ai chuyển trạng thái lúc nào, ghi chú kỹ thuật
   ========================================================================================= */
CREATE TABLE IncidentHistories (
    Id INT NOT NULL,
    IncidentId INT NOT NULL,
    UserId INT NOT NULL,
    PreviousStatus NVARCHAR(50) NULL,
    NewStatus NVARCHAR(50) NOT NULL,
    ActionNote NVARCHAR(2000) NOT NULL,
    CreatedAt DATETIME NOT NULL,
    CONSTRAINT PK_IncidentHistories PRIMARY KEY (Id)
);

/* =========================================================================================
   9. BẢNG ĐÁNH GIÁ NGHIỆM THU (INCIDENT_FEEDBACKS)
   Quan hệ 1:1 với Incident - Đánh giá từ 1 đến 5 sao và nhận xét nghiệm thu
   ========================================================================================= */
CREATE TABLE IncidentFeedbacks (
    Id INT NOT NULL,
    IncidentId INT NOT NULL,
    UserId INT NOT NULL,
    Rating INT NOT NULL,
    Comment NVARCHAR(2000) NULL,
    CreatedAt DATETIME NOT NULL,
    CONSTRAINT PK_IncidentFeedbacks PRIMARY KEY (Id),
    CONSTRAINT UQ_IncidentFeedbacks_IncidentId UNIQUE (IncidentId)
);

/* =========================================================================================
   10. BẢNG THÔNG BÁO HỆ THỐNG (NOTIFICATIONS)
   ========================================================================================= */
CREATE TABLE Notifications (
    Id INT NOT NULL,
    UserId INT NOT NULL,
    Title NVARCHAR(250) NOT NULL,
    Message NVARCHAR(2000) NOT NULL,
    IncidentId INT NULL,
    IsRead BIT NOT NULL,
    CreatedAt DATETIME NOT NULL,
    CONSTRAINT PK_Notifications PRIMARY KEY (Id)
);

/* =========================================================================================
   ĐỊNH NGHĨA CÁC RÀNG BUỘC KHÓA NGOẠI (FOREIGN KEY CONSTRAINTS)
   PowerDesigner sẽ tự động vẽ các đường quan hệ 1-N và tạo Sơ đồ ERD hoàn chỉnh
   ========================================================================================= */

-- 1. Tòa nhà thuộc Khuôn viên (Campuses -> Buildings: 1 - N)
ALTER TABLE Buildings ADD CONSTRAINT FK_Buildings_Campuses
    FOREIGN KEY (CampusId) REFERENCES Campuses (Id);

-- 2. Phòng học thuộc Tòa nhà (Buildings -> Rooms: 1 - N)
ALTER TABLE Rooms ADD CONSTRAINT FK_Rooms_Buildings
    FOREIGN KEY (BuildingId) REFERENCES Buildings (Id);

-- 3. Sự cố xảy ra tại Phòng học (Rooms -> Incidents: 1 - N)
ALTER TABLE Incidents ADD CONSTRAINT FK_Incidents_Rooms
    FOREIGN KEY (RoomId) REFERENCES Rooms (Id);

-- 4. Sự cố thuộc Danh mục (Categories -> Incidents: 1 - N)
ALTER TABLE Incidents ADD CONSTRAINT FK_Incidents_Categories
    FOREIGN KEY (CategoryId) REFERENCES Categories (Id);

-- 5. Sự cố được Báo cáo bởi Người dùng (Users -> Incidents: 1 - N)
ALTER TABLE Incidents ADD CONSTRAINT FK_Incidents_ReportedUser
    FOREIGN KEY (ReportedByUserId) REFERENCES Users (Id);

-- 6. Sự cố được Giao việc cho Kỹ thuật viên (Users -> Incidents: 0..1 - N)
ALTER TABLE Incidents ADD CONSTRAINT FK_Incidents_AssignedUser
    FOREIGN KEY (AssignedToUserId) REFERENCES Users (Id);

-- 7. Hình ảnh thuộc Sự cố (Incidents -> IncidentImages: 1 - N)
ALTER TABLE IncidentImages ADD CONSTRAINT FK_IncidentImages_Incidents
    FOREIGN KEY (IncidentId) REFERENCES Incidents (Id);

-- 8. Hình ảnh được tải lên bởi Người dùng (Users -> IncidentImages: 1 - N)
ALTER TABLE IncidentImages ADD CONSTRAINT FK_IncidentImages_Users
    FOREIGN KEY (UploadedByUserId) REFERENCES Users (Id);

-- 9. Lịch sử thuộc Sự cố (Incidents -> IncidentHistories: 1 - N)
ALTER TABLE IncidentHistories ADD CONSTRAINT FK_IncidentHistories_Incidents
    FOREIGN KEY (IncidentId) REFERENCES Incidents (Id);

-- 10. Lịch sử được cập nhật bởi Người dùng (Users -> IncidentHistories: 1 - N)
ALTER TABLE IncidentHistories ADD CONSTRAINT FK_IncidentHistories_Users
    FOREIGN KEY (UserId) REFERENCES Users (Id);

-- 11. Đánh giá nghiệm thu thuộc Sự cố (Incidents -> IncidentFeedbacks: 1 - 0..1)
ALTER TABLE IncidentFeedbacks ADD CONSTRAINT FK_IncidentFeedbacks_Incidents
    FOREIGN KEY (IncidentId) REFERENCES Incidents (Id);

-- 12. Đánh giá được thực hiện bởi Người dùng (Users -> IncidentFeedbacks: 1 - N)
ALTER TABLE IncidentFeedbacks ADD CONSTRAINT FK_IncidentFeedbacks_Users
    FOREIGN KEY (UserId) REFERENCES Users (Id);

-- 13. Thông báo gửi đến Người dùng (Users -> Notifications: 1 - N)
ALTER TABLE Notifications ADD CONSTRAINT FK_Notifications_Users
    FOREIGN KEY (UserId) REFERENCES Users (Id);

-- 14. Thông báo liên quan đến Sự cố (Incidents -> Notifications: 0..1 - N)
ALTER TABLE Notifications ADD CONSTRAINT FK_Notifications_Incidents
    FOREIGN KEY (IncidentId) REFERENCES Incidents (Id);
