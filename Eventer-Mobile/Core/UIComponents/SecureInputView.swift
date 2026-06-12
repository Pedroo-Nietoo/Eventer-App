import SwiftUI

struct SecureInputView: View {
    var title: String
    @Binding var text: String
    @State private var isSecured: Bool = true
    
    var body: some View {
        HStack {
            if isSecured {
                SecureField(title, text: $text)
                    .textInputAutocapitalization(.never)
            } else {
                TextField(title, text: $text)
                    .textInputAutocapitalization(.never)
            }
            
            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: isSecured ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
