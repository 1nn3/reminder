use diagnostics;
use strict;
use utf8;
use warnings;

use ExtUtils::MakeMaker;
use File::ShareDir::Install;

install_share dist => 'dist';

WriteMakefile(
    NAME          => 'App::Reminder',
    VERSION_FROM  => 'lib/App/Reminder.pm',
    AUTHOR        => q{user <user@host>},
    ABSTRACT_FROM => 'pod/reminder.pod',

    #NO_MYMETA => 1,which lasts until the end of that BLOCK.
    MAN1PODS => { 'pod/reminder.pod' => '$(INST_MAN1DIR)/reminder.1p', },
    MAN3PODS => {},

    PM        => { 'lib/App/Reminder.pm' => '$(INST_LIBDIR)/Reminder.pm', },
    EXE_FILES => [ 'bin/reminder', 'bin/reminder-cronjob', ],
    PREREQ_PM => {
        'Config::Tiny'               => undef,
        'DateTime'                   => undef,
        'Data::ICal'                 => undef,
        'DateTime::Format::Strptime' => undef,
        'DateTime::Event::ICal'      => undef,
        'Encode::Guess'              => undef,
        'Encode'                     => undef,
        'File::HomeDir'              => undef,
        'MIME::Lite'                 => undef,    # libmime-lite-perl
        'Path::Tiny'                 => undef,    # libpath-tiny-perl
        'Proc::PID::File'            => undef,    # libproc-pid-file-perl
        'Log::Log4perl'              => undef,    # liblog-log4perl-perl
    }
);

package MY;
use File::ShareDir::Install qw(postamble);
