#
# Regular cron jobs for the reminder package
#

# maintenance
0 4	* * *	root	[ -x /usr/bin/reminder_maintenance ] && /usr/bin/reminder_maintenance

