# Reminder ⏰ aka. Ritual - A reminder/calendar using the iCalendar standard
Topics: reminder calendar

**THIS SOFTWARE WAS CREATED WITH AI**

## Setup

    apt install devscripts
    git clone https://github.com/1nn3/reminder
    cd reminder
    mk-build-deps --install
    debuild
    debi

After installation you have to run *reminder* every minute manually (e.g. as a cronjob):

    */1 * * * * reminder-cronjob

## Testing

    apt install faketime
    faketime 'YYYY-MM-DD HH:MM:SS' reminder

## LICENSE AND COPYRIGHT

Reminder is free software. See COPYING and
http://www.gnu.org/licenses/gpl.html for more information.

