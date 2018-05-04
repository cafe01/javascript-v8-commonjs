package JavaScript::V8::CommonJS::Exception;

use Mojo::Base -base;
use overload '""' => 'to_string';

has 'message' => '';
has 'source'  => '?';
has 'line'    => '?';


sub to_string {
    my $self = shift;
    sprintf "[javascript exception] %s at %s:%s", $self->message, $self->source, $self->line;
}


1;
