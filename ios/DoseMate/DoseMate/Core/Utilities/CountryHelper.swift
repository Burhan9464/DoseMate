import Foundation

struct CountryItem: Identifiable, Hashable {
    var id: String { code }
    let name: String
    let code: String
    let flag: String
}

enum CountryHelper {
    static let allCountries: [CountryItem] = [
        CountryItem(name: "United States", code: "US", flag: "🇺🇸"),
        CountryItem(name: "Canada", code: "CA", flag: "🇨🇦"),
        CountryItem(name: "United Kingdom", code: "GB", flag: "🇬🇧"),
        CountryItem(name: "Australia", code: "AU", flag: "🇦🇺"),
        CountryItem(name: "Germany", code: "DE", flag: "🇩🇪"),
        CountryItem(name: "France", code: "FR", flag: "🇫🇷"),
        CountryItem(name: "Pakistan", code: "PK", flag: "🇵🇰"),
        CountryItem(name: "India", code: "IN", flag: "🇮🇳"),
        CountryItem(name: "United Arab Emirates", code: "AE", flag: "🇦🇪"),
        CountryItem(name: "Saudi Arabia", code: "SA", flag: "🇸🇦"),
        CountryItem(name: "Singapore", code: "SG", flag: "🇸🇬"),
        CountryItem(name: "Japan", code: "JP", flag: "🇯🇵"),
        CountryItem(name: "South Korea", code: "KR", flag: "🇰🇷"),
        CountryItem(name: "Spain", code: "ES", flag: "🇪🇸"),
        CountryItem(name: "Italy", code: "IT", flag: "🇮🇹"),
        CountryItem(name: "Netherlands", code: "NL", flag: "🇳🇱"),
        CountryItem(name: "Brazil", code: "BR", flag: "🇧🇷"),
        CountryItem(name: "Mexico", code: "MX", flag: "🇲🇽"),
        CountryItem(name: "South Africa", code: "ZA", flag: "🇿🇦"),
        CountryItem(name: "New Zealand", code: "NZ", flag: "🇳🇿"),
        CountryItem(name: "Switzerland", code: "CH", flag: "🇨🇭"),
        CountryItem(name: "Sweden", code: "SE", flag: "🇸🇪"),
        CountryItem(name: "Norway", code: "NO", flag: "🇳🇴"),
        CountryItem(name: "Turkey", code: "TR", flag: "🇹🇷"),
        CountryItem(name: "Egypt", code: "EG", flag: "🇪🇬")
    ].sorted { $0.name < $1.name }
}
