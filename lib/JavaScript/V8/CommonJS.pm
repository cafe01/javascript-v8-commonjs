package JavaScript::V8::CommonJS;

use Mojo::Base -base;
use strictures 2;
use Mojo::File 'path';
use JavaScript::V8;
use JavaScript::V8::CommonJS::Exception;
use Cwd;
use Data::Dumper;
use Data::Printer;

our $VERSION = "0.01";

my $scripts_dir = path(__FILE__)->sibling('scripts');


has 'paths' => sub { [getcwd()] };
has 'c' => \&_build_ctx;
has 'modules' => sub { {} };


sub _build_ctx {
    my $self = shift;
    my $c = JavaScript::V8::Context->new;


    # global functions
    for my $name (qw/ readFile resolveModule requireNative /) {

        $c->bind($name => sub {
            $self->can("_$name")->($self, @_);
        });
    }

    $c->bind(
        console => {
            log => \&_log
        }
    );

    # require.js
    my $require_js = $scripts_dir->child("require.js");
    _eval($c, $require_js->slurp, $require_js->to_string);

    $c;
}

sub add_module {
    my ($self, $name, $module) = @_;
    my $mods = $self->modules;
    die "add_module() error: '$name' already exists'" if exists $mods->{$name};
    $mods->{$name} = $module;
}


sub _requireNative {
    my ($self, $id) = @_;
    $self->modules->{$id};
}

sub _resolveModule {
    my ($self, $id) = @_;

    # relative
    foreach my $path (@{$self->paths}) {
        my $file = path($path)->child($id.".js");
        return "$file" if -f $file;
    }

    return undef;
}


sub _readFile {
    my ($self, $path) = @_;
    my $file = path($path);
    return undef unless -e $file;
    $file->slurp;
}


sub _log {
    my (@lines) = @_;
    @lines = map { ref ? Dumper($_) : $_ } @lines;
    printf STDERR "# [console.log] @lines\n";
}

sub eval {
    my $self = shift;
    _eval($self->c, @_);
};

sub _eval {
    my ($c, $code, $source) = @_;
    local $@ = undef;
    my $rv = $c->eval($code, $source || ());
    if (!defined $rv && $@) {
        my ($msg, $source, $line) = $@ =~ /(.*) at (.*):(\d+)$/;
        die JavaScript::V8::CommonJS::Exception->new({
            message => $msg,
            source => $source,
            line => $line
        })
    }
    $rv;
};




# use File::Basename qw(dirname);
# use IO::File;
#
# my %MODS = ();
# sub _absolute {
#     my $path = shift;
#     if($path =~ m|^\./(.*)|) {
#         $path = dirname($JSPL::This->{module}{id}) . "/$1";
#     }
#     $path;
# }
#
# my @Paths = ();
#
# sub _require {
#     my $path = shift;
#     $path = _absolute($path);
#     my $incs = $MODS{$JSPL::Context::CURRENT};
#     return $incs->{$path} if($incs->{$path});
#     for(@Paths) {
#         my $file = "$_/$path.js";
#         if(-r $file) {
#             my $ctx = JSPL::Context->current;
#             my $gbl = $ctx->get_global;
#             my $scope = $ctx->new_object;
#             $scope->{'exports'} = $ctx->new_object($scope);
#             $incs->{$path} = $scope->{'exports'};
#             $scope->{'module'} = $ctx->new_object($scope);
#             $scope->{'module'}{'id'} = $path;
#             $scope->{'require'} = $gbl->{'require'};
#             $ctx->jsc_eval($scope, undef, $file);
#             return $incs->{$path};
#         }
#     }
#     die "Can't open $path\n";
# }
#
# our @System = (
#     env => \%ENV,
#     args => \@main::ARGS,
#     platform => 'JSPL commonJS',
#     stdout => IO::Handle->new_from_fd(fileno(STDOUT), 'w'),
#     stdin => IO::Handle->new_from_fd(fileno(STDIN), 'r'),
#     stderr => IO::Handle->new_from_fd(fileno(STDERR), 'w'),
# );
#
# $JSPL::Runtime::Plugins{commonJS} = {
#     ctxcreate => sub {
#         my $ctx = shift;
#         $MODS{$ctx->id} = {
#             program => $ctx->eval(q|var require, exports = {}; exports;|)
#         };
#         $ctx->bind_all(
#             'require' => \&_require,
#             'require.paths' => \@Paths,
#             'require.main' => undef
#         );
#     },
#     main => sub {
#         my $ctx = shift;
#         my $prgname = shift;
#         push @Paths, dirname($prgname);
#         my $sys = $ctx->new_object;
#         while(my($k, $v) = splice(@System, 0,  2)) {
#             $sys->STORE($k, $v);
#         }
#         $sys->STORE('global', $ctx->get_global);
#         $sys->STORE('command', $prgname);
#         my $ctl = $ctx->get_controller;
#         $ctl->_chktweaks('IO::Handle', $ctl->add('IO::Handle'));
#         $MODS{$ctx->id}{'system'} = $sys;
#     },
# };



1;
__END__

=encoding utf-8

=head1 NAME

CommonJS - It's new $module

=head1 SYNOPSIS

    use CommonJS;

=head1 DESCRIPTION

CommonJS is ...

=head1 LICENSE

Copyright (C) Carlos Fernando Avila Gratz.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Carlos Fernando Avila Gratz E<lt>cafe@kreato.com.brE<gt>

=cut
