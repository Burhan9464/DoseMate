# DoseMate REST API Specification (v1)

Base URL: `/api/v1`  
All protected endpoints require:
```http
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

---

## 1. Standard Response Formats

### 1.1 Success Envelope
```json
{
  "data": { ... },
  "message": "Operation completed successfully"
}
```

### 1.2 Error Envelope
```json
{
  "code": "DOSE_ALREADY_COMPLETED",
  "message": "This dose has already been taken.",
  "details": null,
  "timestamp": "2026-10-04T12:00:00.000Z"
}
```

### 1.3 Standard Machine-Readable Error Codes
The client **must** key off the `code` attribute, never human-readable strings:

| Error Code | HTTP Status | Description |
|---|---|---|
| `VALIDATION_FAILED` | 400 | Request body failed validation rules (field errors in `details`) |
| `INVALID_CREDENTIALS` | 401 | Email or password incorrect |
| `UNAUTHORIZED` | 401 | Missing or invalid/expired JWT token |
| `FORBIDDEN` | 403 | User does not have access to requested resource |
| `RESOURCE_NOT_FOUND` | 404 | Medicine, Dose, or User ID not found |
| `DUPLICATE_EMAIL` | 409 | An account with this email already exists |
| `DOSE_ALREADY_COMPLETED` | 409 | Dose has already been marked TAKEN |
| `DOSE_NOT_PENDING` | 409 | Dose is not in a state that permits this action |
| `UNDO_WINDOW_EXPIRED` | 400 | Allowed undo window has passed |
| `INSUFFICIENT_INVENTORY` | 400 | Stock would drop below zero |
| `MEDICINE_ALREADY_PAUSED` | 409 | Medicine is already in PAUSED status |
| `MEDICINE_ALREADY_ACTIVE` | 409 | Medicine is already in ACTIVE status |
| `INTERNAL_SERVER_ERROR` | 500 | Unhandled backend exception |

---

## 2. Authentication APIs

### 2.1 Register
- **POST** `/auth/register`
- **Public**
- **Request Body:**
```json
{
  "fullName": "Jane Doe",
  "email": "jane@example.com",
  "password": "SecurePassword123!",
  "dateOfBirth": "1995-06-15",
  "gender": "FEMALE",
  "country": "United States",
  "timezone": "America/New_York"
}
```
- **Response (201 Created):**
```json
{
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsIn...",
    "tokenType": "Bearer",
    "expiresIn": 86400,
    "user": {
      "id": 1,
      "fullName": "Jane Doe",
      "email": "jane@example.com",
      "dateOfBirth": "1995-06-15",
      "gender": "FEMALE",
      "country": "United States",
      "timezone": "America/New_York",
      "onboardingCompleted": false,
      "guideCompleted": false
    }
  },
  "message": "User registered successfully"
}
```

### 2.2 Login
- **POST** `/auth/login`
- **Public**
- **Request Body:**
```json
{
  "email": "jane@example.com",
  "password": "SecurePassword123!"
}
```
- **Response (200 OK):** Same payload as Register.

### 2.3 Logout
- **POST** `/auth/logout`
- **Protected**
- **Response (200 OK):**
```json
{
  "data": null,
  "message": "Logged out successfully"
}
```

---

## 3. User & Profile APIs

### 3.1 Get Profile
- **GET** `/users/me`
- **Protected**
- **Response (200 OK):** User entity JSON.

### 3.2 Update Profile
- **PUT** `/users/me`
- **Protected**
- **Request Body:**
```json
{
  "fullName": "Jane Smith",
  "dateOfBirth": "1995-06-15",
  "gender": "FEMALE",
  "country": "Canada",
  "timezone": "America/Toronto"
}
```
- **Response (200 OK):** Updated user entity JSON.

### 3.3 Update App Progress Flags
- **PATCH** `/users/me/flags`
- **Protected**
- **Request Body:**
```json
{
  "onboardingCompleted": true,
  "guideCompleted": true
}
```

---

## 4. Medicine APIs

### 4.1 List Medicines
- **GET** `/medicines`
- **Protected**
- **Query Params:** `status` (optional: `ACTIVE`, `PAUSED`, or omit for all non-deleted)
- **Response (200 OK):** Array of Medicine cards with schedule and inventory summary.

### 4.2 Get Medicine Details
- **GET** `/medicines/{id}`
- **Protected**
- **Response (200 OK):** Full medicine object with full schedule and inventory details.

### 4.3 Create Medicine
- **POST** `/medicines`
- **Protected**
- **Request Body:**
```json
{
  "name": "Amoxicillin",
  "dosageValue": 500.0,
  "dosageUnit": "mg",
  "type": "CAPSULE",
  "startDate": "2026-10-05",
  "endDate": "2026-10-15",
  "ongoing": false,
  "instructions": "Take with food",
  "schedule": {
    "frequencyMode": "MULTIPLE_DAILY",
    "days": ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"],
    "times": ["08:00:00", "20:00:00"]
  },
  "inventory": {
    "quantity": 20,
    "unit": "capsules",
    "lowStockThreshold": 4
  }
}
```
- **Response (201 Created):** Full created medicine representation.

### 4.4 Update Medicine
- **PUT** `/medicines/{id}`
- **Protected**
- **Request Body:** Same schema as Create Medicine.
- **Behavior:** Updates future schedules without modifying historical dose records.

### 4.5 Pause Medicine
- **PATCH** `/medicines/{id}/pause`
- **Protected**
- **Behavior:** Cancels future pending doses from current time onwards.

### 4.6 Resume Medicine
- **PATCH** `/medicines/{id}/resume`
- **Protected**
- **Behavior:** Re-generates pending doses starting from current time onwards.

### 4.7 Delete Medicine
- **DELETE** `/medicines/{id}`
- **Protected**
- **Behavior:** Soft-deletes medicine (`status = DELETED`), clears future pending doses, preserves historical dose records.

---

## 5. Dose APIs

### 5.1 Get Today's Doses
- **GET** `/doses/today`
- **Protected**
- **Response (200 OK):**
```json
{
  "data": [
    {
      "id": 101,
      "medicineId": 1,
      "medicineName": "Amoxicillin",
      "dosage": "500 mg",
      "type": "CAPSULE",
      "scheduledAt": "2026-10-05T08:00:00.000Z",
      "status": "TAKEN",
      "actedAt": "2026-10-05T08:05:12.000Z"
    },
    {
      "id": 102,
      "medicineId": 1,
      "medicineName": "Amoxicillin",
      "dosage": "500 mg",
      "type": "CAPSULE",
      "scheduledAt": "2026-10-05T20:00:00.000Z",
      "status": "PENDING",
      "actedAt": null
    }
  ],
  "message": "Today's doses retrieved"
}
```

### 5.2 Mark Dose Taken (Drag-the-Pill Transaction)
- **POST** `/doses/{id}/taken`
- **Protected**
- **Transactional:** Atomically updates dose to `TAKEN` and decrements `inventory.quantity` by 1.
- **Idempotency:** If already `TAKEN`, returns HTTP 409 `DOSE_ALREADY_COMPLETED` without decrementing inventory.
- **Response (200 OK):**
```json
{
  "data": {
    "dose": {
      "id": 102,
      "status": "TAKEN",
      "actedAt": "2026-10-05T20:01:23.000Z"
    },
    "remainingInventory": 19,
    "isLowStock": false
  },
  "message": "Dose recorded as taken"
}
```

### 5.3 Mark Dose Skipped
- **POST** `/doses/{id}/skipped`
- **Protected**
- **Behavior:** Updates dose to `SKIPPED`. Inventory remains unchanged.
- **Response (200 OK):**
```json
{
  "data": {
    "id": 102,
    "status": "SKIPPED",
    "actedAt": "2026-10-05T20:01:45.000Z"
  },
  "message": "Dose skipped"
}
```

### 5.4 Undo Skip
- **POST** `/doses/{id}/undo-skip`
- **Protected**
- **Behavior:** Reverts a `SKIPPED` dose back to `PENDING` if within the allowed window (e.g. 15 minutes).
- **Response (200 OK):** Reverted dose object.

### 5.5 Medication History
- **GET** `/doses/history`
- **Protected**
- **Query Params:**
  - `status` (`ALL`, `TAKEN`, `SKIPPED`, `MISSED`)
  - `search` (medicine name search)
  - `startDate` (ISO-8601 date)
  - `endDate` (ISO-8601 date)
  - `page` (default: 0)
  - `size` (default: 20)
- **Response (200 OK):** Pageable history grouped by date.

---

## 6. Inventory APIs

### 6.1 Get Inventory
- **GET** `/medicines/{id}/inventory`
- **Protected**

### 6.2 Manual Inventory Correction
- **PATCH** `/medicines/{id}/inventory`
- **Protected**
- **Request Body:**
```json
{
  "quantity": 18
}
```

### 6.3 Refill Inventory
- **POST** `/medicines/{id}/inventory/refill`
- **Protected**
- **Request Body:**
```json
{
  "refillAmount": 30
}
```

---

## 7. Dashboard API

### 7.1 Aggregate Dashboard Data
- **GET** `/dashboard`
- **Protected**
- **Response (200 OK):**
```json
{
  "data": {
    "greeting": "Good evening, Jane",
    "dailyProgress": {
      "takenDoses": 1,
      "totalScheduledDoses": 2,
      "percentage": 50,
      "skippedDoses": 0
    },
    "currentDose": {
      "id": 102,
      "medicineId": 1,
      "medicineName": "Amoxicillin",
      "dosage": "500 mg",
      "type": "CAPSULE",
      "scheduledAt": "2026-10-05T20:00:00.000Z",
      "status": "PENDING",
      "priority": "DUE_NOW"
    },
    "nextUp": {
      "medicineName": "Vitamin D3",
      "dosage": "1000 IU",
      "scheduledAt": "2026-10-06T08:00:00.000Z"
    },
    "needsAttention": [
      {
        "type": "LOW_INVENTORY",
        "medicineId": 1,
        "medicineName": "Amoxicillin",
        "remaining": 3,
        "threshold": 4,
        "message": "Only 3 capsules left (below threshold of 4)"
      }
    ]
  },
  "message": "Dashboard data retrieved"
}
```
