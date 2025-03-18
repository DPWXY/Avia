// swiftlint:disable all
import Amplify
import Foundation

extension PostData {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case username
    case userId
    case title
    case content
    case uiImage
    case date
    case duration
    case distance
    case likes
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let postData = PostData.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.listPluralName = "PostData"
    model.syncPluralName = "PostData"
    
    model.attributes(
      .primaryKey(fields: [postData.id])
    )
    
    model.fields(
      .field(postData.id, is: .required, ofType: .string),
      .field(postData.username, is: .optional, ofType: .string),
      .field(postData.userId, is: .optional, ofType: .string),
      .field(postData.title, is: .optional, ofType: .string),
      .field(postData.content, is: .optional, ofType: .string),
      .field(postData.uiImage, is: .optional, ofType: .string),
      .field(postData.date, is: .optional, ofType: .date),
      .field(postData.duration, is: .optional, ofType: .double),
      .field(postData.distance, is: .optional, ofType: .double),
      .field(postData.likes, is: .optional, ofType: .int),
      .field(postData.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(postData.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension PostData: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}