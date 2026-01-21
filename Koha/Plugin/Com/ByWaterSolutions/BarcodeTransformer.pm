package Koha::Plugin::Com::ByWaterSolutions::BarcodeTransformer;

use Modern::Perl;

use base qw(Koha::Plugins::Base);

use C4::Context;
use C4::Auth;

use YAML qw(Load);

our $VERSION = "{VERSION}";
our $MINIMUM_VERSION = "{MINIMUM_VERSION}";

our $metadata = {
    name            => 'Scanned Barcode Transformer',
    author          => 'Kyle M Hall',
    date_authored   => '2020-07-02',
    date_updated    => "1900-01-01",
    minimum_version => $MINIMUM_VERSION,
    maximum_version => undef,
    version         => $VERSION,
    description     => 'Transform scanned barcodes',
};

sub new {
    my ( $class, $args ) = @_;

    $args->{'metadata'} = $metadata;
    $args->{'metadata'}->{'class'} = $class;

    my $self = $class->SUPER::new($args);

    return $self;
}

sub patron_barcode_transform {
    my ( $self, $barcode ) = @_;

    $self->barcode_transform( 'patron', $barcode );
}

sub item_barcode_transform {
    my ( $self, $barcode ) = @_;

    $self->barcode_transform( 'item', $barcode );
}

sub barcode_transform {
    my ( $self, $type, $barcode_ref ) = @_;

    my $barcode = $$barcode_ref;

    my $yaml = $self->retrieve_data('yaml_config');
    return $barcode unless $yaml;

    my $data;
    eval { $data = YAML::Load( $yaml ); };
    return $barcode unless $data;

    my $transformations = $data->{$type};
    return $barcode unless $transformations;

    foreach my $t ( @$transformations ) {
        my $match = $t->{match};
        my $search = $t->{search};
        my $replace = $t->{replace};

        next unless $match && $search;

        my $is_match = $barcode =~ m/$match/g;
        if ( $is_match ) {
            if ( ref($replace) ) {
                my $branchcode = C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef;
                my $new_replace;

                if ( ref($replace) eq 'HASH' ) {
                    $new_replace = $replace->{$branchcode} // $replace->{'_default'};
                }

                next unless defined $new_replace;
                $replace = $new_replace;
            }

            $barcode =~ s/$search/$replace/g;
        }
    }

    $$barcode_ref = $barcode;
}

sub configure {
    my ( $self, $args ) = @_;
    my $cgi = $self->{'cgi'};

    unless ( $cgi->param('save') ) {
        my $template = $self->get_template({ file => 'configure.tt' });

        my $yaml = $self->retrieve_data('yaml_config');
        my $data;
        eval { $data = YAML::Load( $yaml ); };

        ## Grab the values we already have for our settings, if any exist
        $template->param(
            yaml_config => $self->retrieve_data('yaml_config'),
            yaml_error => $yaml && !$data,
        );

        $self->output_html( $template->output() );
    }
    else {
        $self->store_data(
            {
                yaml_config => $cgi->param('yaml_config'),
            }
        );
        $self->go_home();
    }
}

sub install() {
    my ( $self, $args ) = @_;

    return 1;
}

sub upgrade {
    my ( $self, $args ) = @_;

    return 1;
}

sub uninstall() {
    my ( $self, $args ) = @_;

    return 1;
}

1;
