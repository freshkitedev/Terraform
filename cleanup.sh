#!/bin/bash

# Get all VPCs
all_vpcs=$(aws ec2 describe-vpcs --query "Vpcs[*].VpcId" --output text)

# Get VPCs with instances
used_vpcs=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].VpcId" --output text | sort | uniq)

# Find unused VPCs
unused_vpcs=$(comm -23 <(echo "$all_vpcs" | sort) <(echo "$used_vpcs" | sort))

# Loop through unused VPCs and delete dependencies
for vpc in $unused_vpcs; do
    echo "Processing VPC: $vpc"

    # Delete subnets
    for subnet in $(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc" --query "Subnets[*].SubnetId" --output text); do
        echo "Deleting subnet: $subnet"
        aws ec2 delete-subnet --subnet-id $subnet
    done

    # Delete route tables (except main)
    for rtb in $(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$vpc" --query "RouteTables[?Associations[?Main==false]].RouteTableId" --output text); do
        echo "Deleting route table: $rtb"
        aws ec2 delete-route-table --route-table-id $rtb
    done

    # Delete NAT gateways
    for nat in $(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$vpc" --query "NatGateways[*].NatGatewayId" --output text); do
        echo "Deleting NAT gateway: $nat"
        aws ec2 delete-nat-gateway --nat-gateway-id $nat
        sleep 10  # Give some time for deletion
    done

    # Delete security groups (except default)
    for sg in $(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$vpc" --query "SecurityGroups[?GroupName!='default'].GroupId" --output text); do
        echo "Deleting security group: $sg"
        aws ec2 delete-security-group --group-id $sg
    done

    # Delete the VPC
    echo "Deleting VPC: $vpc"
    aws ec2 delete-vpc --vpc-id $vpc
done

echo "✅ Cleanup complete!"