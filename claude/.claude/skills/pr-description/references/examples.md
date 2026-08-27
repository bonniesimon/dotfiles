# Worked examples

The "before" bodies below are real merged PRs from `glomopay_service`. The
"after" bodies are rewrites showing what the rules ask for. Both are included
deliberately: the failures are the common ones.

---

## 1. Diff narration dressed as a description

**Before** (PR #4313, abridged). Four bullets, each one a code change:

> The TIN was gated on `tin_available`, a key no form collects, so the guard
> fired on every render and blanked every TIN. It now gates on
> `tax_resident_yes_no` plus `identification_type`.
> Identification Type was labelled from the nominee's document list
> (`IDENTITY_TYPES`) rather than the tax-residency one (`IDENTIFICATION_TYPES`),
> so it never matched and always printed empty.
> The `other` branch (`doc_type` / `doc_id`) had nowhere to print. It now fills
> the same pair of cells as a TIN...
> The KYC matrix hard-coded every column but the first to blank...

Why it fails: every bullet names a constant or key and says what it now does.
That is the diff. A reviewer opening the Files tab learns all of it in less time
than reading the paragraph.

**After:**

> - Jira: https://glomopay.atlassian.net/browse/KAN-8043
>
> ## Change Description
> The TATA eSign template read KYC keys the forms never write, so answered
> fields printed blank on a signed regulatory document. Realigned the template
> and the spec fixture to the keys the forms actually produce.
>
> Row counts and reserved heights are unchanged, so the Digio sign coordinates
> still land on the same pages.

The last line survives because it is a verified fact a reviewer would otherwise
have to check by hand. Not speculation, and not visible in the diff.

---

## 2. Imagined risk, and a footer

**Before** (PR #4323, abridged):

> **Worth a look before approving:** the name comes from
> `kyc_record.business.name`, which is the GlomoPay merchant, and it prints
> against TATA's own HSBC account number. If that cell is meant to name the
> account's holder rather than the merchant... Confirmed as the intended source,
> but flagging it since this is a signed regulatory document.
>
> Generated with Claude Code

Two failures. The paragraph raises a concern and then says it was already
confirmed, so it is not an open decision and does not belong in the body. And
the footer is banned outright.

**After:**

> - Jira: KAN-000, no ticket raised yet.
>
> ## Change Description
> The Account Name cell on the eSign collection-account block declared `nil`, so
> it printed as an empty rule next to a populated account number. Fills it from
> the business on the KYC record.
>
> Split out of #4313, which covers the rest of the form.

---

## 3. A one-line body is complete

Not every PR needs more.

> - Jira: https://glomopay.atlassian.net/browse/KAN-8057
>
> ## Change Description
> Falls back to DigiLocker for the primary applicant's Aadhaar when the eSign
> payload omits it.

---

## 4. When "Confirm before merge" is earned

Only when a real decision is still open and the reviewer is the one to make it.

> **Confirm before merge:** the joint-holder PEP row reads a key that ships in a
> separate form change. Until that merges the row prints unticked. Merging this
> first is safe; confirm you want that ordering.

Not earned when: you already checked and it was fine; you are listing things you
did not test; you are hedging.
