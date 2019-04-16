//
//  ViewController.swift
//  ENETS SDK QuickStart
//
//  Created by Jason Loh on 15/3/19.
//  Copyright © 2019 Nets. All rights reserved.
//

import UIKit
import ENETSLib

class ViewController: UIViewController, PaymentRequestCallback, PaymentRequestDelegate, UITextFieldDelegate {
    
    //Replace the UMID details with your own if you prefer
    static let apiKeyUat = "154eb31c-0f72-45bb-9249-84a1036fd1ca"
    static let secretKeyUat = "38a4b473-0295-439d-92e1-ad26a8c60279"
    static let MID_UAT = "UMID_877772003"
    
    //Replace These dummy URLs if you want to get the host response
    static let dummyB2sTxnEndUrlParam = "gateway=http://sit2.enets.sg"
    static let dummyB2sTxnEndUrl = "http://localhost:8088/MerchantApp/redirectServlet"
    static let dummyS2sTxnEndUrl = "https://sit2.enets.sg/MerchantApp/rest/s2sTxnEnd"
    
    @IBOutlet weak var apiKeyTextField: UITextField?
    @IBOutlet weak var secretKeyTextField: UITextField?
    @IBOutlet weak var umidTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiKeyTextField?.text = ViewController.apiKeyUat
        secretKeyTextField?.text = ViewController.secretKeyUat
        umidTextField?.text = ViewController.MID_UAT
        
        apiKeyTextField?.delegate = self
        secretKeyTextField?.delegate = self
        umidTextField?.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
    @IBAction func doClickPayment(_ sender: Any) {
        makePaymentWithDemoTxnRequest()
    }
    
    func makePaymentWithDemoTxnRequest() {
        let mid: String
        let apiKey: String
        let secretKey: String
        mid = umidTextField?.text ?? ViewController.apiKeyUat
        apiKey = apiKeyTextField?.text ?? ViewController.apiKeyUat
        secretKey = secretKeyTextField?.text ?? ViewController.secretKeyUat
        
        // Generate txn request with MID
        if let txnRequest      = getTxnRequestWithMID(mid: mid) {
            
            // Generate HMAC from txn request with secret key
            let hmac            = Util.hashShash256(message: txnRequest,
                                                    secretKey: secretKey)
            
            let paymentManager = PaymentRequestManager()
            paymentManager.paymentDelegate = self
            
            // Send Payment request to eNETS mobile SDK
            let request = PaymentRequest(hmac:hmac, txnReq : txnRequest)
            paymentManager.sendPaymentRequest(apiKey: apiKey,
                                              paymentRequest: request,
                                              viewController: self)
            
            
            // Send Payment request to eNETS mobile SDK(but using the Obj C wrapper this time)
            //            let wrapper = ENETSLibWrapper()
            //            wrapper.resultCallback = self
            //            wrapper.sendPaymentRequest(hmac: hmac, apiKey: apiKey, txnRequest: txnRequest, viewDelegate: self)
        }
    }
    
    
    private func getTxnRequestWithMID(mid : String) -> String? {
        
        let currentDateTime = Date()
        let merchantTxnRefFormatter = DateFormatter()
        
        merchantTxnRefFormatter.dateFormat = "yyyyMMdd HH:mm:ss.SS"
        merchantTxnRefFormatter.timeZone = TimeZone(identifier: "SGT")
        let merchantTxnRef = merchantTxnRefFormatter.string(from: currentDateTime)
        
        let merchantTxnDtmFormatter = DateFormatter()
        merchantTxnDtmFormatter.dateFormat = "yyyyMMdd HH:mm:ss.SSS"
        merchantTxnDtmFormatter.timeZone = TimeZone(identifier: "SGT")
        let merchantTxnDtm = merchantTxnDtmFormatter.string(from: currentDateTime)
        

        
        let jsonObject: [String: Any] = [
            "ss": "1",
            "msg" : [
                "netsMid" : mid,
                "tid": "",
                "paymentMode": "",
                "b2sTxnEndURLParam": ViewController.dummyB2sTxnEndUrlParam,
                "s2sTxnEndURLParam": "",
                "supMsg": "",
                "submissionMode" : "B",
                "txnAmount" : "1001",
                "merchantTxnRef" : merchantTxnRef,
                "merchantTxnDtm" : merchantTxnDtm,
                "paymentType" : "SALE",
                "currencyCode" : "SGD",
                "merchantTimeZone" : "+8:00",
                "b2sTxnEndURL" : ViewController.dummyB2sTxnEndUrl,
                "s2sTxnEndURL" : ViewController.dummyS2sTxnEndUrl,
                "clientType" : "S",
                "netsMidIndicator" : "U",
                "ipAddress" : "172.18.20.161",
                "language" : "en",
                "mobileOS" : "IOS",
                "ss" : "1"
            ]
        ]
        
        let jsonData: NSData
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject,
                                                  options: JSONSerialization.WritingOptions()) as NSData
            
            let txnRequest = NSString(data: jsonData as Data,
                                      encoding: String.Encoding.utf8.rawValue)! as String
            print("json string = \(txnRequest)")
            
            return txnRequest
            
        } catch _ {
            print ("JSON Failure")
        }
        return nil
    }
    
    
    //--------------------------------------------------------------------
    //MARK: - Methods to Display the Txn Response
    //--------------------------------------------------------------------
    func showDebitCreditMessage(hmac: String, keyId: String, txnResponse: String){
        var message : String!
        let hmacVerified = Util.hashShash256(message: txnResponse, secretKey: ViewController.secretKeyUat)
        print ("HMAC Verified   : \(hmacVerified)")
        message = "Debit Credit Response:\n\(txnResponse)"
        let alertController = UIAlertController(title: "TXN Response",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: {
            (alertAction : UIAlertAction) in
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func showNonDebitCreditMessage(txnStatus: String){
        var message : String!
        print ("- - - - - - - - - - - - - - - - - - - - - - - - - - - ")
        print ("Payment completed : Non Debit Credit Response")
        print ("Response Txn Status : \(txnStatus)" )
        message = "Non Debit Credit Response:\n\(txnStatus)"
        let alertController = UIAlertController(title: "TXN Response",
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: {
            (alertAction : UIAlertAction) in
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func showErrorMessage(actionCode: String, withResponseCode responseCode: String) {
        let alertController = UIAlertController(title: "Error Response",
                                                message: "\(actionCode)-\(responseCode)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Continue", style: .cancel, handler: {
            (alertAction : UIAlertAction) in
            
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    //--------------------------------------------------------------------
    //MARK: - PaymentRequestDelegate methods
    //--------------------------------------------------------------------
    func onResult(response: PaymentResponse) {
        if response is DebitCreditResponse {
            let debitCreditResponse = response as! DebitCreditResponse
            let hmac = debitCreditResponse.hmac
            let keyId = debitCreditResponse.keyId
            let txnRes = debitCreditResponse.txnRes
            
            showDebitCreditMessage(hmac: hmac, keyId: keyId, txnResponse: txnRes)
        } else if response is NonDebitCreditResponse {
            let nonDebitCreditResponse = response as! NonDebitCreditResponse
            let txnStatus = nonDebitCreditResponse.txn_Status
            
            showNonDebitCreditMessage(txnStatus: txnStatus)
        }
    }
    
    func onFailure(error: NETSError) {
        showErrorMessage(actionCode: error.actionCode, withResponseCode: error.responseCode)
    }
    
    //--------------------------------------------------------------------
    //MARK: - PaymentRequestCallback methods
    //--------------------------------------------------------------------
    func onResultDebitCredit(hmac: String, withKeyId keyId: String, withResponse txnResponse: String) {
        showDebitCreditMessage(hmac: hmac, keyId: keyId, txnResponse: txnResponse)
    }
    
    func onResultNonDebitCredit(txnStatus: String) {
        showNonDebitCreditMessage(txnStatus: txnStatus)
    }
    
    func onError(actionCode: String, withResponseCode responseCode: String) {
        showErrorMessage(actionCode: actionCode, withResponseCode: responseCode)
    }
}

