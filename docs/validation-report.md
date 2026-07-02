---
prd_source_hash: ""
validation_status: pass
blocker_count: 0
warning_count: 1
info_count: 1
schema_version: 1
generated_at: "2026-07-02T19:28:55Z"
rules:
  - name: "route-vs-screen"
    severity: "BLOCKER"
    status: "pass"
    failures:
  - name: "api-vs-state"
    severity: "BLOCKER"
    status: "pass"
    failures:
  - name: "entity-vs-schema"
    severity: "BLOCKER"
    status: "pass"
    failures:
  - name: "business-rule-vs-validation"
    severity: "WARNING"
    status: "fail"
    failures:
      - item: "business_rule=BR-001"
        reason: "Business rule 'BR-001' has no related Zod schema/validation in doc08"
      - item: "business_rule=BR-002"
        reason: "Business rule 'BR-002' has no related Zod schema/validation in doc08"
      - item: "business_rule=BR-008"
        reason: "Business rule 'BR-008' has no related Zod schema/validation in doc08"
      - item: "business_rule=BR-011"
        reason: "Business rule 'BR-011' has no related Zod schema/validation in doc08"
      - item: "business_rule=BR-012"
        reason: "Business rule 'BR-012' has no related Zod schema/validation in doc08"
      - item: "business_rule=BR-017"
        reason: "Business rule 'BR-017' has no related Zod schema/validation in doc08"
      - item: "business_rule=BR-019"
        reason: "Business rule 'BR-019' has no related Zod schema/validation in doc08"
      - item: "business_rule=BR-021"
        reason: "Business rule 'BR-021' has no related Zod schema/validation in doc08"
  - name: "user-story-vs-task"
    severity: "WARNING"
    status: "pass"
    failures:
  - name: "edge-case-vs-handling"
    severity: "INFO"
    status: "fail"
    failures:
      - item: "edge_case=EC-004"
        reason: "Edge case 'EC-004' has no handling in doc08.state_handling[]"
      - item: "edge_case=EC-005"
        reason: "Edge case 'EC-005' has no handling in doc08.state_handling[]"
---

# Validation Report

**Status:** ✅ PASS | 
BLOCKER: 0 | WARNING: 1 | INFO: 1

| Rule | Severity | Status | Failures |
|------|----------|--------|----------|
| route-vs-screen | BLOCKER | ✅ pass | 0 |
| api-vs-state | BLOCKER | ✅ pass | 0 |
| entity-vs-schema | BLOCKER | ✅ pass | 0 |
| business-rule-vs-validation | WARNING | ❌ fail | 8 |
| user-story-vs-task | WARNING | ✅ pass | 0 |
| edge-case-vs-handling | INFO | ❌ fail | 2 |

## ⚠️ Warnings
### business-rule-vs-validation
- **business_rule=BR-001**: Business rule 'BR-001' has no related Zod schema/validation in doc08
- **business_rule=BR-002**: Business rule 'BR-002' has no related Zod schema/validation in doc08
- **business_rule=BR-008**: Business rule 'BR-008' has no related Zod schema/validation in doc08
- **business_rule=BR-011**: Business rule 'BR-011' has no related Zod schema/validation in doc08
- **business_rule=BR-012**: Business rule 'BR-012' has no related Zod schema/validation in doc08
- **business_rule=BR-017**: Business rule 'BR-017' has no related Zod schema/validation in doc08
- **business_rule=BR-019**: Business rule 'BR-019' has no related Zod schema/validation in doc08
- **business_rule=BR-021**: Business rule 'BR-021' has no related Zod schema/validation in doc08

## ℹ️ Info
### edge-case-vs-handling
- **edge_case=EC-004**: Edge case 'EC-004' has no handling in doc08.state_handling[]
- **edge_case=EC-005**: Edge case 'EC-005' has no handling in doc08.state_handling[]
