#!/usr/bin/perl

use strict; use warnings; use utf8; use feature ':5.10';

use LWP;
use JSON::PP qw(decode_json encode_json);


print "Content-Type: application/json\r\n\r\n";

sub getData {
    my $query = shift;
    my $endpoints = shift;
    my $json = JSON::PP->new->utf8->pretty;
    
    my $maxBlocktime = 600; # Last block timestamp $maxBlocktime seconds ago...

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
            $data = $json->decode( $res->content );
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
                $results{$data->{data}{timestamp}}{json} = $json->encode($data);
                $fails++;
                next;
            } else {
                $results{$data->{data}{timestamp}} = $data;
                $results{$data->{data}{timestamp}}{json} = $json->encode($data);
            }
        }
        
        my @SRK = sort { $a <=> $b } keys %results;
        return $results{$SRK[-1]}->{json} if( $maxBlocktime > (time - $results{$SRK[-1]}->{data}{timestamp}) || $fails == scalar @$endpoints ); 
    }
}

print getData('{"method":"eth.contract.CMR_Mining.read"}', ['http://ethereum-full.mine.io:88','http://ethereum-rinkeby.mine.io:88','http://ethereum-full.mine.io:91','http://ethereum-rinkeby:91','http://localhost:91']);


1;