import Kitura
import Foundation
import Dispatch
import HeliumLogger

HeliumLogger.use()

let router = Router()

let queue = DispatchQueue(label: "clientmsg", attributes: .concurrent)
let timer = DispatchSource.makeTimerSource(flags: [], queue: queue)

timer.scheduleRepeating(deadline: .now(), interval: .seconds(2))


timer.setEventHandler {
    
    var request = URLRequest(url: URL(string: "http://localhost:8090")!)
    
    
    request.httpMethod = "POST"
    request.httpBody = Data()
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("awesome", forHTTPHeaderField: "Test-Header")
    
    let task = URLSession.shared.dataTask(with: request) {
        data, response, error in
        
        // print(response)
        
    }
    
    task.resume()
    
    print("Send a message")
}

timer.resume()

router.get("/") {
    request, response, next in
    response.send("Hello, World!")
    next()
}


router.post("/") {
    request, response, next in
    
    request.headers.forEach {
        print($0)
    }
    
    print(request.userInfo)
    
    response.status(.OK).send("OK")
    
    
    next()
}

// Look for environment variables for PORT
let envVars = ProcessInfo.processInfo.environment
let portString: String = envVars["PORT"] ?? envVars["CF_INSTANCE_PORT"] ??  envVars["VCAP_APP_PORT"] ?? "8090"
let port = Int(portString) ?? 8090

Kitura.addHTTPServer(onPort: port, with: router)
Kitura.run()
