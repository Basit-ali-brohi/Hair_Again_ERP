# Hair Again ERP — Transplant & Care Clinic Management System

A comprehensive, professional-grade **Enterprise Resource Planning (ERP)** desktop application built with **Flutter**, purpose-built for hair transplant and cosmetic care clinics.

---

## Overview

Hair Again ERP is a full-featured clinic management solution that streamlines every aspect of running a hair transplant and care practice — from patient intake and surgical scheduling through to billing, inventory, staff HR, and business analytics.

The application targets **Windows desktop** as the primary platform, delivering a fast, native experience with a sleek Obsidian & Gold design theme.

---

## Features

### Patient & CRM
- Complete patient profiles with Norwood scale classification and hair loss journey tracking
- Patient search, filtering, and segmentation
- Consultation history and progress notes

### Appointments & Scheduling
- Calendar-based appointment booking and management
- Surgeon and treatment assignment
- Status tracking (Confirmed / Pending / Cancelled)

### Treatment Plans & Sessions
- Multi-session treatment plan creation and tracking
- Per-session progress with cost breakdown
- Visual progress bar per plan

### Point of Sale (POS) & Invoicing
- Full POS interface with product/service cart
- Hold & restore sales
- Refund processing with reason tracking
- End-of-Day (EOD) summary report
- Invoice generation and payment recording

### Inventory Management
- Stock items with category, unit, reorder level tracking
- Stock movements log (purchase, usage, adjustment)
- Low-stock and out-of-stock alerts

### Hair Patch Module
- Dedicated patch order management
- Order status lifecycle (Design → Production → Delivered)

### Finance & Accounts
- Income and expense entry with categorization
- Budget vs. actual tracking
- Cash flow visualization

### Staff & HR
- Staff profiles, roles, and department assignment
- Leave management (requests, approval, balance)
- Payroll summary

### Leads & CRM Pipeline
- Lead pipeline with stages (New → Consultation → Treatment → Closed)
- Lead source attribution
- Conversion tracking

### Marketing
- Campaign management (SMS, Email, Social)
- Coupon / discount code management with usage limits
- Marketing analytics

### Loyalty & Referrals
- Points-based loyalty program
- Membership tier management (Silver / Gold / Platinum)
- Referral tracking and rewards

### Products & Services Catalog
- Product listings with pricing and stock linkage
- Service catalog with duration and cost

### Reports & Analytics
- Patient reports (Norwood distribution, status breakdown)
- Financial reports (revenue, expenses, cash flow)
- Inventory reports (stock value, movements)
- Marketing reports (lead sources, campaign ROI)
- Appointment and treatment session analytics

### Settings & Configuration
- Clinic profile management
- Theme switching (Dark / Light) with Gold accent
- User roles and access control matrix
- Activity logs and login history
- Security settings and session management
- Notification preferences

### Company Management
- Multi-branch department and branch setup
- Vendor management

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart) |
| Platform | Windows Desktop (primary) |
| State Management | Custom `AppState` singleton with `ChangeNotifier` |
| Persistence | `shared_preferences` (local JSON storage) |
| Theming | Custom `AppPalette` with Obsidian/Gold and Clinical Light modes |
| Charts | Custom canvas-drawn charts (no third-party chart lib) |
| PDF | `pdf` + `printing` packages |

---

## Project Structure

```
lib/
├── main.dart
├── core/
│   ├── core.dart                  # Barrel export
│   ├── state/app_state.dart       # Global store + navigation
│   ├── theme/
│   │   ├── app_palette.dart       # Color palettes
│   │   └── app_scope.dart         # InheritedNotifier (instant theme flip)
│   ├── utils/
│   │   ├── formatters.dart
│   │   ├── dialogs.dart
│   │   ├── storage_service.dart   # shared_preferences wrapper
│   │   ├── pdf_service.dart
│   │   └── pdf_viewer.dart
│   └── widgets/
│       ├── common.dart            # Shared UI components
│       ├── charts.dart            # Custom chart widgets
│       ├── shell.dart             # App shell & navigation sidebar
│       └── app_root.dart
└── modules/
    ├── auth/
    ├── dashboard/
    ├── crm/
    ├── appointments/
    ├── treatment/
    ├── pos_inventory/
    ├── inventory/
    ├── hair_patch/
    ├── finance/
    ├── staff/
    ├── hr/
    ├── leads/
    ├── marketing/
    ├── membership/
    ├── loyalty/
    ├── products/
    ├── reports/
    ├── company/
    ├── user_roles/
    └── settings/
```

---

## Getting Started

### Prerequisites

- Flutter SDK 3.x
- Dart 3.x
- Windows 10 or later (for desktop build)

### Setup

```bash
# Clone the repository
git clone https://github.com/Basit-ali-brohi/Hair_Again_ERP.git
cd Hair_Again_ERP

# Install dependencies
flutter pub get

# Run on Windows desktop
flutter run -d windows

# Build release executable
flutter build windows --release
```

---

## Design

The UI follows a **Clinic-Premium** design language:

- **Dark mode**: Obsidian background (`#111814`) with Gold (`#C9A84C`) accents
- **Light mode**: Clinical white with deep green (`#0C4A26`) brand color
- Minimal border radii for a sharp, professional desktop feel
- Consistent `Panel` cards, `FilterBar` toolbars, and `FullWidthDataTable` grids across all modules

---

## License

This project is proprietary software developed for **Hair Again — Transplant & Care Clinic**, Karachi, Pakistan.

---

*Hair Again ERP — Built for professionals, by professionals.*
