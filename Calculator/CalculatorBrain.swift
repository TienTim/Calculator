//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Tien Do on 11/26/17.
//  Copyright © 2017 Tien Do. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    mutating func addUnaryOperation(named symbol: String, _ operation: @escaping (Double) -> Double) {
        operations[symbol] = Operation.unaryOperation(operation)
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    private var resultIsPending = false
    private var description = "" { didSet {  print(description) } }
    
    private var accumulator: Double?
    var variableName = String()
    private var brainVariables: [String : Double]?
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double) -> Double)
        case equal
    }
    
    private var operations: [String:Operation] = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "C": Operation.constant(0),
        "√": Operation.unaryOperation({ sqrt($0) }),
        "cos": Operation.unaryOperation({ cos($0) }),
        "±": Operation.unaryOperation({ -$0 }),
        "+": Operation.binaryOperation({ $0 + $1 }),
        "-": Operation.binaryOperation({ $0 - $1 }),
        "x": Operation.binaryOperation({ $0 * $1 }),
        "÷": Operation.binaryOperation({ $0 / $1 }),
        "=": Operation.equal
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            if symbol == "C" {
                setOperand(variable: "")
                description = ""
            }
            switch operation {
            case .constant(let value):
                accumulator = value
                if value == 0 {
                    pendingBinaryOperation = nil
                }
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
//                } else if variableName != nil {
//                    variable = function(variable)
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    description += symbol
                    pendingBinaryOperation = PendingBinaryOperations(firstOperand: accumulator!, function: function)
                    if !resultIsPending {
                        resultIsPending = true
                    }
                    accumulator = nil
                }
            case .equal:
                description = ""
                performPendingBinaryOperation()
                resultIsPending = false
                if result != nil {
                    description = String(result!)
                }
            }
        }
    }
    
    mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
        }
    }
    
    private struct PendingBinaryOperations {
        var firstOperand: Double
        var function: (Double,Double) -> Double
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand,secondOperand)
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperations?
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        description += "\(operand)"
    }
    
    mutating func setOperand(variable named: String) {
        variableName = named
        if named == "" {
            accumulator = nil
        } else if brainVariables != nil {
            accumulator = brainVariables![variableName]
        } else {
            accumulator = 0
        }
        description += named
    }
    
    mutating func evaluate(using variables: Dictionary<String,Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        if variables != nil {
            brainVariables = variables
        }
        return (brainVariables?[variableName], resultIsPending, description)
    }
    
}



