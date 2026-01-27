@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row">
        <div class="col-md-12">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h2 class="panel-title">Dashboard</h2>
                </div>
                <div class="panel-body">
                    Selamat datang di Menu Administrasi Larapus. Silahkan pilih menu administrasi yang diinginkan.
                    <hr>
                    <h4>Statistik Penulis</h4>
                    <canvas id="chartPenulis" width="400" height="150"></canvas>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.3/Chart.min.js"></script>
<script>
    var data = {
        labels: {!! json_encode($authors) !!},
        datasets: [{
            label: 'Jumlah buku',
            data: {!! json_encode($books) !!},
            backgroundColor: [
                'rgba(255, 99, 132, 0.6)',   
                'rgba(54, 162, 235, 0.6)',   
                'rgba(255, 206, 86, 0.6)',   
                'rgba(75, 192, 192, 0.6)',   
                'rgba(153, 102, 255, 0.6)',  
                'rgba(255, 159, 64, 0.6)',   
                'rgba(201, 203, 207, 0.6)',  
                'rgba(0, 204, 102, 0.6)',    
                'rgba(204, 0, 204, 0.6)'     
            ],
            borderColor: [
                'rgba(255, 99, 132, 1)',
                'rgba(54, 162, 235, 1)',
                'rgba(255, 206, 86, 1)',
                'rgba(75, 192, 192, 1)',
                'rgba(153, 102, 255, 1)',
                'rgba(255, 159, 64, 1)',
                'rgba(201, 203, 207, 1)',
                'rgba(0, 204, 102, 1)',
                'rgba(204, 0, 204, 1)'
            ],
            borderWidth: 1
        }]
    };

    var options = {
        responsive: true,
        legend: {
            position: 'top',
        },
        scales: {
            yAxes: [{
                ticks: {
                    beginAtZero: true,
                    stepSize: 1
                }
            }]
        }
    };

    var ctx = document.getElementById("chartPenulis").getContext("2d");
    var authorChart = new Chart(ctx, {
        type: 'pie', 
        data: data,
        options: options
    });
</script>
@endsection