import logging, json

import azure.functions as func
from azure.identity import ManagedIdentityCredential
from azure.keyvault.secrets import SecretClient

def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    name = req.params.get('name')
    if not name:
        try:
            req_body = req.get_json()
        except ValueError:
            pass
        else:
            name = req_body.get('name')

    if name:
        KEY_VAULT_URL = f"https://{name}.vault.azure.net/"

        credential = ManagedIdentityCredential()


        secret_client = SecretClient(vault_url=KEY_VAULT_URL, credential=credential)

        try:
            secret = secret_client.get_secret("VaronisAssignmentSecret")
        except:
            return func.HttpResponse(
                status_code=400
            )
        else: 
            return func.HttpResponse(
                json.dumps({ 
                    "vault_name" : name, 
                    "secret_name" : secret.name,
                    "created_date" : secret.properties.created_on,
                    "secret_value" : secret.value
                }, default=str),
                status_code=200
            )
        finally:
            secret_client.close
    else:
        return func.HttpResponse(
             "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response.",
             status_code=200
        )