class AppConstants {
// Codecanyon
  static const String baseUrl = 'https://totalhealthherbalist.com/api';
  // QA Testing
  //static const String baseUrl = 'https://uat.readyecommerce.app/api';
  // static const String baseUrl = 'http://chat.razinsoft.site/api';
  // Development
  //static const String baseUrl = 'https://dev.readyecommerce.app/api';
  static const String settings = '$baseUrl/master';
  static const String loginUrl = '$baseUrl/login';
  static const String registrationUrl = '$baseUrl/registration';
  static const String sendOTP = '$baseUrl/auth/otp/send';
  static const String verifyOtp = '$baseUrl/auth/otp/verify';
  static const String googleLogin = '$baseUrl/auth/google';
  static const String driverLocationPost = '$baseUrl/driver/location';
  static const String driverLocationGet = '$baseUrl/driver/location';
  static const String resetPassword = '$baseUrl/reset-password';
  static const String changePassword = '$baseUrl/change-password';
  static const String updateProfile = '$baseUrl/update-profile';
  static const String getDashboardData = '$baseUrl/home';
  static const String getCategories = '$baseUrl/categories';
  static const String getSubCategories = '$baseUrl/sub-categories';
  static const String getShops = '$baseUrl/shops';
  static const String getShopDetails = '$baseUrl/shop';
  static const String getProducts = '$baseUrl/products';
  static const String getShopCategiries = '$baseUrl/shop-categories';
  static const String getReviews = '$baseUrl/reviews';
  static const String getCategoryWiseProducts = '$baseUrl/category-products';
  static const String getProductDetails = '$baseUrl/product-details';
  static const String productFavoriteAddRemoveUrl =
      '$baseUrl/favorite-add-or-remove';
  static const String getFavoriteProducts = '$baseUrl/favorite-products';
  static const String addAddess = '$baseUrl/address/store';
  static const String address = '$baseUrl/address';
  static const String getAddress = '$baseUrl/addresses';
  static const String addToCart = '$baseUrl/cart/store';
  static const String incrementQty = '$baseUrl/cart/increment';
  static const String decrementQty = '$baseUrl/cart/decrement';
  static const String getAllCarts = '$baseUrl/carts';
  static const String getAllGifts = '$baseUrl/gifts';
  static const String addGift = '$baseUrl/gift/store';
  static const String updateGift = '$baseUrl/gift/update';
  static const String removeGift = '$baseUrl/gift/delete';
  static const String buyNow = '$baseUrl/buy-now';
  static const String cartSummery = '$baseUrl/cart/checkout';
  static const String placeOrder = '$baseUrl/place-order';
  static const String placeOrderV1 = '$baseUrl/v1/place-order';
  static const String orderAgain = '$baseUrl/place-order/again';
  static const String buyNowOrderPlace = '$baseUrl/buy-now/place-order';
  static const String getOrders = '$baseUrl/orders';
  static const String getOrderDetails = '$baseUrl/order-details';
  static const String cancelOrder = '$baseUrl/orders/cancel';
  static const String addProductReview = '$baseUrl/product-review';
  static const String getVoucher = '$baseUrl/get-vouchers';
  static const String collectVoucher = '$baseUrl/vouchers-collect';
  static const String applyVoucher = '$baseUrl/apply-voucher';
  static const String ordePayment = '$baseUrl/order-payment';
  static const String blogs = '$baseUrl/blogs';
  static const String blogDetails = '$baseUrl/blog';

  static const String privacyPolicy = '$baseUrl/legal-pages/privacy-policy';
  static const String termsAndConditions =
      '$baseUrl/legal-pages/terms-and-conditions';
  static const String refundPolicy =
      '$baseUrl/legal-pages/return-and-refund-policy';
  static const String support = '$baseUrl/support';
  static const String contactUs = '$baseUrl/contact-us';
  static const String profileinfo = '$baseUrl/profile';

  static const String logout = '$baseUrl/logout';
  static const String flashSales = '$baseUrl/flash-sales';
  static const String flashSaleDetails = '$baseUrl/flash-sale';
  static const String allCountry = '$baseUrl/countries';
  static const String storeMessage = '$baseUrl/store-message';
  static const String getMessage = '$baseUrl/get-message';
  static const String sendMessage = '$baseUrl/send-message';
  static const String getShopsList = '$baseUrl/get-shops';
  static const String unreadMessage = '$baseUrl/unread-messages';

  // dynamic url based on the service name
  static String getDashboardInfoUrl(String serviceName) =>
      '$baseUrl/api/$serviceName/store/dashoard';

  // hive constants

  // Box Names
  static const String appSettingsBox = 'appSettings';
  static const String authBox = 'laundrySeller_authBox';
  static const String userBox = 'laundrySeller_userBox';
  static const String cartModelBox = 'hive_cart_model_box';

  // Settings Veriable Names
  static const String firstOpen = 'firstOpen';
  static const String appLocal = 'appLocal';
  static const String isDarkTheme = 'isDarkTheme';
  static const String primaryColor = 'primaryColor';
  static const String appLogo = 'appLogo';
  static const String appName = 'appName';
  static const String splashLogo = 'splashLogo';

  // Auth Variable Names
  static const String authToken = 'token';

  // User Variable Names
  static const String userData = 'userData';
  static const String storeData = 'storeData';
  static const String cartData = 'cartData';
  static const String defaultAddress = 'defaultAddress';

  static String appCurrency = "\$";
  static String appServiceName = 'ecommerce';

  static String pusherApiKey = 'a3cbadc04a202a7746fc';
  static String pusherCluster = 'mt1';
}

enum FileSystem {
  file,
  image,
}
