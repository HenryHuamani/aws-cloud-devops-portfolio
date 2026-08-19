# Changelog – Lab 09 CloudWatch

All notable changes and validation milestones for Lab 09 are documented here.

---

## [1.0.0] – 2026-08-18

### Status

✅ Completed and validated.

### Existing / Reused Infrastructure

Lab 09 reused the NovaCommerce infrastructure built in previous laboratories:

- `portfolio-vpc`
- `portfolio-alb`
- `portfolio-web-tg`
- `portfolio-asg`
- `portfolio-web-template`
- `novacommerce-efs`
- `portfolio-db`
- Existing public/private subnets, route tables, Security Groups, and network controls

The Launch Template predates Lab 09. The console shows an earlier default version, while the Auto Scaling Group evidence confirms that **Launch Template version 5** was used by the ASG during this lab.

### Added in Lab 09

#### CloudWatch Monitoring

- Reviewed native EC2 metrics.
- Reviewed ALB and Target Group metrics.
- Reviewed EFS metrics.
- Reviewed RDS metrics.
- Enabled Auto Scaling Group metric collection.
- Created `portfolio-monitoring-dashboard`.

#### CloudWatch Alarms

- Created `portfolio-ec2-high-cpu`.
- Configured high CPU threshold evaluation.
- Created `portfolio-alb-unhealthy-targets`.
- Configured `HealthyHostCount < 2` evaluation.

#### Amazon SNS

- Created/reused SNS topic `portfolio-cloudwatch-alerts` for alarm notifications.
- Confirmed email subscription.
- Validated email delivery during alarm events.

#### Dynamic Scaling

- Added `portfolio-asg-cpu-target-tracking`.
- Target metric: Average CPU Utilization.
- Target value: `50%`.
- Instance warmup: `300 seconds`.
- Scale in enabled.

### Validated in Lab 09

#### High CPU Alarm

- Generated controlled CPU load.
- Observed CPU utilization increase in CloudWatch.
- Confirmed alarm transition to `ALARM`.
- Confirmed SNS notification delivery.
- Confirmed CPU recovery and alarm return to `OK`.

#### Target Health Alarm / Self-Healing

- Stopped Apache on one EC2 instance as a controlled failure.
- Observed unhealthy target detection.
- Observed `HealthyHostCount` reduction.
- Confirmed CloudWatch alarm and SNS notification.
- Confirmed Auto Scaling replaced the unhealthy EC2 instance.
- Confirmed Target Group recovery.

#### Scale-Out

- Generated sustained CPU load on the baseline EC2 instances.
- Confirmed Target Tracking activation.
- Confirmed desired capacity change from `2` to `4`.
- Confirmed four InService/Healthy EC2 instances.

#### Scale-In

- Removed the synthetic CPU workload.
- Allowed Target Tracking to stabilize without manual desired-capacity changes.
- Confirmed automatic scale-in back to the two-instance baseline.

#### Supporting Service Validation

- Confirmed EFS shared-storage behavior between EC2 instances.
- Confirmed EFS Multi-AZ Mount Targets and monitoring.
- Confirmed RDS remains not publicly accessible.
- Confirmed MySQL `3306` is restricted to the application Security Group.
- Confirmed RDS backup and monitoring configuration.
- Confirmed final application availability through the ALB across multiple Availability Zones.

### Fixed / Improved

- Enabled Auto Scaling Group metrics after the Monitoring view initially showed no data.
- Improved centralized observability with a CloudWatch dashboard.
- Added operational alerting through SNS.
- Added explicit availability monitoring through `HealthyHostCount`.
- Added CPU-based Target Tracking and validated the full scale-out/scale-in lifecycle.

---

## [0.1.0] – Initial State

NovaCommerce infrastructure from previous labs was available and used as the monitored workload for Lab 09.

---

**Current Version:** `1.0.0`  
**Lab Status:** ✅ Completed
