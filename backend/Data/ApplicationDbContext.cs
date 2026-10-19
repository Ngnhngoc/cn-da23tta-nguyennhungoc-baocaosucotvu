using Microsoft.EntityFrameworkCore;
using backend.Models;

namespace backend.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<Campus> Campuses => Set<Campus>();
    public DbSet<Building> Buildings => Set<Building>();
    public DbSet<Room> Rooms => Set<Room>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Incident> Incidents => Set<Incident>();
    public DbSet<IncidentImage> IncidentImages => Set<IncidentImage>();
    public DbSet<IncidentHistory> IncidentHistories => Set<IncidentHistory>();
    public DbSet<IncidentFeedback> IncidentFeedbacks => Set<IncidentFeedback>();
    public DbSet<Notification> Notifications => Set<Notification>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // 1. KHUÔN VIÊN (khuon_vien)
        modelBuilder.Entity<Campus>(b =>
        {
            b.ToTable("khuon_vien");
            b.HasKey(c => c.Id);
            b.Property(c => c.Id).HasColumnName("ma_khuon_vien");
            b.Property(c => c.Name).HasColumnName("ten_khuon_vien").HasMaxLength(250).IsRequired();
            b.Property(c => c.Code).HasColumnName("ma_viet_tat").HasMaxLength(50).IsRequired();
            b.Property(c => c.Address).HasColumnName("dia_chi").HasMaxLength(500);
            b.Property(c => c.Description).HasColumnName("mo_ta");
            b.HasIndex(c => c.Code).IsUnique();
        });

        // 2. DÃY NHÀ (day_nha)
        modelBuilder.Entity<Building>(b =>
        {
            b.ToTable("day_nha");
            b.HasKey(x => x.Id);
            b.Property(x => x.Id).HasColumnName("ma_day_nha");
            b.Property(x => x.CampusId).HasColumnName("ma_khuon_vien");
            b.Property(x => x.Name).HasColumnName("ten_day_nha").HasMaxLength(250).IsRequired();
            b.Property(x => x.Code).HasColumnName("ma_toa").HasMaxLength(50).IsRequired();
            b.Property(x => x.TotalFloors).HasColumnName("tong_so_tang");

            b.HasIndex(x => x.Code).IsUnique();
            b.HasOne(x => x.Campus)
                .WithMany(c => c.Buildings)
                .HasForeignKey(x => x.CampusId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // 3. PHÒNG HỌC & TRANG THIẾT BỊ (phong_hoc)
        modelBuilder.Entity<Room>(b =>
        {
            b.ToTable("phong_hoc");
            b.HasKey(x => x.Id);
            b.Property(x => x.Id).HasColumnName("ma_phong_hoc");
            b.Property(x => x.BuildingId).HasColumnName("ma_day_nha");
            b.Property(x => x.RoomNumber).HasColumnName("so_phong").HasMaxLength(50).IsRequired();
            b.Property(x => x.RoomType).HasColumnName("loai_phong").HasMaxLength(50).IsRequired();
            b.Property(x => x.Floor).HasColumnName("tang_so");
            b.Property(x => x.QrCode).HasColumnName("ma_qr_dinh_danh").HasMaxLength(100).IsRequired();
            
            // Thiết bị phòng học Khu A & Khu B
            b.Property(x => x.AirConditionerCount).HasColumnName("so_may_lanh");
            b.Property(x => x.FanCount).HasColumnName("so_quat");
            b.Property(x => x.FanType).HasColumnName("loai_quat").HasMaxLength(50);
            b.Property(x => x.TvCount).HasColumnName("so_tivi");
            b.Property(x => x.HdmiCount).HasColumnName("so_cong_hdmi");
            b.Property(x => x.BoardCount).HasColumnName("so_bang_viet");
            b.Property(x => x.StudentDeskCount).HasColumnName("so_ban_sinh_vien");
            b.Property(x => x.TeacherDeskCount).HasColumnName("so_ban_giao_vien");
            b.Property(x => x.Description).HasColumnName("mo_ta_hien_trang");
            b.Property(x => x.IsActive).HasColumnName("dang_su_dung");

            b.HasIndex(x => x.QrCode).IsUnique();
            b.HasOne(x => x.Building)
                .WithMany(bld => bld.Rooms)
                .HasForeignKey(x => x.BuildingId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // 4. LOẠI SỰ CỐ (loai_su_co)
        modelBuilder.Entity<Category>(b =>
        {
            b.ToTable("loai_su_co");
            b.HasKey(x => x.Id);
            b.Property(x => x.Id).HasColumnName("ma_loai_su_co");
            b.Property(x => x.Name).HasColumnName("ten_loai_su_co").HasMaxLength(200).IsRequired();
            b.Property(x => x.Icon).HasColumnName("bieu_tuong").HasMaxLength(100);
            b.Property(x => x.Description).HasColumnName("mo_ta_chi_tiet");
        });

        // 5. NGƯỜI DÙNG (nguoi_dung)
        modelBuilder.Entity<User>(b =>
        {
            b.ToTable("nguoi_dung");
            b.HasKey(x => x.Id);
            b.Property(x => x.Id).HasColumnName("ma_nguoi_dung");
            b.Property(x => x.Username).HasColumnName("ten_dang_nhap").HasMaxLength(100).IsRequired();
            b.Property(x => x.FullName).HasColumnName("ho_va_ten").HasMaxLength(200).IsRequired();
            b.Property(x => x.Email).HasColumnName("email_tvu").HasMaxLength(200).IsRequired();
            b.Property(x => x.PhoneNumber).HasColumnName("so_dien_thoai").HasMaxLength(50);
            b.Property(x => x.PasswordHash).HasColumnName("mat_khau_ma_hoa").HasMaxLength(500).IsRequired();
            b.Property(x => x.Role).HasColumnName("vai_tro").HasMaxLength(50).IsRequired();
            b.Property(x => x.DepartmentOrClass).HasColumnName("lop_hoac_don_vi").HasMaxLength(200);
            b.Property(x => x.CreatedAt).HasColumnName("ngay_tao");
            b.Property(x => x.IsActive).HasColumnName("dang_hoat_dong");

            b.HasIndex(x => x.Username).IsUnique();
            b.HasIndex(x => x.Email).IsUnique();
        });

        // 6. SỰ CỐ (su_co)
        modelBuilder.Entity<Incident>(b =>
        {
            b.ToTable("su_co");
            b.HasKey(x => x.Id);
            b.Property(x => x.Id).HasColumnName("ma_su_co_id");
            b.Property(x => x.IncidentCode).HasColumnName("ma_phieu_su_co").HasMaxLength(100).IsRequired();
            b.Property(x => x.Title).HasColumnName("tieu_de").HasMaxLength(300).IsRequired();
            b.Property(x => x.Description).HasColumnName("mo_ta_hu_hong").IsRequired();
            b.Property(x => x.RoomId).HasColumnName("ma_phong_hoc");
            b.Property(x => x.CategoryId).HasColumnName("ma_loai_su_co");
            b.Property(x => x.SpecificLocation).HasColumnName("vi_tri_trong_phong").HasMaxLength(250);
            b.Property(x => x.Priority).HasColumnName("muc_do_uu_tien").HasMaxLength(50).IsRequired();
            b.Property(x => x.Status).HasColumnName("trang_thai").HasMaxLength(50).IsRequired();
            b.Property(x => x.ReportedByUserId).HasColumnName("nguoi_bao_cao_id");
            b.Property(x => x.AssignedToUserId).HasColumnName("ky_thuat_vien_id");
            b.Property(x => x.CreatedAt).HasColumnName("ngay_gui_bao_cao");
            b.Property(x => x.AssignedAt).HasColumnName("ngay_phan_cong");
            b.Property(x => x.ResolvedAt).HasColumnName("ngay_hoan_thanh");
            b.Property(x => x.ClosedAt).HasColumnName("ngay_dong_phieu");

            b.HasIndex(x => x.IncidentCode).IsUnique();

            b.HasOne(i => i.ReportedByUser)
                .WithMany()
                .HasForeignKey(i => i.ReportedByUserId)
                .OnDelete(DeleteBehavior.Restrict);

            b.HasOne(i => i.AssignedToUser)
                .WithMany()
                .HasForeignKey(i => i.AssignedToUserId)
                .OnDelete(DeleteBehavior.SetNull);

            b.HasOne(i => i.Room)
                .WithMany()
                .HasForeignKey(i => i.RoomId)
                .OnDelete(DeleteBehavior.Restrict);

            b.HasOne(i => i.Category)
                .WithMany()
                .HasForeignKey(i => i.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            b.HasMany(i => i.Images)
                .WithOne(img => img.Incident)
                .HasForeignKey(img => img.IncidentId)
                .OnDelete(DeleteBehavior.Cascade);

            b.HasMany(i => i.Histories)
                .WithOne(h => h.Incident)
                .HasForeignKey(h => h.IncidentId)
                .OnDelete(DeleteBehavior.Cascade);

            b.HasOne(i => i.Feedback)
                .WithOne(f => f.Incident)
                .HasForeignKey<IncidentFeedback>(f => f.IncidentId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // 7. HÌNH ẢNH SỰ CỐ (hinh_anh_su_co)
        modelBuilder.Entity<IncidentImage>(b =>
        {
            b.ToTable("hinh_anh_su_co");
            b.HasKey(x => x.Id);
            b.Property(x => x.Id).HasColumnName("ma_hinh_anh");
            b.Property(x => x.IncidentId).HasColumnName("ma_su_co_id");
            b.Property(x => x.ImageUrl).HasColumnName("duong_dan_anh").HasMaxLength(500).IsRequired();
            b.Property(x => x.ImageType).HasColumnName("loai_hinh_anh").HasMaxLength(50).IsRequired();
            b.Property(x => x.UploadedAt).HasColumnName("ngay_chup_anh");
            b.Property(x => x.UploadedByUserId).HasColumnName("nguoi_chup_id");
        });

        // 8. LỊCH SỬ XỬ LÝ (lich_su_xu_ly)
        modelBuilder.Entity<IncidentHistory>(b =>
        {
            b.ToTable("lich_su_xu_ly");
            b.HasKey(x => x.Id);
            b.Property(x => x.Id).HasColumnName("ma_lich_su");
            b.Property(x => x.IncidentId).HasColumnName("ma_su_co_id");
            b.Property(x => x.UserId).HasColumnName("nguoi_thuc_hien_id");
            b.Property(x => x.PreviousStatus).HasColumnName("trang_thai_cu").HasMaxLength(50);
            b.Property(x => x.NewStatus).HasColumnName("trang_thai_moi").HasMaxLength(50).IsRequired();
            b.Property(x => x.ActionNote).HasColumnName("noi_dung_ghi_chu").IsRequired();
            b.Property(x => x.CreatedAt).HasColumnName("thoi_gian_cap_nhat");
        });

        // 9. ĐÁNH GIÁ NGHIỆM THU (danh_gia_nghiem_thu)
        modelBuilder.Entity<IncidentFeedback>(b =>
        {
            b.ToTable("danh_gia_nghiem_thu");
            b.HasKey(x => x.Id);
            b.Property(x => x.Id).HasColumnName("ma_danh_gia");
            b.Property(x => x.IncidentId).HasColumnName("ma_su_co_id");
            b.Property(x => x.UserId).HasColumnName("nguoi_danh_gia_id");
            b.Property(x => x.Rating).HasColumnName("so_sao_hai_long");
            b.Property(x => x.Comment).HasColumnName("y_kien_phan_hoi");
            b.Property(x => x.CreatedAt).HasColumnName("ngay_danh_gia");
        });

        // 10. THÔNG BÁO (thong_bao)
        modelBuilder.Entity<Notification>(b =>
        {
            b.ToTable("thong_bao");
            b.HasKey(x => x.Id);
            b.Property(x => x.Id).HasColumnName("ma_thong_bao");
            b.Property(x => x.UserId).HasColumnName("nguoi_nhan_id");
            b.Property(x => x.Title).HasColumnName("tieu_de").HasMaxLength(250).IsRequired();
            b.Property(x => x.Message).HasColumnName("noi_dung_thong_bao").IsRequired();
            b.Property(x => x.IncidentId).HasColumnName("ma_su_co_id");
            b.Property(x => x.IsRead).HasColumnName("da_doc");
            b.Property(x => x.CreatedAt).HasColumnName("ngay_gui");
        });

        // Seed Initial Master Data for Tra Vinh University
        SeedData(modelBuilder);
    }

    private static void SeedData(ModelBuilder modelBuilder)
    {
        // 1. Khuôn viên (Campuses)
        modelBuilder.Entity<Campus>().HasData(
            new Campus
            {
                Id = 1,
                Name = "Khu 1 - Đại học Trà Vinh (Cơ sở chính)",
                Code = "KHU1",
                Address = "Số 126 Nguyễn Thiện Thành, Khóm 4, Phường 5, TP. Trà Vinh, Tỉnh Trà Vinh",
                Description = "Khuôn viên trung tâm bao gồm Ban Giám hiệu, Khoa Kỹ thuật & Công nghệ, Khoa Y Dược..."
            },
            new Campus
            {
                Id = 2,
                Name = "Khu 2 - Đại học Trà Vinh",
                Code = "KHU2",
                Address = "Xã Hòa Thuận, Huyện Châu Thành, Tỉnh Trà Vinh",
                Description = "Khu thực nghiệm Nông nghiệp, Thủy sản và Ký túc xá"
            }
        );

        // 2. Dãy nhà (Buildings)
        modelBuilder.Entity<Building>().HasData(
            new Building { Id = 1, CampusId = 1, Code = "B3", Name = "Dãy B3 - Khoa Kỹ thuật & Công nghệ (Khu B)", TotalFloors = 4 },
            new Building { Id = 2, CampusId = 1, Code = "A4", Name = "Dãy A4 - Giảng đường Lý thuyết (Khu A)", TotalFloors = 4 },
            new Building { Id = 3, CampusId = 1, Code = "A1", Name = "Tòa nhà A1 - Nhà Hiệu bộ & Ban Quản trị CSVC", TotalFloors = 5 },
            new Building { Id = 4, CampusId = 1, Code = "D1", Name = "Dãy D1 - Khu Xưởng Thực hành & Cơ khí", TotalFloors = 3 }
        );

        // 3. Phòng học & Trang thiết bị hiện trạng (Rooms)
        // Chuẩn trang bị Khu A & B: 2 máy lạnh, 2 quạt trần (hoặc 4 quạt điện), 1 Tivi, 1 HDMI, 1 bảng viết, 14-18 bàn SV, 1 bàn GV
        modelBuilder.Entity<Room>().HasData(
            new Room 
            { 
                Id = 1, 
                BuildingId = 1, 
                RoomNumber = "B31.101", 
                RoomType = "LectureHall", 
                Floor = 1, 
                QrCode = "TVU-B31.101", 
                AirConditionerCount = 2, 
                FanCount = 2, 
                FanType = "Quạt trần", 
                TvCount = 1, 
                HdmiCount = 1, 
                BoardCount = 1, 
                StudentDeskCount = 16, 
                TeacherDeskCount = 1, 
                Description = "Phòng học Dãy B: 16 bàn SV, 1 bàn GV, 2 máy lạnh, 2 quạt trần, 1 Tivi, 1 cổng HDMI, 1 bảng viết",
                IsActive = true 
            },
            new Room 
            { 
                Id = 2, 
                BuildingId = 1, 
                RoomNumber = "B31.102", 
                RoomType = "LectureHall", 
                Floor = 1, 
                QrCode = "TVU-B31.102", 
                AirConditionerCount = 2, 
                FanCount = 4, 
                FanType = "Quạt điện", 
                TvCount = 1, 
                HdmiCount = 1, 
                BoardCount = 1, 
                StudentDeskCount = 14, 
                TeacherDeskCount = 1, 
                Description = "Phòng học Dãy B: 14 bàn SV, 1 bàn GV, 2 máy lạnh, 4 quạt điện, 1 Tivi, 1 cổng HDMI, 1 bảng viết",
                IsActive = true 
            },
            new Room 
            { 
                Id = 3, 
                BuildingId = 2, 
                RoomNumber = "A42.103", 
                RoomType = "LectureHall", 
                Floor = 2, 
                QrCode = "TVU-A42.103", 
                AirConditionerCount = 2, 
                FanCount = 2, 
                FanType = "Quạt trần", 
                TvCount = 1, 
                HdmiCount = 1, 
                BoardCount = 1, 
                StudentDeskCount = 18, 
                TeacherDeskCount = 1, 
                Description = "Phòng học Dãy A: 18 bàn SV, 1 bàn GV, 2 máy lạnh, 2 quạt trần, 1 Tivi, 1 cổng HDMI, 1 bảng viết",
                IsActive = true 
            },
            new Room 
            { 
                Id = 4, 
                BuildingId = 2, 
                RoomNumber = "A42.204", 
                RoomType = "LectureHall", 
                Floor = 2, 
                QrCode = "TVU-A42.204", 
                AirConditionerCount = 2, 
                FanCount = 4, 
                FanType = "Quạt điện", 
                TvCount = 1, 
                HdmiCount = 1, 
                BoardCount = 1, 
                StudentDeskCount = 16, 
                TeacherDeskCount = 1, 
                Description = "Phòng học Dãy A: 16 bàn SV, 1 bàn GV, 2 máy lạnh, 4 quạt điện, 1 Tivi, 1 cổng HDMI, 1 bảng viết",
                IsActive = true 
            },
            new Room 
            { 
                Id = 5, 
                BuildingId = 1, 
                RoomNumber = "B32.201", 
                RoomType = "ComputerLab", 
                Floor = 2, 
                QrCode = "TVU-B32.201", 
                AirConditionerCount = 2, 
                FanCount = 4, 
                FanType = "Quạt điện", 
                TvCount = 1, 
                HdmiCount = 1, 
                BoardCount = 1, 
                StudentDeskCount = 15, 
                TeacherDeskCount = 1, 
                Description = "Phòng Lab máy tính 1: 45 máy, 1 bàn GV, 2 máy lạnh, 4 quạt điện, 1 Tivi, 1 cổng HDMI, 1 bảng viết",
                IsActive = true 
            },
            new Room 
            { 
                Id = 6, 
                BuildingId = 1, 
                RoomNumber = "B32.202", 
                RoomType = "ComputerLab", 
                Floor = 2, 
                QrCode = "TVU-B32.202", 
                AirConditionerCount = 2, 
                FanCount = 4, 
                FanType = "Quạt điện", 
                TvCount = 1, 
                HdmiCount = 1, 
                BoardCount = 1, 
                StudentDeskCount = 15, 
                TeacherDeskCount = 1, 
                Description = "Phòng Lab máy tính 2: 45 máy, 1 bàn GV, 2 máy lạnh, 4 quạt điện, 1 Tivi, 1 cổng HDMI, 1 bảng viết",
                IsActive = true 
            },
            new Room 
            { 
                Id = 7, 
                BuildingId = 3, 
                RoomNumber = "A12.201", 
                RoomType = "Office", 
                Floor = 2, 
                QrCode = "TVU-A12.201", 
                AirConditionerCount = 2, 
                FanCount = 2, 
                FanType = "Quạt trần", 
                TvCount = 1, 
                HdmiCount = 1, 
                BoardCount = 1, 
                StudentDeskCount = 0, 
                TeacherDeskCount = 4, 
                Description = "Văn phòng Phòng Quản trị Cơ sở vật chất TVU",
                IsActive = true 
            }
        );

        // 4. Loại sự cố (Categories)
        modelBuilder.Entity<Category>().HasData(
            new Category { Id = 1, Name = "Hệ thống điện & Chiếu sáng", Icon = "lightbulb", Description = "Đèn phòng chập cháy, mất điện, ổ cắm lỏng, công tắc hư hỏng" },
            new Category { Id = 2, Name = "Máy lạnh & Quạt làm mát", Icon = "ac_unit", Description = "Máy lạnh chảy nước, không lạnh, quạt trần/quạt treo tường kêu to hoặc ngừng quay" },
            new Category { Id = 3, Name = "Thiết bị Tivi, HDMI & CNTT", Icon = "computer", Description = "Tivi không lên nguồn, cáp HDMI chập chờn, máy tính phòng Lab kẹt phím chuột" },
            new Category { Id = 4, Name = "Bàn ghế & Bảng giảng dạy", Icon = "chair", Description = "Bàn học lung lay, gãy chân, bảng mica trắng ố mờ khó xóa, hỏng rèm cửa" },
            new Category { Id = 5, Name = "Cấp thoát nước & Vệ sinh", Icon = "water_drop", Description = "Vòi nước rò rỉ, bồn rửa nghẹt, thiết bị vệ sinh hỏng" },
            new Category { Id = 6, Name = "Vệ sinh môi trường & Khác", Icon = "cleaning_services", Description = "Kẹt khóa cửa phòng, rác thải tồn đọng, kiểm định bình PCCC" }
        );

        // 5. Người dùng mặc định (Mật khẩu: "Tvu@123456")
        modelBuilder.Entity<User>().HasData(
            new User
            {
                Id = 1,
                Username = "admin_csvc",
                FullName = "ThS. Nguyễn Văn Quản (Quản lý CSVC TVU)",
                Email = "csvc@tvu.edu.vn",
                PhoneNumber = "02943855246",
                PasswordHash = "$2a$11$N.csqw2fV2G08J73QcR6kOMWvF/i9qO14uP7iR264J0vB039a0U8K",
                Role = "Admin",
                DepartmentOrClass = "Phòng Quản trị Thiết bị & CSVC",
                CreatedAt = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                IsActive = true
            },
            new User
            {
                Id = 2,
                Username = "ktv_dienlanh",
                FullName = "Trần Kỹ Thuật (Tổ Điện - Điện Lạnh)",
                Email = "dienlanh@tvu.edu.vn",
                PhoneNumber = "0912345678",
                PasswordHash = "$2a$11$N.csqw2fV2G08J73QcR6kOMWvF/i9qO14uP7iR264J0vB039a0U8K",
                Role = "Technician",
                DepartmentOrClass = "Đội ngũ Bảo trì CSVC TVU",
                CreatedAt = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                IsActive = true
            },
            new User
            {
                Id = 3,
                Username = "ktv_it",
                FullName = "Lê Tin Học (Tổ Hỗ trợ Thiết bị CNTT)",
                Email = "it_support@tvu.edu.vn",
                PhoneNumber = "0987654321",
                PasswordHash = "$2a$11$N.csqw2fV2G08J73QcR6kOMWvF/i9qO14uP7iR264J0vB039a0U8K",
                Role = "Technician",
                DepartmentOrClass = "Trung tâm CNTT TVU",
                CreatedAt = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                IsActive = true
            },
            new User
            {
                Id = 4,
                Username = "110121001",
                FullName = "Nguyễn Minh Khang (Sinh viên DA21TT)",
                Email = "110121001@st.tvu.edu.vn",
                PhoneNumber = "0939112233",
                PasswordHash = "$2a$11$N.csqw2fV2G08J73QcR6kOMWvF/i9qO14uP7iR264J0vB039a0U8K",
                Role = "Student",
                DepartmentOrClass = "Lớp DA21TT - CNTT",
                CreatedAt = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                IsActive = true
            },
            new User
            {
                Id = 5,
                Username = "gv_lamthanh",
                FullName = "TS. Lâm Thành (Giảng viên Khoa KT&CN)",
                Email = "lamthanh@tvu.edu.vn",
                PhoneNumber = "0949887766",
                PasswordHash = "$2a$11$N.csqw2fV2G08J73QcR6kOMWvF/i9qO14uP7iR264J0vB039a0U8K",
                Role = "Lecturer",
                DepartmentOrClass = "Bộ môn Công nghệ Thông tin",
                CreatedAt = new DateTime(2026, 1, 1, 0, 0, 0, DateTimeKind.Utc),
                IsActive = true
            }
        );
    }
}
