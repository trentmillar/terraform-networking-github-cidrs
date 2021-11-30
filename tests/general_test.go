package tests

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestInitApplyDestroy(t *testing.T) {
	var dir = "."
	var opt = &terraform.Options{TerraformDir: dir}
	defer terraform.Destroy(t, opt)
	_ = terraform.Init(t, opt)
	_ = terraform.Apply(t, opt)
}
