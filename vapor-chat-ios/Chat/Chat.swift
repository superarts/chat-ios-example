import Starscream

//private let chatURL = URL(string: "wss://vapor-chat.herokuapp.com/chat")!
private let chatURL = URL(string: "ws://127.0.0.1:8080/livecast")!

internal class ChatModel {

    let webSocket = WebSocket(url: chatURL)
    lazy var username: String! = "null"

    // Probably not best to store here, but just trying to get something up quickly
    weak var controller: VaporChatController?

    init(_ controller: VaporChatController) {
        self.controller = controller
    }

    func start() {
		webSocket.headers["Authorization"] = "Bearer 3gMQkpHJ02iS/bgfMDwTtw=="
        webSocket.onConnect = { [unowned webSocket, weak self] in
            guard let username = self?.username else { return }
            webSocket.write(string: "{\"username\":\"\(username)\"}")
        }

        webSocket.onText = { [unowned self] text in
			print("received: \(text)")
            let message = ChatMessage(sentBy: .opponent, content: "\(text)", timeStamp: nil, imageUrl: nil)
            self.controller?.addNewMessage(message)
			/*
            guard let data = text.data(using: .utf8) else { return }

            do {
                guard let js = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] else { return }
                guard
                    let username = js["username"] as? String,
                    let content = js["message"] as? String
                    else { return }
                let message = ChatMessage(sentBy: .opponent, content: "\(username): \(content)", timeStamp: nil, imageUrl: nil)
                self.controller?.addNewMessage(message)

            }
            catch {
                print(error)
            }
            */
        }

        webSocket.onDisconnect = { [weak self] err in
            self?.controller?.showDisconnect()
        }

        webSocket.connect()
    }

    func send(_ msg: String) {
        //let json = "{\"message\":\"\(msg)\"}"
        //webSocket.write(string: json)
        webSocket.write(string: msg)
    }
}

