# Vendr .NET Templates

This repository contains a number of templates for extending Vendr, the eCommerce solution for Umbraco 

The templates can be used via the `dotnet new` command.

## Pre-requisite
You must be using Visual Studio 2019 to work with these templates.


## Installation 
You can install all the templates from a NuGet package:

```
dotnet new -i Vendr.Templates
```

### Updating
To check for any updates you can run the `dotnet new --update-check` command. 

The `dotnet new --update-apply` command will update any of the installed template packages you have installed.

## Usage
All Vendr templates are prefixed `vendr-`. To see what Vendr related templates you have installed: 

```
dotnet new vendr -l
```

## Example: To start a new payment provider project

Supply the name of the payment gateway on the command line, this will setup the namespaces and folders within the project:

```
dotnet new vendr-payment-provider -n Braintree
```