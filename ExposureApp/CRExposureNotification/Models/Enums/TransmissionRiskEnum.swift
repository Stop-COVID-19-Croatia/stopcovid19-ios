enum TransmissionRiskEnum: Int {
    case lowRisk = 0
    case mediumRisk = 501
    case highRisk = 769
}

extension TransmissionRiskEnum: Codable {
    public init(from decoder: Decoder) throws {
        self = try TransmissionRiskEnum(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .lowRisk
    }
}
