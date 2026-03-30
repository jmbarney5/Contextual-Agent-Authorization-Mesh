
SPIFFE/SPIRE
October/2023

Nested model
WG – Assertions and Extensible Tokens

Agenda

Metrics and Objectives
Tools
Samples and Test Environment
ID-mode and Anonymous mode
Introduction
Metrics:
 Data payload
 Runtime
 Resources (CPU / Memory)

Objective
In a broad point-of-view:
 Identify and capture data related to the performance and overhead of the nested token
 Characterize a behaviour baseline based on experiments with a batch of sequential requests
 Estimate the effects of the token extension through the middle-tiers

Metrics
Data Payload:
  Assertions Size (Delta / Tiers)
  Certificates Size (SVIDs) 
Signature Size (Schnorr / ECDSA)

Metrics
Runtime:
 Token mint and nesting time
 Token validation

Metrics
Resources:
 CPU consumption in percentage 
 Memory consumption in MB

Prometheus + PoC


Open-source monitoring tool
GoLang Client
50ms scrapes

PoC:
Metrics collection instrument integrated on the PoC code
Directly measuring the requests on the APIs
Apache JMeter + Rstudio


Open-source tool for load test functional behavior and measure performance on web apps
Sequential requests (one every 6 seconds)
Easy way to test stress load on the app


IDE for processing the collected data using R
Test Environment

Ubuntu Server - 06
Ubuntu 20.04
Processor: Intel(R) Core(TM) i7-4770 CPU @ 3.40GHz - 8 cores
RAM memory: 32 GB
Each container with 1vCPU and 128MB of RAM memory
Ubuntu Server - 04
Processor: Intel(R) Xeon(R) CPU E5-2620 @ 2.00GHz - 24 cores
RAM memory: 192 GB
Test Environment

Tests

Proof of concept
Automated requests with JMeter
The test was conducted with:
Both PoC models with 5 middle-tiers
100 requests warm-up for cache prior to the tests
100 requests in a 10 minute period (batch of 10 tests with 10 requests - 1 every 6 seconds)
Information captured every 50ms through Prometheus API
Results - Payload - Both machines

Assertion Growth (Bytes)






ID-Mode - SVIDs Certificates Size (Bytes)



Payload
Intel i7-4770
Results

Payload
Xeon E5-2620
Results

ID-Mode token mint
Intel i7-4770
Results - Runtime

ID-Mode token mint
Xeon E5-2620
Results - Runtime

Results - Runtime
ID-Mode token validation
Intel i7-4770

+236





+262
+225
+209
+218
+279

Results - Runtime
ID-Mode token validation
Xeon E5-2620

+357





+358
+415
+317
+408
+345

Results - Runtime
Anon-Mode token mint
Intel i7-4770

Results - Runtime
Anon-Mode token mint
Xeon E5-2620

Results - Runtime
Anon-Mode token validation
Intel i7-4770
The validation scheme of anonymous-mode using galindo-garcia had a mean value of 2.842 milliseconds with a standard deviation of 624.57 µs.

Results - Runtime
Anon-Mode token validation
Xeon E5-2620
The validation scheme of anonymous-mode using galindo-garcia had a mean value of 4.616 milliseconds with a standard deviation of 1.01 ms.

ID Mode - CPU
(idle)
Intel i7-4770
Results

ID Mode - CPU
(under load)
Intel i7-4770
Results

ID Mode - CPU
(idle)
Intel Xeon E5-2620
Results

ID Mode - CPU
(under load)
Intel Xeon E5-2620
Results

    ID Mode -Memory
(idle)
Intel i7-4770
Results

ID Mode -Memory
(under load)
Intel i7-4770
Results

    ID Mode -Memory
(idle)
  Intel Xeon E5-2620
Results

ID Mode -Memory
(under load)
Intel Xeon E5-2620
Results

Anon Mode - CPU
(idle)
Intel i7-4770
Results

Anon Mode - CPU
(under load)
Intel i7-4770
Results

Anon Mode - CPU
(idle)
Intel Xeon E5-2620
Results

Anon Mode - CPU
(under load)
Intel Xeon E5-2620
Results

Anon Mode -Memory
(idle)
Intel i7-4770
Results

Anon Mode -Memory
(under load)
Intel i7-4770
Results

Anon Mode -Memory
(idle)
Intel Xeon E5-2620
Results

Anon Mode -Memory
(under load)
Intel Xeon E5-2620
Results
Future work

Provide a branch for the instrumentation of the PoC on our project repository.
The development of the PoC using the LSVID and instrumenting the new model with Prometheus.
Thanks!