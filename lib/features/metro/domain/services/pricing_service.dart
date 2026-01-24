class PricingService {
  /// Calculates the price based on the number of stations in the route path.
  /// [stationsCount] includes the start and end stations (i.e. number of nodes in path).
  int calculatePrice(int stationsCount) {
    // Metro rules:
    // Up to 9 stations: 8 EGP
    // 10 to 16 stations: 10 EGP
    // 17 to 23 stations: 15 EGP
    // 24+ stations: 20 EGP

    // Logic Assumption: "9 stations" usually means a trip spanning 9 stations (inclusive or exclusive?).
    // Standard interpretation: Trip length.
    // If I go A -> B (2 stations list), length 2.
    // Length 9 -> 8 EGP. Length 10 -> 10 EGP.
    if (stationsCount <= 9) return 8;
    if (stationsCount <= 16) return 10;
    if (stationsCount <= 23) return 15;
    return 20;
  }
}
