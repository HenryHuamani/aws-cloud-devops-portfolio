# Architecture Decisions – Lab 09

## ADR-01 – Reuse Existing NovaCommerce Infrastructure

**Decision:** Reuse the VPC, ALB, Auto Scaling Group, Launch Template, EFS, and RDS created in previous laboratories.

**Reason:** Lab 09 focuses on CloudWatch monitoring, alarm-driven observability, SNS notifications, and operational validation rather than recreating infrastructure already present in the portfolio.

---

## ADR-02 – Use Native CloudWatch Metrics First

**Decision:** Start with AWS native metrics for EC2, ALB, Auto Scaling, EFS, and RDS.

**Reason:** These metrics are sufficient to validate CPU, requests, target health, response time, capacity behavior, storage activity, and database health without introducing an unnecessary agent for the primary objectives of this lab.

---

## ADR-03 – Alert on High CPU and Loss of Healthy Targets

**Decision:** Create alarms for:

- EC2 CPU utilization `>= 80%`.
- Target Group `HealthyHostCount < 2`.

**Reason:** These represent two different operational risks: resource saturation and reduced application availability.

---

## ADR-04 – Use Amazon SNS for Notifications

**Decision:** Send CloudWatch alarm notifications through `portfolio-cloudwatch-alerts`.

**Reason:** SNS decouples the alarm from the notification endpoint and provides a standard AWS event-notification pattern.

---

## ADR-05 – Use CPU Target Tracking for Elasticity Validation

**Decision:** Configure `portfolio-asg-cpu-target-tracking` with a 50% average CPU target and maximum capacity of 4.

**Reason:** CPU is easy to generate in a controlled lab and provides a clear demonstration of automatic horizontal scale-out and scale-in.

---

## ADR-06 – Do Not Manually Reduce Desired Capacity During Scale-In Test

**Decision:** Allow Target Tracking to perform scale-in automatically.

**Reason:** Manual capacity reduction would invalidate the proof that Auto Scaling reacted to reduced workload demand.

---

## ADR-07 – Treat the Launch Template as Reused Infrastructure

**Decision:** Document `portfolio-web-template` as inherited from the earlier Auto Scaling implementation.

**Reason:** Evidence shows the template/User Data predates Lab 09. The ASG uses Launch Template version 5 during this lab, while an older default version remains visible in the template console.
