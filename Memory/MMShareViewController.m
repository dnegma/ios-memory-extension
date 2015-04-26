//
//  ShareViewController.m
//  Memory
//
//  Created by D Gren on 4/5/15.
//  Copyright (c) 2015 D Gren. All rights reserved.
//

#import "MMShareViewController.h"

#import "MMCollectionViewCell.h"
#import "MMCollectionViewController.h"
#import "MMCollectionView.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <SoundCloudUtils/SoundCloudUtils.h>

@interface MMShareViewController () <MMCollectionViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet MMCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@property (strong, nonatomic) MMCollectionViewController *collectionViewController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkWidthConstraint;
@end

@implementation MMShareViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSExtensionItem *extensionItem = self.extensionContext.inputItems.firstObject;
  for (NSItemProvider *itemProvider in extensionItem.attachments) {
    if ([itemProvider hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypePlainText]) {
      [itemProvider loadItemForTypeIdentifier:(__bridge NSString *)kUTTypePlainText options:nil completionHandler:^(NSString *item, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
          self.titleLabel.text = item;
        });
      }];
    } else if ([itemProvider hasItemConformingToTypeIdentifier:(__bridge NSString *)kUTTypeURL]) {
      [itemProvider loadItemForTypeIdentifier:(__bridge NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *item, NSError *error) {
        [self _resolvePermalink:item];
      }];
    }
  }
  self.collectionView.dataSource = self.collectionViewController;
  self.collectionView.delegate = self.collectionViewController;
  [self.collectionView registerClass:[MMCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([MMCollectionViewCell class])];
}

#pragma mark Properties

- (MMCollectionViewController *)collectionViewController {
  if (!_collectionViewController) {
    _collectionViewController = [MMCollectionViewController new];
    _collectionViewController.delegate = self;
  }
  return _collectionViewController;
}

#pragma mark Private

- (void)_setError:(NSError *)error {
  self.statusLabel.text = error.localizedDescription;
  self.statusLabel.hidden = NO;
}

- (IBAction)_didTapCancel:(UIButton *)sender {
  self.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
  [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
}

- (void)_resolvePermalink:(NSURL *)url {
  SCResolveRequest *request = [SCResolveRequest newRequestWithResolveURL:url completion:^(NSDictionary *response, NSError *error) {
    if (!error) {
      [self _loadTracksForUserId:response.userId];
    } else {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self _setError:error];
        [self.activityIndicator stopAnimating];
      });
    }
  }];
  [request resume];
}

- (void)_loadTracksForUserId:(NSNumber *)userId {
  SCUserRequest *request = [SCUserRequest newTracksListRequestForUserId:userId completion:^(NSArray *response, NSError *error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (!error) {
        [self.collectionViewController setTracks:response];
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
      } else {
        [self _setError:error];
      }
      [self.activityIndicator stopAnimating];
    });
  }];
  [request resume];
}

#pragma mark MMCollectionViewControllerDelegate

- (void)collectionViewControllerDidFinishGame:(MMCollectionViewController *)controller {
  [UIView animateWithDuration:0.1 animations:^{
    self.checkImageView.hidden = NO;
    self.checkHeightConstraint.constant = 200;
    self.checkWidthConstraint.constant = 200;
    [self.checkImageView layoutIfNeeded];
  } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.2 animations:^{
      self.checkHeightConstraint.constant = 150;
      self.checkWidthConstraint.constant = 150;
    }];
  }];
}

@end
