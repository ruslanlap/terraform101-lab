PROFILES="sto fra"
REGIONS="eu-north-1 eu-central-1"

for p in $PROFILES; do
  echo "========== PROFILE: $p =========="

  for r in $REGIONS; do
    echo
    echo "----- REGION: $r -----"

    echo "EC2:"
    aws ec2 describe-instances --region $r --profile $p --query 'Reservations[].Instances[].InstanceId'

    echo "EBS:"
    aws ec2 describe-volumes --region $r --profile $p --query 'Volumes[].VolumeId'

    echo "Elastic IP:"
    aws ec2 describe-addresses --region $r --profile $p --query 'Addresses[].PublicIp'

    echo "NAT:"
    aws ec2 describe-nat-gateways --region $r --profile $p --query 'NatGateways[].NatGatewayId'

  done
done