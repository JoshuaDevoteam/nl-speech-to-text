package tests

import (
        "strings"
        "testing"
		"os/exec"
		"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTriggerCloudFunction(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "test_trigger_cloud_function",
		VarFiles: []string{"terraform.tfvars"},
	})

	// Clean up resources with "terraform destroy" at the end of the test.
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	cloud_function_full := terraform.Output(t, terraformOptions, "cloud_function")
	cloud_function_list := strings.Split(cloud_function_full, "/")
	region, cloud_function_name := cloud_function_list[3], cloud_function_list[5]

	// Check is bucket url is in list of buckets.
	cmd := exec.Command("gcloud", "functions", "describe", cloud_function_name, "--region", region)
	out, _ := cmd.CombinedOutput()
	got := string(out)

	wants := []string{
		"name: " + cloud_function_full,
		// "eventType: " + cloud_function_event_type,
		// "url: " + cloud_function_source_repository_url,
		// "resource: " + bucket_name,
	}

	for _, want := range wants {
		if !strings.Contains(got, want) {
				t.Errorf("HelloGCS = %q, want to contain %q", got, want)
		}
	}
}
