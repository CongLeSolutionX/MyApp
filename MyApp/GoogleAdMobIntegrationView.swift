//
//  GoogleAdMobIntegrationView.swift
//  MyApp
//
//  Created by Cong Le on 3/30/25.
//

import SwiftUI
import GoogleMobileAds // Make sure to add the SDK via SPM or CocoaPods

// MARK: - AppDelegate for AdMob Initialization

// AppDelegate is still needed for initializing the Google Mobile Ads SDK
// early in the app lifecycle, even in SwiftUI apps.
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Initialize the Google Mobile Ads SDK.
        // It's recommended to do this as early as possible.
        // The completion handler is optional.
        MobileAds.shared.start(completionHandler: nil)

        // --- IMPORTANT PROJECT SETUP REMINDER ---
        // Don't forget to:
        // 1. Add the Google Mobile Ads SDK via Swift Package Manager:
        //    File > Add Packages... > https://github.com/googleads/swift-package-manager-google-mobile-ads.git
        // 2. Update your Info.plist:
        //    - Add GADApplicationIdentifier (String) with your AdMob App ID.
        //      (Use "ca-app-pub-3940256099942544~1458002511" for testing)
        //    - Add SKAdNetworkItems (Array) with the dictionary entries provided
        //      in the Google AdMob documentation for Google and third-party buyers.
        // -----------------------------------------

        print("Mobile Ads SDK Initialized.")
        return true
    }
}

// MARK: - Main App Structure

//@main
//struct AdMobIntegrationApp: App {
//    // Connect the AppDelegate using UIApplicationDelegateAdaptor
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//
//    var body: some Scene {
//        WindowGroup {
//            GoogleAdMobIntegrationView()
//        }
//    }
//}

// MARK: - Main Content View

struct GoogleAdMobIntegrationView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // --- Ad Format Cards ---
                    
                    AdFormatCardView(
                        title: "Banner Ads",
                        description: "Banner ad units display rectangular ads that occupy a portion of an app's layout. They can refresh automatically after a set period of time. This means users view a new ad at regular intervals, even if they stay on the same screen in your app. They're also the simplest ad format to implement.",
                        iconName: "rectangle.on.rectangle",
                        adContent: {
                            // Implement Banner Ad directly here
                            BannerAdView()
                                .frame(height: 50) // Standard banner height
                        }
                    )

                    AdFormatCardView(
                        title: "Interstitial Ads",
                        description: "Interstitial ad units show full-page ads in your app. Place them at natural breaks and transitions in your app's interface, such as after level completion in a gaming app.",
                        iconName: "rectangle.stack",
                        adContent: {
                            Button("Show Interstitial (Placeholder)") {
                                // Full implementation requires loading the ad first
                                // (using GADInterstitialAd.load) and then presenting it
                                // from the root view controller, often managed via a delegate.
                                // See Google AdMob Interstitial guide for details.
                                print("Interstitial button tapped - requires full implementation.")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                        }
                    )

                    AdFormatCardView(
                        title: "Native Ads",
                        description: "Native ads are ads where you can customize the way assets such as headlines and calls to action are presented in your apps. By styling the ad yourself, you can create a natural, unobtrusive ad presentations that can add to a rich user experience.",
                        iconName: "list.bullet.rectangle.portrait",
                        adContent: {
                           Text("Native Ad Placeholder\n(Requires custom UI integration)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(height: 50)
                                // Native ads require significant custom UI work to match
                                // the app's look and feel. You'd load a GADNativeAd and then
                                // populate your custom SwiftUI views with its assets.
                                // See Google AdMob Native Ads guide.
                        }
                    )

                    AdFormatCardView(
                        title: "Rewarded Ads",
                        description: "Rewarded ad units enable users to play games, take surveys, or watch videos to earn in-app rewards, such as coins, extra lives, or points. You can set different rewards for different ad units, and specify the reward values and items the user received.",
                        iconName: "gift",
                        adContent: {
                            Button("Show Rewarded Ad (Placeholder)") {
                                // Requires loading GADRewardedAd, presenting it, and handling
                                // the userDidEarnReward delegate method. Users must opt-in.
                                // See Google AdMob Rewarded Ads guide.
                                print("Rewarded Ad button tapped - requires full implementation.")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                        }
                    )
                    
                    AdFormatCardView(
                        title: "Rewarded Interstitial Ads",
                        description: "Rewarded interstitial is a new type of incentivized ad format that lets you offer rewards, such as coins or extra lives, for ads that appear automatically during natural app transitions. Unlike rewarded ads, users aren't required to opt in to view a rewarded interstitial. Instead, it requires an intro screen with an opt-out option.",
                        iconName: "gift.circle",
                        adContent: {
                            Button("Show Rewarded Interstitial (Placeholder)") {
                                // Requires loading GADRewardedInterstitialAd, presenting it,
                                // handling the intro screen/opt-out, and the userDidEarnReward delegate.
                                // See Google AdMob Rewarded Interstitial guide.
                                print("Rewarded Interstitial button tapped - requires full implementation.")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                        }
                    )

                    AdFormatCardView(
                        title: "App Open Ads",
                        description: "App open is an ad format that appears when users open or switch back to your app. The ad overlays the loading screen.",
                        iconName: "rectangle.portrait.on.rectangle.portrait",
                        adContent: {
                           Text("App Open Ad Placeholder\n(Loads & shows automatically on app foreground)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(height: 50)
                                // App Open ads are loaded typically in the AppDelegate or SceneDelegate
                                // and presented automatically when the app comes to the foreground.
                                // Requires handling lifecycle events and loading/showing logic.
                                // See Google AdMob App Open Ads guide.
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
    @ViewBuilder let adContent: Content // Content closure for ad placeholder/view

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 10) {
                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundColor(.accentColor)
                    .frame(width: 30) // Consistent icon width
                Text(title)
                    .font(.headline)
            }

            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Divider for visual separation
            Divider()

            // Placeholder for the actual ad or action button
            HStack{
                Spacer()
                adContent
                Spacer()
            }
            .padding(.top, 5)

        }
        .padding()
        .background(Material.regular) // Use Material for a modern look
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}


// MARK: - Banner Ad Implementation (UIViewControllerRepresentable)

struct BannerAdView: UIViewControllerRepresentable {
    // --- USE YOUR REAL AD UNIT ID FOR PRODUCTION ---
    private let adUnitID = "ca-app-pub-3940256099942544/2934735716" // Google's Test Banner ID

    func makeUIViewController(context: Context) -> UIViewController {
        let bannerViewController = BannerViewController()
        bannerViewController.adUnitID = adUnitID // Pass the Ad Unit ID
        return bannerViewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No update logic needed for a simple banner in this case.
    }
}

// Helper UIViewController to host the GADBannerView
class BannerViewController: UIViewController {
    var adUnitID: String?
    lazy var bannerView: BannerView = {
        let bannerView = BannerView()
        return bannerView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let adUnitID = adUnitID else {
            print("Error: Ad Unit ID not set for BannerViewController")
            return
        }

        bannerView = BannerView(adSize: AdSizeBanner) // Use GADAdSizeBanner for standard banners
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = self
        bannerView.delegate = self // Set delegate (optional but recommended)

        view.addSubview(bannerView) // Add the banner view to the hierarchy

        // Load the ad request
        print("Banner Ad: Loading request...")
        bannerView.load(Request())
    }

    // Position the banner view at the bottom of the hosting view controller
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Position banner at the bottom center. Adjust if needed.
        // If using AutoLayout, you'd set constraints in viewDidLoad instead.
        bannerView.frame = CGRect(
            x: (view.frame.width - bannerView.frame.width) / 2,
            y: 0, // Place at top within its container
            width: bannerView.frame.width,
            height: bannerView.frame.height
        )
         print("Banner Ad: Layout updated.")
    }
}

// MARK: - Banner View Delegate (Optional but Recommended)

extension BannerViewController: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
      print("Banner Ad: Received ad successfully.")
    }

    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
      print("Banner Ad: Failed to receive ad: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: BannerView) {
      print("Banner Ad: Recorded impression.")
    }

    func bannerViewWillPresentScreen(_ bannerView: BannerView) {
      print("Banner Ad: Will present screen.")
    }

    func bannerViewWillDismissScreen(_ bannerView: BannerView) {
      print("Banner Ad: Will dismiss screen.")
    }

    func bannerViewDidDismissScreen(_ bannerView: BannerView) {
      print("Banner Ad: Did dismiss screen.")
    }
}


// MARK: - Previews

struct GoogleAdMobIntegrationView_Previews: PreviewProvider {
    static var previews: some View {
        GoogleAdMobIntegrationView()
    }
}
