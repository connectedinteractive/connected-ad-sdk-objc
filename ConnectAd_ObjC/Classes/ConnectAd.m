//  ConnectAd.m

#import "ConnectAd.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "MoPub.h"
#import <AppTrackingTransparency/ATTrackingManager.h>

@implementation ConnectAd

NSString * const AdKeyToString[] = {
    [admob] = @"admob",
    [mopub] = @"mopub",
    [adsmanager] = @"adsmanager"
};
BOOL initializationStatus;


// Get the shared instance and create it if necessary.
+ (ConnectAd *)sharedInstance {
    static dispatch_once_t pred;
    static ConnectAd *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[ConnectAd alloc] init];
    });
    return shared;
}

+ (bool)needsAppTrackingPermission {
    if (@available(iOS 14, *)) {
        return [ATTrackingManager trackingAuthorizationStatus] == ATTrackingManagerAuthorizationStatusNotDetermined;
    } else {
        return false;
    }
}

+(void)connectAdInit:(NSString*)appId completion:(void (^ __nullable)(NSMutableDictionary *response, NSError *error))completion{
    NSMutableDictionary *getConnectAdDetailsResponse = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *admobResponse = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *mopubResponse = [[NSMutableDictionary alloc]init];
    Ad *connectAd = [[Ad alloc]init];
    NSString *urlString = [NSString stringWithFormat:@"http://35.235.88.118/appbyidnew/%@", appId];
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200)
        {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            NSLog(@"The response is - %@",responseDictionary);

            connectAd.status = [responseDictionary valueForKey:@"status"];
            connectAd.id = [responseDictionary valueForKey:@"id"];

            if ([responseDictionary valueForKey:@"adOrder"]) {
                id adOrder = [responseDictionary valueForKey:@"adOrder"];
                if ([adOrder isKindOfClass: [NSArray class]]) {
                    NSMutableArray *adOrderArray = adOrder;
                    NSMutableArray *adOrders = [[NSMutableArray alloc]init];
                    for (int i=0; i<adOrderArray.count;i++) {
                        [adOrders addObject:[adOrderArray objectAtIndex:i]];
                    }
                    connectAd.adOrder = adOrders;
                }
            }

            if ([responseDictionary valueForKey:@"adUnitIds"]) {
                id adUnitID = [responseDictionary valueForKey:@"adUnitIds"];
                if ([adUnitID isKindOfClass: [NSArray class]]) {
                    NSArray *adUnitIDArray = adUnitID;
                    NSMutableArray *adUnitIds = [[NSMutableArray alloc]init];
                    for (int i=0; i< [adUnitIDArray count]; i++) {
                        AdUnitID *adUnitID = [[AdUnitID alloc]init];

                        if ([[adUnitIDArray objectAtIndex:i]valueForKey:@"appId"] != nil) {
                            adUnitID.appId = [[adUnitIDArray objectAtIndex:i]valueForKey:@"appId"];
                        } else {
                            adUnitID.appId = @"";
                        }

                        if ([[adUnitIDArray objectAtIndex:i]valueForKey:@"adUnitName"] != nil) {
                            adUnitID.adUnitName = [[adUnitIDArray objectAtIndex:i]valueForKey:@"adUnitName"];
                        } else {
                            adUnitID.adUnitName = @"";
                        }

                        if ([[adUnitIDArray objectAtIndex:i]valueForKey:@"rewardedVideo"] != nil) {
                            id rewardedVideo = [[adUnitIDArray objectAtIndex:i]valueForKey:@"rewardedVideo"];
                            if ([rewardedVideo isKindOfClass: [NSArray class]]) {
                                NSArray *rewardedVideoArray = rewardedVideo;
                                NSMutableArray *rewardedVideos = [[NSMutableArray alloc]init];
                                for (int i=0; i< [rewardedVideoArray count]; i++) {
                                    AdId *adId = [[AdId alloc]init];
                                    adId.adUnitId = [[rewardedVideoArray objectAtIndex:i]valueForKey:@"adUnitId"];
                                    adId.connectedId = [[rewardedVideoArray objectAtIndex:i]valueForKey:@"connectedId"];
                                    [rewardedVideos addObject:adId];
                                }
                                adUnitID.rewardedVideo = rewardedVideos;
                            }
                        }

                        if ([[adUnitIDArray objectAtIndex:i]valueForKey:@"banner"] != nil) {
                            id banner = [[adUnitIDArray objectAtIndex:i]valueForKey:@"banner"];
                            if ([banner isKindOfClass: [NSArray class]]) {
                                NSArray *bannerArray = banner;
                                NSMutableArray *banners = [[NSMutableArray alloc]init];
                                for (int i=0; i< [bannerArray count]; i++) {
                                    AdId *adId = [[AdId alloc]init];
                                    adId.adUnitId = [[bannerArray objectAtIndex:i]valueForKey:@"adUnitId"];
                                    adId.connectedId = [[bannerArray objectAtIndex:i]valueForKey:@"connectedId"];
                                    [banners addObject:adId];
                                }
                                adUnitID.banner = banners;
                            }
                        }

                        if ([[adUnitIDArray objectAtIndex:i]valueForKey:@"interstitial"] != nil) {
                            id interstitial = [[adUnitIDArray objectAtIndex:i]valueForKey:@"interstitial"];
                            if ([interstitial isKindOfClass: [NSArray class]]) {
                                NSArray *interstitialArray = interstitial;
                                NSMutableArray *interstitials = [[NSMutableArray alloc]init];
                                for (int i=0; i< [interstitialArray count]; i++) {
                                    AdId *adId = [[AdId alloc]init];
                                    adId.adUnitId = [[interstitialArray objectAtIndex:i]valueForKey:@"adUnitId"];
                                    adId.connectedId = [[interstitialArray objectAtIndex:i]valueForKey:@"connectedId"];
                                    [interstitials addObject:adId];
                                }
                                adUnitID.interstitial = interstitials;
                            }
                        }
                        [adUnitIds addObject:adUnitID];
                    }
                    connectAd.adUnitIds = adUnitIds;
                }
            }

            if ([responseDictionary valueForKey:@"vastAdUnits"]) {
                id vastAdUnits = [responseDictionary valueForKey:@"vastAdUnits"];
                if ([vastAdUnits isKindOfClass: [NSArray class]]) {
                    NSArray *vastAdUnitsArray = vastAdUnits;
                    NSMutableArray *vastAdUnits = [[NSMutableArray alloc]init];
                    for (int i=0; i< [vastAdUnitsArray count]; i++) {
                        VASTAdUnit *vastAdUnit = [[VASTAdUnit alloc]init];
                        if ([[vastAdUnitsArray objectAtIndex:i]valueForKey:@"vastUrl"] != nil) {
                            vastAdUnit.vastUrl = [[vastAdUnitsArray objectAtIndex:i]valueForKey:@"vastUrl"];
                        } else {
                            vastAdUnit.vastUrl = @"";
                        }
                        if ([[vastAdUnitsArray objectAtIndex:i]valueForKey:@"adUnitName"] != nil) {
                            vastAdUnit.price = [[[vastAdUnitsArray objectAtIndex:i]valueForKey:@"price"] floatValue];
                        } else {
                            vastAdUnit.price = 0.0;
                        }
                        [vastAdUnits addObject:vastAdUnit];
                    }
                    connectAd.vastAdUnits = vastAdUnits;
                }
            }

            if ([responseDictionary valueForKey:@"connectedAdUnit"]) {
                ConnectedAdUnit *connectedAdUnit = [[ConnectedAdUnit alloc]init];
                NSMutableArray *banners = [[responseDictionary valueForKey:@"connectedAdUnit"]valueForKey:@"banner"];
                NSMutableArray *bannerArray = [[NSMutableArray alloc]init];
                for (int i = 0; i<banners.count; i++) {
                    [bannerArray addObject:[banners objectAtIndex:i]];
                }
                connectedAdUnit.banner = bannerArray;
                NSMutableArray *interstitial = [[responseDictionary valueForKey:@"connectedAdUnit"]valueForKey:@"interstitial"];
                NSMutableArray *interstitialArray = [[NSMutableArray alloc]init];
                for (int i = 0; i<interstitial.count; i++) {
                    [interstitialArray addObject:[interstitial objectAtIndex:i]];
                }
                connectedAdUnit.interstitial = interstitialArray;
                connectAd.connectedAdUnit = connectedAdUnit;
            }

            [ConnectAd sharedInstance].ad = connectAd;

            NSMutableArray *adUnitids = [ConnectAd sharedInstance].ad.adUnitIds;
            //checking add unit ids
            if(adUnitids.count != 0) {
                //Mopub initialisation
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"adUnitName = %@", AdKeyToString[mopub]];
                NSArray *filtered = [adUnitids filteredArrayUsingPredicate:predicate];
                AdUnitID *moPub = filtered.firstObject;
                NSString *mopubAppUnitId = @"";
                //checking mopub data
                if (moPub != nil) {
                    NSMutableArray *banners = moPub.banner;
                    if (banners.count != 0) {
                        AdId *banner = banners.firstObject;
                        NSString *appUnitId = banner.adUnitId;
                        mopubAppUnitId = appUnitId;
                    }
                    NSMutableArray *interstitials = moPub.interstitial;
                    if(interstitials.count != 0){
                        AdId *interstitial = interstitials.firstObject;
                        NSString *appUnitId = interstitial.adUnitId;
                        mopubAppUnitId = appUnitId;
                    }
                    NSMutableArray *rewardedVideos = moPub.rewardedVideo;
                    if(rewardedVideos.count != 0){
                        AdId *rewardedVideo = rewardedVideos.firstObject;
                        NSString *appUnitId = rewardedVideo.adUnitId;
                        mopubAppUnitId = appUnitId;
                    }
                    if (![mopubAppUnitId isEqualToString:@""]) {
                        MPMoPubConfiguration *sdkConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:mopubAppUnitId];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[MoPub sharedInstance] initializeSdkWithConfiguration:sdkConfig completion:^{
                                NSLog(@"SDK initialization complete");
                                //admob initialisation
                                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"adUnitName = %@", AdKeyToString[admob]];
                                NSArray *filtered = [adUnitids filteredArrayUsingPredicate:predicate];
                                AdUnitID *adMob = filtered.firstObject;
                                NSString *adMobAppUnitId = @"";
                                if (adMob != nil) {
                                    NSMutableArray *banners = adMob.banner;
                                    if (banners.count != 0) {
                                        AdId *banner = banners.firstObject;
                                        NSString *appUnitId = banner.adUnitId;
                                        adMobAppUnitId = appUnitId;
                                    }
                                    NSMutableArray *interstitials = adMob.interstitial;
                                    if(interstitials.count != 0){
                                        AdId *interstitial = interstitials.firstObject;
                                        NSString *appUnitId = interstitial.adUnitId;
                                        adMobAppUnitId = appUnitId;
                                    }
                                    NSMutableArray *rewardedVideos = adMob.rewardedVideo;
                                    if(rewardedVideos.count != 0){
                                        AdId *rewardedVideo = rewardedVideos.firstObject;
                                        NSString *appUnitId = rewardedVideo.adUnitId;
                                        adMobAppUnitId = appUnitId;
                                    }
                                    
                                    NSPredicate *predicateAdsManager = [NSPredicate predicateWithFormat:@"adUnitName = %@", AdKeyToString[adsmanager]];
                                    NSArray *filteredAdsManager = [adUnitids filteredArrayUsingPredicate:predicateAdsManager];
                                    AdUnitID *adsManager = filteredAdsManager.firstObject;
                                    NSString *adsManagerAppUnitId = @"";
                                    if (adsManager != nil) {
                                        NSMutableArray *banners = adsManager.banner;
                                        if (banners.count != 0) {
                                            AdId *banner = banners.firstObject;
                                            NSString *appUnitId = banner.adUnitId;
                                            adsManagerAppUnitId = appUnitId;
                                        }
                                        NSMutableArray *interstitials = adMob.interstitial;
                                        if(interstitials.count != 0){
                                            AdId *interstitial = interstitials.firstObject;
                                            NSString *appUnitId = interstitial.adUnitId;
                                            adsManagerAppUnitId = appUnitId;
                                        }
                                        NSMutableArray *rewardedVideos = adMob.rewardedVideo;
                                        if(rewardedVideos.count != 0){
                                            AdId *rewardedVideo = rewardedVideos.firstObject;
                                            NSString *appUnitId = rewardedVideo.adUnitId;
                                            adsManagerAppUnitId = appUnitId;
                                        }
                                    }
                                    
                                    
                                    if (![adMobAppUnitId isEqualToString:@""] || ![adsManagerAppUnitId isEqualToString:@""]) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus * _Nonnull status) {
                                                for (int i = 0; i<status.adapterStatusesByClassName.allValues.count; i++) {
                                                    GADAdapterStatus *gadAdapterStatus = [status.adapterStatusesByClassName.allValues objectAtIndex:i];
                                                    if(gadAdapterStatus.state == GADAdapterInitializationStateReady){
                                                        NSLog(@"AdMob/AdsManager Initialization success!");
                                                        initializationStatus = true;
                                                        [admobResponse setObject:[NSNumber numberWithBool:true] forKey:@"success"];
                                                        [admobResponse setValue:@"Admob/AdsManager initialization success" forKey:@"message"];
                                                        [mopubResponse setObject:[NSNumber numberWithBool:true] forKey:@"success"];
                                                        [mopubResponse setValue:@"Mopub initialization success" forKey:@"message"];
                                                        [getConnectAdDetailsResponse setObject:admobResponse forKey:@"Google"];
                                                        [getConnectAdDetailsResponse setObject:mopubResponse forKey:@"Mopub"];
                                                        completion(getConnectAdDetailsResponse, nil);                                   }
                                                }
                                                if (initializationStatus == false) {
                                                    [admobResponse setObject:[NSNumber numberWithBool:false] forKey:@"success"];
                                                    [admobResponse setValue:@"Admob/AdsManager initialization failed" forKey:@"message"];
                                                    [mopubResponse setObject:[NSNumber numberWithBool:true] forKey:@"success"];
                                                    [mopubResponse setValue:@"Mopub initialization success" forKey:@"message"];
                                                    [getConnectAdDetailsResponse setObject:admobResponse forKey:@"Google"];
                                                    [getConnectAdDetailsResponse setObject:mopubResponse forKey:@"Mopub"];
                                                    completion(getConnectAdDetailsResponse, nil);
                                                }
                                            }];
                                        });
                                    } else {
                                        [admobResponse setObject:[NSNumber numberWithBool:false] forKey:@"success"];
                                        [admobResponse setValue:@"Admob/AdsManager Data not found" forKey:@"message"];
                                        [mopubResponse setObject:[NSNumber numberWithBool:true] forKey:@"success"];
                                        [mopubResponse setValue:@"Mopub initialization success" forKey:@"message"];
                                        [getConnectAdDetailsResponse setObject:admobResponse forKey:@"Google"];
                                        [getConnectAdDetailsResponse setObject:mopubResponse forKey:@"Mopub"];
                                        completion(getConnectAdDetailsResponse, nil);
                                    }
                                }
                            }];
                        });
                    } else {
                        //admob initialisation
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"adUnitName = %@", AdKeyToString[admob]];
                        NSArray *filtered = [adUnitids filteredArrayUsingPredicate:predicate];
                        AdUnitID *adMob = filtered.firstObject;
                        NSString *adMobAppUnitId = @"";
                        
                        NSPredicate *predicateAdsManager = [NSPredicate predicateWithFormat:@"adUnitName = %@", AdKeyToString[adsmanager]];
                        NSArray *filteredAdsManager = [adUnitids filteredArrayUsingPredicate:predicateAdsManager];
                        AdUnitID *adsmanager = filteredAdsManager.firstObject;
                        NSString *adsManagerAppUnitId = @"";
                        
                        if (adMob != nil || adsmanager != nil) {
                            NSMutableArray *banners = adMob != nil ? adMob.banner : [NSMutableArray array];
                            if (banners.count != 0) {
                                AdId *banner = banners.firstObject;
                                NSString *appUnitId = banner.adUnitId;
                                adMobAppUnitId = appUnitId;
                            }
                            NSMutableArray *interstitials = adMob != nil ? adMob.interstitial : [NSMutableArray array];
                            if(interstitials.count != 0){
                                AdId *interstitial = interstitials.firstObject;
                                NSString *appUnitId = interstitial.adUnitId;
                                adMobAppUnitId = appUnitId;
                            }
                            NSMutableArray *rewardedVideos = adMob != nil ? adMob.rewardedVideo : [NSMutableArray array];
                            if(rewardedVideos.count != 0){
                                AdId *rewardedVideo = rewardedVideos.firstObject;
                                NSString *appUnitId = rewardedVideo.adUnitId;
                                adMobAppUnitId = appUnitId;
                            }
                            
                            banners = adsmanager != nil ? adsmanager.banner : [NSMutableArray array];
                            if (banners.count != 0) {
                                AdId *banner = banners.firstObject;
                                NSString *appUnitId = banner.adUnitId;
                                adsManagerAppUnitId = appUnitId;
                            }
                            interstitials = adsmanager != nil ? adsmanager.interstitial :[NSMutableArray array];
                            if(interstitials.count != 0){
                                AdId *interstitial = interstitials.firstObject;
                                NSString *appUnitId = interstitial.adUnitId;
                                adsManagerAppUnitId = appUnitId;
                            }
                            rewardedVideos = adsmanager != nil ? adsmanager.rewardedVideo : [NSMutableArray array];
                            if(rewardedVideos.count != 0){
                                AdId *rewardedVideo = rewardedVideos.firstObject;
                                NSString *appUnitId = rewardedVideo.adUnitId;
                                adsManagerAppUnitId = appUnitId;
                            }
                            
                            if (![adMobAppUnitId isEqualToString:@""] || ![adsManagerAppUnitId isEqualToString:@""]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [[GADMobileAds sharedInstance] startWithCompletionHandler:^(GADInitializationStatus * _Nonnull status) {
                                        for (int i = 0; i<status.adapterStatusesByClassName.allValues.count; i++) {
                                            GADAdapterStatus *gadAdapterStatus = [status.adapterStatusesByClassName.allValues objectAtIndex:i];
                                            if(gadAdapterStatus.state == GADAdapterInitializationStateReady){
                                                NSLog(@"AdMob/AdsManager Manager initialization success!");
                                                initializationStatus = true;
                                                [admobResponse setObject:[NSNumber numberWithBool:true] forKey:@"success"];
                                                [admobResponse setValue:@"AdMob/AdsManager initialization success" forKey:@"message"];
                                                [mopubResponse setObject:[NSNumber numberWithBool:false] forKey:@"success"];
                                                [mopubResponse setValue:@"AdMob/AdsManager initialization failed" forKey:@"message"];
                                                [getConnectAdDetailsResponse setObject:admobResponse forKey:@"Google"];
                                                [getConnectAdDetailsResponse setObject:mopubResponse forKey:@"Mopub"];
                                                completion(getConnectAdDetailsResponse, nil);
                                            }
                                        }
                                        if (initializationStatus == false) {
                                            NSError *error = [NSError errorWithDomain:@"ConnectAd" code:3457 userInfo:@{NSLocalizedDescriptionKey:@"AdMob/AdsManager initialization failed & Mopub data not found"}];
                                            completion(nil, error);
                                        }
                                    }];
                                });
                            } else {
                                NSError *error = [NSError errorWithDomain:@"ConnectAd" code:3457 userInfo:@{NSLocalizedDescriptionKey:@"AdMob/AdsManager & Mopub data not found"}];
                                completion(nil, error);
                            }
                        }
                    }
                }
            } else {
                NSError *error = [NSError errorWithDomain:@"ConnectAd" code:3456 userInfo:@{NSLocalizedDescriptionKey:@"Api Failure - Missing Ad UnitIds"}];
                completion(nil,error);
            }
        }
        else
        {
            completion(nil,error);
        }

    }];
    [dataTask resume];
}

+ (void)requestAppTrackingPermissionWithCompletion:(void(^)(NSUInteger status))completion {
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            completion(status);
        }];
    }
}

+ (void)addTestDevice:(AdType)type deviceId:(NSString *)deviceId {
    switch (type) {
        case ADSMANAGER:
            GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[ deviceId ];
            break;
        default:
            break;
    }
}
@end
