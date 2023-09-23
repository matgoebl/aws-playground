Setup Playground
================

- Create AWS S3 Bucket and DynamoDB for holding the terraform remote state and import them
- Create playground user with limited permissions
- Add a role for Lambdas (as creating IAM ressources is not permitted to the playground user)
- Write credentials to .playground.* files, to be used by playground (when not using remote state)
- Set credentials and variables for GitHub actions

Feel free to override AWS profile and region.
