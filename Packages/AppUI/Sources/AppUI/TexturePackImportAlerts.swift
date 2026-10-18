import SwiftUI

struct TexturePackImportAlerts: ViewModifier {
    let flow: TexturePackImportFlow
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .alert(
                Text("texturePacks.notice.title", bundle: .module),
                isPresented: Binding(get: { isActive && flow.pendingAction != nil }, set: { _ in })
            ) {
                Button {
                    Task { await flow.acceptNotice() }
                } label: {
                    Text("texturePacks.notice.continue", bundle: .module)
                }
                Button(role: .cancel) {
                    flow.declineNotice()
                } label: {
                    Text("common.cancel", bundle: .module)
                }
            } message: {
                Text("texturePacks.notice.message", bundle: .module)
            }
            .alert(
                outcomeTitle,
                isPresented: Binding(get: { isActive && flow.outcome != nil }, set: { _ in })
            ) {
                Button {
                    flow.dismissOutcome()
                } label: {
                    Text("common.ok", bundle: .module)
                }
            } message: {
                outcomeMessage
            }
            .overlay {
                if isActive && flow.isImporting {
                    ProgressView()
                        .controlSize(.large)
                        .padding(24)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
    }

    private var outcomeTitle: Text {
        switch flow.outcome {
        case .installed: Text("texturePacks.import.success.title", bundle: .module)
        case .failed, nil: Text("texturePacks.import.failure.title", bundle: .module)
        }
    }

    private var outcomeMessage: Text {
        switch flow.outcome {
        case .installed(let name): Text("texturePacks.import.success.message \(name)", bundle: .module)
        case .failed(let message): Text(verbatim: message)
        case nil: Text(verbatim: "")
        }
    }
}

extension View {
    func texturePackImportAlerts(_ flow: TexturePackImportFlow, isActive: Bool) -> some View {
        modifier(TexturePackImportAlerts(flow: flow, isActive: isActive))
    }
}
