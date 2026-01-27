<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class BorrowLog extends Model
{
    protected $table = 'borrow_logs';
    protected $fillable = ['book_id', 'user_id', 'is_returned'];

    protected $casts = [
        'is_returned' => 'boolean',
    ];

    public function book()
    {
        return $this->belongsTo('App\Book');
    }

    public function user()
    {
        return $this->belongsTo('App\User');
    }

    public function scopeReturned($query)
    {
        return $query->where('is_returned', true);
    }
    
    public function scopeBorrowed($query)
    {
        return $query->where('is_returned', false);
    }
}
