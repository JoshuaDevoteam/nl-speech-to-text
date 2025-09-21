package tests

import (
        "strings"
        "testing"
		"os/exec"
		"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestCreateBucketGCS(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "test_storage",
		VarFiles: []string{"terraform.tfvars"},
	})

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	bucket_url := terraform.Output(t, terraformOptions, "bucket_url")

	// Check is bucket url is in list of buckets.
	cmd := exec.Command("gcloud", "alpha", "storage", "ls")
	out, err := cmd.CombinedOutput()

	if err != nil {
			t.Fatalf("exec.Command: %v", err)
	}
	if got := string(out); !strings.Contains(got, bucket_url) {
			t.Errorf("List of topics in the project includes %q, want to contain %q", got, bucket_url)
	}

}
