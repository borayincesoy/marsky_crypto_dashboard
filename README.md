# Marsky Crypto Dashboard

A professional, SaaS-style cryptocurrency dashboard application built with Flutter. This project was developed as a part of the Marsky Flutter Code Challenge, focusing on modern UI/UX, clean architecture, and robust state management.

## 🚀 Key Features

-   **Authentication System:** Secure registration and login powered by **Supabase Auth**.
-   **Session Management:** Persistent login sessions and secure logout with a confirmation dialog.
-   **Real-time Crypto Data:** Live data fetching from **CoinRanking API**.
-   **Advanced Navigation:** Dual-tab navigation (Home & Favorites) with a custom Page Picker for quick access.
-   **Pagination & Sorting:** Efficient data loading with pagination and 5 different sorting criteria (Price, Market Cap, 24h Volume, Change Rate, Listing Date).
-   **iOS-Style Experience:** Smooth Modal Bottom Sheets for coin details and sleek UI transitions.
-   **Interactive Charts:** Beautifully rendered price history graphs using **fl_chart**.
-   **Persistent Favorites:** Locally stored favorite list using **Hive**, ensuring data stays even after app restarts (fully compatible with Chrome/Web).
-   **Error Handling:** Professional English error notifications for all edge cases (API, connectivity, auth).

## 🛠 Tech Stack

-   **State Management:** [BLoC (flutter_bloc)](https://pub.dev/packages/flutter_bloc)
-   **Backend/Auth:** [Supabase](https://supabase.com/)
-   **Local Database:** [Hive](https://pub.dev/packages/hive)
-   **Networking:** [Dio](https://pub.dev/packages/dio)
-   **Charts:** [fl_chart](https://pub.dev/packages/fl_chart)
-   **Architecture:** Clean Architecture (Data, Domain, Presentation)

## 🏗 Architecture

The project follows **Clean Architecture** principles to ensure maintainability and testability:

-   **Domain Layer:** Contains Business Logic, Entities, and Use Cases. It's independent of any other layer.
-   **Data Layer:** Contains Repository implementations, Data Sources (Remote/Local), and Models.
-   **Presentation Layer:** Contains UI Widgets, Pages, and BLoCs for state management.

## 🧪 Testing

The project includes **Unit Tests** for the core business logic:
-   `CryptoBloc` tests cover successful data fetching, sorting, and error handling scenarios.
-   Uses `bloc_test` and `mocktail` for robust testing without network dependencies.

## 🏁 Getting Started

### Prerequisites

-   Flutter SDK (^3.9.2)
-   A Supabase project (URL and Anon Key required in `lib/env.dart`)

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/borayincesoy/marsky_crypto_dashboard.git
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Configure your environment:
    Open `lib/env.dart` and fill in your Supabase and CoinRanking API credentials.
4.  Run the app:
    ```bash
    flutter run
    ```

## 👨‍💻 Author

**Boray İnceboy**
-   GitHub: [@borayincesoy](https://github.com/borayincesoy)
