#!/usr/bin/perl

use strict; use warnings; use utf8; use feature ':5.10';

use LWP;
use JSON::PP qw(decode_json);
use POSIX 'strftime';


sub getData {
    my $query = shift;
    my $endpoints = shift;
    my $maxBlocktime = shift || 600; # Last block timestamp $maxBlocktime seconds ago...

    my %results;
    my $fails = 0;
    for my $api_url ( @$endpoints ) {
        my $req = HTTP::Request->new( 'POST', $api_url );
        $req->header( 'Content-Type' => 'application/json' );
        $req->content( $query );
        my $lwp = LWP::UserAgent->new;
        my $res = $lwp->request( $req );
        
        my $data = {};
        eval { 
            $data = decode_json( $res->content );
            $data->{data}{api_url} = $api_url;
            unless( defined $data->{meta}{rc} && $data->{meta}{rc} == 200 && defined $data->{data}{timestamp} ) {
                $fails++;
                next;
            }
            1; 
        } or do {
            $fails++;
            next unless( $fails == scalar @$endpoints );
        };
        
        unless( $fails == scalar @$endpoints && scalar keys %results ) {
            if( $fails == scalar @$endpoints ) {
                print '{"meta":{"time":"'.strftime('%Y-%m-%d %H:%M:%S',localtime).'", "rc":500, "msg":"getData() - Could not connect to any API :-("}}'."\n";
                exit 1;
            } elsif ( $maxBlocktime < (time - $data->{data}{timestamp}) && $fails < scalar @$endpoints) {
                $results{$data->{data}{timestamp}} = $data;
                $fails++;
                next;
            } else {
                $results{$data->{data}{timestamp}} = $data;
            }
        }
        
        my @SRK = sort { $a <=> $b } keys %results;
        return $results{$SRK[-1]} if( $maxBlocktime > (time - $results{$SRK[-1]}->{data}{timestamp}) || $fails == scalar @$endpoints ); 
    }
}

sub sendRequest {
    my $query = shift;
    my $api_url = shift;

    my $req = HTTP::Request->new( 'POST', $api_url );
    $req->header( 'Content-Type' => 'application/json' );
    $req->content( $query );
    my $lwp = LWP::UserAgent->new;
    my $res = $lwp->request( $req );
    
    my $data = {};
    eval {
        $data = decode_json( $res->content );
        $data->{data}{api_url} = $api_url;
        1;
    } or do {
        print '{"meta":{"time":"'.strftime('%Y-%m-%d %H:%M:%S',localtime).'", "rc":500, "msg":"sendRequest() - error.decode_json:'.$@.'"}}'."\n";
        exit 1;
    };
    
    return $data; 
}


my $maxBlocktime = 240;
my $remainingFunds = 0.101;
my $minAmount = 0.8;
my $data = getData('{"method":"eth.node.balance"}', ['http://ethereum-full.mine.io:88','http://ethereum-rinkeby.mine.io:88'], $maxBlocktime);

if( $maxBlocktime < (time - $data->{data}{timestamp}) ) {
    print '{"meta":{"time":"'.strftime('%Y-%m-%d %H:%M:%S',localtime).'", "rc":500, "msg":"To old block: '.(time - $data->{data}{timestamp}).' sec, maxBlocktime: '.$maxBlocktime.' sec"}}'."\n";
}
elsif ( $data->{data}{balance_eth} < ($minAmount + $remainingFunds) ) {
    print '{"meta":{"time":"'.strftime('%Y-%m-%d %H:%M:%S',localtime).'", "rc":500, "msg":"To less balance: '.$data->{data}{balance_eth}.' ETH, minBalance: '.($minAmount + $remainingFunds).' ETH"}}'."\n";
}
elsif ( $maxBlocktime > (time - $data->{data}{timestamp}) && $data->{data}{balance_eth} > ($minAmount + $remainingFunds) ) {
    my $result = sendRequest('{"method":"eth.node.exchange"}', $data->{data}{api_url});
    eval {
        my $json = JSON::PP->new->utf8->pretty;
        print $json->encode( $result );
        1;
    } or do {
        print '{"meta":{"time":"'.strftime('%Y-%m-%d %H:%M:%S',localtime).'", "rc":500, "msg":"main($result) - error.decode_json:'.$@.'"}}'."\n";
        exit 1;
    };
}


1;