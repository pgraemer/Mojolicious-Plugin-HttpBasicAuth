#!perl
use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Mojo::ByteStream 'b';
use Test::Mojo;

my $tested_realm;
plugin 'http_basic_auth' => {
    validate => sub {
        my $c = shift;
        my $u = shift;
        my $p = shift;
        my $r = shift;
        $tested_realm = $r;

        return 1 if ($u eq 'foo' && $p eq 'bar');
        return 0;
      }
};

get '/' => sub {
    my $self = shift;
    return unless $self->basic_auth();
    $self->render(text => 'Hello Mojo!');
};

under sub {
    my $self = shift;
    return unless $self->basic_auth();
};

get '/under-bridge' => sub {
    my $self = shift;
    $self->render(text => 'Hello Mojo!');
};

my $t = Test::Mojo->new;

for my $uri (qw(/ /under-bridge)) {

    diag "Testing " . $uri;

    # auth required
    $t->get_ok($uri)->status_is(401)->header_is('WWW-Authenticate' => 'Basic realm="WWW"')->content_like(qr/Authorization Required/);

    # via Browser credentials

    # auth passed
    my $url = $t->ua->server->url->userinfo('foo:bar')->path($uri);
    $t->get_ok($url)->status_is(200)->content_like(qr/Hello Mojo!/);
    is($tested_realm, 'WWW', 'Testing sub gets correct Realm');
    $tested_realm = undef;

    # password only
    $url = $t->ua->server->url->userinfo(':bar')->path($uri);
    $t->get_ok($url)->status_is(401)->header_is('WWW-Authenticate' => 'Basic realm="WWW"')->content_like(qr/Authorization Required/);

    # user only
    $url = $t->ua->server->url->userinfo('foo:')->path($uri);
    $t->get_ok($url)->status_is(401)->header_is('WWW-Authenticate' => 'Basic realm="WWW"')->content_like(qr/Authorization Required/);

    # empty
    $url = $t->ua->server->url->userinfo(':')->path($uri);
    $t->get_ok($url)->status_is(401)->header_is('WWW-Authenticate' => 'Basic realm="WWW"')->content_like(qr/Authorization Required/);

    # via http header

    # auth passed
    my $encoded = b('foo:bar')->b64_encode->to_string;
    chop $encoded;

    $t->get_ok($uri, { Authorization => "Basic $encoded" })->status_is(200)->content_like(qr/Hello Mojo!/);

    # password only
    $encoded = b(':bar')->b64_encode->to_string;
    chop $encoded;
    $t->get_ok($uri, { Authorization => "Basic $encoded" })->status_is(401)->header_is('WWW-Authenticate' => 'Basic realm="WWW"')->content_like(qr/Authorization Required/);

    # user only
    $encoded = b('foo:')->b64_encode->to_string;
    chop $encoded;
    $t->get_ok($uri, { Authorization => "Basic $encoded" })->status_is(401)->header_is('WWW-Authenticate' => 'Basic realm="WWW"')->content_like(qr/Authorization Required/);

    # empty
    $encoded = b(':')->b64_encode->to_string;
    chop $encoded;
    $t->get_ok($uri, { Authorization => "Basic $encoded" })->status_is(401)->header_is('WWW-Authenticate' => 'Basic realm="WWW"')->content_like(qr/Authorization Required/);

} ## end for my $uri (qw(/ /under-bridge))

done_testing();
