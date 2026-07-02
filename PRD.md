# Product Requirement Document

## Pocket — Personal Finance Lite

---

### Latar Belakang

Banyak pengguna personal masih mencatat pemasukan dan pengeluaran secara manual menggunakan catatan sederhana, spreadsheet, atau hanya mengandalkan ingatan. Cara ini sering menyebabkan pengguna sulit mengetahui total uang yang masuk, total uang yang keluar, dan kategori pengeluaran yang paling besar dalam periode tertentu.

Pocket dirancang sebagai aplikasi keuangan pribadi sederhana yang membantu pengguna mencatat transaksi harian, mengelompokkan transaksi berdasarkan kategori, melihat riwayat transaksi, dan memahami ringkasan kondisi keuangan bulanan.

Pada scope MVP, Pocket berfokus pada pencatatan transaksi manual dan penyajian ringkasan keuangan dasar. Fitur seperti integrasi bank, OCR struk, budgeting kompleks, _recurring transaction_, dan _multi-currency_ tidak termasuk dalam scope awal.

---

### Problem Statement

Pengguna membutuhkan cara sederhana untuk mencatat dan memantau keuangan pribadi tanpa harus menggunakan aplikasi yang kompleks. Masalah utama yang ingin diselesaikan:

1. Pengguna sulit melacak pemasukan dan pengeluaran harian.
2. Pengguna sulit melihat total pemasukan, total pengeluaran, dan sisa saldo bulanan.
3. Pengguna sulit mengetahui kategori pengeluaran terbesar.
4. Pencatatan manual di luar aplikasi rawan hilang, tidak konsisten, dan sulit difilter.
5. Pengguna membutuhkan aplikasi ringan yang dapat digunakan tanpa proses setup yang rumit.

---

### Tujuan Produk

Pocket bertujuan menyediakan aplikasi pencatatan keuangan pribadi sederhana yang memungkinkan pengguna:

- Membuat wallet keuangan pribadi;
- Mencatat transaksi pemasukan dan pengeluaran;
- Mengelompokkan transaksi berdasarkan kategori;
- Melihat riwayat transaksi;
- Mencari dan memfilter transaksi;
- Melihat ringkasan keuangan bulanan;
- Memahami distribusi pemasukan dan pengeluaran berdasarkan kategori.

---

### Goals

| Goal                                  | Deskripsi                                                              | Indikator Keberhasilan                                                            |
| :------------------------------------ | :--------------------------------------------------------------------- | :-------------------------------------------------------------------------------- |
| **Mempermudah pencatatan transaksi**  | Pengguna dapat mencatat pemasukan dan pengeluaran secara manual.       | Pengguna dapat membuat transaksi valid.                                           |
| **Menyediakan riwayat transaksi**     | Pengguna dapat melihat daftar transaksi berdasarkan periode tertentu.  | Riwayat transaksi dapat difilter berdasarkan tanggal, tipe, kategori, dan wallet. |
| **Menyediakan ringkasan bulanan**     | Pengguna dapat melihat total income, expense, dan net balance bulanan. | Summary bulanan tersedia berdasarkan bulan dan tahun.                             |
| **Menjaga konsistensi data**          | Perubahan transaksi memengaruhi saldo dan summary secara benar.        | Saldo dan summary selalu merefleksikan transaksi aktif.                           |
| **Mendukung pengelompokan transaksi** | Pengguna dapat menggunakan kategori untuk income dan expense.          | Setiap transaksi memiliki kategori valid.                                         |

---

### Non-Goals

Scope berikut tidak termasuk dalam MVP:

- Integrasi rekening bank
- Integrasi e-wallet
- OCR struk
- Pembayaran atau transfer uang
- Multi-currency
- Shared wallet
- Recurring transaction
- Budget planning
- Export PDF/Excel
- Notifikasi
- Approval transaksi
- Role management kompleks
- Audit trail kompleks

---

### Target User

| User              | Deskripsi                                                                                 |
| :---------------- | :---------------------------------------------------------------------------------------- |
| **Personal User** | Pengguna individu yang ingin mencatat pemasukan dan pengeluaran pribadi secara sederhana. |

**Kebutuhan utama user:**

- Mengetahui total pemasukan bulan ini.
- Mengetahui total pengeluaran bulan ini.
- Mengetahui sisa saldo.
- Mengetahui kategori pengeluaran terbesar.
- Melihat transaksi berdasarkan periode tertentu.

---

### Scope MVP

Scope MVP Pocket terdiri dari lima area utama:

1. Wallet Management
2. Category Management
3. Transaction Management
4. Transaction History & Filter
5. Monthly Financial Summary

---

### Assumptions

- User sudah dianggap login.
- Setiap data wallet, category, dan transaction terikat pada satu user.
- Data antar-user tidak boleh saling terlihat.
- Currency default adalah IDR.
- Amount disimpan dalam bentuk integer.
- Transaction hanya memiliki dua tipe: `income` dan `expense`.
- Summary dihitung dari transaksi aktif.
- Delete transaksi menggunakan _soft delete_.
- Default category tersedia saat user pertama kali menggunakan aplikasi.

---

### Business Rules

| Kode       | Business Rule                                                                    |
| :--------- | :------------------------------------------------------------------------------- |
| **BR-001** | Setiap user hanya dapat melihat dan mengelola data miliknya sendiri.             |
| **BR-002** | Wallet wajib dimiliki oleh user.                                                 |
| **BR-003** | Category wajib dimiliki oleh user atau berasal dari default system category.     |
| **BR-004** | Transaction wajib memiliki wallet, category, type, amount, dan transaction date. |
| **BR-005** | Amount transaksi harus lebih besar dari 0.                                       |
| **BR-006** | Transaction type hanya boleh income atau expense.                                |
| **BR-007** | Category type harus sesuai dengan transaction type.                              |
| **BR-008** | Expense tidak boleh membuat wallet balance menjadi negatif.                      |
| **BR-009** | Transaction date tidak boleh lebih dari tanggal hari ini.                        |
| **BR-010** | Transaction dapat diedit selama masih aktif.                                     |
| **BR-011** | Transaction yang dihapus tidak muncul di history dan summary.                    |
| **BR-012** | Wallet yang memiliki transaksi tidak boleh hard delete.                          |
| **BR-013** | Summary bulanan dihitung berdasarkan bulan dan tahun transaksi.                  |
| **BR-014** | Default category tersedia untuk income dan expense.                              |
| **BR-015** | User dapat membuat custom category sesuai tipe transaksi.                        |

---

### User Stories

| ID         | User Story                                                                                                                            | Priority |
| :--------- | :------------------------------------------------------------------------------------------------------------------------------------ | :------- |
| **US-001** | Sebagai user, saya ingin membuat wallet agar saya dapat mengelompokkan sumber uang pribadi saya.                                      | High     |
| **US-002** | Sebagai user, saya ingin melihat daftar wallet agar saya mengetahui wallet yang saya miliki.                                          | High     |
| **US-003** | Sebagai user, saya ingin menggunakan kategori transaksi agar pemasukan dan pengeluaran saya terorganisir.                             | High     |
| **US-004** | Sebagai user, saya ingin mencatat transaksi income agar pemasukan saya tercatat.                                                      | High     |
| **US-005** | Sebagai user, saya ingin mencatat transaksi expense agar pengeluaran saya tercatat.                                                   | High     |
| **US-006** | Sebagai user, saya ingin melihat riwayat transaksi agar saya dapat meninjau catatan keuangan saya.                                    | High     |
| **US-007** | Sebagai user, saya ingin memfilter transaksi berdasarkan tanggal, tipe, kategori, dan wallet agar pencarian lebih mudah.              | Medium   |
| **US-008** | Sebagai user, saya ingin mengubah transaksi agar saya dapat memperbaiki data yang salah.                                              | Medium   |
| **US-009** | Sebagai user, saya ingin menghapus transaksi agar data yang tidak valid tidak lagi muncul.                                            | Medium   |
| **US-010** | Sebagai user, saya ingin melihat summary bulanan agar saya mengetahui total income, expense, dan net balance.                         | High     |
| **US-011** | Sebagai user, saya ingin melihat breakdown transaksi berdasarkan kategori agar saya tahu kategori pemasukan dan pengeluaran terbesar. | Medium   |

---

### Functional Requirements

#### FR-001 Wallet Management

Sistem menyediakan kemampuan untuk membuat dan melihat wallet milik user. Wallet memiliki informasi dasar seperti nama wallet, tipe wallet, saldo awal, dan saldo saat ini.
Wallet type yang didukung pada MVP:

- cash
- bank
- e-wallet

#### FR-002 Category Management

Sistem menyediakan kategori transaksi untuk income dan expense. Kategori dapat berupa:

- default category;
- custom category milik user.

Kategori income hanya dapat digunakan untuk transaksi income. Kategori expense hanya dapat digunakan untuk transaksi expense.

#### FR-003 Create Transaction

User dapat membuat transaksi income atau expense. Transaksi harus terhubung ke wallet dan category.

- Saat transaksi income dibuat, saldo wallet bertambah.
- Saat transaksi expense dibuat, saldo wallet berkurang. Expense tidak boleh diproses jika saldo wallet tidak cukup.

#### FR-004 Transaction History

User dapat melihat daftar transaksi miliknya. Riwayat transaksi dapat difilter berdasarkan:

- date range;
- transaction type;
- wallet;
- category;
- keyword pada note.

Daftar transaksi ditampilkan secara descending berdasarkan transaction date terbaru.

#### FR-005 Update Transaction

User dapat mengubah transaksi aktif. Perubahan transaksi harus memperbarui saldo wallet secara konsisten. Jika perubahan menyebabkan saldo wallet tidak valid, sistem harus menolak perubahan tersebut.

#### FR-006 Delete Transaction

User dapat menghapus transaksi aktif. Delete menggunakan soft delete. Transaksi yang dihapus tidak muncul pada riwayat transaksi dan tidak dihitung pada summary. Saldo wallet harus dikembalikan sesuai efek transaksi yang dihapus.

#### FR-007 Monthly Summary

User dapat melihat summary keuangan per bulan. Summary menampilkan:

- total income;
- total expense;
- net balance;
- total transaction count;
- expense breakdown by category;
- income breakdown by category.

---

### Acceptance Criteria

#### AC-001 Wallet Management

| No  | Acceptance Criteria                                          |
| :-- | :----------------------------------------------------------- |
| 1   | User dapat membuat wallet dengan nama, tipe, dan saldo awal. |
| 2   | Nama wallet wajib diisi.                                     |
| 3   | Tipe wallet harus salah satu dari cash, bank, atau e-wallet. |
| 4   | Saldo awal tidak boleh kurang dari 0.                        |
| 5   | User hanya dapat melihat wallet miliknya sendiri.            |

#### AC-002 Category Management

| No  | Acceptance Criteria                                            |
| :-- | :------------------------------------------------------------- |
| 1   | User dapat melihat daftar kategori income dan expense.         |
| 2   | User dapat membuat custom category.                            |
| 3   | Nama category wajib diisi.                                     |
| 4   | Category type harus income atau expense.                       |
| 5   | Category expense tidak dapat digunakan untuk transaksi income. |
| 6   | Category income tidak dapat digunakan untuk transaksi expense. |

#### AC-003 Create Transaction

| No  | Acceptance Criteria                                                 |
| :-- | :------------------------------------------------------------------ |
| 1   | User dapat membuat transaksi income.                                |
| 2   | User dapat membuat transaksi expense.                               |
| 3   | Amount wajib lebih besar dari 0.                                    |
| 4   | Wallet wajib valid dan milik user.                                  |
| 5   | Category wajib valid dan sesuai dengan transaction type.            |
| 6   | Transaction date tidak boleh lebih dari hari ini.                   |
| 7   | Income menambah saldo wallet.                                       |
| 8   | Expense mengurangi saldo wallet.                                    |
| 9   | Expense ditolak jika saldo wallet tidak cukup.                      |
| 10  | Response transaksi menampilkan data transaksi yang berhasil dibuat. |

#### AC-004 Transaction History & Filter

| No  | Acceptance Criteria                                    |
| :-- | :----------------------------------------------------- |
| 1   | User dapat melihat daftar transaksi aktif.             |
| 2   | Transaksi yang sudah dihapus tidak muncul.             |
| 3   | User dapat memfilter transaksi berdasarkan date range. |
| 4   | User dapat memfilter transaksi berdasarkan type.       |
| 5   | User dapat memfilter transaksi berdasarkan wallet.     |
| 6   | User dapat memfilter transaksi berdasarkan category.   |
| 7   | User dapat mencari transaksi berdasarkan note.         |
| 8   | Hasil transaksi diurutkan dari tanggal terbaru.        |

#### AC-005 Update Transaction

| No  | Acceptance Criteria                                         |
| :-- | :---------------------------------------------------------- |
| 1   | User dapat mengubah transaksi aktif.                        |
| 2   | Update amount memengaruhi saldo wallet.                     |
| 3   | Update wallet memindahkan efek transaksi ke wallet baru.    |
| 4   | Update category harus tetap sesuai dengan transaction type. |
| 5   | Update ditolak jika menyebabkan saldo wallet tidak valid.   |
| 6   | User tidak dapat mengubah transaksi milik user lain.        |

#### AC-006 Delete Transaction

| No  | Acceptance Criteria                                 |
| :-- | :-------------------------------------------------- |
| 1   | User dapat menghapus transaksi aktif.               |
| 2   | Delete transaksi bersifat soft delete.              |
| 3   | Saldo wallet disesuaikan setelah transaksi dihapus. |
| 4   | Transaksi yang dihapus tidak muncul pada history.   |
| 5   | Transaksi yang dihapus tidak dihitung pada summary. |

#### AC-007 Monthly Summary

| No  | Acceptance Criteria                                     |
| :-- | :------------------------------------------------------ |
| 1   | User dapat melihat summary berdasarkan bulan dan tahun. |
| 2   | Summary menampilkan total income.                       |
| 3   | Summary menampilkan total expense.                      |
| 4   | Summary menampilkan net balance.                        |
| 5   | Summary menampilkan jumlah transaksi aktif.             |
| 6   | Summary menampilkan breakdown income by category.       |
| 7   | Summary menampilkan breakdown expense by category.      |
| 8   | Summary tidak menghitung transaksi yang sudah dihapus.  |

---

### Gherkin Scenarios

| ID        | Given                                                            | When                                                    | Then                                                                  |
| :-------- | :--------------------------------------------------------------- | :------------------------------------------------------ | :-------------------------------------------------------------------- |
| **G-001** | User belum memiliki wallet                                       | User membuat wallet dengan data valid                   | Sistem membuat wallet dan menampilkan data wallet                     |
| **G-002** | User mengisi nama wallet kosong                                  | User submit pembuatan wallet                            | Sistem menolak request dan mengembalikan validation error             |
| **G-003** | User memiliki wallet dengan saldo 100000                         | User membuat transaksi income sebesar 50000             | Sistem membuat transaksi dan saldo wallet menjadi 150000              |
| **G-004** | User memiliki wallet dengan saldo 100000                         | User membuat transaksi expense sebesar 30000            | Sistem membuat transaksi dan saldo wallet menjadi 70000               |
| **G-005** | User memiliki wallet dengan saldo 100000                         | User membuat transaksi expense sebesar 150000           | Sistem menolak transaksi karena saldo tidak cukup                     |
| **G-006** | User memilih category income                                     | User membuat transaksi expense dengan category tersebut | Sistem menolak request karena category tidak sesuai type transaksi    |
| **G-007** | User memiliki beberapa transaksi aktif                           | User membuka riwayat transaksi                          | Sistem menampilkan daftar transaksi aktif berdasarkan tanggal terbaru |
| **G-008** | User memiliki transaksi pada bulan Januari dan Februari          | User memfilter transaksi bulan Januari                  | Sistem hanya menampilkan transaksi bulan Januari                      |
| **G-009** | User memiliki transaksi dengan note "makan siang"                | User mencari keyword "makan"                            | Sistem menampilkan transaksi yang mengandung keyword tersebut         |
| **G-010** | User memiliki transaksi income sebesar 100000                    | User mengubah amount menjadi 150000                     | Sistem memperbarui transaksi dan menyesuaikan saldo wallet            |
| **G-011** | User memiliki transaksi expense aktif                            | User menghapus transaksi tersebut                       | Sistem melakukan soft delete dan mengembalikan saldo wallet           |
| **G-012** | User memiliki transaksi income dan expense dalam bulan yang sama | User membuka monthly summary                            | Sistem menampilkan total income, total expense, dan net balance       |
| **G-013** | User memiliki transaksi yang sudah dihapus                       | User membuka monthly summary                            | Sistem tidak menghitung transaksi yang sudah dihapus                  |
| **G-014** | User mencoba membaca transaksi milik user lain                   | User membuka detail transaksi tersebut                  | Sistem menolak akses atau mengembalikan data tidak ditemukan          |
| **G-015** | User mengisi transaction date di masa depan                      | User submit transaksi                                   | Sistem menolak request dan mengembalikan validation error             |

---

### UI Screen Mapping

| Screen                 | Tujuan                                         | Konten Utama                                                                      |
| :--------------------- | :--------------------------------------------- | :-------------------------------------------------------------------------------- |
| **Dashboard**          | Menampilkan ringkasan kondisi keuangan user    | Total income, total expense, net balance, category breakdown, recent transactions |
| **Wallet List**        | Menampilkan daftar wallet user                 | Nama wallet, tipe wallet, current balance                                         |
| **Create Wallet**      | Membuat wallet baru                            | Form nama wallet, tipe wallet, saldo awal                                         |
| **Category List**      | Menampilkan daftar kategori income dan expense | Default category dan custom category                                              |
| **Create Category**    | Membuat custom category                        | Form nama category dan category type                                              |
| **Transaction List**   | Menampilkan riwayat transaksi                  | List transaksi, filter, search, pagination                                        |
| **Create Transaction** | Membuat transaksi income atau expense          | Wallet, type, category, amount, date, note                                        |
| **Edit Transaction**   | Mengubah transaksi aktif                       | Form transaksi dengan data existing                                               |
| **Monthly Summary**    | Menampilkan ringkasan bulanan                  | Total income, total expense, net balance, breakdown by category                   |

---

### Route Structure

| Route                    | Screen             | Keterangan            |
| :----------------------- | :----------------- | :-------------------- |
| `/dashboard`             | Dashboard          | Ringkasan utama       |
| `/wallets`               | Wallet List        | Daftar wallet         |
| `/wallets/create`        | Create Wallet      | Form tambah wallet    |
| `/categories`            | Category List      | Daftar kategori       |
| `/categories/create`     | Create Category    | Form tambah kategori  |
| `/transactions`          | Transaction List   | Riwayat transaksi     |
| `/transactions/create`   | Create Transaction | Form tambah transaksi |
| `/transactions/:id/edit` | Edit Transaction   | Form edit transaksi   |
| `/summary/monthly`       | Monthly Summary    | Summary bulanan       |

---

### Data Requirement

#### Wallet

| Field             | Deskripsi                          |
| :---------------- | :--------------------------------- |
| `id`              | Unique identifier wallet           |
| `user_id`         | Pemilik wallet                     |
| `name`            | Nama wallet                        |
| `type`            | Jenis wallet: cash, bank, e-wallet |
| `initial_balance` | Saldo awal wallet                  |
| `current_balance` | Saldo wallet saat ini              |
| `created_at`      | Waktu pembuatan                    |
| `updated_at`      | Waktu pembaruan                    |
| `deleted_at`      | Waktu soft delete jika ada         |

#### Category

| Field        | Deskripsi                    |
| :----------- | :--------------------------- |
| `id`         | Unique identifier category   |
| `user_id`    | Pemilik category jika custom |
| `name`       | Nama category                |
| `type`       | income atau expense          |
| `is_default` | Penanda default category     |
| `created_at` | Waktu pembuatan              |
| `updated_at` | Waktu pembaruan              |
| `deleted_at` | Waktu soft delete jika ada   |

#### Transaction

| Field              | Deskripsi                     |
| :----------------- | :---------------------------- |
| `id`               | Unique identifier transaction |
| `user_id`          | Pemilik transaksi             |
| `wallet_id`        | Wallet yang digunakan         |
| `category_id`      | Category transaksi            |
| `type`             | income atau expense           |
| `amount`           | Nominal transaksi             |
| `transaction_date` | Tanggal transaksi             |
| `note`             | Catatan opsional              |
| `created_at`       | Waktu pembuatan               |
| `updated_at`       | Waktu pembaruan               |
| `deleted_at`       | Waktu soft delete jika ada    |

---

### Default Category

#### Income Category

| Category         | Deskripsi                  |
| :--------------- | :------------------------- |
| **Salary**       | Gaji atau pendapatan utama |
| **Bonus**        | Bonus atau insentif        |
| **Gift**         | Hadiah atau pemberian      |
| **Other Income** | Pemasukan lainnya          |

#### Expense Category

| Category          | Deskripsi           |
| :---------------- | :------------------ |
| **Food**          | Makanan dan minuman |
| **Transport**     | Transportasi        |
| **Shopping**      | Belanja             |
| **Bills**         | Tagihan             |
| **Health**        | Kesehatan           |
| **Entertainment** | Hiburan             |
| **Education**     | Pendidikan          |
| **Other Expense** | Pengeluaran lainnya |

---

### User Flow

#### First-Time User Flow

1. User membuka aplikasi.
2. Sistem menyediakan default category.
3. User membuat wallet pertama.
4. User mulai mencatat transaksi income atau expense.
5. User melihat riwayat transaksi.
6. User melihat summary bulanan.

#### Transaction Flow

1. User memilih wallet.
2. User memilih transaction type.
3. User memilih category sesuai type.
4. User mengisi amount.
5. User mengisi transaction date.
6. User mengisi note jika diperlukan.
7. User submit transaksi.
8. Sistem memvalidasi data.
9. Sistem menyimpan transaksi.
10. Sistem memperbarui saldo wallet.
11. Sistem menampilkan transaksi yang berhasil dibuat.

#### Monthly Summary Flow

1. User memilih bulan dan tahun.
2. Sistem mengambil transaksi aktif pada periode tersebut.
3. Sistem menghitung total income.
4. Sistem menghitung total expense.
5. Sistem menghitung net balance.
6. Sistem mengelompokkan income dan expense berdasarkan category.
7. Sistem menampilkan summary.

---

### Error & Empty State

| Kondisi                          | Expected Behavior                                                 |
| :------------------------------- | :---------------------------------------------------------------- |
| **Wallet belum tersedia**        | Sistem menampilkan empty state dan meminta user membuat wallet    |
| **Transaction belum tersedia**   | Sistem menampilkan empty state transaksi                          |
| **Summary tidak memiliki data**  | Sistem menampilkan nilai 0 untuk income, expense, dan net balance |
| **Wallet tidak ditemukan**       | Sistem mengembalikan error data tidak ditemukan                   |
| **Category tidak ditemukan**     | Sistem mengembalikan error data tidak ditemukan                   |
| **Transaction tidak ditemukan**  | Sistem mengembalikan error data tidak ditemukan                   |
| **Saldo tidak cukup**            | Sistem mengembalikan error business validation                    |
| **Input tidak valid**            | Sistem mengembalikan validation error                             |
| **Data milik user lain diakses** | Sistem menolak akses atau mengembalikan data tidak ditemukan      |

---

### Non-Functional Requirements

#### Performance

- Daftar transaksi bulan berjalan dapat dimuat dalam waktu wajar untuk penggunaan personal.
- Summary bulanan dapat dihitung tanpa delay signifikan pada jumlah transaksi personal normal.
- Pagination digunakan pada daftar transaksi.

#### Security

- Data user harus terisolasi berdasarkan user.
- User tidak boleh mengakses wallet, category, atau transaction milik user lain.
- Input harus divalidasi di sisi sistem.
- Error response tidak boleh mengekspos detail internal sistem.

#### Reliability

Perubahan saldo wallet dan pencatatan transaksi harus konsisten.

- Jika transaksi gagal dibuat, saldo wallet tidak boleh berubah.
- Jika update transaksi gagal, data lama harus tetap valid.
- Jika delete transaksi gagal, transaksi tetap aktif.

#### Data Integrity

- Transaction harus selalu memiliki wallet dan category valid.
- Category type harus sesuai dengan transaction type.
- Amount harus bernilai positif.
- Soft-deleted data tidak dihitung dalam summary.

#### Maintainability

Logic transaksi harus mudah dipelihara dan diuji.

- Perhitungan saldo dan summary harus konsisten.
- Business rule harus dapat ditelusuri dari requirement ke implementasi.

#### Observability

Sistem memiliki logging dasar untuk request penting, error, dan business validation failure.

- Error yang terjadi saat proses transaksi harus dapat ditelusuri oleh developer.

#### Compatibility

- API dirancang agar dapat digunakan oleh aplikasi web atau mobile.
- Response format konsisten untuk success dan error.

---

### Supporting Information

#### Currency

- Currency default: IDR.
- Multi-currency tidak termasuk scope MVP.

#### Date & Time

- Transaction date menggunakan tanggal lokal user.
- Created at dan updated at disimpan dalam format timestamp.
- Filter summary menggunakan bulan dan tahun.

#### Pagination

Daftar transaksi mendukung pagination agar data tetap mudah dimuat.

- Parameter pagination yang diharapkan: `page`, `limit`.

#### Sorting

Default sorting transaksi:

- `transaction_date` descending;
- `created_at` descending sebagai secondary sorting.

#### Search

- Search dilakukan pada note transaksi.
- Search bersifat optional dan digunakan pada transaction history.

#### Deletion

Delete menggunakan soft delete. Data yang sudah soft delete:

- tidak muncul pada list;
- tidak dihitung pada summary;
- tidak dapat diedit oleh user.

---

### Edge Cases

| Case                                               | Expected Handling                                            |
| :------------------------------------------------- | :----------------------------------------------------------- |
| User membuat expense lebih besar dari saldo wallet | Request ditolak                                              |
| User update income menjadi expense                 | Sistem memvalidasi ulang category dan saldo                  |
| User update wallet pada transaksi lama             | Saldo wallet lama dan baru harus disesuaikan                 |
| User delete transaksi income                       | Saldo wallet dikurangi sesuai amount income yang dihapus     |
| User delete transaksi expense                      | Saldo wallet dikembalikan sesuai amount expense yang dihapus |
| User filter tanggal tanpa transaksi                | Sistem menampilkan empty state                               |
| User menggunakan category yang sudah dihapus       | Request ditolak                                              |
| User mengakses data milik user lain                | Sistem menolak akses atau mengembalikan not found            |
| User membuat transaksi dengan amount 0             | Request ditolak                                              |
| User membuat transaksi dengan tanggal masa depan   | Request ditolak                                              |

---

### Success Metrics

| Metric                           | Target                                               |
| :------------------------------- | :--------------------------------------------------- |
| **Transaction creation success** | User dapat membuat income dan expense valid          |
| **Data consistency**             | Saldo wallet sesuai dengan transaksi aktif           |
| **Summary accuracy**             | Summary bulanan sesuai dengan total transaksi aktif  |
| **Filtering accuracy**           | Filter transaksi mengembalikan data sesuai parameter |
| **Validation accuracy**          | Input tidak valid ditolak dengan response yang jelas |
| **User data isolation**          | User tidak dapat mengakses data user lain            |

---

### Open Questions

| No  | Pertanyaan                                                                     |
| :-- | :----------------------------------------------------------------------------- |
| 1   | Apakah wallet perlu mendukung update dan delete pada MVP?                      |
| 2   | Apakah category default dapat diubah oleh user atau hanya dibaca?              |
| 3   | Apakah transaction date boleh backdate tanpa batas?                            |
| 4   | Apakah summary perlu disimpan sebagai snapshot atau dihitung secara real-time? |
| 5   | Apakah not found untuk data user lain harus dibedakan dari forbidden?          |
| 6   | Apakah saldo awal wallet boleh diubah setelah wallet memiliki transaksi?       |

---

### Out of Scope

Fitur berikut tidak termasuk dalam scope MVP:

- Authentication penuh
- Registrasi dan login
- Integrasi payment
- Integrasi bank
- OCR
- Recurring transaction
- Budget budgeting
- Export report
- Notification
- Multi-currency
- Multi-user wallet
- Admin panel
