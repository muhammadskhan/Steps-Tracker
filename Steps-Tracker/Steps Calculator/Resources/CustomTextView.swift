//
//  CustomTextView.swift
//  FlowX
//
//  Created by Shahryar Khan on 14/01/2021.
//  Copyright © 2021 FocusBand. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTextView: UITextView {

    @IBInspectable var placeholder: String = "" {
        didSet {
            if self.text.count == 0 {
                self.text = placeholder
                self.textColor = self.placeholderColor
            }
        }
    }
    
    @IBInspectable var placeholderColor: UIColor = .gray
    @IBInspectable var textViewTextColor: UIColor = .black
    
    private var isPlaceholderActive = true
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
    }
    
    
}

extension CustomTextView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        self.textColor = textViewTextColor
        if isPlaceholderActive {
            self.text = ""
            self.isPlaceholderActive = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.text.count > 0 {
            self.isPlaceholderActive = false
        } else {
            self.text = placeholder
            self.textColor = placeholderColor
            self.isPlaceholderActive = true
        }
    }
}
