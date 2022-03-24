# Plum Recipes API

## Purpose

The purpose of this service is to provide an example of how a Spring Boot application can be
set up in HMCTS, so that it can be processed by the pipeline and get deployed to CNP.

## What's inside

The project contains a Spring Boot app that exposes two endpoints ([/src](/src)) and infrastructure
definition ([/infrastructure](/infrastructure)).

## Building and deploying the application

### Building the application

The project uses [Gradle](https://gradle.org) as a build tool. It already contains
`./gradlew` wrapper script, so there's no need to install gradle.

To build the project execute the following command:

```bash
  ./gradlew build
```

### Running the application

See `docker-compose.yml` and set the required environment variables.  They are currently unset.

Create and run docker image:

```bash
  docker-compose up --build
```

This will start the API container exposing the application on host port 9080

In order to test if the application is up, you can call its health endpoint:

```bash
  curl http://localhost:9080/health
```

You should get a response similar to this:

```
  {"status":"UP","diskSpace":{"status":"UP","total":249644974080,"free":137188298752,"threshold":10485760}}
```

## API

The Plum Recipes service has an API (in Azure API Management Service) set up in Terraform. The API serves as
a proxy that lets authenticated requests reach specific endpoints of the service (in this case, the "Find all
your recipes" (/recipes) endpoint). A request, in order to be let through, must meet the following requirements:

- has the `Ocp-Apim-Subscription-Key` header set with a valid subscription key
- is an HTTPS request with one of the allowed client certificates

The API (and its corresponding product) is defined in an Azure Resource Manager template
([infrastructure/template/api.json](infrastructure/template/api.json)).

### Calling the API

#### Generate RSA keys and issue a client certificate

In order to call the API, you need to use a private key and a certificate. Here's how to generate them:

Make sure you have openssl installed, e.g.:

```
brew install openssl
```

Generate a private key:

```
openssl genrsa 2048 > private.pem
```

Generate your client certificate:

```
openssl req -x509 -new -key private.pem -out cert.pem
```

#### <a name="certificate-thumbprint" />Make sure your certificate thumbprint is known to the API

For your requests to be accepted, the API needs to know the thumbprint of the certificate you're going to use.
Here's how you can generate it:

```
openssl x509 -noout -fingerprint -inform pem -in cert.pem | sed -e s/://g
```

Now, add the output value to `local.allowed_certificate_thumbprints` list in [main.tf](infrastructure/main.tf).
It should look similar to this:

```
  locals {
    ...
    
    allowed_certificate_thumbprints = [
      "${var.api_gateway_test_certificate_thumbprint}",
      "8D81D05C0154423AE548D709CDDF9549E826C036" # thumbprint of your new certificate
    ]
    
    ...
  }
```

As certificate thumbprints are no secret information, you typically won't need to store them in Azure Key Vault.

The API will pick up these changes once you've redeployed it, by running the pipeline.

#### <a name="get-subscription-key" />Get a subscription key

You can get your subscription key using Azure Portal. In order to do this, perform the following steps:
- Search for the right API Management service instance (`core-api-mgmt-{environment}`) and navigate to its page
- From the API Management service page, navigate to Developer portal (`Developer portal` link at the top bar)
- In developer portal navigate to `Products` tab and click on `rhubarb-recipes`
- Click on one of the subscriptions from the list (at least `rhubarb-recipes (default)` should be present).
- Click on the `Show` link next to the Primary Key of one of the rhubarb-recipes subscriptions. This will
reveal the key. You will need to provide this value in your request to the API.


#### Send the request

In the directory containing your `private.pem` and `cert.pem` files run the following command:

```
curl -v --key private.pem --cert cert.pem https://core-api-mgmt-{environment}.azure-api.net/plum-recipes-api/recipes -H "Ocp-Apim-Subscription-Key:{subscription key}"
```

You should receive an HTTP response with status 200 and a JSON body containing a list of recipes, e.g.:

```
{"recipes":[]}
```

If you see a response like this, it means that you've successfully sent your request to Rhubarb Recipe Backend
through the API.

### Setting up API (gateway) tests

In order to be able to test the API gateway, tests must know:

 - a certificate recognised by the API (and the corresponding private key)
 - a valid subscription key

These two pieces of information need to be provided in every environment where API tests are run.
Jenkins job reads those secrets from Azure Key Vault and sets them as environment
variables, which can then be accessed by tests (see [Jenkinsfile_CNP](Jenkinsfile_CNP)
and [Jenkinsfile_parameterized](Jenkinsfile_parameterized)). Here's how to set up test
data:

**Test client key store and password**

Generate client private key, a certificate for that key and import both into a key store:

```
# generate private key
openssl genrsa 2048 > private.pem

# generate certificate
openssl req -x509 -new -key private.pem -out cert.pem

# create the key store
# when asked for password, provide one
openssl pkcs12 -export -in cert.pem -inkey private.pem -out cert.pfx -noiter -nomaciter
```

Now, store the content of the key store as a Base64-encoded secret in Azure Key Vault:

```
base64 cert.pfx | perl -pe 'chomp if eof' | xargs az keyvault secret set --vault-name rhubarb-{environment} --name test-client-key-store --value $1
```

and also the password for that key store:

```
az keyvault secret set --vault-name rhubarb-{environment} --name test-client-key-store-password --value {the password you've set}
```

For the test certificate to be recognised by the API, set `api_gateway_test_certificate_thumbprint` input variable
with the thumbprint of the certificate for the right environment (in {environment}.tfvars file). In order
to calculate the thumbprint, run the command from [here](#certificate-thumbprint).

**Test client subscription key**

See the steps listed [here](#get-subscription-key) in order to get a subscription key. Once you've
retrieved one, save it in Azure Key Vault:

```
az keyvault secret set --vault-name rhubarb-{environment} --name test-client-subscription-key --value {the subscription key}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

