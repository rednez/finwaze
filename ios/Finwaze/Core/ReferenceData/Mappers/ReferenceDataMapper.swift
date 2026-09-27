import Foundation

nonisolated enum ReferenceDataMapper {
    static func toAccount(_ dto: AccountDto) -> Account {
        Account(id: dto.id, name: dto.name, currencyCode: dto.currencies.code)
    }

    static func toCurrency(_ dto: CurrencyDto) -> Currency {
        Currency(id: dto.id, code: dto.code, name: dto.name, countryName: dto.countryName)
    }

    static func toGroup(_ dto: GroupDto) -> CategoryGroup {
        CategoryGroup(id: dto.id, name: dto.name, transactionType: dto.transactionType, color: dto.color)
    }

    static func toCategory(_ dto: CategoryDto) -> Category {
        Category(id: dto.id, name: dto.name, groupID: dto.groupID, color: dto.color)
    }
}
