//
//  ContentView.swift
//  opentok-swiftui-sample
//
//  Created by rpc on 02/08/2019.
//  Copyright © 2019 tokbox. All rights reserved.
//

import SwiftUI
import OpenTok

let kApiKey = ""
let kToken = ""
let kSessionId = ""

struct ContentView: View {
    var otController = OpenTokController()
    
    @State var opentokIsConnected = false
    @State var publisherConnected = false
    @State var subscriberConnected = false

    var body: some View {
        VStack {
            if (!opentokIsConnected) {
                Text("Connecting Opentok session")
            } else {
                if (publisherConnected) {
                    OpenTokView(otController, role: .publisher)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                }
                if (subscriberConnected) {
                    OpenTokView(otController, role: .subscriber)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .onAppear {
            self.otController.contentView = self
            self.otController.connect()
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
enum OpenTokViewRole {
    case publisher
    case subscriber
}
struct OpenTokView: UIViewRepresentable {
    private let otController: OpenTokController
    private let viewRole: OpenTokViewRole
    
    init(_ otController: OpenTokController, role: OpenTokViewRole) {
        self.otController = otController
        self.viewRole = role
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<OpenTokView>) {
        switch(viewRole) {
        case .publisher:
            let pubView = otController.publisher?.view ?? UIView()
            uiView.backgroundColor = UIColor.red
            uiView.addSubview(pubView)
        case .subscriber:
            let subView = otController.subscriber?.view ?? UIView()
            uiView.backgroundColor = UIColor.red
            uiView.addSubview(subView)
        }
    }
    
    func makeUIView(context: UIViewRepresentableContext<OpenTokView>) -> UIView {
        UIView()
    }
}

class OpenTokController : NSObject, OTSessionDelegate, OTPublisherDelegate, OTSubscriberDelegate {
    var session: OTSession?
    var publisher: OTPublisher?
    var subscriber: OTSubscriber?
    var contentView: ContentView?
    
    func connect() {
        session = OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)
        session!.connect(withToken: kToken, error: nil)
    }
            
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        subscriber = OTSubscriber(stream: stream, delegate: self)
        session.subscribe(subscriber!, error: nil)
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
    }
    
    func sessionDidConnect(_ session: OTSession) {
        publisher = OTPublisher(delegate: self)
        contentView?.publisherConnected = true
        session.publish(publisher!, error: nil)
        
        contentView?.opentokIsConnected = true
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        contentView?.opentokIsConnected = false
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
    }
    
    func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
        contentView?.subscriberConnected = true
    }
}
