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
    if (config('app.env') === 'production') {
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
