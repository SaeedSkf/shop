import Foundation

struct ShopResponseDTO: Decodable, Sendable {
    let home: HomeDTO
    let categories: [CategoryDTO]
    let shops: [ShopItemDTO]
    let banners: [BannerDTO]
    let tags: [TagDTO]
    let labels: [LabelDTO]
}

struct HomeDTO: Decodable, Sendable {
    let search: Bool
    let faq: FAQDTO
    let sections: [HomeSectionDTO]
}

struct FAQDTO: Decodable, Sendable {
    let id: String
    let title: String
    let sections: [FAQItemDTO]
}

struct FAQItemDTO: Decodable, Sendable {
    let title: String
    let description: String
}

struct HomeSectionDTO: Decodable, Sendable {
    let title: String?
    let type: String
    let subType: String?
    let list: [String]
}

struct CategoryDTO: Decodable, Sendable {
    let id: String
    let title: String
    let iconUrl: String
    let status: String
}

struct ShopItemDTO: Decodable, Sendable {
    let id: String
    let title: String
    let iconUrl: String
    let labels: [String]
    let tags: [String]
    let categories: [String]
    let about: AboutDTO
    let type: [String]
    let code: String
    let status: String
}

struct AboutDTO: Decodable, Sendable {
    let title: String
    let description: String
}

struct BannerDTO: Decodable, Sendable {
    let id: String
    let imageUrl: String
}

struct TagDTO: Decodable, Sendable {
    let id: String
    let title: String
    let iconUrl: String
    let status: String
}

struct LabelDTO: Decodable, Sendable {
    let id: String
    let title: String
    let status: String
}
