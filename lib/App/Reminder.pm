# Reminder
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>
#
# See http://github.com/user/ritual

#use v5.12;
use feature 'unicode_strings';
use feature 'say';

use strict;

use Config::Tiny;
use Data::Dumper;
use DateTime;
use DateTime::Format::Strptime;
use Email::Address;
use Email::Date::Format;
use Encode;
use Encode::Guess;
use Env;
use Fcntl;
use File::Basename;
use File::HomeDir;
use File::Path;
use File::ShareDir;
use File::Spec;
use File::Temp;
use Getopt::Std;
use MIME::Charset;
use MIME::Lite;
use MIME::Lite::HTML;
use Path::Tiny;
use POSIX;
use Proc::PID::File;
use Text::Trim;
use Text::Wrap;

#use locale;
use utf8;
use open ':std',
    ':encoding(UTF-8)';    # Optional, also affects STDIN/STDOUT/STDERR
binmode( STDIN,  ":encoding(UTF-8)" );    # binmode(STDIN, ":utf8");
binmode( STDOUT, ":encoding(UTF-8)" );    # binmode(STDOUT, ":utf8");
binmode( STDERR, ":encoding(UTF-8)" );    # binmode(STDERR, ":utf8");

package App::Reminder {

    use feature 'unicode_strings';
    use feature 'say';

    #use locale;
    use utf8;
    use open ':std',
        ':encoding(UTF-8)';    # Optional, also affects STDIN/STDOUT/STDERR
    binmode( STDIN,  ":encoding(UTF-8)" );    # binmode(STDIN, ":utf8");
    binmode( STDOUT, ":encoding(UTF-8)" );    # binmode(STDOUT, ":utf8");
    binmode( STDERR, ":encoding(UTF-8)" );    # binmode(STDERR, ":utf8");

    use Log::Log4perl;

    # Initialize configuration inline
    my $conf = q(
    log4perl.rootLogger              = DEBUG, LOGFILE, Screen
    log4perl.appender.LOGFILE        = Log::Log4perl::Appender::File
    log4perl.appender.LOGFILE.filename = app.log
    log4perl.appender.LOGFILE.layout = Log::Log4perl::Layout::PatternLayout
    log4perl.appender.LOGFILE.layout.ConversionPattern = [%d] %p %m%n

    log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
    log4perl.appender.Screen.layout  = Log::Log4perl::Layout::SimpleLayout
);

    Log::Log4perl::init( \$conf );

    our $logger = Log::Log4perl->get_logger();

    $logger->info("Application started");

    #$logger->warn("Low disk space");
    #$logger->error("Cannot connect to database");

    our $BUGREPORT = 'user <user@host>';
    our $NAME      = 'App-Reminder';
    our $URL       = 'http://github.com/user/ritual';
    our $VERSION   = '1.00';

    our $PACKAGE_STRING = "$NAME $VERSION";

    # ~/.reminder
    our $HOME = File::Spec->catfile( File::HomeDir->my_home(), '.reminder' );

    # ~/.config/perl
    our $CONFIG_DIR = File::HomeDir->my_dist_config( $NAME, { create => 1 } );

    # ~/.local/share/perl
    our $DIST_DIR = File::HomeDir->my_dist_data( $NAME, { create => 1 } );

    # File::ShareDir::dist_dir works only if directory is installed
    # /usr/share/perl
    our $DISTDIR = File::ShareDir::dist_dir($NAME);

    our @dirs = ( $HOME, $CONFIG_DIR, $DIST_DIR, $DISTDIR );

    our $CONFIGFILE = get_file( "config.ini", @dirs );
    our $CALENDAR_D = get_file( "calendar.d", @dirs );

    our $cfg;    # = load_config($CONFIGFILE);

    sub get_cfg_val {
        my ( $key, $default_value ) = @_;
        return $cfg->{"_"}{$key}
            || $ENV{ uc("APP_REMINDER_$key") }    #$ENV{ uc("${NAME}_$key") }
            || $default_value;
    }

    sub load_config {

        my ($path) = @_;
        $path //= $CONFIGFILE;

        $logger->info(
            sprintf( "⚙️ reading the configuration:: %s", $path ) );

        my $cfg = Config::Tiny->read($path) || Config::Tiny->new();
        $logger->warn( Config::Tiny->errstr );

        # set default values (if undef)
        $cfg->{_}{from} //= $ENV{EMAIL} || $ENV{USER} || $ENV{LOGNAME};
        $cfg->{_}{to}   //= $ENV{EMAIL} || $ENV{USER} || $ENV{LOGNAME};
        return $cfg;
    }

    sub list_calendar_d {
        my ($dir) = Path::Tiny::path(@_);
        my @ret;
        my $iter = $dir->iterator;
        while ( my $file = $iter->() ) {
            if ( $file->is_dir() ) {
                push @ret, list_calendar_d($file);
                next;
            }
            if ( $file !~ /\.ics$/ ) {

                # exclude non-ICS files
                next;
            }
            push @ret, $file;
        }
        return @ret;
    }

=pod

=over

=item get_file($rel_filepath, @directorys)

=back

=cut

    sub get_file {
        my ( $rel_filepath, @directorys ) = @_;
        if ( !scalar @directorys ) {
            @directorys = ( '.', @dirs );
        }
        for (@directorys) {
            File::Path::make_path($_);
            my $abs_filepath = File::Spec->catfile( $_, $rel_filepath );
            if ( -r $abs_filepath ) {
                $logger->info( sprintf( "📄 found file: %s", $abs_filepath ) );
                return $abs_filepath;
            }
        }
        return File::Spec->catfile( ".", $rel_filepath );
    }

    1;

};
