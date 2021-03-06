//
//  SignUpVC.swift
//  Gourmet
//
//  Created by David Martinez on 08/12/2016.
//  Copyright © 2016 Atenea. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController, SignUpView, UITextFieldDelegate {

    @IBOutlet weak var loginBoxView : UIView!
    @IBOutlet weak var cardTF : UITextField!
    @IBOutlet weak var passwordTF : UITextField!
    @IBOutlet weak var signUpButton : UIButton!
    @IBOutlet weak var loadingView : UIActivityIndicatorView!
    @IBOutlet weak var alignYSignUpContainer : NSLayoutConstraint!
    
    private var presenter : SignUpPresenter!
    
    // MARK: UIViewController
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        presenter = SignUpFactory.shared.getPresenter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        presenter = SignUpFactory.shared.getPresenter()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        decorViews()
        cardTF.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControlEvents.editingChanged)
    }
    
    private func decorViews () {
        signUpButton.layer.cornerRadius = 6.0
        signUpButton.clipsToBounds = true
    }
    
    @objc
    private func textFieldDidChange (textField : UITextField) {
        guard let text = textField.text?.characters else { return }
        var textFiltered = text.filter({$0 != "-"})
        
        if (textFiltered.count > 12) {
            textFiltered.insert("-", at: 12)
        }
        
        if (textFiltered.count > 8) {
            textFiltered.insert("-", at: 8)
        }
        
        if (textFiltered.count > 4) {
            textFiltered.insert("-", at: 4)
        }
        
        textField.text = String(textFiltered)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerForKeyboardEvents()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cardTF.resignFirstResponder()
        passwordTF.resignFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unregisterForKeyboardEvents()
    }
    
    private func registerForKeyboardEvents () {
        let center = NotificationCenter.default
        center.addObserver(self, selector:
            #selector(keyboardWillShow(aNotification:)),
                           name: NSNotification.Name.UIKeyboardWillShow,
                           object: nil)
        center.addObserver(self, selector:
            #selector(keyboardWillHide(aNotification:)),
                           name: NSNotification.Name.UIKeyboardWillHide,
                           object: nil)
    }
    
    private func unregisterForKeyboardEvents () {
        let center = NotificationCenter.default
        center.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc
    private func keyboardWillShow (aNotification : NSNotification) {
        
        guard let userInfo = aNotification.userInfo else { return }
        guard let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard loginBoxView.frame.maxY > endFrame.minY else { return }
        
        let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
        if endFrame.origin.y >= UIScreen.main.bounds.size.height {
            alignYSignUpContainer.constant = 0.0
        } else {
            let additionalMargin : CGFloat = 20.0
            let threshold = (loginBoxView.frame.maxY - endFrame.minY) + additionalMargin
            alignYSignUpContainer.constant = 0.0 - threshold //endFrame.size.height ?? 0.0
        }
        
        UIView.animate(withDuration: duration,
                       delay: TimeInterval(0),
                       options: animationCurve,
                       animations: { self.view.layoutIfNeeded() },
                       completion: nil)
    }
    
    @objc
    private func keyboardWillHide (aNotification : NSNotification) {
        guard let userInfo = aNotification.userInfo else { return }
        
        let duration : TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
        let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
        alignYSignUpContainer.constant = 0.0
        UIView.animate(withDuration: duration,
                       delay: TimeInterval(0),
                       options: animationCurve,
                       animations: { self.view.layoutIfNeeded() },
                       completion: nil)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        cardTF.resignFirstResponder()
        passwordTF.resignFirstResponder()
    }
    
    // MARK: SignUpView
    func showLoading() {
        loadingView.isHidden = false
    }
    
    func hideLoading() {
        loadingView.isHidden = true
    }
    
    func showError(message: String) {
        let titleMessage = Localizable.getString(key: "signUp_alert_title")
        let okMessage = Localizable.getString(key: "signUp_alert_ok")
        let alert = UIAlertController(title: titleMessage, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: okMessage, style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }

    func showAccount(account: AccountVM) {
        cardTF.text = ""
        passwordTF.text = ""
    }
    
    // MARK: Actions
    @IBAction func actionSignUp (_ sender : UIButton) {
        performSignUp()
    }
    
    // MARK: UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == cardTF {
            passwordTF.becomeFirstResponder()
        } else {
            passwordTF.resignFirstResponder()
            performSignUp()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == cardTF {
            guard let textWritten = textField.text else { return true }
            let maxCardLength = 16
            let maxAdditionarCharsLength = 3
            let maxLength = maxCardLength + maxAdditionarCharsLength
            if textWritten.characters.count + string.characters.count > maxLength {
                return false
            }
        }
        
        return true
    }
    
    private func performSignUp () {
        let cardId = cardTF.text?.components(separatedBy: "-").filter({$0 != "-"}).joined()
        presenter.signUp(cardId: cardId, password: passwordTF.text, view: self)
    }
}
