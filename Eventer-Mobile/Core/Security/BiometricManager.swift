import Foundation
import LocalAuthentication

class BiometricManager {
    
    enum BiometricType {
        case none, touchID, faceID
    }
    
    var supportedBiometricType: BiometricType {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .touchID: return .touchID
            case .faceID: return .faceID
            default: return .none
            }
        }
        return .none
    }
    
    func authenticate(reason: String, completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        completion(true)
                    } else {
                        print("Erro biométrico: \(authenticationError?.localizedDescription ?? "Desconhecido")")
                        completion(false)
                    }
                }
            }
        } else {
            completion(false)
        }
    }
}
