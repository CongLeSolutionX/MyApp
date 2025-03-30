//
//  GoogleAdMobIntegrationView2.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI
import GoogleMobileAds // Make sure to add the SDK via SPM or CocoaPods

// MARK: - AppDelegate for AdMob Initialization & Test Device Config

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // --- IMPORTANT PROJECT SETUP REMINDER ---
        // Ensure these are done BEFORE initializing the SDK:
        // 1. Add Google Mobile Ads SDK via Swift Package Manager:
        //    File > Add Packages... > https://github.com/googleads/swift-package-manager-google-mobile-ads.git
        // 2. Update your Info.plist:
        //    - Add GADApplicationIdentifier (String) with your AdMob App ID.
        //      (Use "ca-app-pub-3940256099942544~1458002511" for testing initially)
        //    - Add SKAdNetworkItems (Array) with the dictionary entries provided
        //      in the Google AdMob documentation.
        // -----------------------------------------

        // Configure Test Devices (Programmatic Method - Recommended during development)
        // 1. Run your app on a device/simulator and make an ad request (like the banner below).
        // 2. Check the Xcode console output for a message like:
        //    "<Google> To get test ads on this device, set: GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ @"YOUR_DEVICE_ID" ];"
        // 3. Copy YOUR_DEVICE_ID (it's unique to your device/simulator instance).
        // 4. Add it to the array below. You can add multiple IDs.
        // 5. Run the app again. You should see a "Test Ad" label on Google ads.
        
        // !! IMPORTANT !!: Remove or comment out hardcoded test device IDs before submitting to the App Store!
        // GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "YOUR_SIMULATOR_OR_DEVICE_ID_HERE" ]

        // Initialize the Google Mobile Ads SDK *after* potentially setting test devices.
        MobileAds.shared.start(completionHandler: nil)

        print("Mobile Ads SDK Initialized.")
        // If test device IDs were set, subsequent ad requests might show the "Test Ad" label.
        
        return true
    }
}

// MARK: - Main App Structure
//
//@main
//struct AdMobIntegrationApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

// MARK: - Main Content View

struct GoogleAdMobIntegrationView2: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // --- Card Explaining Test Ads ---
                    AdFormatCardView(
                        title: "Enabling Test Ads",
                        description: """
                        **Crucial for Development:** Use test ads to avoid clicking on live ads, which can lead to account suspension due to invalid activity.

                        **Methods:**
                        1.  **Demo Ad Units (Easiest):** Use Google's provided test ad unit IDs (like the banner below). These aren't linked to your account.
                        2.  **Test Devices (Production-like Testing):** Use your *real* ad unit IDs but designate specific devices (or simulators) for testing.
                        
                        **To Enable Test Devices Programmatically:**
                        - Run the app & request an ad.
                        - Find the device ID in the Xcode console log (search for `<Google> To get test ads...`).
                        - Add the ID to the `AppDelegate` as shown in the code comments:
                        ```swift
                        GADMobileAds.sharedInstance()
                           .requestConfiguration
                           .testDeviceIdentifiers = [ "YOUR_ID_HERE" ]
                        ```
                        - Rerun. Google ads will show a **\"Test mode\"** label.
                        
                        **Mediation Note:** The \"Test mode\" label **only** appears on Google ads. For mediation, you *must* enable test mode for *each* network individually following their guides.
                        """,
                        iconName: "wrench.and.screwdriver.fill"
                    ) { /* No ad content needed for info card */ } // Empty content closure

                    // --- Ad Format Cards ---

                    AdFormatCardView(
                        title: "Banner Ads",
                        description: "Rectangular ads fitting a portion of the layout. Can auto-refresh. Simplest to implement.",
                        iconName: "rectangle.on.rectangle",
                        adContent: {
                            BannerAdView2() // Uses Google's demo ID by default
                                .frame(height: 50)
                        }
                    )

                    AdFormatCardView(
                        title: "Interstitial Ads",
                        description: "Full-page ads shown at natural breaks (e.g., level completion).",
                        iconName: "rectangle.stack",
                        adContent: {
                            Button("Show Interstitial (Placeholder)") {
                                print("Interstitial: Use demo ID or enable test device.")
                                // Needs GADInterstitialAd.load with a demo/your ID, then present.
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                        }
                    )

                    AdFormatCardView(
                        title: "Native Ads",
                        description: "Customizable ad format matching your app's look and feel.",
                        iconName: "list.bullet.rectangle.portrait",
                        adContent: {
                           Text("Native Ad Placeholder\n(Use demo ID or enable test device)")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .frame(minHeight: 50)
                               // Needs GADAdLoader with demo/your ID, delegate, and custom UI binding.
                               // The headline asset will be prepended with "Test mode" if using a test device.
                        }
                    )

                    AdFormatCardView(
                        title: "Rewarded Ads",
                        description: "Ads users watch voluntarily for in-app rewards (coins, lives). Requires opt-in.",
                        iconName: "gift",
                        adContent: {
                            Button("Show Rewarded Ad (Placeholder)") {
                                print("Rewarded: Use demo ID or enable test device.")
                                // Needs GADRewardedAd.load with demo/your ID, present, handle reward delegate.
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }
                    )
                    
                    AdFormatCardView(
                        title: "Rewarded Interstitial Ads",
                        description: "Ads shown automatically at transitions, offering rewards. Requires intro screen with opt-out.",
                        iconName: "gift.circle",
                        adContent: {
                            Button("Show Rewarded Interstitial (Placeholder)") {
                                print("Rewarded Interstitial: Use demo ID or enable test device.")
                                // Needs GADRewardedInterstitialAd.load with demo/your ID, present, handle reward delegate.
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                        }
                    )

                    AdFormatCardView(
                        title: "App Open Ads",
                        description: "Ads shown when the app is opened or switched back to, overlaying the loading screen.",
                        iconName: "rectangle.portrait.on.rectangle.portrait",
                        adContent: {
                           Text("App Open Ad Placeholder\n(Use demo ID or enable test device)")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .frame(minHeight: 50)
                                // Needs GADAppOpenAd.load with demo/your ID (often in AppDelegate/SceneDelegate) and show logic.
                        }
                    )
                }
                .padding()
            }
            .navigationTitle("AdMob Ad Formats")
        }
    }
}

// MARK: - Reusable Card View

struct AdFormatCardView<Content: View>: View {
    let title: String
    let description: String
    let iconName: String
    @ViewBuilder let adContent: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 10) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(width: 30, alignment: .center) // Centered icon
                Text(title)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true) // Allow title to wrap
            }

            Text(.init(description)) // Use .init for Markdown support (bold, code blocks)
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Conditionally show divider and content if adContent is not empty
            if !(adContent is EmptyView) {
                 Divider()
                HStack{
                    Spacer()
                    adContent
                    Spacer()
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .background(Material.regular)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Convenience initializer for info-only cards (no ad content)
extension AdFormatCardView where Content == EmptyView {
    init(title: String, description: String, iconName: String) {
        self.init(title: title, description: description, iconName: iconName, adContent: { EmptyView() })
    }
}


// MARK: - Banner Ad Implementation (UIViewControllerRepresentable)

struct BannerAdView2: UIViewControllerRepresentable {
    // --- Using Google's Demo Banner ID ---
    // This ensures safe testing without affecting your account.
    // Replace with your real Ad Unit ID ONLY when enabling Test Devices or for production.
    private let adUnitID = "ca-app-pub-3940256099942544/2934735716" // Google's Test Banner ID

    func makeUIViewController(context: Context) -> UIViewController {
        let bannerViewController = BannerViewController2()
        bannerViewController.adUnitID = adUnitID
        return bannerViewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
}

// Helper UIViewController to host the GADBannerView
class BannerViewController2: UIViewController {
    var adUnitID: String?
    lazy var bannerView: BannerView = {
        let view = BannerView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let adUnitID = adUnitID else { return }

        bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = self
        bannerView.delegate = self
        view.addSubview(bannerView)
        
        print("Banner Ad: Loading request with Ad Unit ID: \(adUnitID)")
        bannerView.load(Request())
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Position banner at the top-center of its container view.
         guard bannerView != nil else { return } // Ensure bannerView is initialized
        bannerView.frame = CGRect(
            x: (view.bounds.width - AdSizeBanner.size.width) / 2,
            y: 0,
            width: AdSizeBanner.size.width,
            height: AdSizeBanner.size.height
        )
    }
}

// MARK: - Banner View Delegate

extension BannerViewController2: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
      print("Banner Ad: Received ad successfully.")
       // Check if the ad has the "Test mode" label (only appears if using Test Devices)
        if let adInspectorClassName = bannerView.adUnitID, adInspectorClassName == "GADMAdapterGoogleAdMobAds" {
             // You might need more specific checks if possible, but generally,
             // if testDeviceIdentifiers is set, Google ads should show the label.
             print("Banner Ad: Served by Google AdMob network. Check visually for 'Test mode' label if using test devices.")
         } else {
             print("Banner Ad: Served by network: \(bannerView.adUnitID ?? "Unknown"). No 'Test mode' label will appear. Ensure test mode enabled for this network if applicable.")
         }
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
      print("Banner Ad: Failed to receive ad: \(error.localizedDescription)")
    }
    // Other delegate methods (optional)...
    func bannerViewDidRecordImpression(_ bannerView: BannerView) {
      print("Banner Ad: Recorded impression.")
    }
}


// MARK: - Previews

struct GoogleAdMobIntegrationView2_Previews: PreviewProvider {
    static var previews: some View {
        GoogleAdMobIntegrationView2()
    }
}
