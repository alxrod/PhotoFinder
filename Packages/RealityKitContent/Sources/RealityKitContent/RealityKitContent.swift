import Foundation
import RealityKit

/// Bundle for the RealityKitContent project
public let realityKitContentBundle = Bundle.module


public func entity(named name: String) async -> Entity? {
    do {
        return try await Entity(named: name, in: realityKitContentBundle)

    } catch is CancellationError {
        // The entity initializer can throw this error if an enclosing
        // RealityView disappears before the model loads. Exit gracefully.
        return nil

    } catch let error {
        // Other errors indicate unrecoverable problems.
        fatalError("Failed to load \(name): \(error)")
    }
}


public func findMainModelEntity(in entity: Entity, with cumulativeScale: simd_float3 = [1, 1, 1]) -> ModelEntity? {
    // Calculate the new cumulative scale by multiplying with the current entity's scale
    let newCumulativeScale = cumulativeScale * entity.transform.scale
    
    // Check if the current entity is a ModelEntity
    if let modelEntity = entity as? ModelEntity {
        // Apply the cumulative scale to the modelEntity
        modelEntity.transform.scale = newCumulativeScale
        return modelEntity
    }
    
    // If not, iterate through the children of the current entity
    for child in entity.children {
        // Recursively search for ModelEntity in the children with the updated cumulative scale
        if let modelEntity = findMainModelEntity(in: child, with: newCumulativeScale) {
            return modelEntity
        }
    }
    
    // If no ModelEntity is found, return nil
    return nil
}
