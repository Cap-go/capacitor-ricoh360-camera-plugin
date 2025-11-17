import Foundation
import Capacitor
import Alamofire
import AVKit
import UIKit
import Network

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(Ricoh360CameraPlugin)
public class Ricoh360CameraPlugin: CAPPlugin, CAPBridgedPlugin, URLSessionDataDelegate {
    private let pluginVersion: String = "7.2.9"
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
        CAPPluginMethod(name: "getCameraAsset", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "listFiles", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getPluginVersion", returnType: CAPPluginReturnPromise)
    ]

    private var previewView: UIImageView?
    private var cameraUrl: String = "http://192.168.1.1"
    private var httpStream: HttpStream?
    private var connection: NWConnection?
    private var browser: NWBrowser?
    private var permissionCompletion: ((Bool) -> Void)?

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
        init(request: URLRequest, plugin: Ricoh360CameraPlugin)
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
        weak var plugin: Ricoh360CameraPlugin?

        deinit {
            self.stopLivePreview()
        }

        required init(request: URLRequest, plugin: Ricoh360CameraPlugin) {
            self.request = request
            self.plugin = plugin
            super.init()
        }

        func startLivePreview(completion: @escaping (UIImage?, Error?) -> Void) {
            if !self.isLivePreviewing {
                self.imageCompletion = completion
                let payload = ["name": "camera.getLivePreview"]
                self.request.httpBody = try? JSONEncoder().encode(payload)
                self.request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                self.request.setValue("application/json", forHTTPHeaderField: "Accept")

                let config = URLSessionConfiguration.default
                config.timeoutIntervalForRequest = 5
                config.waitsForConnectivity = true

                plugin?.requestLocalNetworkPermission { [weak self] granted in
                    guard let self = self else { return }

                    if granted {
                        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
                        self.task = session.dataTask(with: self.request)
                        self.task?.resume()
                        self.isLivePreviewing = true
                    } else {
                        self.imageCompletion?(nil, HttpStreamError.badResponse)
                    }
                }
            }
        }

        func stopLivePreview() {
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

        requestLocalNetworkPermission { [weak self] granted in
            if granted {
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
            } else {
                call.reject("Permission not granted")
            }
        }
    }

    @objc func livePreview(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            if self.previewView == nil {
                let displayInFront = call.getBool("displayInFront") ?? true
                let cropPreview = call.getBool("cropPreview") ?? false

                // Create preview view with zero frame initially
                self.previewView = UIImageView(frame: .zero)
                self.previewView?.backgroundColor = .clear
                self.previewView?.contentMode = cropPreview ? .scaleAspectFill : .scaleAspectFit
                self.previewView?.clipsToBounds = cropPreview // Only clip bounds if cropping

                // Make webview transparent
                self.webView?.isOpaque = false
                self.webView?.backgroundColor = UIColor.clear
                self.webView?.scrollView.backgroundColor = UIColor.clear

                if let previewView = self.previewView {
                    if displayInFront {
                        self.bridge?.viewController?.view.addSubview(previewView)
                    } else {
                        self.webView?.superview?.addSubview(previewView)
                        self.webView?.superview?.bringSubviewToFront(self.webView!)
                    }

                    // Make preview view fill parent
                    previewView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        previewView.topAnchor.constraint(equalTo: previewView.superview!.topAnchor),
                        previewView.bottomAnchor.constraint(equalTo: previewView.superview!.bottomAnchor),
                        previewView.leadingAnchor.constraint(equalTo: previewView.superview!.leadingAnchor),
                        previewView.trailingAnchor.constraint(equalTo: previewView.superview!.trailingAnchor)
                    ])
                }
            }

            let url = URL(string: "\(self.cameraUrl)/osc/commands/execute")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"

            self.httpStream = HttpStream(request: request, plugin: self)
            self.httpStream?.startLivePreview { [weak self] (image: UIImage?, _: Error?) in
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
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters),
              let jsonInputString = String(data: jsonData, encoding: .utf8) else {
            call.reject("Failed to serialize parameters")
            return
        }

        sendCommandRaw(endpoint: "/osc/commands/execute", payload: jsonInputString, call: call)
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

        sendCommandRaw(endpoint: "/osc/commands/execute", payload: jsonInputString, call: call)
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

        sendCommandRaw(endpoint: "/osc/commands/execute", payload: jsonInputString, call: call)
    }

    @objc func sendCommand(_ call: CAPPluginCall) {
        guard let endpoint = call.getString("endpoint"),
              let data = call.getObject("payload"),
              let jsonData = try? JSONSerialization.data(withJSONObject: data),
              let payload = String(data: jsonData, encoding: .utf8) else {
            call.reject("Invalid endpoint or payload")
            return
        }

        sendCommandRaw(endpoint: endpoint, payload: payload, call: call)
    }

    private func sendCommandRaw(endpoint: String, payload: String, call: CAPPluginCall) {
        guard let url = URL(string: cameraUrl + endpoint) else {
            call.reject("Invalid URL")
            return
        }

        requestLocalNetworkPermission { [weak self] granted in
            print("Permission flow completed with result: \(granted)")
            if granted {
                print("Proceeding with socket connection")
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
            } else {
                print("Permission not granted")
                call.reject("Permission not granted")
            }
        }
    }

    private func requestLocalNetworkPermission(completion: @escaping (Bool) -> Void) {
        self.permissionCompletion = completion

        // Use Bonjour browsing to trigger local network permission
        let parameters = NWParameters()
        parameters.includePeerToPeer = true

        // Browse for all services
        let browser = NWBrowser(for: .bonjour(type: "_http._tcp", domain: nil), using: parameters)
        self.browser = browser

        browser.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                print("Browser is ready")
                self?.permissionCompletion?(true)
                self?.browser?.cancel()
            case .failed(let error):
                print("Browser failed: \(error)")
                if let error = error as? NWError {
                    switch error {
                    case .dns(let dnsError):
                        print("DNS error: \(dnsError)")
                    case .posix(let code):
                        print("POSIX error: \(code)")
                    default:
                        print("Other error: \(error)")
                    }
                }
                self?.permissionCompletion?(false)
                self?.browser?.cancel()
            case .cancelled:
                print("Browser was cancelled")
            case .waiting(let error):
                print("Browser is waiting: \(error)")
            default:
                break
            }
        }

        browser.browseResultsChangedHandler = { results, _ in
            print("Found \(results.count) services")
            for result in results {
                print("Service: \(result.endpoint)")
            }
        }

        print("Starting network service browser")
        browser.start(queue: .main)

        // Set a timeout
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            if self?.browser != nil {
                print("Browser timeout - proceeding anyway")
                self?.permissionCompletion?(true)
                self?.browser?.cancel()
            }
        }
    }

    @objc func getCameraAsset(_ call: CAPPluginCall) {
        guard let assetUrl = call.getString("url") else {
            call.reject("URL is required")
            return
        }

        let saveToFile = call.getBool("saveToFile", false)

        guard let url = URL(string: assetUrl) else {
            call.reject("Invalid URL")
            return
        }

        requestLocalNetworkPermission { [weak self] granted in
            guard let self = self else { return }

            if granted {
                let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                    guard let self = self else { return }

                    if let error = error {
                        call.reject("Failed to fetch asset: \(error.localizedDescription)")
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse,
                          let data = data else {
                        call.reject("Failed to fetch asset")
                        return
                    }

                    var result = JSObject()
                    result["statusCode"] = httpResponse.statusCode

                    if saveToFile {
                        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                        let filename = "ricoh_\(timestamp).jpg"
                        let tempDir = FileManager.default.temporaryDirectory
                        let fileURL = tempDir.appendingPathComponent(filename)

                        do {
                            try data.write(to: fileURL)
                            result["filePath"] = fileURL.path
                            call.resolve(result)
                        } catch {
                            call.reject("Failed to save file: \(error.localizedDescription)")
                        }
                    } else {
                        // Downsize and convert to base64
                        if let downsizedData = self.downSizeImage(data) {
                            let base64String = downsizedData.base64EncodedString()
                            result["data"] = base64String
                            call.resolve(result)
                        } else {
                            call.reject("Failed to process image")
                        }
                    }
                }
                task.resume()
            } else {
                call.reject("Permission not granted")
            }
        }
    }

    private func downSizeImage(_ imageData: Data) -> Data? {
        let maxWidth: CGFloat = 2048 // Must be equal to or less than 4096

        guard let image = UIImage(data: imageData) else { return nil }
        let originalWidth = image.size.width

        if originalWidth > maxWidth {
            let scaleFactor = maxWidth / originalWidth
            let newSize = CGSize(width: originalWidth * scaleFactor, height: image.size.height * scaleFactor)

            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
                UIGraphicsEndImageContext()
                return nil
            }
            UIGraphicsEndImageContext()

            return resizedImage.jpegData(compressionQuality: 1.0)
        }

        return imageData
    }

    @objc func listFiles(_ call: CAPPluginCall) {
        var parameters = JSObject()
        parameters["fileType"] = call.getString("fileType", "all")
        parameters["startPosition"] = call.getInt("startPosition", 0)
        parameters["entryCount"] = call.getInt("entryCount", 100)
        parameters["maxThumbSize"] = call.getInt("maxThumbSize", 0)
        parameters["_detail"] = call.getBool("_detail", true)

        var payload = JSObject()
        payload["name"] = "camera.listFiles"
        payload["parameters"] = parameters

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload),
              let jsonInputString = String(data: jsonData, encoding: .utf8) else {
            call.reject("Failed to serialize parameters")
            return
        }

        sendCommandRaw(endpoint: "/osc/commands/execute", payload: jsonInputString, call: call)
    }

    @objc func getPluginVersion(_ call: CAPPluginCall) {
        call.resolve(["version": self.pluginVersion])
    }

}
