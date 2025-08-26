//
//  CustomPaywallView.swift
//  CoolSwiftUIAnimations
//
//  Created by Aykut Güven on 26.08.25.
//

import StoreKit
import SwiftUI

// To use SwiftUI StoreKit APIs, we need to configure in-app urchases on App Store Connect.
// For development, though, we can use StoreKit Configuration files.
// We create a config file and then add it in the scheme.
//
// The Group ID in the config file is important
struct CustomPaywallView: View {
    static var productIDs: [String] {
        ["pro_weekly", "pro_monthly", "pro_yearly"]
    }

    @State private var isLoadingComplete: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            //        SubscriptionStoreView(groupID: "368A2673")
            SubscriptionStoreView(productIDs: Self.productIDs, marketingContent: {
                marketingContent()
            })
            .subscriptionStoreControlStyle(.pagedProminentPicker, placement: .bottomBar)
            .subscriptionStorePickerItemBackground(.ultraThinMaterial)
            .storeButton(.visible, for: .restorePurchases)
            // Hides the terms and conditions button
            .storeButton(.hidden, for: .policies)
            .onInAppPurchaseStart { product in
                print("Purchase started for: \(product.displayName)")
            }
            .onInAppPurchaseCompletion { product, result in
                switch result {
                case .success(let result):
                    switch result {
                    case .success(let verification):
                        switch verification {
                        case .unverified(let transaction, let error):
                            print("Transaction unverified: \(transaction), error: \(error.localizedDescription)")
                        case .verified(let transaction):
                            print("Transaction verified: \(transaction)")
                        }
                        print("Product purchased: \(product.displayName)")
                    case .pending:
                        print("Purchase pending for: \(product.displayName)")
                    case .userCancelled:
                        print("Purchase cancelled for: \(product.displayName)")
                    @unknown default:
                        print("Unknown result for: \(product.displayName)")
                    }
                case .failure(let error):
                    print("Purchase failed for: \(product.displayName), error: \(error.localizedDescription)")
                }
            }
            // Check membership status with Group ID
            .subscriptionStatusTask(for: "368A2673") { state in
                if let result = state.value {
                    let premiumUser = result.filter { $0.state == .subscribed }.isEmpty == false
                    print("Is premium user: \(premiumUser)")
                }
            }

            // Privacy policies, terms and conditions etc.
            HStack(spacing: 3) {
                Link("Terms and Conditions", destination: URL(string: "https://www.apple.com")!)
                Text("and")
                Link("Privacy Policy", destination: URL(string: "https://www.apple.com")!)
            }
            .font(.caption2)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // SubscriptionStoreView has its own loading indicator and shows it until products are
        // fetched. To hide it, we can use the isLoadingComplete state variable.
        .opacity(isLoadingComplete ? 1 : 0)
        .background(backdropView())
        // Adding our own loading indicator instead
        .overlay {
            if !isLoadingComplete {
                ProgressView()
                    .font(.largeTitle)
            }
        }
        // Making the opacity change much smoother
        .animation(.easeInOut, value: isLoadingComplete)
        // Retrieves products from the App Store. We can use this to fetch our products
        // and create our own UI as well.
        .storeProductsTask(for: Self.productIDs) { @MainActor collection in
            if let products = collection.products, products.count == Self.productIDs.count {
                try? await Task.sleep(for: .seconds(0.1))
                isLoadingComplete = true
            }
        }
        .environment(\.colorScheme, .dark)
        .tint(.white)
    }

    @ViewBuilder
    func backdropView() -> some View {
        GeometryReader {
            let size = $0.size

            Image(.autumnRiver)
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .scaleEffect(1.5)
                .blur(radius: 10)
                .overlay {
                    Rectangle()
                        .fill(.black.opacity(0.2))
                }
                .ignoresSafeArea()
        }
    }

    // Marketing Content View
    @ViewBuilder
    func marketingContent() -> some View {
        VStack(spacing: 15) {
            Spacer()

            VStack(spacing: 6) {
                Text("App Name")
                    .font(.title3)

                Text("Membership")
                    .font(.largeTitle.bold())

                Text("Some dummy text")
                    .font(.callout)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(.white)
            .padding(.vertical, 10)
        }
        .padding([.horizontal, .bottom], 15)
    }
}

#Preview {
    CustomPaywallView()
}
