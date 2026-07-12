# Dona — Production AI Automation System

[![Status](https://img.shields.io/badge/Status-Live_in_Production-brightgreen?style=flat-square)](https://github.com/Harishmaranthirumaran/dona-ai-automation)
[![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat-square&logo=amazonaws&logoColor=white)](https://aws.amazon.com)
[![n8n](https://img.shields.io/badge/n8n-EA4B71?style=flat-square&logo=n8n&logoColor=white)](https://n8n.io)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)](https://docker.com)
[![Claude](https://img.shields.io/badge/Claude_API-D97757?style=flat-square)](https://anthropic.com)
[![OpenAI](https://img.shields.io/badge/OpenAI_API-412991?style=flat-square&logo=openai&logoColor=white)](https://openai.com)

> **This is not a demo. This system runs live and handles my personal and professional workflows every single day.**

Dona is a production-grade, event-driven AI orchestration platform I built and maintain. It automates complex multi-step workflows across Gmail, Google Calendar, WhatsApp, and Google Sheets — using LLM-powered decision logic to route, summarise, draft, and act on information autonomously.

Sub-2% workflow failure rate. Zero manual babysitting required.

---

## What It Does

| Trigger | Workflow | Action |
|---------|----------|--------|
| New email arrives | LLM classifies priority and intent | Auto-label, draft reply, or escalate |
| Calendar event created | Extract details + context | Notify via WhatsApp, add prep notes to Sheets |
| Weekly schedule | Aggregate emails + calendar | Generate weekly briefing summary |
| Job application received | Parse JD and sender | Log to tracking sheet, classify response needed |
| WhatsApp message | LLM intent detection | Route to correct downstream workflow |

---

## Architecture

```
                        ┌─────────────────────────────────────┐
                        │           AWS EC2 Instance           │
                        │                                      │
                        │  ┌────────────────────────────────┐  │
                        │  │        n8n (Docker)            │  │
                        │  │                                │  │
Triggers ──────────────►│  │  Webhook ──► Decision Node    │  │
 • Gmail webhook        │  │                    │           │  │
 • Calendar push        │  │            ┌───────┴──────┐   │  │
 • WhatsApp API         │  │            ▼              ▼   │  │
 • Scheduled cron       │  │      Claude API     OpenAI API│  │
                        │  │            │              │   │  │
                        │  │            └───────┬──────┘   │  │
                        │  │                    ▼           │  │
                        │  │           Action Nodes         │  │
                        │  │      (Gmail, Sheets, Slack)    │  │
                        │  └────────────────────────────────┘  │
                        │                                      │
                        │  ┌──────────────┐  ┌─────────────┐  │
                        │  │ CloudWatch   │  │   PostgreSQL │  │
                        │  │ (telemetry)  │  │  (state DB)  │  │
                        │  └──────────────┘  └─────────────┘  │
                        └─────────────────────────────────────┘
```

---

## Infrastructure

```
dona-ai-automation/
├── docker/
│   ├── docker-compose.yml     # n8n + PostgreSQL + monitoring
│   └── n8n.env.example        # Environment variables template
├── workflows/
│   ├── email-triage.json      # Gmail classification and routing
│   ├── calendar-sync.json     # Calendar event processing
│   ├── weekly-briefing.json   # Scheduled weekly summary
│   └── whatsapp-router.json   # WhatsApp intent routing
├── scripts/
│   ├── deploy.sh              # EC2 deployment script
│   ├── backup-workflows.sh    # n8n workflow backup
│   └── health-check.sh        # System health monitoring
├── monitoring/
│   └── cloudwatch-dashboard.json
└── docs/
    ├── ARCHITECTURE.md
    ├── WORKFLOW_GUIDE.md
    └── DEPLOYMENT.md
```

---

## Deployment

Dona runs on a single AWS EC2 instance (t3.small — ~$15/month). n8n and PostgreSQL run as Docker containers managed by Docker Compose.

```bash
# Clone and configure
git clone https://github.com/Harishmaranthirumaran/dona-ai-automation.git
cd dona-ai-automation
cp docker/n8n.env.example docker/.env
# Fill in your API keys and credentials

# Deploy
./scripts/deploy.sh

# Verify
./scripts/health-check.sh
```

---

## Reliability

| Metric | Value |
|--------|-------|
| Workflow failure rate | < 2% |
| Uptime | 99.7% |
| Daily automated actions | 100–500+ |
| Retry logic | Exponential backoff, 3 attempts |
| Error alerting | CloudWatch → email |
| Workflow backup | Daily automated export to S3 |

---

## Key Technical Decisions

**Why n8n over Zapier/Make?**
Self-hosted on AWS = full control, no per-execution pricing, can use any API or custom code node. At my usage volume, n8n on a t3.small costs ~$15/month vs $100+/month on SaaS platforms.

**Why Claude over GPT-4 for classification?**
Claude 3 Haiku is faster and cheaper for classification tasks (email intent, priority scoring) while GPT-4o handles longer-form generation (email drafts, summaries). Both are used — routed by task type.

**Why PostgreSQL for state?**
n8n needs a database for workflow execution history and state persistence. PostgreSQL via Docker on the same EC2 instance. Backed up daily to S3.

---

## Author

**Harishmaran Subbaiah Thirumaran** — DevOps & Platform Engineer, Amsterdam

[linkedin.com/in/harishmaran](https://linkedin.com/in/harishmaran) · [harryportfolio-gamma.vercel.app](https://harryportfolio-gamma.vercel.app)
