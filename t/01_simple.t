use strict;
use warnings;
use Test::More;
use Test::Requires 'RPC::XML';
use Plack::Test;
use XMLRPC::Transport::HTTP::PSGI;
use RPC::XML::ParserFactory;

{
    package MyRPC;
    sub sum {
        my ($class, $arg1, $arg2) = @_;
        return $arg1 + $arg2;
    }
}

test_psgi(
    app    => XMLRPC::Transport::HTTP::PSGI->dispatch_to("MyRPC")->handle,
    client => sub {
        my $rpc_req     = RPC::XML::request->new( 'MyRPC.sum', 18, 22 );
        my $rpc_content = $rpc_req->as_string;
        my $req         = HTTP::Request->new(
            POST => 'http://localhost/',
            [
                'Content-Length' => length($rpc_content),
                'Content-Type'   => 'text/xml'
            ],
            $rpc_content
        );

        my $code = shift;
        my $res  = $code->($req);
        is $res->code, 200;
        my $rpc_res = RPC::XML::ParserFactory->new()->parse( $res->content );
        is $rpc_res->value->value, 40;
    }
);

done_testing;

