package JavaScript::V8::CommonJS::Exception;

use strict;
use warnings;
use overload '""' => 'to_string';



sub new {
    my $class = shift;
    my $args = shift || {};
    $class = ref $class if ref $class;
    my $self = bless {
        message => $args->{message} || '',
        source  => $args->{source}  || '?',
        line    => $args->{line}  || '?',
    }, $class;

    $self;
}


sub message { shift->{message} }
sub source { shift->{source} }
sub line { shift->{line} }


sub to_string {
    my $self = shift;
    sprintf "[javascript exception] %s at %s:%s", $self->message, $self->source, $self->line;
}


1;
