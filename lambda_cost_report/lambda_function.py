import boto3
import os, datetime, json
from botocore.vendored import requests

def lambda_handler(event, context):
    
    now = datetime.datetime.utcnow()
    start = (now - datetime.timedelta(days=int(os.environ['days']))).strftime('%Y-%m-%d')
    end = now.strftime('%Y-%m-%d')
    
    cd = boto3.client('ce', 'us-east-1')
    
    results = []
    
    token = None
    while True:
        if token:
            kwargs = {'NextPageToken': token}
        else:
            kwargs = {}
        data = cd.get_cost_and_usage(TimePeriod={'Start': start, 'End':  end}, Granularity='DAILY', Metrics=['UnblendedCost'], GroupBy=[{'Type': 'DIMENSION', 'Key': 'LINKED_ACCOUNT'}, {'Type': 'DIMENSION', 'Key': 'SERVICE'}], **kwargs)
        results += data['ResultsByTime']
        token = data.get('NextPageToken')
        if not token:
            break
    
    # print('  |  '.join(['TimePeriod', 'LinkedAccount', 'Service', 'Amount', 'Unit', 'Estimated']))
    for result_by_time in results:
        for group in result_by_time['Groups']:
            amount = group['Metrics']['UnblendedCost']['Amount']
            unit = group['Metrics']['UnblendedCost']['Unit']
            
            accountID = group['Keys'][0]
            serviceName = group['Keys'][1]
            
            green = '#5fc92e'
            red = '#ff3700'
            
            if float(amount) <= float(os.environ['amount_limit']):
                message_color = green
            else:
                message_color = red
            
            # payload = {
            #     "attachments": [ {
            #         "color": "#2eb886",
            #         "text": "today was free!"
            #     } ],
            #     "color": "#2eb886",
            #     "mkrdwn": True,
            #     "username": "AWS Cost Reporter",
            #     "text": 'Date: `' + result_by_time['TimePeriod']['Start'] +  '`\nAccountID  and service: `' + '` `'.join(group['Keys']) + '`\nAccount Alias: ' + os.environ['alias'] + '\n*Amount*: `' + amount + '`\nUnit: `' + unit + '`'
            # }
            payload = {
                "attachments": [
                    {
                        "fallback": "AWS cost reporter news",
                        "text": "AWS cost reporter",
                        "fields": [
                            {
                                "title": "Billed day",
                                "value": result_by_time['TimePeriod']['Start'],
                                "short": True
                            },
                            {
                                "title": os.environ['alias'],
                                "value": accountID,
                                "short": True
                            },
                            {
                                "title": serviceName,
                                "value": str(unit + ' ' + amount),
                                "short": True
                            }
                        ],
                        "color": message_color
                    }
                ]
            }
            
            # print(str(payload))
            print(json.dumps(payload))
            # print( accountID + ' | ' + serviceName )
            # print(str(unit + ' ' + amount))
        
            headers = {
                'Content-type': 'application/json',
            }
            
            response = requests.post(os.environ['hook'], headers=headers, data=json.dumps(payload))
            # print(result_by_time['TimePeriod']['Start'], '  |  ', '  |  '.join(group['Keys']), '  |  ', amount, '  |  ', unit, '  |  ', result_by_time['Estimated'])
            
    
