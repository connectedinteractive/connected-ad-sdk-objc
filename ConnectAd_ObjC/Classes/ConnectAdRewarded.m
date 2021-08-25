//  ConnectAdRewarded.m

#import "ConnectAdRewarded.h"

@implementation ConnectAdRewarded
@synthesize moPubConnectId,adMobConnectId,rootViewController;

bool videoStarted;
bool videoFailed;
bool isAdsManagerRewarded;
NSError* playbackErrorCode;

-(id)init:(NSMutableArray*)adMobIDs :(NSMutableArray*)moPubIDs {
    if ([adMobIDs count] != 0) {
        self.adMobConnectIds = adMobIDs;
    }
    if ([moPubIDs count] != 0) {
        self.moPubConnectIds = moPubIDs;
    }
    return self;
}

-(id)init:(NSMutableArray*)adMobIDs :(NSMutableArray*)moPubIDs :(NSMutableArray*)adsManagerIDS {
    id returnValue = [self init:adMobIDs:moPubIDs];
    self.adsManagerConnectIds = adsManagerIDS;
    return returnValue;
}

-(void)loadFrom: (UIViewController*)viewController{
    NSArray *orderArray = [[ConnectAd sharedInstance].ad.adOrder copy];
    self.rewardedOrders = [[NSMutableArray alloc]init];
    [self.rewardedOrders addObjectsFromArray:orderArray];
    self.rootViewController = viewController;
    if ([ConnectAd sharedInstance].ad != nil) {
        Ad *ad = [ConnectAd sharedInstance].ad;
        NSMutableArray *adUnitIds = ad.adUnitIds;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"adUnitName = %@", AdKeyToString[admob]];
        NSArray *filtered = [adUnitIds filteredArrayUsingPredicate:predicate];
        if (filtered != nil && [filtered count] != 0) {
            AdUnitID *adUnitID = filtered.firstObject;
            NSMutableArray * rewardsArray = adUnitID.rewardedVideo;
            if(rewardsArray.count != 0) {
                self.adMobRewardeds = rewardsArray;
            }
        }
        
        NSPredicate *predicateAdsManager = [NSPredicate predicateWithFormat:@"adUnitName = %@", AdKeyToString[adsmanager]];
        NSArray *filteredAdsManager= [adUnitIds filteredArrayUsingPredicate:predicateAdsManager];
        if (filteredAdsManager != nil && [filteredAdsManager count] != 0) {
            AdUnitID *adUnitID = filteredAdsManager.firstObject;
            NSMutableArray * rewardsArray = adUnitID.rewardedVideo;
            if(rewardsArray.count != 0) {
                self.adsManagerRewardeds = rewardsArray;
            }
        }

        NSPredicate *predicate_moPub = [NSPredicate predicateWithFormat:@"adUnitName = %@", AdKeyToString[mopub]];
        NSArray *filtered_moPub = [adUnitIds filteredArrayUsingPredicate:predicate_moPub];
        if (filtered_moPub != nil && [filtered_moPub count] != 0) {
            AdUnitID *adUnitID_moPub = filtered_moPub.firstObject;
            NSMutableArray * rewardsArray_moPub = adUnitID_moPub.rewardedVideo;
            if(rewardsArray_moPub.count != 0) {
                self.moPubRewardeds = rewardsArray_moPub;
            }
        }
    }
    [self loadNewAds];
}
-(void)loadNewAds {
    videoFailed = false;
    videoStarted = false;
    playbackErrorCode = false;
    if(![self.rewardedOrders firstObject]) {
        NSLog(@"No reward found");
        if (self.delegate != nil &&  [(NSObject*)self.delegate respondsToSelector:@selector(onRewardNoAdAvailable)]) {
            [self.delegate onRewardNoAdAvailable];
        }
    } else {
        NSInteger rewardedOrder = [self.rewardedOrders.firstObject integerValue];
        switch (rewardedOrder) {
            case MoPubOrder:
                self.adType = MOPUB;
                [self setMoPubRewarded];
                break;
            case AdMobOrder:
                self.adType = ADMOB;
                [self setAdMobRewarded];
                break;
            case AdsManagerOrder:
                self.adType = ADSMANAGER;
                [self setAdsManagerRewarded];
                break;
            default:
                [self.rewardedOrders removeObjectAtIndex:0];
                [self loadNewAds];
                break;
        }
    }

}
-(void)setAdMobRewarded {
    isAdsManagerRewarded = false;
    self.adMobConnectId = self.adMobConnectIds.firstObject;
    NSString *rewardedAdUnitId = @"";
    if (self.adMobConnectId != nil) {
        for (int i = 0; i< self.adMobRewardeds.count; i++) {
            AdId *adId = [self.adMobRewardeds objectAtIndex:i];
            if ([adId.connectedId isEqualToString:self.adMobConnectId]) {
                AdId *rewardedAd = [self.adMobRewardeds objectAtIndex:i];
                if(rewardedAd.adUnitId != nil) {
                    NSString *adUnitId = rewardedAd.adUnitId;
                    rewardedAdUnitId = adUnitId;
                }
                break;
            }
        }
    }
    GADRequest *request = [GADRequest request];
    [GADRewardedAd loadWithAdUnitID:rewardedAdUnitId
                              request:request
                    completionHandler:^(GADRewardedAd *ad, NSError *error) {
        if (error) {
          NSLog(@"Rewarded ad failed to load with error: %@", [error localizedDescription]);
          return;
        }
        self.rewardedAd = ad;
        NSLog(@"Rewarded ad loaded.");
        self.rewardedAd.fullScreenContentDelegate = self;
        
        if (self.rewardedAd) {
            [self.rewardedAd presentFromRootViewController:self->rootViewController
                                  userDidEarnRewardHandler:^ {
                GADAdReward *reward = self.rewardedAd.adReward;
                AdReward *rewardVideoReward = [[AdReward alloc]init];
                rewardVideoReward.currencyType = reward.type;
                rewardVideoReward.rewardAmount = [reward.amount intValue];
                [self.delegate onRewardedVideoCompleted:self.adType withReward:rewardVideoReward];
                
            }];
        } else {
            NSLog(@"Ad wasn't ready");
        }
    }];
}

-(void)setAdsManagerRewarded {
    isAdsManagerRewarded = true;
    self.adsManagerConnectId = self.adsManagerConnectIds.firstObject;
    NSString *rewardedAdUnitId = @"";
    if (self.adsManagerConnectId != nil) {
        for (int i = 0; i< self.adsManagerRewardeds.count; i++) {
            AdId *adId = [self.adsManagerRewardeds objectAtIndex:i];
            if ([adId.connectedId isEqualToString:self.adsManagerConnectId]) {
                AdId *rewardedAd = [self.adsManagerRewardeds objectAtIndex:i];
                if(rewardedAd.adUnitId != nil) {
                    NSString *adUnitId = rewardedAd.adUnitId;
                    rewardedAdUnitId = adUnitId;
                }
                break;
            }
        }
    }
    
    GAMRequest *request = [GAMRequest request];

    [GADRewardedAd loadWithAdUnitID:rewardedAdUnitId
                              request:request
                    completionHandler:^(GADRewardedAd *ad, NSError *error) {
        if (error) {
            NSLog(@"Rewarded ad %@ failed to load with error: %@, code: %ld", rewardedAdUnitId, [error localizedDescription], (long)[error code]);
            [self.delegate onRewardNoAdAvailable];
          return;
        }
        self.rewardedAd = ad;
        NSLog(@"Rewarded ad loaded.");
        self.rewardedAd.fullScreenContentDelegate = self;
        
        if (self.rewardedAd) {
            [self.rewardedAd presentFromRootViewController:self->rootViewController
                                  userDidEarnRewardHandler:^ {
                GADAdReward *reward = self.rewardedAd.adReward;
                AdReward *rewardVideoReward = [[AdReward alloc]init];
                rewardVideoReward.currencyType = reward.type;
                rewardVideoReward.rewardAmount = [reward.amount intValue];
                [self.delegate onRewardedVideoCompleted:self.adType withReward:rewardVideoReward];
                
            }];
        } else {
            NSLog(@"Ad wasn't ready");
        }
    }];
}

-(void)setMoPubRewarded {
    self.moPubConnectId = self.moPubConnectIds.firstObject;
    NSString *rewardedAdUnitId = @"";
    if (self.moPubConnectId != nil) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"connectedId = %@", self.moPubConnectId];
        AdId *rewardedAd = [self.moPubRewardeds filteredArrayUsingPredicate:predicate].firstObject;
        if (rewardedAd.adUnitId != nil) {
            rewardedAdUnitId = rewardedAd.adUnitId;
        }
    }
    [MPRewardedVideo setDelegate:self forAdUnitId:rewardedAdUnitId];
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:rewardedAdUnitId withMediationSettings:nil];
}
#pragma mark: Admob
/// Tells the delegate that the rewarded ad was presented.
- (void)adDidPresentFullScreenContent:(id)ad {
    [self.delegate onRewardVideoStarted:self.adType];
}

/// Tells the delegate that the rewarded ad failed to present.
- (void)ad:(id)ad
didFailToPresentFullScreenContentWithError:(NSError *)error {
    [self.delegate onRewardFail:self.adType withError:error];
    if (!isAdsManagerRewarded && [self.adMobConnectIds count] != 0) {
        [self.adMobConnectIds removeObjectAtIndex:0];
        if ([self.adMobConnectIds count] != 0) {
            [self setAdMobRewarded];
        } else {
            if ([self.rewardedOrders count] != 0) {
                [self.rewardedOrders removeObjectAtIndex:0];
                [self loadNewAds];
            }
        }
    } else if (isAdsManagerRewarded && [self.adsManagerConnectIds count] != 0) {
        [self.adsManagerConnectIds removeObjectAtIndex:0];
        if ([self.adsManagerConnectIds count] != 0) {
            [self setAdsManagerRewarded];
        } else {
            if ([self.rewardedOrders count] != 0) {
                [self.rewardedOrders removeObjectAtIndex:0];
                [self loadNewAds];
            }
        }
    } else {
        if ([self.rewardedOrders count] != 0) {
            [self.rewardedOrders removeObjectAtIndex:0];
            [self loadNewAds];
        }
    }
}

/// Tells the delegate that the rewarded ad was dismissed.
- (void)adDidDismissFullScreenContent:(id)ad {
    [self.delegate onRewardVideoClosed:self.adType];
}

///The willLeaveApplication callback for all ad formats has been removed in favor of the applicationDidEnterBackground: and sceneDidEnterBackground: methods.
///Using OS-level APIs notify you whenever users leave your app, regardless of whether or not it is due to an ad interaction.
///Note that the willLeaveApplication callback was never intended to be an ad click handler, and relying on this callback to report clicks did not produce an accurate metric.
///For example, a click on the AdChoices icon that launched an external browser invoked the callback but did not count a click.

//-(void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
//    [self.delegate onRewardVideoClicked:self.adType];
//}

#pragma mark: Mopub

- (void)rewardedVideoAdDidLoadForAdUnitID:(NSString *)adUnitID {
    // Called when the video for the given adUnitId has loaded. At this point you should be able to call presentRewardedVideoAdForAdUnitID to show the video.
    if ([MPRewardedVideo hasAdAvailableForAdUnitID:adUnitID]) {
        [MPRewardedVideo presentRewardedVideoAdForAdUnitID:adUnitID fromViewController:rootViewController withReward:nil];
    }
}

- (void)rewardedVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error{
    [self handleMoPubFailure:error];
}

- (void)rewardedVideoAdDidFailToPlayForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    [self handleMoPubFailure:error];
}

- (void) handleMoPubFailure:(NSError*) error {
    videoFailed = true;
    playbackErrorCode = error;
    if (!videoStarted) {
        [self onFail:error];
    }
}

- (void)onFail:(NSError*) error {
    //  Called when there is an error during video playback.
    [self.delegate onRewardFail:self.adType withError:error];
    if ([self.moPubConnectIds count] != 0) {
        [self.moPubConnectIds removeObjectAtIndex:0];
        if ([self.moPubConnectIds count] != 0) {
            [self setMoPubRewarded];
        } else {
            if ([self.rewardedOrders count] != 0) {
                [self.rewardedOrders removeObjectAtIndex:0];
                [self loadNewAds];
            }
        }
    } else {
        if ([self.rewardedOrders count] != 0) {
            [self.rewardedOrders removeObjectAtIndex:0];
            [self loadNewAds];
        }
    }
}

- (void)rewardedVideoAdWillAppearForAdUnitID:(NSString *)adUnitID{
    // Called when a rewarded video starts playing.
    videoStarted = true;
    [self.delegate onRewardVideoStarted:self.adType];
}


- (void)rewardedVideoAdDidDisappearForAdUnitID:(NSString *)adUnitID{
    // Called when a rewarded video is closed. At this point your application should resume.
    
    if (videoStarted && videoFailed) {
        [self onFail:playbackErrorCode];
    } else {
        [self.delegate onRewardVideoClosed:self.adType];
    }
}

- (void)rewardedVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPRewardedVideoReward *)reward{
    // Called when a rewarded video is completed and the user should be rewarded.
    AdReward *rewardVideoReward = [[AdReward alloc]init];
    rewardVideoReward.currencyType = reward.currencyType;
    rewardVideoReward.rewardAmount = [reward.amount intValue];
    [self.delegate onRewardedVideoCompleted:self.adType withReward:rewardVideoReward];
}

- (void)rewardedVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID{
    [self.delegate onRewardVideoClicked:self.adType];
}

@end


