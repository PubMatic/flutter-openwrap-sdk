import Foundation

struct Constants {
    static let kAdIdKey: String = "adId"
    static let kPubIdKey: String = "pubId"
    static let kProfileIdKey: String = "profileId"
    static let kAdUnitIdKey: String = "adUnitId"
    static let kAdSizesKey: String = "adSizes"
    static let kHBKey: String = "isHeaderBidding"
    static let kTargetingKey: String = "openWrapTargeting"
    static let kErrCodeKey: String = "errorCode"
    static let kErrMsgKey: String = "errorMessage"
    static let kInternalErrorCode: Int = 1006 // internal error
    static let kInternalErrorMsg: String = "unknown error occurred"
    static let kOpenWrapPlatformException: String = "OpenWrapPlatformException"
    static let kInitErrorCode: Int = 1013 // initialization error
    static let kInitErrorMessage:
                String = "One or more invalid mandatory config parameters. Please verify Publisher Id & Profile Ids"
}
