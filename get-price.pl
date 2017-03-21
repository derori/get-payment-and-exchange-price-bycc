#!/bin/env perl

use 5.24.1;
use Data::Dumper;
use LWP;
use LWP::UserAgent::JSON;
use HTTP::Request::JSON;
use JSON;
use File::Slurp;
use Digest::SHA qw(sha256 hmac_sha256_base64 sha256_hex hmac_sha256_hex);

use constant ACCESS_KEY => $ENV{"ACCESS_KEY"};
use constant API_SECRET => $ENV{"API_SECRET"};
use constant ACCESS_NONCE => time();
use constant ACCESS_URI => 'https://coincheck.com/api/ec/buttons';

my $user_agent = LWP::UserAgent::JSON->new(agent => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36');
my $req = HTTP::Request::JSON->new(GET => 'https://coincheck.jp/api/ticker');

my $res = $user_agent->request($req);

my $tick = decode_json($res->content);

say Dumper $tick;

my $j = {"button" => {
    "name"     => "DTEST",
    "currency" => "JPY",
    "amount"   => 5000
   }};

warn Dumper $j;
#exit;

my $body = JSON->new->encode($j);

my $ua = LWP::UserAgent::JSON->new(agent => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36');
my $req = HTTP::Request::JSON->new();
$req->method('POST');
$req->uri(ACCESS_URI);
$req->json_content($j);
$req->header(
    ACCESS_KEY       => ACCESS_KEY,
    ACCESS_NONCE     => ACCESS_NONCE,
    ACCESS_SIGNATURE => hmac_sha256_hex(ACCESS_NONCE . ACCESS_URI . $req->content(), API_SECRET)
);


warn $req->as_string();

my $res = $ua->request($req);
warn Dumper $res;
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
