use inc::Module::Install;
name 'XMLRPC-Transport-HTTP-PSGI';
all_from 'lib/XMLRPC/Transport/HTTP/PSGI.pm';

requires 'XMLRPC::Lite';
requires 'parent';
test_requires 'Plack' =>  0.9949;

readme_markdown_from 'lib/XMLRPC/Transport/HTTP/PSGI.pm';
tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More' => 0.96; # done_testing, subtest
author_tests('xt');
WriteAll;

