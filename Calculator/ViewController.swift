//
//  ViewController.swift
//  Calculator
//
//  Created by Tien Do on 11/26/17.
//  Copyright © 2017 Tien Do. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var memoryLabel: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    
    private func showSizeClasses() {
        if !userIsInTheMiddleOfTyping {
            display.textAlignment = .center
            display.text = "width " + traitCollection.horizontalSizeClass.description + " height" + traitCollection.verticalSizeClass.description
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        memoryLabel.isHidden = true
        showSizeClasses()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { coordinator in self.showSizeClasses() }, completion: nil)
    }

    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            var textToDisplay = String(newValue)
            if textToDisplay.hasSuffix(".0") {
                textToDisplay = String(Int(newValue))
            }
            display.text = textToDisplay
        }
    }
    
    private var brain = CalculatorBrain()

    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
        let (_, _, description) = brain.evaluate()
        descriptionLabel.text = description
    }
    
    @IBAction func setMemory(_ sender: UIButton) {
        let number = display.text!
        brain.variableName = "M"
        let _ = brain.evaluate(using: ["M" : Double(number)!])
        let hideMemory = number == "0"
        memoryLabel.text = number
        memoryLabel.isHidden = hideMemory
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func callMemory(_ sender: UIButton) {
        brain.setOperand(variable: brain.variableName)
        let (result, _, _) = brain.evaluate()
        if result != nil {
            displayValue = result!
        }
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func undo(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            var textToDisplay = display.text!
            textToDisplay.removeLast()
            display.text = textToDisplay
        } else {
            display.text = "0"
            brain.setOperand(variable: "")
        }
    }
    
}

extension UIUserInterfaceSizeClass: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .compact: return "Compact"
        case .regular: return "Regular"
        case .unspecified: return "??"
        }
    }
    
}

