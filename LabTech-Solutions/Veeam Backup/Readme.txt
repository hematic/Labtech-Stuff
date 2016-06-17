	1. Create a Veeam group under Backup Management
	2. Use Search Backup - Veeam. This will join the replication servers
	3. Use Remote monitors: 
		a. Veeam Backup and Replication Service
		b. Veeam VM Backup Job Completed
		c. Veeam VM Backup Job Failed or Stopped
		d. Veeam VM Backup Job Started
		
	4. Scripts: These scripts must be loaded to gather Veeam eventlogs
		a. Veeam no backup jobs

Veeam Backup Registry Setup(called by script A)