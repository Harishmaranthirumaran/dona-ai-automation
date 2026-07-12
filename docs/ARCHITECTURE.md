# Architecture — Dona AI Automation

## Overview

Dona is built on a single-tenant, self-hosted architecture designed for reliability,
cost-efficiency, and full control over data and execution.

## Component Diagram

```
External Triggers
├── Gmail (webhook via Google Pub/Sub)
├── Google Calendar (push notifications)
├── WhatsApp (webhook via Meta Cloud API)
└── Cron scheduler (weekly briefings)
         │
         ▼
    ┌─────────┐
    │  NGINX  │  SSL termination + reverse proxy
    └────┬────┘
         │
    ┌────▼────┐
    │   n8n   │  Workflow orchestration engine
    │ :5678   │  (Docker, persistent state in PostgreSQL)
    └────┬────┘
         │
    ┌────▼────────────────────────────────┐
    │          Decision Layer             │
    │                                     │
    │  Classification Task  →  Claude 3   │
    │  Generation Task      →  GPT-4o     │
    │  Summarisation        →  Claude 3   │
    └────┬────────────────────────────────┘
         │
    ┌────▼────────────────────────────────┐
    │          Action Layer               │
    │                                     │
    │  Gmail API    → send, label, draft  │
    │  Sheets API   → read, write, append │
    │  Calendar API → create, update      │
    │  WhatsApp API → send message        │
    └─────────────────────────────────────┘
         │
    ┌────▼────┐
    │  CloudWatch │  Execution telemetry + alerting
    └─────────────┘
```

## Key Design Decisions

### Self-hosted vs SaaS
Running n8n self-hosted on AWS EC2 instead of using Zapier or Make.com.
At 100-500 executions/day, self-hosted costs ~$15/month vs $100+/month SaaS.

### Dual LLM Routing
Tasks are routed to different models based on cost/capability tradeoff:
- **Claude 3 Haiku** — fast classification, intent detection, email triage
- **GPT-4o** — long-form generation, email drafting, complex summarisation

### Stateless Workflows
Each workflow execution is stateless. Persistent state (job tracking, email
history, preferences) is stored in PostgreSQL and read at execution start.

### Error Handling
Every workflow has:
1. Try/catch blocks around external API calls
2. Exponential backoff retry (3 attempts)
3. Error branch → CloudWatch metric → email alert
4. Execution log stored in PostgreSQL for debugging
