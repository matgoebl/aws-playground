Setup Playground
================

- Create playground user with limited permissions
- Add a role for Lambdas (as creating IAM ressources is not permitted to the playground user)
- Write credentials to .playground.* files, to be used by playground (when not using remote state)

Feel free to override AWS profile and region in variables.
