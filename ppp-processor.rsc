# Deklarasikan kembali variabel global agar nilainya terbaca dari RAM Klien
:global pppNama
:global pppSandi
:global pppService
:global pppPaket
:global botToken
:global chatId

# --- AMBIL TANGGAL SEKARANG (FORMAT MMM/DD/YYYY) ---
:local dateNow [/system clock get date]

# Proses verifikasi dan pembuatan akun ke PPP Secret menggunakan variabel global
/ppp secret {
:if ([/interface find name="l2tp-out1" running]) do={
    :local userExist [find name=$pppNama]
    :if ([:len $userExist] = 0) do={
        # Di sini comment diisi dengan $dateNow (tanggal sebelum diaktifkan)
        add name=$pppNama password=$pppSandi profile=$pppPaket service=$pppService comment=$dateNow
        :local msg0 "PPPoE%20Bulanan:%20Pelanggan%20baru%20$pppNama%20berhasil%20ditambahkan.%20Paket:%20$pppPaket."
        :log warning "PPPoE Bulanan: Pelanggan baru $pppNama berhasil ditambahkan."
        /tool fetch url="https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatId&text=$msg0" check-certificate=no keep-result=no
    } else={
        :local msg1 "PPPoE:%20Gagal%20menambah%20user.%20Nama%20'$pppNama'%20sudah%20terdaftar!"
        :log error "PPPoE: Gagal menambah user. Nama sudah terdaftar."
        /tool fetch url="https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatId&text=$msg1" check-certificate=no keep-result=no
    }
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
