
# Get DB instances
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceArn,DBInstanceIdentifier,DBInstanceClass,DBInstanceStatus,Endpoint]'


# Start DB instance orcl
aws rds start-db-instance --db-instance-identifier orcl

# Stop DB instance orcl
aws rds stop-db-instance --db-instance-identifier orcl