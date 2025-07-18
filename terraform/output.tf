output "jenkins_server_public_ip" {
  description = "Public IP address of the Jenkins server"
  value       = aws_instance.jenkins_server.public_ip
}

output "jenkins_server_public_dns" {
  description = "Public DNS name of the Jenkins server"
  value       = aws_instance.jenkins_server.public_dns
}

output "python_app_server_public_ip" {
  description = "Public IP address of the Python application server"
  value       = aws_instance.python_app_server.public_ip
}

output "python_app_server_public_dns" {
  description = "Public DNS name of the Python application server"
  value       = aws_instance.python_app_server.public_dns
}

output "python_app_url" {
  description = "URL to access the Python Flask application"
  value       = "http://${aws_instance.python_app_server.public_ip}:5000"
}

output "jenkins_url" {
  description = "URL to access the Jenkins web interface"
  value       = "http://${aws_instance.jenkins_server.public_ip}:8080"
}

output "ssh_jenkins_command" {
  description = "SSH command to connect to the Jenkins server"
  value       = "ssh -i ~/.ssh/python-app-key ubuntu@${aws_instance.jenkins_server.public_ip}"
}

output "ssh_python_app_command" {
  description = "SSH command to connect to the Python application server"
  value       = "ssh -i ~/.ssh/python-app-key ubuntu@${aws_instance.python_app_server.public_ip}"
}
