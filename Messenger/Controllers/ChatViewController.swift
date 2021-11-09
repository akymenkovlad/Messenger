//
//  ChatViewController.swift
//  Messenger
//
//  Created by Valados on 08.11.2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import CloudKit

struct Message : MessageType{
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}
extension MessageKind{
    var messageKindString: String{
        switch self{
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_tex"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}
struct Sender: SenderType{
   public var photoURL: String
   public var senderId: String
   public var displayName: String
}

class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public var isNewConversation = false
    public let otherUserEMail: String
    private let conversationId: String?
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
       return Sender(photoURL: " ",
               senderId: safeEmail,
               displayName: "Me")
    }
    
    private func listenForMessages(id:String, shouldScrollToBottom:Bool){
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self]result in
            switch result {
            case .success(let messages):
                print("success in getting messages")
                guard !messages.isEmpty else{
                    print("messages are empty")
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom{
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
                
            case .failure(let error):
                print("failed to get messages:\(error)")
            }
        })
    }
    
    init(with email:String, id:String?){
        self.otherUserEMail = email
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId {
            listenForMessages(id:conversationId, shouldScrollToBottom: true)
        }
    }
}
extension ChatViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else{
                  return
              }
        print("Sending:\(text)")
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        //Send message
        if isNewConversation{
            //create conversation in database
            DatabaseManager.shared.createNewConversation(with: otherUserEMail,
                                                     name: self.title ?? "User",
                                                     firstMessage: message,
                                                     completion: { [weak self] success in
                if success{
                    print("message sent")
                    self?.isNewConversation = false
                }
                else{
                    print("message wasnt sent")
                }
            })
        }
        else{
            guard let conversationId = conversationId, let name = self.title else{
                return
            }
            //append to existing conversation data
            DatabaseManager.shared.sendMessage(to: conversationId,otherUserEmail:otherUserEMail, name: name, newMessage: message, completion: {success in
                if success{
                    print("message sent")
                }
                else{
                    print("failed to send")
                }
            })
        }
    }
    
    private func createMessageId()->String?{
        //date, otherUserEmail,senderEmail,randomInt
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            return nil
        }
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEMail)_\(safeCurrentEmail)_\(dateString)"
        print("Created message id:\(newIdentifier)")
        return newIdentifier
        
    }
}
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    func currentSender() -> SenderType {
        if let sender = selfSender{
            return sender
        }
        fatalError("Self Sender is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
