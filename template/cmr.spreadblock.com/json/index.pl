#!/usr/bin/perl

use strict; use warnings; use utf8; use feature ':5.10';

use LWP;
use JSON;
use JSON::PP qw(decode_json);


print "Content-Type: application/json\r\n\r\n";

sub getData {
    my $qry = shift;
    my $nodes = shift;
    
    my $maxBlocktime = 600; # Last block timestamp $maxBlocktime seconds ago...

    my %results;
    my $fails = 0;
    for ( @$nodes ) {
        my $req = HTTP::Request->new( 'POST', $_ );
        $req->header( 'Content-Type' => 'application/json' );
        $req->content( $qry );
        my $lwp = LWP::UserAgent->new;
        my $res = $lwp->request( $req );
        
        my $data;
        eval { 
            $data = decode_json( $res->content );
            unless( defined $data->{meta}{rc} && $data->{meta}{rc} == 200 && defined $data->{data}{timestamp} ) {
                $fails++;
                next;
            }
            1; 
        } or do {
            $fails++;
            next unless( $fails == scalar @$nodes );
        };
        
        unless( $fails == scalar @$nodes && scalar keys %results ) {
            if( $fails == scalar @$nodes ) {
                print '{"error":"Could not connect to any API :-("}'."\n";
                exit 1;
            } elsif ( $maxBlocktime < (time - $data->{data}{timestamp}) && $fails < scalar @$nodes) {
                $results{$data->{data}{timestamp}} = $data;
                $fails++;
                next;
            } else {
                $results{$data->{data}{timestamp}} = $data;
            }
        }
        
        my @SRK = sort { $a <=> $b } keys %results;
        return $results{$SRK[-1]} if( $maxBlocktime > (time - $results{$SRK[-1]}->{data}{timestamp}) || $fails == scalar @$nodes ); 
    }
}


my $data = getData('{"method":"eth.contract.CMR_Mining.read"}', ['http://192.168.102.10:88','http://192.168.102.10:90','http://localhost:88']);

eval { print JSON->new->pretty->encode($data); 1; } or do {
    print $@;
};


1;