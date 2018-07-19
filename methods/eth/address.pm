package API::methods::eth::address;

use strict; use warnings; use utf8; use feature ':5.10';


sub test {
    my ($cgi, $data, $node, $params) = @_;
    
    my $rq = { jsonrpc => "2.0", method => "net_version", params => [], id => 67};
    $data->{num} = $node->_node_request($rq)-> { result };
    
    return { 'rc' => 200 };
}



1;





# sub eth_blockNumber()
# {
  # my ($this) = @_;
  # my $rq = { jsonrpc => "2.0", method => "eth_blockNumber", params => [], id => 83};
  # my $num = $this->_node_request($rq)-> { result };
  # my $dec = sprintf("%d", hex($num)) + 0;
  # return $dec;
# }
