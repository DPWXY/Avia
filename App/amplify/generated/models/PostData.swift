// swiftlint:disable all
import Amplify
import Foundation

public struct PostData: Model {
  public let id: String
  public var username: String?
  public var userId: String?
  public var title: String?
  public var content: String?
  public var uiImage: String?
  public var date: Temporal.Date?
  public var duration: Double?
  public var distance: Double?
  public var likes: Int?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      username: String? = nil,
      userId: String? = nil,
      title: String? = nil,
      content: String? = nil,
      uiImage: String? = nil,
      date: Temporal.Date? = nil,
      duration: Double? = nil,
      distance: Double? = nil,
      likes: Int? = nil) {
    self.init(id: id,
      username: username,
      userId: userId,
      title: title,
      content: content,
      uiImage: uiImage,
      date: date,
      duration: duration,
      distance: distance,
      likes: likes,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      username: String? = nil,
      userId: String? = nil,
      title: String? = nil,
      content: String? = nil,
      uiImage: String? = nil,
      date: Temporal.Date? = nil,
      duration: Double? = nil,
      distance: Double? = nil,
      likes: Int? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.username = username
      self.userId = userId
      self.title = title
      self.content = content
      self.uiImage = uiImage
      self.date = date
      self.duration = duration
      self.distance = distance
      self.likes = likes
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}