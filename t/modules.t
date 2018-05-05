use strict;
use Test2::V0;
use Test2::Tools::Exception qw/dies lives/;
use JavaScript::V8::CommonJS;
use FindBin;
use Data::Dumper;

my $js = JavaScript::V8::CommonJS->new(paths => ["$FindBin::Bin/modules"]);

$js->add_module( test => {
    assert => sub { ok $_[0], $_[1] },
    print  => sub { diag "@_" },
});


js_test('relative');



sub js_test {
    my $name = shift;
    my $dir = "$FindBin::Bin/modules/1.0/$name/";
    my $file = "$dir/program.js";
    die "missing js test '$file'" unless -f $file;

    subtest "$name" => sub {
        local $js->{paths} = [$dir];
        $js->eval_file($file);
    };
}



done_testing;
