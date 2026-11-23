output "certificate_arn" {
  description = "ARN of the validated certificate. Sourced from the validation resource so consumers wait for issuance"
  value       = aws_acm_certificate_validation.app.certificate_arn
}