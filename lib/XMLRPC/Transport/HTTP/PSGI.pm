package XMLRPC::Transport::HTTP::PSGI;

package #
    SOAP::Transport::HTTP::PSGI;
use strict;
use warnings;
use 5.00800;
our $VERSION = '0.01';
use SOAP::Transport::HTTP;
use SOAP::Lite;
use parent -norequire, qw(SOAP::Transport::HTTP::Server);
use Plack::Request;

sub DESTROY { SOAP::Trace::objects('()') }

sub new {
    my $self = shift;
    return $self if ref $self;

    my $class = ref($self) || $self;
    $self = $class->SUPER::new(@_);
    SOAP::Trace::objects('()');

    return $self;
}

sub make_response {
    my $self = shift;
    $self->SUPER::make_response(@_);
}

sub handle {
    my $self = shift->new;

    sub {
        my $env = shift;
        my $req = Plack::Request->new($env);

        my $length = $req->content_length || 0;

        # TODO: support Transfer-Encoding: chuncked

        if ( !$length ) {
            return [ 411, [], [] ];
        }
        elsif ( defined $SOAP::Constants::MAX_CONTENT_SIZE
            && $length > $SOAP::Constants::MAX_CONTENT_SIZE )
        {
            return [ 413, [], [] ];
        }
        else {
            my $status = 200;
            if ( exists $env->{EXPECT}
                && $env->{EXPECT} =~ /\b100-Continue\b/i )
            {
                $status = 100;
            }

            my $content = $req->content;

            $self->request(
                HTTP::Request->new(
                    ($env->{'REQUEST_METHOD'} || '') => $env->{'SCRIPT_NAME'},
                    HTTP::Headers->new(
                        map {
                            (
                                  /^HTTP_(.+)/i
                                ? ( $1 =~ m/SOAPACTION/ )
                                      ? ('SOAPAction')
                                      : ($1)
                                : $_
                              ) => $env->{$_}
                          } grep !/^(?:psgix\.|psgi\.|plack\.)/, keys %$env
                    ),
                    $content,
                )
            );
            $self->SUPER::handle;
        }

        my $res = $self->response;
        return [
            $res->code,
            +[
                map {
                    my $k = $_;
                    map { ( $k => $_ ) } $res->headers->header($_);
                  } $res->headers->header_field_names
            ],
            [ $res->content ]
        ];
    };
}

package XMLRPC::Transport::HTTP::PSGI;
use XMLRPC::Lite;

@XMLRPC::Transport::HTTP::PSGI::ISA = qw(SOAP::Transport::HTTP::PSGI);

sub initialize;
*initialize = \&XMLRPC::Server::initialize;

sub make_fault {
    local $SOAP::Constants::HTTP_ON_FAULT_CODE = 200;
    shift->SUPER::make_fault(@_);
}

sub make_response {
    local $SOAP::Constants::DO_NOT_USE_CHARSET = 1;
    shift->SUPER::make_response(@_);
}

1;
__END__

=encoding utf8

=head1 NAME

XMLRPC::Transport::HTTP::PSGI -

=head1 SYNOPSIS

  use XMLRPC::Transport::HTTP::PSGI;

=head1 DESCRIPTION

XMLRPC::Transport::HTTP::PSGI is

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

Copyright (C) Tokuhiro Matsuno

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
