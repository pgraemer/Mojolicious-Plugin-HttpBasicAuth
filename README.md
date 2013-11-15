# NAME

Mojolicious::Plugin::HttpBasicAuth - Http-Basic-Authentication implementation

# SYNOPSIS

    # in your startup
    $self->plugin(
        'http_basic_auth', {
            validate => sub {
                my $c         = shift;
                my $loginname = shift;
                my $password  = shift;
                return 1 if($loginname eq 'Homer' && $password eq 'Marge');
                return 0;
            },
            realm => 'Homers Home'
        }
    );

    # in your routes
    sub index {
        my $self = shift;
        return unless $self->basic_auth(\%options);
        $self->render();
    }



# DESCRIPTION

[Mojolicious::Plugin::HttpBasicAuth](https://metacpan.org/pod/Mojolicious::Plugin::HttpBasicAuth) is a implemntation of the Http-Basic-Authentication

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
              return 1 if($loginname eq 'Homer' && $password eq 'Marge');
              return 0;
        }
    });

Validation callback to verify user. This option is __mandatory__.

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

Callback vor invalid requests, default can be seen here. Return values are dispatched to ["respond_to" in Mojolicious::Controller](https://metacpan.org/pod/Mojolicious::Controller#respond_to)

# HELPERS

[Mojolicious::Plugin::HttpBasicAuth](https://metacpan.org/pod/Mojolicious::Plugin::HttpBasicAuth) implements the following helpers.

## basic\_auth

    return unless $self->basic_auth({realm => 'Marges Kitchen'});

All default options can be overwritten in every call.

# METHODS

[Mojolicious::Plugin::HttpBasicAuth](https://metacpan.org/pod/Mojolicious::Plugin::HttpBasicAuth) inherits all methods from
[Mojolicious::Plugin](https://metacpan.org/pod/Mojolicious::Plugin) and implements the following new ones.

## register

    my $route = $plugin->register(Mojolicious->new);
    my $route = $plugin->register(Mojolicious->new, {realm => 'Fort Knox'});

Register renderer and helper in [Mojolicious](https://metacpan.org/pod/Mojolicious) application.

# SEE ALSO

[Mojolicious](https://metacpan.org/pod/Mojolicious), [Mojolicious::Guides](https://metacpan.org/pod/Mojolicious::Guides), [http://mojolicio.us](http://mojolicio.us).

# AUTHOR

Patrick Grämer, [http://graemer.org](http://graemer.org).
