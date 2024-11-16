import Foundation
import GCDWebServer

class LocalServerManager {
  static let instance = LocalServerManager()
  let webServer = GCDWebServer()
  let deviceTokenKey = "deviceToken"
  public func startServer() {
    webServer.addGETHandler(forBasePath: "/", directoryPath: NSHomeDirectory(), indexFilename: nil, cacheAge: 3600, allowRangeRequests: true)
    webServer.start(withPort: 8080, bonjourName: "GCD Web Server")
  }
}
