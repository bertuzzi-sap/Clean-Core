# VF01 ZVIC – Automatic Header Text ZSUP (TESTO LIBERO NC EIE)

## 1. Business Requirement

When creating a billing document (VF01) of type **ZVIC**, the custom header text field **"TESTO LIBERO NC EIE"** must be automatically populated with the fixed text **`Fatturato`**.

| Field | Value |
|---|---|
| Text object (`TDOBJECT`) | `VBBK` |
| Text ID (`TDID`) | `ZSUP` |
| Text name (`TDNAME`) | Billing document number (`VBELN`) |
| Language | Italian (`I`) |

The text must be written **only on creation** — never on subsequent change/update operations.

---

## 2. Extension Point

### Why BAdI `BADI_BILLINGDOC_PROCESS` / method `CHANGE_BEFORE_UPDATE`?

| Criterion | Detail |
|---|---|
| **BAdI** | `BADI_BILLINGDOC_PROCESS` |
| **Enhancement Spot** | `BILLING_DOCUMENT_PROCESS` |
| **Interface** | `IF_EX_BADI_BILLINGDOC_PROCESS` |
| **Method** | `CHANGE_BEFORE_UPDATE` |
| **S/4HANA 2023 compatible** | ✅ Yes |
| **Obsolete alternative** | ~~User Exit `RV60AFZB` / FORM `USEREXIT_FILL_VBRK_VBRP`~~ |

`CHANGE_BEFORE_UPDATE` is the correct hook because:

1. At this point the billing document number (`VBELN`) is **already assigned**.
2. The code executes in the **same LUW** as the billing document, so `SAVE_TEXT` (called without `SAVEMODE_DIRECT`) is automatically enqueued in the **update task** together with the document — no explicit `COMMIT WORK` is needed.
3. The method receives `CT_VBRK` (billing header table), which provides `VBELN` and `FKART` to filter on document type `ZVIC`.

---

## 3. Tables and Structures Involved

| Object | Type | Purpose |
|---|---|---|
| `VBRK` | DB Table | Billing document header – provides `VBELN`, `FKART` |
| `STXH` | DB Table | SAPscript text header – used to verify existence (idempotency guard) |
| `STXL` | DB Table | SAPscript text lines – stores actual text content |
| `THEAD` | Structure | Header parameter for FM `SAVE_TEXT` |
| `TLINE` / `TLINE_TAB` | Structure / Type | Text lines for FM `SAVE_TEXT` |
| `SAVE_TEXT` | Function Module | Persists the long text to `STXH`/`STXL` |
| `READ_TEXT` | Function Module | Reads persisted text (used in verification report) |

---

## 4. Implementation Steps

### 4.1 Create the Implementation Class (SE24)

1. Open **SE24**, enter class name `ZCL_IM_BILLDOC_ZVIC_TEXT`, click **Create**.
2. Set *Class type*: **OLE-Compatible Class** (regular class).
3. Paste the content of `src/sd/billing/zcl_im_billdoc_zvic_text.abap`.
4. **Activate** the class (`Ctrl+F3`).

### 4.2 Create the BAdI Implementation (SE19)

1. Open **SE19**, search for Enhancement Spot `BILLING_DOCUMENT_PROCESS`.
2. Click **Create BAdI Implementation**.
3. Enter implementation name: `ZIM_BILLDOC_ZVIC_TEXT`.
4. Assign the implementing class: `ZCL_IM_BILLDOC_ZVIC_TEXT`.
5. Set the filter (if required): *Billing Type = ZVIC* — or leave unfiltered and rely on the `WHERE fkart = gc_billing_type` clause in the code.
6. **Activate** the implementation and set its status to **Active**.

### 4.3 Verify Text Configuration (SOTR / SE63)

Confirm that text ID `ZSUP` is registered for text object `VBBK` in the system's text ID customising (transaction **VOTX** or SE63).

### 4.4 Functional Test (VF01)

1. Create a billing document of type **ZVIC** via VF01.
2. After saving, navigate to *Goto → Header → Texts*.
3. The text "TESTO LIBERO NC EIE" should display **`Fatturato`**.

### 4.5 Technical Verification (SE38 / verification report)

Run report `ZCHECK_ZVIC_TEXT` (see `src/sd/billing/zcheck_zvic_text.abap`) with the created billing document number to confirm the text is present in `STXH`/`STXL`.

---

## 5. Architecture Diagram

```
VF01 (Create billing document – type ZVIC)
        │
        ▼
┌───────────────────────────────────────────┐
│  BADI_BILLINGDOC_PROCESS                  │
│  Enhancement Spot: BILLING_DOCUMENT_PROCESS│
│  Method: CHANGE_BEFORE_UPDATE             │
└──────────────────┬────────────────────────┘
                   │  CT_VBRK (billing headers)
                   ▼
        Filter: FKART = 'ZVIC'
                   │
                   ▼
        ┌──────────────────────┐
        │  text_already_exists │ ──► SELECT SINGLE FROM STXH
        └──────────┬───────────┘          (idempotency guard)
                   │ abap_false
                   ▼
        AUTHORITY-CHECK S_DEVELOP
                   │
                   ▼
        ┌──────────────────────┐
        │     SAVE_TEXT        │ ──► STXH / STXL
        │  insert = abap_true  │     OBJECT = 'VBBK'
        │  (no overwrite)      │     NAME   = VBELN
        └──────────────────────┘     ID     = 'ZSUP'
                                     TEXT   = 'Fatturato'
```

---

## 6. Key Implementation Notes

### `insert = abap_true` in `SAVE_TEXT`
Passing `insert = abap_true` instructs the function module to write the text **only if it does not yet exist**. Combined with the `STXH` pre-check, this makes the solution **fully idempotent** — running the BAdI twice on the same document has no side effects.

### STXH Idempotency Guard
The `text_already_exists` method performs a `SELECT SINGLE @abap_true FROM stxh` with a precise four-field WHERE clause. This single-row lookup is HANA-optimised and prevents duplicate text creation even in edge cases where `SAVE_TEXT` with `insert = abap_true` might behave unexpectedly.

### Update Task Behaviour
`SAVE_TEXT` called **without** `SAVEMODE_DIRECT = 'X'` does **not** write immediately to the database. Instead, it registers the write in the **update task** of the current LUW. The text is therefore committed atomically together with the billing document — ensuring data consistency and avoiding orphaned texts if the billing posting is rolled back.

### Error Handling
Errors inside `write_header_text` are caught at the `CHANGE_BEFORE_UPDATE` level with `CATCH cx_root`. They are logged as `TYPE 'W'` (warning) messages, which **never block** the billing posting. This follows the principle of least surprise for a text population enhancement.

### Security
An `AUTHORITY-CHECK` on object `S_DEVELOP` with activity `02` (Change) is included in `write_header_text`. Adjust the authority object to a more business-specific object (e.g., `V_VBRK_AAT` for billing) if required by your security concept.

---

## 7. Files Delivered

| File | Description |
|---|---|
| `src/sd/billing/zcl_im_billdoc_zvic_text.abap` | BAdI implementation class |
| `src/sd/billing/zcl_test_billdoc_zvic_text.abap` | ABAP Unit test class |
| `src/sd/billing/zcheck_zvic_text.abap` | Verification report |
| `docs/sd/billing/VF01_ZVIC_header_text_ZSUP.md` | This document |
