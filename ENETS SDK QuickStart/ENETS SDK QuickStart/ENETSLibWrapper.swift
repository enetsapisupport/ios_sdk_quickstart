//
//  ENETSLibWrapper.swift
//  ENETS SDK QuickStart
//
//  Created by Jason Loh on 15/3/19.
//  Copyright © 2019 Nets. All rights reserved.
//

import UIKit
import ENETSLib

//Sample Objective C Wrapper
@objc protocol PaymentRequestCallback {
    func onResultDebitCredit(hmac: String, withKeyId keyId:String, withResponse txnResponse: String)
    func onResultNonDebitCredit(txnStatus: String)
    func onError(actionCode: String, withResponseCode responseCode: String)
}

class ENETSLibWrapper: NSObject {
    
    var resultCallback: PaymentRequestCallback?
    
    @objc func sendPaymentRequest(hmac: String,
                                  apiKey: String,
                                  txnRequest: String,
                                  viewDelegate: UIViewController) {
        
        if viewDelegate.conforms(to: PaymentRequestCallback.self) {
            self.resultCallback = viewDelegate as? PaymentRequestCallback
        }
        let paymentManager = PaymentRequestManager()
        paymentManager.paymentDelegate = self
        
        // Send Payment request to eNETS mobile SDK
        let request = PaymentRequest(hmac:hmac, txnReq : txnRequest)
        paymentManager.sendPaymentRequest(apiKey: apiKey,
                                          paymentRequest: request,
                                          viewController: viewDelegate)
    }
    
}

extension ENETSLibWrapper : PaymentRequestDelegate {
    func onResult(response: PaymentResponse) {
        if response is DebitCreditResponse {
            let debitCreditResponse = response as! DebitCreditResponse
            let hmac = debitCreditResponse.hmac
            let keyId = debitCreditResponse.keyId
            let txnRes = debitCreditResponse.txnRes
            
            if let callback = self.resultCallback {
                callback.onResultDebitCredit(hmac: hmac, withKeyId: keyId, withResponse: txnRes)
            }
        } else if response is NonDebitCreditResponse {
            let nonDebitCreditResponse = response as! NonDebitCreditResponse
            let txnStatus = nonDebitCreditResponse.txn_Status
            
            if let callback = self.resultCallback {
                callback.onResultNonDebitCredit(txnStatus: txnStatus)
            }
        }
    }
    
    func onFailure(error: NETSError) {
        if let callback = self.resultCallback {
            callback.onError(actionCode: error.actionCode, withResponseCode: error.responseCode)
        }
    }
}
