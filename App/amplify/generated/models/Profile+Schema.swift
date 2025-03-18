// swiftlint:disable all
import Amplify
import Foundation

extension Profile {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case username
    case userId
    case profileImage
    case rank
    case hours
    case followers
    case groups
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let profile = Profile.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "Profiles"
    model.syncPluralName = "Profiles"
    
    model.attributes(
      .primaryKey(fields: [profile.id])
    )
    
    model.fields(
      .field(profile.id, is: .required, ofType: .string),
      .field(profile.username, is: .optional, ofType: .string),
      .field(profile.userId, is: .optional, ofType: .string),
      .field(profile.profileImage, is: .optional, ofType: .string),
      .field(profile.rank, is: .optional, ofType: .string),
      .field(profile.hours, is: .optional, ofType: .int),
      .field(profile.followers, is: .optional, ofType: .int),
      .field(profile.groups, is: .optional, ofType: .int),
      .field(profile.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(profile.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension Profile: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}