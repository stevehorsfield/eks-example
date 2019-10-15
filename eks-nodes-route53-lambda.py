from os import environ
import json
import boto3
import re
import uuid
import time
import random
from datetime import datetime

print('Loading function ' + datetime.now().time().isoformat())
route53 = boto3.client('route53')
ec2 = boto3.resource('ec2')
compute = boto3.client('ec2')

vpc_id = environ['TARGET_VPC_ID']
forward_zone_id = environ['FORWARD_ZONE_ID']
forward_domain = environ['FORWARD_DOMAIN']
entry_subdomain = environ['ENTRY_SUBDOMAIN']
entry_ttl = environ['ENTRY_TTL']
selector_tag = environ['SELECTOR_TAG']
selector_value = environ['SELECTOR_VALUE']

def lambda_handler(event, context):
    reservations = compute.describe_instances(
      Filters = [
        {
          'Name': 'tag:' + selector_tag,
          'Values': [ selector_value ]
        },
        {
          'Name': 'vpc-id',
          'Values': [ vpc_id ]
        }
      ])['Reservations']
      
    primary_ip_addresses = []
    for x in reservations:
      for y in x['Instances']:
        primary_ip_addresses.append(y['PrivateIpAddress'])
      
    primary_ip_addresses.sort()
    
    route53.change_resource_record_sets(
            HostedZoneId=forward_zone_id,
            ChangeBatch={
                "Comment": "Updated by Lambda for dynamic DNS registration in VPC " + vpc_id,
                "Changes": [
                    {
                        "Action": "UPSERT",
                        "ResourceRecordSet": {
                            "Name": entry_subdomain + '.' + forward_domain,
                            "Type": 'A',
                            "TTL": int(entry_ttl),
                            "ResourceRecords": list(map(lambda x: {"Value":x}, primary_ip_addresses))
                        }
                    }
                ]
            }
        )  
