package tests

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestCreateServiceAccountIAMBinding(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "test_create_service_account_iam_binding/",
		// Specifiy variables with terraform.tfvars file located in TerraformDir.
		VarFiles: []string{"terraform.tfvars"},
	})

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions);

	//TODO: Add more checks
}
