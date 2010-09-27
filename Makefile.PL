use inc::Module::Install;
name 'XMLRPC-Transport-HTTP-PSGI';
all_from 'lib/XMLRPC/Transport/HTTP/PSGI.pm';

# requires '';
# requires 'Exporter' => 5.63; # use Exporter 'import';
# requires 'Plack' =>  0.9949;



readme_markdown_from 'lib/XMLRPC/Transport/HTTP/PSGI.pm';
tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More' => 0.96; # done_testing, subtest
author_tests('xt');
# test_requires 'YAML'; # required for use_test_base.
# use_test_base;
WriteAll;