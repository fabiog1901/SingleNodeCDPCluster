import cm_client
from cm_client.rest import ApiException
from collections import namedtuple
from pprint import pprint
import json

cm_client.configuration.username = 'admin'
cm_client.configuration.password = 'admin'

api_client = cm_client.ApiClient("http://localhost:7180/api/v32")

clusters_api_instance = cm_client.ClustersResourceApi(api_client)
template = clusters_api_instance.export("OneNodeCluster")

json_dict = api_client.sanitize_for_serialization(template)
with open('temp_template.json', 'w') as f:
    json.dump(json_dict, f, indent=4, sort_keys=True)
