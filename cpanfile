requires 'perl', '5.008005';
requires 'Mojolicious';

# requires 'Some::Module', 'VERSION';

on test => sub {
    requires 'Test::More', '0.88';
    requires 'Test::Mojo';
};
