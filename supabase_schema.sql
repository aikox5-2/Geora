-- ==============================================================================
-- GEORA APLIKASI ABSENSI SEKOLAH - SUPABASE SQL SCHEMA RESMI & BERSIH
-- Disesuaikan 100% untuk SMK Negeri 8 Malang
-- Fitur: Reset 00:00 / Admin Reset, Upload Bukti Kamera & Surat ke Storage,
--        Konfigurasi Radius & Lokasi Sekolah, CRUD Kelas & Wali Kelas,
--        Sinkronisasi Profil Siswa, Guru, dan Admin.
-- ==============================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==============================================================================
-- 2. HAPUS TABEL LAMA DENGAN AMAN (CASCADE)
-- ==============================================================================
DROP TABLE IF EXISTS aktifitas CASCADE;
DROP TABLE IF EXISTS notifikasi CASCADE;
DROP TABLE IF EXISTS bukti_absen CASCADE;
DROP TABLE IF EXISTS pengajuan_absen CASCADE;
DROP TABLE IF EXISTS absensi CASCADE;
DROP TABLE IF EXISTS konfigurasi_absen CASCADE;
DROP TABLE IF EXISTS anggota_kelas CASCADE;
DROP TABLE IF EXISTS siswa CASCADE;
DROP TABLE IF EXISTS kelas CASCADE;
DROP TABLE IF EXISTS tahun_ajaran CASCADE;
DROP TABLE IF EXISTS guru CASCADE;
DROP TABLE IF EXISTS admin CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS sekolah CASCADE;

-- ==============================================================================
-- 3. TABEL UTAMA SESUAI STRUKTUR ERD GEORA
-- ==============================================================================

-- 3.1 SEKOLAH
CREATE TABLE sekolah (
    id_sekolah UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nama_sekolah VARCHAR(255) NOT NULL,
    alamat TEXT,
    latitude DOUBLE PRECISION DEFAULT -7.93557,
    longitude DOUBLE PRECISION DEFAULT 112.6595,
    radius_meter DOUBLE PRECISION DEFAULT 300,
    status VARCHAR(50) DEFAULT 'aktif',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3.2 USER (Pengguna Aplikasi: Admin, Guru, Siswa)
CREATE TABLE users (
    id_user UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sekolah_id UUID REFERENCES sekolah(id_sekolah) ON DELETE CASCADE,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('admin', 'guru', 'siswa')),
    nama VARCHAR(255),
    no_hp VARCHAR(50),
    alamat TEXT,
    status VARCHAR(50) DEFAULT 'aktif',
    last_login TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3.2.1 ADMIN (Profil Administrator Sekolah)
CREATE TABLE admin (
    id_admin UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id_user) ON DELETE CASCADE,
    sekolah_id UUID REFERENCES sekolah(id_sekolah) ON DELETE CASCADE,
    nama VARCHAR(255) NOT NULL DEFAULT 'Administrator',
    email VARCHAR(255),
    no_hp VARCHAR(50) DEFAULT '081234567890',
    alamat TEXT DEFAULT 'Jl. Pendidikan No. 10, Blitar',
    jabatan VARCHAR(100) DEFAULT 'Administrator',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3.3 GURU
CREATE TABLE guru (
    id_guru UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id_user) ON DELETE CASCADE,
    sekolah_id UUID REFERENCES sekolah(id_sekolah) ON DELETE CASCADE,
    nama VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    no_hp VARCHAR(50),
    alamat TEXT,
    jabatan VARCHAR(100) DEFAULT 'Guru Pengajar',
    nip VARCHAR(50) UNIQUE,
    mapel VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3.4 TAHUN AJARAN
CREATE TABLE tahun_ajaran (
    id_tahun UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sekolah_id UUID REFERENCES sekolah(id_sekolah) ON DELETE CASCADE,
    tahun VARCHAR(20) NOT NULL, -- Contoh: '2026/2027'
    semester VARCHAR(20) NOT NULL, -- Contoh: 'Ganjil' / 'Genap'
    tahun_mulai DATE,
    tahun_akhir DATE,
    status VARCHAR(20) DEFAULT 'aktif',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3.5 KELAS
CREATE TABLE kelas (
    id_kelas UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sekolah_id UUID REFERENCES sekolah(id_sekolah) ON DELETE CASCADE,
    guru_id UUID REFERENCES guru(id_guru) ON DELETE SET NULL, -- Wali Kelas
    tingkat VARCHAR(20) NOT NULL, -- Contoh: 'XII'
    jurusan VARCHAR(100) NOT NULL, -- Contoh: 'Rekayasa Perangkat Lunak D'
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3.6 SISWA
CREATE TABLE siswa (
    id_siswa UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id_user) ON DELETE CASCADE,
    sekolah_id UUID REFERENCES sekolah(id_sekolah) ON DELETE CASCADE,
    nama_siswa VARCHAR(255) NOT NULL,
    kelas_id UUID REFERENCES kelas(id_kelas) ON DELETE SET NULL,
    jurusan VARCHAR(100),
    jenis_kelamin VARCHAR(20),
    tanggal_lahir DATE,
    no_hp VARCHAR(50),
    alamat TEXT,
    nis VARCHAR(50),
    nisn VARCHAR(50) UNIQUE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3.7 ANGGOTA KELAS
CREATE TABLE anggota_kelas (
    id_anggota_kelas UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    siswa_id UUID REFERENCES siswa(id_siswa) ON DELETE CASCADE,
    kelas_id UUID REFERENCES kelas(id_kelas) ON DELETE CASCADE,
    tahun_ajaran_id UUID REFERENCES tahun_ajaran(id_tahun) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'aktif',
    created_at TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT unique_siswa_kelas_tahun UNIQUE (siswa_id, kelas_id, tahun_ajaran_id)
);

-- 3.8 KONFIGURASI ABSEN
CREATE TABLE konfigurasi_absen (
    id_konfig UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sekolah_id UUID REFERENCES sekolah(id_sekolah) ON DELETE CASCADE,
    hari VARCHAR(20) NOT NULL,
    jam_mulai TIME NOT NULL DEFAULT '06:00:00',
    jam_selesai TIME NOT NULL DEFAULT '08:00:00',
    batas_terlambat TIME NOT NULL DEFAULT '07:00:00',
    lokasi TEXT DEFAULT 'SMK Negeri 8 Malang',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3.9 ABSENSI (Absen hanya 1x per hari per siswa)
CREATE TABLE absensi (
    id_absen UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    siswa_id UUID REFERENCES siswa(id_siswa) ON DELETE CASCADE,
    guru_id UUID REFERENCES guru(id_guru) ON DELETE SET NULL,
    konfig_id UUID REFERENCES konfigurasi_absen(id_konfig) ON DELETE SET NULL,
    tanggal DATE NOT NULL DEFAULT CURRENT_DATE,
    jam_absen TIME NOT NULL DEFAULT CURRENT_TIME,
    status VARCHAR(20) NOT NULL CHECK (status IN ('hadir', 'terlambat', 'izin', 'sakit', 'alpha')),
    metode VARCHAR(50) DEFAULT 'otomatis', -- 'otomatis', 'manual', 'kamera'
    keterangan TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    akurasi_m DOUBLE PRECISION,
    lokasi TEXT DEFAULT 'SMK Negeri 8 Malang',
    created_at TIMESTAMPTZ DEFAULT now(),
    CONSTRAINT unique_siswa_tanggal UNIQUE (siswa_id, tanggal)
);

-- 3.10 PENGAJUAN ABSEN (Manual: Izin / Sakit dengan Bukti Foto/Surat)
CREATE TABLE pengajuan_absen (
    id_pengajuan UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    siswa_id UUID REFERENCES siswa(id_siswa) ON DELETE CASCADE,
    guru_id UUID REFERENCES guru(id_guru) ON DELETE SET NULL,
    absen_id UUID REFERENCES absensi(id_absen) ON DELETE SET NULL,
    tanggal_absen DATE NOT NULL DEFAULT CURRENT_DATE,
    jenis VARCHAR(20) NOT NULL CHECK (jenis IN ('izin', 'sakit')),
    alasan TEXT NOT NULL,
    file_url TEXT,
    tanggal_ajuan TIMESTAMPTZ DEFAULT now(),
    tanggal_proses TIMESTAMPTZ,
    status VARCHAR(20) DEFAULT 'menunggu' CHECK (status IN ('menunggu', 'disetujui', 'ditolak')),
    catatan_guru TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3.11 BUKTI ABSEN
CREATE TABLE bukti_absen (
    id_bukti UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    absen_id UUID REFERENCES absensi(id_absen) ON DELETE CASCADE,
    file_url TEXT NOT NULL,
    file_type VARCHAR(50) DEFAULT 'image/jpeg',
    upload_at TIMESTAMPTZ DEFAULT now()
);

-- 3.12 NOTIFIKASI
CREATE TABLE notifikasi (
    id_notif UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id_user) ON DELETE CASCADE,
    absensi_id UUID REFERENCES absensi(id_absen) ON DELETE SET NULL,
    judul VARCHAR(255) NOT NULL,
    pesan TEXT NOT NULL,
    tipe VARCHAR(50) DEFAULT 'info',
    status VARCHAR(20) DEFAULT 'belum',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3.13 AKTIFITAS
CREATE TABLE aktifitas (
    id_log UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id_user) ON DELETE CASCADE,
    aksi TEXT NOT NULL,
    user_agent TEXT,
    ip_addres TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ==============================================================================
-- 4. ROW LEVEL SECURITY (RLS) & HAK AKSES API SUPABASE
-- ==============================================================================
ALTER TABLE sekolah ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin ENABLE ROW LEVEL SECURITY;
ALTER TABLE guru ENABLE ROW LEVEL SECURITY;
ALTER TABLE tahun_ajaran ENABLE ROW LEVEL SECURITY;
ALTER TABLE kelas ENABLE ROW LEVEL SECURITY;
ALTER TABLE siswa ENABLE ROW LEVEL SECURITY;
ALTER TABLE anggota_kelas ENABLE ROW LEVEL SECURITY;
ALTER TABLE konfigurasi_absen ENABLE ROW LEVEL SECURITY;
ALTER TABLE absensi ENABLE ROW LEVEL SECURITY;
ALTER TABLE pengajuan_absen ENABLE ROW LEVEL SECURITY;
ALTER TABLE bukti_absen ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifikasi ENABLE ROW LEVEL SECURITY;
ALTER TABLE aktifitas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Akses Penuh Sekolah" ON sekolah FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Akses Penuh Users" ON users FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Akses Penuh Admin" ON admin FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Akses Penuh Guru" ON guru FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Akses Penuh Tahun Ajaran" ON tahun_ajaran FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Akses Penuh Kelas" ON kelas FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Akses Penuh Siswa" ON siswa FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Akses Penuh Anggota Kelas" ON anggota_kelas FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Akses Penuh Konfigurasi Absen" ON konfigurasi_absen FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Akses Penuh Absensi" ON absensi FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Akses Penuh Pengajuan Absen" ON pengajuan_absen FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Akses Penuh Bukti Absen" ON bukti_absen FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Akses Penuh Notifikasi" ON notifikasi FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Akses Penuh Aktifitas" ON aktifitas FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;

-- ==============================================================================
-- 5. KONFIGURASI STORAGE BUCKET 'bukti-absen' & RLS POLICY
-- ==============================================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('bukti-absen', 'bukti-absen', true)
ON CONFLICT (id) DO UPDATE SET public = true;

DROP POLICY IF EXISTS "Public Bukti Absen Select" ON storage.objects;
DROP POLICY IF EXISTS "Public Bukti Absen Insert" ON storage.objects;
DROP POLICY IF EXISTS "Public Bukti Absen Update" ON storage.objects;
DROP POLICY IF EXISTS "Public Bukti Absen Delete" ON storage.objects;

CREATE POLICY "Public Bukti Absen Select" ON storage.objects FOR SELECT TO public USING (bucket_id = 'bukti-absen');
CREATE POLICY "Public Bukti Absen Insert" ON storage.objects FOR INSERT TO public WITH CHECK (bucket_id = 'bukti-absen');
CREATE POLICY "Public Bukti Absen Update" ON storage.objects FOR UPDATE TO public USING (bucket_id = 'bukti-absen');
CREATE POLICY "Public Bukti Absen Delete" ON storage.objects FOR DELETE TO public USING (bucket_id = 'bukti-absen');

-- ==============================================================================
-- 6. SEED DATA AWAL (BERSIH SESUAI 1 SEKOLAH, 1 KELAS, DATA RIIL)
-- Password default semua akun: Password123
-- Catatan: Hari ini belum ada absensi terdaftar, sehingga status seluruh siswa
--          secara valid dan akurat adalah "Belum Absen".
-- ==============================================================================

DO $$
DECLARE
    v_sekolah_id UUID;
    v_user_admin UUID;
    v_user_guru UUID;
    v_user_siswa1 UUID;
    v_user_siswa2 UUID;
    v_user_siswa3 UUID;
    v_user_siswa4 UUID;
    v_user_siswa5 UUID;
    v_user_siswa6 UUID;
    v_guru_id UUID;
    v_tahun_id UUID;
    v_kelas_id UUID;
    v_siswa1_id UUID;
    v_siswa2_id UUID;
    v_siswa3_id UUID;
    v_siswa4_id UUID;
    v_siswa5_id UUID;
    v_siswa6_id UUID;
    v_konfig_id UUID;
BEGIN
    -- 1. Buat Data Sekolah (SMK Negeri 8 Malang)
    INSERT INTO sekolah (nama_sekolah, alamat, latitude, longitude, radius_meter, status)
    VALUES ('SMK Negeri 8 Malang', 'Jl. Teluk Pacitan, Arjosari, Kec. Blimbing, Kota Malang, Jawa Timur', -7.93557, 112.6595, 300, 'aktif')
    RETURNING id_sekolah INTO v_sekolah_id;

    -- 2. Buat User Admin
    INSERT INTO users (sekolah_id, username, password, role, nama, no_hp, alamat, status)
    VALUES (v_sekolah_id, 'admin@gmail.com', 'Password123', 'admin', 'Administrator', '081234567890', 'Jl. Pendidikan No. 10, Blitar', 'aktif')
    RETURNING id_user INTO v_user_admin;

    -- 2.1 Buat Profil Admin
    INSERT INTO admin (user_id, sekolah_id, nama, email, no_hp, alamat, jabatan)
    VALUES (v_user_admin, v_sekolah_id, 'Administrator', 'admin@gmail.com', '081234567890', 'Jl. Pendidikan No. 10, Blitar', 'Super Administrator');

    -- 3. Buat User Guru (Yudi Guru)
    INSERT INTO users (sekolah_id, username, password, role, nama, no_hp, alamat, status)
    VALUES (v_sekolah_id, 'yudi@gmail.com', 'Password123', 'guru', 'Yudi Guru, S.Pd', '081234567890', 'Jl. Soekarno Hatta No. 15, Malang', 'aktif')
    RETURNING id_user INTO v_user_guru;

    -- 4. Buat Profil Guru
    INSERT INTO guru (user_id, sekolah_id, nama, email, no_hp, alamat, jabatan, nip, mapel)
    VALUES (v_user_guru, v_sekolah_id, 'Yudi Guru, S.Pd', 'yudi@gmail.com', '081234567890', 'Jl. Soekarno Hatta No. 15, Malang', 'Wali Kelas XII RPL D', '198503122010011005', 'Rekayasa Perangkat Lunak')
    RETURNING id_guru INTO v_guru_id;

    -- Guru Tambahan untuk Kontak Guru Piket
    INSERT INTO guru (sekolah_id, nama, email, no_hp, alamat, jabatan, nip, mapel)
    VALUES 
    (v_sekolah_id, 'Budi Santoso, S.Kom', 'budi@gmail.com', '081234567890', 'Malang', 'Guru Piket (07:00–10:00)', '198205142008011003', 'Basis Data'),
    (v_sekolah_id, 'Siti Rahma, S.Pd', 'siti@gmail.com', '081345678901', 'Malang', 'Guru Piket (10:00–13:00)', '198711202010012015', 'Bahasa Inggris'),
    (v_sekolah_id, 'Deni Pratama, M.Kom', 'deni@gmail.com', '081456789012', 'Malang', 'Guru Piket (13:00–16:00)', '199004052014022008', 'Rekayasa Perangkat Lunak');

    -- 5. Buat Tahun Ajaran
    INSERT INTO tahun_ajaran (sekolah_id, tahun, semester, tahun_mulai, tahun_akhir, status)
    VALUES (v_sekolah_id, '2026/2027', 'Ganjil', '2026-07-15', '2026-12-20', 'aktif')
    RETURNING id_tahun INTO v_tahun_id;

    -- 6. Buat Kelas (XII Rekayasa Perangkat Lunak D) dengan Wali Kelas v_guru_id
    INSERT INTO kelas (sekolah_id, guru_id, tingkat, jurusan)
    VALUES (v_sekolah_id, v_guru_id, 'XII', 'Rekayasa Perangkat Lunak D')
    RETURNING id_kelas INTO v_kelas_id;

    -- 7. Buat Konfigurasi Absen
    INSERT INTO konfigurasi_absen (sekolah_id, hari, jam_mulai, jam_selesai, batas_terlambat, lokasi)
    VALUES (v_sekolah_id, 'Semua Hari', '06:00:00', '08:00:00', '07:00:00', 'SMK Negeri 8 Malang')
    RETURNING id_konfig INTO v_konfig_id;

    -- 8. Buat Akun & Profil 6 Siswa Riil
    -- Siswa 1: Budiono Siregar
    INSERT INTO users (sekolah_id, username, password, role, nama, no_hp, alamat, status)
    VALUES (v_sekolah_id, 'iko@gmail.com', 'Password123', 'siswa', 'Budiono Siregar', '081299887766', 'Jl. Soekarno Hatta No. 12 Malang', 'aktif')
    RETURNING id_user INTO v_user_siswa1;

    INSERT INTO siswa (user_id, sekolah_id, nama_siswa, kelas_id, jurusan, jenis_kelamin, tanggal_lahir, no_hp, alamat, nis, nisn)
    VALUES (v_user_siswa1, v_sekolah_id, 'Budiono Siregar', v_kelas_id, 'Rekayasa Perangkat Lunak', 'Laki-laki', '2008-05-12', '081299887766', 'Jl. Soekarno Hatta No. 12 Malang', '10482', '0051283921')
    RETURNING id_siswa INTO v_siswa1_id;

    -- Siswa 2: Chelsea Aqila Putri
    INSERT INTO users (sekolah_id, username, password, role, nama, no_hp, alamat, status)
    VALUES (v_sekolah_id, 'chelsea@gmail.com', 'Password123', 'siswa', 'Chelsea Aqila Putri', '081299887767', 'Malang', 'aktif')
    RETURNING id_user INTO v_user_siswa2;

    INSERT INTO siswa (user_id, sekolah_id, nama_siswa, kelas_id, jurusan, jenis_kelamin, tanggal_lahir, no_hp, alamat, nis, nisn)
    VALUES (v_user_siswa2, v_sekolah_id, 'Chelsea Aqila Putri', v_kelas_id, 'Rekayasa Perangkat Lunak', 'Perempuan', '2008-07-21', '081299887767', 'Malang', '10483', '0051283922')
    RETURNING id_siswa INTO v_siswa2_id;

    -- Siswa 3: Malika Aisyabila
    INSERT INTO users (sekolah_id, username, password, role, nama, no_hp, alamat, status)
    VALUES (v_sekolah_id, 'malika@gmail.com', 'Password123', 'siswa', 'Malika Aisyabila', '081299887768', 'Malang', 'aktif')
    RETURNING id_user INTO v_user_siswa3;

    INSERT INTO siswa (user_id, sekolah_id, nama_siswa, kelas_id, jurusan, jenis_kelamin, tanggal_lahir, no_hp, alamat, nis, nisn)
    VALUES (v_user_siswa3, v_sekolah_id, 'Malika Aisyabila', v_kelas_id, 'Rekayasa Perangkat Lunak', 'Perempuan', '2008-03-14', '081299887768', 'Malang', '10484', '0051283923')
    RETURNING id_siswa INTO v_siswa3_id;

    -- Siswa 4: Nabil Syafiq Afa
    INSERT INTO users (sekolah_id, username, password, role, nama, no_hp, alamat, status)
    VALUES (v_sekolah_id, 'nabil@gmail.com', 'Password123', 'siswa', 'Nabil Syafiq Afa', '081299887769', 'Malang', 'aktif')
    RETURNING id_user INTO v_user_siswa4;

    INSERT INTO siswa (user_id, sekolah_id, nama_siswa, kelas_id, jurusan, jenis_kelamin, tanggal_lahir, no_hp, alamat, nis, nisn)
    VALUES (v_user_siswa4, v_sekolah_id, 'Nabil Syafiq Afa', v_kelas_id, 'Rekayasa Perangkat Lunak', 'Laki-laki', '2008-09-02', '081299887769', 'Malang', '10485', '0051283924')
    RETURNING id_siswa INTO v_siswa4_id;

    -- Siswa 5: Ahmad Farhan
    INSERT INTO users (sekolah_id, username, password, role, nama, no_hp, alamat, status)
    VALUES (v_sekolah_id, 'farhan@gmail.com', 'Password123', 'siswa', 'Ahmad Farhan', '081299887770', 'Malang', 'aktif')
    RETURNING id_user INTO v_user_siswa5;

    INSERT INTO siswa (user_id, sekolah_id, nama_siswa, kelas_id, jurusan, jenis_kelamin, tanggal_lahir, no_hp, alamat, nis, nisn)
    VALUES (v_user_siswa5, v_sekolah_id, 'Ahmad Farhan', v_kelas_id, 'Rekayasa Perangkat Lunak', 'Laki-laki', '2008-11-18', '081299887770', 'Malang', '10486', '0051283925')
    RETURNING id_siswa INTO v_siswa5_id;

    -- Siswa 6: Dimas Ibrahimovic
    INSERT INTO users (sekolah_id, username, password, role, nama, no_hp, alamat, status)
    VALUES (v_sekolah_id, 'dimas@gmail.com', 'Password123', 'siswa', 'Dimas Ibrahimovic', '081299887771', 'Malang', 'aktif')
    RETURNING id_user INTO v_user_siswa6;

    INSERT INTO siswa (user_id, sekolah_id, nama_siswa, kelas_id, jurusan, jenis_kelamin, tanggal_lahir, no_hp, alamat, nis, nisn)
    VALUES (v_user_siswa6, v_sekolah_id, 'Dimas Ibrahimovic', v_kelas_id, 'Rekayasa Perangkat Lunak', 'Laki-laki', '2008-01-25', '081299887771', 'Malang', '10487', '0051283926')
    RETURNING id_siswa INTO v_siswa6_id;

    -- 9. Daftarkan 6 Siswa ke Anggota Kelas
    INSERT INTO anggota_kelas (siswa_id, kelas_id, tahun_ajaran_id, status)
    VALUES 
    (v_siswa1_id, v_kelas_id, v_tahun_id, 'aktif'),
    (v_siswa2_id, v_kelas_id, v_tahun_id, 'aktif'),
    (v_siswa3_id, v_kelas_id, v_tahun_id, 'aktif'),
    (v_siswa4_id, v_kelas_id, v_tahun_id, 'aktif'),
    (v_siswa5_id, v_kelas_id, v_tahun_id, 'aktif'),
    (v_siswa6_id, v_kelas_id, v_tahun_id, 'aktif');

    -- Tidak ada data absensi hari ini yang di-insert secara otomatis.
    -- Siswa akan mulai dengan status murni "Belum Absen".
END $$;
