# Terraform Template Gimmicks

This is a small demo, showing how you can make use of "optional" variables in templates, replacing them with default values.

A picture is worth a thousand words:

![variables and outputs](variables_and_outputs.png "variables and outputs")


For even more details see
- this [Hashicorp discussion](https://discuss.hashicorp.com/t/how-to-set-a-default-value-for-a-variable-in-a-terraform-template/12817/13)
- my [blog post](https://silviancretu.ro/)


## The Scenario Is:

- you have to manage multiple environments
- all the environments use the same configuration file, that is a template
- the template contains many variables
- some environments tend to be "snowflakes", as they have non-default values
- should you want to edit the template to add these variables, with non-default values, for these snowflake environments, those variables will have to be added to each of the standard (not snowflake) environments, as well; otherwise `terraform plan` and `terraform apply` will fail on all the environments


## The Structure

```sh
$ tree 
.
├── common-template-file.tftpl
├── environmentA
│   ├── render-template.tf
│   └── variables.tf
├── environmentB
│   ├── render-template.tf
│   └── variables.tf
├── environmentC
│   ├── render-template.tf
│   └── variables.tf
├── environmentD
│   ├── render-template.tf
│   └── variables.tf
├── environmentE
│   ├── render-template.tf
│   └── variables.tf
└── README.md
```

So
- there's a common template for all environment
- each environment has its own directory
- each environment has a bunch of .tf files holding the Terraform code
- in `variables.tf` each environment has its own custom set of variables


## The Template and the Variables

The are two important sections in the template:

### the first one:
```
  thisDependsOnTheValueOfVariable: %{ if enable_this == false }0%{ else }1%{ endif }
```
- `enable_this` is a variable that must exist in all `variables.tf` files
- **environmentE** doesn't have it and you'll see Terraform failing because of that
- depending on its value, another variable is set. 


### the second:
```
thisWorksEvenIfVariableIsMissing:
  VarOne: ${try(optional_vars.var_one, 2)}
  VarTwo: ${try(optional_vars.var_two, "bla")}
  VarThree: ${try(optional_vars.var_three, true)}
```
- `optional_vars` is a section (that can have any other name) that must exist in all `variables.tf` files
- **environmentD** doesn't have it and you'll see Terraform failing because of that
- but any variable nested under `optional_vars` is optional and can be missing


## How to Test and Run

Go to each environment and run `terraform plan` or even `terraform apply`, which will generate a file called `output.txt` for that environment, if the variables are not missing

Example:

```sh
$ cd environmentC/

$ terraform init; terraform apply -auto-approve

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/null...
- Installing hashicorp/null v3.2.1...
- Installed hashicorp/null v3.2.1 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # null_resource.example will be created
  + resource "null_resource" "example" {
      + id       = (known after apply)
      + triggers = {
          + "template" = <<-EOT
                global:
                  hostnames: [C.foo.bar]
                  importantStuff:
                    enableThis: true
                thisWorksIfVariableIsDeclared:
                  thisDependsOnTheValueOfVariable: 1
                thisWorksEvenIfVariableIsMissing:
                  VarOne: C has both var_one
                  VarTwo: bla
                  VarThree: ... and var_three
            EOT
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
null_resource.example: Creating...
null_resource.example: Provisioning with 'local-exec'...
null_resource.example (local-exec): Executing: ["/bin/sh" "-c" "cat <<\"EOF\" > \"output.txt\"\nglobal:\n  hostnames: [C.foo.bar]\n  importantStuff:\n    enableThis: true\nthisWorksIfVariableIsDeclared:\n  thisDependsOnTheValueOfVariable: 1\nthisWorksEvenIfVariableIsMissing:\n  VarOne: C has both var_one\n  VarTwo: bla\n  VarThree: ... and var_three\n\nEOF"]
null_resource.example: Creation complete after 0s [id=8194581208246512262]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

$ cat output.txt 
global:
  hostnames: [C.foo.bar]
  importantStuff:
    enableThis: true
thisWorksIfVariableIsDeclared:
  thisDependsOnTheValueOfVariable: 1
thisWorksEvenIfVariableIsMissing:
  VarOne: C has both var_one
  VarTwo: bla
  VarThree: ... and var_three
```
