
import UIKit

class ViewController: UIViewController, URLSessionDelegate {

	override func viewDidLoad() {

		super.viewDidLoad()

		guard
//			let certificateURL = Bundle(for: ViewController.self).url(forResource: "wireless.danieltull.co.uk", withExtension: "cer"),
			let certificateURL = Bundle(for: ViewController.self).url(forResource: "Daniel Tull CA 2017", withExtension: "cer"),
			let certificateData = try? Data(contentsOf: certificateURL),
			let certificate = SecCertificateCreateWithData(nil, certificateData as CFData)
		else {
			return
		}

		var secTrust: SecTrust?
		let policy = SecPolicyCreateSSL(true, "wireless.danieltull.co.uk" as CFString)
		SecTrustCreateWithCertificates(certificate, policy, &secTrust)

		guard let trust = secTrust else {
			return
		}

		SecTrustSetAnchorCertificates(trust, [certificate] as CFArray)
//		SecTrustSetAnchorCertificatesOnly(trust, false)

		let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
		let url = URL(string: "https://wireless.danieltull.co.uk/api/status.json")!
		let task = session.dataTask(with: url) { (data, response, error) in

			if let data = data {
				print("Data: ", data)
			}

			if let error = error {
				print("Error: ", error)
			}

			if let response = response {
				print("Response: ", response)
			}
		}

		task.resume()
	}

	func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

		guard let trust = challenge.protectionSpace.serverTrust else {
			print("FAILED")
			completionHandler(.cancelAuthenticationChallenge, nil)
			return
		}

		let credential = URLCredential(trust: trust)
		completionHandler(.useCredential, credential)
	}
}
