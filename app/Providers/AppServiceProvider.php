<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Hash;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     *
     * @return void
     */
public function boot()
{
    require base_path() . '/app/Helpers/frontend.php';
    
    Validator::extend('passcheck', function ($attribute, $value, $parameters) {
        return Hash::check($value, $parameters[0]);
    });

    // Perbaikan di sini: Paksa HTTPS jika di production ATAU jika diakses via port aman
    if (config('app.env') === 'production' || isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') {
        \Illuminate\Support\Facades\URL::forceSchema('https');
    }
}

    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        //
    }
}
