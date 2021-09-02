aws ec2 import-key-pair --key-name "ackoudguru-key" --public-key-material fileb://~/AWS/Demo/acloudguru.ssh.pub
aws cloudformation create-stack --stack-name myrdsoraclestack --template-body file://~/AWS/Demo/acloudguru-oracle.yaml --capabilities CAPABILITY_NAMED_IAM --parameters ParameterKey=S3BucketName,ParameterValue='myrds-acg'-`date +%Y%m%d%H%M%S`
#aws cloudformation list-stack-resources --stack-name myrdsoraclestack
#aws cloudformation update-stack --stack-name myrdsoraclestack --template-body file://~/AWS/Demo/acloudguru-oracle.yaml --capabilities CAPABILITY_NAMED_IAM
#aws cloudformation delete-stack --stack-name myrdsoraclestack
aws cloudformation wait stack-create-complete --stack-name myrdsoraclestack
aws cloudformation describe-stacks --stack-name myrdsoraclestack
