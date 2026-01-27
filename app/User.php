<?php

namespace App;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laratrust\Traits\LaratrustUserTrait;
use App\Book;
use App\BorrowLog;
use App\Exceptions\BookException;
use Illuminate\Support\Facades\Mail; // BARU: Penting untuk proses kirim email

class User extends Authenticatable
{
    use LaratrustUserTrait, Notifiable;

    protected $fillable = [
        'name', 'email', 'password', 'is_verified',
    ];

    protected $casts = [
        'is_verified' => 'boolean',
    ];

    protected $hidden = [
        'password', 'remember_token',
    ];

    // RELASI KE BORROW LOGS
    public function borrowLogs()
    {
        return $this->hasMany(BorrowLog::class);
    }

    // PROSES PINJAM BUKU
    public function borrow(Book $book)
    {
        // cek stok
        if ($book->stock < 1) {
            throw new BookException("Buku {$book->title} sedang tidak tersedia.");
        }

        // cek apakah user masih meminjam buku ini
        if ($this->borrowLogs()
            ->where('book_id', $book->id)
            ->where('is_returned', false)
            ->exists()) {

            throw new BookException("Buku {$book->title} sedang Anda pinjam.");
        }

        // simpan log peminjaman
        return BorrowLog::create([
            'user_id'     => $this->id,
            'book_id'     => $book->id,
            'is_returned' => false
        ]);
    }

    /**
     * BARU: Method untuk mengirim email verifikasi
     * Dipanggil dari RegisterController
     */
    public function sendVerification()
    {
        $token = $this->generateVerificationToken();
        $user = $this;

        Mail::send('auth.emails.verification', compact('user', 'token'), function ($m) use ($user) {
            $m->to($user->email, $user->name)->subject('Verifikasi Akun Larapus');
        });
    }

    /**
     * BARU: Method untuk membuat token verifikasi acak
     * Disimpan ke kolom 'verification_token' di database
     */
    public function generateVerificationToken()
    {
        $token = str_random(40);
        $this->verification_token = $token;
        $this->save();
        return $token;
    }

    public function verify()
    {
    $this->is_verified = 1;
    $this->verification_token = null;
    $this->save();
    }
}