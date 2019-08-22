# Mount EBS
# Source: https://github.com/hashicorp/terraform/issues/2740#issuecomment-375144680
EC2_INSTANCE_ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id || die \"wget instance-id has failed: $?\")
EC2_AVAIL_ZONE=$(wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone || die \"wget availability-zone has failed: $?\")
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"

#############
# EBS VOLUME
#
# note: /dev/sdh => /dev/xvdh
# see: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html
#############

# wait for EBS volume to attach
DATA_STATE="unknown"
until [ $DATA_STATE == "attached" ]; do
	DATA_STATE=$(aws ec2 describe-volumes \
	    --region $${EC2_REGION} \
	    --filters \
	        Name=attachment.instance-id,Values=$${EC2_INSTANCE_ID} \
	        Name=attachment.device,Values=/dev/sdh \
	    --query Volumes[].Attachments[].State \
	    --output text)
	echo 'waiting for volume...'
	sleep 5
done

sudo file -s /dev/nvme1n1
sudo mkdir /opt/data
sudo mount /dev/nvme1n1 /opt/data
echo 'EBS volume attached!'
