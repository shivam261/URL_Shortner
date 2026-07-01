# Scalable URL Shortener

A high-performance, highly available URL shortener built on AWS. This project is designed to handle high traffic loads with low latency redirection, while asynchronously processing click analytics to ensure the core application remains responsive.

## 🏗️ Architecture

This application leverages a modern, event-driven AWS architecture to ensure scalability and reliability.

* **Amazon Route 53:** DNS routing and domain management.
* **Amazon CloudFront:** Global Content Delivery Network (CDN) to cache redirections at edge locations, drastically reducing latency for end users.
* **Amazon ECS (Elastic Container Service):** Hosts the core containerized backend application responsible for generating short URLs and handling cache misses.
* **Redis (Amazon ElastiCache):** In-memory data store used to cache frequently accessed short URLs, minimizing read loads on the primary database.
* **Amazon SQS (Simple Queue Service):** Asynchronous message queue that captures click events (e.g., timestamp, IP, user agent) without blocking the redirect flow.
* **AWS Lambda:** Serverless compute that consumes messages from the SQS queue, processes the raw click data, and formats it for storage.
* **Amazon S3:** Durable, cost-effective object storage where the Lambda function persists the processed click analytics and event logs for future querying (e.g., via Athena).

## 🚀 Flow of Execution
###  Diagrams
1. Component / Architecture Diagram
```
flowchart LR
    Client([Client])
    
    subgraph AWS Cloud
        R53[Route 53]
        CF[CloudFront]
        API[API Gateway]
        ALB[Application Load Balancer]
        
        subgraph ECS Cluster
            ECS[ECS Target Group]
        end
        
        SQS[SQS Queue]
        Lambda[AWS Lambda]
        S3[(S3 Bucket)]
    end

    Client -->|DNS Query| R53
    Client -->|HTTP/S Request| CF
    CF -->|Static Content / Cache Miss| API
    API -->|Route Request| ALB
    ALB -->|Distribute Traffic| ECS
    
    ECS -->|Redirect Response| Client
    ECS -->|Async Click Stream| SQS
    SQS -->|Trigger Event| Lambda
    Lambda -->|Store Analytics| S3

    classDef aws fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#232F3E;
    class R53,CF,API,ALB,ECS,SQS,Lambda,S3 aws;
```
2. Sequence Diagram

```
sequenceDiagram
    actor User
    participant R53 as Route 53
    participant CF as CloudFront
    participant API as API Gateway
    participant ALB as Application Load Balancer
    participant ECS as ECS (App)
    participant SQS as SQS
    participant LMD as Lambda
    participant S3 as S3 Bucket

    User->>R53: 1. Resolve DNS (short.url)
    R53-->>User: 2. Return IP
    User->>CF: 3. Request URL (GET /xyz)
    
    alt is Static Content or Edge Cached
        CF-->>User: 4a. Return Content / Redirect
    else is API / Dynamic Routing
        CF->>API: 4b. Forward Request
        API->>ALB: 5. Route to Load Balancer
        ALB->>ECS: 6. Forward to Target Group
        
        Note over ECS: Lookup Long URL & Create Click Event
        
        ECS-->>User: 7. HTTP 302 Redirect to Long URL
        
        par Async Background Process
            ECS-)SQS: 8. Send Click Stream Event
            SQS-)LMD: 9. Trigger Lambda Execution
            LMD->>S3: 10. Store Event Data
        end
    end
```
3. Activity Diagram
```
stateDiagram-v2
    [*] --> DNS_Resolution
    DNS_Resolution --> CloudFront_Request
    
    state CloudFront_Request {
        [*] --> Check_Cache
        Check_Cache --> Serve_Static_Content: Cache Hit
        Check_Cache --> Forward_to_API_Gateway: Cache Miss / API Route
    }
    
    Serve_Static_Content --> [*]
    
    Forward_to_API_Gateway --> ALB_Routing
    ALB_Routing --> ECS_Processing
    
    state ECS_Processing {
        [*] --> Fetch_Long_URL
        Fetch_Long_URL --> Fork_Process
        
        state Fork_Process <<fork>>
        Fork_Process --> Return_Redirect
        Fork_Process --> Publish_Click_Event
        
        Return_Redirect --> Join_Process
        Publish_Click_Event --> Join_Process
        state Join_Process <<join>>
    }
    
    Publish_Click_Event --> SQS_Queue
    SQS_Queue --> Lambda_Execution
    Lambda_Execution --> S3_Storage
    
    Return_Redirect --> [*]
    S3_Storage --> [*]
```
### 1. URL Creation
1. Client sends a request to shorten a long URL.
2. The request reaches the **ECS** backend.
3. The system generates a unique hash/alias and stores the mapping in the primary database and **Redis** cache.

### 2. URL Redirection & Analytics
1. A user clicks the short link. **Route 53** resolves the domain to **CloudFront**.
2. If the URL is cached at the edge, CloudFront immediately redirects the user. 
3. If not, the request hits the **ECS** backend.
4. ECS checks **Redis** for the mapping. If found, it returns the long URL. 
5. Before returning the HTTP 301/302 response, the ECS service fires an asynchronous message containing the click data to **SQS**.
6. **Lambda** polls the SQS queue, processes the event, and stores the analytics record in **S3**.

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed:
* [Docker](https://www.docker.com/) (for local container testing)
* [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate IAM permissions
* [Redis CLI](https://redis.io/topics/rediscli) (for local cache testing)
* *(Optional)* Terraform or AWS CDK for infrastructure provisioning

## ⚙️ Local Development Setup

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/yourusername/url-shortener.git](https://github.com/yourusername/url-shortener.git)
   cd url-shortener