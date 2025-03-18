// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "9ed4af8c6e42e74e9543b289a0857fb3"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: PostData.self)
    ModelRegistry.register(modelType: Profile.self)
  }
}