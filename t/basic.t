#!perl
use Mojo::Base -strict;

use Test::More;
use Mojolicious::Lite;
use Mojo::ByteStream 'b';
use Test::Mojo;

my $tested_realm;
my $custom_setting;

sub validate {
    my $c = shift;
    my $u = shift;
    my $p = shift;
    my $r = shift;
    $tested_realm = $r;

    return 1 if ($u eq 'foo' && $p eq 'bar');
    return 0;
}

plugin 'http_basic_auth' => {
    validate => \&validate
};

get '/' => sub {
    my $c = shift;
    return unless $c->basic_auth($custom_setting);
    $c->render(text => 'Hello Mojo!');
};

get '/delayed' => sub {
    my $c = shift;
    $c->render_later;
    Mojo::IOLoop->timer(0 => sub {
        return unless $c->basic_auth($custom_setting);
        $c->render(text => 'Hello Mojo!');
    });
};

under sub {
    my $c = shift;
    return unless $c->basic_auth($custom_setting);
};

get '/under-bridge' => sub {
    my $c = shift;
    $c->render(text => 'Hello Mojo!');
};

helper unauthorized => sub {
    my $c = shift;
    $c->res->code(401);
    $c->render(json => { error => 'Authorization Required' });
};

my $t = Test::Mojo->new;

my @settings_to_test = (
    # name      value
    ['default', undef],
    ['custom realm', { realm => 'FOO' }],
    ['custom validate', { validate => \&validate }],
    ['custom invalid', { invalid => sub { any => { data => 'Authorization Required' } } }],
    ['custom invalid with sub', { invalid => sub { any => sub { shift->render(text => 'Authorization Required') } } }],
    ['custom invalid using helper', { invalid => sub { any => sub {
        shift->unauthorized;
    } } }],
);

for my $uri (qw(/ /under-bridge /delayed)) {
for my $settings (@settings_to_test) {

    $custom_setting = $settings->[1];
    my $realm = $custom_setting->{realm} // 'WWW';
    diag "Testing " . $uri . " with settings: " . $settings->[0];

    # auth required
    $t->get_ok($uri)->status_is(401)->header_is('WWW-Authenticate' => "Basic realm=\"$realm\"")->content_like(qr/Authorization Required/);

    # via Browser credentials

    # auth passed
    my $url = $t->ua->server->url->userinfo('foo:bar')->path($uri);
    $t->get_ok($url)->status_is(200)->content_like(qr/Hello Mojo!/);
    is($tested_realm, $realm, 'Testing sub gets correct Realm');
    $tested_realm = undef;

    # password only
    $url = $t->ua->server->url->userinfo(':bar')->path($uri);
    $t->get_ok($url)->status_is(401)->header_is('WWW-Authenticate' => "Basic realm=\"$realm\"")->content_like(qr/Authorization Required/);

    # user only
    $url = $t->ua->server->url->userinfo('foo:')->path($uri);
    $t->get_ok($url)->status_is(401)->header_is('WWW-Authenticate' => "Basic realm=\"$realm\"")->content_like(qr/Authorization Required/);

    # empty
    $url = $t->ua->server->url->userinfo(':')->path($uri);
    $t->get_ok($url)->status_is(401)->header_is('WWW-Authenticate' => "Basic realm=\"$realm\"")->content_like(qr/Authorization Required/);

    # via http header

    # auth passed
    my $encoded = b('foo:bar')->b64_encode->to_string;
    chop $encoded;

    $t->get_ok($uri, { Authorization => "Basic $encoded" })->status_is(200)->content_like(qr/Hello Mojo!/);

    # password only
    $encoded = b(':bar')->b64_encode->to_string;
    chop $encoded;
    $t->get_ok($uri, { Authorization => "Basic $encoded" })->status_is(401)->header_is('WWW-Authenticate' => "Basic realm=\"$realm\"")->content_like(qr/Authorization Required/);

    # user only
    $encoded = b('foo:')->b64_encode->to_string;
    chop $encoded;
    $t->get_ok($uri, { Authorization => "Basic $encoded" })->status_is(401)->header_is('WWW-Authenticate' => "Basic realm=\"$realm\"")->content_like(qr/Authorization Required/);

    # empty
    $encoded = b(':')->b64_encode->to_string;
    chop $encoded;
    $t->get_ok($uri, { Authorization => "Basic $encoded" })->status_is(401)->header_is('WWW-Authenticate' => "Basic realm=\"$realm\"")->content_like(qr/Authorization Required/);

} ## end of for my $settings (@settings_to_test)
} ## end for my $uri (qw(/ /under-bridge))

done_testing();
