import Foundation
import Capacitor
import Alamofire
import AVKit
import UIKit

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(Ricoh360CameraPlugin)
public class Ricoh360CameraPlugin: CAPPlugin, CAPBridgedPlugin, URLSessionDataDelegate {
    public let identifier = "Ricoh360CameraPlugin"
    public let jsName = "Ricoh360Camera"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "initialize", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "capturePicture", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "readSettings", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "setSettings", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "livePreview", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "stopLivePreview", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "captureVideo", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "sendCommand", returnType: CAPPluginReturnPromise),
    ]

    private var previewView: UIImageView?
    private var cameraUrl: String = "http://192.168.1.1"
    private var httpStream: HttpStream?

    enum RicohThetaError: Error {
        case invalidUrl, badResponse, parseImageProvider, parseCGImage
    }

    private let startMarker = Data([0xFF, 0xD8])
    private let endMarker = Data([0xFF, 0xD9])
    private var buffer = Data()
    private var session: URLSession
    private var task: URLSessionTask?
    private var imageCompletion: ((UIImage?, Error?) -> Void)?

    override init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config, delegate: nil, delegateQueue: OperationQueue.main)
        super.init()
    }

    struct CameraInfo: Decodable {
        let model: String
        let firmwareVersion: String
        let manufacturer: String
        let serialNumber: String
        let supportUrl: String
        let gps: String
        let gyro: String
        let uptime: String
        let api: String
        let apiLevel: String
        let endpoints: Endpoints
    }

    struct Endpoints: Decodable {
        let httpPort: String
        let httpUpdatesPort: String
    }

    struct CommandResponse: Decodable {
        let name: String
        let state: String
        let results: CommandResults?
        let error: CommandError?
    }

    struct CommandResults: Decodable {
        // Define fields based on the specific command response
    }

    struct CommandError: Decodable {
        let code: String
        let message: String
    }

    protocol HttpStreamProtocol: URLSessionDataDelegate {
        init(request: URLRequest)
        func startLivePreview(completion: @escaping (UIImage?, Error?) -> Void)
        func stopLivePreview()
    }

    final class HttpStream: NSObject, HttpStreamProtocol {
        enum HttpStreamError: Error {
            case badResponse, parseImageProvider, parseCGImage
        }

        let startMarker = Data([0xFF, 0xD8])
        let endMarker = Data([0xFF, 0xD9])
        let queue = DispatchQueue(label: "com.ricoh.theta.stream.queue")

        var buffer = Data()
        var request: URLRequest
        var task: URLSessionTask?
        var isLivePreviewing: Bool = false
        var imageCompletion: ((UIImage?, Error?) -> Void)?

        deinit {
            self.stopLivePreview()
        }

        required init(request: URLRequest) {
            self.request = request
            super.init()
        }

        public func startLivePreview(completion: @escaping (UIImage?, Error?) -> Void) {
            if !self.isLivePreviewing {
                self.imageCompletion = completion
                let payload = ["name": "camera.getLivePreview"]
                self.request.httpBody = try? JSONEncoder().encode(payload)
                self.request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                self.request.setValue("application/json", forHTTPHeaderField: "Accept")

                let config = URLSessionConfiguration.default
                config.timeoutIntervalForRequest = 5
                config.waitsForConnectivity = true
                let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)

                self.task = session.dataTask(with: self.request)
                self.task?.resume()
                self.isLivePreviewing = true
            }
        }

        public func stopLivePreview() {
            self.task?.cancel()
        }

        func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            guard let response = dataTask.response as? HTTPURLResponse, response.statusCode == 200 else {
                self.imageCompletion?(nil, HttpStreamError.badResponse)
                return
            }

            if data.range(of: self.startMarker) != nil {
                self.buffer = Data()
            }
            
            self.buffer.append(data)
            
            if data.range(of: self.endMarker) != nil {
                self.parseFrame(self.buffer) { [weak self] image, error in
                    guard let self = self else { return }
                    self.imageCompletion?(image, error)
                }
            }
        }

        func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            session.invalidateAndCancel()
            self.isLivePreviewing = false
            self.imageCompletion?(nil, error)
        }

        private func parseFrame(_ data: Data, _ completion: @escaping ((UIImage?, Error?) -> Void)) {
            self.queue.async {
                guard let imgProvider = CGDataProvider(data: data as CFData) else {
                    completion(nil, HttpStreamError.parseImageProvider)
                    return
                }

                guard let image = CGImage(
                        jpegDataProviderSource: imgProvider,
                        decode: nil,
                        shouldInterpolate: true,
                        intent: .defaultIntent) else {
                    completion(nil, HttpStreamError.parseCGImage)
                    return
                }

                completion(UIImage(cgImage: image), nil)
            }
        }
    }

    @objc func initialize(_ call: CAPPluginCall) {
        if let url = call.getString("url") {
            cameraUrl = url
        }

        let infoUrl = "\(cameraUrl)/osc/info"
        AF.request(infoUrl).validate().responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        call.resolve(["session": "Initialized", "info": json])
                    } else {
                        call.reject("Camera is not reachable or info could not be retrieved")
                    }
                } catch {
                    call.reject("Camera is not reachable or info could not be retrieved")
                }
            case .failure(let error):
                call.reject("Camera is not reachable or info could not be retrieved")
            }
        }
    }

    @objc func livePreview(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            if self.previewView == nil {
                self.previewView = UIImageView(frame: self.bridge?.viewController?.view.bounds ?? CGRect.zero)
                self.previewView?.backgroundColor = .clear
                self.previewView?.contentMode = .scaleAspectFit
                let displayInFront = call.getBool("displayInFront") ?? true

                // Make webview transparent
                self.webView?.isOpaque = false
                self.webView?.backgroundColor = UIColor.clear
                self.webView?.scrollView.backgroundColor = UIColor.clear
                
                if displayInFront {
                    self.bridge?.viewController?.view.addSubview(self.previewView!)
                } else {
                    self.webView?.superview?.addSubview(self.previewView!)
                    if !displayInFront {
                        self.webView?.superview?.bringSubviewToFront(self.webView!)
                    }
                }
            }

            let url = URL(string: "\(self.cameraUrl)/osc/commands/execute")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            self.httpStream = HttpStream(request: request)
            self.httpStream?.startLivePreview { [weak self] (image: UIImage?, error: Error?) in
                guard let self = self else { return }
                if let image = image {
                    DispatchQueue.main.async {
                        self.previewView?.image = image
                    }
                }
            }
        }
        call.resolve(["preview": "Started"])
    }

    @objc func stopLivePreview(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            self.httpStream?.stopLivePreview()
            self.previewView?.removeFromSuperview()
            self.previewView = nil
            
            // Revert webview transparency
            self.webView?.isOpaque = true
            self.webView?.backgroundColor = .white
            self.webView?.scrollView.backgroundColor = .white
            
            call.resolve(["preview": "Stopped"])
        }
    }

    @objc func capturePicture(_ call: CAPPluginCall) {
        let parameters: [String: Any] = ["name": "camera.takePicture"]
        let captureUrl = "\(cameraUrl)/osc/commands/execute"
        print("Capturing picture with URL: \(captureUrl)")
        
        AF.request(captureUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseDecodable(of: CommandResponse.self) { response in
            switch response.result {
            case .success(let value):
                print("Picture captured: \(value)")
                call.resolve(["picture": value])
            case .failure(let error):
                print("Failed to capture picture: \(error.localizedDescription)")
                call.reject("Failed to take picture", error.localizedDescription)
            }
        }
    }

    @objc func readSettings(_ call: CAPPluginCall) {
        guard let data = call.options,
              let jsonData = try? JSONSerialization.data(withJSONObject: data),
              let options = String(data: jsonData, encoding: .utf8) else {
            call.reject("Invalid options")
            return
        }
        
        let jsonInputString = """
        {"name": "camera.getOptions", "parameters": {"optionNames": \(options)}}
        """
        
        guard let url = URL(string: cameraUrl + "/osc/commands/execute") else {
            call.reject("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonInputString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                call.reject("Failed to read settings", error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                call.reject("Failed to read settings")
                return
            }
            
            if httpResponse.statusCode == 200 {
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    if let results = json?["results"] as? [String: Any],
                       let options = results["options"] as? [String: Any],
                       let optionsData = try? JSONSerialization.data(withJSONObject: options),
                       let optionsString = String(data: optionsData, encoding: .utf8) {
                        call.resolve(["settings": optionsString])
                    } else {
                        call.reject("Failed to parse settings response")
                    }
                } catch {
                    call.reject("Failed to parse settings response", error.localizedDescription)
                }
            } else {
                if let error = String(data: data, encoding: .utf8) {
                    call.reject("Failed to read settings: \(error)")
                } else {
                    call.reject("Failed to read settings")
                }
            }
        }
        task.resume()
    }

    @objc func setSettings(_ call: CAPPluginCall) {
        guard let data = call.options,
              let jsonData = try? JSONSerialization.data(withJSONObject: data),
              let options = String(data: jsonData, encoding: .utf8) else {
            call.reject("Invalid options")
            return
        }
        
        let jsonInputString = """
        {"name": "camera.setOptions", "parameters": {"options": \(options)}}
        """
        
        guard let url = URL(string: cameraUrl + "/osc/commands/execute") else {
            call.reject("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonInputString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                call.reject("Failed to set settings", error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                call.reject("Failed to set settings")
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let result = String(data: data, encoding: .utf8) {
                    call.resolve(["settings": result])
                } else {
                    call.reject("Failed to parse settings response")
                }
            } else {
                if let error = String(data: data, encoding: .utf8) {
                    call.reject("Failed to set settings: \(error)")
                } else {
                    call.reject("Failed to set settings")
                }
            }
        }
        task.resume()
    }

    @objc func sendCommand(_ call: CAPPluginCall) {
        guard let endpoint = call.getString("endpoint"),
              let data = call.getObject("payload"),
              let jsonData = try? JSONSerialization.data(withJSONObject: data),
              let payload = String(data: jsonData, encoding: .utf8) else {
            call.reject("Invalid endpoint or payload")
            return
        }
        
        guard let url = URL(string: cameraUrl + endpoint) else {
            call.reject("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = payload.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                call.reject("Command failed", error.localizedDescription)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  let data = data else {
                call.reject("Command failed")
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let result = String(data: data, encoding: .utf8),
                   let jsonData = result.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                    call.resolve(json)
                } else {
                    call.reject("Failed to parse command response")
                }
            } else {
                if let error = String(data: data, encoding: .utf8) {
                    call.reject("Command failed: \(error)")
                } else {
                    call.reject("Command failed")
                }
            }
        }
        task.resume()
    }

    private func startLivePreview(completion: @escaping (UIImage?, Error?) -> Void) {
        self.imageCompletion = completion
        self.startLivePreview(completion: completion)
    }
        
    private func stopLivePreview() {
        print("Stopping live preview")
        self.task?.cancel()
    }
        
    private func processMJPEGStream(data: Data) {
        if data.range(of: self.startMarker) != nil {
            self.buffer = Data()
        }
        
        self.buffer.append(data)
        
        if data.range(of: self.endMarker) != nil {
            self.parseFrame(self.buffer) { [weak self] image, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error parsing frame: \(error)")
                } else if let image = image {
                    print("Frame parsed successfully")
                    DispatchQueue.main.async {
                        self.previewView?.image = image
            }
        }
            }
        }
    }

    private func parseFrame(_ data: Data, _ completion: @escaping ((UIImage?, Error?) -> Void)) {
        DispatchQueue.global().async {
            guard let imgProvider = CGDataProvider(data: data as CFData) else {
                completion(nil, RicohThetaError.parseImageProvider)
                return
                }
                
            guard let image = CGImage(
                jpegDataProviderSource: imgProvider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent) else {
                completion(nil, RicohThetaError.parseCGImage)
                return
            }
            
            completion(UIImage(cgImage: image), nil)
        }
    }
}
