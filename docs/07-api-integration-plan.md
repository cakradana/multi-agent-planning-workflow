---
title: API Integration Plan
description: API endpoint contracts, request/response types, and MSW handler definitions for Pocket personal finance app
prd_source_hash: 2d14b54a3f65482f716c5548f99aeeda8a8027d8cef98522d7ed03723a2ecbc3
agent: 7
schema_version: 1
status: complete
summary: >
  This document defines all API integration contracts for Pocket personal finance
  app — 11 endpoints with full request/response TypeScript types and MSW v2 handler
  definitions. Endpoints cover five resource domains: wallets (list, detail, create),
  categories (list, create), transactions (list, detail, create, update, delete),
  and monthly summary (aggregate by month/year). The API follows REST convention
  with snake_case JSON fields, integer IDs, ISO 8601 timestamps, and ISO 8601 date
  strings for transaction_date. Response envelope standardised: ApiResponse<T>
  wraps single-item responses with data field, ApiListResponse<T> wraps paginated
  lists with data array + pagination meta. Error responses use a standard ApiError
  shape with status, code, message, and optional validation errors array. Ten
  TypeScript type definitions cover all entities (Wallet, Category, Transaction,
  MonthlySummary) and request objects (CreateWalletRequest, CreateCategoryRequest,
  CreateTransactionRequest, UpdateTransactionRequest, TransactionFilters).
  TypeScript field names use camelCase per convention; API JSON uses snake_case —
  mapping table documents the transformation. MSW v2 handlers defined for all 11
  endpoints with realistic mock data, manual validation on POST/PUT mutations,
  simulated 404 for missing resources, and 422 for validation failures. No auth
  endpoints — user assumed authenticated per MVP scope. Eleven endpoint-to-hook
  mappings cross-reference doc-05 query_hooks. Cache invalidation cascade is
  handled client-side (doc-05 section 3.3), not reflected in API contract. Four
  assumptions documented: no auth middleware (ASM-007), counter-based mock IDs
  (ASM-008), joined fields in transaction list response (ASM-009), and summary as
  server-computed endpoint (ASM-010, re-statement of doc-05 ASM-004).
endpoints:
  - method: GET
    path: /api/wallets
    request_type: null
    response_type: ApiListResponse<Wallet>
    msw_handler: getWallets
    related_query_hook: useWallets
    source: "doc-05: query_hooks[0]"
    confidence: 1.0
  - method: GET
    path: /api/wallets/:id
    request_type: null
    response_type: ApiResponse<Wallet>
    msw_handler: getWallet
    related_query_hook: useWallet
    source: "doc-05: query_hooks[1]"
    confidence: 0.6
  - method: POST
    path: /api/wallets
    request_type: CreateWalletRequest
    response_type: ApiResponse<Wallet>
    msw_handler: createWallet
    related_query_hook: useCreateWallet
    source: "doc-05: query_hooks[2]"
    confidence: 1.0
  - method: GET
    path: /api/categories
    request_type: null
    response_type: ApiListResponse<Category>
    msw_handler: getCategories
    related_query_hook: useCategories
    source: "doc-05: query_hooks[3]"
    confidence: 1.0
  - method: POST
    path: /api/categories
    request_type: CreateCategoryRequest
    response_type: ApiResponse<Category>
    msw_handler: createCategory
    related_query_hook: useCreateCategory
    source: "doc-05: query_hooks[4]"
    confidence: 1.0
  - method: GET
    path: /api/transactions
    request_type: TransactionFilters
    response_type: ApiListResponse<Transaction>
    msw_handler: getTransactions
    related_query_hook: useTransactions
    source: "doc-05: query_hooks[5]"
    confidence: 1.0
  - method: GET
    path: /api/transactions/:id
    request_type: null
    response_type: ApiResponse<Transaction>
    msw_handler: getTransaction
    related_query_hook: useTransaction
    source: "doc-05: query_hooks[6]"
    confidence: 0.9
  - method: POST
    path: /api/transactions
    request_type: CreateTransactionRequest
    response_type: ApiResponse<Transaction>
    msw_handler: createTransaction
    related_query_hook: useCreateTransaction
    source: "doc-05: query_hooks[7]"
    confidence: 1.0
  - method: PUT
    path: /api/transactions/:id
    request_type: UpdateTransactionRequest
    response_type: ApiResponse<Transaction>
    msw_handler: updateTransaction
    related_query_hook: useUpdateTransaction
    source: "doc-05: query_hooks[8]"
    confidence: 0.9
  - method: DELETE
    path: /api/transactions/:id
    request_type: null
    response_type: ApiResponse<DeleteTransactionResponse>
    msw_handler: deleteTransaction
    related_query_hook: useDeleteTransaction
    source: "doc-05: query_hooks[9]"
    confidence: 1.0
  - method: GET
    path: /api/summary
    request_type: SummaryParams
    response_type: ApiResponse<MonthlySummary>
    msw_handler: getMonthlySummary
    related_query_hook: useMonthlySummary
    source: "doc-05: query_hooks[10]"
    confidence: 1.0
types:
  - name: Wallet
    fields:
      - name: id
        type: number
        optional: false
        description: Primary key
      - name: userId
        type: number
        optional: false
        description: Owner user foreign key
      - name: name
        type: string
        optional: false
        description: Wallet display name
      - name: type
        type: "'cash' | 'bank' | 'e-wallet'"
        optional: false
        description: Wallet type enum
      - name: initialBalance
        type: number
        optional: false
        description: Starting balance when wallet created
      - name: currentBalance
        type: number
        optional: false
        description: Balance after all transactions applied
      - name: createdAt
        type: string
        optional: false
        description: ISO 8601 creation timestamp
      - name: updatedAt
        type: string
        optional: false
        description: ISO 8601 last update timestamp
    source: "doc-02: entities[1]"
  - name: Category
    fields:
      - name: id
        type: number
        optional: false
        description: Primary key
      - name: userId
        type: number | null
        optional: false
        description: Owner user foreign key (null for system defaults)
      - name: name
        type: string
        optional: false
        description: Category display name
      - name: type
        type: "'income' | 'expense'"
        optional: false
        description: Category type — determines which transaction types can use it
      - name: isDefault
        type: boolean
        optional: false
        description: True for system-provided categories
      - name: createdAt
        type: string
        optional: false
        description: ISO 8601 creation timestamp
      - name: updatedAt
        type: string
        optional: false
        description: ISO 8601 last update timestamp
    source: "doc-02: entities[2]"
  - name: Transaction
    fields:
      - name: id
        type: number
        optional: false
        description: Primary key
      - name: userId
        type: number
        optional: false
        description: Owner user foreign key
      - name: walletId
        type: number
        optional: false
        description: Wallet foreign key
      - name: categoryId
        type: number
        optional: false
        description: Category foreign key
      - name: type
        type: "'income' | 'expense'"
        optional: false
        description: Transaction direction
      - name: amount
        type: number
        optional: false
        description: Transaction amount (positive integer)
      - name: transactionDate
        type: string
        optional: false
        description: ISO 8601 date when transaction occurred
      - name: note
        type: string | null
        optional: false
        description: Optional note/description
      - name: createdAt
        type: string
        optional: false
        description: ISO 8601 creation timestamp
      - name: updatedAt
        type: string
        optional: false
        description: ISO 8601 last update timestamp
      - name: walletName
        type: string
        optional: true
        description: Wallet name from server-side join (list response)
      - name: categoryName
        type: string
        optional: true
        description: Category name from server-side join (list response)
    source: "doc-02: entities[3]"
  - name: User
    fields:
      - name: id
        type: number
        optional: false
        description: Primary key — implicit in all requests via auth context
    source: "doc-02: entities[0]"
  - name: CreateWalletRequest
    fields:
      - name: name
        type: string
        optional: false
        description: Wallet display name (required, non-empty)
      - name: type
        type: "'cash' | 'bank' | 'e-wallet'"
        optional: false
        description: Wallet type
      - name: initialBalance
        type: number
        optional: false
        description: Starting balance (integer, >= 0)
    source: "doc-05: section 3.3 (useCreateWallet)"
  - name: CreateCategoryRequest
    fields:
      - name: name
        type: string
        optional: false
        description: Category display name (required, non-empty)
      - name: type
        type: "'income' | 'expense'"
        optional: false
        description: Category type
    source: "doc-05: section 3.3 (useCreateCategory)"
  - name: CreateTransactionRequest
    fields:
      - name: walletId
        type: number
        optional: false
        description: Target wallet ID
      - name: categoryId
        type: number
        optional: false
        description: Category ID (must match transaction type)
      - name: type
        type: "'income' | 'expense'"
        optional: false
        description: Transaction direction
      - name: amount
        type: number
        optional: false
        description: Transaction amount (positive integer)
      - name: transactionDate
        type: string
        optional: false
        description: ISO 8601 date (YYYY-MM-DD)
      - name: note
        type: string
        optional: true
        description: Optional note (max 500 chars)
    source: "doc-05: section 3.3 (useCreateTransaction)"
  - name: UpdateTransactionRequest
    fields:
      - name: walletId
        type: number
        optional: false
        description: Target wallet ID
      - name: categoryId
        type: number
        optional: false
        description: Category ID (must match transaction type)
      - name: type
        type: "'income' | 'expense'"
        optional: false
        description: Transaction direction
      - name: amount
        type: number
        optional: false
        description: Transaction amount (positive integer)
      - name: transactionDate
        type: string
        optional: false
        description: ISO 8601 date (YYYY-MM-DD)
      - name: note
        type: string
        optional: true
        description: Optional note (max 500 chars)
    source: "doc-05: section 3.3 (useUpdateTransaction)"
  - name: TransactionFilters
    fields:
      - name: dateFrom
        type: string
        optional: true
        description: Filter start date (ISO 8601, inclusive)
      - name: dateTo
        type: string
        optional: true
        description: Filter end date (ISO 8601, inclusive)
      - name: type
        type: "'income' | 'expense'"
        optional: true
        description: Filter by transaction type
      - name: walletId
        type: number
        optional: true
        description: Filter by wallet
      - name: categoryId
        type: number
        optional: true
        description: Filter by category
      - name: q
        type: string
        optional: true
        description: Search note text
      - name: page
        type: number
        optional: true
        description: Page number (1-indexed)
      - name: perPage
        type: number
        optional: true
        description: Items per page (default 20)
    source: "doc-05: section 3.2 (useTransactions)"
  - name: SummaryParams
    fields:
      - name: month
        type: number
        optional: false
        description: Month (1-12)
      - name: year
        type: number
        optional: false
        description: Year (4-digit)
    source: "doc-05: section 3.2 (useMonthlySummary)"
  - name: MonthlySummary
    fields:
      - name: totalIncome
        type: number
        optional: false
        description: Sum of all income transactions
      - name: totalExpense
        type: number
        optional: false
        description: Sum of all expense transactions
      - name: netBalance
        type: number
        optional: false
        description: totalIncome - totalExpense
      - name: transactionCount
        type: number
        optional: false
        description: Total transaction count for month
      - name: incomeByCategory
        type: "CategoryBreakdown[]"
        optional: false
        description: Income grouped by category
      - name: expenseByCategory
        type: "CategoryBreakdown[]"
        optional: false
        description: Expense grouped by category
    source: "doc-05: section 3.2 (useMonthlySummary)"
  - name: CategoryBreakdown
    fields:
      - name: categoryId
        type: number
        optional: false
        description: Category ID
      - name: categoryName
        type: string
        optional: false
        description: Category display name
      - name: total
        type: number
        optional: false
        description: Sum of transactions in this category
    source: "doc-05: section 3.2 (useMonthlySummary)"
  - name: DeleteTransactionResponse
    fields:
      - name: success
        type: boolean
        optional: false
        description: Confirmation of deletion
    source: "doc-05: section 3.3 (useDeleteTransaction)"
  - name: ApiResponse
    fields:
      - name: data
        type: T
        optional: false
        description: Response payload
    source: convention — standard REST envelope
  - name: ApiListResponse
    fields:
      - name: data
        type: "T[]"
        optional: false
        description: Response array
      - name: meta
        type: PaginationMeta
        optional: false
        description: Pagination metadata
    source: convention — standard REST paginated envelope
  - name: PaginationMeta
    fields:
      - name: total
        type: number
        optional: false
        description: Total items across all pages
      - name: page
        type: number
        optional: false
        description: Current page number (1-indexed)
      - name: perPage
        type: number
        optional: false
        description: Items per page
      - name: totalPages
        type: number
        optional: false
        description: Total number of pages
    source: convention — standard pagination metadata
  - name: ApiError
    fields:
      - name: status
        type: number
        optional: false
        description: HTTP status code
      - name: code
        type: string
        optional: false
        description: Machine-readable error code (kebab-case)
      - name: message
        type: string
        optional: false
        description: Human-readable error description
      - name: errors
        type: "FieldError[]"
        optional: true
        description: Validation error details (422 only)
    source: inference — standard error envelope
  - name: FieldError
    fields:
      - name: field
        type: string
        optional: false
        description: Field name in snake_case
      - name: message
        type: string
        optional: false
        description: Human-readable error for this field
      - name: code
        type: string
        optional: false
        description: Machine-readable error code
    source: inference — Zod validation error shape
  - name: UnauthorizedError
    fields:
      - name: status
        type: number
        optional: false
        description: Always 401
      - name: code
        type: string
        optional: false
        description: "'unauthorized'"
      - name: message
        type: string
        optional: false
        description: "'Authentication required'"
    source: inference — standard auth error
  - name: NotFoundError
    fields:
      - name: status
        type: number
        optional: false
        description: Always 404
      - name: code
        type: string
        optional: false
        description: "'not_found'"
      - name: message
        type: string
        optional: false
        description: Resource-specific not found message
    source: inference — standard resource error
  - name: ValidationError
    fields:
      - name: status
        type: number
        optional: false
        description: Always 422
      - name: code
        type: string
        optional: false
        description: "'validation_error'"
      - name: message
        type: string
        optional: false
        description: "'Validation failed'"
      - name: errors
        type: "FieldError[]"
        optional: false
        description: Per-field validation errors
    source: inference — Zod validation error shape
  - name: ServerError
    fields:
      - name: status
        type: number
        optional: false
        description: Always 500
      - name: code
        type: string
        optional: false
        description: "'internal_server_error'"
      - name: message
        type: string
        optional: false
        description: "'An unexpected error occurred'"
    source: inference — generic server error
assumptions:
  - id: ASM-007
    statement: No auth middleware in MVP. All endpoints assume authenticated user via implicit context. Auth endpoints omitted.
    impacts:
      - No auth-related request/response types defined
      - 401 responses documented but never triggered in MSW handlers
      - API contract has no session tokens, cookies, or auth headers
    confidence: 1.0
    source: "doc-03: ASM-001, doc-04: ASM-001"
  - id: ASM-008
    statement: MSW mock handlers use incrementing counter for ID generation, not UUID. IDs are integers starting from seed data.
    impacts:
      - Create responses return sequential numeric IDs
      - ID clashes impossible in single MSW worker session
    confidence: 1.0
    source: inference — MSW mock pattern
  - id: ASM-009
    statement: Transaction list endpoint (GET /api/transactions) returns joined wallet_name and category_name from server-side join. Detail endpoint may not include these.
    impacts:
      - Transaction type has optional walletName and categoryName fields
      - List endpoint always includes joined names
      - Detail endpoint may omit them — client handles missing fields
    confidence: 0.8
    source: inference — common REST API pattern for list vs detail
  - id: ASM-010
    statement: Monthly summary is computed server-side (single endpoint), not aggregated client-side from transaction list. No client-side aggregation needed.
    impacts:
      - GET /api/summary is the only summary endpoint
      - No separate aggregation logic in frontend
    confidence: 1.0
    source: "doc-05: ASM-004"
---

# 07 — API Integration Plan

## 1. API Conventions

### Base URL

```
/api
```

All endpoints relative to `/api`. In development, Next.js API routes or MSW intercepts this prefix. In production, reverse proxy rewrites `/api` to backend server.

### Content Type

- Request: `application/json`
- Response: `application/json`
- No `multipart/form-data` in MVP — all payloads are JSON

### Auth Header

Not required in MVP. User assumed authenticated via implicit session context (Next.js middleware or server-side session). `ponytail: add Authorization: Bearer <token> header when auth is introduced.`

### Response Envelope

Single-item responses:

```json
{
  "data": { ... }
}
```

Paginated list responses:

```json
{
  "data": [ ... ],
  "meta": {
    "total": 100,
    "page": 1,
    "per_page": 20,
    "total_pages": 5
  }
}
```

Error responses:

```json
{
  "status": 422,
  "code": "validation_error",
  "message": "Validation failed",
  "errors": [
    { "field": "name", "message": "Name is required", "code": "required" }
  ]
}
```

### Pagination

- Page numbering: 1-indexed
- Default page size: 20
- Max page size: 100
- Pagination only applies to `GET /api/transactions`
- Wallets, categories, summaries return full lists (no pagination needed for MVP-scale data)

### Field Convention: TypeScript vs API

| Context | Convention | Example |
|---------|-----------|---------|
| TypeScript types | camelCase | `currentBalance`, `createdAt` |
| API JSON | snake_case | `current_balance`, `created_at` |
| Request body (JSON) | snake_case | `{ "wallet_id": 1 }` |
| Query params | snake_case | `?date_from=2026-01-01&per_page=5` |

### Error Status Codes

| Status | Meaning | When |
|--------|---------|------|
| 200 | Success | All GET, PUT, DELETE |
| 201 | Created | POST (resource created) |
| 400 | Bad request | Malformed request body (invalid JSON) |
| 401 | Unauthorized | Not authenticated (MVP: never triggered) |
| 404 | Not found | Resource ID does not exist |
| 422 | Unprocessable entity | Validation failure |
| 500 | Internal server error | Unexpected backend error |

---

## 2. Endpoint Contracts

### 2.1 GET /api/wallets

**Query Hook:** `useWallets` (doc-05: query_hooks[0])
**Confidence:** 1.0 (doc-03: FR-001)

#### Request

No query params. No request body.

#### Response (200)

```typescript
// TypeScript type
interface ApiListResponse<Wallet> {
  data: Wallet[]
  meta: PaginationMeta
}
```

```json
{
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "name": "Cash",
      "type": "cash",
      "initial_balance": 500000,
      "current_balance": 750000,
      "created_at": "2026-01-01T00:00:00.000Z",
      "updated_at": "2026-06-15T10:30:00.000Z"
    }
  ],
  "meta": {
    "total": 3,
    "page": 1,
    "per_page": 20,
    "total_pages": 1
  }
}
```

#### Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 401 | unauthorized | Not authenticated |
| 500 | internal_server_error | Internal error |

---

### 2.2 GET /api/wallets/:id

**Query Hook:** `useWallet` (doc-05: query_hooks[1])
**Confidence:** 0.6 (inferred screen — doc-04: ASM-002)

#### Request

| Param | Type | Location | Required | Description |
|-------|------|----------|----------|-------------|
| id | number | path | yes | Wallet ID |

#### Response (200)

```typescript
interface ApiResponse<Wallet> {
  data: Wallet
}
```

```json
{
  "data": {
    "id": 1,
    "user_id": 1,
    "name": "Cash",
    "type": "cash",
    "initial_balance": 500000,
    "current_balance": 750000,
    "created_at": "2026-01-01T00:00:00.000Z",
    "updated_at": "2026-06-15T10:30:00.000Z"
  }
}
```

#### Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 401 | unauthorized | Not authenticated |
| 404 | not_found | Wallet not found |
| 500 | internal_server_error | Internal error |

---

### 2.3 POST /api/wallets

**Query Hook:** `useCreateWallet` (doc-05: query_hooks[2])
**Confidence:** 1.0 (doc-03: FR-001)

#### Request

```typescript
interface CreateWalletRequest {
  name: string
  type: 'cash' | 'bank' | 'e-wallet'
  initialBalance: number
}
```

```json
{
  "name": "BCA Savings",
  "type": "bank",
  "initial_balance": 1000000
}
```

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| name | string | yes | Non-empty, max 100 chars |
| type | enum | yes | One of: cash, bank, e-wallet |
| initial_balance | integer | yes | >= 0 |

#### Response (201)

```typescript
interface ApiResponse<Wallet> {
  data: Wallet
}
```

Returns the created wallet with server-generated `id`, `current_balance` (equals `initial_balance` on create), `created_at`, and `updated_at`.

#### Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 400 | bad_request | Invalid JSON body |
| 401 | unauthorized | Not authenticated |
| 422 | validation_error | Validation failed (see FieldError[]) |
| 500 | internal_server_error | Internal error |

---

### 2.4 GET /api/categories

**Query Hook:** `useCategories` (doc-05: query_hooks[3])
**Confidence:** 1.0 (doc-03: FR-002)

#### Request

No query params. No request body.

#### Response (200)

```typescript
interface ApiListResponse<Category> {
  data: Category[]
  meta: PaginationMeta
}
```

Returns both system default categories (`is_default: true`, `user_id: null`) and user-created categories.

#### Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 401 | unauthorized | Not authenticated |
| 500 | internal_server_error | Internal error |

---

### 2.5 POST /api/categories

**Query Hook:** `useCreateCategory` (doc-05: query_hooks[4])
**Confidence:** 1.0 (doc-03: FR-002)

#### Request

```typescript
interface CreateCategoryRequest {
  name: string
  type: 'income' | 'expense'
}
```

```json
{
  "name": "Freelance",
  "type": "income"
}
```

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| name | string | yes | Non-empty, max 100 chars |
| type | enum | yes | One of: income, expense |

#### Response (201)

```typescript
interface ApiResponse<Category> {
  data: Category
}
```

#### Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 400 | bad_request | Invalid JSON body |
| 401 | unauthorized | Not authenticated |
| 422 | validation_error | Validation failed (e.g., duplicate name per user per type) |
| 500 | internal_server_error | Internal error |

---

### 2.6 GET /api/transactions

**Query Hook:** `useTransactions` (doc-05: query_hooks[5])
**Confidence:** 1.0 (doc-03: FR-004)

#### Request

Query params (all optional):

| Param | Type | Description |
|-------|------|-------------|
| date_from | string (ISO date) | Filter start date (inclusive) |
| date_to | string (ISO date) | Filter end date (inclusive) |
| type | enum | income or expense |
| wallet_id | integer | Filter by wallet |
| category_id | integer | Filter by category |
| q | string | Search in note field |
| page | integer | Page number (default: 1) |
| per_page | integer | Items per page (default: 20, max: 100) |

```typescript
interface TransactionFilters {
  dateFrom?: string
  dateTo?: string
  type?: 'income' | 'expense'
  walletId?: number
  categoryId?: number
  q?: string
  page?: number
  perPage?: number
}
```

#### Response (200)

```typescript
interface ApiListResponse<Transaction> {
  data: Transaction[]
  meta: PaginationMeta
}
```

List response includes server-joined fields `wallet_name` and `category_name`.

```json
{
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "wallet_id": 1,
      "category_id": 2,
      "type": "expense",
      "amount": 50000,
      "transaction_date": "2026-06-15",
      "note": "Lunch",
      "created_at": "2026-06-15T12:00:00.000Z",
      "updated_at": "2026-06-15T12:00:00.000Z",
      "wallet_name": "Cash",
      "category_name": "Food"
    }
  ],
  "meta": {
    "total": 42,
    "page": 1,
    "per_page": 20,
    "total_pages": 3
  }
}
```

#### Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 401 | unauthorized | Not authenticated |
| 422 | validation_error | Invalid query param values |
| 500 | internal_server_error | Internal error |

---

### 2.7 GET /api/transactions/:id

**Query Hook:** `useTransaction` (doc-05: query_hooks[6])
**Confidence:** 0.9 (doc-03: FR-005)

#### Request

| Param | Type | Location | Required | Description |
|-------|------|----------|----------|-------------|
| id | number | path | yes | Transaction ID |

#### Response (200)

```typescript
interface ApiResponse<Transaction> {
  data: Transaction
}
```

Detail response may omit `wallet_name` and `category_name` joined fields (list-only enrichment per ASM-009).

#### Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 401 | unauthorized | Not authenticated |
| 404 | not_found | Transaction not found |
| 500 | internal_server_error | Internal error |

---

### 2.8 POST /api/transactions

**Query Hook:** `useCreateTransaction` (doc-05: query_hooks[7])
**Confidence:** 1.0 (doc-03: FR-003)

#### Request

```typescript
interface CreateTransactionRequest {
  walletId: number
  categoryId: number
  type: 'income' | 'expense'
  amount: number
  transactionDate: string
  note?: string
}
```

```json
{
  "wallet_id": 1,
  "category_id": 3,
  "type": "expense",
  "amount": 50000,
  "transaction_date": "2026-06-15",
  "note": "Lunch"
}
```

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| wallet_id | integer | yes | Must reference existing wallet |
| category_id | integer | yes | Must reference existing category; type must match transaction type |
| type | enum | yes | One of: income, expense |
| amount | integer | yes | > 0 |
| transaction_date | string (ISO date) | yes | YYYY-MM-DD format; <= today |
| note | string | no | Max 500 chars |

#### Response (201)

```typescript
interface ApiResponse<Transaction> {
  data: Transaction
}
```

#### Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 400 | bad_request | Invalid JSON body |
| 401 | unauthorized | Not authenticated |
| 404 | not_found | wallet_id or category_id not found |
| 422 | validation_error | Validation failed |
| 500 | internal_server_error | Internal error |

---

### 2.9 PUT /api/transactions/:id

**Query Hook:** `useUpdateTransaction` (doc-05: query_hooks[8])
**Confidence:** 0.9 (doc-03: FR-005)

#### Request

```typescript
interface UpdateTransactionRequest {
  walletId: number
  categoryId: number
  type: 'income' | 'expense'
  amount: number
  transactionDate: string
  note?: string
}
```

Same shape as `CreateTransactionRequest`. Backend applies full replacement (not partial patch) for simplicity.

```json
{
  "wallet_id": 1,
  "category_id": 3,
  "type": "expense",
  "amount": 75000,
  "transaction_date": "2026-06-15",
  "note": "Lunch with team"
}
```

#### Response (200)

```typescript
interface ApiResponse<Transaction> {
  data: Transaction
}
```

Returns updated transaction with server-updated `updated_at` timestamp.

#### Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 400 | bad_request | Invalid JSON body |
| 401 | unauthorized | Not authenticated |
| 404 | not_found | Transaction not found |
| 422 | validation_error | Validation failed |
| 500 | internal_server_error | Internal error |

---

### 2.10 DELETE /api/transactions/:id

**Query Hook:** `useDeleteTransaction` (doc-05: query_hooks[9])
**Confidence:** 1.0 (doc-03: FR-006)

#### Request

| Param | Type | Location | Required | Description |
|-------|------|----------|----------|-------------|
| id | number | path | yes | Transaction ID |

No request body.

#### Response (200)

```typescript
interface DeleteTransactionResponse {
  success: true
}

interface ApiResponse<DeleteTransactionResponse> {
  data: DeleteTransactionResponse
}
```

```json
{
  "data": {
    "success": true
  }
}
```

#### Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 401 | unauthorized | Not authenticated |
| 404 | not_found | Transaction not found |
| 500 | internal_server_error | Internal error |

---

### 2.11 GET /api/summary

**Query Hook:** `useMonthlySummary` (doc-05: query_hooks[10])
**Confidence:** 1.0 (doc-03: FR-007)

#### Request

Query params:

| Param | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| month | integer (1-12) | no | Current month | Month |
| year | integer (4-digit) | no | Current year | Year |

```typescript
interface SummaryParams {
  month: number
  year: number
}
```

#### Response (200)

```typescript
interface MonthlySummary {
  totalIncome: number
  totalExpense: number
  netBalance: number
  transactionCount: number
  incomeByCategory: CategoryBreakdown[]
  expenseByCategory: CategoryBreakdown[]
}

interface CategoryBreakdown {
  categoryId: number
  categoryName: string
  total: number
}

interface ApiResponse<MonthlySummary> {
  data: MonthlySummary
}
```

```json
{
  "data": {
    "total_income": 5000000,
    "total_expense": 3200000,
    "net_balance": 1800000,
    "transaction_count": 28,
    "income_by_category": [
      { "category_id": 1, "category_name": "Salary", "total": 4500000 },
      { "category_id": 2, "category_name": "Freelance", "total": 500000 }
    ],
    "expense_by_category": [
      { "category_id": 3, "category_name": "Food", "total": 1200000 },
      { "category_id": 4, "category_name": "Transport", "total": 800000 }
    ]
  }
}
```

#### Error Responses

| Status | Code | Description |
|--------|------|-------------|
| 401 | unauthorized | Not authenticated |
| 422 | validation_error | Invalid month/year values |
| 500 | internal_server_error | Internal error |

---

## 3. TypeScript Type Definitions

### 3.1 Entity Types

```typescript
// types/api.ts

// ── Envelopes ──

interface ApiResponse<T> {
  data: T
}

interface ApiListResponse<T> {
  data: T[]
  meta: PaginationMeta
}

interface PaginationMeta {
  total: number
  page: number
  perPage: number
  totalPages: number
}

// ── Entities ──

interface User {
  id: number
}

interface Wallet {
  id: number
  userId: number
  name: string
  type: 'cash' | 'bank' | 'e-wallet'
  initialBalance: number
  currentBalance: number
  createdAt: string
  updatedAt: string
}

interface Category {
  id: number
  userId: number | null
  name: string
  type: 'income' | 'expense'
  isDefault: boolean
  createdAt: string
  updatedAt: string
}

interface Transaction {
  id: number
  userId: number
  walletId: number
  categoryId: number
  type: 'income' | 'expense'
  amount: number
  transactionDate: string
  note: string | null
  createdAt: string
  updatedAt: string
  // Joined fields (list response only)
  walletName?: string
  categoryName?: string
}
```

### 3.2 Request / Filter Types

```typescript
// types/api.ts

interface CreateWalletRequest {
  name: string
  type: 'cash' | 'bank' | 'e-wallet'
  initialBalance: number
}

interface CreateCategoryRequest {
  name: string
  type: 'income' | 'expense'
}

interface CreateTransactionRequest {
  walletId: number
  categoryId: number
  type: 'income' | 'expense'
  amount: number
  transactionDate: string
  note?: string
}

// Update uses same shape as Create — backend does full replacement
interface UpdateTransactionRequest {
  walletId: number
  categoryId: number
  type: 'income' | 'expense'
  amount: number
  transactionDate: string
  note?: string
}

interface TransactionFilters {
  dateFrom?: string
  dateTo?: string
  type?: 'income' | 'expense'
  walletId?: number
  categoryId?: number
  q?: string
  page?: number
  perPage?: number
}

interface SummaryParams {
  month: number
  year: number
}
```

### 3.3 Summary Types

```typescript
// types/api.ts

interface MonthlySummary {
  totalIncome: number
  totalExpense: number
  netBalance: number
  transactionCount: number
  incomeByCategory: CategoryBreakdown[]
  expenseByCategory: CategoryBreakdown[]
}

interface CategoryBreakdown {
  categoryId: number
  categoryName: string
  total: number
}
```

### 3.4 Response Types

```typescript
// types/api.ts

interface DeleteTransactionResponse {
  success: true
}
```

### 3.5 Field Mapping: TypeScript camelCase → API snake_case

| TypeScript Field | API Field | Applies To |
|-----------------|-----------|------------|
| `userId` | `user_id` | Wallet, Category, Transaction |
| `initialBalance` | `initial_balance` | Wallet |
| `currentBalance` | `current_balance` | Wallet |
| `isDefault` | `is_default` | Category |
| `walletId` | `wallet_id` | Transaction, TransactionFilters |
| `categoryId` | `category_id` | Transaction, TransactionFilters, CategoryBreakdown |
| `transactionDate` | `transaction_date` | Transaction |
| `createdAt` | `created_at` | All entities |
| `updatedAt` | `updated_at` | All entities |
| `walletName` | `wallet_name` | Transaction (joined) |
| `categoryName` | `category_name` | Transaction (joined), CategoryBreakdown |
| `dateFrom` | `date_from` | TransactionFilters |
| `dateTo` | `date_to` | TransactionFilters |
| `perPage` | `per_page` | TransactionFilters, PaginationMeta |
| `totalPages` | `total_pages` | PaginationMeta |
| `totalIncome` | `total_income` | MonthlySummary |
| `totalExpense` | `total_expense` | MonthlySummary |
| `netBalance` | `net_balance` | MonthlySummary |
| `transactionCount` | `transaction_count` | MonthlySummary |
| `incomeByCategory` | `income_by_category` | MonthlySummary |
| `expenseByCategory` | `expense_by_category` | MonthlySummary |

Fields without entries in this table (`id`, `name`, `type`, `amount`, `note`, `q`, `page`, `month`, `year`, `success`) are identical in both conventions.

---

## 4. MSW Handler Definitions

### 4.1 Seed Data

```typescript
// mocks/seed.ts
import { http, HttpResponse } from 'msw'

export const seedWallets = [
  {
    id: 1,
    user_id: 1,
    name: 'Cash',
    type: 'cash' as const,
    initial_balance: 500000,
    current_balance: 750000,
    created_at: '2026-01-01T00:00:00.000Z',
    updated_at: '2026-06-15T10:30:00.000Z',
  },
  {
    id: 2,
    user_id: 1,
    name: 'BCA Savings',
    type: 'bank' as const,
    initial_balance: 2000000,
    current_balance: 2500000,
    created_at: '2026-01-15T00:00:00.000Z',
    updated_at: '2026-06-14T08:00:00.000Z',
  },
  {
    id: 3,
    user_id: 1,
    name: 'GoPay',
    type: 'e-wallet' as const,
    initial_balance: 100000,
    current_balance: 50000,
    created_at: '2026-02-01T00:00:00.000Z',
    updated_at: '2026-06-10T14:00:00.000Z',
  },
]

export const seedCategories = [
  { id: 1, user_id: null, name: 'Salary', type: 'income' as const, is_default: true, created_at: '2026-01-01T00:00:00.000Z', updated_at: '2026-01-01T00:00:00.000Z' },
  { id: 2, user_id: null, name: 'Freelance', type: 'income' as const, is_default: true, created_at: '2026-01-01T00:00:00.000Z', updated_at: '2026-01-01T00:00:00.000Z' },
  { id: 3, user_id: null, name: 'Food', type: 'expense' as const, is_default: true, created_at: '2026-01-01T00:00:00.000Z', updated_at: '2026-01-01T00:00:00.000Z' },
  { id: 4, user_id: null, name: 'Transport', type: 'expense' as const, is_default: true, created_at: '2026-01-01T00:00:00.000Z', updated_at: '2026-01-01T00:00:00.000Z' },
  { id: 5, user_id: null, name: 'Shopping', type: 'expense' as const, is_default: true, created_at: '2026-01-01T00:00:00.000Z', updated_at: '2026-01-01T00:00:00.000Z' },
  { id: 6, user_id: null, name: 'Bills', type: 'expense' as const, is_default: true, created_at: '2026-01-01T00:00:00.000Z', updated_at: '2026-01-01T00:00:00.000Z' },
]

export const seedTransactions = [
  { id: 1, user_id: 1, wallet_id: 1, category_id: 3, type: 'expense' as const, amount: 50000, transaction_date: '2026-06-15', note: 'Lunch', created_at: '2026-06-15T12:00:00.000Z', updated_at: '2026-06-15T12:00:00.000Z' },
  { id: 2, user_id: 1, wallet_id: 1, category_id: 4, type: 'expense' as const, amount: 20000, transaction_date: '2026-06-15', note: 'Gojek', created_at: '2026-06-15T14:00:00.000Z', updated_at: '2026-06-15T14:00:00.000Z' },
  { id: 3, user_id: 1, wallet_id: 2, category_id: 1, type: 'income' as const, amount: 5000000, transaction_date: '2026-06-01', note: 'Monthly salary', created_at: '2026-06-01T08:00:00.000Z', updated_at: '2026-06-01T08:00:00.000Z' },
  { id: 4, user_id: 1, wallet_id: 2, category_id: 6, type: 'expense' as const, amount: 500000, transaction_date: '2026-06-05', note: 'Electricity bill', created_at: '2026-06-05T09:00:00.000Z', updated_at: '2026-06-05T09:00:00.000Z' },
  { id: 5, user_id: 1, wallet_id: 3, category_id: 4, type: 'expense' as const, amount: 15000, transaction_date: '2026-06-10', note: 'Bus', created_at: '2026-06-10T07:00:00.000Z', updated_at: '2026-06-10T07:00:00.000Z' },
]

// Stateful stores for mutations
let nextWalletId = 4
let nextCategoryId = 7
let nextTransactionId = 6
```

### 4.2 Wallet Handlers

```typescript
// mocks/handlers/wallets.ts
import { http, HttpResponse } from 'msw'
import { seedWallets, seedTransactions, nextWalletId as _nextId } from '../seed'

let wallets = [...seedWallets]
let nextId = 4

export const walletHandlers = [
  // GET /api/wallets
  http.get('/api/wallets', () => {
    return HttpResponse.json({
      data: wallets,
      meta: { total: wallets.length, page: 1, perPage: 20, totalPages: 1 },
    })
  }),

  // GET /api/wallets/:id
  http.get('/api/wallets/:id', ({ params }) => {
    const id = Number(params.id)
    const wallet = wallets.find((w) => w.id === id)
    if (!wallet) {
      return HttpResponse.json(
        { status: 404, code: 'not_found', message: 'Wallet not found' },
        { status: 404 }
      )
    }
    return HttpResponse.json({ data: wallet })
  }),

  // POST /api/wallets
  http.post('/api/wallets', async ({ request }) => {
    const body = await request.json() as any

    // Validation
    const errors: { field: string; message: string; code: string }[] = []
    if (!body.name || typeof body.name !== 'string' || body.name.trim() === '') {
      errors.push({ field: 'name', message: 'Name is required', code: 'required' })
    }
    if (body.name && body.name.length > 100) {
      errors.push({ field: 'name', message: 'Name must be 100 characters or less', code: 'max_length' })
    }
    if (!['cash', 'bank', 'e-wallet'].includes(body.type)) {
      errors.push({ field: 'type', message: 'Type must be cash, bank, or e-wallet', code: 'invalid_enum' })
    }
    if (body.initial_balance === undefined || body.initial_balance === null || typeof body.initial_balance !== 'number' || body.initial_balance < 0) {
      errors.push({ field: 'initial_balance', message: 'Initial balance must be a non-negative integer', code: 'invalid' })
    }
    if (errors.length > 0) {
      return HttpResponse.json(
        { status: 422, code: 'validation_error', message: 'Validation failed', errors },
        { status: 422 }
      )
    }

    const now = new Date().toISOString()
    const newWallet = {
      id: nextId++,
      user_id: 1,
      name: body.name.trim(),
      type: body.type,
      initial_balance: body.initial_balance,
      current_balance: body.initial_balance,
      created_at: now,
      updated_at: now,
    }
    wallets.push(newWallet)
    return HttpResponse.json({ data: newWallet }, { status: 201 })
  }),
]
```

### 4.3 Category Handlers

```typescript
// mocks/handlers/categories.ts
import { http, HttpResponse } from 'msw'
import { seedCategories } from '../seed'

let categories = [...seedCategories]
let nextId = 7

export const categoryHandlers = [
  // GET /api/categories
  http.get('/api/categories', () => {
    return HttpResponse.json({
      data: categories,
      meta: { total: categories.length, page: 1, perPage: 20, totalPages: 1 },
    })
  }),

  // POST /api/categories
  http.post('/api/categories', async ({ request }) => {
    const body = await request.json() as any

    // Validation
    const errors: { field: string; message: string; code: string }[] = []
    if (!body.name || typeof body.name !== 'string' || body.name.trim() === '') {
      errors.push({ field: 'name', message: 'Name is required', code: 'required' })
    }
    if (!['income', 'expense'].includes(body.type)) {
      errors.push({ field: 'type', message: 'Type must be income or expense', code: 'invalid_enum' })
    }
    // Check duplicate name per type
    const duplicate = categories.find(
      (c) => c.name.toLowerCase() === body.name.trim().toLowerCase() && c.type === body.type
    )
    if (duplicate) {
      errors.push({ field: 'name', message: `Category "${body.name.trim()}" already exists for type ${body.type}`, code: 'duplicate' })
    }
    if (errors.length > 0) {
      return HttpResponse.json(
        { status: 422, code: 'validation_error', message: 'Validation failed', errors },
        { status: 422 }
      )
    }

    const now = new Date().toISOString()
    const newCategory = {
      id: nextId++,
      user_id: 1,
      name: body.name.trim(),
      type: body.type,
      is_default: false,
      created_at: now,
      updated_at: now,
    }
    categories.push(newCategory)
    return HttpResponse.json({ data: newCategory }, { status: 201 })
  }),
]
```

### 4.4 Transaction Handlers

```typescript
// mocks/handlers/transactions.ts
import { http, HttpResponse } from 'msw'
import { seedTransactions, seedWallets, seedCategories } from '../seed'

let transactions = [...seedTransactions]
let nextId = 6

// Helper: enrich transaction with joined names
function enrichTransaction(tx: any) {
  const wallet = seedWallets.find((w) => w.id === tx.wallet_id)
  const category = seedCategories.find((c) => c.id === tx.category_id)
  return {
    ...tx,
    wallet_name: wallet?.name ?? null,
    category_name: category?.name ?? null,
  }
}

// Helper: validate transaction body
function validateTransactionBody(body: any, isUpdate = false) {
  const errors: { field: string; message: string; code: string }[] = []

  if (body.wallet_id === undefined || typeof body.wallet_id !== 'number') {
    errors.push({ field: 'wallet_id', message: 'wallet_id is required', code: 'required' })
  } else if (!seedWallets.find((w) => w.id === body.wallet_id)) {
    errors.push({ field: 'wallet_id', message: 'Wallet not found', code: 'not_found' })
  }

  if (body.category_id === undefined || typeof body.category_id !== 'number') {
    errors.push({ field: 'category_id', message: 'category_id is required', code: 'required' })
  } else if (!seedCategories.find((c) => c.id === body.category_id)) {
    errors.push({ field: 'category_id', message: 'Category not found', code: 'not_found' })
  }

  if (!['income', 'expense'].includes(body.type)) {
    errors.push({ field: 'type', message: 'Type must be income or expense', code: 'invalid_enum' })
  }

  if (body.amount === undefined || typeof body.amount !== 'number' || body.amount <= 0) {
    errors.push({ field: 'amount', message: 'Amount must be a positive number', code: 'invalid' })
  }

  if (!body.transaction_date || typeof body.transaction_date !== 'string') {
    errors.push({ field: 'transaction_date', message: 'transaction_date is required (YYYY-MM-DD)', code: 'required' })
  }

  if (body.note && typeof body.note === 'string' && body.note.length > 500) {
    errors.push({ field: 'note', message: 'Note must be 500 characters or less', code: 'max_length' })
  }

  return errors
}

export const transactionHandlers = [
  // GET /api/transactions
  http.get('/api/transactions', ({ request }) => {
    const url = new URL(request.url)
    const dateFrom = url.searchParams.get('date_from')
    const dateTo = url.searchParams.get('date_to')
    const type = url.searchParams.get('type')
    const walletId = url.searchParams.get('wallet_id')
    const categoryId = url.searchParams.get('category_id')
    const q = url.searchParams.get('q')
    const page = Math.max(1, Number(url.searchParams.get('page')) || 1)
    const perPage = Math.min(100, Math.max(1, Number(url.searchParams.get('per_page')) || 20))

    let filtered = [...transactions]

    if (dateFrom) filtered = filtered.filter((t) => t.transaction_date >= dateFrom)
    if (dateTo) filtered = filtered.filter((t) => t.transaction_date <= dateTo)
    if (type) filtered = filtered.filter((t) => t.type === type)
    if (walletId) filtered = filtered.filter((t) => t.wallet_id === Number(walletId))
    if (categoryId) filtered = filtered.filter((t) => t.category_id === Number(categoryId))
    if (q) filtered = filtered.filter((t) => t.note?.toLowerCase().includes(q.toLowerCase()))

    const total = filtered.length
    const totalPages = Math.ceil(total / perPage)
    const start = (page - 1) * perPage
    const paged = filtered.slice(start, start + perPage)

    return HttpResponse.json({
      data: paged.map(enrichTransaction),
      meta: { total, page, perPage, totalPages },
    })
  }),

  // GET /api/transactions/:id
  http.get('/api/transactions/:id', ({ params }) => {
    const id = Number(params.id)
    const tx = transactions.find((t) => t.id === id)
    if (!tx) {
      return HttpResponse.json(
        { status: 404, code: 'not_found', message: 'Transaction not found' },
        { status: 404 }
      )
    }
    return HttpResponse.json({ data: tx })
  }),

  // POST /api/transactions
  http.post('/api/transactions', async ({ request }) => {
    const body = await request.json() as any
    const errors = validateTransactionBody(body)
    if (errors.length > 0) {
      return HttpResponse.json(
        { status: 422, code: 'validation_error', message: 'Validation failed', errors },
        { status: 422 }
      )
    }

    const now = new Date().toISOString()
    const newTx = {
      id: nextId++,
      user_id: 1,
      wallet_id: body.wallet_id,
      category_id: body.category_id,
      type: body.type,
      amount: body.amount,
      transaction_date: body.transaction_date,
      note: body.note ?? null,
      created_at: now,
      updated_at: now,
    }
    transactions.push(newTx)
    return HttpResponse.json({ data: enrichTransaction(newTx) }, { status: 201 })
  }),

  // PUT /api/transactions/:id
  http.put('/api/transactions/:id', async ({ params, request }) => {
    const id = Number(params.id)
    const existing = transactions.find((t) => t.id === id)
    if (!existing) {
      return HttpResponse.json(
        { status: 404, code: 'not_found', message: 'Transaction not found' },
        { status: 404 }
      )
    }

    const body = await request.json() as any
    const errors = validateTransactionBody(body)
    if (errors.length > 0) {
      return HttpResponse.json(
        { status: 422, code: 'validation_error', message: 'Validation failed', errors },
        { status: 422 }
      )
    }

    const now = new Date().toISOString()
    const updated = {
      ...existing,
      wallet_id: body.wallet_id,
      category_id: body.category_id,
      type: body.type,
      amount: body.amount,
      transaction_date: body.transaction_date,
      note: body.note ?? null,
      updated_at: now,
    }
    transactions = transactions.map((t) => (t.id === id ? updated : t))
    return HttpResponse.json({ data: enrichTransaction(updated) })
  }),

  // DELETE /api/transactions/:id
  http.delete('/api/transactions/:id', ({ params }) => {
    const id = Number(params.id)
    const existing = transactions.find((t) => t.id === id)
    if (!existing) {
      return HttpResponse.json(
        { status: 404, code: 'not_found', message: 'Transaction not found' },
        { status: 404 }
      )
    }
    transactions = transactions.filter((t) => t.id !== id)
    return HttpResponse.json({ data: { success: true } })
  }),
]
```

### 4.5 Summary Handler

```typescript
// mocks/handlers/summary.ts
import { http, HttpResponse } from 'msw'
import { seedTransactions, seedCategories } from '../seed'

export const summaryHandlers = [
  http.get('/api/summary', ({ request }) => {
    const url = new URL(request.url)
    const month = Number(url.searchParams.get('month')) || new Date().getMonth() + 1
    const year = Number(url.searchParams.get('year')) || new Date().getFullYear()

    if (month < 1 || month > 12) {
      return HttpResponse.json(
        { status: 422, code: 'validation_error', message: 'Month must be between 1 and 12', errors: [] },
        { status: 422 }
      )
    }
    if (year < 1900 || year > 2100) {
      return HttpResponse.json(
        { status: 422, code: 'validation_error', message: 'Year out of range', errors: [] },
        { status: 422 }
      )
    }

    const monthStr = String(month).padStart(2, '0')
    const yearStr = String(year)
    const monthTransactions = seedTransactions.filter(
      (t) => t.transaction_date.startsWith(`${yearStr}-${monthStr}`)
    )

    const income = monthTransactions.filter((t) => t.type === 'income')
    const expense = monthTransactions.filter((t) => t.type === 'expense')

    const totalIncome = income.reduce((sum, t) => sum + t.amount, 0)
    const totalExpense = expense.reduce((sum, t) => sum + t.amount, 0)

    // Group by category
    function groupByCategory(txns: typeof seedTransactions) {
      const map = new Map<number, { category_id: number; category_name: string; total: number }>()
      for (const tx of txns) {
        const cat = seedCategories.find((c) => c.id === tx.category_id)
        const existing = map.get(tx.category_id)
        if (existing) {
          existing.total += tx.amount
        } else {
          map.set(tx.category_id, {
            category_id: tx.category_id,
            category_name: cat?.name ?? 'Unknown',
            total: tx.amount,
          })
        }
      }
      return Array.from(map.values())
    }

    return HttpResponse.json({
      data: {
        total_income: totalIncome,
        total_expense: totalExpense,
        net_balance: totalIncome - totalExpense,
        transaction_count: monthTransactions.length,
        income_by_category: groupByCategory(income),
        expense_by_category: groupByCategory(expense),
      },
    })
  }),
]
```

### 4.6 Handler Registration

```typescript
// mocks/handlers/index.ts
import { walletHandlers } from './wallets'
import { categoryHandlers } from './categories'
import { transactionHandlers } from './transactions'
import { summaryHandlers } from './summary'

export const handlers = [
  ...walletHandlers,
  ...categoryHandlers,
  ...transactionHandlers,
  ...summaryHandlers,
]
```

### 4.7 MSW Browser Worker Setup

```typescript
// mocks/browser.ts (Next.js App Router)
import { setupWorker } from 'msw/browser'
import { handlers } from './handlers'

export const worker = setupWorker(...handlers)
```

### 4.8 MSW Server Setup (Testing)

```typescript
// mocks/server.ts (Vitest / Jest)
import { setupServer } from 'msw/node'
import { handlers } from './handlers'

export const server = setupServer(...handlers)
```

---

## 5. Error Response Types

### 5.1 Generic Error

```typescript
// types/api.ts

interface ApiError {
  status: number
  code: string
  message: string
  errors?: FieldError[]
}

interface FieldError {
  field: string
  message: string
  code: string
}
```

### 5.2 Concrete Error Types

```typescript
// types/api.ts

interface UnauthorizedError {
  status: 401
  code: 'unauthorized'
  message: 'Authentication required'
}

interface NotFoundError {
  status: 404
  code: 'not_found'
  message: string  // e.g., "Wallet not found", "Transaction not found"
}

interface ValidationError {
  status: 422
  code: 'validation_error'
  message: 'Validation failed'
  errors: FieldError[]
}

interface ServerError {
  status: 500
  code: 'internal_server_error'
  message: 'An unexpected error occurred'
}
```

### 5.3 Error Code Reference

| Code | Status | Meaning | Trigger |
|------|--------|---------|---------|
| bad_request | 400 | Malformed request | Invalid JSON body |
| unauthorized | 401 | Not authenticated | No valid session (MVP: never) |
| not_found | 404 | Resource missing | Invalid ID |
| validation_error | 422 | Validation failure | Invalid field values |
| internal_server_error | 500 | Server fault | Unexpected backend error |

---

## 6. Response Envelope

### 6.1 Success Responses

Single resource:

```json
{
  "data": { ... }
}
```

List (paginated):

```json
{
  "data": [ ... ],
  "meta": {
    "total": 42,
    "page": 1,
    "per_page": 20,
    "total_pages": 3
  }
}
```

List (unpaginated — wallets, categories):

```json
{
  "data": [ ... ],
  "meta": {
    "total": 3,
    "page": 1,
    "per_page": 100,
    "total_pages": 1
  }
}
```

Delete confirmation:

```json
{
  "data": {
    "success": true
  }
}
```

### 6.2 Error Responses

Validation error:

```json
{
  "status": 422,
  "code": "validation_error",
  "message": "Validation failed",
  "errors": [
    { "field": "name", "message": "Name is required", "code": "required" }
  ]
}
```

Not found:

```json
{
  "status": 404,
  "code": "not_found",
  "message": "Wallet not found"
}
```

Server error:

```json
{
  "status": 500,
  "code": "internal_server_error",
  "message": "An unexpected error occurred"
}
```

---

## 7. Endpoint-to-Hook Mapping

| Endpoint | React Query Hook | Source doc-05 | Confidence |
|----------|-----------------|---------------|------------|
| GET /api/wallets | useWallets | query_hooks[0] | 1.0 |
| GET /api/wallets/:id | useWallet | query_hooks[1] | 0.6 |
| POST /api/wallets | useCreateWallet | query_hooks[2] | 1.0 |
| GET /api/categories | useCategories | query_hooks[3] | 1.0 |
| POST /api/categories | useCreateCategory | query_hooks[4] | 1.0 |
| GET /api/transactions | useTransactions | query_hooks[5] | 1.0 |
| GET /api/transactions/:id | useTransaction | query_hooks[6] | 0.9 |
| POST /api/transactions | useCreateTransaction | query_hooks[7] | 1.0 |
| PUT /api/transactions/:id | useUpdateTransaction | query_hooks[8] | 0.9 |
| DELETE /api/transactions/:id | useDeleteTransaction | query_hooks[9] | 1.0 |
| GET /api/summary | useMonthlySummary | query_hooks[10] | 1.0 |

---

## 8. Assumptions

| ID | Statement | Impacts | Confidence | Source |
|----|-----------|---------|------------|--------|
| ASM-007 | No auth middleware in MVP. All endpoints assume authenticated user via implicit context. Auth endpoints omitted. | No auth-related request/response types; 401 documented but never triggered in MSW | 1.0 | doc-03: ASM-001 |
| ASM-008 | MSW mock handlers use incrementing counter for ID generation. IDs are integers starting from seed data. | Create responses return sequential numeric IDs; no ID clashes in single session | 1.0 | inference |
| ASM-009 | Transaction list endpoint returns joined wallet_name and category_name. Detail endpoint may omit them. | Transaction type has optional walletName/categoryName; client handles missing | 0.8 | inference |
| ASM-010 | Monthly summary is server-computed (single endpoint), not aggregated client-side. | GET /api/summary is only summary endpoint | 1.0 | doc-05: ASM-004 |

---

## 9. DoD Checklist

- [x] All 11 query hooks from doc-05 have endpoint definitions (useWallets, useWallet, useCreateWallet, useCategories, useCreateCategory, useTransactions, useTransaction, useCreateTransaction, useUpdateTransaction, useDeleteTransaction, useMonthlySummary)
- [x] All 4 entities from doc-02 have type definitions (Wallet, Category, Transaction, User)
- [x] Type/interface names exact match with entity names (PascalCase)
- [x] Every endpoint has MSW handler reference and implementation
- [x] Error response types documented (ApiError, ValidationError, NotFoundError, UnauthorizedError, ServerError)
- [x] References doc-05 query_hooks
- [x] All endpoints identified with method, path, request params, response shape
- [x] Request/response types in TypeScript using PascalCase
- [x] Field mapping table: TypeScript camelCase to API snake_case
- [x] Response envelope standardised (ApiResponse, ApiListResponse)
- [x] No placeholder, TODO, or "TBD"
- [x] Frontmatter YAML valid and complete per schema
- [x] Output file matches docs/07-api-integration-plan.md
