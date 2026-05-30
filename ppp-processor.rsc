# Deklarasikan kembali variabel global agar nilainya terbaca dari RAM Klien
:global pppNama
:global pppSandi
:global pppService
:global pppPaket
:global botToken
:global chatId

# --- PROSES MAJU 1 BULAN (FORMAT MMM/DD/YYYY) ---
:local date [/system clock get date]

# Potong teks tanggal berdasarkan format mmm/dd/yyyy
:local blnTeks [:pick $date 0 3]
:local tgl [:pick $date 4 6]
:local thn [:pick $date 7 11]

# Ubah nama bulan tiga huruf menjadi angka
:local blnAngka 0
:local monthsName {"jan"=1;"feb"=2;"mar"=3;"apr"=4;"may"=5;"jun"=6;"jul"=7;"aug"=8;"sep"=9;"oct"=10;"nov"=11;"dec"=12}
:set blnAngka ($monthsName->$blnTeks)

# Naikkan 1 bulan
:local newBln ($blnAngka + 1)
:local newThn $thn

# Jika melewati Desember (12), maju ke Januari tahun depan
:if ($newBln > 12) do={
    :set newBln 1
    :set newThn ($thn + 1)
}

# Validasi batas maksimal hari di bulan yang baru
:local monthsDays {1=31;2=28;3=31;4=30;5=31;6=30;7=31;8=31;9=30;10=31;11=30;12=31}
# Cek tahun kabisat untuk bulan Februari
:if ((($newThn / 4) * 4) = $newThn) do={ :set ($monthsDays->2) 29 }

:local maxDays ($monthsDays->$newBln)
:local newTgl $tgl

# Jika tanggal hari ini lebih besar dari kapasitas hari bulan baru
:if ($newTgl > $maxDays) do={ :set newTgl $maxDays }

# Kembalikan angka bulan baru menjadi teks mmm MikroTik
:local newBlnTeks ""
:local monthsArray {"jan";"feb";"mar";"apr";"may";"jun";"jul";"aug";"sep";"oct";"nov";"dec"}
:set newBlnTeks ([:pick $monthsArray ($newBln - 1)])

# Susun kembali menjadi format mmm/dd/yyyy untuk disimpan di komentar secret
:local expDate "$newBlnTeks/$newTgl/$newThn"
# --------------------------------------------------

# Proses verifikasi dan pembuatan akun ke PPP Secret menggunakan variabel global
/ppp secret {
    :local userExist [find name=$pppNama]
    :if ([:len $userExist] = 0) do={
        # Di sini comment diisi dengan $expDate (tanggal kedaluwarsa hasil hitungan otomatis)
        add name=$pppNama password=$pppSandi profile=$pppPaket service=$pppService comment=$date
        :local msg0 "PPPoE%20Bulanan:%20Pelanggan%20baru%20$pppNama%20berhasil%20ditambahkan.%20Paket:%20$pppPaket.%20Masa%20Aktif%20S/D%20$expDate."
        :log warning "PPPoE Bulanan: Pelanggan baru $pppNama berhasil ditambahkan."
        /tool fetch url="https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatId&text=$msg0" check-certificate=no keep-result=no
    } else={
        :local msg1 "PPPoE:%20Gagal%20menambah%20user.%20Nama%20'$pppNama'%20sudah%20terdaftar!"
        :log error "PPPoE: Gagal menambah user. Nama sudah terdaftar."
        /tool fetch url="https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatId&text=$msg1" check-certificate=no keep-result=no
    }
}

# --- BERSIHKAN RAM (Keamanan Ganda) ---
# Menghapus isi variabel dari memori setelah skrip selesai agar tidak diintip klien
:set pppNama
:set pppSandi
:set pppService
:set pppPaket
:set botToken
:set chatId
