#!/usr/bin/perl

use strict; use warnings; use utf8; use feature ':5.10';

use HTTP::Request;
use LWP::UserAgent;
use Data::Dumper;

my $uri = 'http://127.0.0.1:880/';
my $json = '{"topics":["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef","0x0000000000000000000000000000000000000000000000000000000000000000","0x000000000000000000000000cb682d89265ab8c7ffa882f0ceb799109bc2a8b0"],"abi":[{"name":"from","indexed":true,"type":"address"},{"type":"address","name":"to","indexed":true},{"name":"value","indexed":false,"type":"uint256"}],"data":"0x00000000000000000000000000000000000000000000021e19e0c9bab2400000"}';
my $req = HTTP::Request->new( 'POST', $uri );
$req->header( 'Content-Type' => 'application/json' );
$req->content( $json );

my $lwp = LWP::UserAgent->new;
my $res = $lwp->request( $req );

print Dumper($res);


1;
