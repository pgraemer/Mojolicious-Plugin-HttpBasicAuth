# NAME

Mojolicious::Plugin::HttpBasicAuth - Http-Basic-Authentication implementation for Mojolicious

# SYNOPSIS

    # in your startup
    $self->plugin(
        'http_basic_auth', {
            validate => sub {
                my $c         = shift;
                my $loginname = shift;
                my $password  = shift;
                my $realm     = shift;
                return 1 if($realm eq 'Evergreen Terrace' && $loginname eq 'Homer' && $password eq 'Marge');
                return 0;
            },
            realm => 'Evergreen Terrace'
        }
    );

    # in your routes
    sub index {
        my $self = shift;
        return unless $self->basic_auth(\%options);
        $self->render();
    }

    # or bridged
    my $foo = $r->bridge('/bridge')->to(cb => sub {
        my $self = shift;
        # Authenticated
        return unless $self->basic_auth({realm => 'Castle Bridge', validate => sub {return 1;}});
    });
    $foo->route('/bar')->to(controller => 'foo', action => 'bar');

# DESCRIPTION

[Mojolicious::Plugin::HttpBasicAuth](https://metacpan.org/pod/Mojolicious::Plugin::HttpBasicAuth) is a implementation of the Http-Basic-Authentication

# OPTIONS

[Mojolicious::Plugin::HttpBasicAuth](https://metacpan.org/pod/Mojolicious::Plugin::HttpBasicAuth) supports the following options.

## realm

    $self->plugin('http_basic_auth', {realm => 'My Castle!'});

HTTP-Realm, defaults to 'WWW'

## validate

    $self->plugin('http_basic_auth', {
        validate => sub {
              my $c          = shift;
              my $loginname  = shift;
              my $password   = shift;
              my $realm      = shift;
              return 1 if($realm eq 'Springfield' && $loginname eq 'Homer' && $password eq 'Marge');
              return 0;
        }
    });

Validation callback to verify user. This option is **mandatory**.

## invalid

    $self->plugin('http_basic_auth', {
        invalid => sub {
            my $controller = shift;
            return (
                json => { json     => { error => 'HTTP 401: Unauthorized' } },
                html => { template => 'auth/basic' },
                any  => { data     => 'HTTP 401: Unauthorized' }
            );
        }
    });

Callback for invalid requests, default can be seen here. Return values are dispatched to ["respond\_to" in Mojolicious::Controller](https://metacpan.org/pod/Mojolicious::Controller#respond_to)

# HELPERS

[Mojolicious::Plugin::HttpBasicAuth](https://metacpan.org/pod/Mojolicious::Plugin::HttpBasicAuth) implements the following helpers.

## basic\_auth

    return unless $self->basic_auth({realm => 'Kitchen'});

All default options can be overwritten in every call.

# METHODS

[Mojolicious::Plugin::HttpBasicAuth](https://metacpan.org/pod/Mojolicious::Plugin::HttpBasicAuth) inherits all methods from
[Mojolicious::Plugin](https://metacpan.org/pod/Mojolicious::Plugin) and implements the following new ones.

## register

    my $route = $plugin->register(Mojolicious->new);
    my $route = $plugin->register(Mojolicious->new, {realm => 'Fort Knox', validate => sub {
        return 0;
    }});

Register renderer and helper in [Mojolicious](https://metacpan.org/pod/Mojolicious) application.

# SEE ALSO

[Mojolicious](https://metacpan.org/pod/Mojolicious), [Mojolicious::Guides](https://metacpan.org/pod/Mojolicious::Guides), [http://mojolicio.us](http://mojolicio.us).

# AUTHOR

Patrick Grämer <pgraemer@cpan.org>
, [http://graemer.org](http://graemer.org).

# COPYRIGHT

Copyright 2015 Patrick Grämer

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
