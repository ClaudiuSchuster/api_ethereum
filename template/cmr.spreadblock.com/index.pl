#!/usr/bin/perl

use strict; use warnings; use utf8; use feature ':5.10';

use LWP;
use JSON::PP qw(decode_json);
use Date::Format;


print "Content-type: text/html\r\n\r\n";


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
                print "<strong>There was a problem, could not connect to any API :-(</strong> </br></br>\n\n";
                exit 1;
            } elsif ( $maxBlocktime < (time - $data->{data}{timestamp}) && $fails < scalar @$nodes) {
                $results{$data->{data}{timestamp}} = $data->{data};
                $fails++;
                next;
            } else {
                $results{$data->{data}{timestamp}} = $data->{data};
            }
        }
        
        my @SRK = sort { $a <=> $b } keys %results;
        return $results{$SRK[-1]} if( $maxBlocktime > (time - $results{$SRK[-1]}->{timestamp}) || $fails == scalar @$nodes ); 
    }
}


my $data = getData('{"method":"eth.contract.CMR_Mining.read"}', ['http://192.168.102.10:88','http://192.168.102.10:90','http://localhost:88']);

print "<html><head><title>CMR_Mining</title>\n";
print qq~  
  <style type="text/css">
    body {
        padding: 8px;
        background-color: #f7fcff;
    }
    table.gradienttable {
        font-family: "Courier New", Courier, "Lucida Sans Typewriter", "Lucida Typewriter", monospace;
        font-size: 16px;
        color: #333333;
        border-width: 1px;
        border-color: #999999;
        border-collapse: collapse;
    }
    table.gradienttable th, table.gradienttable td {
        text-align: center;
        padding: 0 10 0 10;
        border: 1px solid #999999;
    }
    table.gradienttable th {
        background: #d5e3e4;
        background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iI2Q1ZTNlNCIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjQwJSIgc3RvcC1jb2xvcj0iI2NjZGVlMCIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiNiM2M4Y2MiIHN0b3Atb3BhY2l0eT0iMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);
        background: -moz-linear-gradient(top,  #d5e3e4 0%, #ccdee0 40%, #b3c8cc 100%);
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#d5e3e4), color-stop(40%,#ccdee0), color-stop(100%,#b3c8cc));
        background: -webkit-linear-gradient(top,  #d5e3e4 0%,#ccdee0 40%,#b3c8cc 100%);
        background: -o-linear-gradient(top,  #d5e3e4 0%,#ccdee0 40%,#b3c8cc 100%);
        background: -ms-linear-gradient(top,  #d5e3e4 0%,#ccdee0 40%,#b3c8cc 100%);
        background: linear-gradient(to bottom,  #d5e3e4 0%,#ccdee0 40%,#b3c8cc 100%);
    }
    table.gradienttable td {
        background: #ebecda;
        background: url(data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pgo8c3ZnIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgd2lkdGg9IjEwMCUiIGhlaWdodD0iMTAwJSIgdmlld0JveD0iMCAwIDEgMSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ibm9uZSI+CiAgPGxpbmVhckdyYWRpZW50IGlkPSJncmFkLXVjZ2ctZ2VuZXJhdGVkIiBncmFkaWVudFVuaXRzPSJ1c2VyU3BhY2VPblVzZSIgeDE9IjAlIiB5MT0iMCUiIHgyPSIwJSIgeTI9IjEwMCUiPgogICAgPHN0b3Agb2Zmc2V0PSIwJSIgc3RvcC1jb2xvcj0iI2ViZWNkYSIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjQwJSIgc3RvcC1jb2xvcj0iI2UwZTBjNiIgc3RvcC1vcGFjaXR5PSIxIi8+CiAgICA8c3RvcCBvZmZzZXQ9IjEwMCUiIHN0b3AtY29sb3I9IiNjZWNlYjciIHN0b3Atb3BhY2l0eT0iMSIvPgogIDwvbGluZWFyR3JhZGllbnQ+CiAgPHJlY3QgeD0iMCIgeT0iMCIgd2lkdGg9IjEiIGhlaWdodD0iMSIgZmlsbD0idXJsKCNncmFkLXVjZ2ctZ2VuZXJhdGVkKSIgLz4KPC9zdmc+);
        background: -moz-linear-gradient(top,  #ebecda 0%, #e0e0c6 40%, #ceceb7 100%);
        background: -webkit-gradient(linear, left top, left bottom, color-stop(0%,#ebecda), color-stop(40%,#e0e0c6), color-stop(100%,#ceceb7));
        background: -webkit-linear-gradient(top,  #ebecda 0%,#e0e0c6 40%,#ceceb7 100%);
        background: -o-linear-gradient(top,  #ebecda 0%,#e0e0c6 40%,#ceceb7 100%);
        background: -ms-linear-gradient(top,  #ebecda 0%,#e0e0c6 40%,#ceceb7 100%);
        background: linear-gradient(to bottom,  #ebecda 0%,#e0e0c6 40%,#ceceb7 100%);
    }
    a:link, a:visited, a:hover, a:active { color: #006666; }
  </style>
~;
print "\n</head><body>\n\n";

my @members = sort { uc($a) cmp uc($b) } keys %{$data->{members}};
print "<table class='gradienttable'>";
print "<tr><th colspan='".(1 + scalar @members)."' style='padding-bottom:2px; padding-top:2px; border-bottom:0;'>";
print "<a title='Click to open contract on Etherscan.io ...' href='https://etherscan.io/address/$data->{address}#code' target='_blank'><span style='font-size:18px;'>CMR_Mining contract - $data->{address}</span></a>";
print "</th></tr>";
print "<tr><th colspan='".(1 + scalar @members)."' style='padding-bottom:4px; padding-top:2px; border-top:0;'>";
print "<span style='padding: 0 0 0 0;color:#006600;'>Holding ".sprintf("%.3f", $data->{balance_eth})." ETH from $data->{depositCount} deposits over total ".sprintf("%.3f", $data->{deposited_eth})." ETH</span>";
print "</br><span style='color:#006600; font-size:15px;'>@ Ethereum block #<a title='Click to open block on Etherscan.io ...' href='https://etherscan.io/block/$data->{current_block_number}' target='_blank'>".$data->{current_block_number}."</a> ".time2str("[%Y/%m/%d-%X]",$data->{timestamp})."</span>";
print "</th></tr>";
print "<tr><th>Member Address</th>";
print "<th title='$_'>".substr($_, 0, 7).'....'.substr($_, -5)."</th>" for( @members );
print "</tr>";
print "<tr><th>Share %</th>";
print "<td>".$data->{members}{$_}{share}."</td>" for( @members );
print "</tr>";
print "<tr><th>Unpaid ETH</th>";
print "<td><b>".sprintf("%.4f", $data->{members}{$_}{unpaid_eth})."</b></td>" for( @members );
print "</tr>";
print "<tr><th>Unpaid Wei</th>";
print "<td>".$data->{members}{$_}{unpaid_wei}."</td>" for( @members );
print "</tr>";
print "<tr><th>Withdrawals</th>";
print "<td>".$data->{members}{$_}{withdrawalCount}."</td>" for( @members );
print "</tr>";
print "<tr><th>Withdrawed ETH</th>";
print "<td>".sprintf("%.4f", $data->{members}{$_}{withdrawed_eth})."</td>" for( @members );
print "</tr>";
print "<tr><th>Withdrawed Wei</th>";
print "<td>".$data->{members}{$_}{withdrawed_wei}."</td>" for( @members );
print "</tr>";
print "<tr><th>Total ETH</th>";
print "<td>".sprintf("%.4f", $data->{members}{$_}{total_eth})."</td>" for( @members );
print "</tr>";
print "<tr><th>Total Wei</th>";
print "<td>".$data->{members}{$_}{total_wei}."</td>" for( @members );
print "</tr>";
print "</table>";

print "\n\n</body></html>";

1;