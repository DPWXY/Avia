// swiftlint:disable all
import Amplify
import Foundation

public struct Profile: Model {
  public let id: String
  public var username: String?
  public var userId: String?
  public var profileImage: String?
  public var rank: String?
  public var hours: Int?
  public var followers: Int?
  public var groups: Int?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      username: String? = nil,
      userId: String? = nil,
      profileImage: String? = nil,
      rank: String? = nil,
      hours: Int? = nil,
      followers: Int? = nil,
      groups: Int? = nil) {
    self.init(id: id,
      username: username,
      userId: userId,
      profileImage: profileImage,
      rank: rank,
      hours: hours,
      followers: followers,
      groups: groups,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      username: String? = nil,
      userId: String? = nil,
      profileImage: String? = nil,
      rank: String? = nil,
      hours: Int? = nil,
      followers: Int? = nil,
      groups: Int? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.username = username
      self.userId = userId
      self.profileImage = profileImage
      self.rank = rank
      self.hours = hours
      self.followers = followers
      self.groups = groups
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}