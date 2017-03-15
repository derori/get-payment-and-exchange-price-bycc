#!/bin/env perl

use 5.24.1;
use Data::Dumper;
use LWP;
use LWP::UserAgent::JSON;
use JSON;
use File::Slurp;
use Digest::SHA qw(hmac_sha256_hex);

use constant ACCESS_KEY => $ENV{"ACCESS_KEY"};
use constant API_SECRET => $ENV{"API_SECRET"};
use constant ACCESS_NONCE => time();
use constant ACCESS_URI => 'https://coincheck.com/api/ec/buttons';


my $user_agent = LWP::UserAgent::JSON->new(agent => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36');
my $req = HTTP::Request::JSON->new(GET => 'https://coincheck.jp/api/ticker');

my $res = $user_agent->request($req);

my $tick = decode_json($res->content);

say Dumper $tick;

my $j = {button => {
    name     => "ddddkottgdaizyobu",
    currency => "JPY",
    display_currency => "USD",
    amount   => 10000
}};

my $body = encode_json($j);

my $user_agent = LWP::UserAgent::JSON->new(agent => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36');
my $req    = HTTP::Request::JSON->new(POST => ACCESS_URI);
$req->header(
    'ACCESS-KEY'       => ACCESS_KEY,
    'ACCESS-NONCE'     => ACCESS_NONCE,
    'ACCESS-SIGNATURE' => hmac_sha256_hex(ACCESS_NONCE . ACCESS_URI . $body, API_SECRET)
);

$req->json_content($j);

my $res = $user_agent->request($req);

my $pay = decode_json($res->content);
if(!$pay->{success}){
    die(Dumper $pay);
}
warn Dumper $pay->{button};
warn Dumper $pay->{button}->{url};
exit;


my $file = '/opt/prometheus/collector/bitflyer.prom';
my $data;

# $data .= 'payment' . ' ' . $d->{d}->{TradeBTC24h_MM} . "\n";
# $data .= 'exchange_bid' . ' ' .  $d->{d}->{TradeBTC24h_Juliet} . "\n";
# $data .= 'exchange_ask' . ' ' . $d->{d}->{FX_BTC_JPY}->{TradeAmount24h} . "\n";

write_file($file, $data);
