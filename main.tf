### Nicolas Panozo Castellon - Cloudwatch Metrics Certificación 3
/*
### Creamos un topico SNS con el nombre "my-sns-topic"
resource "aws_sns_topic" "sns_topic" {
  name = "my-sns-topic"
}

### Creamos la suscripción para el email "nicopanozoc@gmail.com"
resource "aws_sns_topic_subscription" "sns_topic_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = "nicopanozoc@gmail.com"
}
*/

### Creamos la instancia EC2 especificando datos como AMI, instance type, and subnet ID
resource "aws_instance" "example" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t3.large"
  subnet_id     = "subnet-06200033affd5e04f"
  tags = {
    Name = "ec2-cloudwatch"
  }
}

# Creamos la alarma para monitorear la "CPU utilization" de la instancia EC2
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "ec2-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "70"
  actions_enabled     = true

  # Indicamos las dimensiones de la CloudWatch metric que será monitorizada
  dimensions = {
    InstanceId = aws_instance.example.id
  }

  alarm_description = "This metric monitors EC2 CPU utilization"
}

#creamos un panel enviando los datos como un objeto json
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "my-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              "i-0f23e30ac308147f8"
            ]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "EC2 Instance CPU"
        }
      },
      {
        type   = "text"
        x      = 0
        y      = 7
        width  = 3
        height = 3

        properties = {
          markdown = "Hello world"
        }
      }
    ]
  })
}
/*En el código no se crea explícitamente una métrica de CloudWatch, 
ya que Terraform no requiere la creación de métricas de forma independiente,
 sino que las crea automáticamente cuando se configura una alarma.
Por lo tanto, al crear el recurso de alarma, Terraform automáticamente crea la métrica correspondiente en CloudWatch.*/