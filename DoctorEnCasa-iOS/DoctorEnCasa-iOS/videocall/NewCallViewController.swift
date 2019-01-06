//
//  NewCallViewController.swift
//  DoctorEnCasa-iOS
//
//  Created by Agustin Bala on 31/10/2018.
//  Copyright © 2018 Agustin. All rights reserved.
//

import UIKit
import TwilioVideo

class NewCallViewController: UIViewController {
    
    weak var timer: Timer?
    
    @IBOutlet weak var callIconContainer: UIView!
    var videocallId : Int?
    var room : TVIRoom?
    var roomName : String?
    var accessToken : String?
    // Create an audio track
    var localAudioTrack = TVILocalAudioTrack()
    // Create a Capturer to provide content for the video track
    var localVideoTrack : TVILocalVideoTrack?
    var camera:TVICameraCapturer?
    var remoteView: TVIVideoView?
    // `TVIVideoView` created from a storyboard
    @IBOutlet weak var previewView: TVIVideoView!
    var remoteParticipant: TVIRemoteParticipant?
    var isCameraStopped = false

    @IBOutlet weak var rejectButton: UIView!
    @IBOutlet weak var acceptButton: UIImageView!
    @IBOutlet weak var incomingCallContainer: UIView!
    @IBOutlet weak var inProgressContainer: UIView!
    @IBOutlet weak var muteButton: UIImageView!
    @IBOutlet weak var videoButton: UIImageView!
    @IBOutlet weak var changeCameraButton: UIImageView!
    @IBOutlet weak var hangoutButton: UIImageView!
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        // To disconnect from a Room, we call:
        room?.disconnect()
        print("Attempting to disconnect from room \(room?.name)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isSimulator {
            self.previewView.removeFromSuperview()
        } else {
            // Preview our local camera track in the local video preview view.
            self.startPreview()
        }
        
        let flipCameraGesture = UITapGestureRecognizer(target: self, action: #selector(hangout(_:)))
        changeCameraButton.addGestureRecognizer(flipCameraGesture)
        
        let hangoutCameraGesture = UITapGestureRecognizer(target: self, action: #selector(flipCamera(_:)))
        hangoutButton.addGestureRecognizer(hangoutCameraGesture)
        
        let muteCameraGesture = UITapGestureRecognizer(target: self, action: #selector(mute(_:)))
        muteButton.addGestureRecognizer(muteCameraGesture)
        
        let videoCameraGesture = UITapGestureRecognizer(target: self, action: #selector(changeVideo(_:)))
        videoButton.addGestureRecognizer(videoCameraGesture)
        
        let rejectGesture = UITapGestureRecognizer(target: self, action: #selector(reject(_:)))
        rejectButton.addGestureRecognizer(rejectGesture)
        
        let acceptGesture = UITapGestureRecognizer(target: self, action: #selector(accept(_:)))
        acceptButton.addGestureRecognizer(acceptGesture)
        
        self.inProgressContainer.isHidden = true
        self.incomingCallContainer.isHidden = false
        
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(timeout), userInfo: nil, repeats: false)
        
        
    }
    
    @objc func timeout(){
        self.roomName = nil
        self.accessToken = ""
        UserDefaults.standard.set(true, forKey: "CALL_TIMEOUT")
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: NavigationUtil.NAVIGATE.main)
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    func connect(){
        // Prepare local media which we will share with Room Participants.
        self.prepareLocalMedia()
        
        // Preparing the connect options with the access token that we fetched (or hardcoded).
        let connectOptions = TVIConnectOptions.init(token: accessToken!) { (builder) in
            
            // Use the local media that we prepared earlier.
            builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [TVILocalAudioTrack]()
            builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [TVILocalVideoTrack]()
        }
        
        // Connect to the Room using the options we provided.
        room = TwilioVideo.connect(with: connectOptions, delegate: self)
        
        print("Attempting to connect to room")
      
    }
    
    // MARK: Operations
    @objc func reject(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        timer?.invalidate()
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: NavigationUtil.NAVIGATE.main)
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    @objc func accept(_ sender: Any) {
        self.inProgressContainer.isHidden = false
        self.incomingCallContainer.isHidden = true
        connect()
        timer?.invalidate()
    }
        
    // Select between the front and (wide) back camera.
    @objc func flipCamera(_ sender: Any) {
        if let camera = camera {
            if (camera.source == .frontCamera) {
                camera.selectSource(.backCameraWide)
            } else {
                camera.selectSource(.frontCamera)
            }
        }
    }
    
    private func disconnect () {
        self.room?.disconnect()
        self.room = nil
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: NavigationUtil.NAVIGATE.showRank, sender: nil)
    }
    
    @objc func hangout(_ sender: Any) {
        self.cleanupRemoteParticipant()
        disconnect()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? RankCallViewController {
            dvc.videocallId = self.videocallId
        }
    }
    
    @objc func changeVideo(_ sender: Any) {
        if let camera = camera {
            camera.stopCapture()
            self.camera = nil
            self.videoButton.image = UIImage(named: "camera_off")
        } else {
            startPreview()
            self.videoButton.image = UIImage(named: "camera")
        }
    }
    
    @objc func mute(_ sender: Any) {
        if (self.localAudioTrack != nil) {
            self.localAudioTrack?.isEnabled = !(self.localAudioTrack?.isEnabled)!
            
            // Update the button title
            if (self.localAudioTrack?.isEnabled == true) {
                self.muteButton.image = UIImage(named: "mic")
            } else {
                self.muteButton.image = UIImage(named: "mic_off")
            }
        }
    }
    
    func cleanupRemoteParticipant() {
        if ((self.remoteParticipant) != nil) {
            if ((self.remoteParticipant?.videoTracks.count)! > 0) {
                let remoteVideoTrack = self.remoteParticipant?.remoteVideoTracks[0].remoteTrack
                remoteVideoTrack?.removeRenderer(self.remoteView!)
                self.remoteView?.removeFromSuperview()
                self.remoteView = nil
            }
        }
        self.remoteParticipant = nil
        disconnect()
    }
    
    
    func setupRemoteVideoView() {
        // Creating `TVIVideoView` programmatically
        self.remoteView = TVIVideoView.init(frame: CGRect.zero, delegate:self)
        
        self.view.insertSubview(self.remoteView!, at: 0)
        
        // `TVIVideoView` supports scaleToFill, scaleAspectFill and scaleAspectFit
        // scaleAspectFit is the default mode when you create `TVIVideoView` programmatically.
        self.remoteView!.contentMode = .scaleAspectFill;
        
        let centerX = NSLayoutConstraint(item: self.remoteView!,
                                         attribute: NSLayoutConstraint.Attribute.centerX,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: self.view,
                                         attribute: NSLayoutConstraint.Attribute.centerX,
                                         multiplier: 1,
                                         constant: 0);
        self.view.addConstraint(centerX)
        let centerY = NSLayoutConstraint(item: self.remoteView!,
                                         attribute: NSLayoutConstraint.Attribute.centerY,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: self.view,
                                         attribute: NSLayoutConstraint.Attribute.centerY,
                                         multiplier: 1,
                                         constant: 0);
        self.view.addConstraint(centerY)
        let width = NSLayoutConstraint(item: self.remoteView!,
                                       attribute: NSLayoutConstraint.Attribute.width,
                                       relatedBy: NSLayoutConstraint.Relation.equal,
                                       toItem: self.view,
                                       attribute: NSLayoutConstraint.Attribute.width,
                                       multiplier: 1,
                                       constant: 0);
        self.view.addConstraint(width)
        let height = NSLayoutConstraint(item: self.remoteView!,
                                        attribute: NSLayoutConstraint.Attribute.height,
                                        relatedBy: NSLayoutConstraint.Relation.equal,
                                        toItem: self.view,
                                        attribute: NSLayoutConstraint.Attribute.height,
                                        multiplier: 1,
                                        constant: 0);
        self.view.addConstraint(height)
    }
    
    func prepareLocalMedia() {
        
        // We will share local audio and video when we connect to the Room.
        // Create an audio track.
        if (localAudioTrack == nil) {
            localAudioTrack = TVILocalAudioTrack.init(options: nil, enabled: true, name: "Microphone")
            
            if (localAudioTrack == nil) {
                print("Failed to create audio track")
            }
        }
        
        // Create a video track which captures from the camera.
        if (localVideoTrack == nil) {
            self.startPreview()
        }
    }
    
    func startPreview() {
        if isSimulator {
            return
        }
        // Preview our local camera track in the local video preview view.
        camera = TVICameraCapturer(source: .frontCamera, delegate: self)
        // Setup the video constraints
        let videoConstraints = TVIVideoConstraints { (constraints) in
            constraints.maxSize = TVIVideoConstraintsSize1280x960
            constraints.minSize = TVIVideoConstraintsSize1280x960
            constraints.maxFrameRate = TVIVideoConstraintsFrameRate30
            constraints.minFrameRate = TVIVideoConstraintsFrameRate30
        }
        localVideoTrack = TVILocalVideoTrack.init(capturer: camera!, enabled: true, constraints: videoConstraints, name: "Camera")
        if (localVideoTrack == nil) {
            print("Failed to create video track")
        } else {
            // Add renderer to video track for local preview
            localVideoTrack!.addRenderer(self.previewView)
            
            print("Video track created")
            
            // We will flip camera on tap.
            let tap = UITapGestureRecognizer(target: self, action: #selector(flipCamera))
            self.previewView.addGestureRecognizer(tap)
        }
    }
    
    let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
        isSim = true
        #endif
        return isSim
    }()
  
}

// MARK: TVIVideoViewDelegate
extension NewCallViewController : TVIVideoViewDelegate {
    func videoView(_ view: TVIVideoView, videoDimensionsDidChange dimensions: CMVideoDimensions) {
        print("The dimensions of the video track changed to: \(dimensions.width)x\(dimensions.height)")
        self.view.setNeedsLayout()
    }
}

// MARK: TVICameraCapturerDelegate
extension NewCallViewController : TVICameraCapturerDelegate {
    func cameraCapturer(_ capturer: TVICameraCapturer, didStartWith source: TVICameraCaptureSource) {
        self.previewView.shouldMirror = (source == .frontCamera)
    }
}

// MARK: TVIRemoteParticipantDelegate
extension NewCallViewController : TVIRemoteParticipantDelegate {
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           publishedVideoTrack publication: TVIRemoteVideoTrackPublication) {
        
        // Remote Participant has offered to share the video Track.
        
        print("Participant \(participant.identity) published \(publication.trackName) video track")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           unpublishedVideoTrack publication: TVIRemoteVideoTrackPublication) {
        
        // Remote Participant has stopped sharing the video Track.
        print("Participant \(participant.identity) unpublished \(publication.trackName) video track")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           publishedAudioTrack publication: TVIRemoteAudioTrackPublication) {
        
        // Remote Participant has offered to share the audio Track.
        print("Participant \(participant.identity) published \(publication.trackName) audio track")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           unpublishedAudioTrack publication: TVIRemoteAudioTrackPublication) {
        
        // Remote Participant has stopped sharing the audio Track.
        print("Participant \(participant.identity) unpublished \(publication.trackName) audio track")
    }
    
    func subscribed(to videoTrack: TVIRemoteVideoTrack,
                    publication: TVIRemoteVideoTrackPublication,
                    for participant: TVIRemoteParticipant) {
        
        // We are subscribed to the remote Participant's audio Track. We will start receiving the
        // remote Participant's video frames now.
        
        print("Subscribed to \(publication.trackName) video track for Participant \(participant.identity)")
        
        if (self.remoteParticipant == participant) {
            setupRemoteVideoView()
            videoTrack.addRenderer(self.remoteView!)
        }
    }
    
    func unsubscribed(from videoTrack: TVIRemoteVideoTrack,
                      publication: TVIRemoteVideoTrackPublication,
                      for participant: TVIRemoteParticipant) {
        
        // We are unsubscribed from the remote Participant's video Track. We will no longer receive the
        // remote Participant's video.
        
        print(  "Unsubscribed from \(publication.trackName) video track for Participant \(participant.identity)")
        
        if (self.remoteParticipant == participant) {
            videoTrack.removeRenderer(self.remoteView!)
            self.remoteView?.removeFromSuperview()
            self.remoteView = nil
        }
    }
    
    func subscribed(to audioTrack: TVIRemoteAudioTrack,
                    publication: TVIRemoteAudioTrackPublication,
                    for participant: TVIRemoteParticipant) {
        
        // We are subscribed to the remote Participant's audio Track. We will start receiving the
        // remote Participant's audio now.
        
        print("Subscribed to \(publication.trackName) audio track for Participant \(participant.identity)")
    }
    
    func unsubscribed(from audioTrack: TVIRemoteAudioTrack,
                      publication: TVIRemoteAudioTrackPublication,
                      for participant: TVIRemoteParticipant) {
        
        // We are unsubscribed from the remote Participant's audio Track. We will no longer receive the
        // remote Participant's audio.
        
        print("Unsubscribed from \(publication.trackName) audio track for Participant \(participant.identity)")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           enabledVideoTrack publication: TVIRemoteVideoTrackPublication) {
        print("Participant \(participant.identity) enabled \(publication.trackName) video track")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           disabledVideoTrack publication: TVIRemoteVideoTrackPublication) {
        print("Participant \(participant.identity) disabled \(publication.trackName) video track")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           enabledAudioTrack publication: TVIRemoteAudioTrackPublication) {
        print("Participant \(participant.identity) enabled \(publication.trackName) audio track")
    }
    
    func remoteParticipant(_ participant: TVIRemoteParticipant,
                           disabledAudioTrack publication: TVIRemoteAudioTrackPublication) {
        print("Participant \(participant.identity) disabled \(publication.trackName) audio track")
    }
    
    func failedToSubscribe(toAudioTrack publication: TVIRemoteAudioTrackPublication,
                           error: Error,
                           for participant: TVIRemoteParticipant) {
        print("FailedToSubscribe \(publication.trackName) audio track, error = \(String(describing: error))")
    }
    
    func failedToSubscribe(toVideoTrack publication: TVIRemoteVideoTrackPublication,
                           error: Error,
                           for participant: TVIRemoteParticipant) {
        print("FailedToSubscribe \(publication.trackName) video track, error = \(String(describing: error))")
    }
}


// MARK: TVIRoomDelegate
extension NewCallViewController : TVIRoomDelegate {
    func didConnect(to room: TVIRoom) {
        print("Connected to room \(room.name) as \(String(describing: room.localParticipant?.identity))")
        if (room.remoteParticipants.count > 0) {
            self.remoteParticipant = room.remoteParticipants[0]
            self.remoteParticipant?.delegate = self
        }
        
    }
    
    func room(_ room: TVIRoom, didDisconnectWithError error: Error?) {
        print( "Disconncted from room \(room.name), error = \(String(describing: error))")
        self.cleanupRemoteParticipant()
        self.room = nil
    }
    
    func room(_ room: TVIRoom, didFailToConnectWithError error: Error) {
        print("Failed to connect to room with error")
        self.room = nil
    }
    
    func room(_ room: TVIRoom, participantDidConnect participant: TVIRemoteParticipant) {
        if (self.remoteParticipant == nil) {
            self.remoteParticipant = participant
            self.remoteParticipant?.delegate = self
        }
        print("Participant \(participant.identity) connected with \(participant.remoteAudioTracks.count) audio and \(participant.remoteVideoTracks.count) video tracks")
    }
    
    func room(_ room: TVIRoom, participantDidDisconnect participant: TVIRemoteParticipant) {
        if (self.remoteParticipant == participant) {
            cleanupRemoteParticipant()
        }
        print("Room \(room.name), Participant \(participant.identity) disconnected")
    }
}

extension NewCallViewController {
  
    
}
